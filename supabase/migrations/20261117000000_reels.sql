-- Reels: short videos people post. Verified people watch them in the Reels tab.
--
-- The app uploads the video to the private "reels" bucket, in a folder named
-- after the account id, then calls the server (postReel), which checks the
-- file exists and adds the row. The app never reads this table directly: the
-- server lists reels (reelFeed) so blocks and banned accounts are respected.

create table public.reels (
  id uuid primary key,
  uid uuid not null references public.users (id) on delete cascade,
  video_path text not null unique,
  caption text not null default '' check (char_length(caption) <= 150),
  created_at timestamptz not null default now()
);
create index reels_newest on public.reels (created_at desc, id desc);
create index reels_by_author on public.reels (uid, created_at desc);
alter table public.reels enable row level security;
-- No policies: only the server (which bypasses row-level security) uses it.

-- Videos up to 50 MB (about a minute of phone video).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('reels', 'reels', false, 52428800, array['video/mp4', 'video/quicktime', 'video/3gpp', 'video/webm'])
on conflict (id) do nothing;

create policy reels_read on storage.objects for select to authenticated
  using (bucket_id = 'reels' and (public.is_verified() or (storage.foldername(name))[1] = auth.uid()::text));
create policy reels_write on storage.objects for insert to authenticated
  with check (bucket_id = 'reels' and (storage.foldername(name))[1] = auth.uid()::text and public.is_verified());
create policy reels_delete_own on storage.objects for delete to authenticated
  using (bucket_id = 'reels' and (storage.foldername(name))[1] = auth.uid()::text);
