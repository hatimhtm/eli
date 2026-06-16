import SwiftUI

/// Shown when re-translating a chapter that already has an edited translation —
/// compares the current version with the new one so the author's edits are never
/// silently overwritten. She chooses which to keep.
struct TranslationReviewSheet: View {
    let current: String
    let proposed: String
    var onUseNew: () -> Void
    var onKeep: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Review translation").font(.headline)
                Text("You've edited this chapter. Compare your version with the new translation.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)

            Divider()

            HSplitView {
                column(title: "Your current version", text: current, badge: "Keeps your edits")
                column(title: "New translation", text: proposed, badge: "Freshly generated")
            }

            Divider()

            HStack {
                Spacer()
                Button("Keep Current") { onKeep(); dismiss() }
                Button("Use New Translation") { onUseNew(); dismiss() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
        .frame(width: 780, height: 560)
    }

    private func column(title: String, text: String, badge: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.subheadline.weight(.semibold))
                Spacer()
                Text(badge)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            ScrollView {
                Text(text.isEmpty ? "—" : text)
                    .font(.system(.body, design: .serif))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(.quaternary.opacity(0.25), in: RoundedRectangle(cornerRadius: Radius.field, style: .continuous))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
    }
}
