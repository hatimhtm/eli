import Foundation

/// Progress status for a chapter or scene. Colors live in DesignSystem (no green).
enum WritingStatus: String, Codable, CaseIterable, Identifiable {
    case draft, revising, done
    var id: String { rawValue }
    var label: String {
        switch self {
        case .draft:    return "Draft"
        case .revising: return "Revising"
        case .done:     return "Done"
        }
    }
}

/// A chapter as held in memory while editing. The body text lives in its own
/// Markdown file inside the `.eli` package; only id + title are mirrored into
/// the manifest so the binder can render without loading every chapter's text.
struct Chapter: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    var title: String
    /// Source-language manuscript (e.g. Tagalog), Markdown. Used when the
    /// chapter has no scenes; otherwise the scenes hold the text.
    var source: String
    /// Target-language translation (e.g. English), Markdown. `nil` until translated.
    var translation: String?
    /// Optional sub-sections. Empty = a plain chapter (the simple default).
    /// Scenes are never forced; the writer adds them only if she wants them.
    var scenes: [BookScene]
    var status: WritingStatus

    init(id: UUID = UUID(), title: String = "", source: String = "", translation: String? = nil,
         scenes: [BookScene] = [], status: WritingStatus = .draft) {
        self.id = id
        self.title = title
        self.source = source
        self.translation = translation
        self.scenes = scenes
        self.status = status
    }

    var hasScenes: Bool { !scenes.isEmpty }

    /// Word count for the whole chapter — its scenes if it has them, else its own text.
    var wordCount: Int {
        hasScenes ? scenes.reduce(0) { $0 + $1.wordCount } : Self.countWords(source)
    }

    /// The chapter's source text for export — scenes joined, or its own text.
    var effectiveSource: String {
        hasScenes ? scenes.map(\.source).joined(separator: "\n\n") : source
    }

    /// The chapter's translation for export — scenes joined, or its own translation.
    var effectiveTranslation: String? {
        guard hasScenes else { return translation }
        let parts = scenes.map { $0.translation ?? $0.source }
        return parts.joined(separator: "\n\n")
    }

    static func countWords(_ s: String) -> Int {
        s.split(whereSeparator: { $0.isWhitespace }).count
    }
}

/// An optional sub-section of a chapter (e.g. a scene break in a novel).
/// Named `BookScene` to avoid colliding with SwiftUI's `Scene` protocol.
struct BookScene: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    var title: String
    var source: String
    var translation: String?
    var status: WritingStatus

    init(id: UUID = UUID(), title: String = "", source: String = "", translation: String? = nil,
         status: WritingStatus = .draft) {
        self.id = id
        self.title = title
        self.source = source
        self.translation = translation
        self.status = status
    }

    var wordCount: Int { Chapter.countWords(source) }
}

/// Lightweight scene reference in the manifest (order + title + status).
struct SceneMeta: Codable, Equatable {
    let id: UUID
    var title: String
    var status: WritingStatus?
}

/// Lightweight chapter reference stored in the manifest to preserve order + title.
/// `scenes`/`status` are optional so books written before they existed still decode.
struct ChapterMeta: Codable, Equatable {
    let id: UUID
    var title: String
    var scenes: [SceneMeta]?
    var status: WritingStatus?
}

/// Per-book settings. Grows in later phases (theme, font, goals, deadline).
struct BookSettings: Codable, Equatable {
    var wordCountGoal: Int?
    var deadline: Date?

    init(wordCountGoal: Int? = nil, deadline: Date? = nil) {
        self.wordCountGoal = wordCountGoal
        self.deadline = deadline
    }
}

/// `manifest.json` — the book's metadata and chapter order. Body text is NOT here.
struct BookManifest: Codable, Equatable {
    var title: String
    var author: String
    /// BCP-47-ish language codes. Defaults to Maria's edition: Tagalog → English.
    var sourceLanguage: String
    var targetLanguage: String
    var chapters: [ChapterMeta]
    var settings: BookSettings
    var schemaVersion: Int
    var createdAt: Date
    var modifiedAt: Date
}

// MARK: - Glossary (translation style memory)

enum CharacterGender: String, Codable, CaseIterable {
    case feminine, masculine, neutral
}

/// One glossary entry — a recurring term, name, or do-not-translate item. The
/// optional gender resolves Tagalog's gender-neutral pronoun *siya* per character.
struct GlossaryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var source: String
    var target: String
    var note: String?
    var gender: CharacterGender?

    init(id: UUID = UUID(), source: String, target: String, note: String? = nil, gender: CharacterGender? = nil) {
        self.id = id
        self.source = source
        self.target = target
        self.note = note
        self.gender = gender
    }
}

/// `glossary.json` — translation style memory carried across chapters.
struct Glossary: Codable, Equatable {
    var entries: [GlossaryEntry]

    init(entries: [GlossaryEntry] = []) {
        self.entries = entries
    }
}
