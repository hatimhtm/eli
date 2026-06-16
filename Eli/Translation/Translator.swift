import Foundation

/// Turns a chapter of source text into voice-preserving literary target-language
/// prose. Builds a literary-translator prompt (persona + Taglish rules + glossary)
/// and optionally runs a second "refine" pass — the model drafts, the author edits.
struct Translator {
    var client: GeminiClient
    var refine: Bool

    func translateChapter(
        source: String,
        sourceLanguage: String,
        targetLanguage: String,
        glossary: Glossary,
        previousTail: String? = nil
    ) async throws -> String {
        let src = LanguageName.of(sourceLanguage)
        let tgt = LanguageName.of(targetLanguage)
        let isTagalog = ["tl", "fil", "tgl"].contains(sourceLanguage.lowercased())

        let system = Translator.systemPrompt(src: src, tgt: tgt, glossary: glossary, isTagalog: isTagalog)

        var prompt = ""
        if let tail = previousTail?.trimmingCharacters(in: .whitespacesAndNewlines), !tail.isEmpty {
            prompt += "For continuity, the previous chapter's \(tgt) ended like this (do NOT re-translate it):\n\"\"\"\n\(tail)\n\"\"\"\n\n"
        }
        prompt += "Translate this \(src) chapter into \(tgt). Output ONLY the \(tgt) translation.\n\n\"\"\"\n\(source)\n\"\"\""

        let draft = try await client.generate(systemInstruction: system, prompt: prompt, temperature: 0.7)
        guard refine else { return draft }

        let editorSystem = "You are a literary editor polishing a \(tgt) translation of \(src) fiction. Improve flow and naturalness, remove literal or awkward phrasing, and preserve the author's voice, tone, and meaning exactly. Do not add or cut content. Output ONLY the revised \(tgt) text."
        let editorPrompt = "Original \(src):\n\"\"\"\n\(source)\n\"\"\"\n\nDraft \(tgt) translation:\n\"\"\"\n\(draft)\n\"\"\"\n\nReturn the polished \(tgt) translation only."
        return try await client.generate(systemInstruction: editorSystem, prompt: editorPrompt, temperature: 0.5)
    }

    static func systemPrompt(src: String, tgt: String, glossary: Glossary, isTagalog: Bool) -> String {
        var s = """
        You are an award-winning literary translator rendering \(src) fiction into professional, \
        publishable \(tgt). Preserve the author's voice, rhythm, tone, and emotional register. \
        Translate sense and feeling, never word-for-word. Keep dialogue natural to a native \(tgt) \
        reader. Do not add, omit, or explain. Output only the \(tgt) translation — no notes, no quotation fences.
        """

        if isTagalog {
            s += """
            \n\nTagalog/Taglish guidance:
            - Render code-switching (Taglish) naturally in \(tgt); don't flag it.
            - Convey particles (po/opo, na, naman, ba, ng, mga) through tone and word choice, not literal words.
            - Resolve the gender-neutral pronoun "siya" using the glossary's character genders.
            - Avoid false friends: "salvage" (to summarily kill), "comfort room" (restroom), \
            "nosebleed" (struggling with English), "for a while" (hold on).
            """
        }

        if !glossary.entries.isEmpty {
            s += "\n\nGlossary — use these renderings consistently:\n"
            for entry in glossary.entries where !entry.source.isEmpty {
                var line = "- \"\(entry.source)\" → \"\(entry.target)\""
                if let gender = entry.gender { line += " [\(gender.rawValue)]" }
                if let note = entry.note, !note.isEmpty { line += " (\(note))" }
                s += line + "\n"
            }
        }
        return s
    }
}

enum LanguageName {
    static func of(_ code: String) -> String {
        switch code.lowercased() {
        case "tl", "fil", "tgl": return "Tagalog/Filipino"
        case "en":               return "English"
        default:
            return Locale(identifier: "en").localizedString(forIdentifier: code) ?? code
        }
    }
}
