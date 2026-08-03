# TIDEBOUND — Project Status & Phase Tracker
*Living document — updated at the end of every phase. Last update: 2026-08-02*

## The Game
**Tidebound** — fishing collection RPG. Cast → catch → sell → upgrade → fill the bestiary → chase shinies → race the storms → win the weekly contest.

## Phase Tracker

| Phase | Deliverable | Status | Notes |
|---|---|---|---|
| 1. Planning | Market research, 20 ideas, decision | ✅ DONE | `docs/01_market_research.md` |
| 2. Architecture | Tech architecture + code standards | ✅ DONE | `docs/04_architecture.md` |
| 3. Core gameplay | All server services + data catalogs | ✅ DONE | 18 modules, tested (see below) |
| 4. UI | Client controllers: HUD, cast/reel, shop, bestiary, quests | ✅ DONE | 9 client modules + Bootstrap.client, contract-tested |
| 5. Economy | Quest/streak/achievement tuning + live data checks | ⏳ NEXT | Server logic done; live tuning after first playtests |
| 6. Saving | DataStore hardening, migration, error handling | ⏳ NEXT | v1 done; hardening list in architecture doc §9 |
| 7. Monetization | Gamepass/Product IDs + shop UI + receipt testing | ⏳ NEXT | Server handlers done; needs Creator Dashboard IDs |
| 8. Optimization | Perf/memory/network audit + playtest | ⏳ NEXT | |
| 9. Testing | Full exploit/bug/balance test plan + execution | ⏳ NEXT | Smoke harness exists; expand |
| 10. Publishing | Icon, thumbnail, logo, description, tags, marketing, 12-update roadmap | 🚧 PARTIAL | **Game LIVE (v4) via Open Cloud API 2026-08-03**; marketing kit still to come |

## Codebase (Phase 4 — all tested)
```
tidebound/src/
├── ReplicatedStorage/Shared/
│   ├── Config.luau           — every tunable constant (incl. AUDIO_IDS, UI constants)
│   ├── Types.luau            — shared type definitions
│   ├── Util.luau             — pure helpers
│   ├── Remotes.luau          — single C2S + single S2C RemoteEvent
│   └── Data/                 — FishCatalog (53 fish), RodCatalog (8), ZoneCatalog (8), QuestCatalog (8 daily + 5 weekly + 21 achievements)
├── ServerScriptService/
│   ├── Bootstrap.server.luau — service loader + message router
│   └── Services/             — Security, Data, Economy, Inventory, Quest, Event, Leaderboard, Fishing, Shop
└── StarterPlayer/StarterPlayerScripts/
    ├── Bootstrap.client.luau — client loader + dispatcher (LocalScript)
    ├── Controllers/          — Audio, Cast (charge/reel minigame), UI (HUD/banners/catch card/feed), Menu (shop/bestiary/bag/quests)
    └── Modules/              — Theme, UiKit, ClientState (server-state cache), FishVisuals (procedural fish)
```

## Assets
- `assets/audio/` — 14 synthesized original SFX (tools/generate_audio.py). Upload in Studio → paste IDs into Config.AUDIO_IDS.

## Studio bridge (how this becomes YOUR game)
- `tools/studio_installer.luau` — paste into Studio Command Bar → creates the full script tree. See `src/README.md`. Then build the map, publish under your account.

## Test Results (2026-08-02, Luau CLI + stub harness)
- 27/27 modules compile and load (9 server services + Bootstrap.server + 8 client modules + Bootstrap.client)
- 42 smoke checks PASS (catalog sanity, rarity weights = 1000, rod ladder, zone fish coverage,
  ClientState apply tests, FishVisuals build test, **15 server→client contract checks**)
- Deep simulation PASS (quests, streaks, achievements, 90k RNG picks)
- Simulation PASS:
  - Abyss mythic rate ≈ 0.47% with luck (sane)
  - Old One locked pre-trigger; ≈ 2.0% after 50 deep fish
  - Storm fish appear during storms; universal storm fish included
  - Squid bait boosts squid-family odds (1.66×)
  - Luck stack (rod+charm+golden+night = 90%) boosts epic+ ~1.72× — real but bounded (< 2.5× cap)
  - Daily quest completion, streak 1→2, rewards, achievements, claims all verified

