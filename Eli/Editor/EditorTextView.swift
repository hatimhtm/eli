import SwiftUI
import AppKit

/// The manuscript editor: a TextKit-1 `NSTextView` wrapped for SwiftUI.
/// TextKit 1 (not 2) is deliberate — TextKit 2 on Ventura lacks printing/PDF
/// and is unstable on long documents. Each chapter is short, so this is fast.
///
/// Supports typewriter scrolling, focus-mode dimming, themes, and a controlled
/// measure (max line width) for comfortable reading.
struct EditorTextView: NSViewRepresentable {
    @Binding var text: String
    var palette: EditorPalette
    var font: NSFont
    var lineSpacing: CGFloat
    var paragraphSpacing: CGFloat
    var firstLineIndent: CGFloat
    var measureWidth: CGFloat
    var typewriter: Bool
    var focusMode: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        let textView = EliTextView(frame: .zero)
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.lineFragmentPadding = 0
        textView.drawsBackground = false
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = true
        // No spell/grammar redlining — the writer works in Tagalog, which macOS's
        // English checker would underline everywhere.
        textView.isContinuousSpellCheckingEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.usesFindBar = true
        textView.string = text

        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay

        context.coordinator.textView = textView
        configure(textView, context: context)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? EliTextView else { return }
        context.coordinator.parent = self
        if textView.string != text {
            textView.string = text
            context.coordinator.lastSignature = nil // restyle the freshly injected text
        }
        configure(textView, context: context)
    }

    private func configure(_ textView: EliTextView, context: Context) {
        // Cheap, idempotent settings — safe to set on every update.
        textView.maxContentWidth = measureWidth
        textView.typewriterEnabled = typewriter
        textView.invalidateInsets()
        textView.insertionPointColor = palette.caretNS

        if let name = palette.appearanceName {
            let appearance = NSAppearance(named: name)
            textView.appearance = appearance
            textView.enclosingScrollView?.appearance = appearance
        } else {
            textView.appearance = nil
            textView.enclosingScrollView?.appearance = nil
        }

        // Expensive, whole-document work runs only when an input actually changed
        // (theme/font/size/measure/focus) — not on every keystroke.
        let signature = "\(font.fontName)|\(font.pointSize)|\(lineSpacing)|\(paragraphSpacing)|\(firstLineIndent)|\(measureWidth)|\(palette.textNS.hashValue)|\(focusMode)|\(typewriter)"
        guard context.coordinator.lastSignature != signature else { return }
        context.coordinator.lastSignature = signature

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = lineSpacing
        paragraph.paragraphSpacing = paragraphSpacing // breathing room between paragraphs
        paragraph.firstLineHeadIndent = firstLineIndent // "linea" — indent the first line of each paragraph
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: palette.textNS,
            .paragraphStyle: paragraph
        ]
        textView.typingAttributes = attributes
        if let storage = textView.textStorage {
            storage.setAttributes(attributes, range: NSRange(location: 0, length: storage.length))
        }

        context.coordinator.applyFocus()
        if typewriter { context.coordinator.centerCaret() }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorTextView
        weak var textView: EliTextView?
        var lastSignature: String?

        init(_ parent: EditorTextView) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            guard let textView else { return }
            parent.text = textView.string
            applyFocus()
            if parent.typewriter { centerCaret() }
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            applyFocus()
            if parent.typewriter { centerCaret() }
        }

        /// Dim everything but the current paragraph when Focus mode is on.
        /// Uses NSLayoutManager *temporary* attributes — display-only, so the
        /// document text storage is never modified by a visual effect.
        func applyFocus() {
            guard let textView, let layoutManager = textView.layoutManager else { return }
            let full = NSRange(location: 0, length: (textView.string as NSString).length)
            layoutManager.removeTemporaryAttribute(.foregroundColor, forCharacterRange: full)
            guard parent.focusMode else { return } // base color comes from text storage
            layoutManager.addTemporaryAttribute(.foregroundColor, value: parent.palette.dimNS, forCharacterRange: full)
            let active = (textView.string as NSString).paragraphRange(for: textView.selectedRange())
            layoutManager.addTemporaryAttribute(.foregroundColor, value: parent.palette.textNS, forCharacterRange: active)
        }

        /// Keep the caret line vertically centered (typewriter scrolling).
        func centerCaret() {
            guard let textView,
                  let layoutManager = textView.layoutManager,
                  let container = textView.textContainer,
                  let scrollView = textView.enclosingScrollView else { return }
            let selection = textView.selectedRange()
            let glyphRange = layoutManager.glyphRange(forCharacterRange: selection, actualCharacterRange: nil)
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: container)
            rect.origin.y += textView.textContainerInset.height

            let clip = scrollView.contentView
            let target = rect.midY - clip.bounds.height / 2
            let maxY = max(0, textView.bounds.height - clip.bounds.height)
            let y = min(max(0, target), maxY)
            clip.scroll(to: NSPoint(x: 0, y: y))
            scrollView.reflectScrolledClipView(clip)
        }
    }
}

/// NSTextView that centers its text to a max measure and, in typewriter mode,
/// adds tall top/bottom insets so any line can be scrolled to center.
final class EliTextView: NSTextView {
    var maxContentWidth: CGFloat = 680
    var typewriterEnabled: Bool = false
    private let basePadding: CGFloat = 28

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateInsets()
    }

    func invalidateInsets() { updateInsets() }

    // MARK: Markdown formatting (Format menu / ⌘B / ⌘I)

    @objc func wrapBold(_ sender: Any?) { wrapSelection(with: "**") }
    @objc func wrapItalic(_ sender: Any?) { wrapSelection(with: "*") }

    /// Wraps the selection in a Markdown marker (or inserts an empty pair and
    /// places the caret between them). Goes through the undo-aware text path.
    private func wrapSelection(with marker: String) {
        guard let textStorage else { return }
        let range = selectedRange()
        let selected = (string as NSString).substring(with: range)
        let replacement = "\(marker)\(selected)\(marker)"
        guard shouldChangeText(in: range, replacementString: replacement) else { return }
        textStorage.replaceCharacters(in: range, with: replacement)
        didChangeText()
        let markerLen = (marker as NSString).length
        if selected.isEmpty {
            setSelectedRange(NSRange(location: range.location + markerLen, length: 0))
        } else {
            setSelectedRange(NSRange(location: range.location, length: (replacement as NSString).length))
        }
    }

    private func updateInsets() {
        let horizontal = max(basePadding, (bounds.width - maxContentWidth) / 2)
        let viewportHeight = enclosingScrollView?.contentView.bounds.height ?? bounds.height
        let vertical = typewriterEnabled ? max(basePadding, viewportHeight * 0.42) : basePadding
        let newInset = NSSize(width: horizontal, height: vertical)
        if abs(textContainerInset.width - newInset.width) > 0.5
            || abs(textContainerInset.height - newInset.height) > 0.5 {
            textContainerInset = newInset
        }
    }
}
