# TIDEBOUND — Roblox Studio Install Guide

> **Fastest path (no pasting):** download the 3 files in `tools/rbxmx/` → Studio → sign in as **x_max10xh** → new Baseplate place → right-click **ReplicatedStorage** / **ServerScriptService** / **StarterPlayer > StarterPlayerScripts** → **Insert from File...** → pick each file. Then build the map (~30–60 min) and Publish.
> **Full click-by-click instructions: `docs/INSTALL_GUIDE.md`**
> **Fallback (if import fails):** paste the 12 parts in `tools/installer_parts/` one by one into the Command Bar (tested end-to-end, idempotent).

---

## 1. Create the place
- Roblox Studio → New → **Baseplate** template (or Terrain template).
- Name the place **Tidebound** in Game Settings.

## 2. Install the scripts (3 imports OR 12 pastes)
- **Recommended:** import the three `.rbxmx` models (see `docs/INSTALL_GUIDE.md` §3–4).
- **Fallback:** paste `tools/installer_parts/part_01_of_12.luau` … `part_12_of_12.luau` into the Command Bar in order (each prints `[Installer] Part k/12 complete`).
- Either way you should end up with this tree:
```
ReplicatedStorage/Shared            (Config, Types, Util, Remotes, Data/*)
ServerScriptService/Bootstrap       + ServerScriptService/Services/*  (9 services)
StarterPlayer/StarterPlayerScripts/ Bootstrap (LocalScript) + Controllers/* + Modules/*
```

## 3. Build the map (30–60 min, follows the art doc)
- **Terrain**: create a flat ocean (water at **Y = 0**). Sculpt 6 islands:
  1. `Sunshall Cove` (spawn) — sandy, small dock, market stall, Old Salt NPC.
  2. `Whisper Shallows` — turquoise, seagrass, ~800 studs from spawn.
  3. `The Drop` — deep blue, cliffs, fog, ~1,600 studs.
  4. `Ember Falls` — volcanic rock, red glow parts, waterfall, ~2,400 studs.
  5. `Frostreach` — ice blocks, aurora (emissive parts), ~3,200 studs.
  6. `Abyssal Trench` — near-black water, bioluminescent decals, ~4,200 studs.
- **Region markers** (REQUIRED for fishing): for each zone, insert an anchored, transparent Part
  named exactly `ZoneRegion_sunshall`, `ZoneRegion_whisper`, `ZoneRegion_drop`,
  `ZoneRegion_ember`, `ZoneRegion_frost`, `ZoneRegion_abyss`,
  `ZoneRegion_hidden_isles`, `ZoneRegion_sunken_grotto`.
  Size: cover the fishable water of that zone. **CanCollide = false, transparency = 1**.
- Hidden zones: behind the waterfall (Ember) and inside a sea cave (The Drop).
- Spawn location: on the Sunshall pier, facing the water.
- Lighting: default. (Zone ambience can be tuned later in the client.)

## 4. Upload audio (optional but strongly recommended)
1. Run `python3 tools/generate_audio.py` (or grab the WAVs from `assets/audio/`).
2. In Studio: **Asset Manager → Audio → Import** each WAV.
3. Copy each asset ID and paste into `Config.AUDIO_IDS` in ReplicatedStorage → Shared → Config (e.g. `ui_click = 123456789`).
4. While IDs are 0 the game is silent-but-functional (by design).

## 5. Configure game settings
- **Creator Dashboard → Place** → Monetization: `Community Sells` = ON (required for gamepasses/dev products).
- Experience type: fishing/casual. Devices: all. Genre: **Adventure** (search category).
- Max players: 20 (perf-tuned; raise later).

## 6. Monetization items (Phase 7)
- Create the gamepasses/products listed in `Config.luau` (`GAMEPASS_IDS` / `PRODUCT_IDS`) in Creator Dashboard, paste the numeric IDs.

## 7. Test & publish
- **Play** (F5): you should spawn on the pier. Cast with **Q** (hold to charge) or the on-screen **CAST** button.
- First catch → XP bar fills, coin popups, bestiary entry. Type `/console` behaviors are not needed — everything is in the HUD.
- **File → Publish to Roblox As…** → it's live under your account. Testers: set the place to Private until launch.

## 8. Update flow (after any source change here)
Re-copy `studio_installer.luau` into the Command Bar → all changed scripts update in place. Rerun `tools/build_smoke_harness.py && tools/luau-bin/luau /tmp/harness.luau` locally to verify before updating Studio.

## File tree (this repo)
```
tidebound/
├── docs/                  (market research, GDD, economy, architecture, status)
├── assets/audio/          (14 synthesized SFX WAVs — original, legal)
├── src/                   (Roblox source; maps 1:1 into Studio)
└── tools/
    ├── studio_installer.luau    ← paste into Studio Command Bar
    ├── build_smoke_harness.py   ← test harness generator
    ├── sim_tests.luau           ← deep simulation tests
    ├── generate_audio.py        ← SFX synthesizer (original sounds)
    ├── generate_installer.py    ← rebuilds studio_installer.luau
    └── luau-bin/                ← Luau CLI toolchain (for local tests)
```
