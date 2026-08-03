# TIDEBOUND — Technical Architecture & Code Standards
**Phase 2 Deliverable | Luau, --!strict everywhere, modular services**

> **Architecture law: the server is the only source of truth.** The client is a fancy remote control. Every economy mutation, RNG roll, and inventory change happens on the server and is validated against the player's real state.

---

## 1. Folder Structure (mirrors Roblox Studio tree)

```
Tidebound.rbxl (place)
├── ReplicatedStorage/
│   ├── TideboundAssets/            (models, decals, sounds — builder place)
│   └── Shared/                     (REQUIRE-ABLE BY BOTH SIDES)
│       ├── Config.luau             (all tunable constants — one file to rule them)
│       ├── Types.luau              (shared type definitions)
│       ├── Util.luau               (pure functions: clamp, format, weighted pick, deep copy)
│       ├── Remotes.luau            (remote registry — single C2S + single S2C event)
│       └── Data/
│           ├── FishCatalog.luau    (fish definitions — the content DB)
│           ├── RodCatalog.luau     (rod definitions)
│           ├── ZoneCatalog.luau    (zone definitions + region markers)
│           └── QuestCatalog.luau   (daily/weekly quest templates)
├── ServerScriptService/
│   ├── Bootstrap.server.luau       (service loader, lifecycle, shutdown)
│   └── Services/
│       ├── DataService.server.luau      (profiles, DataStore, autosave, sessions)
│       ├── EconomyService.server.luau   (coins/pearls/XP — single mutation choke point)
│       ├── InventoryService.server.luau (fish inventory, bestiary unlocks)
│       ├── FishingService.server.luau   (cast/bite/reel state machine — the heart)
│       ├── QuestService.server.luau     (daily/weekly/streak/achievements)
│       ├── LeaderboardService.server.luau (leaderstats + weekly contest + catch feed)
│       ├── EventService.server.luau     (day/night cycle + storm scheduler)
│       ├── ShopService.server.luau      (gamepasses, dev products, ProcessReceipt)
│       └── SecurityService.server.luau  (rate limits, validation, flags, kicks)
└── StarterPlayer/
    └── StarterPlayerScripts/
        ├── Bootstrap.client.luau    (client service loader + message dispatcher, LocalScript)
        ├── Controllers/             (ModuleScripts, required by Bootstrap.client)
        │   ├── AudioController.luau      (lazy Sound player; IDs from Config.AUDIO_IDS)
        │   ├── CastController.luau       (cast charge/release, reel hold, auto-reel, mobile buttons)
        │   ├── UIController.luau         (HUD: coins/pearls/XP bar, banners, feed, catch card)
        │   └── MenuUIController.luau     (shop, bestiary, inventory, quests panels)
        └── Modules/                 (ModuleScripts, client-only helpers)
            ├── Theme.luau               (UI colors/fonts — single style source)
            ├── UiKit.luau               (frame/label/button/scroll factories — no duplicated UI code)
            ├── ClientState.luau         (client cache of server state + Send() choke point)
            └── FishVisuals.luau         (procedural fish models — no external 3D assets)
```

**Client rules:** controllers are ModuleScripts (require-able by each other and by tests); the only LocalScript is Bootstrap.client. The client NEVER computes game values it doesn't own — it renders server state from ClientState and sends intents through ClientState:Send. Message dispatch is fan-out: every server message is applied to ClientState, then every registered handler runs (multiple handlers per type are allowed and expected, e.g. CatchResult → CastController hides the reel UI, UIController shows the card).

**Why one C2S + one S2C RemoteEvent?** Remote proliferation is a security anti-pattern (each remote is an unvalidated door). We use a single `RemoteEvent` per direction with a message envelope `{type: string, payload: any}` and a server-side **router** that validates type, payload shape, and rate limit before dispatch. New features = new message types in one file, not new remotes.

---

## 2. Module Lifecycle (service pattern)

Every service is a ModuleScript exposing:

```lua
local Service = {}
Service.Name = "FishingService"

function Service:Init(context) ... end   -- require dependencies, build state, no side effects
function Service:Start() ... end          -- connect events, start loops, take over
function Service:Stop() ... end           -- graceful shutdown (save everything)

return Service
```

`Bootstrap.server.luau` runs an **ordered dependency list**:
1. SecurityService → 2. DataService → 3. EconomyService → 4. InventoryService → 5. QuestService → 6. FishingService → 7. EventService → 8. LeaderboardService → 9. ShopService.
Init all → Start all → hook `game:BindToClose` → save-all → shutdown.

