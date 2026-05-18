# Pith Voice — Design system context

Generated 2026-05-19 from SPEC v1.2 § Design vector.

## Topic / niche
On-device voice journal for iPhone. User taps to record (2–8 min entries),
Apple's SpeechAnalyzer transcribes locally, FoundationModels produces a short
summary and 2–4 thematic tags. Threads view surfaces recurring subjects of
thought across a week. Everything stays on device — no servers, no analytics,
no cloud AI. Bundle ID `com.hadger.pith`, App Store name "Pith Voice".

## Platform
iOS native, iPhone-only, iOS 26+, SwiftUI, portrait-only, light-mode primary
(dark mode as first-class citizen — not inverted).

## Register
Primary: **warm-minimal editorial** — a reading-room voice. Like a New Yorker
column or a Substack Sunday morning read.

Secondary: **considered / restrained / adult** — there is care in the layout;
there is not enthusiasm.

## Anti-registers (MUST NOT feel like)
- **Cold medical blues** — `#3B82F6 / #2563EB / #1D4ED8` family. Reads as
  "clinic" to therapy-going Sarah segment.
- **AI-startup neon** — purple-to-pink gradients, shimmering "✨ AI ✨" sparkle
  motifs, oversaturated accents. The AI here is Apple's; we don't perform it.
- **Pastel-lifestyle** — Pinterest aesthetic, Calm-app blue-purple background,
  millennial-coral / sage-mint. Reads as "lifestyle brand for someone else."
- **Productivity-mode** — dark-by-default, Linear-grade monochrome density,
  info-rich dashboards. Pith Voice is not a tool.
- **Gamification** — streak counters, badges, heat-maps, progress bars,
  trophies, celebratory confetti animations. Punishes the returning-after-gap
  user that Read me back exists to undo.
- **Sans-serif everywhere** — reads SaaS-cold. The journal layer needs at
  least one serif surface to land as a reading place.
- **AI sparkle iconography** — ✨, gradient orbs, animated Siri shimmer.
  Counterproductive when user's reason-to-install is mistrust of cloud AI.
- **Onboarding cartoon illustrations** — Calm and Headspace own that
  language; we are not them.

## Reference register (apps to learn from, not copy whole)
- **NYT Cooking** — warm editorial palette (cream / sand / rust-accent),
  serif headlines, generous whitespace. Take: palette temperature and
  unhurried reading-room feel.
- **Stripe Press / Stripe Atlas onboarding** — typographic restraint,
  monochrome + one muted accent, trust signals that whisper. Take:
  typographic confidence.
- **Substack reader** — generous whitespace, reading-first, serif body type.
  Take: reading-place framing.
- **Day One Journal** — journal-as-archive metaphor, calendar-driven entry
  list. Take: journal-as-place feel. Don't take: cluttered toolbars.
- **Things 3** — quiet UI density, restrained motion. Take:
  one-thing-at-a-time pacing. Don't take: productivity coldness.

## Brand-locked constraints
- **Hadger Ember `#A8481C`** — studio mark only, never recoloured. Used
  exclusively in `AboutView.swift` and `HadgerMark.swift` as inline literal
  with the comment `// Hadger brand color, AboutView-only`. Never added to
  `DesignSystem/Colors.swift`. Pith Voice's own accent MUST be outside the
  `#A8481C ± 30°` hue range (no near-orange, near-rust, near-coral primary).

## Primary persona (for Step 7 validation)
**Sarah, 32, marketing/design IC, Brooklyn.** Weekly therapy. Reads NYT
Cooking on Sundays. Subscribes to a few Substacks. Already journals in a
Moleskine but inconsistent. Pays for Substack Premium ($8/mo). Won't pay
$60/year for a wellness app that "feels like Calm for younger people"; will
pay for something that reads as adult and considered.

Will reject:
- Anything that reads "clinical" or "wellness scam".
- Sans-serif-everywhere SaaS look.
- AI sparkle iconography.
- Anything pastel.

Will accept (and pay for):
- Editorial reading-room palette.
- Serif headlines + sans-serif body.
- One muted accent, used sparingly.
- Subtle, unbouncy motion.

## Secondary personas (cross-check after primary)
- **James, 35, journalist, UK, privacy-hawk** — also editorial-leaning.
  Same visual reaction as Sarah.
- **Olivia, 41, psychotherapist, AU** — uses for personal reflection; will
  uninstall if visual reads as "AI therapist".
- **Carla, 45, perimenopause, US** — mindfulness-curious; will close if
  pastel Calm-for-young-people look.

These three converge on the same visual register as Sarah, so a passing
Sarah test largely satisfies them too.
