# FindX launch checklist (Google Play, Android)

Everything in the code is ready for the first production release:
- a separate production Supabase project;
- real Google Play payments, checked by the server;
- auto-approved ID checks (owner decision, see below);
- a release signing key, a FindX icon and splash screen, and version 1.0.0.

What's left needs your accounts. Do the steps in order. Never paste secrets
(keys, passwords, the service-account file) into chats or project files.

## Decisions already made for the launch

| Topic | Launch behaviour | Later |
|---|---|---|
| Selfie and ID checks | **Approved automatically.** Every account gets the same placeholder date of birth (age 26), so ages on profiles are not real. | Connect a provider (HyperVerge, IDfy, Digio) to read real ages. |
| Payments | Real Google Play Billing: credit packs and Plus/Premium plans, verified by the server. Refunds take credits back. | — |
| Venue "Hot / Busy" | No data source yet: every venue shows as quiet, and spots are ranked by distance. | Connect a popularity source. |
| Companion earnings and payouts | Not offered. | Needs a payout provider. |
| Phone OTP | Off (Google sign-in only). | See `docs/supabase-setup.md`. |

## 1. Production Supabase project

1. Create a Supabase project named `findx-prod` in **South Asia (Mumbai)**.
   Save the database password.
2. Set up Google sign-in exactly as for the test project
   (`docs/supabase-setup.md`, steps 2–3). You can reuse the same Web client;
   add the new project's callback URL to its redirect URIs.
3. **Authentication → Sign In / Providers → Email:** turn it **off**
   (production is Google only).
4. Put the project URL and publishable key into
   `config/supabase.production.json`.
5. Deploy. The commands only differ from the test project in the project
   ref and the secrets:

```sh
npx supabase link --project-ref <prod ref>
npx supabase db push --remote
npm --prefix server run build:edge
npx supabase functions deploy api --use-api --project-ref <prod ref>
npx supabase secrets set --project-ref <prod ref> \
  FINDX_ENVIRONMENT=production \
  FINDX_IDENTITY_AUTO_APPROVE=true \
  GOOGLE_PLAY_PACKAGE=com.findx.app \
  FINDX_CRON_SECRET=<long random text> \
  FINDX_PLAY_NOTIFICATION_SECRET=<another long random text>
```

6. **Table Editor → app_config:** set `overrides` to
   `{"environment": "production"}`. The seed script then refuses to run here,
   so no test data can reach production.
7. **Plan renewals:** create the two Vault secrets (step 5 of
   `docs/supabase-setup.md`) with the production URL and cron secret.

## 2. Google Play Console

1. Create a developer account at https://play.google.com/console. It costs
   USD 25, one time.
2. **Create app:** name FindX, app (not game), free.
3. **Products → In-app products**, all consumable:
   - `findx_credits_10`
   - `findx_credits_30`
   - `findx_credits_75`
4. **Products → Subscriptions**, each with a monthly base plan:
   - `findx_plus_monthly`
   - `findx_premium_monthly`

   The IDs must match exactly. Prices are set here; the app shows Play's
   prices.
5. **Play app signing:** keep it on, the default. Upload builds with the
   upload key below.

## 3. Let the server check purchases (Google Cloud)

1. In the Google Cloud project linked to Play Console, enable the
   **Google Play Android Developer API**.
2. Create a **service account**, for example `findx-play-checks`, and
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

## 5. Google sign-in for release builds

In Google Cloud, go to **Credentials → the Android OAuth client** and add
both release SHA-1 fingerprints. The client takes one fingerprint, so create
a second Android client for the second one.

- **Upload key** (on this computer):
  `8C:EB:E4:AC:32:68:2A:DF:71:91:DC:FA:71:C1:69:BD:CF:76:9B:10`
- **Play app signing key:** Play Console → **Test and release → App
  integrity**, after your first upload.

Without the Play key, Google sign-in fails for people who install from Play.

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

- **Privacy policy URL.** Required. The app uses location, camera, selfies
  and ID photos, and payments.
- **Data safety form:**
  - **Collected:** location (approximate and precise), photos (selfie and
    ID), name, email, purchase history.
  - **Encrypted in transit:** yes.
  - **Account deletion:** in the app, **Profile → Delete account**. It
    deletes the account, photos, ID images, preferences and credits, and
    cancels open bookings. Play also asks for a **web link** where people can
    request deletion without the app. A page on your website with a support
    email works; deletions requested there are done by deleting the user in
    **Supabase → Authentication → Users**.
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
