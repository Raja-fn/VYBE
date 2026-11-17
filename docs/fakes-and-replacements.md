# Placeholders in the live app

VYBE runs on one Supabase project in production mode. These parts are still
placeholders. Each sits behind an interface, so replacing one means writing
a new implementation and choosing it in `server/src/services/factory.ts`
(`createServices`). Nothing else changes.

| Part | What production does today | To replace it |
|---|---|---|
| **ID and selfie checks** | Approved automatically. That is the owner's launch decision, switched on by the secret `FINDX_IDENTITY_AUTO_APPROVE=true`. Every account gets the same placeholder date of birth, so **ages are not real** (shown as 26). | A provider such as HyperVerge, IDfy or Digio, implementing `IdentityVerificationService`. |
| **Venue popularity ("Hot / Busy")** | No data: every spot is "Quiet", and spots rank by distance. | A foot-traffic source, or FindX's own meetup counts, implementing `PlacesPopularityService`. |
| **Companion earnings and payouts** | Not offered: any payout call fails. | A payout provider, implementing `PaymentPayoutService`. |
| **Chat moderation** | VYBE's own rules block phone numbers, emails, handles and links. Nothing checks for explicit content. | A text-moderation API, implementing `ModerationService`. |
| **Phone login** | Off (`phoneLoginEnabled: false`); Google sign-in only. | Set `RENFLAIR_API_KEY` and turn `phoneLoginEnabled` on (see `docs/supabase-setup.md`). |
| **Purchases** | Real Google Play checks. They are refused until `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` is set (launch checklist, section 3). | Done in code; only the key is missing. |
| **Meeting spots** | Real places from OpenStreetMap (a one-time India import; see `tool/places/`). Places without a venue partner get default slots from 10:00 to 22:00. | Re-run the import every few months. Venue partners can claim places later. |

## Fakes used only in tests

`server/src/services/**/fake*.ts` and `server/src/services/fakeFixtures.ts`
are used by the server tests, and by `FINDX_FAKE_SERVICES=true` on a test
project. That secret is not set on the live project, and the server ignores
it whenever `FINDX_ENVIRONMENT=production`. `server/seed/` creates sample
people and venues for local tests. It refuses to run against a project marked
`environment: production`.

On the app side, `TestStoreClient` (`lib/features/credits/data/store_client.dart`)
only appears in test builds. Production builds always use Google Play.
