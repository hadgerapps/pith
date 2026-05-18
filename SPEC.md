# Pith Voice — Technical Specification v1.2

**App:** Pith Voice — a journal you speak, kept on your iPhone
**Studio:** Hadger (ИП Шмигирилов, Apple Team `X243T6N439`)
**App Store display name:** `Pith Voice`
**Bundle ID:** `com.hadger.pith` (Apple-bound — already registered in
Developer Portal `Z84G867MYW` with `IN_APP_PURCHASE` capability; ASC App
record `6770544476` already created under this bundle ID; cannot be
changed)
**Repository:** `hadgerapps/pith` (already live; public pages already
served from `docs/`)
**Public pages:** `https://hadgerapps.github.io/pith/`
**ASC API key (studio-wide):** `9P9W84M53Z` / Issuer
`3030c9a1-732a-427c-a680-1de04cd5005d`; `.p8` at
`/Users/vassiliyshmigirivov/Apple_apps/AuthKey_9P9W84M53Z.p8`
**Source brief:** `Pith_BRIEF_0.2.md` (marketing handoff, 2026-05-16;
brief referred to the product as "Pith" — renamed to "Pith Voice" at the
App Store layer in v1.1 after Apple's name-uniqueness check blocked the
bare "Pith" stem; bundle ID remains `com.hadger.pith` since v1.0)
**Date:** 2026-05-19
**Version history:**
- **v1.0** (2026-05-16) — initial SPEC from marketing brief handoff.
  Bundle ID `com.hadger.pith`, repo `hadgerapps/pith`, URLs
  `hadgerapps.github.io/pith/`.
- **v1.1** (2026-05-19, morning) — app renamed `Pith` → `Pith Voice`
  at the **product / App Store layer** after Apple's name-uniqueness
  check blocked the bare "Pith" stem (`Pith: Focus & Flow`,
  `com.redcrumb.pith`, Productivity, released 2026-04-27 holds it).
  Draft v1.1 over-rotated and proposed migrating the bundle ID to
  `com.hadger.pithvoice`, repo to `pith-voice`, URLs to
  `hadgerapps.github.io/pith-voice/`, product IDs to
  `com.hadger.pithvoice.*` — this was the section corrected in v1.2.
  ASO title / subtitle / keywords reworked to avoid tautology with the
  new name; new mandatory **Phase 0 — Skill audit** added before any
  code work; Implementation rules updated to require skill discovery
  and use.
- **v1.2** (2026-05-19, afternoon) — infrastructure-bound identifiers
  reverted to v1.0 values after live ASC API verification revealed:
  (a) bundle ID `com.hadger.pith` is already registered in Developer
  Portal as `Z84G867MYW` with `IN_APP_PURCHASE` capability;
  (b) ASC App record `6770544476` for the display name "Pith Voice"
  is bound to bundle ID `com.hadger.pith` and cannot be re-bound;
  (c) GitHub repo `hadgerapps/pith` already exists with live public
  pages serving from `docs/`. Apple does not permit changing the bundle
  ID of an existing ASC App record, so the v1.1 draft would have
  required deleting and re-creating the App record, losing the SKU and
  history. The product / display-name / wordmark / keywords layer is
  unchanged from v1.1 — it stays `Pith Voice` everywhere user-facing.
  Open questions 1, 7, and 11 closed (see § Open questions for
  per-item resolution).

This document is the single source of truth for Claude Code. It must be
the file at the repository root as `SPEC.md`. Claude Code reads it via
`@SPEC.md`. All implementation derives from this file; any deviation
between code and this file is a defect in this file, not the code.

The companion file `CLAUDE.md` at the repo root contains a single line:
`See @SPEC.md for the full specification.`

---

## Summary

Pith Voice is a journal you speak. It lives entirely on the iPhone.
The user taps to record, speaks for 2–8 minutes, and stops. Apple's
`SpeechAnalyzer` transcribes locally in seconds. Apple's
`FoundationModels` produces a short summary and 2–4 thematic tags.
Over days and weeks, a Threads view surfaces what the user keeps
returning to. Nothing about any of this — audio, transcripts, themes,
usage — leaves the device unless the user explicitly exports. There
is no account, no server, no telemetry, and no iCloud sync by default.

---

## Goals

1. **Capture-to-insight under 10 seconds.** From "Stop recording" to
   "summary + themes visible" must complete in ≤10 s on iPhone 15 Pro
   for a 4-minute entry.
2. **Verifiable on-device claim.** A user running Pith Voice on airplane mode
   experiences full functionality. A user running a network proxy
   (Charles, Proxyman) observes zero outbound traffic from Pith Voice
   processes outside StoreKit endpoints.
3. **Habit-forming returning surface.** Day-7 paid retention ≥ 28 %,
   driven by Threads + Read me back rather than streaks or push.
4. **Mid-premium revenue per install.** D14 revenue per install ≥ $2.00
   (RC SOSA 2026 hard-paywall median is $2.32).
5. **Vector-compliant calm design.** Result of `/design-system` passes
   the Vector compliance check against the Design vector below.

## Non-goals

These are out of scope for v1 and v1.1. Several encode the brand
stance — they will not be revisited without a major version bump.

- **No server, no backend, no proprietary API.** All processing on
  device. Sole outbound traffic: StoreKit endpoints (Apple-controlled)
  and a one-time check for App Store review status if rejected.
- **No cloud AI.** No OpenAI, no Whisper, no third-party transcription
  or LLM endpoints. Apple frameworks only.
- **No iCloud sync by default in v1.** v1.1 will revisit optional
  opt-in iCloud sync with end-to-end encryption only if cross-device
  retention analysis demands it; otherwise single-device-forever is
  the brand commitment.
- **No accounts.** No sign-up, no Sign in with Apple, no email, no
  password. The device IS the account.
- **No analytics SDK.** No Mixpanel, Amplitude, RevenueCat SDK,
  Firebase, Sentry, Crashlytics, Bugsnag. The only telemetry the app
  emits is what `MetricKit` and `StoreKit` send to Apple — both of
  which are on-device aggregation and opt-out in iOS Settings.
- **No social, no sharing, no community, no public profile.**
- **No streaks, no badges, no heat-maps, no gamification, no points,
  no levels.**
- **No AI chat / reply features.** The journal does not talk back.
  The summary is a noun, not a response.
- **No coaching, no prompts, no suggestions.** Pith Voice does not tell the
  user what to journal about.
- **No iPad, Mac Catalyst, watchOS, visionOS, tvOS.** iPhone only.
- **No free trial.** Adapty SOIS 2026 documents a 21.2 % LTV penalty
  for trials in Lifestyle.
- **No paid upfront, no ads, no in-app credits, no consumables.**
- **No push notifications in v1.** Local notifications only, and only
  for reminders the user opts into.
- **No deep-link advertising surface.** No App Clips. No widgets in
  v1 (widget is a v1.1 candidate).
- **No localisations beyond US English in v1.** UK / CA / AU spelling
  drift is tolerated. DE / FR / ES localisation is v1.1.

## Goals → metrics map

| Goal | Primary metric | Source-of-truth |
|---|---|---|
| Capture-to-insight ≤ 10 s | p50 latency from stop-tap to summary-visible | local debug log; manual measurement on QA device |
| Verifiable on-device | zero outbound (non-StoreKit) bytes in 1-hour proxy session | manual QA via Proxyman before each release |
| Day-7 paid retention ≥ 28 % | App Store Connect Analytics — Paying users retention | ASC dashboard, monthly review |
| D14 revenue per install ≥ $2.00 | ASC Analytics — proceeds + installs (no SDK) | ASC dashboard, weekly during first 90 days |
| Vector compliance | pass / fail Vector compliance check | manual pass per `DESIGN_SYSTEM_GUIDE.md` |

---

## User flows

Each flow is the eventual basis for acceptance criteria and XCUITest
cases. Each begins from a known state and ends at an observable
result.

### Flow 1 — First entry (Aha moment)

1. User installs Pith Voice from App Store. Opens the app.
2. Onboarding (3 screens — see Onboarding flow below) ends with the
   microphone permission prompt. User grants.
3. Main screen shows a single Record button on a Cream background.
4. User taps Record. Live waveform animation begins. Live partial
   transcript appears in serif italic below the waveform as
   `SpeechAnalyzer` emits partial results.
5. User speaks for ~3 minutes about their day. Taps Stop.
6. `SpeechAnalyzer` finalises the transcript on-device within ~2 s.
7. `FoundationModels` produces a 2–3-sentence summary and 2–4
   thematic tags within ~6 s. UI shows a "Drawing the pith…"
   ambient state during this window (not a spinner; a typographic
   shimmer on the placeholder lines).
8. The entry card appears: date · audio · transcript · summary · tags.
   User reads, optionally renames the entry, taps Done.

**Result:** entry persisted to SwiftData. `pith_entry_count = 1`.

### Flow 2 — Second entry → paywall

1. User opens Pith Voice on Day 2. Sees yesterday's entry on Today screen.
2. Taps Record. Records second entry. Sees second summary + themes.
3. Closes app.
4. User opens Pith Voice for the third entry attempt.
5. Tap on Record triggers paywall (hard, full-screen, not skippable).
6. Paywall shows: Annual $59.99 / Lifetime $99.99 / Weekly $4.99 in
   that order. CTA: "Subscribe" or "Unlock for life". Restore
   purchases button visible. Subscription Disclosure block visible
   in-frame.
7. User selects Annual. Apple Pay sheet. Confirms.
8. Receipt verified locally via `StoreKit 2.Transaction`. User
   returns to Record screen. Records third entry.

**Result:** active entitlement persisted; paywall never shown again
unless entitlement expires.

### Flow 3 — Returning user (Day 7+)

1. User opens Pith Voice on Day 7+. Today screen shows recent entries.
2. Bottom tab bar shows: **Today** · **Threads** · **Settings**.
3. User taps Threads. Sees 3–4 themes of the past week, each with a
   one-sentence summary and a count of underlying entries.
4. User taps a theme. Sees a chronological list of entries that
   contributed, with excerpts. Each excerpt links to its entry.

**Result:** user perceives accumulation. Threads is the surface
that earns the subscription beyond the initial Aha.

### Flow 4 — Read me back (comfort surface, retention rescue)

1. User opens Pith Voice after 5+ days of inactivity. Today screen detects
   the gap.
2. Above the Record button appears a single secondary action:
   **Read me back**. It plays yesterday's most recent entry in the
   user's own voice with a quiet "1 ago" timestamp.
3. Playback uses `AVAudioPlayer`. Lock-screen and Control Center
   show the playback (`MPNowPlayingInfoCenter`).
