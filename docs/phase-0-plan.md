# Phase 0 — Plan

Status: **approved with the decisions below (2026-11-10).**

## Decisions (answers to the questions in §11)

| # | Decision |
|---|---|
| Q1 | Drop `geoflutterfire_plus`. All geo queries (companions and venues) run in Cloud Functions with `geofire-common`. |
| Q2 | Matching rules in §3 approved as written. |
| Q4 | Extra packages in §5.2 approved. |
| Q5 | Signup bonus 20 credits (once). Start chat 1. Book spot 5. Instant request 5. **No credits are ever refunded** (owner decision, Phase 4): not on decline, not on cancel. Plans: Free (signup bonus only), Plus 100 credits/month, Premium 200 credits/month. No swipes, likes, boosts or fee discounts. Top-up packs: 10 / 30 / 75 credits. Prices come from the stores. |
| Q5 / Q8 / Q9 (Phase 4) | The seeker picks venue and time slot before sending any request, instant ones included. Requests **never expire**: a companion can accept any time before the slot starts; after that the request shows "Time passed" (status stays `requested`, no new status). The seeker can cancel while requested or accepted and before the start: the table is released, credits are not refunded. |
| Q6 | Build minimal extra screens (tab lists, profile and companion editors, trusted contact, venue sign-up, rating, saved list) in the design system, each in the phase it belongs to. |
| Q11 | Hard limits written as literals in security rules are OK, each with a comment naming its AppConfig key. |
| Q12 | App name: **VYBE**. Launch city: **Mumbai** (seed data around Bandra / Khar / Santacruz). Bundle id: **com.vybe.app** on both platforms. |
| Q13 | Screenshots received. Wording conflicts resolved with safe copy: "Coffee meetup" (not "Coffee date"), "Book a coffee meetup", "Pick a day", "Only used to decide who sees you", "Unlock chats and bookings". The chat booking card shows a credit cost, not Rs. |
| Phase 1 | Riverpod pinned to **3.0.3** (with codegen): newer Riverpod generators need Dart 3.12, and this machine has Flutter 3.38.3 / Dart 3.10. Upgrade Flutter later to move up. Small accent text on the page background uses `accentText` (`#C82D59`), because `#D1325E` on `#FBF5F1` is 4.49:1, just under 4.5. Distances shown to other users are rounded to the **nearest** km, minimum "About 1 km". Credit ledger gains the reason `signup_bonus` (20 credits at signup). |
| Phase 2 | Onboarding order follows the screenshots: rules (1), then verification (2: phone OTP, selfie, ID), then preferences (3). Consent is carried on the device until the phone is verified, then recorded on the server with the rules version. The 20 signup credits are granted when the account is created (`acceptRules`). Verification step statuses are `not_started`, `in_review`, `approved`, `rejected`. Under 18 (from the ID's date of birth) is a permanent rejection. Gender locks once verified. Age slider range 18 to 60 (`ageMaximum` = 60). The app always calls the real verification Functions; the server decides whether the fake or a real provider is used. |
| Phase 3 | Seekers get a bottom bar: Discover, Chats, Bookings, Profile. "N spots nearby" on a card = verified venues with an open slot today that are within 5 km of **both** the seeker and that companion (replaces assumption 5). "Free right now": Next 2 hrs = companion switched on "I am free now"; Tonight = today's weekly hours from 18:00 (`tonightStartHour`); Tomorrow = tomorrow's weekly hours. First name is entered on the Profile tab (Discover shows a reminder until it is set). Buttons that belong to later phases are visible but disabled: Map and Book your spot / Pick spot (Phase 4), Message and Chat (Phase 5), credits pill tap (Phase 6). Riverpod's automatic retry is off; every error screen has "Try again". Location updates that imply travel faster than `maxPlausibleSpeedKmh` (300) are rejected. Emulator builds use a fixed Bandra location unless run with `--dart-define=USE_DEVICE_LOCATION=true`. |
| Phase 6 | Credits screen = screen 11 with credits-only wording (no swipes, likes, boosts or booking-fee discounts). Prices come from the stores. Credits are added only by the server after the store confirms the payment, **once per store transaction**; a receipt used by one account can never credit another. **Unused plan credits are kept** (they never expire). **Upgrading** (Plus → Premium) grants the new plan's credits **straight away**; **downgrading** starts at the next renewal. Each renewal grants that month's credits (the `renewSubscriptions` job re-checks plans with the store hourly); a plan that is not renewed goes back to Free and the credits stay. **A store refund takes back the credits it gave, never below 0**, and a refunded plan ends at once. A pending payment (e.g. slow UPI) adds nothing until it clears. "Not enough credits" messages get a **Get credits** button. No credit history screen (not requested). |
| Backend (Phase 6, move) | **Moved from Firebase to Supabase** (owner decision, 2026-11-13: Firebase Blaze billing could not be set up). Firestore collections became Postgres tables (`supabase/migrations`), security rules became row-level security, Cloud Functions became one Edge Function `api` (same TypeScript logic, `server/`), Storage paths kept as `<bucket>/<object>`, Remote Config became the `app_config` table, the companion index is kept by database triggers, the emulator is replaced by a test Supabase project plus local Postgres tests. Firebase remains only for Crashlytics. Older rows below still name Firestore paths; the matching tables are in the migration. Setup: `docs/supabase-setup.md`. |
| Login (Phase 6, update) | **Google only for now** (owner decision): "Continue with Google" on the Verify screen; the account is created from the verified Google email (kept privately in `private/{uid}.email`). Phone OTP via Renflair stays built and tested but is switched off (`phoneLoginEnabled: false`); the server then refuses to send SMS. Emulator builds sign in with test Google accounts (`<first name>@findx.test`). Google sign-in itself is free (Spark); account creation needs Cloud Functions (Blaze). |
| Login (Phase 6) | Login codes are sent by **Renflair**, not Firebase SMS (owner request). The server creates a 4-digit code (Renflair's limit), stores only a salted hash, sends it, checks it (3 tries, 5 minutes, used once) and returns a one-time Firebase sign-in token; the account is created on first login. Limits per number and per network stop SMS abuse. Android's automatic SMS reading is gone (it was Firebase-only). Key: Secret Manager `RENFLAIR_API_KEY`. |
| Test project | A real **test** Firebase project (alias `dev`) gives real SMS login to anyone. It keeps the fake services (auto-approved verification, test-store purchases) and does not enforce App Check. The launch project (id ending `-prod`) never uses fakes. Blaze plan. Setup: `docs/test-project-setup.md`. |
| Phase 5 | Chat is between a seeker and a companion. Starting one costs `creditCostStartChat` (1) **once per pair**; opening it again is free and the app asks before spending. No refunds, including after a block. Messages are checked before they are stored: phone numbers (digits or spelled out in English or Hindi), emails (including "at/dot" tricks), social handles or platform names, and links are blocked by our own detector; ModerationService then checks the content. Blocked messages are never stored; the 3rd blocked attempt in 24 h files an automatic report. When a booking is requested between two people who already chat, a booking card appears in the chat with its live status. A seeker's chat with no booking yet shows a "Book your spot" prompt. "Online now" is not shown (not in the spec). Report or block is on every profile and chat; blocking closes the chat for both, hides each from the other, and cancels their open bookings (table released, no refund). |
| Phase 4 | Map: Google Maps with a heat layer when a key is configured (`--dart-define=MAPS_ENABLED=true` plus `MAPS_API_KEY`), otherwise a drawn map in the screenshot style. "Best spots to meet" = verified, listed venues within 5 km of the seeker (and of the companion when one is chosen), ranked by popularity then distance. A booking needs: companion visible to the seeker, venue within 5 km of both, plan offered by both, slot open and in the future, companion free then ("free now" or weekly hours) and not booked at an overlapping time, seeker not booked at an overlapping time, enough credits. Charge, table and booking are one transaction; the client's request id makes retries safe. In Free right now, tap a person to choose them, then Pick spot (instant request). |
| Design | The screenshots need a few extra colour tokens: avatar peach, avatar initial brown, photo overlay, track, soft chip fill, SOS halo. They will live in the theme only. Success green `#1E8A5A` is below 4.5:1 for small text on white/background, so text uses a darker `successText` token (`#18744B`, ≥ 5.3:1) and fills and icons keep `#1E8A5A`. |

Working name: the folder is `VYBE`. The app name is confirmed as **VYBE** (Q12).

---

## 1. The app in 10 lines

1. A verified, public-place companionship and meetup app for one Indian launch city, on Android and iOS.
2. A **seeker** finds a verified **companion** within 5 km and books a **spot**: a time slot at a verified public **venue**.
3. Plans are everyday ones: coffee, movie, event, walk, dinner. It is not a dating, hookup or escort product, and the copy never suggests it is.
4. Everyone passes phone OTP, a selfie liveness check and a government ID check before they can chat, book or go "Free now".
5. Visibility works both ways: the seeker's "Show me" must include the companion's gender, and the companion's "Who can request you" must include the seeker's gender.
6. Other users' exact locations never reach a client. Clients get a rounded distance ("About 2 km"). Venue distances can be exact.
7. Seekers spend credits (start chat, book spot, instant request) from a server-side ledger. Credits come from IAP packs and Free/Plus/Premium plans.
8. Bookings are capacity-checked in transactions. Venues confirm attendance by scanning a QR code. Completing a meetup releases the companion's held earnings. Payout rates are not decided and stay behind a fake service.
9. Chat is moderated before a message is stored. Contact details, links and explicit content are blocked. Report and block work everywhere.
10. During a meetup there are live location sharing, "I am safe" check-ins, a hold-to-trigger SOS and escalation to a trusted contact and the admin queue.

---

## 2. Key architecture decisions

### 2.1 All cross-user discovery runs in Cloud Functions
Firestore security rules cannot calculate distance. So "only within 5 km" cannot be enforced on a direct client query. Decisions:

- **Companions:** the client calls the callable `discoverCompanions({lat, lng, planType, window})`. The Function runs a geohash query on a server-only collection, checks the exact distance against 5 km, applies matching, verification, block and age filters, and returns DTOs that hold `distanceLabel` only. No coordinates and no geohash leave the server.
- **Venues:** the callable `nearbyVenues({lat, lng})` returns venues within 5 km with exact distances and coordinates. Venue coordinates are public, so pins and the heatmap can use them.
- **Profiles:** other users' profile documents cannot be read directly. `getCompanionProfile(uid)` re-checks radius, matching and blocks. This stops a seeker from opening profiles outside 5 km or across a block by guessing IDs.
- **Consequence:** `geoflutterfire_plus` (Dart, client-side) would have **nothing to do**. The geohash work moves to `geofire-common` in the TypeScript Functions (decided in Q1).

### 2.2 Location privacy
- A user's own location goes to the server through the callable `updateMyLocation`. The server stores the exact point in `private/{uid}/location/current`, which no other user can read.
- For discovery, the server stores a **snapped** point in `companionLocations/{uid}`, rounded to a grid (`AppConfig.companionLocationSnapMeters`, suggested default 500 m). That collection is never readable by any client.
- Distance labels are calculated from the snapped point and rounded to the nearest whole km, never below 1: "About 1 km", "About 2 km", and so on. Combined with per-user rate limits on `discoverCompanions` (`AppConfig.discoverCallsPerMinute`), this blocks trilateration attacks.
- Known limit: the seeker's own location is reported by the client and could be spoofed. App Check plus a plausibility check (no impossible jumps between updates) reduces this but cannot remove it.

### 2.3 All money and state changes go through Functions
Clients can never write balances, ledgers, bookings, slot counts, messages, reports, blocks, SOS alerts or verification status. Every one of these is a callable or trigger Function that uses Firestore transactions and idempotency keys.

### 2.4 One AppConfig source shared by app and server
- `config/app_config_defaults.json` is the single source of tunable values.
- **Flutter:** it is bundled as an asset, set as the Remote Config in-app defaults, and read through `AppConfig` (Riverpod provider).
- **Functions:** they read the same JSON (copied into `functions/src/config/` by `npm run sync-config`) as defaults and override it from the Remote Config **server template** (`firebase-admin` `getServerTemplate`).
- The Emulator Suite has **no Remote Config emulator**. Locally, both sides fall back to the JSON defaults. This is expected.

### 2.5 Where third-party interfaces live
| Interface | Flutter side | Functions side |
|---|---|---|
| IdentityVerificationService | capture (camera), upload, status from the account doc | session creation, decision, writes the result |
| PaymentPayoutService | none (UI only reads the ledger) | earnings quote per booking, release, payout |
| ModerationService | none | text classification before a message is stored |
| PlacesPopularityService | none | venue popularity scores for heatmap and ranking |
| PurchaseVerificationService | none | verifies Play / App Store receipts before credits are granted |

Each server interface has a `Fake…` implementation, chosen only on the emulator. A production build fails loudly until a real provider is wired in.

### 2.6 Timers (timeouts, check-ins, auto-complete)
These use **Cloud Tasks task-queue Functions** (`onTaskDispatched`), which the Emulator Suite supports. Scheduled cron Functions do not fire automatically in the emulator. Each task is enqueued when its trigger event happens: instant request created, meetup started, slot end.

### 2.7 Errors
- Dart: `sealed class Result<T>` = `Ok<T>` | `Err<T>(AppFailure)`. `AppFailure` carries a `FailureKind`: `network`, `offline`, `unauthenticated`, `permissionDenied`, `notVerified`, `insufficientCredits`, `slotFull`, `blocked`, `moderationBlocked`, `notFound`, `rateLimited`, `invalidInput`, `unknown`.
- Repositories map `FirebaseException` / `FirebaseFunctionsException` codes to these values. Nothing is thrown to the UI.
- Functions throw `HttpsError` with a stable `details.code` string that maps one-to-one to `FailureKind`.

---

## 3. Matching rules (approved, Q2)

Genders stored: `woman`, `man`, `non_binary`, `undisclosed` (shown as "Prefer not to say").
Seeker "Show me": `women`, `men`, `everyone`. Companion "Who can request you": `everyone`, `women`, `men`.

```
showMeIncludes(showMe, g)        = showMe == everyone
                                   || (showMe == women && g == woman)
                                   || (showMe == men   && g == man)

whoCanRequestIncludes(wcr, g)    = wcr == everyone
                                   || (wcr == women && g == woman)
                                   || (wcr == men   && g == man)

visible(seeker, companion) = showMeIncludes(seeker.showMe, companion.gender)
                          && whoCanRequestIncludes(companion.whoCanRequest, seeker.gender)
                          && companion.age in seeker.ageRange
                          && no block in either direction
                          && both verified, neither banned
                          && distance(seeker, companion) <= 5 km
```

How this handles the edge cases:
- **Non-binary and "Prefer not to say" companions** appear only to seekers whose "Show me" is **Everyone**. A seeker who picks "Women" sees women only.
- **Non-binary and "Prefer not to say" seekers** can only request companions whose "Who can request you" is **Everyone**. A companion who picked "Women" has asked for women only, and we can't assume an undisclosed gender meets that.
- **"Show my gender on my profile"** only controls **display**. Matching always uses the stored gender, which never leaves the server for other users.
- **Gender is locked after verification** (rules block changes; support or admin can change it). Otherwise someone could switch gender to get past a companion's "Women only" setting.
- **Age** comes from the verified ID date of birth. It is not self-entered.
- Open point: gender is self-declared. See Q3 on whether to cross-check it against the ID.

The same rule decides who can see whom in "Free right now", who can start a chat and who can create a booking. The server re-checks it on every write, not only at discovery.

---

## 4. Folder structure

```
VYBE/
├── lib/
│   ├── main.dart                     # prod entry
│   ├── main_emulator.dart            # emulator entry (fakes + emulators)
│   ├── bootstrap.dart                # shared start-up
│   ├── app.dart                      # MaterialApp.router, theme, l10n
│   ├── core/
│   │   ├── config/                   # app_config.dart, app_env.dart, firebase_config.dart, remote config
│   │   ├── theme/                    # app_colors, app_typography, app_dimens, app_theme
│   │   ├── router/                   # app_router.dart, routes.dart, start / not-found screens
│   │   ├── widgets/                  # AppButton, AppChoiceChip, AppCard, PhotoCard, badges, CreditsPill,
│   │   │                             # StepRow, AsyncStateView (loading/empty/error/offline)
│   │   ├── utils/                    # result.dart, app_failure.dart, run_guarded.dart, clock.dart
│   │   ├── firebase/                 # bootstrap, providers, callable client, file uploader
│   │   ├── connectivity/             # online/offline provider
│   │   └── services/                 # identity_verification (client), image_capture
│   ├── l10n/                         # app_en.arb (Hindi added later)
│   └── features/
│       └── <feature>/                # onboarding, verification, preferences, discover, map,
│           ├── data/                 # booking, availability, profile, chat, safety, credits,
│           ├── domain/               # companion, venue
│           └── presentation/
├── test/                             # mirrors lib/, plus test/helpers (fakes, pump helpers)
├── functions/
│   ├── src/
│   │   ├── index.ts
│   │   ├── config/                   # appConfig.ts, env.ts
│   │   ├── services/                 # identity/, payout/, moderation/, places/, purchases/
│   │   │                             #   each: interface + fake; factory.ts, registry.ts
│   │   ├── domain/                   # geo.ts, slots.ts, verification.ts (later: matching, ledger, bookings)
│   │   ├── handlers/                 # onboarding.ts (later: discover, booking, chat, credits, ...)
│   │   └── shared/                   # errorCodes.ts, callable.ts
│   ├── test/                         # jest unit tests; test/rules + test/emulator run on the emulator
│   ├── scripts/                      # sync-config, smoke-onboarding
│   └── seed/                         # emulator seed script + fixtures
├── config/app_config_defaults.json
├── assets/fonts/                     # Plus Jakarta Sans 400/600/800 (bundled, OFL)
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
├── firebase.json                     # emulators: auth, firestore, functions, storage, tasks, ui
├── .firebaserc                       # project alias "demo-findx" (demo- = no real project needed)
├── analysis_options.yaml             # flutter_lints + strict-casts/inference/raw-types
└── docs/
```

---

## 5. Packages

Exact locked versions are in `pubspec.lock` and `functions/package-lock.json`. Notable ones as of Phase 2: Flutter 3.38.3, Riverpod 3.0.3 (codegen), go_router 17.5, freezed 3.2, FlutterFire core 5.1 / auth 7.0 / firestore 7.1 / functions 7.0 / storage 14.0, firebase-admin 14.5, firebase-functions 7.4, TypeScript 5.9, Jest 29.

### 5.1 From your stack
flutter_riverpod, riverpod_annotation, riverpod_generator, go_router, freezed, freezed_annotation, json_serializable, json_annotation, build_runner, firebase_core, firebase_auth, cloud_firestore, cloud_functions, firebase_storage, firebase_messaging, firebase_app_check, firebase_crashlytics, firebase_remote_config, google_maps_flutter (built-in `Heatmap` layer), in_app_purchase, geolocator, flutter_secure_storage, flutter_localizations + intl, flutter_lints. (`geoflutterfire_plus` dropped, Q1.)

### 5.2 Extra packages (approved, Q4)
| Package | Why | Screen |
|---|---|---|
| connectivity_plus | offline state on every screen | all |
| url_launcher | "Call a friend" opens the dialer | 10 |
| mobile_scanner | venue scans the check-in QR | 14 |
| qr_flutter | seeker shows the check-in QR | 10 (or booking card) |
| just_audio | play 15 s voice intro | 4, 8 |
| record | record voice intro (profile editor) | — |
| camera | live camera preview if a provider SDK needs it | 2 |
| image_picker | selfie and ID capture, profile photos | 2, profile edit |
| mocktail (dev) | test doubles | tests |
| fake_cloud_firestore + firebase_auth_mocks (dev) | repository unit tests without emulator | tests |

Not added: `google_fonts` (the font is bundled as an asset) or a chart library (the weekly earnings chart is a small `CustomPainter`).

### 5.3 Functions (Node 22, TypeScript 5.x)
`firebase-functions`, `firebase-admin`, `geofire-common`, `zod` (input validation); dev: `jest`, `ts-jest`, `@firebase/rules-unit-testing`, `firebase`, `tsx`, `typescript`.

---

## 6. Firestore data model

Conventions: timestamps are `Timestamp` in UTC. "Day" logic runs in `Asia/Kolkata`. Money is stored as integer minor units (paise) with `currency: "INR"`. Credits are integers. **Fn** = written only by Cloud Functions (admin SDK).

Custom auth claims set by Functions: `verified: bool`, `accountType: "member" | "venue_partner"`, `banned: bool`.

### 6.1 Identity and preferences
**`users/{uid}`**: owner-readable account doc
- `accountType` ("member" | "venue_partner") Fn
- `displayName` (owner)
- `photoPaths: string[]` (owner, Storage paths, max `AppConfig.maxProfilePhotos`)
- `activeMode` ("seeker" | "companion") (owner; "companion" only if verified)
- `consent: { rulesVersion, ageConfirmed: true, acceptedAt }` Fn (written by `acceptRules`)
- `verificationStatus` ("pending" | "approved" | "rejected") Fn
- `verificationSteps: { phone, selfie, id }` each ("not_started" | "in_review" | "approved" | "rejected") Fn
- `verificationReason` (e.g. "underage", "fake_rejection") Fn
- `ageYears` Fn (from verified DOB)
- `accountStatus` ("active" | "suspended" | "banned") Fn
- `createdAt`, `updatedAt`

**`private/{uid}`**: owner-readable, never shared
- `phoneE164` Fn
- `dateOfBirth` Fn (from ID provider)
- `idVerification: { provider, providerRef, status, reviewedAt }` Fn
- `trustedContact: { name, phoneE164 }` (owner)
- `fcmTokens: string[]` Fn (via `registerDevice`)

**`private/{uid}/location/current`**: Fn only: `{ lat, lng, geohash, accuracyM, updatedAt }`

**`preferences/{uid}`**: owner read/write with validation
- `gender` (locked once verified)
- `showMe`, `ageMin`, `ageMax`, `showGender` (default false)
- `whoCanRequest` (companion setting, default "everyone")
- *Distance is not stored. It is always `AppConfig.discoveryRadiusKm` = 5.*

### 6.2 Companions
**`companionProfiles/{uid}`**: owner-readable. Others see it only via `getCompanionProfile` / `discoverCompanions`
- `about`, `activityTags: string[]` (enum ids), `planTypes: string[]` (coffee|movie|event|walk|dinner)
- `prompt: { promptId, answer }`
- `voiceIntro: { path, durationSec }` (≤ `AppConfig.voiceIntroMaxSec` = 15)
- `isListed: bool` (owner)
- `freeNow: { active, until }` Fn (via `setFreeNow`, which requires verified)
- `ratingAvg`, `ratingCount`, `meetupCount` Fn
- `updatedAt`

**`companionLocations/{uid}`**: Fn only, never client-readable (denormalized discovery index)
- `geohash`, `lat`, `lng` (snapped), `gender`, `whoCanRequest`, `ageYears`, `planTypes`
- `isListed`, `verified`, `banned`, `freeNowUntil`, `updatedAt`

**`availability/{uid}`**: owner read/write
- `weekly: [{ weekday (1–7), start "HH:mm", end "HH:mm" }]`
- `exceptions: [{ dayKey "yyyy-MM-dd", unavailable: bool }]`
- `timezone: "Asia/Kolkata"`

### 6.3 Venues and slots
**`venues/{venueId}`**: owner-readable. Seekers get it via `nearbyVenues`
- `ownerUid`, `name`, `category`, `addressLine` (set once at onboarding, admin-verified, not editable by seekers)
- `lat`, `lng`, `geohash`, `planTypes`
- `verificationStatus` ("pending" | "verified" | "rejected" | "suspended") Fn/admin
- `isListed` (owner, only when verified)
- `perk: { text, updatedAt }` (owner)
- `safetyChecklist: { staffBriefed, wellLit, publicSeating, … : bool }` (owner)
- `slotTemplate: { slotMinutes, tablesPerSlot, openingHours: [{weekday, open, close}] }` (owner)
- `popularityScore` Fn (PlacesPopularityService + completed-meetup counts)
- `meetupsToday`, `meetupsThisMonth` Fn counters
- `photoPaths`

**`venues/{venueId}/slots/{slotId}`**: `slotId = yyyyMMdd_HHmm` (IST)
- `venueId`, `startAt`, `endAt`, `dayKey`, `capacity`, `booked`, `status` ("open" | "full" | "closed")
- Created by Fn from `slotTemplate` for the next `AppConfig.bookingDaysAhead` days.
- The owner can change `capacity` (never below `booked`) and close a slot. Only Fn changes `booked`.

### 6.4 Bookings
**`bookings/{bookingId}`**: readable by seeker, companion and venue owner. Fn writes only
- `seekerUid`, `companionUid`, `venueId`, `venueOwnerUid`, `slotId` (null for instant until venue picked, see Q9), `planType`
- `kind` ("scheduled" | "instant")
- `status` ("requested" | "accepted" | "declined" | "cancelled" | "checked_in" | "completed" | "disputed")
- `statusReason` (e.g. "timeout", "seeker_cancelled", "companion_cancelled", "venue_closed")
- `startAt`, `endAt`, `respondBy`
- `creditCost`, `chargeLedgerId`, `refundLedgerId?`
- `checkInTokenHash` (the raw token goes to the seeker only)
- `checkedInAt`, `completedAt`, `cancelledBy`, `disputeReportId?`
- `participants: [seekerUid, companionUid]` (for array-contains queries)
- `createdAt`, `updatedAt`

State machine (enforced in Functions):
```
requested ──accept──▶ accepted ──venue QR──▶ checked_in ──end/auto──▶ completed
    │                     │                       │
    ├─decline/timeout──▶ declined (refund)        └─report──▶ disputed
    └─seeker cancel───▶ cancelled (refund)   accepted ─cancel─▶ cancelled (policy Q8)
                                             accepted/checked_in ─report─▶ disputed
```
Slot `booked` is incremented in the same transaction that creates the booking, and decremented on decline, cancel or timeout.

### 6.5 Chat
**`chats/{chatId}`**: `chatId` = sorted `uidA_uidB`
- `participants: [uidA, uidB]`, `participantInfo: { uid: { displayName, photoPath } }`
- `openedBy`, `openLedgerId`, `status` ("open" | "closed_blocked")
- `lastMessage: { text, senderUid, at }`, `lastMessageAt`, `unread: { uid: int }`

**`chats/{chatId}/messages/{messageId}`**: Fn writes only (via `sendMessage`, after moderation)
- `senderUid`, `type` ("text" | "booking_card" | "system"), `text?`, `bookingId?`, `createdAt`

**`moderationStrikes/{uid}`**: Fn only: `{ count, windowStartedAt, lastReportId }`. On the `AppConfig.moderationStrikesForReport`-th (3rd) blocked attempt, Fn creates a `reports` doc with `source: "auto_moderation"`.

### 6.6 Credits and subscriptions
**`creditAccounts/{uid}`**: owner read, Fn write: `{ balance, updatedAt }`

**`creditLedger/{entryId}`**: owner read (where `uid == auth.uid`), Fn write
- `uid`, `delta` (+/−), `balanceAfter`
- `reason` ("signup_bonus" | "purchase" | "subscription_grant" | "chat_start" | "booking" | "instant_request" | "purchase_reversal" (store refund) | "admin_adjustment")
- `refType`, `refId`, `idempotencyKey` (unique: the entry id is derived from it), `createdAt`

**`purchases/{purchaseId}`**: Fn only: `{ uid, platform, productId, storeTransactionId, status, verifiedAt, ledgerId }`

**`subscriptions/{uid}`**: owner read, Fn write: `{ tier ("free"|"plus"|"premium"), productId, platform, status, currentPeriodEnd, autoRenew, lastGrantAt }`

### 6.7 Earnings
**`earningsAccounts/{uid}`**: owner read, Fn write: `{ heldMinor, withdrawableMinor, currency, updatedAt }`

**`earningsLedger/{entryId}`**: owner read, Fn write
- `uid`, `bookingId`, `amountMinor`, `currency`
- `state` ("held" | "released" | "reversed" | "paid_out")
- `quoteRef` (from PaymentPayoutService), `createdAt`, `updatedAt`
- *The amount always comes from `PaymentPayoutService.quoteEarning(booking)`. No rate is defined in code or config. See Q10.*

**`payouts/{payoutId}`**: Fn only: `{ uid, amountMinor, providerRef, status, createdAt }`

### 6.8 Safety, reports, blocks
**`reports/{reportId}`**: reporter can read their own, Fn writes (`submitReport`, rate-limited)
- `reporterUid?` (null for auto), `reportedUid`, `context: { type ("profile"|"chat"|"booking"|"meetup"|"venue"), refId }`
- `reason` (enum), `details`, `source` ("user" | "auto_moderation" | "sos" | "missed_checkin")
- `status` ("open" | "reviewing" | "actioned" | "dismissed"), `resolution?`, `createdAt`

**`blocks/{blockerUid_blockedUid}`**: blocker can read their own, Fn writes (`blockUser`)
- `blockerUid`, `blockedUid`, `createdAt`
- Side effects: matching chats get `status: closed_blocked`, open requests are cancelled with refund, and both users are excluded from each other's discovery, profile, chat and booking calls.

**`safetySessions/{bookingId}`**: participants read, Fn write
- `startedAt`, `nextCheckInDueAt`, `lastSafeAt`, `missedCount`, `escalatedAt?`
- `liveShare: { active, ownerUid, shareTokenHash, expiresAt }`
- **`safetySessions/{bookingId}/locations/{autoId}`**: written by the sharing user only (their own location), `{ uid, lat, lng, accuracyM, at }`

**`sosAlerts/{alertId}`**: owner read, Fn create/update
- `uid`, `bookingId?`, `status` ("active" | "acknowledged" | "resolved")
- `startedAt`, `lastLocation: { lat, lng, accuracyM, at }`
- `trustedContactNotifiedAt?`, `adminAckAt?`
- **`sosAlerts/{alertId}/locations/{autoId}`**: created by the owner while `status == active`

### 6.9 Verification and admin support
**`verificationSessions/{sessionId}`**: owner read, Fn write: `{ uid, step ("selfie"|"id"), documentType, provider, providerRef, status ("awaiting_upload" | step status), uploadPath, createdAt, expiresAt, decidedAt }`
**`venuePartners/{uid}`**: owner read, Fn write: `{ businessName, venueIds, verificationStatus, createdAt }`
**`adminAudit/{id}`**: Fn only, a log of bans, verification overrides and report actions (supports a future admin tool).

### 6.10 Composite indexes (`firestore.indexes.json`)
| Collection | Fields | Used by |
|---|---|---|
| companionLocations | isListed ↑, verified ↑, geohash ↑ | discover (range on geohash) |
| companionLocations | isListed ↑, verified ↑, freeNowUntil ↑ | Free right now (then geo filter) |
| venues | verificationStatus ↑, isListed ↑, geohash ↑ | nearbyVenues |
| bookings | companionUid ↑, status ↑, createdAt ↓ | companion incoming requests |
| bookings | seekerUid ↑, status ↑, startAt ↓ | seeker bookings |
| bookings | venueId ↑, startAt ↑ | venue today's slots |
| bookings | participants (array-contains), startAt ↓ | active meetup lookup |
| chats | participants (array-contains), lastMessageAt ↓ | chat list |
| creditLedger | uid ↑, createdAt ↓ | credits history |
| earningsLedger | uid ↑, createdAt ↓ | earnings list + weekly chart |
| reports | status ↑, createdAt ↓ | admin queue |
| sosAlerts | status ↑, startedAt ↓ | admin queue |
| slots (collection group) | dayKey ↑, startAt ↑ | day chips / time slots |

---

## 7. Security rules

The live rules are in `firestore.rules` and `storage.rules` at the repo root; they are the source of truth (this section no longer copies them). Summary:

- Clients read only their own `users`, `private`, `preferences`, `companionProfiles`, `availability`, credit/earnings/subscription docs, reports they filed and blocks they made.
- Clients write only: display name, photos and active mode on `users` (companion mode needs `verified`); trusted contact on `private`; validated `preferences` (gender locked once verified); their own companion profile and availability (verified only); venue listing, perk, checklist and slot template (venue owner; listing needs a verified venue); slot capacity (never below `booked`); their own live-share and SOS location points.
- Everything else (accounts, verification, credits, bookings, chat messages, reports, blocks, SOS alerts, discovery index) is written only by Cloud Functions.
- Storage: profile photos and voice intros readable by verified users; verification images write-once by the owner and never readable by clients; venue photos writable by the venue owner.
- Numeric limits in rules (18+, 500-char bio, 15 s voice intro, photo counts and sizes) are hard ceilings with a comment naming their AppConfig key (Q11).

Rules tests (`functions/test/rules/`) run on the emulator and cover: own-doc reads only; companion mode needs verification; server-owned fields blocked; trusted contact format; gender lock; under-18 ranges rejected; balances and ledgers unwritable; companion locations hidden from everyone; bookings readable only by participants and the venue owner; chat messages unwritable by clients; unverified venues cannot be listed; capacity never below bookings; SOS points only while active.

---

## 8. Cloud Functions (callables and triggers)

| Name | Type | Summary | Phase |
|---|---|---|---|
| acceptRules | callable | records consent; first time creates the account, private doc, 20 signup credits, Free plan, member claims | 2 (done) |
| startVerification / submitVerification | callable | selfie and ID sessions through IdentityVerificationService; checks the upload exists; under 18 is permanent; sets the `verified` claim | 2 (done) |
| requestLoginOtp / verifyLoginOtp | callable (signed out) | 4-digit code via Renflair (fake on the emulator), salted hash, limits; the right code returns a one-time sign-in token | 6 (done) |
| updateMyLocation | callable | stores exact point privately, rejects impossible jumps, updates snapped `companionLocations` | 3 (done) |
| discoverCompanions | callable | 5 km + two-way matching + age + blocks + plan; rate-limited; returns cards with a rounded `distanceKm` | 3 (done) |
| freeNowCompanions | callable | same filter + next 2 hrs / tonight / tomorrow window | 3 (done) |
| getCompanionProfile | callable | same checks for one uid; "not found" for hidden, far or missing | 3 (done) |
| savedCompanions | callable | the seeker's saved list, minus anyone no longer visible | 3 (done) |
| onCompanionProfileWrite / onPreferencesWrite / onUserWrite | triggers | rebuild the server-only `companionLocations` index (snapped point only) | 3 (done) |
| nearbyVenues | callable | 5 km verified venues (reachable by the companion too, when given), ranked; rate-limited | 4 (done) |
| venueSlots | callable | a venue's slots for a day, each marked available / past / closed / full / companion_unavailable | 4 (done) |
| startChat | callable | charges `creditCostStartChat` once per pair, creates chat | 5 (done) |
| sendMessage | callable | contact detector + ModerationService → store, or strike (3rd strike in 24 h files a report) | 5 (done) |
| markChatRead | callable | resets my unread count | 5 (done) |
| requestBooking | callable | one transaction: all checks, credits − cost (ledger entry), slot.booked +1, booking created; idempotent per request id | 4 (done) |
| respondToBooking | callable | companion accepts / declines (decline releases the table; no refund) | 7 |
| cancelBooking | callable | seeker cancels before the start; table released; no refund | 4 (done) |
| (no booking timeout) | — | requests never expire (owner decision) | — |
| venueCheckIn | callable | venue owner + token + time window → `checked_in` | 8 |
| endMeetup / autoComplete | callable / task | → `completed`, earnings held → released | 7 |
| setFreeNow | callable | verified only, sets `until` | 7 |
| verifyPurchase | callable | PurchaseVerificationService → credits once per store transaction; upgrade now, downgrade at renewal | 6 (done) |
| storeNotification | https | store refund → credits taken back (never below 0), refunded plan ends | 6 (done) |
| renewSubscriptions | scheduled, hourly | re-checks ended periods with the store → next month's credits, or back to Free | 6 (done) |
| submitReport / blockUser | callable | as in §6.8; reports rate-limited (`reportsPerDay`); block closes the chat and cancels open bookings, no refund | 5 (done) |
| startSafetySession / imSafe / safetyCheckDue | callable / callable / task | check-in loop, escalation | 9 |
| triggerSos | callable | alert + notify trusted contact + admin queue | 9 |
| refreshVenuePopularity | task | PlacesPopularityService | 4 |

---

## 9. AppConfig keys

The full list with current values is `config/app_config_defaults.json`. Business values confirmed by you: radius 5 km, signup bonus 20, start chat 1, book spot 5, instant request 5, Plus 100/month, Premium 200/month, top-ups 10/30/75, SOS hold 3 s, voice intro 15 s, 3 moderation strikes. Values I proposed and you have not explicitly confirmed are listed in `docs/fakes-and-replacements.md` §5. Still undecided: instant-request timeout and how long a companion has to respond.

---

## 10. Assumptions (correct any that are wrong)

1. One Firebase project per environment: `demo-findx` (emulator only), then real `findx-dev` and `findx-prod` later.
2. Chat is text-only in v1 (no images or voice notes).
3. Only the **seeker** pays credits. Companions never spend credits to accept, decline or reply.
4. "Start chat" is charged **once per seeker–companion pair**, not per message.
5. "N spots nearby" on Discover = verified venues within 5 km of the **seeker** that have an open slot today.
6. A booking reserves a table when **requested**. The table is released on decline or cancel.
7. Requests never expire. A request still unanswered when its slot starts is shown as "Time passed"; it keeps the status `requested`.
8. Check-in: the seeker shows a one-time QR on the active-meetup card. The venue partner scans it. One scan checks in the booking.
9. Completion: either participant taps "End meetup" after check-in, or the booking auto-completes at slot end plus grace, unless an SOS or report is open (then it becomes `disputed`).
10. Venue partners sign in with phone OTP. Venue verification is done by admin (outside the app). Partners cannot use seeker or companion mode on that account.
11. Check-in reminders go to **both** participants during a meetup. SOS can be triggered by either.
12. Everything runs in `Asia/Kolkata`. English is the only shipped language. Hindi is added later as `app_hi.arb`.
13. No analytics package (not in your list).

---

## 11. Questions

### Answered
Q1, Q2, Q4, Q5 (costs and plans), Q6, Q7 (PurchaseVerificationService kept), Q11, Q12, Q13: see the Decisions table at the top.

### Still open (needed by the phase noted)
- **Q3 (any time).** Should gender be cross-checked against the ID result, or stay self-declared? IDs usually show only M/F, which doesn't fit non-binary users. Currently self-declared and locked after verification.
- **Q10 (Phase 7).** Earnings need an amount per completed meetup. `PaymentPayoutService.quoteEarning()` returns it; the fake returns 0 and the UI shows it as-is, so no rate exists anywhere until you decide.
- **Q14 (Phase 9).** Trusted contact: is it an off-app phone number or another app user? If it's a phone number, notifying them needs an SMS or WhatsApp sender (a new interface with a fake), and live location needs a view-only web link.
- **Display name.** Collected on the Profile tab (Phase 3); Discover reminds people until it is set.

---

## 12. Keys and secrets you will need

Everything up to now runs on the emulator with project id `demo-findx`. No keys are needed. Later:

| Item | Where it goes | Committed? |
|---|---|---|
| `google-services.json` (real) | `android/app/` (replaces the demo file) | No (gitignore it once real) |
| `GoogleService-Info.plist` | `ios/Runner/` | No |
| `lib/core/firebase/firebase_options_*.dart` from `flutterfire configure` | `lib/core/firebase/` | No (generated locally/CI) |
| Google Maps Android key | `android/local.properties` → `MAPS_API_KEY` → manifest placeholder | No |
| Google Maps iOS key | `ios/Flutter/Secrets.xcconfig` → Info.plist | No |
| Play Developer API service account | Secret Manager `PLAY_SA_JSON` (`defineSecret`) | No |
| App Store Server API key (.p8, key id, issuer id) | Secret Manager `APPSTORE_KEY_P8`, `APPSTORE_KEY_ID`, `APPSTORE_ISSUER_ID` | No |
| Identity verification provider keys | Secret Manager `IDV_API_KEY`, `IDV_WEBHOOK_SECRET` | No |
| Renflair SMS API key (login codes) | Secret Manager `RENFLAIR_API_KEY` (`firebase functions:secrets:set RENFLAIR_API_KEY`) | No |
| Moderation / places / payout provider keys | Secret Manager (names fixed once providers are chosen) | No |
| APNs auth key | Firebase console → Cloud Messaging | No |
| App Check: Play Integrity + App Attest | Firebase console; debug tokens for local devices | No |
| Android upload keystore | `android/key.properties` + keystore file | No |
| Token signing for login | Grant the Functions service account **Service Account Token Creator** (see `docs/test-project-setup.md` §4) | — |