Services never reference each other directly at require-time (circular dependency risk); they resolve dependencies in `:Init` via the context table. Shared *data* lives in `ReplicatedStorage.Shared` (read-only catalogs); shared *state* never leaves the server.

---

## 3. Remote Protocol (message envelope)

```
Client → Server:  { type = "Cast",      payload = { dir = Vector3, power = 0..1 } }
Client → Server:  { type = "ReelHold",  payload = { held = true } }       -- ≤10/sec
Client → Server:  { type = "SellFish",  payload = { ids = {...} } }
Client → Server:  { type = "SellAll",   payload = { maxRarity = "rare" } }
Client → Server:  { type = "BuyRod",    payload = { rodId = "storm" } }
Client → Server:  { type = "BuyBait",   payload = { baitId, count } }
Client → Server:  { type = "ClaimDaily", payload = {} }
Client → Server:  { type = "RerollQuest", payload = { slot = 1 } }
Client → Server:  { type = "PurchasePass", payload = { passId } }          -- MarketplaceService path

Server → Client:  { type = "StateSync",   payload = { coins, pearls, xp, level, ... } }
Server → Client:  { type = "CatchResult", payload = { fish, shiny, weightKg, value, ... } }
Server → Client:  { type = "Bite",        payload = { bobberId, strength } }
Server → Client:  { type = "ReelState",   payload = { progress, tension, over } }  -- ≤6/sec
Server → Client:  { type = "EventBanner", payload = { kind = "storm"|"night"|"mythic", text } }
Server → Client:  { type = "BestiaryUpdate", payload = { fishId, shiny } }
Server → Client:  { type = "QuestUpdate", ... } { type = "FeedMessage", ... } ...
```

**RATE LIMITS (SecurityService, token bucket per player per type):** Cast 1/2s, ReelHold 10/s, SellFish 5/s, Purchase 1/3s, Claim 1/10s. Violations → warn → flag → kick at 10× threshold. All timestamps via `os.clock()` server-side.

---

## 4. DataStore Design (save/load — no data loss)

```
Key: "TD_Save_v1_" .. userId          -- versioned for migrations
Value: JSON blob (compact), ~2–6 KB:
{
  v = 1,                              -- schema version
  coins, pearls, xp, level, streak, streakLastDay,
  rods = { owned = {...}, equipped },
  baits = { worm = n, shrimp = n, squid = n, golden = n },
  inventory = { {id, fishId, weight, shiny, caughtAt} , ... },  -- capped 200
  bestiary = { [fishId] = { caught = n, shiny = false, maxWeight = kg } },
  quests = { daily = {...}, weekly = {...}, lastDailyUTC },
  achievements = {...}, titles = {...},
  stats = { totalCatch, totalCoins, stormFish, nightFish, deepFish, ... },
  cosmetics = { bobber = id, trail = id, aura = id, rodSkin = id, nameColor },
  flags = { tutorialDone, chests = {...}, prestige = 0 }
}
```

**Rules:**
- **Load**: `GetAsync` on join, pcall-wrapped, 3 retries, default profile on failure (log). While loading, player is in a safe "loading" state (frozen, no remote processing).
- **Save triggers**: every 90s autosave (dirty flag), on `PlayerRemoving` (fire-and-forget with retry), on `BindToClose` (all profiles), after major grants (purchase, contest reward).
- **Save method**: `SetAsync` of whole blob (profiles are small; full-write avoids merge conflicts). Retry with backoff (1s, 5s, 15s). On persistent failure: warn, keep in-memory, retry next cycle, log to a server log.
- **Session lock**: in-memory lock map (userId → serverId, timestamp). If a player rejoins while locked (crashed server case), we allow overwrite after 60s stale. For v1 DAU this is sufficient; PlayerDataStore-style locking is a Phase 6 hardening item.
- **Data hygiene**: JSON-serialize with a strict whitelist (no NaN/Infinity — serialize guards), integer checks, size cap assert (if blob > 8KB → trim inventory oldest commons, log anomaly).
- **Migration**: `v` field + `Migrate()` chain — v1→v2 etc. Never write without reading schema.

---

## 5. Anti-Exploit Design (defense in depth)

