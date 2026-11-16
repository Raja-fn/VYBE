-- Public places from OpenStreetMap become meeting spots near each user.
--
-- Imported places have no venue partner (owner) until one claims them. They
-- get default open time slots on demand (see server ensureDefaultSlots).
alter table public.venues alter column owner_uid drop not null;
alter table public.venues add column source text not null default 'partner' check (source in ('partner', 'osm'));
alter table public.bookings alter column venue_owner_uid drop not null;

-- Which map areas have been fetched, so each area is asked once a month.
-- Server only: no client can read or write it.
create table public.place_imports (
  cell text primary key,
  fetched_at timestamptz not null,
  venue_count int not null
);
alter table public.place_imports enable row level security;
revoke all on public.place_imports from anon, authenticated;
