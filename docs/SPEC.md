# Eli — Product & Technical Spec

Source of truth for what we're building and why. Every feature here is grounded in the research
in `docs/research/` (competitor analysis, distraction-free UX, export pipeline, motivation
features, and literary Tagalog→English translation). Decisions, not options.

---

## 1. Positioning

**Beautiful + free + native + writing-first**, with chapter-by-chapter literary translation as the
headline differentiator. Three stacked wedges, all research-backed:

1. The free competitors (bibisco/Quoll/Manuskript) all fail on one axis — design polish and native
   feel. A Cocoa-native SwiftUI app wins that segment outright.
2. Writing-first, not outline-first. Open-source tools gate writing behind detailed outlining —
   "an illusion of progress: copious notes and no manuscript." Eli lets you write immediately.
3. In-context literary translation. No mainstream writing app does it. This is genuinely novel.

### Competitor takeaways
- **Scrivener** — sets the structure bar (binder, corkboard, outliner, compile) but is the
  "cockpit of a 747." We take the structure, drop the overwhelm.
- **Ulysses** — the calm-premium target: minimalist UI, typewriter + fixed scrolling, Markdown
  library, per-sheet goals. Subscription, Apple-only, light on book structure.
- **iA Writer** — distraction-free benchmark; signature near-monospace Duospace typography
  (intentionally paced for writing), syntax highlighting.
- **Free/OSS (bibisco, Quoll, Manuskript)** — free and capable, uniformly unpolished and
  non-native. Our opening.

---

## 2. Feature set

### v1 — Maria's edition (build first)
- **Distraction-free editor** (see §3): full-screen, typewriter/fixed scrolling, focus mode
  (dim all but current sentence/paragraph), light/dark + warm paper themes, deliberate typography.
- **Book structure**: binder sidebar with chapters and scenes; drag-to-reorder; optional and
  collapsible — never required to start writing.
- **Chapter-by-chapter Tagalog → English literary translation** (see §5): side-by-side bilingual
  editor, two-pass translate-then-refine, auto-updating glossary, author stays final editor.
- **Goals & progress** (research-ranked highest-impact, lowest-risk): project + session +
  per-chapter word targets with deadline back-calc; "words today," chapter progress bars,
  projected finish date.
- **Export** (see §4): DOCX, EPUB, Markdown, PDF, RTF, plain text via bundled Pandoc.
- **Autosave + snapshots** (see §6).

