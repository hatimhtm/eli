import Foundation

/// A full, self-contained snapshot of a book — everything needed to restore it.
struct BookSnapshot: Codable {
    var manifest: BookManifest
    var chapters: [Chapter]
    var glossary: Glossary

    init(_ book: Book) {
        manifest = book.manifest
        chapters = book.chapters
        glossary = book.glossary
    }
}

struct BackupEntry: Identifiable {
    let url: URL
    let date: Date
    let title: String
    var id: URL { url }
}

/// Automatic, storage-tiny safety net. Each backup is the whole book encoded to
/// JSON and **LZFSE-compressed** (text compresses ~5–10×), and we keep only the
/// most recent `maxBackups`. Identical-content saves are skipped. Lives in the
/// app's sandbox container, so it survives app updates and needs no permissions.
enum BackupManager {
    static let maxBackups = 12

    private static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("Eli/Backups", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static let stampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static var encoder: JSONEncoder {
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e
    }
    private static var decoder: JSONDecoder {
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d
    }

    /// Write a compressed backup, unless it's identical to the latest one.
    @discardableResult
    static func backUp(_ book: Book, now: Date = Date()) -> Bool {
        guard !book.chapters.isEmpty else { return false }
        do {
            let json = try encoder.encode(BookSnapshot(book))
            if let latest = entries().first,
               let prev = try? Data(contentsOf: latest.url),
               let prevJSON = try? (prev as NSData).decompressed(using: .lzfse) as Data,
               prevJSON == json {
                return false // nothing changed since the last backup
            }
            let compressed = try (json as NSData).compressed(using: .lzfse) as Data
            let safeTitle = (book.manifest.title.isEmpty ? "Untitled" : book.manifest.title)
                .replacingOccurrences(of: "/", with: "-")
            let name = "\(safeTitle)__\(stampFormatter.string(from: now)).elibak"
            try compressed.write(to: directory.appendingPathComponent(name))
            prune()
            return true
        } catch {
            return false
        }
    }

    static func entries() -> [BackupEntry] {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        return files
            .filter { $0.pathExtension == "elibak" }
            .map { url in
                let date = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                let title = url.deletingPathExtension().lastPathComponent.components(separatedBy: "__").first ?? "Untitled"
                return BackupEntry(url: url, date: date, title: title)
            }
            .sorted { $0.date > $1.date }
    }

    static func restore(_ url: URL) -> BookSnapshot? {
        guard let data = try? Data(contentsOf: url),
              let json = try? (data as NSData).decompressed(using: .lzfse) as Data else { return nil }
        return try? decoder.decode(BookSnapshot.self, from: json)
    }

    private static func prune() {
        let all = entries()
        guard all.count > maxBackups else { return }
        for entry in all.dropFirst(maxBackups) { try? FileManager.default.removeItem(at: entry.url) }
    }
}
