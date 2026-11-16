-- The app saves its own rows with "insert, or update if it exists" (upsert).
-- The update half also writes the key column, so it needs update permission
-- on it. Row-level security still pins the key to the signed-in person
-- (`with check (uid = auth.uid())`), so nobody can move a row to someone else.
grant update (uid) on public.preferences to authenticated;
grant update (uid) on public.companion_profiles to authenticated;
grant update (uid) on public.availability to authenticated;
