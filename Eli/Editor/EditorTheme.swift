import SwiftUI
import AppKit

/// A writing theme. System follows the OS; Cream is a warm, fixed paper mode.
enum EditorThemeID: String, CaseIterable, Identifiable {
    case system, light, cream, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .cream:  return "Cream"
        case .dark:   return "Dark"
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
                backgroundNS: .textBackgroundColor,
                textNS: .labelColor,
                dimNS: .tertiaryLabelColor,
                caretNS: .labelColor,
                background: Color(nsColor: .textBackgroundColor),
                text: Color(nsColor: .labelColor),
                preferredScheme: nil,
                appearanceName: nil
            )
        case .light:
            // Soft off-white — easier on the eyes than pure #FFF.
            let bg = NSColor(srgbRed: 0.992, green: 0.992, blue: 0.996, alpha: 1)
            let ink = NSColor(srgbRed: 0.13, green: 0.13, blue: 0.15, alpha: 1)
            return EditorPalette(
                backgroundNS: bg, textNS: ink,
                dimNS: NSColor(srgbRed: 0.74, green: 0.74, blue: 0.78, alpha: 1), caretNS: ink,
                background: Color(nsColor: bg), text: Color(nsColor: ink),
                preferredScheme: .light, appearanceName: .aqua
            )
        case .cream:
            // Warm paper — calm, low-glare, great for long sessions.
            let bg = NSColor(srgbRed: 0.980, green: 0.957, blue: 0.906, alpha: 1)
            let ink = NSColor(srgbRed: 0.227, green: 0.196, blue: 0.149, alpha: 1)
            return EditorPalette(
                backgroundNS: bg, textNS: ink,
                dimNS: NSColor(srgbRed: 0.706, green: 0.659, blue: 0.576, alpha: 1), caretNS: ink,
                background: Color(nsColor: bg), text: Color(nsColor: ink),
                preferredScheme: .light, appearanceName: .aqua
            )
        case .dark:
            let bg = NSColor(srgbRed: 0.110, green: 0.110, blue: 0.122, alpha: 1)
            let ink = NSColor(srgbRed: 0.902, green: 0.902, blue: 0.910, alpha: 1)
            return EditorPalette(
                backgroundNS: bg, textNS: ink,
                dimNS: NSColor(white: 0.42, alpha: 1), caretNS: ink,
                background: Color(nsColor: bg), text: Color(nsColor: ink),
                preferredScheme: .dark, appearanceName: .darkAqua
            )
        }
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
