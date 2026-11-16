# Fakes, demo values and placeholders

> **Backend moved to Supabase (2026-11-13).** "Emulator" below now means the **test Supabase project** (fakes on with the `FINDX_FAKE_SERVICES=true` secret); "Cloud Functions" means the `api` Edge Function (`server/`). Test sign-in: **Use a test account** with `<first name>@findx.test` (shared password `findx-test-2026`, test project only). The production switch is `FINDX_ENVIRONMENT=production`.

Everything below is fake or temporary and must be replaced before a real launch.
The app does **not** silently fall back to fakes in production: a production build
fails loudly ("No production … provider is configured") until each real service is wired in.

Last updated: end of Phase 6 (2026-11-12).

---

## 1. Fake third-party services

These are only used on the Firebase emulator (`main_emulator.dart` / `FUNCTIONS_EMULATOR=true`).

| # | Service | Fake file(s) | What the fake does | Replace with | Where to wire it in |
|---|---|---|---|---|---|
| 1 | Identity verification (app side) | Real client now: `functions_identity_verification_service.dart` calls Cloud Functions in every build. The old fake is a **test double only**. | Captures with the phone camera (`image_picker`) and uploads; the server decides. | If the chosen provider requires its own liveness SDK (most do), swap the camera capture in `lib/core/services/image_capture/` for that SDK. | `lib/core/services/image_capture/image_capture_service.dart` |
| 2 | Identity verification (server side) | `functions/src/services/identity/fakeIdentityVerificationService.ts` | Approves every selfie and ID instantly, except uid `u_rejected`. Says every ID shows date of birth `2000-01-15` (age 26). Real providers are usually asynchronous; the app already handles an "in review" state. | A real KYC / liveness provider that supports Aadhaar, passport and driving licence (provider not chosen yet) | `functions/src/services/factory.ts` |
| 3 | Payments and payouts (companion earnings) | `functions/src/services/payout/fakePaymentPayoutService.ts` | Quotes **₹0** for every meetup (no commission rate decided). Every payout "succeeds". | A payout provider + your commission decision | `functions/src/services/factory.ts` |
| 4 | Chat moderation (explicit content) | `functions/src/services/moderation/fakeModerationService.ts` | Flags only the test phrase `fake-explicit-term`. | A real text-moderation API. Phone/email/handle/link blocking is our own code (Phase 5), not this service. | `functions/src/services/factory.ts` |
| 5 | Place popularity (heatmap) | `functions/src/services/places/fakePlacesPopularityService.ts` | Pseudo-random but repeatable "busyness" score per venue per hour. | A real foot-traffic data source and/or our own completed-meetup counts. Note: the official Google Places API does not expose "popular times". | `functions/src/services/factory.ts` |
| 6 | Purchase receipt checks and store refund notices (credits and plans) | `functions/src/services/purchases/fakePurchaseVerificationService.ts` | Accepts receipts `fake-t<purchase ms>-…` for a known product id. Plans renew every 30 days unless the token has `-norenew`; `-pending` means payment not cleared. Refund notices are plain JSON `{ "fake": { "type": "refund", "storeTransactionId": … } }`. | Google Play Developer API (+ Play RTDN via Pub/Sub push to `storeNotification?platform=android`) and App Store Server API (+ App Store Server Notifications v2 to `?platform=ios`) | `functions/src/services/factory.ts` |
| 6b | Test store (app side) | `lib/features/credits/data/store_client.dart` (`TestStoreClient`) | Used by emulator and test-project builds: every purchase succeeds at once with a `fake-` receipt; prices show "Test". The production build (`lib/main.dart`) always uses Google Play / the App Store. | Create the 5 products in Play Console and App Store Connect (§4). | `lib/features/credits/presentation/credits_providers.dart` |
| 7 | Inputs for the fakes | `functions/src/services/fakeFixtures.ts` | Rejected test uid, test moderation phrase, test date of birth. | Delete once all real providers are wired. | — |

`FakeConnectivityService` (in `lib/core/connectivity/connectivity_service.dart`) is a test double only. The app always uses the real `connectivity_plus` service.

---

**Login (Google only for now):** emulator builds offer **Use a test Google account**. The Auth emulator accepts an unsigned Google token, and the seed links every test person to `<first name>@findx.test`. Production builds never show this option, and real Firebase rejects such tokens.

