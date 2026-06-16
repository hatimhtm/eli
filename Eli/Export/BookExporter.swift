import AppKit
import CoreText

/// Assembles the manuscript into a single document and serializes it to the
/// chosen format. `useTranslation` exports the target-language text (falling
/// back to source where a chapter hasn't been translated yet).
struct BookExporter {
    let book: Book
    let useTranslation: Bool

    private var author: String { book.manifest.author }
    private var title: String {
        book.manifest.title.isEmpty ? "Untitled Book" : book.manifest.title
    }

    private func body(_ chapter: Chapter) -> String {
        // Scene-aware: a chapter with scenes exports its joined scenes.
        useTranslation ? (chapter.effectiveTranslation ?? chapter.effectiveSource) : chapter.effectiveSource
    }

    func data(for format: ExportFormat) throws -> Data {
        switch format {
        case .markdown:  return Data(markdown().utf8)
        case .plainText: return Data(plainText().utf8)
        case .rtf:       return try richData(.rtf)
        case .docx:      return try richData(.officeOpenXML)
        case .pdf:       return pdfData()
        case .epub:      return epubData()
        }
    }

    // MARK: Text formats

    private func markdown() -> String {
        var out = "# \(title)\n\n"
        if !author.isEmpty { out += "_\(author)_\n\n" }
        for chapter in book.chapters {
            out += "\n\n## \(chapter.title.isEmpty ? "Untitled" : chapter.title)\n\n"
            out += body(chapter) + "\n"
        }
        return out
    }

    private func plainText() -> String {
        var out = title + "\n\n"
        if !author.isEmpty { out += author + "\n\n" }
        for chapter in book.chapters {
            out += "\n\n" + (chapter.title.isEmpty ? "Untitled" : chapter.title) + "\n\n"
            out += Markdown.plain(body(chapter)) + "\n"
        }
        return out
    }

    // MARK: Rich formats (via the system text engine)

    private func richData(_ type: NSAttributedString.DocumentType) throws -> Data {
        let doc = attributedManuscript()
        return try doc.data(
            from: NSRange(location: 0, length: doc.length),
            documentAttributes: [.documentType: type]
        )
    }

