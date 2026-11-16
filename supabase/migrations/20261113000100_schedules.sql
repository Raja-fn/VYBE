-- Hourly plan renewals: calls the `api` function's renewSubscriptions action
-- with a shared secret. Uses Supabase's pg_cron and pg_net (free plan).
--
-- It needs two Vault secrets, set once per project (SQL editor):
--   select vault.create_secret('https://<ref>.supabase.co/functions/v1/api', 'findx_api_url');
--   select vault.create_secret('<the same value as FINDX_CRON_SECRET>', 'findx_cron_secret');
-- Until both exist, the job does nothing.
--
-- Skipped where pg_cron / pg_net are not available (the local test database).

do $outer$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron')
     and exists (select 1 from pg_available_extensions where name = 'pg_net') then
    create extension if not exists pg_cron;
    create extension if not exists pg_net;
    perform cron.schedule(
      'findx-renew-subscriptions',
      '7 * * * *',
      $job$
        select net.http_post(
          url := (select decrypted_secret from vault.decrypted_secrets where name = 'findx_api_url') || '/renewSubscriptions',
          headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'x-cron-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'findx_cron_secret')
          ),
          body := '{}'::jsonb
        )
        where exists (select 1 from vault.decrypted_secrets where name = 'findx_api_url')
          and exists (select 1 from vault.decrypted_secrets where name = 'findx_cron_secret');
      $job$
    );
  end if;
end
$outer$;
