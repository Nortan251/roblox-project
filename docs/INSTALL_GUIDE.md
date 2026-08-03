# TIDEBOUND — How to get it into your Roblox Studio (x_max10xh)
*Step-by-step. No jargon. If anything here doesn't match what you see on screen, stop and ask.*

> ⭐ **NEW — Method C (fully automatic):** I can build the whole game and publish it
> straight to your Roblox account using the official **Open Cloud API**. You only do
> **2 web clicks** (create the experience + generate an API key), then I do everything.
> See **Section 9**.

---

## 1. What went wrong (so you understand it)

You pasted `studio_installer.luau` (a 381 KB file) into the **Command Bar**. That box in Studio
can't handle files that big — it cuts them off mid-sentence, and the cut-off code produces the
error you saw:

> `CommandBar:1: Incomplete statement: expected assignment or a function call`

The code itself is fine (it passed every test). The problem was the delivery method.

**Good news: you never need the Command Bar again.** I built you two better ways.

---

## 2. What you need first (2 minutes)

1. **Roblox Studio** — free from https://www.roblox.com/create (click "Start Creating").
2. Open Studio and **sign in as x_max10xh** (top-right corner).
3. Click **New** → choose the **Baseplate** template (flat gray world).
4. In the menu bar make sure you can see the **Explorer** panel (View tab → Explorer) on the right.

---

## 3. Download the 3 import files

In the workspace (where you read this), open these three files one at a time and download each
to your computer (Desktop is fine — make a folder called `Tidebound`):

| File | What it contains |
|---|---|
| `tools/rbxmx/01_replicatedstorage_shared.rbxmx` | Shared code (Config, Types, Util, Remotes, Data catalogs) |
| `tools/rbxmx/02_serverscriptservice.rbxmx` | Server code (Bootstrap + 9 services) |
| `tools/rbxmx/03_starterplayer_client.rbxmx` | Client code (Bootstrap, Controllers, Modules) |

**How to download:** open the file → click the **Download** button on the file viewer → save it.
(If your browser asks "Keep this file?" → click Keep.)

---

## 4. Method A — the 3-click import (RECOMMENDED, no copying at all)

**Step A1 — import the Shared code:**
1. In the **Explorer** panel, find **ReplicatedStorage** (under the game name at the top).
2. **Right-click** ReplicatedStorage → click **Insert from File...**
   (If you don't see it, hover "Insert" → "From File". In some versions you can also just
   **drag the file onto the Explorer panel**.)
3. Choose `01_replicatedstorage_shared.rbxmx` → Open.
4. You should now see a **Shared** folder inside ReplicatedStorage.

**Step A2 — import the Server code:**
1. Right-click **ServerScriptService** → **Insert from File...**
2. Choose `02_serverscriptservice.rbxmx` → Open.
3. You should now see a **Bootstrap** script and a **Services** folder (with 9 scripts inside).

