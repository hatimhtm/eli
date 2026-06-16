import SwiftUI

/// App settings — the Gemini API key (stored in Keychain) and translation model.
struct SettingsView: View {
    @AppStorage("translation.model") private var model = "gemini-3.5-flash"
    @AppStorage("translation.refine") private var refine = true
    @AppStorage("editor.accent") private var accentRaw = AccentChoice.burgundy.rawValue

    @State private var apiKey = ""
    @State private var status = ""

    var body: some View {
        Form {
            Section("Gemini API") {
                SecureField("API key", text: $apiKey)
                HStack {
                    Button("Save Key") {
                        KeychainStore.saveGeminiKey(apiKey)
                        status = apiKey.isEmpty ? "Cleared." : "Saved to Keychain."
                    }
                    Text(status).font(.caption).foregroundStyle(.secondary)
                }
                Text("Stored privately in your macOS Keychain — never in your book or in the app. Get a free key at aistudio.google.com.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Translation") {
                Picker("Model", selection: $model) {
                    Text("Gemini 3.5 Flash — fast, low cost").tag("gemini-3.5-flash")
                    Text("Gemini 3.1 Pro — highest quality").tag("gemini-3.1-pro-preview")
                    Text("Gemini 2.5 Flash").tag("gemini-2.5-flash")
                    Text("Gemini 2.5 Pro").tag("gemini-2.5-pro")
                }
                Toggle("Two-pass refine (better prose, ~2× cost)", isOn: $refine)
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .tint((AccentChoice(rawValue: accentRaw) ?? .burgundy).color)
        .onAppear { apiKey = KeychainStore.geminiKey() ?? "" }
    }
}
