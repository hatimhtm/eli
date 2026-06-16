import SwiftUI

/// A plain-language way to go back to an earlier version. No jargon: just dates,
/// and one "Restore" button. Eli backs up automatically, so this is always here.
struct RestoreSheet: View {
    var onRestore: (BookSnapshot) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var entries: [BackupEntry] = []
    @State private var pending: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Earlier Versions").font(.headline)
                Text("Eli saves your last \(BackupManager.maxBackups) versions automatically. Pick one to go back to.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(16)
            Divider()

            if entries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 28, weight: .light)).foregroundStyle(.tertiary)
                    Text("No earlier versions yet").foregroundStyle(.secondary)
                    Text("They'll appear here as you write.").font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, minHeight: 220)
            } else {
                List {
                    ForEach(entries) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                Text(entry.title).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Restore") { pending = entry.url }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .frame(minHeight: 240)
            }

            Divider()
            HStack {
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
        .frame(width: 460, height: 440)
        .onAppear { entries = BackupManager.entries() }
        .alert("Go back to this version?", isPresented: Binding(
            get: { pending != nil },
            set: { if !$0 { pending = nil } }
        )) {
            Button("Cancel", role: .cancel) {}
            Button("Restore") {
                if let url = pending, let snapshot = BackupManager.restore(url) {
                    onRestore(snapshot)
                    dismiss()
                }
            }
        } message: {
            Text("This replaces your current text with the saved version. Don't worry — your current text is backed up first, so you can switch back.")
        }
    }
}
