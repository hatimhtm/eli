# Motivation Features & Competitor Deltas — Research

For: design of a free, beautiful, distraction-free macOS book-writing app.
Date: 2026-06-15.

---

## PART A — WRITING-MOTIVATION & STATS FEATURES THAT ACTUALLY DRIVE RETENTION

### A1. Daily / project word-count goals and per-chapter targets

**How the leaders do it:**

- **Scrivener Project Targets** — Set a total manuscript word goal *and* a session goal. Scrivener can compute the session goal automatically from your deadline and how many days/week you write, and it tracks per-day/week/month writing history. There's a two-level system: **Project Targets** (whole manuscript + session) and **Document Targets** (per-document/per-chapter bars that turn from red → amber → green as you approach the target). Writers consistently report the targets add useful accountability and that small/low targets work better than ambitious ones — one author noted switching to lower targets made them "always meet the target," which made them more productive and happier.
  - Literature & Latte: https://www.literatureandlatte.com/blog/track-statistics-and-targets-in-your-scrivener-projects
  - Well-Storied (how to use targets/deadlines): https://www.well-storied.com/blog/setting-easy-writing-goals-deadlines-with-scrivener-targets
  - Document targets walkthrough: https://lancymccall.com/using-word-count-targets-in-scrivener-part-2-document-targets/
  - Larbalestier on small goals beating big ones: https://justinelarbalestier.com/blog/2013/10/28/small-word-count-goals-2/

- **Ulysses Goals** — Per-sheet or per-group goals based on word/character/page count, reading time, or sentence/paragraph count. Ulysses 13 added **daily goals** (auto-reset at midnight) and **deadlines** (you enter target length + due date, and Ulysses back-calculates the words/day needed). A live progress ring updates as you type. Reviewers describe the live ring as "gamifying the writing process in a productive way" and call it simple but genuinely motivating for deadline/daily-count work.
  - Ulysses Goals docs: https://help.ulysses.app/goals
  - MacStories on Ulysses 13 goals/deadlines: https://www.macstories.net/reviews/ulysses-13-brings-upgrades-to-writing-goals-keywords-and-code-blocks/
  - The Sweet Setup: https://thesweetsetup.com/ulysses-13-debuts-deadlines-keywords-code-block-support/

**Verdict on goals:** This is the single most-validated motivation feature. Writers value it, it's table-stakes in every serious tool, and the two-tier model (project total + per-session/daily + optional per-chapter) is the proven pattern. The key nuance from testimonials: **defaults should be modest**, and a deadline-driven auto-calculated daily target is the highest-leverage variant.

### A2. Writing streaks (consecutive-day)

**The core finding is a genuine paradox — streaks both motivate and harm, depending on design.**

- Streak design is "one of the most powerful tools in gamification, and one of the most misused." Most implementations optimize short-term engagement and ignore what happens psychologically past ~30 days. (Yu-kai Chou / Octalysis): https://yukaichou.com/gamification-analysis/streak-design-gamification-motivation-burnout/
- **Pro side:** consistent small daily progress is one of the strongest motivators; not wanting to reset to zero drives daily writing; long streaks reinforce a "I am a writer" identity. 750words testimonials show users building 128-day (and multi-year) streaks and the discipline they previously lacked. Authorspublish documents a 3-year-5-month streak as transformative.
  - 750words testimonial analysis: https://medium.com/750-words/i-analyzed-15-years-of-testimonials-from-users-of-750words-com-to-learn-how-journaling-helped-them-9665c93814e8
  - Authorspublish 3yr+ streak: https://authorspublish.com/lessons-from-a-3-year-5-month-writing-streak/
  - Authorlytica (science of streaks): https://authorlytica.com/science-of-writing-streaks/
