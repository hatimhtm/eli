import SwiftUI

/// The bilingual chapter editor: source language on the left, target translation
/// on the right. The author writes/edits the source, runs the translation, then
/// edits the result — the model drafts, she stays the final editor.
struct TranslationView: View {
    @Binding var source: String
    @Binding var translation: String?
    let sourceLanguage: String
    let targetLanguage: String
    let glossary: Glossary
    /// Tail of the previous unit's translation, for cross-unit continuity.
    let previousTail: String?
    let palette: EditorPalette
    let font: NSFont
    let lineSpacing: CGFloat
    let paragraphSpacing: CGFloat

    @AppStorage("translation.model") private var model = "gemini-3.5-flash"
    @AppStorage("translation.refine") private var refine = true

    @State private var isTranslating = false
    @State private var errorText: String?
    @State private var task: Task<Void, Never>?
    @State private var proposed: String?       // new translation awaiting review
    @State private var showReview = false

    private var translationBinding: Binding<String> {
        Binding(
            get: { translation ?? "" },
            set: { translation = $0.isEmpty ? nil : $0 }
        )
    }

    var body: some View {
        HSplitView {
            pane(
                title: LanguageName.of(sourceLanguage),
                text: $source,
                trailing: { EmptyView() }
            )
            pane(
                title: LanguageName.of(targetLanguage),
                text: translationBinding,
                trailing: { translateControls }
            )
        }
        .background(palette.background)
        .onDisappear { task?.cancel() }
        .sheet(isPresented: $showReview) {
            TranslationReviewSheet(
                current: translation ?? "",
                proposed: proposed ?? "",
                onUseNew: { translation = proposed; proposed = nil },
                onKeep: { proposed = nil }
            )
        }
    }

    @ViewBuilder
    private func pane<Trailing: View>(
        title: String,
        text: Binding<String>,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(.subheadline, design: .serif).weight(.semibold))
                    .foregroundStyle(palette.text.opacity(0.7))
                Spacer()
                trailing()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            Divider().opacity(0.4)

            EditorTextView(
                text: text,
                palette: palette,
                font: font,
                lineSpacing: lineSpacing,
                paragraphSpacing: paragraphSpacing,
                measureWidth: 100_000, // fill the pane; centering handled by base padding
                typewriter: false,
                focusMode: false
            )
        }
        .frame(minWidth: 280)
        .background(palette.background)
    }

    @ViewBuilder
    private var translateControls: some View {
        if isTranslating {
            ProgressView().controlSize(.small)
        } else {
            Button {
                translate()
            } label: {
                Label(translation == nil ? "Translate" : "Re-translate",
                      systemImage: "character.book.closed")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .help("Translate with \(model)")
        }
        if let errorText {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .help(errorText)
        }
    }

    private func translate() {
        guard let key = KeychainStore.geminiKey(), !key.isEmpty else {
            errorText = TranslationError.missingKey.errorDescription
            return
        }
        let sourceText = source
        guard !sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isTranslating = true
        errorText = nil
        let translator = Translator(client: GeminiClient(apiKey: key, model: model), refine: refine)
        let tail = previousTail

        task = Task {
            do {
                let result = try await translator.translateChapter(
                    source: sourceText,
                    sourceLanguage: sourceLanguage,
                    targetLanguage: targetLanguage,
                    glossary: glossary,
                    previousTail: tail
                )
                if Task.isCancelled { return }
                await MainActor.run {
                    let existing = translation?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    // Protect her edits: if she already has a translation, review
                    // the new one instead of overwriting it.
                    if !existing.isEmpty && existing != result {
                        proposed = result
                        showReview = true
                    } else {
                        translation = result
                    }
                    isTranslating = false
                }
            } catch {
                if Task.isCancelled { return }
                await MainActor.run {
                    errorText = error.localizedDescription
                    isTranslating = false
                }
            }
        }
    }
}
