import SwiftUI

/// Eli's design language — adapted from the GoPilates app's feel: minimal, warm,
/// and fluid, with spring-driven motion that's responsive without bouncing.
/// All values are Ventura-safe (no macOS 14+ named animations).

enum Motion {
    /// Tactile button press — subtle and quick.
    static let press = Animation.spring(response: 0.3, dampingFraction: 0.7)
    /// Selection changes (toggles, segments) — snappy, no overshoot.
    static let select = Animation.spring(response: 0.35, dampingFraction: 0.8)
    /// Larger surface changes — measured and smooth.
    static let surface = Animation.spring(response: 0.45, dampingFraction: 0.85)
    /// Cross-fades and theme changes.
    static let fluid = Animation.easeInOut(duration: 0.25)
}

enum Radius {
    static let field: CGFloat = 10
    static let card: CGFloat = 14
    static let sheet: CGFloat = 20
}

/// Accent colors the writer can choose. Burgundy is the default (Maria's
/// favorite). Deliberately NO green. Each is mid-toned so it reads well on
/// both light/cream and dark backgrounds, for buttons, links, and selection.
enum AccentChoice: String, CaseIterable, Identifiable {
    case burgundy, plum, rose, terracotta, amber, navy, slate, graphite
    var id: String { rawValue }
    var label: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .burgundy:   return Color(red: 0.573, green: 0.149, blue: 0.247) // #92263F
        case .plum:       return Color(red: 0.435, green: 0.247, blue: 0.518) // #6F3F84
        case .rose:       return Color(red: 0.741, green: 0.357, blue: 0.443) // #BD5B71
        case .terracotta: return Color(red: 0.737, green: 0.388, blue: 0.255) // #BC6341
        case .amber:      return Color(red: 0.737, green: 0.529, blue: 0.180) // #BC872E
        case .navy:       return Color(red: 0.184, green: 0.275, blue: 0.451) // #2F4673
        case .slate:      return Color(red: 0.345, green: 0.388, blue: 0.475) // #586379
        case .graphite:   return Color(red: 0.255, green: 0.255, blue: 0.275) // #414146
        }
    }
}

extension WritingStatus {
    /// Status dot colors — deliberately no green (Maria's preference).
    var color: Color {
        switch self {
        case .draft:    return .secondary
        case .revising: return .orange
        case .done:     return .blue
        }
    }
}

/// Subtle press feedback for plain/icon buttons — scale 0.97, GoPilates-style.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

/// Primary call-to-action — a full-width accent capsule with spring press.
/// Uses the environment accent (`.tint`), so it follows the chosen accent color.
struct CapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentColor, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}
