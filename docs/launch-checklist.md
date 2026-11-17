# VYBE launch checklist (Google Play, Android)

Everything in the code is ready for the first production release:
- a separate production Supabase project;
- real Google Play payments, checked by the server;
- auto-approved ID checks (owner decision, see below);
- a release signing key, a VYBE icon and splash screen, and version 1.0.0.

What's left needs your accounts. Do the steps in order. Never paste secrets
(keys, passwords, the service-account file) into chats or project files.

## Decisions already made for the launch

| Topic | Launch behaviour | Later |
|---|---|---|
| Selfie and ID checks | **Approved automatically.** Every account gets the same placeholder date of birth (age 26), so ages on profiles are not real. | Connect a provider (HyperVerge, IDfy, Digio) to read real ages. |
| Payments | Real Google Play Billing: credit packs and Plus/Premium plans, verified by the server. Refunds take credits back. | — |
| Booking a meetup | **Free**, no credits (client decision). Credits are only used to start a new chat. | Set `creditCostBookSpot` / `creditCostInstantRequest` in app_config overrides to charge again. |
| Venue "Hot / Busy" | No data source yet: every venue shows as quiet, and spots are ranked by distance. | Connect a popularity source. |
| Companion earnings and payouts | Not offered. | Needs a payout provider. |
| Phone OTP | Off (Google sign-in only). | See `docs/supabase-setup.md`. |

## 1. The Supabase project (live)

The project `findx-dev` (`stgfjguoytqzmliurbvp`) **is** production. Done
already: `FINDX_ENVIRONMENT=production`, the app_config override
`{"environment": "production"}`, the Play package and notification secret,
and the plan-renewal cron job.

Still to do:

1. **Plan renewals (Vault).** The cron job runs but has nothing to call yet.
   Make a long random text (for example a password generator, 48 characters),
   then:
   ```sh
   npx supabase secrets set --project-ref stgfjguoytqzmliurbvp FINDX_CRON_SECRET=<that text>
   ```
   and in **SQL Editor**:
   ```sql
   select vault.create_secret('https://stgfjguoytqzmliurbvp.supabase.co/functions/v1/api', 'findx_api_url');
   select vault.create_secret('<the same text>', 'findx_cron_secret');
   ```
   Keep the text in your password manager.
2. **Email sign-in off:** Authentication → Sign In / Providers → Email →
   off (VYBE signs in with Google only).
3. **Sample profiles off** at launch: Table Editor → app_config → overrides
   `{"environment": "production", "showSampleProfiles": false}`.
4. **Reels and free booking (server update).** Apply the new database
   migration (the `reels` table and video storage), then deploy the API:
   ```sh
   npx supabase db push --remote
   npm --prefix server run build:edge
   npx supabase functions deploy api --use-api --project-ref stgfjguoytqzmliurbvp
   ```
   Until then the Reels tab shows "Something went wrong" and booking still
   costs credits.
5. **Reels moderation.** Reported reels land in the `reports` table
   (context `reel`). To remove one: Table Editor → `reels` → delete the row,
   and delete its file in Storage → `reels`. Google Play requires that
   reported content is reviewed.

## 2. Google Play Console

1. Create a developer account at https://play.google.com/console. It costs
   USD 25, one time.
2. **Create app:** name VYBE, app (not game), free.
3. **Products → In-app products**, all consumable:
   - `vybe_credits_10`
   - `vybe_credits_30`
   - `vybe_credits_75`
4. **Products → Subscriptions**, each with a monthly base plan:
   - `vybe_plus_monthly`
   - `vybe_premium_monthly`

   The IDs must match exactly. Prices are set here; the app shows Play's
   prices.
5. **Play app signing:** keep it on, the default. Upload builds with the
   upload key below.

## 3. Let the server check purchases (Google Cloud)

1. In the Google Cloud project linked to Play Console, enable the
   **Google Play Android Developer API**.
2. Create a **service account**, for example `vybe-play-checks`, and
   download a **JSON key**.
3. In Play Console, go to **Users and permissions → Invite new users** and
   add the service account's email. Give it **View financial data** and
   **Manage orders and subscriptions**.
4. Store the key as a server secret. Run this in your own terminal; the file
   never goes into the project:

```sh
npx supabase secrets set --project-ref <prod ref> GOOGLE_PLAY_SERVICE_ACCOUNT_JSON="$(cat path/to/key.json)"
```

Until this secret exists, the production server refuses every purchase
instead of granting credits it can't verify.

## 4. Refund notices (Real-time developer notifications)

