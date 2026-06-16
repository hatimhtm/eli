import SwiftUI
import AppKit

/// A writing theme — researched, eye-comfortable palettes (docs/research/relaxing-themes.md).
/// Deliberately no green; burgundy ships as Blush (light) + Wine (dark).
enum EditorThemeID: String, CaseIterable, Identifiable {
    case system, light, cream, sepia, sand, mist, blush, dark, warmDark, midnight, espresso, burgundy
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system:   return "System"
        case .light:    return "Light"
        case .cream:    return "Cream"
        case .sepia:    return "Sepia"
        case .sand:     return "Sand"
        case .mist:     return "Mist"
        case .blush:    return "Blush"
        case .dark:     return "Dark"
        case .warmDark: return "Warm Dark"
        case .midnight: return "Midnight"
        case .espresso: return "Espresso"
        case .burgundy: return "Burgundy"
        }
    }
}

/// Resolved colors for a theme, in both AppKit (for the NSTextView) and SwiftUI flavors.
struct EditorPalette {
    let backgroundNS: NSColor
    let textNS: NSColor
    let dimNS: NSColor        // non-focused text in Focus mode
    let caretNS: NSColor
    let background: Color
    let text: Color
    /// Forces the rest of the UI light/dark. `nil` = follow system.
    let preferredScheme: ColorScheme?
    /// Forces the text view's appearance. `nil` = follow system.
    let appearanceName: NSAppearance.Name?
}

extension EditorThemeID {
    var palette: EditorPalette {
        switch self {
        case .system:
            return EditorPalette(
                backgroundNS: .textBackgroundColor, textNS: .labelColor,
                dimNS: .tertiaryLabelColor, caretNS: .labelColor,
                background: Color(nsColor: .textBackgroundColor), text: Color(nsColor: .labelColor),
                preferredScheme: nil, appearanceName: nil)
        // Researched palettes (hex → sRGB): bg / text / dim. See docs/research/relaxing-themes.md.
        case .light:    return .make(bg: 0xF7F6F2, ink: 0x2B2B2B, dim: 0x6B6B68, dark: false)
        case .cream:    return .make(bg: 0xFBF8F1, ink: 0x3A3A38, dim: 0x7C7468, dark: false)
        case .sepia:    return .make(bg: 0xF4ECD8, ink: 0x5B4636, dim: 0x7A6248, dark: false)
        case .sand:     return .make(bg: 0xEDE6D6, ink: 0x4A4036, dim: 0x756A5A, dark: false)
        case .mist:     return .make(bg: 0xEAEEF2, ink: 0x33404A, dim: 0x5E6A74, dark: false)
        case .blush:    return .make(bg: 0xF7EAEA, ink: 0x5A1A2B, dim: 0x8A4A55, dark: false)
        case .dark:     return .make(bg: 0x1E1E1E, ink: 0xD6D3CC, dim: 0x9A968C, dark: true)
        case .warmDark: return .make(bg: 0x211E1B, ink: 0xE4DCCF, dim: 0xA89F90, dark: true)
        case .midnight: return .make(bg: 0x14181F, ink: 0xC9D1D9, dim: 0x8B949E, dark: true)
        case .espresso: return .make(bg: 0x241B17, ink: 0xE8D9C5, dim: 0xB09A82, dark: true)
        case .burgundy: return .make(bg: 0x2A1118, ink: 0xE9D7C7, dim: 0xB98A8A, dark: true)
        }
    }
}

private extension EditorPalette {
    /// Build a fixed light/dark palette from hex bg / text / dim values.
    static func make(bg: Int, ink: Int, dim: Int, dark: Bool) -> EditorPalette {
        func color(_ hex: Int) -> NSColor {
            NSColor(srgbRed: Double((hex >> 16) & 0xFF) / 255,
                    green: Double((hex >> 8) & 0xFF) / 255,
                    blue: Double(hex & 0xFF) / 255, alpha: 1)
        }
        let bgC = color(bg), inkC = color(ink), dimC = color(dim)
        return EditorPalette(
            backgroundNS: bgC, textNS: inkC, dimNS: dimC, caretNS: inkC,
            background: Color(nsColor: bgC), text: Color(nsColor: inkC),
            preferredScheme: dark ? .dark : .light,
            appearanceName: dark ? .darkAqua : .aqua)
    }
}

/// Manuscript typeface options. Defaults to a book serif for the calm feel.
enum FontChoice: String, CaseIterable, Identifiable {
    case serif, sans, mono
    var id: String { rawValue }

    var label: String {
        switch self {
        case .serif: return "Serif"
        case .sans:  return "Sans"
        case .mono:  return "Mono"
        }
    }

    func nsFont(size: CGFloat) -> NSFont {
        switch self {
        case .serif:
            return NSFont(name: "Iowan Old Style", size: size)
                ?? NSFont(name: "Georgia", size: size)
                ?? .systemFont(ofSize: size)
        case .sans:
            return .systemFont(ofSize: size)
        case .mono:
            return NSFont(name: "SF Mono", size: size)
                ?? NSFont(name: "Menlo", size: size)
                ?? .monospacedSystemFont(ofSize: size, weight: .regular)
        }
    }
}