- **Con side (the backfire):** the "habit streak paradox" — streaks cause anxiety, shame and burnout once the number gets precious. The all-or-nothing trap is real: one author nearly quit a whole challenge after missing just 3 days; perfectionists treat one miss as total failure and abandon the project. 750words users report stress about "never missing a single day."
  - Work Brighter, habit-streak paradox: https://workbrighter.co/habit-streak-paradox/
  - Amy Hupe, "You've broken your streak": https://amyhupe.co.uk/articles/youve-broken-your-streak/
  - Perfectionism / all-or-nothing: https://janefriedman.com/how-to-overcome-perfectionism-to-achieve-your-writing-goals/

**Verdict on streaks:** Ship them, but **with anti-anxiety design built in from day one**: (1) define streaks against a *goal you choose* (e.g. "days I wrote ≥250 words") rather than mere app-open; (2) offer **streak freezes / rest days / weekly (not strictly daily) cadence** so a single miss doesn't nuke months of progress; (3) de-emphasize the raw number — celebrate cumulative days written and "X of last 30 days" rather than a fragile consecutive counter. A bounded challenge (e.g. a 30-day push) keeps pressure manageable. Done naively, streaks are the feature most likely to *drive users away*.

### A3. Writing sprints / timed sessions

- A sprint = a timed (usually 15–45 min, sometimes up to 60) burst of continuous writing with no editing, aiming for momentum/output over polish. Originated in and is integral to **NaNoWriMo culture** ("word wars"/"word sprints" run on forums, write-ins, Discord/Twitter). NaNoWriMo has reported 400k+ writers using sprints each November. Sprints work by "chunking" a big daily goal into achievable bursts and silencing the inner critic.
  - ProWritingAid: https://prowritingaid.com/art/1042/how-to-use-word-sprints-to-meet-your-writing-goals.aspx
  - Writer's Edit (sprints for NaNoWriMo): https://writersedit.com/fiction-writing/word-sprints-win-nanowrimo/
  - Wikiwrimo "Word war": https://www.wikiwrimo.org/wiki/Word_war
  - Writing Beginner guide: https://www.writingbeginner.com/writing-sprints-the-ultimate-guide-to-successful-writing-sprints/

**Verdict on sprints:** Strongly loved, low-risk, and culturally sticky. A simple in-app timer + "words this sprint" counter + a celebratory end-of-sprint summary is high value and cheap to build. The social/community sprint angle (shared sprints) drives accountability but is out of scope for a v1 local app.

### A4. Progress visualization (bars, charts, session history, "words today")

- Strong, consistent psychological payoff: charts turn "I wrote something" into a visibly moving line; making manuscript progress visible keeps people going. Tools writers single out:
  - **Trackbear** — gamified progress displays, streak counters, historical trend graphs, motivational stats.
  - **WritersAlley** — charts, current streak, **projected finish date**, "are you on track" signal.
  - **Writer's Progress Bar** — chart-based visual tracking for visual people.
  - Ulysses' live progress ring; Scrivener's per-doc red→green target bars.
  - Yomu roundup: https://www.yomu.ai/blog/10-best-writing-accountability-apps
  - ScribeCount trackers: https://scribecount.com/author-resource/writing-tools-for-authors/wordcount-trackers
  - WritersAlley: https://writersalley.com/word-count-tracker.html
  - AuthorsTech word-count apps: https://authorstech.com/word-count-apps/

**Verdict on visualization:** High value, near-zero downside. The standouts are (a) the **"words written today"** live number, (b) a **per-chapter progress bar that changes color** as it fills, and (c) a **calendar/heatmap of session history** plus a **projected finish date** computed from recent pace. This is the feature set that makes the goal/streak/sprint data *feel* rewarding.

### A5. Gamification approaches — what works, what backfires

