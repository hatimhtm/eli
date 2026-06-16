import SwiftUI

/// Appearance selector — theme swatches, accent dots, and font. All are direct
/// buttons (not nested menus, which fired unreliably), so picks apply instantly.
struct ThemePicker: View {
    @AppStorage("editor.theme") private var themeRaw = EditorThemeID.cream.rawValue
    @AppStorage("editor.accent") private var accentRaw = AccentChoice.burgundy.rawValue
    @AppStorage("editor.font") private var fontRaw = FontChoice.serif.rawValue

    private let themeColumns = [GridItem(.adaptive(minimum: 86), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                section("Theme") {
                    LazyVGrid(columns: themeColumns, spacing: 12) {
                        ForEach(EditorThemeID.allCases) { theme in
                            Button { themeRaw = theme.rawValue } label: {
                                ThemeSwatch(theme: theme, selected: themeRaw == theme.rawValue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                section("Accent") {
                    HStack(spacing: 10) {
                        ForEach(AccentChoice.allCases) { choice in
                            Button { accentRaw = choice.rawValue } label: {
                                Circle()
                                    .fill(choice.color)
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        Circle().strokeBorder(.primary.opacity(accentRaw == choice.rawValue ? 0.9 : 0),
                                                              lineWidth: 2).padding(-3)
                                    )
                            }
                            .buttonStyle(.plain)
                            .help(choice.label)
                        }
                    }
                }

                section("Font") {
                    HStack(spacing: 8) {
                        ForEach(FontChoice.allCases) { font in
                            Button { fontRaw = font.rawValue } label: {
                                Text(font.label)
                                    .font(.callout)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(fontRaw == font.rawValue ? Color.accentColor : Color.secondary.opacity(0.15),
                                                in: Capsule())
                                    .foregroundStyle(fontRaw == font.rawValue ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(16)
        }
        .frame(width: 340, height: 380)
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
        }
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
            .frame(height: 46)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(selected ? Color.accentColor : Color.secondary.opacity(0.25),
                                  lineWidth: selected ? 2.5 : 1)
            )
            Text(theme.label).font(.caption2).foregroundStyle(selected ? Color.accentColor : .secondary)
        }
    }
}
