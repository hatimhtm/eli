# Relaxing, Eye-Comfortable Color Themes for a Long-Form Writing App

Research brief for a distraction-free book-writing app (macOS). Goal: ~10 named themes
that minimize eye strain over multi-hour reading/writing sessions. All values are
hand-tuned and contrast-checked (WCAG sRGB formula) to sit in a *calm* contrast band,
not a maximal-contrast one.

Constraints honored:
- **No green anywhere** — no sage/mint/forest. Cool themes use blue/slate only.
- A dedicated **burgundy / wine** family (light "blush" + dark "wine").
- Warm, low-glare, paper-like defaults; softened darks.

---

## 1. Why not pure white (#FFFFFF) for the page

Pure white at full screen luminance is the single biggest avoidable strain factor in a
reading app:

- On an emissive display, a white page is a light source pointed at the eye. Measured
  effective radiance of a sepia/warm page is roughly **~25% lower** than a pure-white
  page at the same brightness setting, which directly lowers visual fatigue over long
  sessions. ([techcrawlr](https://techcrawlr.com/which-is-best-for-eyes-while-reading/))
- White-on-screen contrast is *more* pronounced than ink-on-paper, so the same black
  text feels harsher digitally than in a printed book.
  ([techcrawlr](https://techcrawlr.com/which-is-best-for-eyes-while-reading/))
- Slightly off-white / warm-grey backgrounds reduce glare while preserving legibility —
  this is the standard recommendation for long-form reading surfaces.
  ([UXmatters](https://www.uxmatters.com/mt/archives/2007/01/applying-color-theory-to-digital-displays.php))

**Warm paper / sepia reference values found in the wild:**

- Kindle sepia: background **#FBF0D9**, text **#5F4B32** — the canonical e-reader warm page.
  ([greatnote](https://www.greatnote.com/2018/03/kindle-sepia-color-code.html))
- Classic "sepia" reading tone ≈ **#F4ECD8** (warm beige) with dark-brown text ≈ **#5B4636**;
  eyes respond well to the softer, warmer spectrum vs. the white spectrum.
  ([techcrawlr](https://techcrawlr.com/which-is-best-for-eyes-while-reading/),
  [media.io sepia](https://www.media.io/color-palette/sepia-color-palette.html))
- Solarized "Base3" cream (**#FDF6E3**) was explicitly designed as an old-paper light
  background that is "much better for your eyes than a pure white background."
  ([Ethan Schoonover / Solarized](https://ethanschoonover.com/solarized/),
  [Silphium Design](https://silphiumdesign.com/solarized-palette-hex-codes-biophilic-design/))

**Calm cool tones** (the only non-warm family here, since green is excluded): a very light,
slightly-blue "mist" grey reads as cool and clean without glare. Solarized's dark base
(**#002b36**) is a dark *blue*-leaning tone designed for balanced, low-fatigue contrast —
the inspiration for the "Midnight" dark-blue theme below.
([Silphium Design](https://silphiumdesign.com/solarized-palette-hex-codes-biophilic-design/))

**Blue-light note:** warmer page tints shift the display toward lower color temperature
(less short-wavelength blue), which is associated with reduced strain in long sessions —
the same principle behind macOS Night Shift and f.lux. Evidence on *sleep/melatonin* from
spectrum-only changes is mixed (a 2018 study found spectrum change without brightness
change may be insufficient), but the *comfort/strain* benefit of warmer, dimmer pages is
well supported. ([ViewSonic](https://www.viewsonic.com/library/business/blue-light-filter-eye-strain/),
[f.lux / Wikipedia](https://en.wikipedia.org/wiki/F.lux),
[PMC night-workers study](https://pmc.ncbi.nlm.nih.gov/articles/PMC6717920/))

---

## 2. Dark mode: why not pure black (#000000) + softened text

- Pure black with pure-white text is *too* high-contrast: it causes **halation** — light
  text appears to bleed/glow and "vibrate" against the black, blurring edges and tiring
  the eye, especially for astigmatic readers.
  ([DubBot](https://dubbot.com/dubblog/2023/dark-mode-a11y.html),
  [weareaffective](https://weareaffective.com/learning-centre/what-are-the-best-practices-for-dark-mode-colour-schemes))
- **Material Design** specifies dark grey **#121212**, not black, as the base dark surface.
  Grey shows elevation/depth (shadows are visible on grey, not on black) and reduces eye
  strain because light text on dark grey is lower-contrast than on pure black.
  ([Material Design — Dark theme](https://m2.material.io/design/color/dark-theme.html))
- **Text should be off-white, not #FFFFFF.** Recommended dark-mode body colors cluster
  around **#E0E0E0–#F0F0F0**; pure white "glows" during long reading.
  ([weareaffective](https://weareaffective.com/learning-centre/what-are-the-best-practices-for-dark-mode-colour-schemes),
  [themeandcolor dark palette](https://themeandcolor.com/blog/dark-mode-color-palette))
- **Text-emphasis opacity tiers (Material):** primary/high-emphasis ~**87%**, secondary
  ~**60%**, disabled ~**38%** of the on-surface color — a useful model for primary vs.
  dim/secondary text. ([Material Design — Dark theme](https://m2.material.io/design/color/dark-theme.html))
- Poorly executed dark mode (wrong contrast) has been shown to *reduce* reading
  comprehension, so the dark themes below are tuned to a moderate band, not maxed out.
  ([Tenacity](https://tenacity.io/facts/how-poor-dark-mode-design-reduces-reading-comprehension-by-14-percent/))

A **warm dark** (very dark brown-grey, e.g. #211E1B / #241B17) is even gentler than neutral
grey for a writing app because it continues the warm, low-blue page feel into dark mode.

---

## 3. Optimal contrast for *comfort* (not maximum)

- WCAG floors: **4.5:1** for normal body text (AA), **3:1** for large/secondary text;
  AAA is **7:1**. These are *legibility floors*, not comfort targets.
  ([WebAIM](https://webaim.org/articles/contrast/),
  [W3C 1.4.3](https://www.w3.org/TR/UNDERSTANDING-WCAG20/visual-audio-contrast-contrast.html))
- Meeting 4.5:1 "does not mean the ratio is always comfortable" — it is a reliable floor;
  comfort needs balancing with typography and brightness.
  ([AAArdvark 1.4.3](https://aaardvarkaccessibility.com/wcag-plain-english/1-4-3-contrast-minimum/))
- Maximum contrast is **not** ideal: real readability depends on brightness, rendering,
  and font weight; if text feels brittle, the guidance is to use a *less pure-black*
  background or slightly heavier weight rather than crank brightness.
  ([KTC display contrast](https://us.ktcplay.com/blogs/technology-hub/display-contrast-ratio-text-readability-dark-backgrounds),
  [MDN color contrast](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides/Understanding_WCAG/Perceivable/Color_contrast))

**Working comfort band used for these themes:**

| Role | Target ratio | Rationale |
|------|--------------|-----------|
| Body text | **~7:1 to ~13:1** | Above AAA floor, well below the harsh ~21:1 of black-on-white. Calm, "printed-page" feel. |
| Dim / secondary text | **~4:1 to ~6.5:1** | Clearly quieter than body but still above the 3:1 large-text floor; readable for metadata, word counts, captions. |

Pure black on pure white is 21:1 — deliberately avoided everywhere below.

---

## 4. Burgundy / wine family

Burgundy reference: standard burgundy **#800020**; modern berry-wine anchors **#6B1E2E**,
deep velvet wines **#5C0011 / #5A0F2E**; classic soft companions are cream **#FFF8F0** and
blush **#E8B4B8 / #F5E3DA**. Burgundy pairs beautifully with warm cream for typography —
"keep backgrounds creamy, use burgundy for headlines, avoid a heavy page."
([media.io wine-burgundy](https://www.media.io/color-palette/wine-burgundy-color-palette.html),
[media.io burgundy](https://www.media.io/color-palette/burgundy-color-palette.html),
[themeandcolor burgundy](https://themeandcolor.com/blog/burgundy-color-palette),
[Figma burgundy](https://www.figma.com/colors/burgundy/))

Two themes deliver this:

- **Wine (dark):** deep wine-near-black page **#2A1118** with warm cream text **#E9D7C7**
  and a dusty-rose dim **#B98A8A** — velvet-curtain mood, body contrast ~12.6:1.
- **Blush (light):** soft warm-pink page **#F7EAEA** with deep burgundy text **#5A1A2B**
  and a muted wine dim **#8A4A55** — body contrast ~11:1.

---

## 5. The 10 themes (concrete hex)

Body-text contrast ratio shown in the rationale is computed with the WCAG sRGB formula.
All are warm/low-glare except **Mist** and **Midnight** (the two calm cool options;
neither uses any green).

| # | Theme | Background | Primary text | Dim / secondary | Body ratio | Rationale + source |
|---|-------|-----------|--------------|-----------------|-----------|--------------------|
| 1 | **Light** | `#F7F6F2` | `#2B2B2B` | `#6B6B68` | 13.1:1 | Soft off-white, never pure #FFFFFF, with near-black (not pure black) ink — glare-reduced default. ([UXmatters](https://www.uxmatters.com/mt/archives/2007/01/applying-color-theory-to-digital-displays.php)) |
| 2 | **Cream** | `#FBF8F1` | `#3A3A38` | `#7C7468` | 10.8:1 | Old-paper cream à la Solarized Base3; warmer than Light, easy for long sessions. ([Solarized](https://ethanschoonover.com/solarized/)) |
| 3 | **Sepia** | `#F4ECD8` | `#5B4636` | `#7A6248` | 7.5:1 | Classic sepia: warm beige + dark-brown ink; softer spectrum, ~25% less radiance than white. ([techcrawlr](https://techcrawlr.com/which-is-best-for-eyes-while-reading/)) |
| 4 | **Sand** | `#EDE6D6` | `#4A4036` | `#756A5A` | 8.1:1 | Deeper, low-glare kraft/parchment tone for bright rooms; warm and matte. ([media.io sepia](https://www.media.io/color-palette/sepia-color-palette.html)) |
| 5 | **Mist** | `#EAEEF2` | `#33404A` | `#5E6A74` | 9.1:1 | Calm *cool* light option (no green): faint blue-grey page with slate ink. ([Silphium Design](https://silphiumdesign.com/solarized-palette-hex-codes-biophilic-design/)) |
| 6 | **Blush** (wine light) | `#F7EAEA` | `#5A1A2B` | `#8A4A55` | 11.1:1 | Burgundy light mode: soft blush page + deep wine ink; "creamy bg, burgundy text." ([media.io burgundy](https://www.media.io/color-palette/burgundy-color-palette.html)) |
| 7 | **Dark** | `#1E1E1E` | `#D6D3CC` | `#9A968C` | 11.2:1 | Material-style dark grey (#121212 family), off-white warm-grey text — no halation. ([Material](https://m2.material.io/design/color/dark-theme.html)) |
| 8 | **Warm Dark** | `#211E1B` | `#E4DCCF` | `#A89F90` | 12.2:1 | Warm dark brown-grey + cream text: carries the low-blue paper feel into dark mode. ([themeandcolor dark](https://themeandcolor.com/blog/dark-mode-color-palette)) |
| 9 | **Midnight** | `#14181F` | `#C9D1D9` | `#8B949E` | 11.5:1 | Calm dark *navy/blue* (Solarized-dark inspired), softened blue-grey text; no pure black. ([Silphium Design](https://silphiumdesign.com/solarized-palette-hex-codes-biophilic-design/)) |
| 10 | **Espresso** | `#241B17` | `#E8D9C5` | `#B09A82` | 12.2:1 | Deep coffee-brown page + warm cream text — coziest warm dark for night writing. ([techcrawlr](https://techcrawlr.com/which-is-best-for-eyes-while-reading/)) |
| 11 | **Wine** (burgundy dark) | `#2A1118` | `#E9D7C7` | `#B98A8A` | 12.6:1 | Deep wine/velvet dark mode + warm cream text, dusty-rose dim; the burgundy showpiece. ([media.io wine](https://www.media.io/color-palette/wine-burgundy-color-palette.html)) |

(11 listed so the burgundy family ships as a matched **Blush + Wine** pair; trim to 10 by
dropping **Sand** or **Mist** if a round number is required.)

All dim/secondary values were tuned to 4.2:1–6.4:1 (quieter than body, above the 3:1
large-text floor). No pair uses pure #000000 or pure #FFFFFF; no green appears anywhere.

---

## Sources

- [techcrawlr — Black vs White vs Sepia for eyes](https://techcrawlr.com/which-is-best-for-eyes-while-reading/)
- [UXmatters — Applying Color Theory to Digital Displays](https://www.uxmatters.com/mt/archives/2007/01/applying-color-theory-to-digital-displays.php)
- [greatnote — Kindle sepia color code (#FBF0D9 / #5F4B32)](https://www.greatnote.com/2018/03/kindle-sepia-color-code.html)
- [media.io — Sepia palette](https://www.media.io/color-palette/sepia-color-palette.html)
- [Ethan Schoonover — Solarized](https://ethanschoonover.com/solarized/)
- [Silphium Design — Solarized palette hex / biophilic guide](https://silphiumdesign.com/solarized-palette-hex-codes-biophilic-design/)
- [ViewSonic — Blue light filter & eye strain](https://www.viewsonic.com/library/business/blue-light-filter-eye-strain/)
- [Wikipedia — f.lux](https://en.wikipedia.org/wiki/F.lux)
- [PMC — Screen light filtering, cognition & sleep in night workers](https://pmc.ncbi.nlm.nih.gov/articles/PMC6717920/)
- [DubBot — Dark Mode best practices for accessibility](https://dubbot.com/dubblog/2023/dark-mode-a11y.html)
- [weareaffective — Dark mode colour scheme best practices](https://weareaffective.com/learning-centre/what-are-the-best-practices-for-dark-mode-colour-schemes)
- [Material Design — Dark theme (#121212, opacity tiers)](https://m2.material.io/design/color/dark-theme.html)
- [themeandcolor — Dark mode color palette](https://themeandcolor.com/blog/dark-mode-color-palette)
- [Tenacity — Poor dark mode reduces comprehension](https://tenacity.io/facts/how-poor-dark-mode-design-reduces-reading-comprehension-by-14-percent/)
- [WebAIM — Contrast and Color Accessibility](https://webaim.org/articles/contrast/)
- [W3C — Understanding SC 1.4.3 Contrast (Minimum)](https://www.w3.org/TR/UNDERSTANDING-WCAG20/visual-audio-contrast-contrast.html)
- [AAArdvark — 1.4.3 plain English](https://aaardvarkaccessibility.com/wcag-plain-english/1-4-3-contrast-minimum/)
- [KTC — Display contrast ratio & readability on dark backgrounds](https://us.ktcplay.com/blogs/technology-hub/display-contrast-ratio-text-readability-dark-backgrounds)
- [MDN — Color contrast](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides/Understanding_WCAG/Perceivable/Color_contrast)
- [media.io — Burgundy palette](https://www.media.io/color-palette/burgundy-color-palette.html)
- [media.io — Wine-burgundy palette](https://www.media.io/color-palette/wine-burgundy-color-palette.html)
- [themeandcolor — Burgundy palette](https://themeandcolor.com/blog/burgundy-color-palette)
- [Figma — Burgundy color](https://www.figma.com/colors/burgundy/)
</content>
</invoke>
