-- ============================================================
-- AdiMusic Listen Together: room registry
-- Run ONCE in Supabase Dashboard -> SQL Editor -> New query.
-- (Dashboard -> your project -> left menu "SQL Editor" -> paste -> Run)
--
-- WHY: Realtime channels come into existence the moment anyone joins
-- them, so without this table ANY 6-digit code "joined" successfully,
-- including codes nobody ever created. The app checks this table
-- before joining, so fake / expired codes are rejected.
--
-- WHAT IT STORES: only the room code, the host's display name, a
-- creator id and timestamps. No chat, no songs, nothing sensitive.
-- Chat is never stored anywhere: it travels over the Realtime
-- channel and lives only in members' memory.
--
-- 24 HOURS: a row is valid for exactly 24 hours from creation. The
-- app ignores expired rows, and prunes them on the next create.
-- ============================================================

create table if not exists public.together_rooms (
  code text primary key,
  host_name text not null default '',
  creator_id text not null default '',
  created_at timestamptz not null default now(),
  expires_at timestamptz not null
);

alter table public.together_rooms enable row level security;

-- Anyone with the app's anon key can read the registry (the app must
-- check a code before joining). Codes are 6-digit lobby PINs: share
-- them only with people you trust, like a game lobby code.
drop policy if exists "together_rooms_read" on public.together_rooms;
create policy "together_rooms_read"
  on public.together_rooms for select
  using (true);

-- Anyone can create a room row.
drop policy if exists "together_rooms_insert" on public.together_rooms;
create policy "together_rooms_insert"
  on public.together_rooms for insert
  with check (true);

-- Rows can only be deleted once expired, so nobody can kill a live room.
drop policy if exists "together_rooms_delete_expired" on public.together_rooms;
create policy "together_rooms_delete_expired"
  on public.together_rooms for delete
  using (expires_at < now());
