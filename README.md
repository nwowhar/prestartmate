# Fleet Prestart System
**Offline-first PWA for daily vehicle prestart checks**

---

## What this does
- Workers complete digital prestart checklists on their phone
- Works offline — saves locally, syncs to Supabase when WiFi available
- Outstanding issues carry over between days until a supervisor resolves them
- Supervisor dashboard: odometer history graph, service due alerts, issue tracker, mechanic service log
- Install to home screen for app-like experience

---

## Deployment in 3 steps (~20 minutes)

### Step 1: Set up Supabase (free)

1. Go to **supabase.com** → Sign up / Log in
2. Click **New Project** → give it a name (e.g. "Fleet Prestart") → set a DB password → choose a region
3. Wait ~2 minutes for it to spin up
4. Go to **SQL Editor** (left sidebar) → **New Query**
5. Paste the entire contents of `schema.sql` into the editor → click **Run**
6. Go to **Project Settings** → **API**
7. Copy two values:
   - **Project URL** (looks like `https://xxxxxx.supabase.co`)
   - **anon public** key (the long `eyJ...` string)

### Step 2: Deploy to Vercel (free)

**Option A — Drag and drop (easiest)**
1. Go to **vercel.com** → Sign up / Log in
2. Click **Add New** → **Project**
3. Click **Upload** and drag in the entire `prestart-app` folder
4. Click **Deploy** — done in ~30 seconds
5. Vercel gives you a URL like `https://prestart-app-xxx.vercel.app`

**Option B — Via GitHub (recommended for updates)**
1. Create a GitHub account if you don't have one
2. Create a new repo → upload these files
3. In Vercel → **Add New** → **Project** → **Import Git Repository** → connect your repo
4. Future updates: just push to GitHub and Vercel auto-redeploys

### Step 3: First run on your phone

1. Open the Vercel URL on your phone
2. You'll see the **Setup** screen — paste your Supabase URL and anon key
3. Click **Connect** — it'll verify the connection and load
4. On iPhone: tap the Share button → **Add to Home Screen**
5. On Android: tap the three-dot menu → **Add to Home Screen**

The app is now installed as a PWA and will work offline.

---

## Adding vehicles

Log in as **Supervisor / Mechanic** → go to **Dashboard** → scroll down → **+ Add Vehicle**.

Each vehicle needs:
- Vehicle ID (e.g. LV159)
- Make / Model / Year
- Last service km and date
- Service interval (default 5000km)

Alternatively, the `schema.sql` file includes 4 demo vehicles at the bottom you can edit before running.

---

## How offline sync works

1. When a worker submits a prestart with no WiFi, it saves to the phone's local storage instantly
2. A sync queue builds up with the pending operations
3. The moment WiFi is detected, the queue flushes to Supabase automatically
4. The orange dot in the nav corner shows pending items; green = all synced; grey = offline

---

## Sharing with your team

Send everyone the Vercel URL. Each person enters their name on first use — that's it. No accounts needed.

The setup screen (Supabase credentials) only shows on first use per device. Once connected it stays connected.

---

## Customising the checklist

Edit the `CHECKLIST` array in `index.html` around line 245. Each item needs:
```js
{id:'unique_id', label:'What the worker sees', cat:'Category'}
```
Categories must be in the `CATS` array: `['Fluids','Tyres','Lights','Safety','Condition']`

Add or change categories by updating both arrays.

---

## File structure

```
prestart-app/
├── index.html       ← Full app (edit checklist items here)
├── manifest.json    ← PWA config
├── sw.js            ← Service worker (offline caching)
├── vercel.json      ← Vercel routing config
├── schema.sql       ← Run this once in Supabase SQL Editor
└── README.md        ← This file
```

---

## Security note

This app uses the Supabase **anon key** with open row-level security policies — suitable for an internal tool on a private URL. If you want to restrict access, Supabase supports Auth (email login, magic links) which can be added later.

---

## Troubleshooting

**"Connection failed" on setup screen**
→ Double-check the URL starts with `https://` and the key starts with `eyJ`. Make sure you ran schema.sql first.

**Data not appearing on another device**
→ Tap the sync dot or close/reopen the app. If online, it'll pull from Supabase.

**Service worker not working**
→ Make sure you're on HTTPS (Vercel URLs are always HTTPS). HTTP won't register service workers.

**Prestart already shows submitted but worker says they didn't submit**
→ Check if the prestart was synced from another device. The unique constraint is one prestart per vehicle per day.