- **The Most Dangerous Writing App** — deletes everything if you stop typing for ~5 seconds before hitting your time/word goal; "hardcore mode" blurs prior text. Massive cultural reach (70.9M TikTok results; covered by Wired/Forbes/The Verge; recommended by NaNoWriMo). It genuinely forces flow/silences the inner editor for some — but it is explicitly anxiety-inducing and review write-ups describe it "scaring" users and deleting real work.
  - Wikipedia: https://en.wikipedia.org/wiki/The_Most_Dangerous_Writing_App
  - MakeUseOf ("deleted my work when I paused"): https://www.makeuseof.com/most-dangerous-writing-app-experience/
  - Medium ("scared the sh*t out of me"): https://medium.com/the-masterpiece/i-tried-the-most-dangerous-writing-app-and-it-scared-the-shit-out-of-me-2ddc1c14b542
- **Cold Turkey Writer** — turns the machine into a locked "typewriter": you can't leave until you hit a word/time goal; can disable the delete key; Pro adds themes/soundtracks. Loved by procrastinators for *aggressive blocking* rather than reward-style gamification.
  - Cold Turkey Writer: https://getcoldturkey.com/writer/
  - Indie Author Magazine, 7 gamification apps: https://indieauthormagazine.com/seven-apps-to-gamify-your-writing-sessions-and-other-author-approved-methods-for-boosting-your-word-count/
- **Writeometer / Forest-style** — reward/positive-reinforcement gamification (rewards, virtual tree that dies if you quit). The Forest "grow a tree / it dies if you leave" pattern is a softer, well-liked motivator.

**Verdict on gamification:** Two schools — **punishment** (delete/lock: MDWA, Cold Turkey) and **reward** (rings, trees, badges, streaks). Punishment mechanics get press and work for a vocal minority in *drafting* mode, but they backfire for most (data loss, anxiety) and are a poor fit for a "beautiful, calm" book app. **Reward/positive-reinforcement gamification is the safer brand fit.** A *destructive* mode, if offered at all, must be strictly opt-in, sandboxed to a scratch buffer, and never able to touch the real manuscript.

---

### A6. RANKED RETENTION IMPACT (Part A verdict)

| Rank | Feature | Retention impact | Backfire risk |
|---|---|---|---|
| 1 | Daily/session goal + project total (modest defaults; deadline auto-calc) | Highest — table-stakes, universally valued | Low (only if defaults are too ambitious) |
| 2 | Progress visualization (words-today, per-chapter bars, heatmap, projected finish) | Very high — makes all other data rewarding | Very low |
| 3 | Writing sprints / timed sessions | High — beloved, NaNoWriMo-native, cheap | Very low |
| 4 | Streaks | High *if* designed for forgiveness; otherwise net-negative | **High** — anxiety, all-or-nothing abandonment |
| 5 | Reward gamification (badges/rings/tree) | Moderate, pleasant, on-brand | Low if subtle; cheesy if overdone |
| 6 | Punishment gamification (delete-on-pause / lockout) | Niche; great press, small loyal base | **Very high** — data loss + anxiety, off-brand |

**Backfire flags:** strict daily streaks without freezes; ambitious default goals; any destructive mechanic that can touch the real manuscript; loud/cheesy badge spam.

---

## PART B — COMPETITOR FEATURE DELTAS (macOS book-writing context)

**Bear** — Markdown-first notes app (Shiny Frog), Apple-only (macOS/iOS/iPadOS), genuinely native and beautiful with the best-regarded design polish in this list; free tier is generous, **Bear Pro $2.99/mo** unlocks iCloud sync, encryption, more exports. Loved for: clean, fast, *gorgeous* Markdown writing and tag organization. Hated for/limited by: no long-form book structure (no chapters/manuscript model), no Windows/web, no tables/collaboration — it's a note app people *wish* scaled to books.
- https://www.g2.com/products/bear/reviews · https://productivitystack.io/tools/bear/

**Highland 2** — macOS-only screenwriting/Markdown (Fountain) editor; aimed at screenwriters (and prose via Markdown). Free to write; was a one-time **$49.99** to remove export watermark, now consolidated into **Highland Pro** subscription (~$4.99/mo annual, $9.99/mo monthly) on the Mac App Store. Loved for: such an enjoyable, clean writing experience that users are reluctant to leave it. Hated for: not a full screenwriting suite for pros (Final Draft veterans find it incomplete) and the shift to subscription.
- https://appleinsider.com/articles/18/07/23/hands-on-highland-2-for-macos-wants-to-be-the-sole-tool-for-screenwriters · https://highland-pro.macupdate.com/