**Login codes on the emulator (phone OTP, switched off):** no SMS is sent. `FakeOtpSender` (`functions/src/services/otp/fakeOtpSender.ts`) writes the 4-digit code to `emulatorOtpCodes/{phone}` (Emulator UI → Firestore) and to the Functions log. On real projects the server sends it through **Renflair** (`renflairOtpSender.ts`, key in Secret Manager as `RENFLAIR_API_KEY`). Login no longer uses Firebase's own phone SMS.

## 2. Fake / demo Firebase project

| Item | Current (demo) value | Where | Replace by |
|---|---|---|---|
| Firebase project | `demo-findx` (works only on the emulators) | `.firebaserc`, `lib/core/config/firebase_config.dart` (`EmulatorConfig`), `functions/src/config/env.ts` | Create real projects (`findx-dev`, `findx-prod`), add them with `firebase use --add`. Keep `demo-findx` for local work. |
| Android Firebase config | `android/app/google-services.json` with **demo values** (`demo-api-key`, project `demo-findx`) | `android/app/google-services.json` | Run `flutterfire configure` (or download from the Firebase console). Then add the real file to `.gitignore`. |
| iOS Firebase config | **Missing** | `ios/Runner/GoogleService-Info.plist` | Download from the Firebase console and add it to the Runner target in Xcode. |
| Emulator API key / app ids | `demo-api-key`, `1:000000000000:...` | `lib/core/config/firebase_config.dart` | Nothing. These are only used against the emulator. |

---

## 3. Fake seed data (emulator only)

File: `functions/seed/fixtures.ts`. Loaded with `npm --prefix functions run seed`. The script refuses to run against any non-`demo-` project.
All people and venues are **fictional**.

**Members (15):** phone numbers `+9198000001xx`, `…02xx`, `…03xx`.

| uid | Name | Role | Gender | Notes |
|---|---|---|---|---|
| c_neha | Neha | companion | woman | Who can request: everyone; free now |
| c_arjun | Arjun | companion | man | Who can request: women; free now |
| c_sam | Sam | companion | non-binary | everyone |
| c_riya | Riya | companion | woman | women only; free now |
| c_kabir | Kabir | companion | man | everyone |
| c_ira | Ira | companion | prefer not to say | everyone; free now |
| c_dev | Dev | companion | man | men only |
| c_far | Meera | companion | woman | **~9 km away in Powai**. Must never appear. |
| s_aarav | Aarav | seeker | man | Show me: everyone |
| s_diya | Diya | seeker | woman | Show me: men |
| s_alex | Alex | seeker | non-binary | Show me: everyone |
| s_kiran | Kiran | seeker | prefer not to say | Show me: women |
| u_unverified | Tara | seeker | woman | verification pending |
| u_banned | Rohan | seeker | man | banned |
| u_rejected | Nikhil | seeker | man | verification rejected |

**Venues (7):** Harbour Bean Cafe, Palm Grove Mall Food Court, Seaface Garden, Reel House Cinema, Lantern Dinner House (all verified, Bandra/Khar/Santacruz), Corner Tea House (**pending**, never listed), Lakeview Cafe (**Powai, outside 5 km**). Each comes with 7 days of slots (393 in total).

Also seeded for each member: 20 signup credits, a Free plan, and default weekly availability for companions.

**Replace by:** real sign-ups and real venue partners. Seed data never goes to production.

---

## 4. Store product ids (placeholders until created in the stores)

In `config/app_config_defaults.json`. These must match the ids you create in Play Console and App Store Connect:

| Product | Id | Credits |
|---|---|---|
| Plus plan (monthly) | `vybe_plus_monthly` | 100 / month |
| Premium plan (monthly) | `vybe_premium_monthly` | 200 / month |
| Top-up | `vybe_credits_10` | 10 |
| Top-up | `vybe_credits_30` | 30 |
| Top-up | `vybe_credits_75` | 75 |

Prices are set in the stores, not in the app.

---

## 5. Numbers I proposed that you have not explicitly confirmed

All are in `config/app_config_defaults.json` and can be changed later through Remote Config without an app update.

