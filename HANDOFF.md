# Pith Voice — session handoff

> **Status as of 2026-05-19 night:** **Phases 0–8 complete.** Code green
> on iPhone 17 Pro simulator: build clean, 37 unit + UI tests passing,
> SwiftLint --strict zero violations, SwiftFormat --lint zero violations.
> docs/ live, fastlane configured, 10 placeholder screenshots rendered.
> Only Phase 9 remains — Apple-gated UI work in App Store Connect.

---

## TL;DR

Pith Voice v1.2 is built from scratch against SPEC v1.3. The previous
`1_Pith_old/` attempt is kept as reference only (not migrated). App Store
name "Pith Voice"; infrastructure layer (bundle ID `com.hadger.pith`,
repo `hadgerapps/pith`, GitHub Pages `hadgerapps.github.io/pith/`,
product IDs `com.hadger.pith.sub.*` + `.iap.lifetime`) all stays on the
legacy `pith` stem because the ASC App record `6770544476` is already
bound to that bundle ID.

---

## Identity & paths

| Thing | Value |
|---|---|
| Working dir | `/Users/vassiliyshmigirivov/Apple_apps/1_Pith` |
| Reference dir (old, bug-ridden) | `/Users/vassiliyshmigirivov/Apple_apps/1_Pith_old/` |
| Studio brand | Hadger (ИП ШМИГИРИЛОВ, KZ) |
| Apple Team ID | `X243T6N439` |
| App Store display name | **Pith Voice** |
| Bundle ID | `com.hadger.pith` (Apple-bound, Developer Portal id `Z84G867MYW`, IAP capability) |
| App Store Connect App ID | `6770544476` |
| SKU | `pith-ios-1` |
| Subscription products | `com.hadger.pith.sub.weekly` `$4.99` / `.sub.annual` `$59.99` / `.iap.lifetime` `$99.99` |
| Subscription group | `pith.main` |
| GitHub repo | `hadgerapps/pith` |
| Public pages | `https://hadgerapps.github.io/pith/` (`/`, `/privacy/`, `/terms/`, `/support/`) |
| Studio ASC API key | `9P9W84M53Z` / Issuer `3030c9a1-732a-427c-a680-1de04cd5005d` |
| `.p8` location | `/Users/vassiliyshmigirivov/Apple_apps/AuthKey_9P9W84M53Z.p8` |

Studio account state (inherited from SoftDay): W-8BEN signed,
Paid Apps Agreement active, USD-capable banking configured. No
first-app friction for Pith Voice.

---

## Phases — final status

| # | Phase | Status | Commit |
|---|---|---|---|
| 0 | Skill audit + hygiene | ✅ | `b55a534` |
| 1 | Project skeleton + DesignSystem (via /design-system) | ✅ | `43dc02d` + `b4bc31e` + `93719f6` |
| 2 | Capture (Recorder + Transcriber + WaveformView) | ✅ | `cdecbb8` |
| 3 | Intelligence (FoundationModels @Generable) | ✅ | `6ddd3a5` |
| 4 | Storage + Today + EntryDetail + Search | ✅ | `431dd11` |
| 5 | Threads + Read me back + Weekly digest | ✅ | `a5bb4a3` |
| 6 | Paywall + StoreKit 2 + Keychain entitlement | ✅ | `94781fb` |
| 7 | Onboarding + Settings + Export + AppIntents | ✅ | `05799d1` |
| 7b/7c | Privacy Manifest + AboutView + HadgerMark | ✅ | included in `05799d1` |
| 8 | fastlane + docs/ + screenshots + ASC metadata | ✅ | pending commit |
| 9 | TestFlight + ASC product config + Submit | ⏳ USER TOUCHPOINT | — |

Quality gates at every phase boundary:

- `xcodebuild build`: **SUCCEEDED**, 0 warnings
- Tests: **37 / 37 passed** (7 suites: Phase 1 smoke + Capture +
  Intelligence + Storage + Threads + Paywall + Exporter)
- `swiftlint --strict`: **0 violations**
- `swiftformat --lint`: **0 violations** (48 files)

---

## What's ready for Phase 9 (the human handoff)

### Local artifacts

- **Source code**: 38 Swift files under `PithVoice/` + 12 colorsets +
  AppIcon 1024 placeholder + PrivacyInfo.xcprivacy.
