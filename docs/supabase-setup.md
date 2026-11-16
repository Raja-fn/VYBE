# Setting up VYBE on Supabase

VYBE runs on **Supabase** (database, sign-in, file storage and server code)
on the free plan. No card is needed. Firebase is used only for crash reports
(Crashlytics, also free).

You need two Supabase projects:

| Project | Used for | Server fakes |
|---|---|---|
| `findx-dev` (test) | testers, demos | On: ID checks auto-approve, test-store purchases, test accounts |
| `findx-prod` (launch) | the real app | Off: real providers only |

Steps 1–7 set up the **test** project. "The launch project, later" at the end
lists what changes for production.

Never paste passwords, the `service_role` / secret key or the Google client
**secret** into chats or files in this project. The project URL, the
publishable (anon) key and the Google **client ID** are public. They ship
inside the app, so they're safe to share.

---

## 1. Create the Supabase project

1. Go to https://supabase.com and sign in.
2. Click **New project**:
   - Name: `findx-dev`
   - Region: **South Asia (Mumbai)**
   - Database password: generate one and save it in your password manager.
3. When it's ready, go to **Project Settings → API** and note:
   - **Project URL**, for example `https://abcdefgh.supabase.co` (public).
   - **Publishable key** (or the legacy **anon** key) (public).
   - **Secret key** (or the legacy **service_role** key). Keep this private.

## 2. Create the Google sign-in clients (Google Cloud, no billing needed)

In https://console.cloud.google.com, choose or create a project:

1. **APIs & Services → OAuth consent screen**: set it to External, app name
   VYBE, and add your support email.
2. **Credentials → Create credentials → OAuth client ID → Web application**:
   - Name it `VYBE Supabase`.
   - Under **Authorized redirect URIs**, add
     `https://<your project ref>.supabase.co/auth/v1/callback`.
   - Copy the **Client ID** (public) and the **Client secret** (private).
3. **Create credentials → OAuth client ID → Android**:
   - Package name: `com.vybe.app`
   - SHA-1 of the computer that builds test APKs:
     `42:17:45:A2:CE:70:85:AE:2E:DE:09:B8:39:8C:F2:A6:4B:2A:86:9C`
   - For release builds, also add the SHA-1 of the release key, or of
     Play App Signing.

To print the SHA-1 on another computer:
```sh
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android
```

## 3. Sign-in settings (Supabase dashboard → Authentication)

1. **Sign In / Providers → Google → Enable**:
   - **Client IDs**: the **Web** client ID from step 2.
   - **Client Secret**: the Web client secret from step 2. Paste it here
     yourself.
   - **Skip nonce checks**: on. Android's Google sign-in doesn't send a nonce.
   - Save.
2. **Sign In / Providers → Email** (test project only): keep it enabled,
   turn **Confirm email** off, and save. Test accounts use it.

## 4. Fill in the app's settings file

Copy `config/supabase.example.json` to `config/supabase.dev.json` and fill in:

```json
{
  "SUPABASE_URL": "https://abcdefgh.supabase.co",
  "SUPABASE_KEY": "sb_publishable_...",
  "GOOGLE_WEB_CLIENT_ID": "1234567890-abc.apps.googleusercontent.com"
}
```

## 5. Put the database and server online (on this computer)

Run these from the project folder:

```sh
npx supabase login                               # opens your browser
npx supabase link --project-ref <your project ref>   # asks for the database password

npx supabase db push --remote                    # tables, security rules, storage, schedules

npx supabase secrets set FINDX_FAKE_SERVICES=true FINDX_CRON_SECRET=<a long random text>

npm --prefix server install
npm --prefix server run build:edge
npx supabase functions deploy api --use-api      # no Docker needed
```

Then turn on the hourly plan renewals: open **SQL Editor** in the Supabase
dashboard and run:

```sql
select vault.create_secret('https://<your project ref>.supabase.co/functions/v1/api', 'findx_api_url');
select vault.create_secret('<the same long random text as FINDX_CRON_SECRET>', 'findx_cron_secret');
```