| Key | Value | Meaning |
|---|---|---|
| companionLocationSnapMeters | 500 | Privacy grid for companion locations |
| discoverCallsPerMinute | 20 | Anti-tracking rate limit |
| bookingDaysAhead | 7 | Day chips on "Book your spot" |
| slotMinutesDefault | 60 | Default slot length for venues |
| freeNowMaxHours | 2 | "Free now" window |
| checkInWindowMinutesBefore / After | 15 / 30 | When the venue QR scan is accepted |
| safetyCheckIntervalMinutes | 30 | "I am safe" prompts |
| safetyMissedCheckInsToEscalate | 1 | Missed check-ins before escalation |
| autoCompleteGraceMinutes | 30 | Auto-complete after the slot ends |
| moderationStrikeWindowHours | 24 | Window for the 3-strike rule |
| verificationSessionMinutes | 15 | Selfie / ID session lifetime |
| maxProfilePhotos | 6 | Photos per profile |
| ageMaximum | 60 | Upper limit of the age slider (security rules still allow up to 99) |
| defaultAgeRangeMin / Max | 21 / 35 | Default age range (from the screenshot) |
| otpLength | 4 | Login code digits (Renflair only sends 4) |
| otpValiditySeconds | 300 | A login code works for 5 minutes |
| otpMaxAttempts | 3 | Wrong tries before a code is used up |
| otpRequestsPerPhonePerDay | 10 | Login codes per number per day |
| otpRequestsPerIpPerHour | 20 | Login code requests per network per hour |
| popularityHotThreshold / BusyThreshold | 0.7 / 0.4 | Heatmap legend cut-offs |
| subscriptionPeriodDays | 30 | Used only by the fake purchase service |

**Still undecided (needed before Phases 3–7):** instant-request timeout, how long a companion has to respond, cancellation and refund rules for scheduled bookings, the commission rate and payout schedule, and whether the trusted contact is an app user or a phone number.

---

## 6. Other temporary items

| Item | Where | Replace by |
|---|---|---|
| Component gallery screen (design-system check) | `lib/core/dev/component_gallery_screen.dart`, route `/dev/components` | Emulator builds only. Never reachable in production. Can be deleted any time. |
| Gallery sample text ("Name", "4.8", "32") | `lib/l10n/app_en.arb` (`devGallery*` keys) | Delete together with the gallery. |
| App icon and splash screen | Flutter defaults in `android/app/src/main/res/` and `ios/Runner/Assets.xcassets/` | Your VYBE icon and splash (Phase 10). |
| Release signing | Falls back to the **debug key** when `android/key.properties` is missing | Create an upload keystore and add `android/key.properties` (never committed). |
| **Fixed location (opt-in)** | `lib/core/location/location_service.dart` (`FixedLocationService`) | All builds use real GPS. An emulator without GPS can pretend to be at the launch city centre with `--dart-define=FIXED_LOCATION=true` (test builds only). |
| **Fakes on the real test project** | `functions/.env.dev` (`FINDX_FAKE_SERVICES=true`, `FINDX_ENFORCE_APP_CHECK=false`) | Only for the test project (alias `dev`). Never create `.env.prod`; a project id ending in `-prod` ignores the switch anyway. |
| **Drawn map instead of Google Maps** | `lib/features/map/presentation/widgets/venue_map.dart` (`_DrawnVenueMap`) | Used until a Google Maps key is set. Add `MAPS_API_KEY=AIza...` to `android/local.properties` and `MAPS_API_KEY = AIza...` to `ios/Flutter/Secrets.xcconfig`, then build with `--dart-define=MAPS_ENABLED=true`. Enable "Maps SDK for Android" and "Maps SDK for iOS" for the key in Google Cloud. |
| **Venue time slots come from the seed script only** | `functions/seed/seed.ts` (7 days from when it runs) | Re-run `npm --prefix functions run seed` to get fresh days. Automatic daily slot creation from each venue's opening hours arrives with the venue partner side (Phase 8). |
| Venue popularity | Fake service: repeatable made-up scores per venue and hour | A real foot-traffic source and/or our own meetup counts (see §1, item 5). |
| Profile photos and voice intros | Seeded companions have none, so cards show the initial-letter art | Uploaded in the companion profile editor (Phase 7). Display code is already in place. |
| Hindi | English only; Hindi file not created yet | Add `lib/l10n/app_hi.arb` when translations are ready. |
