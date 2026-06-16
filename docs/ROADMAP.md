# Eli — Build Roadmap

Phased plan. We build **Maria's edition first**, then generalize. Each phase ends at something
runnable so progress is visible. Design-first: polish each surface to ~9/10 before moving on.

> **Shipping priority (Max, 2026-06-16):** ship a complete, fully Ventura-compatible (macOS 13)
> version FIRST so Maria can test and use it. Apple Intelligence and Liquid Glass are deferred
> progressive enhancements — do NOT spend effort on them until the Ventura baseline ships.

## Phase 0 — Project scaffold
- Create the Xcode project (SwiftUI app, macOS 13 deployment target, sandboxed, hardened runtime).
- Folder layout already staged: `Eli/Models`, `Editor`, `Translation`, `Export`, `UI`,
  `Resources`.
- App shell: window, sidebar + editor split, empty-state, app icon placeholder.
- Decide local document type registration for the `.eli` bundle.

## Phase 1 — The document model
- `.eli` package: `manifest.json`, per-chapter Markdown, `glossary.json`, `snapshots/`.
- Models: `Book`, `Chapter`, `Scene`, `BookSettings`, `Glossary`.
- Open / create / save (file-coordinated, autosave, atomic writes).

## Phase 2 — The editor (the heart)
- `NSTextView` (TextKit 1) wrapped via `NSViewRepresentable`.
- Markdown styling, comfortable measure, theming (light/dark/paper).
- Typewriter/fixed scrolling, focus mode, full-screen, hide-chrome.
- Typography pass — this is where "calm-premium" is won or lost.

## Phase 3 — Structure
- Binder sidebar: chapters + scenes, drag-reorder, rename, collapse. Optional, never a gate.
- Per-chapter and project word counts.

## Phase 4 — Translation (Maria's headline)
- `TranslationProvider` protocol; `ClaudeProvider` (BYOK, Keychain, prompt-cached).
- Two-pass translate-then-refine; glossary auto-update; Taglish-aware system prompt.
- Side-by-side bilingual editor, segment alignment, edit-back-to-glossary.

## Phase 5 — Goals & progress
- Project/session/per-chapter targets, deadline back-calc.
- "Words today," chapter progress bars, projected finish date.

## Phase 6 — Export
- Bundle Pandoc; Compile step (order + template/trim presets).
- DOCX, EPUB, Markdown, RTF, plain text; KDP-ready PDF (5×8/6×9) via print CSS; PDFKit fallback.

## Phase 7 — Polish & ship
- Snapshots/versioning UI. Onboarding empty-state. App icon.
- Sub-agent review pass (UI / logic / copy) to ~9–10/10.
- Sign + notarize; GitHub Release; README with banner per house style.

## Later (general edition / v2)
- Generalize translation to any language pair.
- Sprints; forgiving streaks; corkboard/outliner; subtle rewards.
- Apple Intelligence on-device backend; Liquid Glass surface on macOS 26.
