import Foundation
import Combine

/// One book as shown on the shelf.
struct LibraryItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var author: String
    var chapterCount: Int
    var modified: Date
}

/// Manages where books live so the writer never touches a file. Books are `.eli`
/// packages in the app's sandbox container; the library lists them, creates them,
/// opens them, and deletes them. Survives app updates; backed up automatically.
final class LibraryStore: ObservableObject {
    @Published private(set) var items: [LibraryItem] = []

    private let fileManager = FileManager.default

    private var directory: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("Eli/Library", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func url(for id: UUID) -> URL {
        directory.appendingPathComponent("\(id.uuidString).eli", isDirectory: true)
    }

    init() { reload() }

    func exists(_ id: UUID) -> Bool { fileManager.fileExists(atPath: url(for: id).path) }

    func reload() {
        let urls = (try? fileManager.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        items = urls
            .filter { $0.pathExtension == "eli" }
            .compactMap { url -> LibraryItem? in
                guard let id = UUID(uuidString: url.deletingPathExtension().lastPathComponent),
                      let data = try? Data(contentsOf: url.appendingPathComponent("manifest.json")),
                      let manifest = try? decoder.decode(BookManifest.self, from: data) else { return nil }
                let modified = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                return LibraryItem(
                    id: id,
                    title: manifest.title.isEmpty ? "Untitled Book" : manifest.title,
                    author: manifest.author,
                    chapterCount: manifest.chapters.count,
                    modified: modified
                )
            }
            .sorted { $0.modified > $1.modified }
    }

    @discardableResult
    func createBook() -> UUID {
        let id = UUID()
        save(Book(), id: id)
        reload()
        return id
    }

    func load(_ id: UUID) -> Book? {
        guard let wrapper = try? FileWrapper(url: url(for: id)),
              let root = wrapper.fileWrappers else { return nil }
        return try? Book.decode(from: root)
    }

    func save(_ book: Book, id: UUID) {
        do {
            let wrapper = try book.encodeToWrapper(now: Date())
            try wrapper.write(to: url(for: id), options: .atomic, originalContentsURL: nil)
        } catch {
            NSLog("Eli: failed to save book \(id): \(error)")
        }
    }

    func delete(_ id: UUID) {
        try? fileManager.removeItem(at: url(for: id))
        reload()
    }
}
