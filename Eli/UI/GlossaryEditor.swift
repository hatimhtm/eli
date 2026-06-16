import SwiftUI

/// Edit the translation glossary — names and recurring terms the translator keeps
/// consistent across chapters. The optional gender resolves Tagalog's gender-neutral
/// pronoun *siya* per character.
struct GlossaryEditor: View {
    @Binding var glossary: Glossary
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Glossary").font(.headline)
                    Text("Names and terms the translator keeps consistent across chapters.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: addEntry) {
                    Label("Add", systemImage: "plus")
                }
            }
            .padding(.bottom, 12)

            if glossary.entries.isEmpty {
                emptyState
            } else {
                List {
                    ForEach($glossary.entries) { $entry in
                        GlossaryRow(entry: $entry) { remove(entry.id) }
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .frame(minHeight: 240)
            }

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 12)
        }
        .padding(20)
        .frame(width: 580, height: 460)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "character.book.closed")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(.tertiary)
            Text("No glossary entries yet")
                .foregroundStyle(.secondary)
            Text("Add character names and recurring terms so translations stay consistent.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 240)
    }

    private func addEntry() {
        glossary.entries.append(GlossaryEntry(source: "", target: ""))
    }

    private func remove(_ id: UUID) {
        glossary.entries.removeAll { $0.id == id }
    }
}

private struct GlossaryRow: View {
    @Binding var entry: GlossaryEntry
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField("Tagalog", text: $entry.source)
                .textFieldStyle(.roundedBorder)
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("English", text: $entry.target)
                .textFieldStyle(.roundedBorder)

            Picker("", selection: $entry.gender) {
                Text("—").tag(CharacterGender?.none)
                ForEach(CharacterGender.allCases, id: \.self) { gender in
                    Text(gender.rawValue.capitalized).tag(Optional(gender))
                }
            }
            .labelsHidden()
            .frame(width: 104)
            .help("Character gender — resolves Tagalog's gender-neutral “siya”")

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .help("Remove")
        }
        .padding(.vertical, 2)
    }
}