| Layer | Mechanism |
|---|---|
| 1. No client trust | All RNG server-side; client payloads are *intents* only; server re-derives state from its own truth |
| 2. Input validation | Every message: type whitelist, payload type-check, numeric range checks (no NaN/Inf/negative), string length caps |
| 3. Rate limiting | Token buckets per player per message type (see §3) |
| 4. Cooldowns & state machine | Cast requires valid state (not casting, cooldown elapsed, alive, inside a fishing region); reel only while a catch session is open for that player |
| 5. Position validation | Server checks player position against zone region bounds at cast-time and catch-time (anti-teleport anti-exploit: catch requires proximity to own bobber) |
| 6. Economy anomaly detection | EconomyService flags transactions >10× expected; max coins/pearls caps; negative-balance impossible by construction (single choke point) |
| 7. Server logs | Every purchase, every mythic catch, every flag → HttpService-less local log + optional webhook (Phase 6) |
| 8. No trust in client "achievements" | Achievements derive from server-side stats counters only |
| 9. Purchase receipt idempotency | ProcessReceipt: receipt cache set; grant exactly once even on duplicate receipts |
| 10. Kick policy | 10× rate violation or 3 validation failures → kick with reason; repeated joins flagged |

---

## 6. Performance / Memory / Networking Optimization

- **Networking**: no per-frame server→client spam; state sync on change (dirty-flag coalescing, max 3/s per player); reel state 6/s; catch feed throttled to 2 messages/5s globally; storm/night announcements once.
- **Server**: services use `task.spawn` + `task.wait` (never `wait()`); no per-player loops when idle (FishingService is event-driven); single physics-dependent piece per player (bobber) — no unneeded constraints; fish are never physical parts — they are *data* (visuals are client-side procedural models). This is the single biggest perf win: **zero fish models on the server.**
- **Client**: procedural fish models built once per species and cached (reused across catches); UI built in code (no giant StarterGui bloat), toggled by state; pooling for particles; `RenderStepped` work minimal (only reel bar animation).
- **Memory**: catalogs are immutable tables (never deep-copied per player); bestiary/inventory mutate in place on the server profile only; no string concatenation in hot loops.
- **Scalability**: stateless services (state lives in per-player profile objects), so future vertical split (multiple servers) only requires moving profiles — the event system (storm/night) is server-local by design, which keeps cross-server consistency trivial at launch scale. Place can grow to 30+ players without tuning.

---

## 7. Code Standards (every file, no exceptions)

1. `--!strict` on every module; explicit type annotations on all functions and exported tables.
2. Header comment: file purpose, author (AI-assisted), last-touched date, dependencies.
3. Naming: `camelCase` locals/functions, `PascalCase` types/modules, `SCREAMING_SNAKE` constants. Booleans read as questions (`isCasting`, `hasCharm`).
4. No magic numbers in logic — everything in `Config.luau` or a catalog. Balance tuning = config edit, zero code changes.
5. No duplicated logic — shared pure functions in `Util.luau` (weighted pick, format numbers, roll weight, etc.).
6. Early returns > nested ifs; functions < 40 lines; services < 400 lines (split if exceeded).
7. `pcall` around every DataStore and MarketplaceService call; errors logged with context, never silent.
8. No `game:GetService()` inside hot functions — cache at module top.
9. Security: no `loadstring`, no `HttpService` in release (Phase 6 adds opt-in analytics), no admin commands.
10. Comments explain *why*, not *what*. AI-generated code is reviewed against these standards before it ships.

---

## 8. What the Builder (human) must do in Studio

The code assumes a simple scene. Builder checklist (in `src/README.md`):
1. Create terrain ocean, sculpt 6 islands per zone art doc, place region markers named `Zone_<id>_Region` (Part, transparent, anchored).
2. Place spawn point + Old Salt NPC + market stall + pier showcase spots.
3. Import AI-generated decals (fish textures are optional — procedural fish use solid colors + emissive accents; only UI art, icon, logo need generated images).
4. Create one folder per src/ tree; paste modules; run. The game is fully playable with default starter terrain as a fallback (regions are config-optional).

---

## 9. Phase 6 Hardening List (post-launch)
- PlayerDataStore migration / real session locks
- Analytics events (analyticsService.ReportStats or DataStore rollups) for economy tuning
- Webhook-based server logs (Discord) for anomaly paging
- Backfill scripts for contest/leaderboard data
- Save-size trimmer + oldest-first inventory pruning for 200+ fish accounts
