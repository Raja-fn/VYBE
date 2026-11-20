# VYBE

Verified, public-place companionship and meetups. Flutter (Android + iOS) on
**Supabase** (Postgres, Auth, Storage, Edge Functions), free plan. Firebase is
used only for crash reports (Crashlytics).
Setup is in [docs/supabase-setup.md](docs/supabase-setup.md) and the launch steps in [docs/launch-checklist.md](docs/launch-checklist.md).

## Requirements

- Flutter 3.38+ (Dart 3.10+)
- Node 22 (server code, tests and the Supabase CLI through `npx`)
- No Docker needed

To keep caches off a small system drive, set `PUB_CACHE`, `GRADLE_USER_HOME`
and `npm_config_cache` to folders on a larger drive.

## First-time setup

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
npm --prefix server install
```

Then set up the Supabase test project, the Google sign-in clients and
`config/supabase.dev.json`: **[docs/supabase-setup.md](docs/supabase-setup.md)**.

## Run

```sh
flutter run -t lib/main_dev.dart --dart-define-from-file=config/supabase.dev.json
```

(VS Code: Run and Debug -> **VYBE (test project)**.)

Login is **Google only** for now (phone OTP is built but switched off with
`phoneLoginEnabled`).

## Map

The spots map uses `flutter_map` with OpenStreetMap tiles: no API key or
billing needed. The public OSM tile server is meant for light use; before
heavy traffic, switch `VenueMap._tileUrl` to a hosted tile provider
(MapTiler, Stadia Maps or similar).

## Checks

```sh
flutter analyze
flutter test
npm --prefix server run typecheck
npm --prefix server test            # unit tests
npm --prefix server run test:db     # handlers + security rules on a throwaway local Postgres
npm --prefix server run build:edge && npm --prefix server run smoke:edge   # the deployed bundle under Deno, end to end
```

## Layout

- `lib/core/`: config (AppConfig), theme, router, shared widgets, utils, fake services
- `lib/core/backend/`: Supabase start-up, tables, server calls, file storage
- `lib/features/<feature>/{data,domain,presentation}`: added phase by phase
- `config/app_config_defaults.json`: every tunable number, shared by the app and the server
  (live overrides: the `app_config` table)
- `supabase/migrations/`: tables, row-level security, triggers, storage, schedules
- `supabase/functions/api/`: the one Edge Function (bundled from `server/`)
- `server/`: server code (TypeScript), service interfaces and fakes, seed data, tests
