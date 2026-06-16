import SwiftUI

/// Edit book metadata — title, author, and an optional word-count goal.
/// Title/author bind directly; the goal commits on Done (0 = no goal).
struct BookInfoSheet: View {
    @Binding var book: Book
    @Environment(\.dismiss) private var dismiss

    @State private var goal = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Book Info")
                .font(.headline)
                .padding(.bottom, 12)

            Form {
                TextField("Title", text: $book.manifest.title)
                TextField("Author", text: $book.manifest.author)
                TextField("Word-count goal (0 = none)", value: $goal, format: .number)
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("Done") {
                    book.manifest.settings.wordCountGoal = goal > 0 ? goal : nil
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 12)
        }
        .padding(20)
        .frame(width: 420)
        .onAppear { goal = book.manifest.settings.wordCountGoal ?? 0 }
    }
}