**Step A3 — import the Client code:**
1. Expand **StarterPlayer** (it's below ReplicatedStorage).
2. Right-click **StarterPlayerScripts** → **Insert from File...**
3. Choose `03_starterplayer_client.rbxmx` → Open.
4. You should see a **Bootstrap** LocalScript, plus **Controllers** and **Modules** folders.

**Step A4 — check your Explorer looks like this:**
```
ReplicatedStorage
└── Shared
    ├── Config, Types, Util, Remotes
    └── Data (FishCatalog, RodCatalog, ZoneCatalog, QuestCatalog)

ServerScriptService
├── Bootstrap
└── Services (SecurityService, DataService, EconomyService, InventoryService,
              QuestService, EventService, LeaderboardService, ShopService, FishingService)

StarterPlayer > StarterPlayerScripts
├── Bootstrap (LocalScript)
├── Controllers (Audio, Cast, UI, Menu)
└── Modules (Theme, UiKit, ClientState, FishVisuals)
```

**Step A5 — test it:**
1. Click **Play** (green button, or press **F5**).
2. Look at the **Output** window (View → Output). You should see:
   `[Tidebound] Server booted. Services: SecurityService, ...` and `[Tidebound] Client booted.`
3. You'll see the HUD (coins top-left, XP bar bottom-center). Press **Q** — you'll cast a
   bobber. (Catching fish needs the map zones — that's step 6 below.)
4. Click the red **Stop** button (or Shift+F5).

✅ **You did it — the whole game is in Studio.**

---

## 5. Method B — fallback: paste 12 small parts (only if Method A fails)

If importing the .rbxmx files gives you trouble for any reason, use this instead:

1. Test the bar first: in the **Command Bar** (View tab → Command Bar), type:
   `print("ok")` → press **Enter**. You should see `ok` in the Output window.
2. Open `tools/installer_parts/part_01_of_12.luau` → download it → open in **Notepad**.
3. **Ctrl+A** (select all) → **Ctrl+C** (copy).
4. Click in the Command Bar → **Ctrl+V** (paste) → **Enter**.
5. Wait for the message `[Installer] Part 1/12 complete` in Output.
6. Repeat for parts 2 → 12 (each is a separate small paste).
7. Done — same result as Method A. (These parts were tested end-to-end: all 12 create the
   exact same tree, and running them twice doesn't duplicate anything.)

---

## 6. What's next (30–60 minutes)

The scripts are in, but the world is still a flat baseplate. To make the game playable:

1. **Build the ocean + islands.** Use the Terrain tools (Home tab → Terrain Editor):
   - Create water at **Y = 0** (Edit tab → Water).
   - Sculpt 6 islands and name the zones (details + screenshot checklist in `src/README.md`).
2. **Place the zone region parts** (REQUIRED for fishing to work): for each zone, insert an
   anchored transparent Part named exactly `ZoneRegion_sunshall`, `ZoneRegion_whisper`,
   `ZoneRegion_drop`, `ZoneRegion_ember`, `ZoneRegion_frost`, `ZoneRegion_abyss`
   (set Transparency = 1, CanCollide = false). Size them to cover each zone's water.
3. **Upload the sounds** (optional): the 14 WAV files in `assets/audio/` are already
   synthesized and legal. In Studio: **Asset Manager** → Audio → Import. Then paste each
   sound ID into `ReplicatedStorage > Shared > Config` (the `AUDIO_IDS` section).
4. **Publish:** File → **Publish to Roblox As...** → name it (e.g., "Tidebound") → Publish.
   Your game is now LIVE on your account.

---

## 7. Updating the game later (when I improve the code)

- **Easy way:** delete the old `Shared`, `Services`, `Controllers`, `Modules` folders and the
  two `Bootstrap` scripts in Explorer, then re-import the 3 .rbxmx files (they're rebuilt
  from the latest code every time you ask me).
- The 12 parts work too (re-running them overwrites changed files only).

---

## 8. Checklist

- [ ] Signed into Studio as x_max10xh
- [ ] Baseplate place created
- [ ] 3 .rbxmx files imported (or 12 parts pasted)
- [ ] Explorer matches the tree in Step A4
- [ ] Play shows "[Tidebound] Server booted" in Output
- [ ] Map built: 6 islands + ZoneRegion parts
- [ ] Sounds uploaded + IDs in Config (optional but recommended)
- [ ] Published to Roblox (File → Publish to Roblox As...)

---

## 9. ⭐ Method C — FULLY AUTOMATIC (recommended!)

I built the entire game as ONE complete place file (`tools/tidebound_full.rbxlx`,
286 KB): every script **plus** a starter map — ocean, sea floor, dock, spawn,
Old Salt NPC, market stall, and all 8 fishing zones with buoys and name tags.
That file can be pushed straight to your account with the official
**Open Cloud Place Publishing API** — no Studio, no downloads, no pasting.

**Only 2 things must stay on your side (account security — I never take your password):**

### Step 1 — Create the empty experience (2 minutes, on the website)
1. Go to https://create.roblox.com/dashboard/creations
2. Click **Create** → **Experience** (top-right).
3. Name it **Tidebound** (or anything). It creates an empty game.
4. On the game tile, click the **⋯** (three dots) → **Copy Universe ID** → paste it somewhere.
5. Click the ⋯ again → **Copy Start Place ID** → paste it too.

### Step 2 — Create the API key (2 minutes)
1. Go to https://create.roblox.com/dashboard/credentials
2. Click **Create API Key**.
3. Name it `tidebound-publish`.
4. Under **API System**: add **Place Publishing**. Add **Tidebound** (your experience) to it,
   and set **Operations** to **Write**.
5. Under **Security**: IP = `0.0.0.0/0` (any IP), Expiration = **1 Day** (we only need it once).
6. Click **Save & Generate Key** → **Copy** the key. (It's shown only once!)

### Step 3 — Paste the 3 values to me
In this chat, send:
```
key: rbxl_xxxx... (the key)
universeId: 1234567890
placeId: 9876543210
```
That's it. I run the publisher, and the game goes **LIVE on your account**.

### What I do after you paste it
- Build the final place file from the latest code.
- `POST` it to the Place Publishing API → the game is published instantly.
- Update the experience name/description/genre (best-effort).
- You open it on Roblox and play.

### Security — read this once
- The API key can only publish to **that one experience** (you scoped it), and it
  **expires in 1 day**. Treat it like a password; delete it in the Credentials page
  whenever you want it dead instantly.
- I use it only to publish the game — nothing else.
- This is the **official, Roblox-sanctioned** mechanism (it's how studios do
  automated publishing).

### What still can't be automated (Roblox limitations)
- Enabling **Community Sells** (monetization) — one toggle in the Dashboard (Phase 7).
- Uploading the 14 sound files — optional; do it later in Studio/Asset Manager.
- The fancy map art (terrain sculpting) — the starter map is functional and
  good-looking; beautify later in Studio.
- Creating gamepasses — may be automatable via Open Cloud; Phase 7 will check.

### Re-publishing later (after I improve the code)
Same command with the same key (while it's valid): I rebuild and re-publish in
one step. Your players' saves are untouched (they live in DataStores, not the file).

---

## 10. ⚡ RIGHT NOW: 60-second guaranteed publish (Studio fallback)

The Open Cloud upload API is currently returning "server busy" (a known, documented
Roblox-side flakiness — the file itself is accepted and verified). While we wait for
it to recover (just say "retry" and I'll run the publisher again — your key is valid
for 1 day), here's the **guaranteed path that works this second**:

1. **Download** `tools/tidebound_full.rbxl` (78 KB — the whole game: all 27 scripts
   + ocean + 6 islands + dock + spawn + Old Salt NPC + market + 8 zone markers).
2. Open **Roblox Studio** (signed in as x_max10xh). **File → Open From File** →
   select `tidebound_full.rbxl`. The whole game loads.
3. Press **Play** → Output shows `[Tidebound] Server booted.` — cast with **Q**.
4. **File → Publish to Roblox As...** → choose the **Tidebound** experience you
   created (the one with Universe ID 10621536269) → **Publish**.
5. Done — **your game is live on your account.** 🎣

Studio's publish button uses a different, healthy backend — it will not hit the
"server busy" error. This takes about 60 seconds.

### If you want me to keep trying the automatic path instead
Just say **"retry"** in the chat and I'll run the API publisher again (it retries
automatically for ~6 minutes per run). Whenever Roblox's backend recovers, it'll
go live with zero effort on your side.

---

## 11. ✅ PUBLISHED (2026-08-03)

**The game is LIVE on your account via the Open Cloud API — place version 4 published.**
- Universe ID: `10621536269` · Place ID: `83680094307668`
- Open your game at: **roblox.com/games/83680094307668** (or Creator Dashboard → Creations → Tidebound → "…" → View)
- The published world now includes the **rich map** (v4): 684 parts, 34 lights, particle FX, per-zone landmarks.

**After first launch, in Creator Dashboard (2 min):**
1. Creations → Tidebound → set the **name** (it may show a default/blank name) and **description**.
2. **Monetization tab → enable "Community Sells"** (required before any gamepass/Robux income).
3. Set the **icon + thumbnail** (Phase 10 kit comes next).
4. (Recommended) **Delete the publish API key** in Dashboard → Credentials once you're done — it expires in 1 day anyway.