**Storyist** — Mac + iOS creative-writing app for novelists & screenwriters; **one-time $59 (Mac), $14.99 (iOS)**, no subscription, iCloud/Dropbox sync. For authors who want Scrivener-like structure (notecards, character/story sheets, outlining) but prefer a buy-once model on Apple devices. Loved for: notecards + customizable story sheets and the no-subscription pricing. Hated for/limited by: Apple-only (no Windows/Android/web) and a dated feel relative to newer tools.
- https://selfpublishing.com/storyist-review/ · https://www.storyist.com/mac/

**Dabble** — cloud-based novel-writing app (web + desktop wrappers, syncs across devices); for plotters writing long fiction who want clean drafting + visual plotting. Subscription-led (~**$9–$29/mo**; lifetime ~$399–$699; 14-day trial). Features: Plot Grid, Story Notes, Focus Mode, goal tracking, NaNoWriMo integration. Loved for: the visual Plot Grid and a clean, easy cloud experience between Google Docs and Scrivener. Hated for: feels pricey over time vs Scrivener's one-off or Atticus's lifetime.
- https://reedsy.com/studio/resources/dabble-writing-review · https://kindlepreneur.com/dabble-writer/

**Atticus** — all-in-one writing + book *formatting* tool (web/PWA, offline-capable) on Windows/Mac/Linux/Chromebook; positioned as a cross-platform Vellum rival. **$147 one-time, lifetime updates**, 30-day refund. For indie authors who want to draft *and* produce print/EPUB in one app. Loved for: cross-platform formatting at a one-time price (vs Mac-only Vellum) plus solid export/front-matter/TOC. Hated for/limited by: it's a browser-based PWA (not a true native Mac app), so polish/feel is web-app, not Cocoa.
- https://kindlepreneur.com/atticus-review/ · https://reedsy.com/studio/resources/atticus-review/

**Novlr** — cloud/web novel-writing platform (also offline mode) for novelists/memoirists wanting distraction-free drafting + habit-building analytics. Free tier (limited); **Plus ~$6/mo annual**, **Pro $18/mo or $144/yr**, **Lifetime Pro ~$499**; notably writer-co-owned. Standout: dashboard of daily/monthly/yearly word counts with **streaks and graphs**, custom goals — i.e. strong motivation/analytics. Loved for: progress tracking + clean drafting and the co-ownership model. Hated for: Pro pricing is steep and formatting/layout is weak (drafting tool, not a layout tool).
- https://reedsy.com/blog/guide/book-writing-software/novlr/ · https://kindlepreneur.com/novlr-review/

**Plottr** — visual plotting/outlining + story-bible software (Windows/Mac, mobile/web on higher tiers); for outliners who plan plot points, character arcs and series bibles visually. Pricing: ~**$39/yr (1 device) → $99/yr Pro all-devices**; lifetime **$139–$299**; 30-day trial. Loved for: flexible timeline/outline boards, series bibles, and famously fast, friendly support. Hated for/limited by: it's a *planning* companion, not a drafting/manuscript editor — you still write your prose elsewhere; per-platform license tiering annoys some.
- https://kindlepreneur.com/plottr-review/ · https://plottr.com/pricing/

### The open-source free competitors (our direct rivals)

**bibisco** — open-source novel-writing software (Italian dev Andrea Feccomandi, since 2014); Linux/macOS/Windows, 15 languages. Free Community edition + cheap paid Supporters edition. Strong structural tools: character development (deep interview-style questionnaires), chapter/scene organization, revisions, export to PDF/DOCX/TXT. Reviews call it the **best interface among open-source options** — yet still flag it as "fairly unattractive," buggy, with limited support. **Design weakness:** functional but visually unpolished, an Electron/web feel, cramped utilitarian forms — not "beautiful," not Mac-native.
- https://self-publishingschool.com/bibisco-review/ · https://bibisco.com/ · https://www.linux-magazine.com/Online/Features/Write-a-Novel-with-Open-Source-Tools

