import SwiftUI

/// Whole-book find & replace. The editor's own ⌘F handles a single chapter;
/// this sweeps every chapter at once, across the manuscript or the translation.
struct FindReplaceSheet: View {
    @Binding var book: Book
    @Environment(\.dismiss) private var dismiss

    enum Scope: String, CaseIterable, Identifiable {
        case manuscript, translation
        var id: String { rawValue }
        var label: String { self == .manuscript ? "Manuscript" : "Translation" }
    }

    @State private var find = ""
    @State private var replace = ""
    @State private var caseSensitive = false
    @State private var scope: Scope = .manuscript
    @State private var status = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Find & Replace").font(.headline).padding(.bottom, 12)

            Form {
                TextField("Find", text: $find)
                TextField("Replace with", text: $replace)
                Picker("In", selection: $scope) {
                    ForEach(Scope.allCases) { Text($0.label).tag($0) }
                }
                Toggle("Case sensitive", isOn: $caseSensitive)
            }
            .formStyle(.grouped)

            HStack {
                Text(status).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                Button("Replace All") { replaceAll() }
                    .buttonStyle(.borderedProminent)
                    .disabled(find.isEmpty)
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 12)
        }
        .padding(20)
        .frame(width: 440)
    }

    private func replaceAll() {
        let options: String.CompareOptions = caseSensitive ? [] : [.caseInsensitive]
        var replacements = 0
        var chaptersTouched = 0

        for index in book.chapters.indices {
            let original = scope == .manuscript ? book.chapters[index].source
                                                : (book.chapters[index].translation ?? "")
            guard !original.isEmpty else { continue }
            let count = occurrences(of: find, in: original, options: options)
            guard count > 0 else { continue }

            let updated = original.replacingOccurrences(of: find, with: replace, options: options, range: nil)
            if scope == .manuscript {
                book.chapters[index].source = updated
            } else {
                book.chapters[index].translation = updated.isEmpty ? nil : updated
            }
            replacements += count
            chaptersTouched += 1
        }

        status = replacements == 0
            ? "No matches found."
            : "Replaced \(replacements) \(replacements == 1 ? "match" : "matches") in \(chaptersTouched) \(chaptersTouched == 1 ? "chapter" : "chapters")."
    }

    private func occurrences(of needle: String, in haystack: String, options: String.CompareOptions) -> Int {
        guard !needle.isEmpty else { return 0 }
        var count = 0
        var searchStart = haystack.startIndex
        while let range = haystack.range(of: needle, options: options, range: searchStart..<haystack.endIndex) {
            count += 1
            searchStart = range.upperBound
        }
        return count
    }
}
