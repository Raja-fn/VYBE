-- Profile details people fill in on "Edit profile": city, languages, work,
-- a short bio, interests, lifestyle and personality. Optional; shown to
-- seekers on a companion's profile. Values are fixed lists (checked here) so
-- every client and the server agree on them.

create table public.profile_details (
  uid uuid primary key references public.users (id) on delete cascade,
  about text check (char_length(about) <= 500),
  city text check (char_length(city) <= 40),
  languages text[] not null default '{}' check (
    cardinality(languages) <= 8
    and languages <@ array['english', 'hindi', 'marathi', 'gujarati', 'tamil', 'telugu', 'kannada', 'malayalam',
                           'bengali', 'punjabi', 'urdu', 'odia']
  ),
  education text check (education in ('high_school', 'diploma', 'bachelors', 'masters', 'doctorate', 'other')),
  profession text check (char_length(profession) <= 60),
  interests text[] not null default '{}' check (
    cardinality(interests) <= 8
    and interests <@ array['music', 'movies', 'travel', 'food', 'coffee', 'books', 'fitness', 'art', 'photography',
                           'gaming', 'cricket', 'football', 'dance', 'theatre', 'tech', 'nature', 'cooking', 'fashion']
  ),
  personality text[] not null default '{}' check (
    cardinality(personality) <= 3
    and personality <@ array['calm', 'cheerful', 'curious', 'adventurous', 'thoughtful', 'witty', 'easygoing', 'ambitious']
  ),
  social_energy text check (social_energy in ('introvert', 'ambivert', 'extrovert')),
  drinking text check (drinking in ('never', 'socially', 'regularly')),
  smoking text check (smoking in ('never', 'socially', 'regularly')),
  fitness text check (fitness in ('rarely', 'sometimes', 'active', 'very_active')),
  updated_at timestamptz not null default now()
);

alter table public.profile_details enable row level security;
revoke all on public.profile_details from anon, authenticated;
grant select, insert on public.profile_details to authenticated;
grant update (uid, about, city, languages, education, profession, interests, personality, social_energy, drinking,
  smoking, fitness, updated_at) on public.profile_details to authenticated;

create policy details_read_self on public.profile_details for select to authenticated using (uid = auth.uid());
create policy details_insert_self on public.profile_details for insert to authenticated
  with check (uid = auth.uid() and public.is_not_banned());
create policy details_update_self on public.profile_details for update to authenticated
  using (uid = auth.uid() and public.is_not_banned()) with check (uid = auth.uid());

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.profile_details;
  end if;
end $$;

-- People see their own profile photos even before they are verified (to edit them).
create policy photos_read_own on storage.objects for select to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);

-- Profile photos must be the person's own uploads (photos/<their id>/...),
-- so nobody can show someone else's picture as theirs.
create function public.users_photo_guard()
returns trigger language plpgsql set search_path = '' as $$
declare path text;
begin
  if current_user = 'authenticated' and new.photo_paths is distinct from old.photo_paths then
    foreach path in array new.photo_paths loop
      if path not like 'photos/' || new.id::text || '/%' then
        raise exception 'Profile photos must be your own uploads.' using errcode = '42501';
      end if;
    end loop;
  end if;
  return new;
end $$;
create trigger users_photo_guard before update on public.users for each row execute function public.users_photo_guard();
