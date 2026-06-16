import AppKit

/// A tiny Markdown subset (bold `**`, italic `*`, `#`/`##` headings, blank-line
/// paragraphs) — enough for prose. Used so exports render real emphasis instead
/// of showing literal asterisks.
enum Markdown {

    // MARK: Attributed (DOCX / RTF / PDF)

    static func attributed(_ markdown: String, body: NSFont, heading: NSFont,
                           bodyStyle: NSParagraphStyle) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let lines = markdown.components(separatedBy: "\n")
        for (i, line) in lines.enumerated() {
            if let h = headingContent(line) {
                result.append(inline(h, baseFont: heading, style: bodyStyle))
            } else {
                result.append(inline(line, baseFont: body, style: bodyStyle))
            }
            if i < lines.count - 1 { result.append(NSAttributedString(string: "\n")) }
        }
        return result
    }

    /// Inline emphasis → attributed runs. `**` toggles bold, `*` toggles italic.
    private static func inline(_ s: String, baseFont: NSFont, style: NSParagraphStyle) -> NSAttributedString {
        let out = NSMutableAttributedString()
        let chars = Array(s)
        var i = 0
        var buffer = ""
        var bold = false, italic = false

        func flush() {
            guard !buffer.isEmpty else { return }
            var font = baseFont
            if bold { font = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask) }
            if italic { font = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask) }
            out.append(NSAttributedString(string: buffer, attributes: [.font: font, .paragraphStyle: style]))
            buffer = ""
        }

        while i < chars.count {
            if chars[i] == "*" {
                if i + 1 < chars.count && chars[i + 1] == "*" { flush(); bold.toggle(); i += 2; continue }
                flush(); italic.toggle(); i += 1; continue
            }
            buffer.append(chars[i]); i += 1
        }
        flush()
        return out
    }

    // MARK: Plain text (strip markers)

    static func plain(_ markdown: String) -> String {
        markdown
            .components(separatedBy: "\n")
            .map { line -> String in
                let content = headingContent(line) ?? line
                return content.replacingOccurrences(of: "**", with: "").replacingOccurrences(of: "*", with: "")
            }
            .joined(separator: "\n")
    }

    // MARK: HTML (EPUB)

    /// Convert one block (paragraph) to an HTML element. Headings → <h2>, else <p>.
    static func htmlBlock(_ block: String) -> String {
        if let h = headingContent(block) {
            return "<h2>\(inlineHTML(h))</h2>"
        }
        return "<p>\(inlineHTML(block))</p>"
    }

    private static func inlineHTML(_ s: String) -> String {
        let chars = Array(s)
        var i = 0
        var html = ""
        var bold = false, italic = false
        func emit(_ c: Character) {
            switch c {
            case "&": html += "&amp;"
            case "<": html += "&lt;"
            case ">": html += "&gt;"
            default: html.append(c)
            }
        }
        while i < chars.count {
            if chars[i] == "*" {
                if i + 1 < chars.count && chars[i + 1] == "*" {
                    html += bold ? "</strong>" : "<strong>"; bold.toggle(); i += 2; continue
                }
                html += italic ? "</em>" : "<em>"; italic.toggle(); i += 1; continue
            }
            emit(chars[i]); i += 1
        }
        if italic { html += "</em>" }
        if bold { html += "</strong>" }
        return html
    }

    // MARK: Helpers

    /// Returns the heading text if the line is `# ` or `## `, else nil.
    private static func headingContent(_ line: String) -> String? {
        if line.hasPrefix("## ") { return String(line.dropFirst(3)) }
        if line.hasPrefix("# ")  { return String(line.dropFirst(2)) }
        return nil
    }
}
