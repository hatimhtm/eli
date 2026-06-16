import SwiftUI

/// First-launch welcome — sets the calm tone, explains Eli in three lines, and
/// lets the writer optionally set up translation right away. Shown once.
struct WelcomeView: View {
    var onDone: () -> Void

    @State private var apiKey = ""
    @State private var keySaved = false
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            // Hero
            VStack(spacing: 10) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(.tint)
                Text("Welcome to Eli")
                    .font(.system(.largeTitle, design: .serif).weight(.bold))
                Text("A calm, beautiful place to write your book.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 28)

            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "text.alignleft",
                           title: "Distraction-free writing",
                           subtitle: "Typewriter and focus modes, warm themes, and clean type.")
                FeatureRow(icon: "books.vertical",
                           title: "Organized by chapters",
                           subtitle: "A simple binder — drag to reorder, never in your way.")
                FeatureRow(icon: "character.book.closed",
                           title: "Tagalog → English",
                           subtitle: "Translate each chapter into polished, literary English.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 24)

            // Optional translation setup
            VStack(alignment: .leading, spacing: 8) {
                Text("Set up translation (optional)")
                    .font(.headline)
                Text("Eli uses Google Gemini to translate. Paste a free API key — it's stored privately in your Mac's Keychain, never in your book.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    SecureField("Gemini API key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                    Button(keySaved ? "Saved" : "Save") {
                        KeychainStore.saveGeminiKey(apiKey)
                        keySaved = !apiKey.isEmpty
                    }
                    .disabled(apiKey.isEmpty)
                }
                Link("Get a free key →", destination: URL(string: "https://aistudio.google.com/apikey")!)
                    .font(.caption)
            }
            .padding(16)
            .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .padding(.bottom, 24)

            Button("Start Writing", action: onDone)
                .buttonStyle(CapsuleButtonStyle())
                .keyboardShortcut(.defaultAction)
        }
        .padding(36)
        .frame(width: 540)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}
