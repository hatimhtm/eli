# AI-Assisted Literary Translation (Tagalog/Taglish → English) — Research

**Purpose:** Design the headline feature for a free, open-source macOS book-writing app: chapter-by-chapter, voice-preserving literary translation from Tagalog/Filipino (including Taglish code-switching) into polished literary English, for a Filipina author writing her book in Tagalog.

**Date:** 2026-06-15. Researched with live web search/fetch; Claude model/pricing facts are from the Anthropic `claude-api` skill reference (cached 2026-06-04). Sources are cited inline as URLs.

> **Honesty note up front.** The strongest "model X is best for literary translation" claims circulate on vendor and affiliate blogs that recycle the same handful of figures. The most rigorous *peer-reviewed* study found that published **human** translations still beat **every** LLM, and that LLMs translate "considerably more literally and less diversely" than humans ([NAACL 2025, *How Good Are LLMs for Literary Translation, Really?*](https://aclanthology.org/2025.naacl-long.548/) / [arXiv 2410.18697](https://arxiv.org/abs/2410.18697)). So everything below is about the best **machine** option as a *draft-and-refine engine under human editorial control* — not a replacement for the author's own ear. For this app that is exactly the right framing: the author is the final editor.

---

## 1. Which cloud LLM is best for high-quality literary/creative translation (2025–2026)

**Ranking for *voice / tone / register preservation* specifically:**

1. **Claude (Anthropic) — best for voice, prose feel, and long-document consistency.** Across vendor-neutral benchmarks and translator-community discussion, Claude is the most consistently cited model for *how* something is said rather than just *what*. A Lokalise blind study of professional translators rated Claude 3.5's output "good" most often of any system (~78%), ahead of GPT-4o, DeepL, Google, and Microsoft ([lokalise.com/blog/what-is-the-best-llm-for-translation](https://lokalise.com/blog/what-is-the-best-llm-for-translation/)). Claude 3.5 Sonnet reportedly won 9 of 11 language pairs in WMT24 human evaluation. Creative-writing comparisons describe Claude as best at varied sentence rhythm, subtext, humor/sarcasm, and resisting the "AI-flavored default register," and note its very large context (200K–1M tokens) holds character voice across long documents without forced chunking ([fictionai.pro](https://www.fictionai.pro/blog/best-ai-models-for-fiction-writing-claude-vs-gpt-vs-gemini), [tactiq.io](https://tactiq.io/learn/claude-vs-gemini-vs-chatgpt-for-writing), [machinetranslation.com/blog/claude-ai-3-5](https://www.machinetranslation.com/blog/claude-ai-3-5)).
2. **GPT-5-class (OpenAI) — strong, highly steerable runner-up.** Excellent at idioms, context, and being *directed* to preserve rhythm/rhyme; often cited as best for several Asian languages and poetry experiments. But reviewers repeatedly call its *default* prose competent-but-generic — "strong commercial fiction rather than literary work" ([getblend.com](https://www.getblend.com/blog/which-llm-is-best-for-translation/), [machinetranslation.com/blog/claude-ai-vs-chatgpt](https://www.machinetranslation.com/blog/claude-ai-vs-chatgpt), [buildmvpfast.com](https://www.buildmvpfast.com/articles/best-llms-2026-guide/creative-writing-ai)).
3. **Gemini (Google) — competitive on accuracy, weaker on flair.** Benchmark-strong (notably EN↔ZH) and long-context, but multiple creative comparisons call its prose "mechanical" ([machinetranslation.com/blog/claude-ai-vs-gemini](https://www.machinetranslation.com/blog/claude-ai-vs-gemini), [localizejs.com](https://localizejs.com/articles/the-3-best-llms-for-translation)).
4. **DeepL — best for accuracy/business text, *not* literary voice.** Fluent and reliable for European-language business/technical translation, but repeatedly criticized for *smoothing away* the original's slang, humor, and personal voice. It is an accuracy engine, not an artistry engine (see §2).

**What translators actually say:** consensus among indie authors and localization blogs is that Claude best preserves authorial voice and reads least "AI-written," with GPT a more steerable second, Gemini trailing on flair, and DeepL valued for fidelity not artistry ([otranslator.com/en/blog/top-3-novel-translation-sites](https://otranslator.com/en/blog/top-3-novel-translation-sites), [bookbutchers.com](https://www.bookbutchers.com/ai-translation-for-fiction-writers-the-game-changers-the-costs-and-the-cautionary-tales/), [creativindie.com](https://www.creativindie.com/ai-book-translation-why-its-easier-now-than-ever-and-how-to-do-it/)).

**Caveats:** (a) The specific "78%" and "9 of 11" figures are widely repeated but trace to single sources — treat as directional. (b) Most pro-Claude material is vendor/affiliate content. (c) For figurative language, idiom studies show LLMs preserve *semantics* well but still lag on full pragmatic/cultural nuance ([arxiv.org/pdf/2508.10421](https://arxiv.org/pdf/2508.10421), [aclanthology.org/2025.coling-main.697.pdf](https://aclanthology.org/2025.coling-main.697.pdf)).

**Bottom line for this app:** Use a frontier general LLM, default to **Claude** for voice preservation; GPT-5-class is the credible alternative if you want provider optionality. DeepL is the wrong tool for literary voice.

---

## 2. How DeepL and Sudowrite handle creative vs literal translation

### DeepL — an accuracy engine, no literary mode
DeepL is fundamentally fidelity-focused. Its 2025 next-gen LLM is pitched entirely at **business** outcomes ("higher-quality, more context-aware business translations," legal/medical/technical/financial verticals); literary/creative/voice work is *absent* from the messaging, and the marketed gains are **edit-distance** improvements (an accuracy metric), not creativity ([deepl.com/en/blog/next-gen-language-model](https://www.deepl.com/en/blog/next-gen-language-model), [PR Newswire](https://www.prnewswire.com/news-releases/deepl-launches-next-generation-llm-that-outperforms-competitors-on-translation-quality-fluency-302198364.html)).

- **DeepL Clarify** (Mar 2025) adds interactivity — it flags ambiguities (gender, names, idioms, cultural references) and asks clarifying questions — but is explicitly pitched for "legal, medical and technical translations": disambiguation for *correctness*, not voice ([deepl.com/en/blog/introducing-the-deepl-clarify-feature](https://www.deepl.com/en/blog/introducing-the-deepl-clarify-feature)).
- **DeepL Write** is a separate *monolingual* writing assistant (grammar/tone/style à la Grammarly), not a literary-translation tool ([techcrunch.com](https://techcrunch.com/2023/01/17/deepl-takes-aim-at-grammarly-with-the-launch-of-write-to-clean-up-your-prose/)).

**What writers report:** DeepL "usually decent, but you might lose some nuance or voice"; for "style-driven fiction or snarky dialogue, you may need to babysit the output"; a bestselling author avoids it "for lengthy texts featuring pop culture references, historical language, or slang." 2025 academic work likewise found NMT (DeepL, Google) outperforms on accuracy but "none came close to replicating the degree of creativity required" for metaphor/imagery/tone ([bookbutchers.com](https://www.bookbutchers.com/ai-translation-for-fiction-writers-the-game-changers-the-costs-and-the-cautionary-tales/), [degruyterbrill.com/document/doi/10.1515/phras-2025-0006/html](https://www.degruyterbrill.com/document/doi/10.1515/phras-2025-0006/html)).

### Sudowrite — no translation feature
Sudowrite is an AI **fiction-drafting** app (Write/Expand, Story Engine, Describe, Rewrite, Story Bible, the Muse model). Neither its docs nor 2025–2026 reviews list a translate function. Its docs only cover *writing in* other languages — the Write button "will (usually!) automatically match your language," with other features sometimes falling back to English ([docs.sudowrite.com — using other languages](https://docs.sudowrite.com/resources/ktuxRrzphwp3uTNneRtaos/can-i-use-sudowrite-in-other-languages/aR5Me5vw2J3wmLD9acqrvw), [skywork.ai/blog/sudowrite-review-2025](https://skywork.ai/blog/sudowrite-review-2025-story-engine-describe-pricing/)). Novelists wanting cross-language work have hacked it by pairing Google Translate with Sudowrite to smooth output in sub-1,000-word chunks — only marginally better than raw MT ([linkedin.com — Google Translator + Sudowrite](https://www.linkedin.com/pulse/google-translator-sudowrite-automated-authors-wojciech-zielinski)).

**Implication for the app:** Neither off-the-shelf product solves voice-preserving Tagalog→English literary translation. The opportunity is a **purpose-built workflow on a frontier LLM** — which is exactly what this feature should be. Specialist book-translation wrappers (O.Translator, Booktranslator.ai) exist, but their voice advantage comes from the underlying LLM, not from DeepL-style NMT ([booktranslator.ai blog](https://booktranslator.ai/blog/18-ai-translation-tools-tested-by-reddit-users-heres-what-actually-works-for-full-books)).

---

## 3. Prompting strategy for literary translation

Literary quality comes from a **staged process**, not one clever prompt: persona + rich brief + glossary + paragraph-level context + an iterative reflection pass.

### Core prompt patterns

**a) Translator persona / role framing.** Setting an expert role measurably shifts register. Andrew Ng's `translation-agent` opens with *"You are an expert linguist, specializing in translation from {source_lang} to {target_lang}"* ([github.com/andrewyng/translation-agent](https://github.com/andrewyng/translation-agent), prompts in [utils.py](https://raw.githubusercontent.com/andrewyng/translation-agent/main/src/translation_agent/utils.py)). Anthropic confirms role prompting "can drastically change the output" ([docs.anthropic.com — prompt engineering](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)). A sharper literary persona works better: *"You are an award-winning literary translator who renders Tagalog/Taglish fiction into polished, voice-faithful English prose."* Counterintuitive finding: for wordplay, *avoiding the word "translate"* reduces literal output ([arxiv.org/pdf/2507.06506](https://arxiv.org/pdf/2507.06506)).

**b) Rich translation brief.** Specify audience, purpose, register, era, dialect, tone, and target voice ([slator.com](https://slator.com/resources/prompt-ai-better-translation/), [crowdin.com](https://crowdin.com/blog/ai-prompts-for-quality-translation)). A peer-reviewed study found brief elements alone have *limited* effect — the model still rendered cultural devices literally — so briefs help but don't replace iteration ([awej-tls.org](https://www.awej-tls.org/exploring-the-role-of-translation-brief-elements-in-prompts-to-large-language-models/)).

**c) Glossary / do-not-translate / proper nouns.** Provide an approved-term list, mark items to leave in source language, and embed glossary slices as few-shot pairs ([poeditor.com/blog/ai-prompts-for-translation](https://poeditor.com/blog/ai-prompts-for-translation/), [Smartling RAG prompt tooling](https://help.smartling.com/hc/en-us/articles/42142862499227-Prompt-Tooling-with-RAG-for-LLM-translations)).

**d) Preserve structure explicitly.** Instruct: keep paragraph breaks, one paragraph per source paragraph, preserve formatting/markdown ([poeditor.com](https://poeditor.com/blog/ai-prompts-for-translation/)).

**e) Handle idioms explicitly.** LLMs default to word-for-word on idioms; instruct the model to "translate meaning, not words" and substitute a functionally equivalent English idiom (IdiomKB, [arxiv.org/pdf/2308.13961](https://arxiv.org/pdf/2308.13961); [aclanthology.org/2025.loreslm-1.13](https://aclanthology.org/2025.loreslm-1.13/)).

**f) Few-shot voice anchoring.** Give 2–3 contrast pairs of the author's desired English voice; the model generalizes from them ([crowdin.com](https://crowdin.com/blog/ai-prompts-for-quality-translation)).

**g) Translate at paragraph (not sentence) level.** Karpinska & Iyyer showed whole-paragraph translation beats sentence-by-sentence across 18 language pairs — fewer mistranslations and stylistic inconsistencies ([arxiv.org/abs/2304.03245](https://arxiv.org/abs/2304.03245)).

### Two-pass / reflection (best-supported technique)
**Andrew Ng's translation-agent** runs three steps: (1) translate, (2) **reflect** — *"improve the translation"* scoring accuracy/fluency/style/terminology and matching the target dialect, (3) **improve** — apply the suggestions. Ng reports results "occasionally fantastic… superior to commercial offerings" ([github.com/andrewyng/translation-agent](https://github.com/andrewyng/translation-agent)). **TEaR** (Translate–Estimate–Refine) formalizes the self-refinement loop and confirms quality gains ([arxiv.org/abs/2402.16379](https://arxiv.org/abs/2402.16379)); **TransAgents** scales it to a multi-agent "translation company," with human evaluators sometimes preferring its literary output over human references ([arxiv.org/abs/2405.11804](https://arxiv.org/abs/2405.11804)). Counter-evidence: refinement narrows but does not close the human gap ([arxiv.org/abs/2410.18697](https://arxiv.org/abs/2410.18697)) — keep the author as final editor.

### Recommended prompt skeleton (for this app)
```
SYSTEM: You are an award-winning literary translator rendering Tagalog/Filipino
(including Taglish code-switching) into polished, voice-faithful literary English.

CONTEXT
- Author's voice/register/era/tone: {style_brief}
- Glossary & character names (use exactly; do-not-translate list): {glossary}
- Previous chapter's closing paragraphs (for continuity): {prev_tail}
- Running story summary so far: {summary}

RULES
- Preserve the author's voice, rhythm, and emotional register above literal accuracy.
- Translate meaning, not words: render Tagalog idioms as equivalent English idioms.
- Keep paragraph structure 1:1. Preserve names/terms per the glossary.
- For Taglish: judge whether each English word is a real code-switch or a loanword;
  preserve intentional register/tone shifts rather than flattening them.
- "siya" is gender-neutral — infer gender only from context; if unknown, use the
  established character gender or singular "they"; never guess from stereotype.

TASK: Translate the chapter below. (Pass 1: faithful literary draft.)
[chapter text]
```
Then a **Pass 2 reflection** call: *"Here is the source and your draft. Improve it for voice, fluency, naturalness, and idiom; fix any over-literal renderings, dropped honorific/particle nuance, or mis-gendering. Output only the improved translation."*

---

## 4. Tagalog/Taglish-specific pitfalls

Tagalog (standardized as Filipino) is an Austronesian, verb-initial, morphologically rich, **lower-resource** language. Mapping it onto analytic English breaks many one-to-one assumptions in MT. These pitfalls compound each other.

**Taglish code-switching.** Real Filipino prose interleaves Tagalog and English at the morpheme/word/clause level — the hardest cases being *intra-word* switches where an English root takes a Tagalog affix: **nagda-drive** ("was driving"), **magla-lunch** ("will have lunch"), **pinost** ("posted"), **nagse-sweat ako** ("I was sweating"), **paki-fax** ("please fax") ([en.wikipedia.org/wiki/Taglish](https://en.wikipedia.org/wiki/Taglish)). Taglish is **structured, not broken English**: Filipino is the grammatical spine, English injects specificity/modernity/status. Language choice carries meaning — English signals education/cosmopolitanism, Filipino conveys warmth/sincerity — so flattening Taglish to plain English destroys humor, class implications, and emotional cues ([veqta.com — the code-switching paradox](https://veqta.com/the-code-switching-paradox-why-taglish-isnt-broken-english-but-a-localization-minefield/)). Translators should *mirror tone over structure, use culturally equivalent expressions, retain untranslatable borrowed terms, and match rhythm/personality*. Monolingual-trained MT mis-segments or drops affixed English stems ([aclanthology.org/2022.lrec-1.225.pdf](https://aclanthology.org/2022.lrec-1.225.pdf), [1stopasia.com](https://www.1stopasia.com/blog/taglish-the-mastery-of-code-switching/)).

**Semantic repurposing of English words.** In Filipino usage, **effort**, **comfort room** (= restroom), **nosebleed** (= struggling with fast/heavy English), and **salvage** (= extrajudicial killing) carry meanings that, translated literally, confuse or misrepresent ([veqta.com — code-switching paradox](https://veqta.com/the-code-switching-paradox-why-taglish-isnt-broken-english-but-a-localization-minefield/)).

**Honorifics & discourse particles (often silently dropped by MT).** **po/opo** are respect particles with no English equivalent (stronger than "sir/ma'am"); MT typically deletes them, erasing register ([ling-app.com/blog/tagalog-honorifics](https://ling-app.com/blog/tagalog-honorifics/)). Stance/mood particles — **ba** (question force), **na** (already/now), **pa** (still/yet), **naman** (contrast/mild emphasis), **kasi** (because/explanatory) — modify tone, not proposition, so MT drops them and flattens voice ([academia.edu — Tagalog particles](https://www.academia.edu/30481105/Tagalog_particles_in_Philippine_English_The_cases_of_ba_na_no_and_pa), [files.eric.ed.gov/fulltext/ED573079.pdf](https://files.eric.ed.gov/fulltext/ED573079.pdf)). Grammatical markers **ng** (genitive/non-focus: *bumili ng tinapay* = "bought bread") and plural **mga** (*ng mga damit* = "the clothes") have no surface English counterpart ([talktomeintagalog.com](https://talktomeintagalog.com/filipino-grammar/tagalog-ng-markers/)). VEQTA confirms honorifics and verb affixes as top recurring mistakes ([veqta.com — common mistakes](https://veqta.com/filipino-tagalog-into-english-the-common-mistakes-when-translating/)).

**Gender-neutral "siya."** Third-person singular **siya** encodes no gender; English forces a choice, and MT resolves it via biased statistics — defaulting to stereotyped genders by occupation/action ([pop.inquirer.net — Google Translate gender bias](https://pop.inquirer.net/107105/google-translate-gender-bias), [arxiv.org/abs/2305.10510](https://arxiv.org/abs/2305.10510)). A 2025 *Translating Siya* study finds Google Translate and ChatGPT reproduce these asymmetries and argues singular "they" better preserves indeterminacy ([ssrn 6594058](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=6594058), [arxiv.org/pdf/2401.13165](https://arxiv.org/pdf/2401.13165)). **Mitigation:** track each character's established gender in the glossary so the model resolves *siya* consistently.

**Reduplication & the aspect/affix + voice system.** Tagalog marks **aspect** (completed/progressive/contemplated), not English tense, via affix + reduplication: *aral* → **nag-aral** (studied) / **nag-aaral** (studying) / **mag-aaral** (will study) ([ling-app.com/blog/tagalog-conjugation](https://ling-app.com/blog/tagalog-conjugation/)). Reduplication also marks plurality/intensity/repetition — **araw-araw** = "every day." The **symmetrical voice/focus** system (mag-, -um-, in-, i-, -an selects the *ang*-subject) has no clean English mapping, so MT mis-assigns who-did-what-to-whom ([en.wikipedia.org/wiki/Tagalog_grammar](https://en.wikipedia.org/wiki/Tagalog_grammar), [rrg.caset.buffalo.edu — Voice and Case in Tagalog](https://rrg.caset.buffalo.edu/rrg/Voice_and_Case_in_Tagalog.pdf)).

**Idioms (literal rendering destroys meaning):** *mababaw ang luha* (cries easily), *butas ang bulsa* (broke), *dugong bughaw* (high-born), *pagputi ng uwak* ("when the crow turns white" = never), *kabiyak ng dibdib* (spouse) ([yourdictionary.com](https://www.yourdictionary.com/articles/examples-filipino-idioms), [ling-app.com/blog/tagalog-idioms](https://ling-app.com/blog/tagalog-idioms/)).

**Why general MT underperforms:** Tagalog is lower-resource — scarce parallel corpora, reliance on cross-lingual transfer (Google added five more Philippine languages via PaLM 2 in 2024). Filipino-specific benchmarks exist *because* standard models underperform on its morphology/voice/code-switching ([rappler.com](https://www.rappler.com/technology/google-translate-support-new-languages-june-2024/), Batayan benchmark [arxiv.org/html/2502.14911v1](https://arxiv.org/html/2502.14911v1)). **This is the strongest argument for using a frontier LLM (Claude/GPT) with explicit prompting over a generic NMT engine** — and for keeping the native-speaker author as the final reviewer, since she catches *siya* gender, dropped *po*, and flattened Taglish register that no model reliably handles.

---

## 5. Chapter-by-chapter workflow

### Chunk size — bounded chunks, not whole books, bigger than a sentence
There's genuine tension in the research. Document-level work shows multi-sentence context improves quality (pronouns, register, discourse); ~10-sentence chunks were "almost universally" best and **full-document consistently underperformed** in one study ([arxiv.org/html/2504.12140](https://arxiv.org/html/2504.12140)). But book-length evaluation shows **sharp degradation at 4k–8k token contexts** — some models stop translating and start summarizing — compounded by the "lost in the middle" positional bias (U-shaped attention; >30% drop for mid-context content) ([arxiv.org/pdf/2509.17249](https://arxiv.org/pdf/2509.17249), [arxiv.org/pdf/2508.19578](https://arxiv.org/pdf/2508.19578), [arxiv.org/abs/2406.16008](https://arxiv.org/abs/2406.16008)).

**Practical synthesis:** translate at **scene / sub-chapter granularity** (~a few hundred to ~2,000 tokens, comfortably below the 4k danger zone), giving the model paragraph-level discourse context but not dumping a whole long chapter in one call. A large context window *lets* you do multi-chapter passes but that's a capability claim, not a quality guarantee — the research argues against relying on it for literary voice. (Note: fine-tuned doc-MT models tolerate larger chunks; this guidance is for an off-the-shelf LLM via API, which is this app's case.)

### Consistency across chapters — running glossary + carried context
- **Glossary as a hard constraint, not a suggestion.** Raw LLM calls "enforce terminology probabilistically." The production fix is a pipeline: lexically match source strings against the glossary, inject only the relevant terms as structured context, then validate term adherence post-generation (~80% publish-ready in Lokalise's report) ([lokalise.com/blog/ai-translation-glossary](https://lokalise.com/blog/ai-translation-glossary/)).
- **Auto-built, self-updating fiction glossary.** Open-source tools like LLM Novel Translator auto-generate and update a series glossary of names/places/ranks across chapters ([github.com/qw02/llm-novel-translator](https://github.com/qw02/llm-novel-translator)).
- **Glossary + style guide split:** glossary = the "what" (right words/names), style guide = the "how" (tone/register/voice) — both needed ([lingualinx.com](https://www.lingualinx.com/blog/the-role-of-style-guides-and-glossaries-in-localization-projects)).
- **Carry prior-chapter context.** Feed the previous chapter's translated tail + a brief running summary into each new chunk — the practical analogue of "style memory" ([arxiv.org/html/2504.12140](https://arxiv.org/html/2504.12140), Ch2Ch literary work [arxiv.org/abs/2407.08978](https://arxiv.org/abs/2407.08978)).
- **CAT tools** (Trados/memoQ/Phrase) institutionalize this — translation memory + termbase + MT in one workspace ([memoq.com](https://www.memoq.com/tools/what-is-a-translation-memory/)). The app should reimplement the *concepts* (glossary, TM-like reuse, prior-chapter context), not require a CAT tool.

### Human-in-the-loop review (the author is the editor)
Best UX is **segment-level bilingual side-by-side editing**: source left, translation right, click-to-edit per segment/paragraph ([otranslator.com](https://otranslator.com/en/blog/download-bilingual-PDF-for-easy-comparison), [Google Translation Hub post-edit docs](https://docs.cloud.google.com/translation-hub/docs/user-post-edit)). For literary work use the **full post-editing** standard (match style/nuance), not light post-editing, since LLM output is "more literal and less diverse" ([aclanthology.org/2025.naacl-long.548](https://aclanthology.org/2025.naacl-long.548/), [tarjama.com](https://tarjama.com/9-best-practices-for-machine-translation-post-editing-mtpe/)). Optionally use a quality-estimation pass to flag risky segments. 2025 practitioner consensus (~66%) is that post-editing is useful but still needs substantial skilled human intervention ([blog.gts-translation.com](https://blog.gts-translation.com/2025/04/07/the-state-of-machine-translation-post-editing-mtpe-in-2025-what-translators-think/)). **Feed approved segments back into the glossary/style memory so consistency compounds across chapters.**

---

## 6. Cost & privacy

### Rough API cost per chapter
Assume a chapter ≈ **3,000–5,000 English words ≈ ~5K–7K input tokens** (source + glossary + prior-chapter context) and **~5K–8K output tokens** (translation). With a **two-pass** (translate + reflect) workflow, roughly **double** the token volume. Authoritative Claude pricing (per 1M tokens, from the `claude-api` skill, cached 2026-06-04):

| Model | Input $/1M | Output $/1M | ~Cost / chapter (two-pass, ~15K in + ~16K out) |
|---|---|---|---|
| **Claude Opus 4.8** (`claude-opus-4-8`) | $5.00 | $25.00 | **~$0.48** |
| **Claude Sonnet 4.6** (`claude-sonnet-4-6`) | $3.00 | $15.00 | **~$0.29** |
| **Claude Haiku 4.5** (`claude-haiku-4-5`) | $1.00 | $5.00 | **~$0.10** |

Order-of-magnitude comparison from public 2025–2026 sources (figures move fast — verify before quoting): **GPT-5-class** roughly $1.25–$5 input / $10–$30 output per 1M ([pricepertoken.com — GPT-5](https://pricepertoken.com/pricing-page/model/openai-gpt-5), [skywork.ai](https://skywork.ai/skypage/en/gpt-5-5-api-pricing-features/2047576515257520128)); **Gemini 2.5 Pro** ~$1.25 input / $10 output ([openrouter.ai/google/gemini-2.5-pro](https://openrouter.ai/google/gemini-2.5-pro), [tldl.io](https://www.tldl.io/resources/google-gemini-api-pricing)); **DeepL API Pro** ~$5.49 per 1M *characters* with a 500K-char/mo free tier (character-based, not directly comparable) ([eesel.ai/blog/deepl-pricing](https://www.eesel.ai/blog/deepl-pricing)).

**Takeaway:** A full ~30-chapter book on a two-pass Claude pipeline costs roughly **$3–$15 total** depending on model — **Sonnet 4.6 is the sweet spot** for cost/quality on this volume; reserve **Opus 4.8** for a final high-stakes pass or the reflection step. Prompt caching (cache the static system prompt + style brief + glossary across chapters) further cuts repeated-context cost ~90% on cache reads.

### Bring-your-own-key (BYOK) vs developer-hosted key — for a FREE open-source app
- **Developer-hosted key (you pay):** best UX (zero setup), but for a *free* app you'd be funding every user's translations — financially unsustainable, plus you bear all rate-limit, abuse, and data-handling liability. Untenable at scale for a free GitHub project.
- **Bring-your-own-API-key (recommended):** each user supplies their own Anthropic/OpenAI key; you store it locally (macOS Keychain), call the provider directly, and the app stays free to ship. The user controls and pays their own (small) costs and owns the privacy relationship with the provider. This is the standard pattern for free/open-source AI desktop apps.

**Privacy:** With BYOK, the manuscript goes from the user's Mac directly to the provider under the user's own account/terms — no third-party server in between. Anthropic's API does **not** train on API data by default and offers configurable retention (note: zero-data-retention is *not* available on the Fable-tier model, but standard Opus/Sonnet/Haiku are fine). Store the key in **Keychain**, never in plaintext config or git. Clearly disclose in-app that chapter text is sent to the chosen provider.

**Recommendation: BYOK, Keychain-stored, provider-direct calls, with Anthropic as the default provider** — keeps the app free and open-source, gives the author full control of cost and data, and avoids you hosting or paying for inference.

---

## RECOMMENDATION

**Model.** Default to **Claude** for voice-preserving literary translation — it's the most consistently cited frontier model for authorial voice, tone, and long-document consistency, and DeepL/Sudowrite don't solve this problem. Concretely: run the **draft pass on Claude Sonnet 4.6** (`claude-sonnet-4-6`, ~$0.29/chapter, the cost/quality sweet spot) and the **reflection/refine pass on Claude Opus 4.8** (`claude-opus-4-8`) for the highest-fidelity polish. Make the provider pluggable so a user can choose GPT-5-class as a steerable alternative.

**Prompting.** Use a **literary-translator persona + rich style brief + glossary/do-not-translate list + prior-chapter context**, translate at **paragraph/scene granularity**, and run a **two-pass translate-then-reflect** loop (the best-supported technique — Andrew Ng's translation-agent / TEaR). Bake in explicit handling of the Tagalog/Taglish pitfalls: preserve intentional Taglish register, keep *po/opo* and discourse-particle nuance, resolve *siya* from a per-character gender record (never stereotype), render idioms by equivalence, and treat repurposed English words (*comfort room*, *nosebleed*, *salvage*) carefully.

**Workflow.** Chapter-by-chapter, chunked at **scene/sub-chapter level (≤~2K tokens, below the 4k degradation zone)**; maintain an **auto-updating glossary + style memory** (names, places, register, per-character gender) injected as a hard constraint and validated post-generation; carry the **previous chapter's tail + a running summary** into each chunk for cross-chapter consistency; and present output in a **segment-level bilingual side-by-side editor** so the author does full post-editing and her edits feed back into the glossary. The author — a native speaker — is the final editor; the LLM is a strong draft-and-refine engine, not a replacement (peer-reviewed evidence still puts human literary translation ahead of every LLM).

**API-key model.** **Bring-your-own-key**, stored in the macOS **Keychain**, calling the provider directly from the app — the only sustainable, privacy-respecting choice for a free open-source GitHub app. Default provider Anthropic; disclose data flow in-app; use prompt caching of the static prompt/glossary to cut cost ~90% on repeated context.
