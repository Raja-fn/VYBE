-- FindX database: tables, row-level security, triggers and storage.
--
-- Principle (unchanged from the Firestore rules): people read only their
-- own data and write only a few self-owned fields. Everything that touches
-- another person, money, capacity, chat or safety goes through the `api`
-- Edge Function, which connects as the database owner and bypasses RLS.
--
-- Numeric limits here are hard ceilings; the server enforces the (tighter)
-- AppConfig values named in the comments.

create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------------------
-- App settings shared by the app and the server
-- ---------------------------------------------------------------------------

-- Overrides on top of config/app_config_defaults.json (only the keys set here
-- change). Edit in the Table Editor; the app and the server pick them up.
create table public.app_config (
  id int primary key default 1 check (id = 1),
  overrides jsonb not null default '{}'::jsonb check (jsonb_typeof(overrides) = 'object'),
  updated_at timestamptz not null default now()
);
insert into public.app_config (id) values (1);

-- A numeric setting: the override if set, else the default given here.
create function public.config_number(key text, fallback numeric)
returns numeric language sql stable security definer set search_path = '' as $$
  select coalesce((select (overrides ->> key)::numeric from public.app_config where id = 1), fallback);
$$;

-- ---------------------------------------------------------------------------
-- People
-- ---------------------------------------------------------------------------

