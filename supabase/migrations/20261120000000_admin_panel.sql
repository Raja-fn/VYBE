-- Admin panel: the VYBE team manages meeting spots, reports and members from
-- admin/index.html (through the `api` function with the admin secret).

-- Meeting spots the team adds by hand (source 'admin'), or public places it
-- has corrected (they become 'admin' too, so the monthly map refresh no
-- longer overwrites the correction). Featured spots are suggested first.
alter table public.venues drop constraint if exists venues_source_check;
alter table public.venues add constraint venues_source_check check (source in ('partner', 'osm', 'admin'));
alter table public.venues add column if not exists featured boolean not null default false;
alter table public.venues add column if not exists admin_note text check (admin_note is null or char_length(admin_note) <= 300);
create index if not exists venues_featured on public.venues (featured) where featured;

-- What the team decided about a report.
alter table public.reports add column if not exists resolution text
  check (resolution is null or resolution in ('dismissed', 'actioned'));
alter table public.reports add column if not exists resolution_note text
  check (resolution_note is null or char_length(resolution_note) <= 500);
alter table public.reports add column if not exists resolved_at timestamptz;
create index if not exists reports_open on public.reports (created_at) where status = 'open';

-- Who on the team did it (the name typed into the admin panel).
alter table public.admin_audit add column if not exists actor text;
create index if not exists admin_audit_at on public.admin_audit (at desc);
