import SwiftUI
import AppKit

/// A writing theme — a curated set of calm, relaxing palettes (deliberately no green).
enum EditorThemeID: String, CaseIterable, Identifiable {
    case system, light, cream, sepia, sand, mist, rose, dark, midnight, espresso
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system:   return "System"
        case .light:    return "Light"
        case .cream:    return "Cream"
        case .sepia:    return "Sepia"
        case .sand:     return "Sand"
        case .mist:     return "Mist"
        case .rose:     return "Rose"
        case .dark:     return "Dark"
        case .midnight: return "Midnight"
        case .espresso: return "Espresso"
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
        case .light:    return .make(bg: (0.992, 0.992, 0.996), ink: (0.13, 0.13, 0.15), dark: false)
        case .cream:    return .make(bg: (0.980, 0.957, 0.906), ink: (0.227, 0.196, 0.149), dark: false)
        case .sepia:    return .make(bg: (0.937, 0.886, 0.792), ink: (0.337, 0.255, 0.169), dark: false)
        case .sand:     return .make(bg: (0.945, 0.929, 0.898), ink: (0.270, 0.247, 0.208), dark: false)
        case .mist:     return .make(bg: (0.925, 0.937, 0.953), ink: (0.180, 0.210, 0.247), dark: false)
        case .rose:     return .make(bg: (0.969, 0.933, 0.929), ink: (0.290, 0.220, 0.224), dark: false)
        case .dark:     return .make(bg: (0.110, 0.110, 0.122), ink: (0.902, 0.902, 0.910), dark: true)
        case .midnight: return .make(bg: (0.075, 0.086, 0.118), ink: (0.840, 0.860, 0.910), dark: true)
        case .espresso: return .make(bg: (0.118, 0.094, 0.078), ink: (0.910, 0.870, 0.800), dark: true)
        }
    }
}

private extension EditorPalette {
    /// Build a fixed light/dark palette from RGB tuples; dim is a blend toward the bg.
    static func make(bg: (Double, Double, Double), ink: (Double, Double, Double), dark: Bool) -> EditorPalette {
        let bgC = NSColor(srgbRed: bg.0, green: bg.1, blue: bg.2, alpha: 1)
        let inkC = NSColor(srgbRed: ink.0, green: ink.1, blue: ink.2, alpha: 1)
        let t = 0.55 // dim = ink blended 55% toward bg
        let dimC = NSColor(srgbRed: ink.0 + (bg.0 - ink.0) * t,
                           green: ink.1 + (bg.1 - ink.1) * t,
                           blue: ink.2 + (bg.2 - ink.2) * t, alpha: 1)
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