create table public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  account_type text not null default 'member' check (account_type in ('member', 'venue_partner')),
  display_name text check (char_length(display_name) <= 40),
  -- maxProfilePhotos
  photo_paths text[] not null default '{}' check (cardinality(photo_paths) <= 6),
  active_mode text not null default 'seeker' check (active_mode in ('seeker', 'companion')),
  consent jsonb,
  verification_status text not null default 'pending' check (verification_status in ('pending', 'approved', 'rejected')),
  verification_steps jsonb not null default '{"phone":"approved","selfie":"not_started","id":"not_started"}'::jsonb,
  verification_reason text,
  age_years int,
  account_status text not null default 'active' check (account_status in ('active', 'banned')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Private details: never shown to anyone else.
create table public.private_profiles (
  id uuid primary key references public.users (id) on delete cascade,
  phone_e164 text,
  email text,
  date_of_birth text,
  id_verification jsonb,
  trusted_contact jsonb check (
    trusted_contact is null or (
      char_length(trusted_contact ->> 'name') between 1 and 60
      and (trusted_contact ->> 'phoneE164') ~ '^\+[1-9][0-9]{7,14}$'
    )
  ),
  fcm_tokens text[] not null default '{}'
);

-- Exact location: only the person and the server see it.
create table public.user_locations (
  uid uuid primary key references public.users (id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  accuracy_m double precision not null,
  updated_at timestamptz not null default now()
);

create table public.preferences (
  uid uuid primary key references public.users (id) on delete cascade,
  gender text not null check (gender in ('woman', 'man', 'non_binary', 'undisclosed')),
  show_me text not null check (show_me in ('women', 'men', 'everyone')),
  who_can_request text not null check (who_can_request in ('everyone', 'women', 'men')),
  show_gender boolean not null,
  -- ageMinimum / ageMaximum
  age_min int not null check (age_min >= 18),
  age_max int not null check (age_max <= 99),
  updated_at timestamptz not null default now(),
  check (age_min <= age_max)
);

-- ---------------------------------------------------------------------------
-- Companions
-- ---------------------------------------------------------------------------

create table public.companion_profiles (
  uid uuid primary key references public.users (id) on delete cascade,
  about text not null default '' check (char_length(about) <= 500),
  activity_tags text[] not null default '{}',
  plan_types text[] not null default '{}',
  prompt jsonb,
  -- voiceIntroMaxSec
  voice_intro jsonb check (voice_intro is null or (voice_intro ->> 'durationSec')::numeric <= 15),
  is_listed boolean not null default false,
  free_now_until timestamptz,
  rating_avg numeric,
  rating_count int not null default 0,
  meetup_count int not null default 0,
  updated_at timestamptz not null default now()
);

-- Server-only discovery index. Holds a snapped location, never the exact one.
-- Rebuilt by triggers whenever any of its inputs change.
create table public.companion_index (
  uid uuid primary key references public.users (id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  gender text not null,
  who_can_request text not null,
  age_years int not null,
  plan_types text[] not null,
  is_listed boolean not null,
  verified boolean not null,
  banned boolean not null,
  free_now_until timestamptz,
  updated_at timestamptz not null default now()
);
create index companion_index_listed_lat_lng on public.companion_index (lat, lng) where is_listed and verified;

create table public.availability (
  uid uuid primary key references public.users (id) on delete cascade,
  weekly jsonb not null default '[]'::jsonb check (jsonb_typeof(weekly) = 'array' and jsonb_array_length(weekly) <= 28),
  exceptions jsonb not null default '[]'::jsonb check (jsonb_typeof(exceptions) = 'array'),
  timezone text not null default 'Asia/Kolkata',
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Venues and bookings
-- ---------------------------------------------------------------------------

create table public.venue_partners (
  uid uuid primary key references public.users (id) on delete cascade,
  business_name text not null,
  venue_ids text[] not null default '{}',
  verification_status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table public.venues (
  id text primary key,
  owner_uid uuid not null references public.users (id),
  name text not null,
  category text not null,
  address_line text not null,
  lat double precision not null,
  lng double precision not null,
  plan_types text[] not null default '{}',
  verification_status text not null default 'pending' check (verification_status in ('pending', 'verified', 'rejected')),
  is_listed boolean not null default false,
  perk jsonb check (perk is null or char_length(coalesce(perk ->> 'text', '')) <= 140),
  safety_checklist jsonb,
  slot_template jsonb,
  popularity_score numeric not null default 0,
  meetups_today int not null default 0,
  meetups_this_month int not null default 0,
  photo_paths text[] not null default '{}',
  updated_at timestamptz not null default now()
);
create index venues_bookable_lat_lng on public.venues (lat, lng) where verification_status = 'verified' and is_listed;

create table public.venue_slots (
  venue_id text not null references public.venues (id) on delete cascade,
  id text not null,
  day_key text not null,
  start_at timestamptz not null,
  end_at timestamptz not null,
  capacity int not null check (capacity >= 0),
  booked int not null default 0 check (booked >= 0),
  status text not null default 'open' check (status in ('open', 'full', 'closed')),
  primary key (venue_id, id),
  check (capacity >= booked)
);
create index venue_slots_day on public.venue_slots (venue_id, day_key, start_at);

create table public.bookings (
  id text primary key,
  seeker_uid uuid not null references public.users (id),
  seeker_name text not null default '',
  seeker_age int,
  companion_uid uuid not null references public.users (id),
  companion_name text not null default '',
  companion_age int,
  venue_id text not null references public.venues (id),
  venue_name text not null,
  venue_category text not null,
  venue_owner_uid uuid not null,
  slot_id text not null,
  day_key text not null,
  start_at timestamptz not null,
  end_at timestamptz not null,
  plan_type text not null,
  kind text not null check (kind in ('scheduled', 'instant')),
  status text not null,
  status_reason text,
  credit_cost int not null,
  charge_ledger_id text,
  participants uuid[] not null,
  cancelled_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index bookings_seeker_day on public.bookings (seeker_uid, day_key);
create index bookings_companion_day on public.bookings (companion_uid, day_key);
create index bookings_participants on public.bookings using gin (participants);

-- ---------------------------------------------------------------------------
-- Chat, safety, moderation
-- ---------------------------------------------------------------------------

create table public.chats (
  id text primary key,
  participants uuid[] not null,
  participant_info jsonb not null default '{}'::jsonb,
  seeker_uid uuid not null,
  companion_uid uuid not null,
  opened_by uuid not null,
  open_ledger_id text,
  status text not null default 'open',
  last_message jsonb,
  last_message_at timestamptz not null default now(),
  unread jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  closed_at timestamptz
);
create index chats_participants on public.chats using gin (participants);

create table public.messages (
  chat_id text not null references public.chats (id) on delete cascade,
  id text not null,
  sender_uid uuid,
  type text not null check (type in ('text', 'system', 'booking_card')),
  system_kind text,
  credits int,
  text text,
  booking_id text,
  plan_type text,
  start_at timestamptz,
  venue_name text,
  created_at timestamptz not null default now(),
  primary key (chat_id, id)
);
create index messages_chat_created on public.messages (chat_id, created_at desc);

create table public.blocks (
  blocker_uid uuid not null references public.users (id) on delete cascade,
  blocked_uid uuid not null references public.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_uid, blocked_uid)
);
create index blocks_blocked on public.blocks (blocked_uid);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_uid uuid,
  reported_uid uuid not null,
  context_type text not null,
  context_ref_id text,
  reason text not null,
  details text,
  source text not null,
  status text not null default 'open',
  created_at timestamptz not null default now()
);

create table public.moderation_strikes (
  uid uuid primary key,
  count int not null,
  window_started_at timestamptz not null,
  last_reasons text[] not null default '{}',
  last_report_id uuid,
  updated_at timestamptz not null default now()
);

create table public.rate_limits (
  key text primary key,
  window_start timestamptz not null,
  count int not null
);

-- Login codes: only a salted hash is kept.
create table public.otp_challenges (
  phone text primary key,
  code_hash text not null,
  salt text not null,
  attempts int not null default 0,
  sent_at timestamptz not null,
  expires_at timestamptz not null
);

-- Which account a phone number signs in to (phone login only).
create table public.phone_logins (
  phone text primary key,
  uid uuid not null unique references auth.users (id) on delete cascade
);

create table public.saved_companions (
  uid uuid not null references public.users (id) on delete cascade,
  companion_uid uuid not null references public.users (id) on delete cascade,
  saved_at timestamptz not null default now(),
  primary key (uid, companion_uid),
  check (uid <> companion_uid)
);

-- ---------------------------------------------------------------------------
-- Credits and plans
-- ---------------------------------------------------------------------------

create table public.credit_accounts (
  uid uuid primary key references public.users (id) on delete cascade,
  balance int not null default 0 check (balance >= 0),
  updated_at timestamptz not null default now()
);

create table public.credit_ledger (
  id text primary key,
  uid uuid not null references public.users (id) on delete cascade,
  delta int not null,
  balance_after int not null,
  reason text not null,
  ref_type text not null,
  ref_id text not null,
  idempotency_key text not null unique,
  created_at timestamptz not null default now()
);
create index credit_ledger_uid on public.credit_ledger (uid, created_at desc);

create table public.purchases (
  id text primary key,
  uid uuid not null references public.users (id) on delete cascade,
  platform text not null,
  product_id text not null,
  kind text not null,
  store_transaction_id text not null,
  purchase_token text not null,
  token_hash text not null,
  status text not null,
  credits int not null default 0,
  ledger_id text,
  verified_at timestamptz not null,
  period_start timestamptz,
  period_end timestamptz,
  credits_taken_back int,
  refunded_at timestamptz
);
create index purchases_token_hash on public.purchases (token_hash);

create table public.subscriptions (
  uid uuid primary key references public.users (id) on delete cascade,
  tier text not null default 'free',
  product_id text,
  platform text,
  status text not null default 'active',
  current_period_end timestamptz,
  auto_renew boolean not null default false,
  last_grant_at timestamptz,
  latest_purchase_id text,
  pending_tier text,
  pending_product_id text,
  pending_purchase_id text,
  updated_at timestamptz not null default now()
);
create index subscriptions_due on public.subscriptions (current_period_end) where status = 'active';

-- ---------------------------------------------------------------------------
-- Verification and admin
-- ---------------------------------------------------------------------------

create table public.verification_sessions (
  id uuid primary key default gen_random_uuid(),
  uid uuid not null references public.users (id) on delete cascade,
  step text not null,
  document_type text,
  provider text not null,
  provider_ref text not null,
  status text not null,
  upload_path text not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  decided_at timestamptz
);

create table public.admin_audit (
  id bigint generated always as identity primary key,
  action text not null,
  details jsonb,
  at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Helpers used by the policies
-- ---------------------------------------------------------------------------

create function public.is_not_banned()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.users where id = auth.uid() and account_status = 'active');
$$;

create function public.is_verified()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.users
    where id = auth.uid() and account_status = 'active' and verification_status = 'approved'
  );
$$;

create function public.is_venue_partner()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.users
    where id = auth.uid() and account_status = 'active' and account_type = 'venue_partner'
  );
$$;

create function public.is_chat_participant(chat text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.chats where id = chat and auth.uid() = any (participants));
$$;

create function public.owns_venue(venue text)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.is_venue_partner()
    and exists (select 1 from public.venues where id = venue and owner_uid = auth.uid());
$$;

-- ---------------------------------------------------------------------------
-- Row-level security. Anything without a policy is denied to app users.
-- ---------------------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array[
    'app_config', 'users', 'private_profiles', 'user_locations', 'preferences', 'companion_profiles',
    'companion_index', 'availability', 'venue_partners', 'venues', 'venue_slots', 'bookings', 'chats',
    'messages', 'blocks', 'reports', 'moderation_strikes', 'rate_limits', 'otp_challenges', 'phone_logins',
    'saved_companions', 'credit_accounts', 'credit_ledger', 'purchases', 'subscriptions',
    'verification_sessions', 'admin_audit'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
  end loop;
end $$;

-- App settings: everyone, even before sign-in.
grant select on public.app_config to anon, authenticated;
create policy app_config_read on public.app_config for select to anon, authenticated using (true);

-- users: read self; edit name, photos and mode.
grant select on public.users to authenticated;
grant update (display_name, photo_paths, active_mode, updated_at) on public.users to authenticated;
create policy users_read_self on public.users for select to authenticated using (id = auth.uid());
create policy users_update_self on public.users for update to authenticated
  using (id = auth.uid() and public.is_not_banned()) with check (id = auth.uid());

-- Switching to companion mode needs a verified member.
create function public.users_guard()
returns trigger language plpgsql set search_path = '' as $$
begin
  if current_user = 'authenticated'
     and new.active_mode = 'companion' and old.active_mode is distinct from 'companion'
     and not (old.verification_status = 'approved' and old.account_type = 'member') then
    raise exception 'Only verified members can switch to companion mode.' using errcode = '42501';
  end if;
  return new;
end $$;
create trigger users_guard before update on public.users for each row execute function public.users_guard();

-- private_profiles: read self; edit the trusted contact only.
grant select on public.private_profiles to authenticated;
grant update (trusted_contact) on public.private_profiles to authenticated;
create policy private_read_self on public.private_profiles for select to authenticated using (id = auth.uid());
create policy private_update_self on public.private_profiles for update to authenticated
  using (id = auth.uid() and public.is_not_banned()) with check (id = auth.uid());

grant select on public.user_locations to authenticated;
create policy locations_read_self on public.user_locations for select to authenticated using (uid = auth.uid());

-- preferences: read and write self.
grant select, insert on public.preferences to authenticated;
grant update (gender, show_me, who_can_request, show_gender, age_min, age_max, updated_at) on public.preferences to authenticated;
create policy preferences_read_self on public.preferences for select to authenticated using (uid = auth.uid());
create policy preferences_insert_self on public.preferences for insert to authenticated
  with check (uid = auth.uid() and public.is_not_banned());
create policy preferences_update_self on public.preferences for update to authenticated
  using (uid = auth.uid() and public.is_not_banned()) with check (uid = auth.uid());

-- Gender is locked once verified, so it cannot be switched to get past a
-- companion's "Who can request you" setting.
create function public.preferences_guard()
returns trigger language plpgsql set search_path = '' as $$
begin
  if current_user = 'authenticated' and new.gender is distinct from old.gender and public.is_verified() then
    raise exception 'Gender cannot change after verification.' using errcode = '42501';
  end if;
  new.updated_at := now();
  return new;
end $$;
create trigger preferences_guard before update on public.preferences for each row execute function public.preferences_guard();

-- companion_profiles: verified people edit their own profile.
grant select on public.companion_profiles to authenticated;
grant insert (uid, about, activity_tags, plan_types, prompt, voice_intro, is_listed, updated_at) on public.companion_profiles to authenticated;
grant update (about, activity_tags, plan_types, prompt, voice_intro, is_listed, updated_at) on public.companion_profiles to authenticated;
create policy companion_read_self on public.companion_profiles for select to authenticated using (uid = auth.uid());
create policy companion_insert_self on public.companion_profiles for insert to authenticated
  with check (uid = auth.uid() and public.is_verified());
create policy companion_update_self on public.companion_profiles for update to authenticated
  using (uid = auth.uid() and public.is_verified()) with check (uid = auth.uid());

-- availability: verified people edit their own hours.
grant select, insert on public.availability to authenticated;
grant update (weekly, exceptions, timezone, updated_at) on public.availability to authenticated;
create policy availability_read_self on public.availability for select to authenticated using (uid = auth.uid());
create policy availability_insert_self on public.availability for insert to authenticated
  with check (uid = auth.uid() and public.is_verified());
create policy availability_update_self on public.availability for update to authenticated
  using (uid = auth.uid() and public.is_verified()) with check (uid = auth.uid());

grant select on public.venue_partners to authenticated;
create policy partners_read_self on public.venue_partners for select to authenticated using (uid = auth.uid());

-- venues: owners read theirs and edit listing, perk, checklist and slot template.
grant select on public.venues to authenticated;
grant update (is_listed, perk, safety_checklist, slot_template, updated_at) on public.venues to authenticated;
create policy venues_read_owner on public.venues for select to authenticated using (owner_uid = auth.uid());
create policy venues_update_owner on public.venues for update to authenticated
  using (owner_uid = auth.uid() and public.is_venue_partner()) with check (owner_uid = auth.uid());

create function public.venues_guard()
returns trigger language plpgsql set search_path = '' as $$
begin
  if current_user = 'authenticated' and new.is_listed and not old.is_listed and old.verification_status <> 'verified' then
    raise exception 'Only verified venues can be listed.' using errcode = '42501';
  end if;
  return new;
end $$;
create trigger venues_guard before update on public.venues for each row execute function public.venues_guard();

-- venue_slots: owners change capacity and open/close.
grant select on public.venue_slots to authenticated;
grant update (capacity, status) on public.venue_slots to authenticated;
create policy slots_read_owner on public.venue_slots for select to authenticated using (public.owns_venue(venue_id));
create policy slots_update_owner on public.venue_slots for update to authenticated
  using (public.owns_venue(venue_id)) with check (public.owns_venue(venue_id) and status in ('open', 'closed'));

-- bookings: the two people and the venue owner.
grant select on public.bookings to authenticated;
create policy bookings_read on public.bookings for select to authenticated
  using (auth.uid() = any (participants) or auth.uid() = venue_owner_uid);

-- chats and messages: verified participants read; the server writes.
grant select on public.chats to authenticated;
create policy chats_read on public.chats for select to authenticated
  using (public.is_verified() and auth.uid() = any (participants));
grant select on public.messages to authenticated;
create policy messages_read on public.messages for select to authenticated
  using (public.is_verified() and public.is_chat_participant(chat_id));

grant select on public.blocks to authenticated;
create policy blocks_read_own on public.blocks for select to authenticated using (blocker_uid = auth.uid());

grant select on public.reports to authenticated;
create policy reports_read_own on public.reports for select to authenticated using (reporter_uid = auth.uid());

-- saved companions: the person's own list.
grant select, delete on public.saved_companions to authenticated;
grant insert (uid, companion_uid) on public.saved_companions to authenticated;
create policy saved_read_self on public.saved_companions for select to authenticated using (uid = auth.uid());
create policy saved_insert_self on public.saved_companions for insert to authenticated
  with check (uid = auth.uid() and public.is_verified() and companion_uid <> auth.uid());
create policy saved_delete_self on public.saved_companions for delete to authenticated using (uid = auth.uid());

grant select on public.credit_accounts to authenticated;
create policy credits_read_self on public.credit_accounts for select to authenticated using (uid = auth.uid());
grant select on public.credit_ledger to authenticated;
create policy ledger_read_self on public.credit_ledger for select to authenticated using (uid = auth.uid());
grant select on public.subscriptions to authenticated;
create policy subscriptions_read_self on public.subscriptions for select to authenticated using (uid = auth.uid());
grant select on public.verification_sessions to authenticated;
create policy verification_read_self on public.verification_sessions for select to authenticated using (uid = auth.uid());

-- ---------------------------------------------------------------------------
-- Discovery index triggers
-- ---------------------------------------------------------------------------

-- Same maths as snapToGrid in server/src/domain/geo.ts.
create function public.snap_to_grid(lat double precision, lng double precision, meters double precision,
  out snapped_lat double precision, out snapped_lng double precision)
language plpgsql immutable as $$
declare
  lat_step double precision := meters / 111320.0;
  lng_step double precision;
begin
  snapped_lat := round(lat / lat_step) * lat_step;
  lng_step := meters / (111320.0 * cos(radians(snapped_lat)));
  snapped_lng := round(lng / lng_step) * lng_step;
  snapped_lat := round(snapped_lat::numeric, 6)::double precision;
  snapped_lng := round(snapped_lng::numeric, 6)::double precision;
end $$;

-- Rebuilds one companion's index row from profile, account, preferences and
-- location, or removes it when any input is missing.
create function public.sync_companion_index(target uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  p public.companion_profiles;
  u public.users;
  pr public.preferences;
  l public.user_locations;
  s record;
begin
  select * into p from public.companion_profiles where uid = target;
  select * into u from public.users where id = target;
  select * into pr from public.preferences where uid = target;
  select * into l from public.user_locations where uid = target;
  if p.uid is null or u.id is null or pr.uid is null or l.uid is null or u.age_years is null then
    delete from public.companion_index where uid = target;
    return;
  end if;
  -- companionLocationSnapMeters
  select * into s from public.snap_to_grid(l.lat, l.lng, public.config_number('companionLocationSnapMeters', 500)::double precision);
  insert into public.companion_index as ci (uid, lat, lng, gender, who_can_request, age_years, plan_types,
    is_listed, verified, banned, free_now_until, updated_at)
  values (target, s.snapped_lat, s.snapped_lng, pr.gender, pr.who_can_request, u.age_years, p.plan_types,
    p.is_listed, u.verification_status = 'approved', u.account_status <> 'active', p.free_now_until, now())
  on conflict (uid) do update set
    lat = excluded.lat, lng = excluded.lng, gender = excluded.gender, who_can_request = excluded.who_can_request,
    age_years = excluded.age_years, plan_types = excluded.plan_types, is_listed = excluded.is_listed,
    verified = excluded.verified, banned = excluded.banned, free_now_until = excluded.free_now_until,
    updated_at = excluded.updated_at;
end $$;

create function public.on_companion_input_change()
returns trigger language plpgsql security definer set search_path = '' as $$
declare target uuid;
begin
  -- NEW and OLD have different columns per table, so read them in separate branches.
  if tg_table_name = 'users' then
    target := new.id;
  elsif tg_op = 'DELETE' then
    target := old.uid;
  else
    target := new.uid;
  end if;
  -- Only companions are indexed.
  if tg_table_name = 'companion_profiles'
     or exists (select 1 from public.companion_profiles where uid = target) then
    perform public.sync_companion_index(target);
  end if;
  return null;
end $$;

create trigger companion_index_profiles after insert or update or delete on public.companion_profiles
  for each row execute function public.on_companion_input_change();
create trigger companion_index_users after update on public.users
  for each row execute function public.on_companion_input_change();
create trigger companion_index_preferences after insert or update on public.preferences
  for each row execute function public.on_companion_input_change();
create trigger companion_index_locations after insert or update on public.user_locations
  for each row execute function public.on_companion_input_change();

-- ---------------------------------------------------------------------------
-- Live updates (Realtime) for what the app watches
-- ---------------------------------------------------------------------------

do $$
declare t text;
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach t in array array['users', 'preferences', 'chats', 'messages', 'bookings', 'credit_accounts',
                             'subscriptions', 'saved_companions'] loop
      execute format('alter publication supabase_realtime add table public.%I', t);
    end loop;
  end if;
end $$;
-- Deletes must carry the whole row so the app can drop it from its list.
alter table public.saved_companions replica identity full;

-- ---------------------------------------------------------------------------
-- File storage. Paths are "<bucket>/<object>", e.g. verification/<uid>/<id>.jpg
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('photos', 'photos', false, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('voice', 'voice', false, 1048576, array['audio/mp4', 'audio/aac', 'audio/m4a', 'audio/mpeg']),
  ('verification', 'verification', false, 10485760, array['image/jpeg', 'image/png']),
  ('venue-photos', 'venue-photos', false, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Profile photos and voice intros: verified people see them; owners upload to their own folder.
create policy media_read on storage.objects for select to authenticated
  using (bucket_id in ('photos', 'voice', 'venue-photos') and public.is_verified());
create policy photos_write on storage.objects for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy voice_write on storage.objects for insert to authenticated
  with check (bucket_id = 'voice' and (storage.foldername(name))[1] = auth.uid()::text and public.is_verified());
create policy own_media_delete on storage.objects for delete to authenticated
  using (bucket_id in ('photos', 'voice') and (storage.foldername(name))[1] = auth.uid()::text);
-- Selfies and ID images: write-once by the owner, never readable by app users.
create policy verification_write on storage.objects for insert to authenticated
  with check (bucket_id = 'verification' and (storage.foldername(name))[1] = auth.uid()::text);
create policy venue_photos_write on storage.objects for insert to authenticated
  with check (bucket_id = 'venue-photos' and public.owns_venue((storage.foldername(name))[1]));