    private func attributedManuscript() -> NSAttributedString {
        let titleFont = NSFont(name: "Iowan Old Style", size: 28) ?? .boldSystemFont(ofSize: 28)
        let headingFont = NSFont(name: "Iowan Old Style", size: 18) ?? .boldSystemFont(ofSize: 18)
        let bodyFont = NSFont(name: "Iowan Old Style", size: 13) ?? .systemFont(ofSize: 13)

        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.lineSpacing = 3
        bodyStyle.paragraphSpacing = 9

        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: title + "\n", attributes: [.font: titleFont]))
        if !author.isEmpty {
            let italic = NSFontManager.shared.convert(bodyFont, toHaveTrait: .italicFontMask)
            result.append(NSAttributedString(string: author + "\n", attributes: [.font: italic]))
        }

        for chapter in book.chapters {
            result.append(NSAttributedString(
                string: "\n\(chapter.title.isEmpty ? "Untitled" : chapter.title)\n\n",
                attributes: [.font: headingFont]
            ))
            // Render Markdown emphasis (bold/italic/headings) instead of literal markers.
            result.append(Markdown.attributed(body(chapter), body: bodyFont,
                                               heading: headingFont, bodyStyle: bodyStyle))
            result.append(NSAttributedString(string: "\n"))
        }
        return result
    }

    // MARK: PDF (CoreText pagination, 6×9 print trim)

    private func pdfData() -> Data {
        let pageSize = CGSize(width: 6 * 72, height: 9 * 72) // 6×9" — standard KDP trim
        let margin: CGFloat = 54                              // 0.75"
        let attributed = attributedManuscript()

        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let pdf = NSMutableData()
        guard let consumer = CGDataConsumer(data: pdf) else { return Data() }
        var mediaBox = CGRect(origin: .zero, size: pageSize)
        guard let ctx = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { return Data() }

        let textRect = CGRect(x: margin, y: margin,
                              width: pageSize.width - 2 * margin,
                              height: pageSize.height - 2 * margin)
        let path = CGPath(rect: textRect, transform: nil)
        let total = attributed.length
        var start = 0
        while start < total {
            ctx.beginPDFPage(nil)
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(start, 0), path, nil)
            CTFrameDraw(frame, ctx)
            let visible = CTFrameGetVisibleStringRange(frame)
            ctx.endPDFPage()
            if visible.length == 0 { break } // safety: avoid infinite loop
            start += visible.length
        }
        ctx.closePDF()
        return pdf as Data
    }

    // MARK: EPUB 3 (our own ZIP writer — no dependencies)

    private func epubData() -> Data {
        let lang = useTranslation ? book.manifest.targetLanguage : book.manifest.sourceLanguage
        let bookID = "urn:uuid:\(UUID().uuidString)"

        var zip = ZipArchive()
        // EPUB requires `mimetype` first and uncompressed (store-only satisfies this).
        zip.add("mimetype", Data("application/epub+zip".utf8))
        zip.add("META-INF/container.xml", Data("""
        <?xml version="1.0" encoding="UTF-8"?>
        <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
          <rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
        </container>
        """.utf8))
        zip.add("OEBPS/style.css", Data("""
        body { font-family: Georgia, serif; line-height: 1.5; margin: 5%; }
        h1 { font-size: 1.6em; margin: 1.5em 0 0.8em; }
        h2 { font-size: 1.3em; margin: 2em 0 0.6em; }
        p { margin: 0 0 0.9em; text-indent: 1.2em; }
        """.utf8))

        var manifestItems = ""
        var spineItems = ""
        var navList = ""
        for (index, chapter) in book.chapters.enumerated() {
            let file = "chap\(index + 1).xhtml"
            let chTitle = chapter.title.isEmpty ? "Chapter \(index + 1)" : chapter.title
            zip.add("OEBPS/\(file)", Data(chapterXHTML(title: chTitle, body: body(chapter), lang: lang).utf8))
            manifestItems += "<item id=\"ch\(index + 1)\" href=\"\(file)\" media-type=\"application/xhtml+xml\"/>\n"
            spineItems += "<itemref idref=\"ch\(index + 1)\"/>\n"
            navList += "<li><a href=\"\(file)\">\(escapeXML(chTitle))</a></li>\n"
        }

        zip.add("OEBPS/nav.xhtml", Data("""
        <?xml version="1.0" encoding="UTF-8"?>
        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="\(lang)">
        <head><title>\(escapeXML(title))</title></head>
        <body><nav epub:type="toc" id="toc"><h1>Contents</h1><ol>\(navList)</ol></nav></body>
        </html>
        """.utf8))

        zip.add("OEBPS/content.opf", Data("""
        <?xml version="1.0" encoding="UTF-8"?>
        <package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="bookid" xml:lang="\(lang)">
          <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
            <dc:identifier id="bookid">\(bookID)</dc:identifier>
            <dc:title>\(escapeXML(title))</dc:title>
            <dc:language>\(lang)</dc:language>
            <dc:creator>\(escapeXML(author))</dc:creator>
            <meta property="dcterms:modified">2026-01-01T00:00:00Z</meta>
          </metadata>
          <manifest>
            <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
            <item id="css" href="style.css" media-type="text/css"/>
            \(manifestItems)
          </manifest>
          <spine>
            <itemref idref="nav" linear="no"/>
            \(spineItems)
          </spine>
        </package>
        """.utf8))

        return zip.finalize()
    }

    private func chapterXHTML(title: String, body: String, lang: String) -> String {
        let paragraphs = body
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { Markdown.htmlBlock($0) } // renders **bold**/*italic*/# headings
            .joined(separator: "\n")
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="\(lang)">
        <head><title>\(escapeXML(title))</title><link rel="stylesheet" type="text/css" href="style.css"/></head>
        <body><h1>\(escapeXML(title))</h1>\n\(paragraphs)</body>
        </html>
        """
    }

    private func escapeXML(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
