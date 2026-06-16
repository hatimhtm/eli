import UniformTypeIdentifiers

/// Native, dependency-free export targets. EPUB is built with our own ZIP writer;
/// print-ready PDF (6×9) is rendered with CoreText — no bundled Pandoc needed.
enum ExportFormat: String, CaseIterable, Identifiable {
    case pdf, epub, docx, rtf, markdown, plainText
    var id: String { rawValue }

    var label: String {
        switch self {
        case .pdf:       return "PDF (print-ready, 6×9)"
        case .epub:      return "EPUB (ebook)"
        case .docx:      return "Word (.docx)"
        case .rtf:       return "Rich Text (.rtf)"
        case .markdown:  return "Markdown (.md)"
        case .plainText: return "Plain Text (.txt)"
        }
    }

    var fileExtension: String {
        switch self {
        case .pdf:       return "pdf"
        case .epub:      return "epub"
        case .docx:      return "docx"
        case .rtf:       return "rtf"
        case .markdown:  return "md"
        case .plainText: return "txt"
        }
    }

    var contentType: UTType {
        switch self {
        case .pdf:       return .pdf
        case .epub:      return UTType("org.idpf.epub-container") ?? (UTType(filenameExtension: "epub") ?? .data)
        case .docx:      return UTType("org.openxmlformats.wordprocessingml.document") ?? .data
        case .rtf:       return .rtf
        case .markdown:  return UTType(filenameExtension: "md") ?? .plainText
        case .plainText: return .plainText
        }
    }
}
