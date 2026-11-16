-- The app watches app_config live (prices and limits change without an app
-- update). Supabase Realtime now refuses subscriptions to tables that are not
-- published, so publish it.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (select 1 from pg_publication_tables
                     where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'app_config') then
    alter publication supabase_realtime add table public.app_config;
  end if;
end $$;
