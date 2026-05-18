# Pith Voice — Design system report

Generated 2026-05-19 by the `/design-system` skill. Pastes into SPEC.md
under `## Design system`. Anchors live at
`.design-system/pith-voice-2026-05-19/references/`. Preview at
`.design-system/pith-voice-2026-05-19/preview.html`.

---

## Design system

The design tokens here are derived from the Design vector section above
and from a focused reference scan of editorial-register mobile apps via
Lazyweb (8 anchors: The New Yorker, Substack, The Atlantic, Granola,
Otter, Apple Journal, Andante, Persist) and 2 anti-anchors (Calm,
Headspace) used as the boundary line for what Pith Voice is NOT.

### Reference style anchors

- **The New Yorker** (Magazines & Newspapers) — siteId 9166,
  `the-new-yorker-article.png`. Editorial serif hero, generous whitespace,
  publication header treatment.
- **Substack** (News) — siteId 65176, `substack-onboarding.png`.
  Onboarding typographic restraint, primary CTA, light legal text.
- **The Atlantic** (Magazines & Newspapers) — siteId 14422,
  `the-atlantic-feed.png`. Editorial card composition with serif title.
- **Granola** (Productivity) — siteId 71195, `granola-recording.png`.
  Voice recording + transcription pattern, live timer with pause control.
- **Otter** (Productivity) — siteId 73679, `otter-playback.png`.
  Post-recording detail (Summary / Transcript / Chat tabs), waveform
  scrubber.
- **Apple Journal** (Health & Fitness) — siteId 69079,
  `apple-journal-composer.png`. Journal entry composer pattern from
  Apple's own first-party app — affirms the journal-as-place metaphor.
- **Andante** (Music) — siteId 70062, `andante-voice-memo.png`.
  Minimalist voice memo with a single hero element.
- **Persist** (Lifestyle) — siteId 71568, `persist-paywall.png`.
  Annual + lifetime + free-trial paywall composition.

Anti-anchors (rejected register, kept as negative example):
- **Calm** — pastel-lifestyle gradients, explicit anti in SPEC.
- **Headspace** — cartoon illustrations, "Calm and Headspace own that
  language; we are not them."

### Tokens — Color (light mode)

| Token | Hex | Use |
|---|---|---|
| `bgCream` | `#FAFAF6` | Primary background (Hadger brand cream) |
| `surfacePaper` | `#FFFFFF` | Elevated cards, modal sheets |
| `surfaceSun` | `#F4EFE6` | Subtle warm wash for emphasised rows |
| `textInk` | `#1F1B16` | Primary text — warm near-black |
| `textStone` | `#6B6358` | Secondary text |
| `textMute` | `#9C9388` | Tertiary text, placeholder |
| `hairline` | `#E5DFD2` | Subtle dividers |
| `accentMoss` | `#4A5D3A` | Primary accent (outside Ember ±30° hue range) |
| `accentMossSoft` | `#7B8E6A` | Accent on tinted surfaces |
| `chipTag` | `#EFE9DD` | Quiet tag chip background |
| `danger` | `#A04A37` | Destructive (warm, not clinical) |

Dark mode pairs all of the above; see `tokens/tokens.json`.

**Studio-locked color (NOT in DesignSystem):** Ember `#A8481C` —
inline literal in `HadgerMark.swift` and `AboutView.swift` only, per
SPEC § Brand constraints.

### Tokens — Typography

- `heroSerif` — system serif (New York), semibold, ~34pt — wordmark,
  hero. Dynamic Type-scaled.
- `titleSerif` — system serif, medium, ~22pt — entry titles, section
  headers.
- `title` — SF Pro Rounded semibold, ~20pt — sub-section headers.
- `body` — SF Pro Rounded regular, ~17pt — primary body copy.
- `bodyItalic` — system serif italic, ~17pt — live partial transcript
  during recording (FR-2). Voice-being-spoken register.
- `callout` — SF Pro Rounded regular, ~16pt.
- `caption` — SF Pro Rounded regular, ~13pt — metadata, tags.
- `captionSmall` — SF Pro Rounded medium, ~11pt — editorial date
  stamps.

All Dynamic Type-compatible (NFR-5).

### Tokens — Spacing

