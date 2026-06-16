import SwiftUI

/// A visual theme selector — a grid of live swatches. Picking one applies it
/// immediately (writes `editor.theme`, which the editor observes).
struct ThemePicker: View {
    @AppStorage("editor.theme") private var themeRaw = EditorThemeID.cream.rawValue

    private let columns = [GridItem(.adaptive(minimum: 88), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme").font(.headline)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(EditorThemeID.allCases) { theme in
                    Button {
                        themeRaw = theme.rawValue
                    } label: {
                        ThemeSwatch(theme: theme, selected: themeRaw == theme.rawValue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(width: 340)
    }
}

private struct ThemeSwatch: View {
    let theme: EditorThemeID
    let selected: Bool

    var body: some View {
        let p = theme.palette
        VStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(p.background)
                Text("Aa").font(.system(.title3, design: .serif)).foregroundStyle(p.text)
            }
            .frame(height: 48)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(selected ? Color.accentColor : Color.secondary.opacity(0.25),
                                  lineWidth: selected ? 2.5 : 1)
            )
            Text(theme.label)
                .font(.caption2)
                .foregroundStyle(selected ? Color.accentColor : .secondary)
        }
    }
}