## Bugs found & fixed during Phase 3/4 review
1. ~50 generic `for` loops missing `pairs()`/`ipairs()` → would crash at runtime (fixed, verified)
2. `FishingService:StartBite` nil-order crash on cleanup race (fixed)
3. `DataService` local declared after use in closures (fixed)
4. **Design flaw**: The Old One was in the normal abyss loot table → now secret-trigger only (verified)
5. Existing players at boot missed profile-ready callbacks → deferred load with guard (fixed)
6. **Server Bootstrap crash**: `require(script.Services[name])` looked INSIDE the script → `script.Parent.Services` (would crash on boot in Studio)
7. **QuestService crash**: bare `for ... in { }` loop — invalid Luau → `ipairs` (would crash on streak claim)
8. **Client crash (harness-caught, would hit production)**: `ctx.RegisterHandler` defined with implicit `self` but called with dot syntax → every controller Init would crash. Fixed.
9. **Luau gotcha (harness-caught)**: a `local` referencing itself inside its own initializer is nil in Luau (unlike Lua) → ctx method attached after table declaration.
10. Contract tests: all 15 server→client message types verified consumed client-side.

## Next Turn (Phase 5+)
- Phase 5: economy live-tuning playbook (needs real playtest data)
- Phase 6: save hardening (session locks, migration tests)
- Phase 7: monetization wiring (Creator Dashboard IDs + receipt testing)
- Phase 8: optimization audit
- Phase 9: full exploit/balance test plan
- Phase 10: publishing kit (AI-generated icon/logo/thumbnails + marketing + 12-update roadmap + revenue model tables)

## Reference docs
- `docs/01_market_research.md` — research + 20 ideas + decision
- `docs/02_game_design.md` — full GDD
- `docs/03_economy_monetization.md` — economy tables, pricing, revenue model
- `docs/04_architecture.md` — architecture, security, standards
- `tools/build_smoke_harness.py` — regenerates the test harness (`python3 tools/build_smoke_harness.py && luau /tmp/harness.luau`)

## 🚀 LAUNCH STATUS (2026-08-03)
- **Published to account x_max10xh via Open Cloud Place Publishing API** — v4 then **v5 (fixed)**.
  v5 fixes: dock/spawn/market/NPCs raised ABOVE water (was underwater = unplayable),
  UI crash bug (nil `self` in shop/bestiary/bag/quests callbacks — 18 refs fixed),
  added TravelService (fast travel via 🗺 Map button), AmbienceService (bobbing buoys +
  orbiting gulls), Terrain instance, sand shelf + island bases, SellAll no longer
  sells shinies, NumberSequence keypoint safety, first-catch tutorial hint.
  29 scripts now. All 42 harness checks + simulations PASS.
  Universe `10621536269` · Place `83680094307668`.
- **Rich map included in v4**: 684 parts, 34 lights, 4 particle FX, 10 billboards —
  detailed dock (railings/lanterns/crates/rowboat), beach + palms + campfire + lighthouse,
  underwater coral/kelp, route buoys every 300 studs, and per-zone landmarks:
  Whisper seagrass fields + rock arch, The Drop cliffs + fog + shipwreck, Ember volcano +
  lava + waterfall, Frost icebergs + aurora + ice crystals, Abyss bioluminescence +
  whale skeleton + treasure, Hidden Isle (waterfall + chest), Sunken Grotto (crystal cave).
- Verified: 27/27 scripts at exact paths, 8 zone regions, spawn present, all FX types decode.

## 🚀 v6 LAUNCH (2026-08-03) — polish milestone
- **Published v6** (place version 6): 30 scripts, 120.5 KB place file.
- **New this cycle (studio directive — no placeholders):**
  1. **Audio out of the box** — AudioController now falls back to Roblox's built-in
     client sounds (impact_water, Kerplunk, clickfast, electronicpingshort) so the
     game is NO LONGER SILENT; custom WAVs override when IDs are configured.
  2. **Pearl shop (cosmetics)** — CosmeticsCatalog (13 items: bobbers, trails,
     auras, rod grips, name colors); buy with pearls → equips immediately; bobber
     colors + trails visible in-game, catch auras, rod grip recolors the held rod.
  3. **Robux Store panel** — gamepass + dev-product prompts (renders when IDs are
     configured in Creator Dashboard).
  4. **Visible fishing rod** — server attaches a FishingRod Tool to every player,
     recolored per equipped rod / grip.
  5. **Golden spots** — periodic shimmer locations (+20% luck, +10% value) with
     particles + banner.
  6. **Achievements panel** (21, locked/unlocked + rewards), **Contest panel**
     (weekly top-10 leaderboard via GetContestTop), **Profile panel** (stats +
     title equip), **Bag filters/sort**, **purchase-equips-immediately** UX.
- **Testing:** 30/30 modules load, 42 smoke checks + sim tests PASS (incl. cosmetic
  purchase/equip/guard, contest top, title equip). Installer parts (13) verified
  end-to-end: 35 instances, 0 failures.
