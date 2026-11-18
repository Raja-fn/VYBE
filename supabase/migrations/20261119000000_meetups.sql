-- Meetups: the invited person answers a request, both people check in at the
-- venue, and afterwards each can privately say how it went.

alter table public.bookings add column if not exists checked_in_uids uuid[] not null default '{}';
alter table public.bookings add column if not exists feedback_uids uuid[] not null default '{}';

-- Private answers to "How did it go?". Only the server reads them (RLS on, no
-- policies); an "unsafe" answer also files a report for the safety team.
create table if not exists public.meet_feedback (
  booking_id text not null references public.bookings (id) on delete cascade,
  uid uuid not null,
  about_uid uuid not null,
  felt text not null check (felt in ('good', 'okay', 'unsafe')),
  note text check (note is null or char_length(note) <= 1000),
  created_at timestamptz not null default now(),
  primary key (booking_id, uid)
);
alter table public.meet_feedback enable row level security;
