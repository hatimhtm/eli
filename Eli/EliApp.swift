import SwiftUI
import AppKit

@main
struct EliApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .commands {
            CommandMenu("Format") {
                Button("Bold") {
                    NSApp.sendAction(#selector(EliTextView.wrapBold(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("b", modifiers: .command)

                Button("Italic") {
                    NSApp.sendAction(#selector(EliTextView.wrapItalic(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("i", modifiers: .command)

                Text("Type **bold** or *italic*. Start a line with # for a heading.")
            }
        }

        Settings {
            SettingsView()
        }
    }
}