4. User listens, returns to the Record screen — or doesn't.

**Result:** no penalty for inactivity. The return surface is comfort,
not guilt. If the user creates a new entry within 24 h of a Read me
back session, the session is logged locally as a "return success."

### Flow 5 — Weekly Threads digest (passive surfacing)

1. Once a week (Friday 8 AM by default; user-configurable in
   Settings), Pith Voice schedules a local notification (only if user opted
   in during onboarding step 4).
2. Notification copy: "Your week, in 4 sentences." Tap opens the
   Threads view directly.
3. The week's themes are recomputed locally when Threads is opened
   (not pre-cached; computation budget ~3 s on iPhone 15 Pro).

**Result:** non-promotional return trigger. No streak, no count.

### Flow 6 — Search ("what did I say about Mom this month?")

1. User pulls down on Today screen. Search bar appears.
2. User types or speaks a natural-language query.
3. `FoundationModels` performs a guided search: first by tag overlap
   (instant), then by transcript text match (instant), then by
   semantic relevance via on-device embedding similarity (1–3 s).
4. Results appear chronologically with snippet highlights.

**Result:** local search. Zero network traffic. No "did you mean"
or other LLM-rephrasing — the query is the query.

### Flow 7 — Manual export (data portability, App Review nicety)

1. User opens Settings → "Export your journal."
2. Confirms export. Pith Voice assembles a ZIP containing:
   - `entries.json` (transcripts, summaries, tags, timestamps)
   - `audio/` folder with `.m4a` files keyed to entry IDs
   - `README.md` explaining the format
3. iOS share sheet appears. User saves to Files, AirDrops, etc.

**Result:** the user can leave with everything they ever created.
No lock-in. This satisfies App Store Review Guidelines 5.1.1(v)
on data portability.

### Flow 8 — Entry detail and deletion

1. User taps any entry from Today or Threads.
2. Detail screen shows audio playback control, full transcript, AI
   summary, thematic tags, and an edit action (rename entry title,
   re-run AI on edited transcript).
3. Swipe-left on the list or "Delete" action in detail removes the
   entry — confirmation prompt warns deletion is permanent.

**Result:** full CRUD. Deleted entries are not recoverable (no
"trash" surface in v1).

### Flow 9 — Action Button (iPhone 15 Pro+, iPhone 16+)

1. User opens Settings → "Connect to Action Button." Instruction:
   "In iOS Settings → Action Button → choose Shortcut → Start Pith Voice
   recording."
2. Pith Voice exposes an App Intent (`StartRecordingIntent`) via the
   `AppIntents` framework.
3. Holding the Action Button launches recording directly without
   opening the app UI; an iOS "Live Activity" or notification banner
   confirms recording is in progress.
4. User stops recording via the same Action Button or by opening the
   app.

**Result:** capture friction approaches zero. This is the
"on-walks-home" use case from the brief.

---

## Monetization

### Model

**Auto-renewing subscription (weekly, annual) + non-consumable lifetime
IAP. Hard paywall after N = 2 free entries. No free trial.**

This deviates from four Hadger studio defaults. Each deviation is
defended in the brief (§7 of `Pith_BRIEF_0.2.md`) and accepted in
this SPEC:

- Pricing above Tier 1 default — competitive necessity in the
  $39–108 annual range for AI-voice journals.
- Annual + lifetime in v1 (not v1.1) — Adapty SOIS 2026 documents
  annual retention 19.9 % vs weekly 5.5 % at D380.
- Hard paywall (not hybrid soft) — RC SOSA 2026: hard 10.7 % vs
  freemium 2.1 % paid-conversion median.
- No trial — Adapty SOIS 2026: Lifestyle trials cost 21.2 % LTV.

### Pricing

| Product ID | Period | Price (USD) | Apple tier |
|---|---|---|---|
| `com.hadger.pith.sub.weekly` | weekly | $4.99 | T-5 |
| `com.hadger.pith.sub.annual` | annual | $59.99 | T-45 |
| `com.hadger.pith.iap.lifetime` | one-time | $99.99 | T-75 (non-consumable) |

The legacy short forms `pith.sub.weekly`, `pith.sub.annual`, and
`pith.iap.lifetime` used in the brief are aliases of the canonical
`com.hadger.*` IDs above. App Store Connect uses canonical IDs.

### Paywall

- **Type:** hard, full-screen, no dismiss. Not skippable.
- **Trigger:** the 3rd entry-record attempt. Counter persisted in
  UserDefaults and migrated alongside SwiftData on reinstall (Keychain
  flag `pith.entitlement.firstUseDate` survives reinstall as the
  guard against "uninstall to reset counter" exploit).