1. In Google Cloud **Pub/Sub**, create a topic named `play-notifications`.
   Give `google-play-developer-notifications@system.gserviceaccount.com` the
   **Pub/Sub Publisher** role on it.
2. Create a **push** subscription to that topic with this endpoint:
   `https://<prod ref>.supabase.co/functions/v1/api/storeNotification?platform=android&token=<FINDX_PLAY_NOTIFICATION_SECRET>`
3. In Play Console, go to **Monetize → Monetization setup → Real-time
   developer notifications**, enter the topic and click **Send test
   notification**. The server accepts it and takes no action.

## 5. Google sign-in and crash reports for the app id `com.vybe.app`

The app id changed from `com.findx.app` to `com.vybe.app` with the VYBE
rename. Until both steps below are done, Google sign-in fails on Android
and crash reports are off (the app still builds and runs).

**Google sign-in.** Google Cloud → **APIs & Services → Credentials →
Create credentials → OAuth client ID → Android**. Create one client per
fingerprint, each with package name `com.vybe.app`:

- **Debug key** (the builds you install from this computer):
  `42:17:45:A2:CE:70:85:AE:2E:DE:09:B8:39:8C:F2:A6:4B:2A:86:9C`
- **Upload key** (on this computer):
  `8C:EB:E4:AC:32:68:2A:DF:71:91:DC:FA:71:C1:69:BD:CF:76:9B:10`
- **Play app signing key:** Play Console → **Test and release → App
  integrity**, after your first upload.

Without the Play key, Google sign-in fails for people who install from Play.
Keep using the same **Web** client id (`GOOGLE_WEB_CLIENT_ID`); it does not
change. The old `com.findx.app` Android clients can be deleted.

**Crash reports.** Firebase console → your project → **Add app → Android**,
package name `com.vybe.app`. Download the new `google-services.json` and
replace `android/app/google-services.json`. The build picks it up
automatically.

## 6. The upload key: back it up now

- Key file: `E:\FindX-release\findx-upload.jks`
- Its passwords: `E:\FindX\android\key.properties`, with a copy in
  `E:\FindX-release\key.properties.backup`

Copy both to safe storage, such as a password manager or an encrypted
drive. If they're lost, Play can reset the upload key, but it takes days.
Never commit them; git already ignores them.

## 7. Build and upload

```sh
flutter build appbundle --release -t lib/main.dart --dart-define-from-file=config/supabase.production.json
#   -> build/app/outputs/bundle/release/app-release.aab
```

Upload the `.aab` to the **Internal testing** track first. Install it from
Play on a phone, sign in with Google, and buy the cheapest pack. Credits
appear only after the server has checked the payment with Google. Then
promote the build to **Production**.

**Next releases:** raise the version in `pubspec.yaml`, for example
`1.0.1+2`. The number after `+` must go up every time.

## 8. Store listing and policies (Play Console)

- **Privacy policy URL:** `https://findx-dev-b5f6b.firebaseapp.com/privacy`
  (required; the app uses location, camera, selfies and ID photos, and
  payments). Terms: `https://findx-dev-b5f6b.firebaseapp.com/terms`.
- **Data safety form:**
  - **Collected:** location (approximate and precise), photos (selfie and
    ID), name, email, purchase history.
  - **Encrypted in transit:** yes.
  - **Account deletion:** in the app, **Profile → Delete account**. It
    deletes the account, photos, ID images, preferences and credits, and
    cancels open bookings. Play also asks for a **web link** where people can
    request deletion without the app:
    `https://findx-dev-b5f6b.firebaseapp.com/delete-account`. Requests sent
    to the email there are done by deleting the user in
    **Supabase → Authentication → Users** (within 7 days, as the page promises).
- **Content rating questionnaire.** The app is for 18+ and enables meeting
  strangers in person.
- **Target audience:** 18 and over.
- **Store listing:** screenshots, short and full description, feature graphic.

## Known limits of this first release

- Ages come from the placeholder ID check, not from real documents.
- No companion earnings or payouts, venue partner dashboard, or meetup
  safety screen with SOS yet. These are planned for later phases.
- The Supabase free plan allows 500 MB of database storage and 1 GB of file
  storage. The dashboard shows usage; upgrade the plan before reaching it.

## Website (privacy, terms, account deletion)

The pages are in `site/`, published with Firebase Hosting at
`https://findx-dev-b5f6b.firebaseapp.com` (also `findx-dev-b5f6b.web.app`).
After editing them, publish with:

```sh
npx firebase-tools deploy --only hosting --project findx-dev-b5f6b
```
