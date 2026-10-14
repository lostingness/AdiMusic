# Listen Together — Supabase Setup

AdiMusic's **Together** tab syncs playback between two phones over Supabase
Realtime (Phoenix-channels protocol over WebSocket). No tables or SQL are
needed — rooms are broadcast-only channels named
`realtime:together:<6-LETTER-CODE>`. The room code itself is the access
control: codes are 6 characters from a 31-symbol alphabet, generated with
`SecureRandom` (~887 million combinations).

## 1. Create a free Supabase project

1. Go to https://supabase.com/dashboard and sign in (free tier is enough).
2. **New project** → pick a name, a database password, and the nearest region.
3. Wait for the project to finish provisioning.

## 2. Copy the two keys

In the project dashboard → **Project Settings → API**:

- **Project URL** → e.g. `https://abcdefghijklm.supabase.co`
- **anon / public key** → the long `eyJ...` token labelled `anon public`
  (in newer dashboards it is under **"Legacy API keys"** — scroll down
  past the new keys to find it).

> IMPORTANT: use the **legacy `anon` key** (`eyJ...`), NOT the new
> publishable key (`sb_publishable_...`). The Realtime server validates
> the key as a JWT — the publishable key is rejected and both phones
> stay stuck on "Disconnected". This was the v4.2.8 bug.

> The `anon` key is a *public* key by design (it ships inside the app, like
> any client API key). Never paste the `service_role` key anywhere — it
> bypasses all security rules.

## 3. Add the keys to this repo

**For CI builds (the APKs released here):**

Repo → **Settings → Secrets and variables → Actions → New repository secret**:

| Secret name      | Value                  |
| ---------------- | ---------------------- |
| `SUPABASE_URL`   | your Project URL       |
| `SUPABASE_ANON_KEY` | your `anon public` key |

The workflow passes these as build environment variables; Gradle reads them
into `BuildConfig.SUPABASE_URL` / `BuildConfig.SUPABASE_ANON_KEY`.

**For local builds:** put the same two values in `local.properties`
(or a root `.env` file):

```properties
SUPABASE_URL=https://abcdefghijklm.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

Builds without these keys still compile — the Together tab shows the
"isn't set up yet" card instead of crashing.

## 4. Two-phone test

1. Install the same APK on both phones (uninstall the old version first —
   every CI build signs with a fresh debug key).
2. Phone A: open the **Together** tab → enter a name → **Create room** →
   share the 6-letter code.
3. Phone B: open the **Together** tab → enter a name + the code →
   **Join room**. Both phones should show **Connected** and each other's names.
4. Phone A (host): play any song, pause it, seek, change track. Phone B
   must follow within ~1 second.
5. Turn off Phone B's internet for ~10 seconds, then turn it back on —
   it should reconnect and resynchronize automatically.
6. Either phone: **Leave room** → clean disconnect.

## How sync works (short)

- Only the **host** broadcasts: track id, title/artist/artwork, position,
  play/pause + a server timestamp, plus a heartbeat every 3 s.
- Joiners apply the snapshot: different track → load it and seek; position
  drift over 600 ms → seek; play/pause mismatch → resume/pause.
- Joiners never broadcast, so there is no feedback loop.
- On reconnect, the joiner asks the host for a fresh snapshot
  (`together_request`) and resyncs.
- Room state is never written to a database — it lives only in the
  Realtime channel while members are connected.
