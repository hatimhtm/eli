import Foundation

/// A book, stored as a `.eli` package (folder) the app manages automatically in
/// its library — the writer never sees or locates a file:
///
///     <id>.eli/
///       manifest.json          metadata + chapter/scene order + status
///       glossary.json          translation style memory
///       chapters/
///         <uuid>.md            source manuscript
///         <uuid>.translation.md  translation, if present
///
/// Plain text + JSON keeps it inspectable and git-friendly. Encode/decode are
/// pure functions over a `FileWrapper`, so they're unit-testable.
struct Book: Equatable {
    var manifest: BookManifest
    var chapters: [Chapter]
    var glossary: Glossary

    init(manifest: BookManifest, chapters: [Chapter], glossary: Glossary) {
        self.manifest = manifest
        self.chapters = chapters
        self.glossary = glossary
    }

    /// A fresh, empty book.
    init() {
        let now = Date()
        let first = Chapter(title: "Chapter One")
        self.chapters = [first]
        self.glossary = Glossary()
        self.manifest = BookManifest(
            title: "Untitled Book",
            author: "",
            sourceLanguage: "tl",   // Tagalog (Maria's edition default)
            targetLanguage: "en",   // English
            chapters: [ChapterMeta(id: first.id, title: first.title, scenes: nil, status: .draft)],
            settings: BookSettings(),
            schemaVersion: 1,
            createdAt: now,
            modifiedAt: now
        )
    }

    // MARK: Decode

    static func decode(from root: [String: FileWrapper]) throws -> Book {
        guard let manifestData = root["manifest.json"]?.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let decoder = Book.jsonDecoder
        let manifest = try decoder.decode(BookManifest.self, from: manifestData)

        let glossary: Glossary
        if let data = root["glossary.json"]?.regularFileContents,
           let g = try? decoder.decode(Glossary.self, from: data) {
            glossary = g
        } else {
            glossary = Glossary()
        }

        let files = root["chapters"]?.fileWrappers ?? [:]
        func text(_ name: String) -> String? {
            files[name]?.regularFileContents.flatMap { String(data: $0, encoding: .utf8) }
        }

        let chapters: [Chapter] = manifest.chapters.map { meta in
            let scenes: [BookScene] = (meta.scenes ?? []).map { sm in
                BookScene(id: sm.id, title: sm.title,
                          source: text("\(sm.id.uuidString).md") ?? "",
                          translation: text("\(sm.id.uuidString).translation.md"),
                          status: sm.status ?? .draft)
            }
            return Chapter(
                id: meta.id, title: meta.title,
                source: text("\(meta.id.uuidString).md") ?? "",
                translation: text("\(meta.id.uuidString).translation.md"),
                scenes: scenes,
                status: meta.status ?? .draft
            )
        }
        return Book(manifest: manifest, chapters: chapters, glossary: glossary)
    }

    // MARK: Encode

    func encodeToWrapper(now: Date) throws -> FileWrapper {
        var manifest = self.manifest
        manifest.chapters = chapters.map { chapter in
            ChapterMeta(
                id: chapter.id,
                title: chapter.title,
                scenes: chapter.scenes.isEmpty ? nil : chapter.scenes.map { SceneMeta(id: $0.id, title: $0.title, status: $0.status) },
                status: chapter.status
            )
        }
        manifest.modifiedAt = now

        let encoder = Book.jsonEncoder
        let root = FileWrapper(directoryWithFileWrappers: [:])
        root.addRegularFile(withContents: try encoder.encode(manifest), preferredFilename: "manifest.json")
        root.addRegularFile(withContents: try encoder.encode(glossary), preferredFilename: "glossary.json")

        let chaptersDir = FileWrapper(directoryWithFileWrappers: [:])
        func write(_ id: UUID, source: String, translation: String?) {
            chaptersDir.addRegularFile(withContents: Data(source.utf8), preferredFilename: "\(id.uuidString).md")
            if let translation {
                chaptersDir.addRegularFile(withContents: Data(translation.utf8), preferredFilename: "\(id.uuidString).translation.md")
            }
        }
        for chapter in chapters {
            write(chapter.id, source: chapter.source, translation: chapter.translation)
            for scene in chapter.scenes {
                write(scene.id, source: scene.source, translation: scene.translation)
            }
        }
        chaptersDir.preferredFilename = "chapters"
        root.addFileWrapper(chaptersDir)
        return root
    }

    // MARK: JSON

    private static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    private static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