**Quoll Writer** — free, open-source (Java, Apache 2.0) distraction-free novel app for Windows/Mac/Linux; chapters, scenes, character/location assets, research and basic project structure for privacy-conscious offline writers. Loved for: free, private, local, novel-specific structure. **Design weakness:** being a **Java/Swing** app it looks and feels conspicuously non-native and dated on macOS (no Retina-crisp Cocoa UI, clunky widgets), no mobile, no slick export/formatting pipeline, development is slow/sporadic.
- https://www.scalarly.com/startup-stack/quoll-writer-tailored-tool-for-storytellers/ · http://quollwriter.com/ · https://github.com/garybentley/quollwriter

**Manuskript** (bonus, named in brief) — free, open-source, cross-platform Scrivener-style tool (snowflake method, outline, distraction-free mode). Widely called the *best* open-source Scrivener alternative on features. **Design weakness:** Qt UI is openly acknowledged as "not as polished as proprietary software," with concrete usability bugs (e.g. windows only partially visible until you drag their edges) — clearly behind commercial polish.
- https://www.scalarly.com/startup-stack/manuskript-the-open-source-tool-for-writers/ · https://www.linux-magazine.com/Online/Features/Write-a-Novel-with-Open-Source-Tools

**The open-source design gap (our opportunity):** all three (bibisco, Quoll, Manuskript) compete *only* on being free + feature-rich, and **all three are visibly unpolished** — Electron/Java/Qt toolkits, non-native macOS feel, dated widgets, occasional bugs, weak typography. None is "beautiful" or truly Mac-native. A free app that is genuinely gorgeous, fast, and Cocoa-native would dominate this segment on the exact axis they all fail.

---

## RECOMMENDED MOTIVATION FEATURE SET

**Ship in v1 (core, high-value, low-risk):**
1. **Goals — two-tier + deadline.** Project total word goal, plus a per-session/daily goal. Let the user enter a deadline and auto-calculate the words/day needed (Ulysses/Scrivener pattern). **Default targets modest**, never preset high. Optional per-chapter targets with a color-filling progress bar (red→amber→green).
2. **Progress visualization.** Prominent live "words written today," per-chapter progress bars, a session-history calendar/heatmap, and a **projected finish date** from recent pace. This is what makes everything else feel rewarding — cheap, beloved, zero backfire.
3. **Writing sprints.** Built-in timer (15/25/45 min presets + custom), live "words this sprint" counter, gentle celebratory end-of-sprint summary. NaNoWriMo-native, low-risk, sticky.

**Ship in v2 / later (valuable but needs careful design or more scope):**
4. **Forgiving streaks.** Streak against a *chosen daily goal*, with **rest days / streak freezes / weekly-cadence option** baked in. Surface "X of last 30 days" and total days written more than the fragile consecutive number. Optionally frame as bounded challenges (30-day push). Do NOT ship a naive daily streak first — design the forgiveness mechanics before launching it at all.
5. **Subtle reward gamification.** Tasteful milestone moments (first 1k/10k/50k words, chapter complete) and an optional Forest-style focus reward. Keep it quiet and on-brand; avoid badge spam.

**Avoid (or strictly opt-in, sandboxed):**
6. **Punishment/destructive gamification** (delete-on-pause à la Most Dangerous Writing App; hard lockout à la Cold Turkey). Off-brand for a calm, beautiful book app and a real data-loss/anxiety risk. If offered at all: opt-in only, confined to a scratch/sprint buffer, and **never able to delete the actual manuscript.**
7. **Strict, unforgiving daily streaks** — the highest-backfire feature in the category (anxiety, all-or-nothing abandonment). Only ship the forgiving version above.