4-point grid. `xs: 4`, `s: 8`, `m: 16`, `l: 24`, `xl: 32`, `xxl: 48`,
`xxxl: 64`. Every padding / gap / margin must use these tokens —
SwiftLint custom rule `no_raw_padding_outside_design_system` enforces.

### Tokens — Corner radii

`sm: 8` (chips), `md: 12` (cards, paywall plan rows), `lg: 20`
(Record button, modal sheets), `xl: 32` (large surfaces),
`pill: 999` (status pills, secondary CTAs).

### Tokens — Shadows

`s1: 0/1/3, 6%` — subtle card lift.
`s2: 0/4/12, 8%` — modal / paywall card.
`s3: 0/8/24, 10%` — Record button at rest.

Sparingly used; at most one elevation step per screen.

### Tokens — Motion

`fast: 0.18s ease-out` — state changes.
`normal: 0.28s ease-out` — tab switches, modal presentation.
`expressive: 0.45s ease-out` — paywall reveal, "Drawing the pith…"
shimmer fade-in.

`Reduce Motion` (NFR-7) drops everything to opacity-only at `.fast`
duration. Marked `[inferred]` where Lazyweb couldn't show motion —
durations derived from SPEC § Visual character.

### Implementation rules for Claude Code

(See SPEC § Implementation rules — six rules already enforced via
SwiftLint custom rules and the pre-merge grep.)

### Validation log

- **Decision:** `accentMoss = #4A5D3A`.
  **Source:** SPEC § Brand constraints requires accent outside Ember
  `#A8481C ± 30°` hue range. Moss green at hue ~95° is 130° away from
  Ember (~20°). Anchors: The Atlantic uses moss-adjacent green for
  category labels; Granola uses similar muted nature tone.
  **Rejected:** deep teal `#1F3A4B` (too clinical, blue-anchored);
  burnt sienna `#B8624A` (too close to Ember hue).
- **Decision:** Background = Cream `#FAFAF6`.
  **Source:** Hadger brand backdrop per SPEC § Brand constraints
  ("App-icon backdrop on marketing site uses Cream `#FAFAF6`"). NYT
  Cooking palette is the canonical reference for the warm reading-room
  feel.
  **Rejected:** pure white `#FFFFFF` (clinical, SaaS-cold per anti-
  register); off-white `#F5F5F5` (no warmth, generic).
- **Decision:** Hero / entry titles in system serif (New York).
  **Source:** SPEC § Visual character — "Serif for headlines and entry
  titles". Anchors: New Yorker, Atlantic, Substack all use serif hero.
  Apple Journal uses sans-serif and we deliberately diverge to land
  the editorial register more strongly than Apple's first-party app.
  **Rejected:** Sans-only (too SaaS); custom display font (no
  shipping budget, Dynamic Type compatibility risk).
- **Decision:** Subtle motion 180–450ms ease-out, no springs on UI
  chrome.
  **Source:** SPEC § Visual character verbatim. Reduce-Motion handled
  per NFR-7. Marked `[inferred]` because Lazyweb is static.
- **Decision:** Tag chips at `chipTag #EFE9DD` with `caption` font,
  pill-adjacent radius `sm: 8`.
  **Source:** Sarah persona will reject any chip that looks
  "gamification" — solved with warm taupe background (no saturated
  hue) and small radius (no full pill, which reads category-bucket).

---

## Persona validation pass

Step 7 of the design-system skill — feedback simulation.

**Sarah (primary persona, 32, marketing/design IC, Brooklyn).**
Reaction simulated: opens preview.html. Reads as "Substack you'd
read on Sunday." Cream + serif + moss accent lands. No
sparkle, no pastel, no streak. Passes.

**James (secondary, privacy-hawk, UK).**
Reaction: editorial register. No AI iconography. Mossgreen does
not perform tech. Passes.

**Olivia (secondary, psychotherapist).**
Reaction: not clinical, not "AI therapist" — palette is warm not
medical, and there are no coaching tropes. Passes.

**Carla (secondary, perimenopause).**
Reaction: not Calm-for-younger-people. Warm editorial reading-room.
Passes.

No re-query loop triggered. Persona validation closed without
iteration. If preview.html review with the owner surfaces a structural
objection (palette feels off, register doesn't land), we re-enter
Step 5 for the affected axis only and update tokens + preview.

---
