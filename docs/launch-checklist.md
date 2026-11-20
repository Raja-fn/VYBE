# VYBE launch checklist (Google Play, Android)

Everything in the code is ready for the first production release:
- a separate production Supabase project;
- real Google Play payments, checked by the server;
- a person on the team reviews every new member's selfie and ID (see below);
- a release signing key, a VYBE icon and splash screen, and version 1.0.0.

What's left needs your accounts. Do the steps in order. Never paste secrets
(keys, passwords, the service-account file) into chats or project files.

## Decisions already made for the launch

| Topic | Launch behaviour | Later |
|---|---|---|
| Selfie and ID checks | **Reviewed by a person.** People type their date of birth at sign-up (under 18 is refused). A reviewer compares selfie, ID and date of birth in the admin panel (**ID checks**) and approves or rejects. Ages on profiles come from the reviewed date of birth. | Connect a provider (HyperVerge, IDfy, Digio) to check automatically. |
| Payments | Real Google Play Billing: credit packs and Plus/Premium plans, verified by the server. Refunds take credits back. | — |
| Booking a meetup | **Free**, no credits (client decision). Credits are only used to start a new chat. | Set `creditCostBookSpot` / `creditCostInstantRequest` in app_config overrides to charge again. |
| Venue "Hot / Busy" | No data source yet: every venue shows as quiet, and spots are ranked by distance. | Connect a popularity source. |
| Companion earnings and payouts | Not offered. | Needs a payout provider. |
| Phone OTP | Off (Google sign-in only). | See `docs/supabase-setup.md`. |
| Notifications | Booking requests, answers, cancellations, new chats and messages, and the verification result. Needs `FINDX_FCM_SERVICE_ACCOUNT_JSON` (step 1.8); without it nothing is sent and the app still works. | — |
| SOS number | Calls **112** (works in India, the EU and many other countries). | Set `emergencyNumber` in app_config overrides per country. |

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
3. **Production marker:** Table Editor → app_config → overrides contains
   `{"environment": "production"}`. (Sample profiles and test accounts were
   removed from the app on 20 Nov; nothing to switch off.)
4. **Reels and free booking (server update).** Apply the new database
   migration (the `reels` table and video storage), then deploy the API:
   ```sh
   npx supabase db push --remote
   npm --prefix server run build:edge
   npx supabase functions deploy api --use-api --project-ref stgfjguoytqzmliurbvp
   ```
   Until then the Reels tab shows "Something went wrong" and booking still
   costs credits.
5. **Meetups and safety (server update, 19 Nov).** Apply the `meetups`
   migration (check-in, private feedback) and deploy the API, the same three
   commands as item 4. Until then Accept/Decline, "I'm here" and "How did it
   go?" show an error.
6. **Safety reports from meetups.** "I felt unsafe" answers land in the
   `reports` table (context `meetup`, source `feedback`) next to normal
   reports; the private answers are in `meet_feedback`. Review them daily.
7. **Reels moderation.** Reported reels land in the `reports` table
   (context `reel`). To remove one: Table Editor → `reels` → delete the row,
   and delete its file in Storage → `reels`. Google Play requires that
   reported content is reviewed.

8. **Launch requirements update (20 Nov): manual review, notifications,
   legal links.** Apply the new code the usual way (item 4's three commands;
   there is no new migration this time, so `db push` just says it is up to
   date). Then set two secrets. Run each line on its own in PowerShell:
   ```powershell
   npx supabase secrets set --project-ref stgfjguoytqzmliurbvp FINDX_ADMIN_SECRET=<a long random text, 40+ letters and digits>
   $key = [Convert]::ToBase64String([IO.File]::ReadAllBytes("firebase-service-account.json"))
   npx supabase secrets set --project-ref stgfjguoytqzmliurbvp FINDX_FCM_SERVICE_ACCOUNT_JSON=$key
   npx supabase secrets unset --project-ref stgfjguoytqzmliurbvp FINDX_IDENTITY_AUTO_APPROVE
   ```
   (The key is passed as base64 because PowerShell breaks the quotes in
   JSON; the server accepts either form.)
   - The Firebase key: Firebase console → project `findx-dev-b5f6b` →
     Project settings → Service accounts → **Generate new private key**. Save
     it as `firebase-service-account.json` in the project folder, run the
     command, then **delete the file** (it is a password).
   - The last line removes the old auto-approve switch (it does nothing any
     more).
   - The admin secret now only signs the panel's sign-in sessions; nobody
     types it any more (see item 9). Changing it signs everyone out.
