-- Account deletion (Google Play requirement).
--
-- Deleting the Supabase Auth account cascades to every personal row (users,
-- private profile, location, preferences, credits, purchases, saved, blocks).
-- Bookings stay for the other person's history, holding only the name
-- snapshot they already saw, so they no longer point at the users table.
alter table public.bookings drop constraint if exists bookings_seeker_uid_fkey;
alter table public.bookings drop constraint if exists bookings_companion_uid_fkey;