**After changing server code:** run `build:edge` and `functions deploy` again.
**After adding a migration:** run `db push --remote` again.

## 6. Load the Mumbai test data (test project only)

1. In the dashboard, open **Connect** and copy the **Session pooler**
   connection string. Put your database password into it.
2. Run this in your own terminal. Don't save these values in any file.

```sh
set SUPABASE_URL=https://<ref>.supabase.co
set SUPABASE_SERVICE_ROLE_KEY=<secret / service_role key>
set SUPABASE_DB_URL=<session pooler connection string>
npm --prefix server run seed -- --test-project <ref>
```

This creates 15 people, 7 venues and two weeks of slots. You can run it
again: it resets the people and venues, and keeps what testers spent or
booked.

**Test sign-in:**
- **In the app:** tap **Use a test account** and type the email, for example
  `aarav@findx.test`, `diya@findx.test` or `neha@findx.test`. The password is
  `findx-test-2026` and the app fills it in for you.
- **Brand-new account:** type any email that isn't seeded.

## 7. Run the app or share it

```sh
# Your phone over USB:
flutter run -t lib/main_dev.dart --dart-define-from-file=config/supabase.dev.json

# An APK for testers:
flutter build apk --release -t lib/main_dev.dart --dart-define-from-file=config/supabase.dev.json
#   -> build/app/outputs/flutter-apk/app-release.apk
```

In VS Code, use the launch option **VYBE (test project)**.

All builds use the phone's real location. On an emulator without GPS, add
`--dart-define=FIXED_LOCATION=true` to pretend to be in central Mumbai.

---

## Changing prices and limits without a new app

Open **Table Editor → app_config** and edit the `overrides` JSON. For example:

```json
{ "creditCostBookSpot": 6, "phoneLoginEnabled": false }
```

Only the keys you set change. Everything else comes from
`config/app_config_defaults.json`. The app and the server both read this row,
so they always agree. The server picks up a change within a minute.

## Phone OTP (Renflair), later

Phone login is built but switched off. To turn it on:

1. Store the key:
   `npx supabase secrets set RENFLAIR_API_KEY=<key>` (paste it in your
   terminal, not in a file).
2. Set `"phoneLoginEnabled": true` in `app_config.overrides`.
3. Keep the **Email** provider enabled. Phone accounts sign in through a
   one-time email-style token, and no email is ever sent.

**Before launch:**
- **DLT:** confirm with Renflair that their route is DLT-compliant.
- **Testing without Renflair:** on the test project, codes then appear in
  **Edge Functions → api → Logs**.

## The launch project, later

Create `findx-prod` the same way, with these differences:

- **Server settings:** don't set `FINDX_FAKE_SERVICES`. Set
  `FINDX_ENVIRONMENT=production` and `FINDX_CRON_SECRET`. The server then
  refuses to approve IDs or grant purchases until the real providers are
  connected (see `docs/fakes-and-replacements.md`).
- **Mark it as production:** in `app_config.overrides`, add
  `"environment": "production"`. The seed script then refuses to run on it.
- **Email provider:** turn it off (Google only), unless phone OTP is on.
- **App settings file:** fill `config/supabase.production.json`, and build
  with `lib/main.dart`:
  ```sh
  flutter build appbundle --dart-define-from-file=config/supabase.production.json
  ```
- **Free plan pause:** free projects pause after 7 days without any
  requests. A launched app with daily users never pauses. For a quiet test
  project, open the dashboard and click **Restore** if it paused.

## Where things are

| What | Where |
|---|---|
| Tables, security rules, storage buckets, triggers | `supabase/migrations/*.sql` |
| Server code (all 20 app actions, store notices, renewals) | `server/src`, bundled to `supabase/functions/api/server.js` |
| Server tests (real Postgres, no Docker) | `npm --prefix server run test:db` |
| App ↔ server connection | `lib/core/backend/` |