9. **Use the admin panel every day.** After publishing the website (item 11)
   it is at `https://findx-dev-b5f6b.web.app/admin`. You can also open
   Sign-in is **Sign in with Google**, and only the Google accounts listed in
   the `FINDX_ADMIN_EMAILS` secret get in (you and the client). Set it once,
   with the two addresses separated by a comma, plus the Google client id
   (the same `GOOGLE_WEB_CLIENT_ID` as in `config/supabase.production.json`):
   ```powershell
   npx supabase secrets set --project-ref stgfjguoytqzmliurbvp "FINDX_ADMIN_EMAILS=first@gmail.com,second@gmail.com" --yes
   npx supabase secrets set --project-ref stgfjguoytqzmliurbvp FINDX_ADMIN_GOOGLE_CLIENT_ID=<GOOGLE_WEB_CLIENT_ID> --yes
   ```
   In Google Cloud console → **APIs & Services → Credentials** → that web
   client, make sure **Authorized JavaScript origins** includes
   `https://findx-dev-b5f6b.web.app` (add `http://localhost` too if you open
   the panel locally). A sign-in lasts 12 hours. Removing an email from the
   secret locks that person out at once. Everything done there is in the
   **Activity log** with the person's email. After 10 refused sign-ins from
   one address, that address is locked out for 15 minutes.
   - **ID checks:** same face in selfie, ID and profile photo? Date of birth
     matches the ID (fix it if not)? Then **Approve**, **Reject selfie** or
     **Reject ID**. They get a notification. Never copy ID numbers anywhere.
   - **Reports:** safety reports come first, with the private meetup answer,
     the reported reel or the last chat messages. **Ban**, **Remove reel**,
     **Mark handled** or **Dismiss**.
   - **Members:** search, see meetups, reports and credits. Ban or lift a
     ban, give or take credits, send a notification, or delete an account
     (for deletion requests sent by email).
   - **Meetups:** upcoming, waiting for an answer, past and cancelled ones,
     with check-ins and "How did it go?" answers. The team can cancel one;
     both people are told.
   - **Cafés & spots:** the places VYBE suggests. Hide wrong ones, **Feature**
     good partners (suggested first), add a café yourself (click the map to
     set its location), and set a perk.
   - **App settings:** credit amounts, free credits, SOS number, Grievance
     Officer. Applied within a few minutes.

   The panel needs the `admin_panel` migration and the new API (item 4's
   three commands).
10. **Grievance Officer.** Choose the person, then in the admin panel →
    **App settings** fill in the name (and the email, if different from the
    support email).
    Put the same name in `site/privacy.html` and `site/terms.html` (they say
    "VYBE Grievance Officer" now).
11. **Publish the updated website** (privacy policy and terms now cover
    reels, meetups, the Safety Hub, notifications and the Grievance Officer):
    ```sh
    npx firebase-tools deploy --only hosting --project findx-dev-b5f6b
    ```

## 2. Google Play Console

1. Create a developer account at https://play.google.com/console. It costs
   USD 25, one time.
2. **Create app:** name VYBE, app (not game), free.
3. **Products → In-app products**, all consumable:
   - `vybe_credits_10`
   - `vybe_credits_30`
   - `vybe_credits_75`
4. **Products → Subscriptions**, each with one auto-renewing monthly base
   plan, available in India:
   - `vybe_plus_monthly` — **₹149 a month**, gives 100 credits each month
   - `vybe_premium_monthly` — **₹299 a month**, gives 300 credits each month

   Free members get 20 credits when they join. The IDs must match exactly.
   Prices are charged as set here, and the app shows Play's price; the
   ₹149 / ₹299 in the app settings (`plans[].price`) only fill in until
   Play answers, so keep them the same. Credit amounts are in the app
   settings (`plans[].monthlyCredits`, `signupBonusCredits`).
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

```powershell
$key = [Convert]::ToBase64String([IO.File]::ReadAllBytes("play-key.json"))
npx supabase secrets set --project-ref stgfjguoytqzmliurbvp GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=$key
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
    to the email there are done in the admin panel → **Members** → the
    person → **Delete account** (within 7 days, as the page promises).
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