- **Display order:** Annual (largest, recommended badge) →
  Lifetime (second, "Never expires" caption) → Weekly (smallest, "Try
  weekly" framing).
- **Headline:** "Keep showing up for yourself." (Hadger voice —
  outcome-led, not feature-led.)
- **CTA buttons:** "Subscribe" for sub products; "Unlock for life"
  for the lifetime IAP. No "Start free trial" copy anywhere.
- **Mandatory elements (App Review):** Restore Purchases (single
  tap), Subscription Disclosure block (renewal terms, cancellation
  via Settings → Apple ID), Privacy Policy link, Terms link.
- **Below the fold:** "What stays on your iPhone" — a 3-bullet
  on-device reassurance band, reinforcing the value at the moment of
  purchase decision.

### Retention triggers

All triggers are local and gentle. None are streaks or shame loops.

| Trigger | Surface | Frequency |
|---|---|---|
| Weekly Threads digest | Local notification | Friday 8 AM, opt-in |
| Read me back | Today screen, above Record | Auto-surfaces after 3+ idle days |
| New theme detected | Subtle Today-screen banner | When a new theme reaches confidence threshold |
| Annual renewal reminder | StoreKit-driven, system banner | iOS handles natively |

No streak counters. No "you missed a day" notifications. No re-engagement
push outside the weekly digest.

### Conversion targets (90-day, US)

These are targets, not commitments. Refine post-launch with App Store
Connect Analytics.

| Metric | Source benchmark | Target |
|---|---|---|
| Paywall view → paid | 10.7 % median hard (RC SOSA 2026) | ≥ 9 % |
| D14 revenue per install | $2.32 median hard (RC SOSA 2026) | ≥ $2.00 |
| Download → first entry | n/a | ≥ 55 % |
| First entry → second entry | n/a | ≥ 40 % |
| D7 paid retention | ~28 % proxy (Adapty Lifestyle, US-adj) | ≥ 28 % |
| D30 paid retention | n/a | ≥ 14 % |
| D365 annual subscriber retention | 19.9 % global (Adapty 2026) | ≥ 22 % |
| US refund rate | 4.2 % AI-app median (RC SOSA 2026) | ≤ 4.5 % |

### Failure modes and v1.1 levers

| Signal | Diagnosis | v1.1 response |
|---|---|---|
| Paywall → paid < 6 % | Too few free entries OR price too high | A/B N=3 free entries; A/B annual $49.99 |
| Paywall → paid > 15 % | Underpriced | Raise annual to $79.99 |
| D7 < 22 % | AI magic isn't landing | Onboarding sequence audit |
| US refund > 5 % | Onboarding over-promises on privacy | Audit screenshot copy |
| D30 < 10 % | Read me back not discoverable | Promote in returning-user moment |

---

## Design vector

> This section is the **input** for the `/design-system` skill. It
> describes direction only. Concrete hex values, font sizes, spacing
> scales, corner radii, and SwiftUI component code are produced by the
> skill in Phase 2 and live in the `## Design system` section that
> the skill will append below.
>
> If anyone — human or AI — adds a `## Design system` section to this
> file before the skill has run, that is an error. Delete it.

### Target emotional register

Pith Voice should feel like:

- **Quiet, adult, considered.** A reading-room voice, not a wellness
  app voice.
- **Editorial.** Like a New Yorker column or a Substack you read on
  Sunday morning, not a productivity SaaS.
- **Warm but restrained.** There is care in the layout. There is not
  enthusiasm.
- **Confident in plain language.** Not "AI-powered." Not "intelligent
  insights." Not "your journey." Words mean what they say.

What Pith Voice must NOT feel like:

- **Clinical.** No doctor's-office blues, no caretaker grey. Pith Voice is
  not a mental health intervention — it is a place to keep what you
  said.
- **Gamified.** No streaks, no medals, no points, no progress bars
  that fill. No celebratory animations on completing an entry.
- **AI-startup neon.** No purple-to-pink gradients, no shimmering
  "✨ AI ✨" sparkle motifs, no oversaturated accent. The AI is
  Apple's; we don't perform it.
- **Pastel-lifestyle.** No millennial-coral, no sage-mint, no Pinterest
  aesthetic, no soft-illustration onboarding.
- **Productivity-mode.** No dark-by-default, no Linear-grade
  monochrome density, no information-rich dashboards.

### Audience anti-patterns (must avoid)

Derived from the brief's persona walkthrough (§9) and the validation
log below. Each is a concrete sensory pattern that alienates a
target segment.

- **Cold medical blues** (`#3B82F6 / #2563EB / #1D4ED8` family) —
  reads as "clinic" to the therapy-going Sarah segment and the
  privacy-hawk James segment.
- **High-saturation gamification accents** (Duolingo orange, Headspace
  marigold, neon green for "you did it!") — reads as "wellness scam"
  to the privacy-hawk and the cynical-engineer Mike segments.
- **Pastel gradients** (Pinterest aesthetic, Calm-app blue-purple
  background) — reads as "lifestyle brand for someone else" to the
  editorial-leaning Sarah and James.
- **Sans-serif everywhere** — reads as cold/SaaS to the editorial
  audience. The journal layer of the app needs at least one serif
  surface to land as a reading place, not a tool.
- **AI sparkle iconography** (✨, gradient orbs, animated Siri
  shimmer) — performs AI in a category where the user's whole reason
  to install is mistrust of cloud AI. Counterproductive.
- **Streak counters, "X days in a row"** — punishes the returning-after-a-
  gap user; specifically what Read me back exists to undo.
- **Heat-map calendars** — gamification surface that converts
  reflection into compliance.
- **Onboarding cartoon illustrations** — Calm and Headspace own that
  language; we are not them.

### Reference register

Three to five products/apps with explicit notes on **what** we take
from each. We do not copy any of them whole.

- **NYT Cooking app** — warm editorial palette (cream / sand /
  rust-accent), serif headlines, generous whitespace. Take: palette
  temperature and the unhurried reading-room feel. Don't take: photo
  density, recipe-card layout.
- **Stripe Press / Stripe Atlas onboarding** — typographic restraint,
  monochrome with one muted accent, trust signals that whisper
  rather than shout. Take: typographic confidence, restraint with
  colour. Don't take: B2B coolness.
- **Substack reader** — generous whitespace, reading-first layout,
  serif body type acceptable when long-form. Take: the reading-place
  framing. Don't take: subscription banners, social affordances.
- **Day One Journal** — the journal-as-archive metaphor, calendar-
  driven entry list, photo-on-day-card composition (we adapt to
  audio waveform on day-card). Take: the journal-as-place feel.
  Don't take: cluttered toolbars, "moments" surfaces.
- **Things 3** — quiet UI density, restrained motion, "nothing
  unnecessary on screen at once" discipline. Take: the
  one-thing-at-a-time pacing. Don't take: productivity-app coldness.

### Visual character

High-level orientation tokens. **No specific hex, no specific px, no
specific component names** here — those are the skill's job.

- Editorial over playful.
- Generous whitespace; one-thing-on-screen-at-a-time.
- Serif for headlines and entry titles; sans-serif (SF Pro Rounded
  family) for body, controls, and UI chrome.
- One muted accent colour, not a multi-colour palette. The accent is
  for action affordances (Record button, primary CTA) and nothing else.
- Light mode primary. Dark mode is a first-class citizen — not an
  inverted afterthought.
- Subtle motion: 200–300 ms ease-out for state changes; nothing
  bouncy; nothing that draws attention to itself.
- Iconography: SF Symbols only, monoline, no filled-and-coloured
  variants for primary surfaces.
- Date typography is a first-class element of every entry card —
  dates carry the journal-as-time-record feeling.
- The waveform during recording is the visual hero — calm, organic,
  not "audio-meter aggressive."

### Brand constraints (Hadger)

What is locked by `Hadger_BRAND_README_2.0.md` and cannot be touched
by Pith Voice's design system:

- **Hadger mark uses Ember `#A8481C` always — never recoloured.**
- The About screen renders the `HadgerMark` SwiftUI snippet from
  `Hadger_BRAND_README_2.0.md` (4-primitive shape, no asset-catalog
  dependency) with the text "Made by Hadger" and a tap-through to
  `https://hadger.com`.
- App-icon backdrop on the marketing site at `hadgerapps.github.io/pith/`
  uses Cream `#FAFAF6`.
- Pith Voice's own accent colour MUST be visually distinguishable from
  Hadger Ember — no near-orange, near-rust, or near-coral primary
  accent. (Pith Voice's accent should land somewhere outside the
  `#A8481C ± 30°` hue range. Skill: pick accordingly.)
- The wordmark "Pith Voice" on app surfaces uses the same SF Pro Display
  stack as the Hadger wordmark; letter-spacing tunable by skill.
- App icon (1024×1024) is a Pith Voice-specific mark designed in Phase 1.
  It is NOT the Hadger Ember mark with a Pith Voice colourway — Hadger is
  the studio, not the app brand.

---

## Functional requirements

Each requirement has an ID (`FR-N`), priority (`MVP` / `v1.1` /
`Later`), and acceptance phrasing in past tense ("Given … When … Then
…") that maps directly to a test case.

### Capture & transcription

- **FR-1 [MVP]** — Record audio. Given the main screen, when the user
  taps Record, then audio capture begins via `AVAudioEngine` at
  44.1 kHz mono AAC, persisted to a temporary file under
  `Caches/recordings/`, and a live waveform animation runs at ≥ 30 fps.
- **FR-2 [MVP]** — Live partial transcript. Given an active recording,
  when `SpeechAnalyzer` emits a partial result, then the partial
  transcript text updates within ~500 ms in the live transcript
  region. Locale: `en-US`.
- **FR-3 [MVP]** — Stop recording. Given an active recording, when the
  user taps Stop, then the recording finalises, the file is committed
  to `Documents/audio/<entry-id>.m4a` with `NSFileProtectionComplete`,
  and the finalised transcript is requested from `SpeechAnalyzer`.
- **FR-4 [MVP]** — Maximum recording length. Given an active recording,
  when the duration reaches 30 minutes, then recording auto-stops and
  the user is shown a "30-minute limit" toast. The hard cap exists for
  battery/thermal reasons.
- **FR-5 [MVP]** — Microphone permission. Given the user has not
  granted microphone permission, when they tap Record for the first
  time, then iOS shows the standard permission prompt with our
  `NSMicrophoneUsageDescription` copy ("Pith Voice records audio you choose
  to journal. Nothing leaves your iPhone.").
- **FR-6 [MVP]** — Speech permission. Given the user has not granted
  speech-recognition permission, when they tap Record for the first
  time, then iOS shows the standard permission prompt with our
  `NSSpeechRecognitionUsageDescription` copy ("Pith Voice transcribes your
  voice on this device. Nothing leaves your iPhone.").

### AI summarisation & themes

- **FR-7 [MVP]** — Generate summary. Given a finalised transcript,
  when the entry is committed, then `FoundationModels` produces a 2–3
  sentence summary via guided generation against a Swift
  `@Generable` struct, completing within ~6 s for a 600-word
  transcript on iPhone 15 Pro.
- **FR-8 [MVP]** — Extract themes. Given a finalised transcript, when
  the entry is committed, then `FoundationModels` produces 2–4
  thematic tags (strings, lowercased, ≤ 2 words each) via the same
  guided-generation call. Tags are subject-of-thought ("boundary,"
  "exhaustion," "Mom"), not categorical buckets.
- **FR-9 [MVP]** — Drawing-the-pith state. Given an entry is awaiting
  summary, when the user is on the entry detail screen, then the
  summary and tags regions show a typographic shimmer (not a system
  spinner) labelled "Drawing the pith…" until the result lands.
- **FR-10 [MVP]** — Re-run AI on edit. Given an entry exists, when the
  user edits the transcript and taps Save, then the summary and tags
  are regenerated; the previous values are overwritten (no version
  history in v1).
- **FR-11 [MVP]** — Graceful AI failure. Given `FoundationModels`
  returns an error (model unavailable, out-of-memory, content policy
  refusal), when the entry would otherwise be committed, then the
  entry is saved with transcript and audio intact, summary and tags
  are marked "Unavailable — tap to retry," and the user can re-trigger
  generation manually.

### Storage & data lifecycle

- **FR-12 [MVP]** — Persist entry. Given a finalised transcript, audio
  file, summary, and tags, then a SwiftData `Entry` record is created
  with: `id` (UUID), `createdAt` (Date), `duration` (TimeInterval),
  `audioFilename` (String), `transcript` (String), `summary` (String?),
  `tags` ([String]), `summaryState` (`pending` / `ready` / `failed`),
  `userTitle` (String?). All fields stored locally.
- **FR-13 [MVP]** — Encrypt at rest. Given any persisted audio file or
  SwiftData record, then the file/container uses
  `NSFileProtectionComplete` (data inaccessible when device is
  locked). Verified by build-time assertion.
- **FR-14 [MVP]** — Delete entry. Given an entry exists, when the user
  swipes-to-delete or taps Delete in detail view, then a confirmation
  prompt appears; on confirm, the SwiftData record and audio file are
  permanently removed. No undo.
- **FR-15 [MVP]** — Export. Given the user taps "Export your journal"
  in Settings, then the app assembles `pith-export-<yyyy-MM-dd>.zip`
  containing `entries.json`, `audio/*.m4a`, and `README.md`, and
  presents the iOS share sheet.
- **FR-16 [MVP]** — Excluded from iCloud Backup? **No** — entries
  participate in standard encrypted iCloud Backup so a new-phone
  restore brings the journal back. This is consistent with "stays on
  your iPhone" because Apple's iCloud Backup is end-to-end encrypted
  when Advanced Data Protection is on and Apple-managed otherwise;
  it is not "Pith Voice sync."

### Today screen

- **FR-17 [MVP]** — Today view. Given the user opens Pith Voice, then the
  Today screen shows: a serif greeting (`"Pith Voice"` wordmark + today's
  date in editorial typography), the Record button, and below it a
  chronological list of recent entries (most-recent first, grouped by
  day).
- **FR-18 [MVP]** — Entry card on Today. Each card shows: date, audio
  duration ("4 min"), entry title (user title or first-line of
  transcript truncated), summary (truncated to two lines), and tags
  as quiet inline chips.
- **FR-19 [MVP]** — Read me back surface. Given the user has been
  inactive ≥ 72 hours and yesterday's entry exists, when the user
  opens Today, then a secondary "Read me back" action appears above
  the Record button with a quiet "N days ago" caption.
- **FR-20 [MVP]** — Search. Given the user pulls down on Today, then a
  search bar appears; queries match against transcript text and tags
  (instant), then against semantic similarity via Foundation Models
  (~1–3 s).

### Threads view

- **FR-21 [MVP]** — Threads view. Given the user taps the Threads tab,
  then the app computes the 3–4 strongest themes of the past 7 days
  by tag frequency and semantic clustering via Foundation Models,
  showing each theme with a one-sentence summary and a count of
  contributing entries.
- **FR-22 [MVP]** — Theme detail. Given the user taps a theme, then
  a chronological list of contributing entries appears with
  excerpts. Tapping an excerpt opens the entry detail.
- **FR-23 [MVP]** — Theme period selector. Given the user is on
  Threads, then a period selector at the top toggles "This week" /
  "Last week" / "This month" (default: "This week").
- **FR-24 [v1.1]** — Long-arc Threads ("This year"). Computed nightly
  on charge, cached. Not in MVP because computation cost on a year's
  worth of entries may exceed user-acceptable latency.

### Read me back

- **FR-25 [MVP]** — Playback. Given the user taps Read me back, then
  the most recent entry's audio plays via `AVAudioPlayer`, with
  `MPNowPlayingInfoCenter` populated for lock-screen and Control
  Center display showing "Pith Voice — N days ago."
- **FR-26 [MVP]** — Playback controls. Standard controls: play /
  pause / 15 s back / 15 s forward / scrubber.
- **FR-27 [MVP]** — No autoplay. Read me back never starts
  automatically; it is always a user-initiated action.

### Onboarding

- **FR-28 [MVP]** — Onboarding sequence (4 screens, all skippable
  after the first):
  1. **What Pith Voice is.** Serif headline: "A voice journal that stays
     on your iPhone." Subhead: brief plain-language sentence.
     Continue.
  2. **What stays here.** Three on-device promises with the
     specific Apple framework names (`SpeechAnalyzer`,
     `FoundationModels`). Continue.
  3. **Permissions.** Inline explainer of microphone + speech
     permission prompts. "Allow" button triggers iOS prompts.
  4. **Weekly Threads.** Opt-in to the Friday digest via standard
     `UNUserNotificationCenter` permission prompt. "Maybe later"
     skips.
- **FR-29 [MVP]** — Onboarding completion state persisted in
  UserDefaults; not shown again unless the user resets via Settings
  → "Show onboarding again."

### Settings

- **FR-30 [MVP]** — Settings list:
  - Subscription status (managed by `StoreKit.SubscriptionStatusView`
    or equivalent).
  - Manage subscription (deep link to iOS Settings).
  - Restore Purchases.
  - Export your journal.
  - Connect to Action Button (instructional + App Intent install
    confirmation).
  - Weekly Threads digest (toggle).
  - Privacy Policy (web view to `hadgerapps.github.io/pith/privacy`).
  - Terms of Service (web view to
    `hadgerapps.github.io/pith/terms`).
  - Support (mailto: `hadger.support@gmail.com`).
  - About (HadgerMark + "Made by Hadger" tap-through to
    `https://hadger.com`).
  - Version + build number (tap 5 times reveals diagnostics, see
    FR-32).
  - "Show onboarding again" (debug-style affordance, harmless).

### Monetization

- **FR-31 [MVP]** — Paywall trigger. Given the user has reached 2
  persisted entries (regardless of session), when they attempt a 3rd
  Record, then the paywall is presented modally and is not
  dismissable until Subscribe / Unlock / Restore or paywall-specific
  "× Close" tap (which returns to Today without a 3rd entry).
- **FR-32 [MVP]** — Entitlement check. Given a paywall is presented,
  when the user purchases a product, then `StoreKit.Transaction`
  verification runs locally, the entitlement is cached in Keychain
  (`pith.entitlement.kind` = `weekly` | `annual` | `lifetime`,
  `pith.entitlement.expiresAt` = Date?), and the paywall dismisses.
- **FR-33 [MVP]** — Reinstall guard. Given the user has previously
  purchased and reinstalls the app, when they reach the paywall,
  then a Restore tap recovers entitlement via
  `Transaction.currentEntitlements`. The entry counter resets to 0
  on fresh install but the Keychain flag
  `pith.entitlement.firstUseDate` is preserved across reinstall —
  preventing repeated "delete & reinstall to reset" behaviour without
  punishing legitimate device-switch users.
- **FR-34 [MVP]** — Subscription expiry. Given an annual or weekly
  subscription lapses, when the user next opens the app, then they
  see the paywall on the next Record attempt; existing entries
  remain visible and exportable. Pith Voice never deletes user data based
  on subscription state.

### Diagnostics & developer affordances

- **FR-35 [v1.1]** — Local diagnostics view (hidden behind 5-tap on
  version label in Settings): last 50 events from a local
  `OSLog`-backed ring buffer; copy-to-clipboard. No network upload.

### Privacy & telemetry

- **FR-36 [MVP]** — Privacy Manifest. The app ships a Privacy Manifest
  (`PrivacyInfo.xcprivacy`) declaring: no tracking, no data collection
  beyond the StoreKit minimum that Apple itself reports for
  subscription state.
- **FR-37 [MVP]** — No analytics SDK. The build process fails if any
  non-Apple analytics dependency is detected in the SPM resolution
  graph. SwiftLint rule: forbid imports of `Sentry`, `Mixpanel`,
  `Amplitude`, `FirebaseAnalytics`, `RevenueCat`, `Crashlytics`,
  `Bugsnag`.

### Non-functional requirements

- **NFR-1 [MVP]** — Latency. p50 capture-to-summary ≤ 10 s on iPhone
  15 Pro for a 4-minute entry. p95 ≤ 18 s.
- **NFR-2 [MVP]** — Battery. A 5-minute entry must consume ≤ 1 % of
  battery on iPhone 15 Pro (measured via `MetricKit`).
- **NFR-3 [MVP]** — Storage. A 5-minute entry (audio + transcript +
  summary + tags) consumes ≤ 4 MB on disk.
- **NFR-4 [MVP]** — Cold-start. App launch (icon-tap to Today
  visible) ≤ 1.5 s on iPhone 15 Pro.
- **NFR-5 [MVP]** — Accessibility. All interactive elements have
  VoiceOver labels and Dynamic Type support up to `xxxLarge`. The
  waveform during recording has a VoiceOver accessibility action that
  speaks "Recording. Tap to stop."
- **NFR-6 [MVP]** — Localisation-ready. All UI strings live in
  `Localizable.strings`; v1 ships `en` only; v1.1 adds `de`, `fr`,
  `es`.
- **NFR-7 [MVP]** — Reduce Motion. With Reduce Motion on, the
  waveform animation shows a static muted state; the "Drawing the
  pith…" shimmer fades rather than shimmers.
- **NFR-8 [MVP]** — Dark Mode parity. Light and dark themes are
  designed in parallel — no inverted-light hack.

---

## Technical decisions

### Platform & runtime

- **Minimum iOS:** **iOS 26.0.** Required for the
  `FoundationModels` framework and the `SpeechAnalyzer` API. This is
  a deviation from the Hadger default of iOS 17 — defended in
  Open Question 2 of the brief and accepted here: the product
  *is* on-device AI, and the framework that provides it is gated to
  iOS 26+.
- **Device gating:** iPhone 15 Pro, 15 Pro Max, 16/16 Plus/16 Pro/16
  Pro Max, 17 Pro/17 Pro Max — i.e. any
  Apple-Intelligence-capable iPhone. Enforced via Info.plist
  `UIRequiredDeviceCapabilities` (`apple-intelligence` capability if
  Apple exposes it; otherwise via runtime check at first launch with
  a clear "Pith Voice needs iPhone 15 Pro or newer." landing screen).
- **Orientation:** portrait only.
- **iPad:** disabled. `UIDeviceFamily` = `1` (iPhone) only.

### Language & frameworks

- **Swift** — latest stable.
- **SwiftUI** as the primary UI framework. UIKit only via
  `UIViewRepresentable` shims for `MPNowPlayingInfoCenter` and any
  edge cases that arise in practice — each shim requires justification
  in the code comment.
- **Swift Concurrency** (async/await, actors). No Combine.
- **`AVFoundation` / `AVAudioEngine`** for recording.
- **`Speech` framework** specifically the new `SpeechAnalyzer` API
  introduced in iOS 26 for on-device transcription.
- **`FoundationModels` framework** for summary and theme generation
  via guided generation (`@Generable`).
- **`SwiftData`** for entry persistence.
- **`StoreKit 2`** for subscriptions and lifetime IAP.
- **`AppIntents`** for the Action Button integration
  (`StartRecordingIntent`).
- **`UserNotifications`** for weekly Threads digest local
  notification.
- **`MetricKit`** for on-device battery / launch / hang signals
  (read locally; never uploaded).

### Architecture

- **Pattern:** MV (Model-View) per Apple's modern SwiftUI guidance.
  No ViewModel layer for v1 — the app's scope is small (single
  user, single device, no network state). Use `@Observable` model
  types and pass them via the environment.
- **Modules:** organised as Swift Packages within the workspace where
  it pays for itself; one app target consumes them. Initial split:
  - `App/` — entry point, app-level state, navigation root.
  - `DesignSystem/` — produced by the `/design-system` skill in
    Phase 1. Imported by all other modules.
  - `Capture/` — recording, transcription pipeline.
  - `Intelligence/` — FoundationModels glue, prompt design.
  - `Storage/` — SwiftData schema + repository protocols.
  - `Paywall/` — StoreKit 2 client + paywall UI.
  - `Threads/` — Threads view + theme clustering.
  - `Export/` — ZIP assembly.
  - `Onboarding/` — onboarding sequence.
  - `Settings/` — Settings screen.
  - `AppIntentsKit/` — Action Button integration.

  In Phase 1, these can start as folders rather than SPM packages —
  promotion to SPM happens when a module exceeds ~500 lines or
  develops a clean public API.

### Foundation Models prompt design

The summary + tags request is a single guided-generation call. The
target Swift struct (subject to skill-influenced renaming):

```swift
@Generable
struct EntryDistillation {
    @Guide(description: "Two to three plain sentences summarising what the speaker said. Past tense. No advice, no reframing, no encouragement.")
    let summary: String

    @Guide(description: "Two to four short thematic tags — subjects of thought, not categorical buckets. Lowercase, one or two words each. Examples: 'boundary', 'exhaustion', 'Mom'.")
    let tags: [String]
}
```

Prompt scaffolding (paraphrased, subject to iteration in Phase 3):

> System: You distill what a person said to themselves into a brief,
> respectful summary. You do not give advice, ask questions, or
> reframe. You write past tense.
>
> User: Here is the transcript: <transcript>
>
> Return an EntryDistillation.

Out-of-policy refusals from Foundation Models are handled per FR-11.

### Storage schema (SwiftData)

```swift
@Model
final class Entry {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var duration: TimeInterval
    var audioFilename: String         // relative to Documents/audio/
    var transcript: String
    var summary: String?
    var tags: [String]
    var summaryState: SummaryState    // pending | ready | failed
    var userTitle: String?
}

enum SummaryState: String, Codable {
    case pending, ready, failed
}
```

Future migrations: SwiftData's `VersionedSchema` mechanism. No
schema changes planned for v1.

### Audio storage

- Files: `Documents/audio/<entry-id>.m4a`, AAC-LC mono 44.1 kHz at
  64 kbps.
- File protection: `NSFileProtectionComplete`.
- Trash: deleted entries' audio files are removed synchronously with
  the SwiftData record.

### StoreKit 2 product configuration

`Configuration.storekit` file in the project for local testing
mirroring App Store Connect:

| ID | Type | Period | Price |
|---|---|---|---|
| `com.hadger.pith.sub.weekly` | auto-renewable subscription | 1 week | $4.99 |
| `com.hadger.pith.sub.annual` | auto-renewable subscription | 1 year | $59.99 |
| `com.hadger.pith.iap.lifetime` | non-consumable IAP | — | $99.99 |

Subscription group: `pith.main` (so weekly and annual cannot be held
simultaneously; lifetime is an independent non-consumable that
supersedes any active subscription).

### Network

- No outbound HTTP from app code.
- The only network usage is what `StoreKit` performs against
  Apple endpoints, which is opaque to the app.
- The App Transport Security policy in Info.plist forbids arbitrary
  loads.
- A debug-only assertion in `URLSession` swizzle (DEBUG configuration
  only) flags any unexpected network usage during development.

### Sign in with Apple

**Not used.** No accounts.

### Push notifications

**Not used in v1.** All retention notifications are scheduled locally
via `UNUserNotificationCenter`.

### Deep links / Universal Links

**Not used in v1.** The marketing site does not need to deep-link
into the app for any goal.

### App Intents / Action Button

`StartRecordingIntent` exposed via `AppIntents`. Donated on first
launch and after each successful recording.

### Logging & diagnostics

`OSLog`-backed ring buffer (last 200 events) accessible only via the
hidden 5-tap diagnostics view (FR-35, v1.1). No file logging in v1.

---

## File structure

```
pith/                                 (repo root)
├── SPEC.md                                 ← this file
├── CLAUDE.md                               ← contains: "See @SPEC.md"
├── README.md                               ← short, English, public
├── .gitignore                              ← Xcode + macOS
├── Secrets.example.xcconfig                ← committed example
├── Secrets.xcconfig                        ← gitignored
├── Configuration.storekit                  ← local StoreKit test config
├── fastlane/
│   ├── Fastfile
│   ├── Appfile
│   └── Matchfile
├── docs/                                   ← GitHub Pages root
│   ├── index.html
│   ├── privacy.html
│   ├── terms.html
│   ├── support.html
│   ├── favicon.ico
│   ├── favicon-16x16.png
│   ├── favicon-32x32.png
│   └── apple-touch-icon.png
├── PithVoice.xcworkspace/
├── PithVoice/                                   ← main app target
│   ├── PithVoiceApp.swift
│   ├── Info.plist
│   ├── PrivacyInfo.xcprivacy
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   └── Colors.xcassets/                ← managed by /design-system
│   ├── DesignSystem/                       ← produced by /design-system skill
│   │   ├── DesignSystem.swift
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   └── Components.swift
│   ├── App/
│   │   ├── RootView.swift
│   │   ├── AppState.swift
│   │   └── HadgerMark.swift                ← from BRAND_README
│   ├── Capture/
│   │   ├── Recorder.swift
│   │   ├── Transcriber.swift               ← SpeechAnalyzer wrapper
│   │   └── WaveformView.swift
│   ├── Intelligence/
│   │   ├── EntryDistillation.swift         ← @Generable
│   │   ├── Distiller.swift
│   │   └── ThemeClusterer.swift            ← used by Threads
│   ├── Storage/
│   │   ├── Entry.swift
│   │   ├── EntryRepository.swift
│   │   └── EntitlementStore.swift          ← Keychain-backed
│   ├── Paywall/
│   │   ├── PaywallView.swift
│   │   ├── PaywallController.swift
│   │   └── ProductCatalog.swift
│   ├── Today/
│   │   ├── TodayView.swift
│   │   ├── EntryCardView.swift
│   │   ├── ReadMeBackView.swift
│   │   └── SearchView.swift
│   ├── Threads/
│   │   ├── ThreadsView.swift
│   │   └── ThemeDetailView.swift
│   ├── EntryDetail/
│   │   └── EntryDetailView.swift
│   ├── Export/
│   │   └── Exporter.swift
│   ├── Onboarding/
│   │   ├── OnboardingFlow.swift
│   │   └── OnboardingScreens.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   ├── AppIntentsKit/
│   │   └── StartRecordingIntent.swift
│   └── Localizable.strings (en)
├── PithVoiceTests/                              ← XCTest + Swift Testing
│   ├── CaptureTests.swift
│   ├── IntelligenceTests.swift
│   ├── StorageTests.swift
│   ├── PaywallTests.swift
│   └── ExporterTests.swift
└── PithVoiceUITests/                            ← XCUITest
    ├── FirstEntryFlowUITests.swift
    ├── PaywallFlowUITests.swift
    ├── ReadMeBackFlowUITests.swift
    └── ExportFlowUITests.swift
```

The `PithVoice/DesignSystem/` subtree is produced and owned by the
`/design-system` skill. No human or AI hand-edits files in that
folder. To change the design system, re-run the skill.

---

## Commands

All commands run from the repository root on the Mac Mini.

```bash
# Build (Debug, simulator)
xcodebuild -workspace PithVoice.xcworkspace -scheme PithVoice \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run unit tests
xcodebuild -workspace PithVoice.xcworkspace -scheme PithVoice \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# Run UI tests
xcodebuild -workspace PithVoice.xcworkspace -scheme PithVoiceUITests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# Format
swiftformat .

# Lint
swiftlint --strict

# Release to TestFlight via Fastlane
fastlane beta

# Promote to App Store
fastlane release
```

Build must succeed with **zero warnings** before any phase is
considered done.

---

## Acceptance criteria

A release candidate is shippable only when every box is checked.

### Phase 0 — Skill audit

- [ ] `docs/CHANGELOG-internal.md` contains a `## Phase 0 — Skill
      audit` block.
- [ ] Every skill directory listed in the SPEC's Phase 0 procedure was
      enumerated; every `SKILL.md` found was read.
- [ ] Each found skill is bound to one or more phases in the
      changelog note.
- [ ] The `/design-system` skill is bound to Phase 1.
- [ ] If a design-review / Vector-compliance skill was found, it is
      bound to Phase 1 step 9 AND to every UI-touching phase
      thereafter (4, 5, 6, 7).
- [ ] If a code-testing skill was found, it is bound to every phase
      where new code is written (2 through 8) and was used to scaffold
      tests for each FR.

### Functional

- [ ] All MVP-priority FRs (FR-1 through FR-37 marked `[MVP]`) pass
      their acceptance phrasings, verified by automated tests where
      automatable.
- [ ] Critical user flows have XCUITest coverage:
      FirstEntryFlow, PaywallFlow, ReadMeBackFlow, ExportFlow.
- [ ] Unit-test coverage ≥ 70 % for `Capture`, `Intelligence`,
      `Storage`, `Paywall`, `Export` modules.
- [ ] App builds with **zero warnings** under Release configuration.
- [ ] SwiftLint passes with zero violations (`--strict`).

### Privacy & on-device claim

- [ ] On airplane mode, the app records, transcribes, summarises,
      shows Threads, plays back Read me back, exports — all without
      degradation.
- [ ] A 1-hour Proxyman network capture during normal use shows zero
      outbound bytes from Pith Voice processes outside `apple.com`
      domains (StoreKit + system).
- [ ] Privacy Manifest declares no tracking and no data-collection
      categories.
- [ ] No analytics SDK present in the SPM resolution graph; lint
      check verifies absence.
- [ ] Microphone and Speech permission prompts use the exact
      `NSMicrophoneUsageDescription` and
      `NSSpeechRecognitionUsageDescription` copy from FR-5 / FR-6.
- [ ] All audio files and SwiftData store use
      `NSFileProtectionComplete`.

### Performance

- [ ] NFR-1: p50 capture-to-summary ≤ 10 s on iPhone 15 Pro (4-min
      entry).
- [ ] NFR-2: 5-minute entry uses ≤ 1 % battery on iPhone 15 Pro.
- [ ] NFR-3: 5-minute entry consumes ≤ 4 MB disk.
- [ ] NFR-4: cold-start ≤ 1.5 s on iPhone 15 Pro.

### Accessibility

- [ ] VoiceOver: every interactive element has a label; full
      first-entry flow can be completed by a VoiceOver user without
      visual cues.
- [ ] Dynamic Type: every screen renders without truncation up to
      `xxxLarge`.
- [ ] Reduce Motion: animation degradations per NFR-7.
- [ ] Dark Mode: every screen has a designed dark-mode variant.

### Design vector compliance

- [ ] **Vector compliance check passes** per the 6-step procedure in
      `DESIGN_SYSTEM_GUIDE.md`. Specifically:
      - [ ] Anti-patterns check: no anti-pattern colours present in
            `Colors.swift`.
      - [ ] Emotional register check: a blind reading of `preview.html`
            matches the Target emotional register.
      - [ ] Reference register check: the result reads as the noted
            qualities from each reference.
      - [ ] Brand constraint check: Hadger Ember not used as Pith Voice
            accent; About screen uses `HadgerMark` snippet.
      - [ ] Persona walkthrough: Sarah, James, and Olivia from the
            Validation log do not reject the visual.
      - [ ] Hard-coded values check: `grep` returns zero hits for
            hex colours, raw `.padding(N)`, and
            `.font(.system(size: N))` outside `DesignSystem/`.

### Store readiness

- [ ] App Store Connect listing complete: title, subtitle, keywords,
      description, screenshots, app review notes.
- [ ] Privacy Policy, Terms, and Support pages live at the
      `hadgerapps.github.io/pith/` URLs.
- [ ] Subscription disclosure text matches Apple template (in-app and
      App Store Connect side).
- [ ] App Privacy section in ASC completed: "Data Not Collected"
      across the board (defensible — Pith Voice truly collects none).
- [ ] App icon (1024×1024) uploaded; favicon and apple-touch-icon
      present in `docs/`.

---

## App Store readiness

### Category and ratings

- **Primary category:** Lifestyle (rationale: Lifestyle AI grew
  691 % YoY per Adapty SOIS 2026, ASO competition for
  voice-journal terms anchors here, our nearest direct competitor
  Pillowtalk is Health & Fitness but Pith Voice's editorial register
  fits Lifestyle better).
- **Secondary category:** Productivity.
- **Age rating:** 12+ (Infrequent/Mild Mature/Suggestive Themes — the
  user may journal about anything; we don't moderate their voice).
- **Content rights:** "Does not contain, show or access third-party
  content."

### Title, subtitle, keywords (paste-ready)

- **Title (≤ 30 chars):** `Pith Voice` (10 chars)
- **Subtitle (≤ 30 chars):** `A journal that stays here.` (26 chars)

  Why this subtitle, not the v1.0 subtitle "Voice journal, on-device.":
  with "Voice" now in the title, repeating it in the subtitle wastes
  ~5 indexable characters and reads tautologically. "A journal that
  stays here." is Hadger voice — plain, declarative, emotionally on
  brand. "Stays here" is shorthand for "stays on your iPhone" and
  pairs with the screenshot 1 headline ("Speak. Stays here.") for a
  cohesive store-page top.

  Backup subtitles (in priority order, swap if A/B preferred):
  1. `Private journal, on-device.` (27 chars) — more literal.
  2. `Stays on your iPhone, always.` (29 chars) — most explicit.
  3. `On-device. Private. Yours.` (26 chars) — terser cadence.

- **Keywords (≤ 100 chars, comma-separated):**
  ```
  voice,diary,journal,audio,memo,transcribe,speech,offline,private,mindfulness,gratitude,therapy
  ```
  (94 chars.) Note the change vs v1.0: with the subtitle no longer
  containing "voice" or "journal", we put them BACK into keywords —
  they are the highest-intent discovery terms in this category. Dropped
  "mood" and "reflection" to make room; both are weaker drivers than
  the two core terms.

### Long description (paste-ready)

```
Speak when you can't write.
Pith Voice is a quiet, private journal you talk to — themes
and summaries drawn by Apple Intelligence, every word kept on
your iPhone. Never uploaded. Never trained on.

A LOCAL JOURNAL, NOT A SERVICE
Pith Voice doesn't have an account. It doesn't sync to iCloud by
default. It doesn't make API calls. The AI that summarises your
day is the iPhone in your hand — Apple Intelligence on-device.
If your phone is in airplane mode, Pith Voice still works.

THE DAY IS A WALK HOME
Tap to record. Speak. Stop. In seconds your transcript appears,
followed by a kind two-sentence summary and a few quiet thematic
tags — the things you keep coming back to. You can read it once
and close the app. The act of having said it is the point.

THREADS, NOT GRAPHS
Once a week, Pith Voice offers a Threads view: the strongest 3–4 themes
of the past seven days, with a sentence each, and the entry behind
each. No streak counters. No heat maps. No badges. Just the shape
of what you've been carrying.

READ ME BACK
Some days you don't want to make anything new. Pith Voice plays back
yesterday's entry in your own voice — proof to yourself that
yesterday existed. The on-ramp back, after the missed weeks.

WHAT PITH VOICE DOES NOT DO
We don't reply. We don't coach. We don't suggest topics. The
journal is yours; we just make it easier to keep.

PRIVACY, LITERALLY
- All transcription runs on-device (Apple SpeechAnalyzer, iOS 26+)
- All AI summaries run on-device (Apple Intelligence, Foundation
  Models)
- No accounts, no servers, no analytics SDKs, no telemetry
- No iCloud sync by default (export is manual and explicit)
- Verifiable via Tracker Control or any network proxy

PRICING
- Annual: $59.99
- Lifetime (one-time, never expires): $99.99
- Weekly: $4.99
- Two free entries before the paywall. No free trial.

Pith Voice is made by Hadger — a one-person iOS studio that ships calm,
private apps for iPhone.
```

The trailing "Our other app, Soft Day…" line from the brief is
**removed** for v1 because Soft Day is not yet shipped. Re-add when
that app is live.

### Screenshots (paste-ready creative brief)

Per the Hadger design vocabulary; produced by the `/design-system`
skill or by hand in Phase 1 in the same style. 6.9" + 6.1" sets.

| # | Type | Headline | Content |
|---|---|---|---|
| 1 | Hook | "Speak. Stays here." | Cream background, serif headline. Subhead: "A voice journal where every word stays on your iPhone." Small badge bottom-left: "Apple Intelligence · On-device". No device mockup. |
| 2 | Value | "Your iPhone listens. Nothing else does." | iPhone 17 Pro Max mockup mid-recording. Waveform animation. Live transcript appearing in serif italic. Quiet "On device" indicator at top. |
| 3 | Trust | "One price. No cloud, ever." | iPhone mockup showing paywall. Annual $59.99 selected; Lifetime $99.99 second; Weekly $4.99 third. Subscription Disclosure block visible in-frame. |
| 4 | Threads | "The shape of what you've been carrying." | iPhone mockup showing Threads view with 3 themes — `boundary` · `exhaustion` · `Mom` — quiet typography, no charts. |
| 5 | Read me back | "Some days you don't want to make anything new." | iPhone mockup showing Today screen with the Read me back affordance highlighted above Record. |

### URLs (in App Store Connect)

| Field | Value |
|---|---|
| Support URL | `https://hadgerapps.github.io/pith/support` |
| Marketing URL | `https://hadgerapps.github.io/pith/` |
| Privacy Policy URL | `https://hadgerapps.github.io/pith/privacy` |
| App Review contact email | `hadger.support@gmail.com` |

### App Privacy (ASC section)

Declare across all data types: **"Data Not Collected."** Defensible
because:

- Audio, transcripts, summaries, tags — all stay on device.
- Subscription state is processed by Apple StoreKit, not Pith Voice.
- No analytics SDK, no first-party telemetry endpoint, no email
  capture.

### App Review notes (paste-ready)

```
Pith Voice is a voice journal that runs entirely on the user's iPhone.

WHAT THE APP DOES
1. Records audio (AVAudioEngine).
2. Transcribes speech on-device using Apple's SpeechAnalyzer API
   (Speech framework, iOS 26+).
3. Generates a short summary and 2-4 thematic tags on-device using
   Apple's FoundationModels framework (Apple Intelligence, iOS 26+).
4. Persists entries locally via SwiftData with NSFileProtectionComplete.
5. Offers a paid subscription or lifetime IAP after 2 free entries
   (hard paywall, no free trial).

VERIFYING THE ON-DEVICE CLAIM
The app works fully in airplane mode after first launch. Reviewers
can verify zero outbound traffic from the app process via Network
Link Conditioner or any network proxy. The only outbound traffic
the app participates in is StoreKit (Apple-controlled).

DEVICE REQUIREMENT
Pith Voice requires iPhone 15 Pro or newer (Apple Intelligence is a hard
requirement for FoundationModels access). The app gracefully
informs the user on unsupported devices with an explanatory screen
rather than crashing.

PERMISSIONS
- Microphone (NSMicrophoneUsageDescription): for recording entries.
- Speech Recognition (NSSpeechRecognitionUsageDescription): for
  on-device transcription via SpeechAnalyzer.
- Notifications (optional): weekly Threads digest only, opt-in.

PAYWALL DEMO
For Apple's reviewers, the paywall triggers after the 3rd entry
attempt. To reach it in a single session, please record 2 short
entries and then tap Record again. Reviewers may also use the
'Restore Purchases' flow with any Sandbox account.

LIFETIME IAP
The non-consumable `com.hadger.pith.iap.lifetime` ($99.99) is
offered alongside the auto-renewable subscriptions, per the
precedent set by Pillowtalk (id6484401671) and Murmur PVN
(id6762516042). This is not a misrepresented subscription — it is
a one-time purchase that grants permanent access to the same
features, as the in-paywall copy and Subscription Disclosure block
make explicit.
```

---

## Validation log

Здесь — журнал прохода по сегментам аудитории и правок, внесённых
в ТЗ после симуляции реакции каждой персоны. Сегменты — расширение
6 персон из брифа (раздел 9) с добавлением двух недостающих
«хвостов», которые маркетинг-команда отметила в Open question 7 как
требующие проверки.

### Сегменты

| # | Персона | Гео | Установит | Купит | Главный риск |
|---|---|---|---|---|---|
| 1 | Sarah, 32, marketing/design IC, weekly therapy | US (Brooklyn) | да | annual | основная персона; ничего не теряем |
| 2 | Mike, 38, software engineer, ADHD, мыслит вслух | US (Austin) | да | lifetime | AI-галлюцинации в саммари → публичный 1-звёздочный отзыв |
| 3 | Emma, 24, грантовая аспирантка, тревожность, чувствительна к цене | US (Chicago) | да | weekly (возможно) | $60/год — реальное препятствие; weekly $4.99 ловит, если конвертируется |
| 4 | James, 35, журналист, privacy-hawk | UK (London) | да | lifetime | Любой analytics SDK, обнаруженный через Tracker Control → 1 звезда со скриншотами |
| 5 | Olivia, 41, психотерапевт, использует для личной рефлексии | AU (Melbourne) | да | annual | Если "Therapy prep" звучит предписывающе или клинически — uninstall |
| 6 | Lukas, 30, дизайнер, не-носитель английского, privacy-conscious | DE (Berlin) | возможно | возможно | English-only v1 — трение; качество транскрипции accented English |
| 7 | Carla, 45, перименопауза, ищет mindful-инструменты | US (San Diego) | возможно | annual | Если визуал считывается как клинический или как Calm/Headspace для молодых — uninstall |
| 8 | Devon, 22, GenZ, нет терапии, использует voice memos для творческих идей | US (LA) | возможно | weekly | Если позиционирование «journal as therapy» — отторжение; нужен use case «creative ideas» |

### Прохождение и правки

#### Sarah (основная персона) — конвертируется в annual
Никаких изменений. ТЗ построено под неё.

#### Mike (engineer, ADHD)
**Симуляция:** скачивает, делает 2 записи, видит AI-саммари. Если хоть
одно саммари галлюцинирует (например, добавляет факт, который Mike не
сказал) — пишет 1-звёздочный отзыв с цитатой галлюцинации.
**Правка в ТЗ:** FR-7 fixed на guided generation с `@Generable` —
структурированный output снижает риск свободных галлюцинаций. Системный
промпт явно говорит: «You do not give advice, ask questions, or
reframe.» Это сужает model behavior. FR-11 описывает graceful failure
вместо тихой подмены.
**Acceptance criterion добавлен:** ручная QA-сессия из 20 записей
2–8 минут каждая, проверка что summary не вводит факты, отсутствующие
в transcripte. Это уже в acceptance.

#### Emma (price-sensitive)
**Симуляция:** видит paywall, оценивает $59.99/год как «месяц аренды
spotify * 6». Может купить weekly $4.99 на эмоции после плохого дня,
потом отменить.
**Правка в ТЗ:** weekly retention низкая (Adapty: 5.5 % @ D380) — но
weekly здесь работает как маленький якорь относительно annual ($4.99/нед
≈ $260/год — annual выглядит как «обманчиво дешёво»). Weekly в третьей
позиции на paywall (раздел Monetization, paywall flow) — это сознательное
решение.
**Никаких изменений ТЗ.** Признаём, что Emma может weekly-and-cancel —
это в failure modes (раздел Monetization).

#### James (privacy hawk, UK)
**Симуляция:** ставит, открывает Charles Proxy / Proxyman, делает
запись. Видит выходящий трафик — пишет 1 звезду со скриншотом. Видит
строго StoreKit на apple.com доменах — пишет 5 звёзд и постит в
r/privacy.
**Правка в ТЗ:** Acceptance criteria → раздел Privacy & on-device claim
содержит явный пункт: «1-hour Proxyman capture during normal use shows
zero outbound bytes outside apple.com domains». **Это блокер релиза.**
FR-37 запрещает SDK-импорты на уровне линта. Privacy Manifest пустой.
**Уже в ТЗ.**

#### Olivia (психотерапевт)
**Симуляция:** оценивает «Therapy prep» use case (раздел 3 брифа). Если
интерфейс звучит как «AI-терапевт» — она удалит как unethical. Если
звучит как «личный инструмент рефлексии» — оставит.
**Правка в ТЗ:** убрал из user flows и FR любое явное упоминание
«therapy prep». Use case остался в брифе как маркетинговая зацепка, но в
продукте сам интерфейс Threads — нейтральный «темы недели». Никаких
терапевтических подсказок (это уже non-goal: «no coaching, no prompts»).
Onboarding screen 1 говорит «voice journal», а не «mental health».
Description body не использует слово «therapy» (использует «reflection»
один раз).
**Внесено в ТЗ.**

#### Lukas (DE, non-native English)
**Симуляция:** скачивает, видит English-only UI — раздражает, но
терпимо. Делает запись на акцентированном английском — `SpeechAnalyzer`
выдаёт ошибки в транскрипции — пишет 2 звезды.
**Правка в ТЗ:** v1.1 explicit goal в Implementation phases — DE/FR/ES
localisation. v1 explicitly English-only (NFR-6). Risk признан в Open
questions.

#### Carla (45, перименопауза)
**Симуляция:** ищет mindfulness apps. Видит обзоры Pillowtalk и Pith Voice.
Если Pith Voice выглядит как Calm для молодых (пастельные градиенты,
иллюстрации) — закроет. Если выглядит как editorial reading room с
warm-tone палитрой — попробует.
**Правка в ТЗ:** добавлено в Audience anti-patterns в Design vector:
«Pastel gradients (Calm-app blue-purple background) — reads as 'lifestyle
brand for someone else'». Reference register явно включает NYT Cooking
(warm editorial palette) — палитра под Карлу так же, как под Сару.
**Внесено в ТЗ (раздел Design vector).**

#### Devon (22, creative ideas)
**Симуляция:** не ищет journaling. Ищет «better voice memos» / «AI voice
notes». Натыкается на Pith Voice. Subtitle «Voice journal, on-device» — может
оттолкнуть (он не ищет journal). Description первая фраза «Speak when
you can't write» — попадает в его use case (записать идею на ходу).
**Правка в ТЗ:** subtitle оставлен (журналисты-аудитория важнее), но в
keywords добавлены `audio`, `memo`, `transcribe` — это ловит Devon на
ASO. Long description первый параграф открывает «Speak when you can't
write» — попадает в его surface. **Уже в ТЗ.**
**Risk не закрывается полностью:** Devon, возможно, всё равно купит
AudioPen, не Pith Voice. Принимаем — это не наша основная персона.

### Итог валидации

- **6 из 8 сегментов конвертируются** в платных в v1 (Sarah, Mike,
  Emma, James, Olivia, Carla).
- **2 из 8 — open** (Lukas — закроется v1.1 DE; Devon — частично, рискует
  уйти к AudioPen, но keywords и description первый параграф ловят его).
- **Главный технический риск** (Mike: AI-галлюцинации) смягчён
  guided generation, явным системным промптом и QA-acceptance.
- **Главный визуальный риск** (Carla, Olivia: клиника / lifestyle для
  молодых) смягчён двумя anti-patterns и reference register в Design
  vector.

Этот журнал передан в Phase 2 как вход для Vector compliance check
(пункт «Persona walkthrough», `DESIGN_SYSTEM_GUIDE.md`).

---

## Implementation phases

Each phase ends with: build green, tests green, manual walkthrough of
its phase-specific acceptance criteria, and a short progress note in
`docs/CHANGELOG-internal.md` (gitignored).

### Phase 0 — Skill audit (mandatory, runs before any other phase)

Before Claude Code writes any code, generates any file, or runs any
tool in this repository, it MUST audit the skills available on this
machine and decide which to use for each subsequent phase. This is
not optional, not a recommendation, and not skippable. Phase 0 produces
a written plan that becomes the implementation roadmap for Phases 1–8.

**Why this phase exists.** Skills encode hard-won environment-specific
knowledge (rendering quirks, framework constraints, output paths,
prompt patterns) that is not in the LLM's weights. A skill that exists
for a task and is not used is a missed quality and consistency win.
For Pith Voice, the design-system skill is already known to exist and
is mandatory; the design-review and code-testing skill domains are the
two further areas where a skill is likely to exist and would lift
output quality.

**Procedure.**

1. List every skill directory available on the host:
   - Built-in / public skills at `/mnt/skills/public/` and
     `/mnt/skills/examples/`.
   - User-installed skills at `~/.claude/skills/` (mandatory check
     per `PROJECT_OPERATIONS.md` §3 and `DESIGN_SYSTEM_GUIDE.md`).
   - Repository-local skills at `.claude/skills/` (if any).
2. For each directory, read its `SKILL.md` (or equivalent index file)
   end-to-end. Note: what task each skill handles, what inputs it
   expects, what artifacts it produces.
3. Match every available skill to one or more phases below. Record
   the mapping in `docs/CHANGELOG-internal.md` (gitignored) under a
   `## Phase 0 — Skill audit` heading. Format: one line per skill
   listing its name, location, phases it will be used in, and a
   one-sentence note on why.
4. If a phase task matches a skill's domain, **the skill MUST be
   used** for that task. Improvising an equivalent from scratch is
   forbidden. If two skills overlap, prefer the more specific one
   and note the choice.

**Specific skill domains to check (these MUST be audited explicitly).**
For each, locate the matching skill if present and bind it to the
listed phase. If absent, fall back to the manual procedure noted.

| Domain | Where it likely lives | Bound to | Fallback if absent |
|---|---|---|---|
| Design system generation | `~/.claude/skills/design-system/` (global, per `DESIGN_SYSTEM_GUIDE.md`) | Phase 1, step 8 | None — this skill is mandatory; do not proceed without it. |
| Design review / Vector compliance | candidate names: `design-review`, `vector-check`, `compliance-check` | Phase 1, step 9; revisited at end of every UI-touching phase | Manual 6-step Vector compliance check from `DESIGN_SYSTEM_GUIDE.md`. |
| Code testing (XCTest, Swift Testing, XCUITest) | candidate names: `swift-test`, `xctest`, `test-scaffold`, `ios-testing` | Every phase from Phase 2 onward where new code is written | Manual test authoring per `Acceptance criteria → Functional`. |
| Xcode / SwiftPM scaffolding | candidate names: `xcodegen`, `ios-scaffold`, `swift-package` | Phase 1, steps 1–3 | Manual project creation in Xcode UI on Mac Mini. |
| App Store metadata / ASO | candidate names: `app-store`, `aso`, `fastlane-metadata` | Phase 8 | Manual paste-through of the content already prepared in §App Store readiness. |
| iOS Privacy Manifest | candidate names: `privacy-manifest`, `ios-privacy` | Phase 8 | Manual authoring per Apple's `PrivacyInfo.xcprivacy` schema. |

**Output of Phase 0.**

- `docs/CHANGELOG-internal.md` updated with a `## Phase 0 — Skill audit`
  block listing every skill found, where it lives, what it does, and
  which phase(s) will use it.
- A short top-level statement: *"Skills audit complete. The following
  skills will be used: …"* — readable in 30 seconds.
- Confirmation from the operator (the human) before Phase 1 begins.
  If the audit revealed a skill that materially changes the plan
  (e.g. a test-scaffolding skill that means tests get written
  alongside every FR), surface this so it can be reflected in the
  phase plans below before code starts.

Phase 0 takes approximately 10–20 minutes of reading. It is not a
ceremony — its job is to prevent half a day of wasted reimplementation
in Phases 2–7.

### Phase 1 — Project skeleton + DesignSystem module

**First code-producing phase** per `PROJECT_INSTRUCTIONS.md`. Runs only
after Phase 0 (Skill audit) is complete and the audit notes are in
`docs/CHANGELOG-internal.md`.

1. Create Xcode workspace `PithVoice.xcworkspace` with `Pith Voice` app target.
2. Configure Info.plist: bundle ID `com.hadger.pith`, iOS 26 min,
   iPhone-only, portrait-only.
3. Set up `Configuration.storekit` with the three products.
4. Create `Secrets.example.xcconfig`; gitignore the real one.
5. Create `docs/` GitHub Pages directory with placeholder Privacy /
   Terms / Support pages (final copy in Phase 7).
6. Add `Hadger_LOGO_APPICON_1024.png` from the brand pack as the
   AppIcon source (single-size Xcode 14+ behaviour — Xcode generates
   all variants). **Note:** if a Pith Voice-specific app icon is decided
   in Phase 1 instead of using the Hadger mark, swap here. Brand
   constraint says Pith Voice should have its own mark, so the Hadger mark
   is a Phase-1 placeholder.
7. Copy favicon set from the brand pack into `docs/`.
8. **Run `/design-system`** in Claude Code (on Mac Mini). Skill reads
   the `## Design vector` section, runs its 5 steps, generates
   `PithVoice/DesignSystem/`, and appends a `## Design system` section
   below this point in this SPEC.md file.
9. **Run Vector compliance check** (`DESIGN_SYSTEM_GUIDE.md`).
   - If failure on any of the 6 checks: refine `## Design vector`
     above, re-run `/design-system`. Do NOT hand-edit
     `PithVoice/DesignSystem/`.
10. Build green, app launches to a Cream placeholder Today screen
    using DesignSystem tokens.

### Phase 2 — Capture + on-device transcription

1. Implement `Capture/Recorder.swift` (FR-1, FR-3, FR-4, FR-5).
2. Implement `Capture/Transcriber.swift` wrapping `SpeechAnalyzer`
    (FR-2, FR-6).
3. Implement `Capture/WaveformView.swift` (FR-1).
4. Hook recording into Today screen Record button. Live transcript
    visible during recording.
5. End-state: app records, transcribes, displays final transcript.
   No summary yet, no persistence yet.

### Phase 3 — Intelligence (Foundation Models)

1. Implement `Intelligence/EntryDistillation.swift` (`@Generable`).
2. Implement `Intelligence/Distiller.swift` invoking the model
   (FR-7, FR-8, FR-9, FR-10, FR-11).
3. End-state: a finalised transcript yields a summary + tags on the
   same session. "Drawing the pith…" state visible during the
   ~6 s wait.

### Phase 4 — Storage + Today screen

1. Implement `Storage/Entry.swift` SwiftData model (FR-12, FR-13).
2. Implement `Storage/EntryRepository.swift`.
3. Implement Today screen `TodayView.swift` + `EntryCardView.swift`
   (FR-17, FR-18).
4. Implement entry detail (`EntryDetail/EntryDetailView.swift`)
   with edit + delete (FR-10, FR-14).
5. Implement search (FR-20).
6. End-state: full CRUD on entries, persisted, visible chronologically.

### Phase 5 — Threads + Read me back

1. Implement `Intelligence/ThemeClusterer.swift` for theme detection
   (FR-21).
2. Implement `Threads/ThreadsView.swift` (FR-22, FR-23).
3. Implement `Today/ReadMeBackView.swift` (FR-19, FR-25, FR-26, FR-27).
4. Wire up local notification scheduling for weekly digest (FR-5 in
   flow 5; opt-in scheduled via `UNUserNotificationCenter`).
5. End-state: returning user experience is complete.

### Phase 6 — Paywall + StoreKit 2

1. Implement `Paywall/ProductCatalog.swift` loading the three
   products from `Configuration.storekit` (or App Store Connect
   when running on TestFlight).
2. Implement `Paywall/PaywallView.swift` with the 3-product layout
   per Monetization → Paywall section.
3. Implement `Paywall/PaywallController.swift` enforcing FR-31, FR-32.
4. Implement `Storage/EntitlementStore.swift` (Keychain-backed) for
   FR-33, FR-34.
5. End-state: a user can purchase, restore, and be guarded by the
   N=2 entry counter; data survives reinstall via Keychain flag.

### Phase 7 — Onboarding + Settings + Export + App Intents

1. Implement `Onboarding/OnboardingFlow.swift` (FR-28, FR-29).
2. Implement `Settings/SettingsView.swift` (FR-30).
3. Implement `Export/Exporter.swift` (FR-15).
4. Implement `AppIntentsKit/StartRecordingIntent.swift` (Flow 9).
5. End-state: every shipping FR is implemented.

### Phase 8 — App Store readiness

1. Write final Privacy Policy, Terms, Support pages in `docs/` per
   the relevant standards (in English). Use the URLs and email from
   `PROJECT_OPERATIONS.md`.
2. Generate App Store screenshots (5 per device size: 6.9" + 6.1")
   matching the creative brief in App Store readiness above. Use
   `/design-system` skill's `preview.html` as the visual reference.
3. Populate App Store Connect listing: title, subtitle, keywords,
   description, app review notes, URLs.
4. Privacy Manifest (`PrivacyInfo.xcprivacy`) — declare no tracking,
   no data categories.
5. Pre-flight `Acceptance criteria` checklist — every box ticked.
6. Submit to TestFlight via `fastlane beta`. Self-test on owner's
   personal iPhone for 7 days.
7. Submit for App Store review via `fastlane release`.

### Future (post-launch)

- v1.1.1 — DE/FR/ES localisation (NFR-6 unlock).
- v1.1.2 — A/B paywall (N=2 vs N=3, annual-first vs lifetime-first)
  via App Store Connect Experiments.
- v1.1.3 — Optional opt-in iCloud sync with E2EE, if cross-device
  retention analysis demonstrates need.
- v1.1.4 — Long-arc Threads ("This year") with nightly recompute on
  charge (FR-24).
- v1.1.5 — Widget for Today screen (Today entry preview, Lock Screen
  small-size widget).

---

## Open questions

Resolved-with-recommendation items from the brief that the founder
must confirm before TestFlight. Each has a working default in the SPEC
above — flagging here so the assumption can be revisited.

1. ✅ **RESOLVED 2026-05-19** — Hadger conventions: "no AI features"
   amendment. Owner approved amendment: cloud AI forbidden, on-device
   AI via Apple frameworks (`FoundationModels`, `SpeechAnalyzer`,
   Vision, Natural Language) permitted. Studio conventions file
   `~/.claude/skills/apple-app-team/references/hadger_conventions.md`
   line 155 updated in the same change. Pith Voice cleared to proceed.

2. **App icon: Hadger mark placeholder vs Pith Voice-specific mark.** Brand
   constraints in Design vector explicitly say "App icon is a
   Pith Voice-specific mark designed in Phase 1, NOT the Hadger Ember mark."
   But the brand pack ships the Hadger mark as a ready-to-go AppIcon.
   **Recommendation:** ship the Hadger mark as Phase-1 placeholder
   (to unblock TestFlight); commission/design a Pith Voice-specific mark in
   Phase 8 before App Store submission. **Owner confirmation on the
   Pith Voice mark direction.**

3. **iCloud Sync forever-or-never.** Brief §10 Q3 leaves this open
   for v1.1. SPEC bakes in "single-device forever" as a brand stance
   (non-goal). **Owner confirmation:** is this a permanent stance or
   a v1.1 product decision to revisit?

4. **"Read me back" defensibility.** Brief §10 Q4 — is the
   own-voice playback worth a design-patent filing? **Recommendation:**
   not in v1. Defer. Cost vs marginal defensibility benefit
   unattractive for a one-person studio.

5. **Reddit verbatim harvest.** Brief §10 Q7 — marketing did not
   pull verbatim quotes from r/Journaling, r/privacy, r/ADHD.
   **Recommendation:** ground 2 personas in this SPEC's Validation
   log with direct Reddit voices before TestFlight to harden the
   onboarding copy. Specifically — anchor Mike (ADHD) and James
   (privacy hawk).

6. **Trademark verification.** Brief §10 Q10 — USPTO TESS direct
   search and a 1-minute in-store iPhone search required pre-launch.
   **Recommendation:** schedule a trademark attorney pass after Phase
   6 (when product is stable enough to commit to the name "Pith Voice")
   and before Phase 8 (App Store submission). Budget: ~$300–500 for
   a trademark attorney pass. **Owner confirmation.**

7. ✅ **RESOLVED 2026-05-19** — Subscription group on App Store Connect.
   v1.2 confirms canonical IDs: products are `com.hadger.pith.sub.weekly`,
   `com.hadger.pith.sub.annual`, `com.hadger.pith.iap.lifetime`;
   subscription group is `pith.main`. ASC App record `6770544476`
   already exists under bundle ID `com.hadger.pith`; products and
   group will be created via ASC UI in Phase 9 (UI-only — Apple's API
   does not permit `POST /v1/subscriptions` from new accounts on a
   first submission).

8. **Foundation Models device-availability runtime check.** The
   `SystemLanguageModel.default.availability` API can return
   `.unavailable` for various reasons (Apple Intelligence disabled
   in Settings, downloading, region restriction). SPEC's FR-11
   handles model failure on a per-call basis, but the app's
   first-launch landing experience for an iPhone 15 Pro user with
   Apple Intelligence disabled needs explicit copy.
   **Recommendation:** Phase 7 adds an "Apple Intelligence not
   active" landing screen with a deep link to iOS Settings → Apple
   Intelligence.

9. **Apple Review framework-name claim risk.** Brief §10 Q6.
   Marketing claims "Apple Intelligence" and "Foundation Models" in
   the description copy. Apple sometimes rejects apps using its
   trademarks in marketing — though the App Store guidelines
   explicitly permit naming frameworks accurately when describing
   functionality. **Recommendation:** keep the framework names in the
   description as written (precedent: Stoic does the same in its
   App Store listing). If rejected, fallback copy: "Apple's on-device
   AI." Pre-pasted App Review notes (above) include the framework
   names to give the reviewer the right mental model.

10. **Validation log: 8th persona "Devon" (creative ideas use case)
    is not in marketing brief.** Added during analyst-pass validation.
    **Owner confirmation:** is the creative-ideas-on-the-go use case
    worth ASO investment (additional keywords, screenshot variation),
    or is the journaling-only positioning sharper? SPEC defaults to
    journaling-only positioning with creative-ideas as keyword
    spillover.

11. ✅ **RESOLVED 2026-05-19** — App Store name re-verification for
    "Pith Voice". Owner verified via direct App Store Connect action:
    App record successfully created under the display name "Pith Voice"
    (ASC App ID `6770544476`, SKU `pith-ios-1`, bound to bundle ID
    `com.hadger.pith`). Apple's name-uniqueness gate is the
    authoritative check; passing it confirms no live App Store app
    holds the exact name "Pith Voice." USPTO TESS pass and trademark
    attorney review (Q6) remain optional pre-submission diligence —
    not blockers since Apple did not flag the name. Fallback names
    (Pith Voice Journal, Pith — Voice Journal, Mull, Linger) retained
    in this SPEC only as contingency if a trademark dispute emerges
    later.

---

## Implementation rules for Claude Code

The following hard rules apply across the entire codebase. The
`/design-system` skill will, in Phase 1, append a more detailed
*"Implementation rules for Claude Code"* block to the `## Design
system` section it generates. Both sets of rules apply together.

0. **Skill audit before anything.** Before any tool call that touches
   a file in this repository — before reading SPEC.md a second time,
   before opening Xcode, before generating any code — Claude Code
   completes **Phase 0 (Skill audit)** as defined in the
   Implementation phases section. The audit lists every skill at
   `~/.claude/skills/`, `/mnt/skills/public/`, and `.claude/skills/`
   (if present), reads each `SKILL.md`, and binds skills to phases.
   No phase begins until this audit is on paper in
   `docs/CHANGELOG-internal.md`. **If a skill exists for a task, the
   skill is used.** Improvising an equivalent from scratch is a defect.
1. **Read this file end to end** before generating any code in this
   repository. When asked to implement a feature, find its FR-N in
   this file and treat that ID as the authoritative spec. If a
   request appears to conflict with this file, stop and ask — do
   not silently override the SPEC.
2. **Phases are sequential**, not optional. Do not start Phase 2
   work before Phase 1's DesignSystem module is in place and the
   Vector compliance check passes. Do not skip to a later phase
   without finishing the earlier one.
3. **No hard-coded design values** anywhere outside `PithVoice/DesignSystem/`.
   No literal hex colours. No raw `.padding(8)`. No
   `.font(.system(size: 17))`. Always use tokens from `DesignSystem`.
4. **No third-party dependencies** beyond what `SPEC.md` allows.
   The dependency graph must contain zero analytics SDKs. SwiftLint
   rule enforces this; the lint must run in CI before merge.
5. **No network code** outside what `StoreKit` does internally. No
   `URLSession.shared.dataTask` anywhere in the app code.
6. **Privacy first.** Every new file containing user data uses
   `NSFileProtectionComplete`. Every new SwiftData model is reviewed
   for protection class.
7. **Tests first or alongside.** Do not commit a new FR without an
   acceptance-shaped test. Coverage threshold per `Acceptance
   criteria → Functional`. If a testing skill was discovered in Phase
   0, use it to scaffold and run tests — do not write test boilerplate
   by hand when the skill handles it.
8. **Atomic commits.** One FR (or sub-task within an FR) per commit.
   Imperative present-tense messages, no emoji, no AI signatures.
9. **Build with zero warnings**, always. A warning is a defect.
10. **Build and test after every meaningful change.** Do not bundle
    multiple unverified changes into one batch.
11. **Re-check skill bindings at each phase boundary.** At the start
    of every new phase, re-read the Phase 0 skill-audit notes in
    `docs/CHANGELOG-internal.md` and confirm the skills bound to that
    phase are still appropriate. If a UI-touching phase begins, the
    design-review skill (if discovered) runs on the phase's output
    before the phase is considered done.