- **fastlane**: `Fastfile` with 3 lanes (`beta` / `metadata` / `release`).
  `Appfile` configured. `metadata/en-US/` populated (name, subtitle,
  keywords, description, promotional_text, marketing_url, support_url,
  privacy_url, release_notes). `metadata/review_information/` has notes,
  contact info. `metadata/copyright.txt`, `primary_category.txt`
  (LIFESTYLE), `secondary_category.txt` (PRODUCTIVITY).
- **Screenshots**: 10 placeholder PNGs at 1320×2868 and 1206×2622
  (`fastlane/screenshots/en-US/iPhone 17 Pro Max-*` + `iPhone 17 Pro-*`).
  These render the SPEC § Screenshots creative brief (Hook / Value /
  Trust / Threads / Read me back) on Cream background with serif
  headlines. **They are placeholders.** Before Phase 9 submit, replace
  with screenshots from the actual running app via `fastlane snapshot` —
  see "Real screenshots" below.
- **docs/**: 4 HTML pages (`index.html`, `privacy/index.html`,
  `terms/index.html`, `support/index.html`) — editorial cream+serif,
  legally compliant, ready to push to `hadgerapps/pith` GitHub Pages.

### Owner-only actions to do (Phase 9)

In order:

1. **Push code to GitHub.**
   ```bash
   cd /Users/vassiliyshmigirivov/Apple_apps/1_Pith
   git remote add origin git@github.com:hadgerapps/pith.git
   git push -u origin main   # may need --force if old branch lives there
   ```
   GitHub Pages should pick up `docs/` automatically. Verify 4 URLs
   return HTTP 200 before continuing.

2. **Replace placeholder screenshots with real ones.**
   ```bash
   # Option A — manual: install on iPhone 17 Pro / Pro Max simulator,
   # seed 5 entries, screenshot each surface, save to
   # fastlane/screenshots/en-US/ with the existing naming.
   #
   # Option B — fastlane snapshot: requires `Snapfile` + a UI-test
   # target that drives the 5 surfaces. Not yet wired; ~1 hour to add.
   ```

3. **ASC subscription products** (UI-only — Apple's API forbids
   `POST /v1/subscriptions` from first submissions).
   Open ASC → My Apps → Pith Voice → Monetization → Subscriptions:
   - Create subscription group `pith.main`.
   - Add `com.hadger.pith.sub.weekly` ($4.99 / weekly).
   - Add `com.hadger.pith.sub.annual` ($59.99 / annual).
   - Add 7-day Free Trial introductory offer on **both** subs.
   - In Monetization → In-App Purchases → add lifetime
     `com.hadger.pith.iap.lifetime` ($99.99, non-consumable).
   - For each subscription: add en-US localization (display name +
     description), set base price, let it propagate to all 175
     territories.

4. **Intro offers in 175 territories.** Once the products exist,
   call:
   ```bash
   python3 ~/.claude/skills/apple-app-team/scripts/create_intro_offers.py \
     --product com.hadger.pith.sub.weekly \
     --product com.hadger.pith.sub.annual \
     --duration P1W --type FREE_TRIAL
   ```
   (Per SoftDay learnings: per-territory POST — no bulk shortcut.)

5. **Upload paywall review screenshot.** Capture PaywallView on
   iPhone 17 Pro Max simulator (1320×2868 PNG), then:
   ```bash
   bash ~/.claude/skills/apple-app-team/scripts/upload_screenshot.sh \
     subscriptionAppStoreReviewScreenshots \
     ./fastlane/screenshots/en-US/iPhone\ 17\ Pro\ Max-03_Trust.png
   ```

6. **Push code + metadata to TestFlight.**
   ```bash
   cd /Users/vassiliyshmigirivov/Apple_apps/1_Pith
   fastlane beta     # uploads IPA, increments build number
   fastlane metadata # uploads name/subtitle/keywords/description + screenshots
   ```

7. **App Privacy + Age Rating in ASC UI.**
   - App Privacy → "Data Not Collected" across all 32 categories.
     Tap **Publish** (separate button — required step).
   - Age Rating → 12+ via the 7-step questionnaire.

8. **Probe submission blockers.**
   ```bash
   bash ~/.claude/skills/apple-app-team/scripts/probe_blockers.sh
   ```
   Iterate on whatever surfaces (likely just App Privacy / Age Rating).

9. **Submit for review.** Either `fastlane release` or click
   "Add for Review → Submit to App Review" in ASC.

10. **Wait 12–48h.** Apple's first-submission probe email may arrive
    (Guideline 2.1(b) — 5-question business model check). Reply in
    Resolution Center.

11. **Approve + release.** State `PENDING_DEVELOPER_RELEASE` → click
    "Release This Version" in ASC. Live within ~1 hour.

### What's intentionally not yet done

- **Real screenshots from running app.** Placeholders are in place;
  fastlane snapshot setup (Snapfile + UI-test seeded with 5 demo
  entries) is a 1-hour add for the next session — or do manually.
- **Pith Voice-specific app icon.** Phase 1 ships the Hadger mark as
  placeholder per OQ #2 default. Final Pith Voice icon (serif "P."
  on Cream per the SPEC's editorial register) should be designed
  before submission — `scripts/make_app_icon.py` not yet written.
- **Trademark attorney pass** (OQ #6, ~$300–500). Optional pre-launch
  diligence.

---

## Open questions — final status

| OQ | Status |
|---|---|
| #1 — Hadger AI policy | ✅ Resolved 2026-05-19 |
| #2 — Pith Voice app icon | ⏳ Hadger placeholder ships; final to design pre-submit |
| #3 — iCloud Sync | ⏳ v1 stance: single-device forever |
| #4 — Read me back patent | ⏳ Defer beyond v1 |
| #5 — Reddit verbatim harvest | ⏳ Optional pre-TestFlight |
| #6 — Trademark attorney | ⏳ ~$300–500, optional |
| #7 — Subscription IDs | ✅ Canonical `com.hadger.pith.*` |
| #8 — FoundationModels availability landing | ⏳ Phase 7 (basic surfaces in via Distiller.isAvailable; landing screen not yet) |
| #9 — Framework names in description | ✅ Kept as-is, Stoic precedent |
| #10 — Devon persona | ⏳ Defaults to journaling-only positioning |
| #11 — "Pith Voice" name | ✅ Resolved — ASC accepted |

---

## Useful snippets

### Quick state check

```bash
cd /Users/vassiliyshmigirivov/Apple_apps/1_Pith
PATH="$PWD/.tooling/bin:$PATH" xcodegen generate
xcodebuild -project PithVoice.xcodeproj -scheme PithVoice \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild -project PithVoice.xcodeproj -scheme PithVoice \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
./.tooling/bin/swiftlint --config .swiftlint.yml --strict
./.tooling/bin/swiftformat --lint --config .swiftformat \
  PithVoice PithVoiceTests PithVoiceUITests
```

### ASC API token (10-min lifetime)

```bash
TOKEN=$(ruby /Users/vassiliyshmigirivov/.claude/skills/apple-app-team/scripts/asc_jwt.rb \
  /Users/vassiliyshmigirivov/Apple_apps/AuthKey_9P9W84M53Z.p8 \
  9P9W84M53Z 3030c9a1-732a-427c-a680-1de04cd5005d)
```

### ASC App record check

```bash
curl -sS -H "Authorization: Bearer $TOKEN" \
  "https://api.appstoreconnect.apple.com/v1/apps/6770544476" \
  | jq '.data.attributes | {name, bundleId, sku, primaryLocale}'
```

### Render placeholder screenshots

```bash
python3 scripts/make_screenshots.py
```

---

## Recent commits

```
(latest)  feat(phase-8): fastlane + docs/ + ASC metadata + placeholder screenshots
05799d1   feat(phase-7): Onboarding + Settings + Export + AppIntents + AboutView + PrivacyInfo (FR-15, FR-28..FR-30, Flow 9)
94781fb   feat(phase-6): Paywall + StoreKit 2 + Keychain entitlement (FR-31..FR-34)
a5bb4a3   feat(phase-5): Threads + Read me back + Weekly digest (FR-19, FR-21..FR-27)
431dd11   feat(phase-4): SwiftData storage + Today screen + EntryDetail + Search (FR-10, FR-12..FR-20)
6ddd3a5   feat(phase-3): Intelligence layer via FoundationModels (FR-7..FR-11)
cdecbb8   feat(phase-2): on-device capture pipeline (FR-1..FR-6)
93719f6   docs(spec): integrate /design-system report into SPEC v1.3
b4bc31e   feat(phase-1): complete DesignSystem + wire RootView, all gates green
43dc02d   feat(phase-1): scaffold PithVoice Xcode project + tests
b55a534   chore(phase-0): SPEC v1.2, skill audit, hygiene, vendored swiftlint/swiftformat
```