### v2 — general open-source release
- Generalize translation to any language pair.
- Writing **sprints** (timed sessions / word wars).
- **Forgiving** streaks only — rest days, "X of last 30 days," never a fragile consecutive
  counter (strict streaks are the #1 backfire feature: anxiety, abandonment after one miss).
- Corkboard / outliner view; subtle reward gamification.
- Apple Intelligence on-device backend; Liquid Glass surface on macOS 26.

### Explicitly avoided
- Destructive gamification (delete-on-pause, lockout) — off-brand for a calm book app.
- Outline-first gating. Crowded toolbars. Subscription. Account/login requirement.

---

## 3. Distraction-free UX (the calm-premium feel)

- **Typewriter / fixed scrolling**: keep the working line stationary (top/middle/bottom, user
  choice) while text scrolls under it.
- **Focus mode**: dim everything except the current sentence or paragraph.
- **Full-screen + hide-chrome**: the manuscript is the only thing on screen.
- **Typography**: deliberate, paced fonts (near-monospace option à la Duospace; a clean serif for
  prose). Controlled measure (line length ~60–75 chars), generous line height, comfortable margins.
- **Themes**: light, dark, and warm-paper. Minimal, no decoration.
- Animations are quiet and fluid — easing, not bounce. Nothing that calls attention to itself.

---

## 4. Export

**Bundled Pandoc** is the proven pipeline (verified):
- DOCX, EPUB2/EPUB3, Markdown, RTF, plain text — direct Pandoc output.
- **KDP-ready print PDF** (5×8 / 6×9 trim) via Pandoc + print CSS (Matt Gemmell's `pandoc-publish`
  pattern). Native PDFKit as the simple-PDF fallback.
- A "Compile"-style step assembles chapters in order, applies a chosen template/trim, and exports.
  Keep the UI to a few good presets — not Scrivener's wall of options.

---

## 5. Translation architecture (Maria's killer feature)

- **Default model: Gemini** (we use Max's Gemini API key — no Anthropic account). Draft on
  **`gemini-3.5-flash`** (fast, cheap, generous free tier — ideal for a free app), optional polish
  pass on **`gemini-3.1-pro-preview`** for max quality. The `TranslationProvider` protocol keeps
  Claude (Sonnet/Opus) and Apple Intelligence as drop-in alternative backends.
- **Validated 2026-06-16:** a Taglish smoke test (gender-neutral *siya*, Taglish *na-stress*, the
  idiom *hay naku, anak*) produced clean, non-literal literary English ("Oh, sweetheart" for *hay
  naku, anak*). The method works on Gemini.
- **⚠️ Implementation gotcha:** Gemini 3.x models do internal "thinking" that consumes the output
  token budget — set a generous `maxOutputTokens` (≥2048) per call or translations truncate
  mid-sentence.
- The research's top *quality* pick was Claude (Sonnet draft / Opus polish), but DeepL flattens
  literary nuance (no creative mode) and Sudowrite has no translation. **Honest caveat:** human
  literary translators still beat LLMs (NAACL 2025) — LLMs translate too literally. So **the model
  drafts; Maria is the final editor.** The whole UX is built around her editing, not trusting output.
- **Method**: literary-translator persona + style brief + auto-updating **glossary** (character
  names, recurring terms, and per-character gender to resolve Tagalog's gender-neutral *siya*) +
  **two-pass translate-then-refine** + carry previous chapter's tail for continuity.
- **Taglish-aware rules** in the prompt: intra-word code-switching (*nagda-drive*), particles
  (*po/opo, na, naman, ng, mga*), false friends (*comfort room, salvage, nosebleed*),
  aspect-vs-tense, reduplication.
- **Chunking**: scene/sub-chapter level (≤ ~2K tokens) to avoid "lost in the middle" degradation.
- **Cost**: ~$0.29–0.48 / chapter; ~$3–15 / book. Prompt-cache the static system prompt + glossary.
- **Keys**: **bring-your-own Anthropic API key**, stored in **macOS Keychain**, calling Anthropic
  directly. The only sustainable, private model for a free open-source app.
- **UX**: chapter-level **side-by-side bilingual editor** — Tagalog left, English right,
  segment-aligned; Maria's edits feed back into the glossary.

See `docs/research/translation-research.md` for full sourcing.

---

## 6. Technical architecture (Ventura-safe)

- **Min deployment: macOS 13 Ventura.** Progressive enhancement via capability checks:
  - **UI surface-style layer** — one switch: Liquid Glass (macOS 26) ↔ `NSVisualEffectView`
    vibrancy (Ventura).
  - **AI provider protocol** — two backends: cloud Claude (now) and Apple Intelligence on-device
    (capable Macs, later), selected at launch by capability.
- **Editor: `NSTextView` (TextKit 1) wrapped in `NSViewRepresentable`** — *not* TextKit 2
  (verified: no printing/PDF before macOS 15, scroll instability on long docs). Key insight:
  **we edit one chapter at a time**, so each editor holds only a few thousand words — the
  long-document performance problem never arises.
- **File format: a document *bundle*** (a `.eli` package = a folder):
  - one Markdown file per chapter (source language)
  - parallel translation files (e.g. `chapter-03.en.md`)
  - `manifest.json` — chapter order, metadata, goals, settings
  - `glossary.json` — translation glossary / style memory
  - `snapshots/` — versioning
  - Plain text, inspectable, **git-friendly** — fits the open-source ethos and is future-proof.
- **Autosave + snapshots**: debounced autosave to disk; manual + periodic snapshots per chapter.
- **Packaging**: signed, **notarized**, free; distributed via GitHub Releases (+ optional Homebrew
  cask). No App Store dependency.

---

## 7. Open questions to resolve during build
- Exact bundling of Pandoc (binary in app bundle vs. download-on-first-export) and notarization
  implications of a bundled executable.
- Whether to ship a curated set of licensed fonts or rely on system + a free near-monospace face.
- Snapshot granularity and storage cost for very long books.
