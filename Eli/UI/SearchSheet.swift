import SwiftUI

/// Search the whole book — manuscript and translation — and jump to a result.
/// (The editor's ⌘F searches one chapter; this finds across all of them.)
struct SearchSheet: View {
    let book: Book
    var onSelect: (UUID) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""

    private struct Hit: Identifiable {
        let id: UUID
        let title: String
        let snippet: String
    }

    private var hits: [Hit] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= 2 else { return [] }
        var results: [Hit] = []
        for chapter in book.chapters {
            let chapterTitle = chapter.title.isEmpty ? "Untitled" : chapter.title
            if chapter.scenes.isEmpty {
                if let snip = snippet(in: chapter.source, q) ?? snippet(in: chapter.translation ?? "", q) {
                    results.append(Hit(id: chapter.id, title: chapterTitle, snippet: snip))
                }
            } else {
                for scene in chapter.scenes {
                    let sceneTitle = scene.title.isEmpty ? "Scene" : scene.title
                    if let snip = snippet(in: scene.source, q) ?? snippet(in: scene.translation ?? "", q) {
                        results.append(Hit(id: scene.id, title: "\(chapterTitle) — \(sceneTitle)", snippet: snip))
                    }
                }
            }
        }
        return results
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search the whole book", text: $query)
                    .textFieldStyle(.plain)
            }
            .padding(12)
            Divider()

            if query.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                hint("Type to search across every chapter and scene.")
            } else if hits.isEmpty {
                hint("No matches.")
            } else {
                List(hits) { hit in
                    Button {
                        onSelect(hit.id)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(hit.title).font(.callout.weight(.medium))
                            Text(hit.snippet).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
            HStack { Spacer(); Button("Done") { dismiss() }.keyboardShortcut(.cancelAction) }.padding(12)
        }
        .frame(width: 480, height: 440)
    }

    private func hint(_ text: String) -> some View {
        Text(text)
            .font(.callout).foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func snippet(in text: String, _ q: String) -> String? {
        guard let range = text.range(of: q, options: .caseInsensitive) else { return nil }
        let start = text.index(range.lowerBound, offsetBy: -32, limitedBy: text.startIndex) ?? text.startIndex
        let end = text.index(range.upperBound, offsetBy: 32, limitedBy: text.endIndex) ?? text.endIndex
        let prefix = start > text.startIndex ? "…" : ""
        let suffix = end < text.endIndex ? "…" : ""
        return prefix + text[start..<end].replacingOccurrences(of: "\n", with: " ") + suffix
    }
}
