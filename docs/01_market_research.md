# TIDEBOUND — Market Research & Game Strategy
**Phase 1 Deliverable | Studio: One developer + AI tooling | Date: 2026-08-02**

> Principle: *The best business is not the biggest game. It is the game with the best ratio of Profit / Development Time.*

---

## 1. TL;DR (Read this if you read nothing else)

1. **Roblox is the right platform**: ~100M+ DAU platform-wide; casual "cozy/collection" genres are the fastest-growing category in 2026 (Grow a Garden, Fish It!, Fisch).
2. **Fishing/collection is the highest-validated genre for a solo dev**: Fisch (built by one 19-year-old) reached 1.2M peak CCU and ~$400K/month including brand deals (LEGO, Walmart); "Fish It!" (an idle fishing sim) still holds ~110K concurrent players in mid-2026 — **three years after the genre "peaked."**
3. **The #1 killer of Roblox games is not competition — it's a bad first 60 seconds.** FTUE failures (no XP bar, silent gameplay, expensive first upgrade, text-heavy tutorials, unclear spawn, no progression feel) each cost ~7.5% Day-1 retention. This is 100% under our control.
4. **Simulator/collection games have the best retention of any casual genre**: D1 32% / D7 14% / D30 6.2% (2026 benchmarks). Retention is what the Roblox algorithm rewards.
5. **Monetization math (2026)**: 1–3% conversion is normal (2–3% for simulators); 70% of a gamepass sale reaches you after the 30% fee; DevEx ≈ $0.0038/Robux. Gamepasses should be 60–70% of monetization surface, developer products 30–40%.
6. **The pick: "Tidebound" — a server-driven fishing collection RPG** with night cycles, storm events, shiny variants, and a bestiary. Highest profit/time ratio of all 20 ideas evaluated. Details in §6.

---

## 2. Platform Landscape (2026)

| Fact | Data | Source |
|---|---|---|
| Roblox platform scale | ~100–145M DAU, ~380M MAU | demandsage.com (May 2026), Bloomberg (Mar 2026) |
| Top concurrent games | Brookhaven ~647K, MM2 ~530K, Grow a Garden ~485K, Steal a Brainrot ~329K, Adopt Me ~262K, Blox Fruits ~234K, RIVALS ~232K | robloxgames.org (Jul 2026) |
| Biggest 2025–26 breakout | **Grow a Garden** — cozy idle sim, fastest-growing new game in Roblox history (1.0–1.2M CCU at peak) | studiokrew.com (May 2026) |
| Fishing genre proof | **Fisch**: 4.5B+ visits, 1.2M peak CCU, ~$400K/month, brand deals with LEGO & Walmart | fischipedia.org, Bloomberg (Mar 2026) |
| Fishing genre still alive | **Fish It!** (idle fishing): ~110–117K CCU in mid-2026; **Fisch** still ~50K CCU | levelupplay.my, ejaw.net (Mar 2026) |
| DevEx rate | $0.0038/Robux base (Sept 2025 update), 30% marketplace fee on all sales | generalistprogrammer.com (Jun 2026) |

**Interpretation:**
- The platform rewards *retention-first* design; the Discover algorithm aggressively promotes games with strong D1/D7/D30 ([bloxg.com](https://bloxg.com/guides/roblox-player-retention)).
- Cozy/collection/idle genres are on a multi-year upswing — this is a structural trend (casual mobile audience), not a fad like "brainrot" games.
- A solo developer can absolutely win here: Fisch's creator built it alone from a trailer park in Nova Scotia.

---

## 3. Why Most Roblox Games Fail (and what we will do differently)

From community studies + analytics (r/robloxgamedev 2026, bloxg.com, GameAnalytics):

| # | Failure cause | Our countermeasure |
|---|---|---|
| 1 | **Bad FTUE** — #1 churn driver: players don't know what to do in the first 2 minutes | Visual tutorial (glowing markers + giant "!" NPC), first catch within 30 seconds, no walls of text |
| 2 | **No visible progress** — no XP bar on HUD | Permanent XP bar + level-up burst + catch banners |
| 3 | **Silent gameplay** — no sound/particle feedback on actions | Sound + coin popups on every sell/catch/level-up |
| 4 | **First upgrade too expensive** — feels grindy immediately | First rod upgrade costs ~5 minutes of play (not 30) |
| 5 | **Content stagnation** — no updates in 2–4 weeks → predictable erosion | 12-update live-ops roadmap (§8 in publishing doc) |
| 6 | **Unclear spawn / no objective** | Spawn facing the fishing dock, quest tracker always visible |
| 7 | **Exploit-driven economy collapse** | Server-authoritative everything; no client trust (see architecture doc) |
| 8 | **Monetization before retention** — paywalls in the first session | No purchase prompts until minute 3; monetization is QoL/cosmetics only |

**The 6 FTUE elements are non-negotiable for us.** Data: a game with 6/6 elements sees ~40%+ D1 vs ~15% for 2/6. We design for 6/6.

---

## 4. Monetization Economics (2026 figures — read twice)

- **Fee chain**: Player pays for 1,000 Robux → gamepass priced at 1,000 R$ → we receive 700 R$ (30% fee) → DevEx at $0.0038 → **~$2.66 net**.
- **Conversion**: 1–3% of players buy anything (2–3% for simulators; >3% = excellent). Social/roleplay games are lower (1–2%).
- **Revenue per visit benchmark**: well-monetized games earn 3–8 Robux per visit.
- **Mix**: Gamepasses ≈ 60–70% of revenue surface (one-time, aspirational, converts first-time spenders); Developer Products ≈ 30–40% (recurring from engaged players).
- **Premium payouts**: players with Roblox Premium generate higher payouts on their engagement — an upside we design for but don't depend on.
- **80% of lifetime revenue comes from players who survive the first week** — retention IS the revenue strategy.

**Pricing ladder we will use** (per rolearn.dev 2026 benchmarks): Entry 25–75 R$ (impulse, 4–8% conv among engaged), Core 99–249 R$ (2–5%), Premium 249–499 R$ (1–3%), VIP 499–999 R$ (0.5–2%). We price on *net* thinking, but display standard prices.

---

## 5. Retention Benchmarks We're Targeting

| Metric | Sim genre average (2026) | Our target (design for) | How |
|---|---|---|---|
| D1 | 32% | **38–42%** | 6/6 FTUE elements, first catch <30s, visible XP |
| D7 | 14% | **16–20%** | Daily quests, streak rewards, night cycle novelty |
| D30 | 6.2% | **7–9%** | Storm events, weekly contest, bestiary %, update cadence |
| Session length | ~35 min (sims) | 20–30 min | One-more-cast loop, event hooks ("storm in 3 min!") |

We measure everything in Creator Hub Analytics and iterate weekly.

---

## 6. The Decision Framework

Scored on **Profit / Development Time**, weighted: monetization potential × retention potential × viral potential ÷ (dev complexity × asset difficulty). AI-implementability is a hard filter (everything must be buildable with AI-generated code + legally clean assets).

---

## 7. 20 Ranked Game Ideas

### Ranking table (1 = best ratio)

| # | Idea | Diff (1-10) | Dev time | Uniqueness | Viral | Retention | Monet. | Scalability | AI impl. | 1st-mo revenue est.* | Why keep playing |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **1** | **Fishing collection RPG (Tidebound)** | 4 | 6–8 wks | 6/10 | 8 | 9 | 8 | 9 | Easy | 1–10K R$ | Bestiary %, shiny hunt, storm events, weekly contest |
| 2 | Cozy garden idle sim | 5 | 8 wks | 4 | 7 | 9 | 8 | 8 | Medium | 1–5K R$ | Daily harvest ritual, decoration |
| 3 | Mining/forging sim (The Forge-like) | 5 | 7 wks | 5 | 6 | 8 | 8 | 8 | Medium | 1–4K R$ | Crafting ladder, market |
| 4 | Pet collection simulator | 7 | 10 wks | 3 | 7 | 9 | 9 | 9 | Hard | 1–5K R$ | Pet rarity chase, trading |
| 5 | Steal-and-defend meme tycoon | 5 | 6 wks | 4 | 9 | 7 | 7 | 6 | Medium | 2–8K R$ | Social stealing, meme moments |
| 6 | Co-op horror escape (Doors-like) | 7 | 10 wks | 3 | 9 | 7 | 7 | 7 | Hard | 1–6K R$ | Party runs, scare clips |
| 7 | Diving/ocean exploration sim | 6 | 8 wks | 7 | 7 | 7 | 6 | 8 | Hard | 0.5–3K R$ | Discovery, depth fear |
| 8 | Restaurant/cooking tycoon | 6 | 8 wks | 4 | 5 | 8 | 7 | 7 | Medium | 0.5–3K R$ | Menu expansion, service loop |
| 9 | Classic tycoon | 3 | 4 wks | 2 | 4 | 6 | 6 | 5 | Easy | 0.2–2K R$ | Numbers go up |
| 10 | Obby with economy + checkpoints | 3 | 4 wks | 3 | 5 | 5 | 5 | 5 | Easy | 0.2–1.5K R$ | Speedrun, cosmetics |
| 11 | Tower defense | 6 | 8 wks | 4 | 5 | 7 | 7 | 8 | Medium | 0.5–3K R$ | Build variety, waves |
| 12 | Racing/car sim | 8 | 12 wks | 4 | 6 | 6 | 7 | 7 | Hard | 0.5–3K R$ | Garage collection |
| 13 | Social hangout/roleplay city | 9 | 16 wks | 3 | 6 | 8 | 7 | 8 | Hard | 1–5K R$ | Social identity |
| 14 | Mobile-first FPS (Rivals-like) | 9 | 16 wks | 4 | 8 | 7 | 8 | 8 | Very hard | 1–5K R$ | Ranked grind — but needs netcode we can't AI-build reliably |
| 15 | Anime fighter | 8 | 12 wks | 3 | 8 | 7 | 8 | 7 | Hard | 1–4K R$ | **REJECTED: IP/copyright risk + needs combat anims we can't AI-generate legally** |
| 16 | Battle royale | 9 | 14 wks | 3 | 7 | 6 | 7 | 6 | Very hard | 0.5–3K R$ | **REJECTED: matchmaking + netcode complexity** |
| 17 | Rhythm game | 6 | 8 wks | 5 | 7 | 7 | 5 | 6 | Hard | 0.2–2K R$ | **REJECTED: music licensing problem (no copyrighted audio)** |
| 18 | RNG/luck game (Sol's RNG-like) | 3 | 5 wks | 5 | 9 | 8 | 7 | 6 | Easy | 1–6K R$ | **REJECTED: simulated gambling policy risk for minors — Roblox has cracked down; not worth account risk** |
| 19 | "Brainrot" meme game | 2 | 3 wks | 3 | 9 | 4 | 5 | 3 | Easy | 0.5–3K R$ | **REJECTED: fad economics — content exhaustion in weeks, zero long-term value** |
| 20 | Party/trivia social game | 4 | 6 wks | 6 | 6 | 6 | 4 | 5 | Medium | 0.2–1K R$ | **REJECTED: weak monetization ceiling** |

*First-month revenue estimate: net Robux earned, range from pessimistic to optimistic at realistic marketing effort (not luck-based viral blowup). At 2026 DevEx: 1K R$ ≈ $2.66 net. Revenue in month 1 is primarily a *validation* metric; the compounding value is the retained player base.

### Why the top contenders scored the way they did

- **#1 Fishing collection RPG — WINNER.** Detailed in §8. The single best combination of: proven genre demand (Fisch, Fish It!), minimal 3D asset requirements (water + procedural fish = AI-friendly), simple server logic (no physics combat, no matchmaking, no pathfinding AI), naturally viral rare-catch moments, best-in-class retention loops (collection), and QoL/cosmetic monetization that never feels pay-to-win.
- **#2 Cozy garden idle sim** — validated by Grow a Garden's explosion, but that game now *owns* the niche; entering it is a direct fight against a 1M-CCU incumbent with a huge studio behind it. Also needs hundreds of plant/decoration assets.
- **#3 Mining/forging** — solid, but The Forge already occupies the niche; fishing has more emotional range (rare catch dopamine) than mining for clips.
- **#4 Pet simulator** — proven economics but asset-heavy (hundreds of pets needed at launch to feel alive) and brutally saturated (Adopt Me, PS99, dozens of clones).
- **#5 Meme tycoon** — strong viral ceiling (Steal a Brainrot hit the all-time CCU record) but relies on riding meme waves that decay in weeks; our game must be built to last 12+ months.
- **#6 Co-op horror** — high ceiling, but AI-generated 3D horror environments are the hardest thing on this list to make feel genuinely scary; audio is 80% of horror and we can't license copyrighted audio.
- **#14 FPS** — RIVALS proved the ceiling, but competitive netcode + hit registration + animation quality is exactly what AI assistance is *worst* at. Rejected on engineering risk.

---

## 8. THE WINNER: "Tidebound" — Fishing Collection RPG

### Why this game, precisely

1. **Demand is proven twice over**: Fisch (premium active-fishing RPG) AND Fish It! (idle fishing) both hold massive audiences in 2026. The genre has a structural audience of casual + mobile players who love collection loops. We are not creating a market; we are entering one with a differentiated product.
2. **Differentiation is achievable without scope creep**: Fisch = open-world exploration + many systems. Fish It! = idle. **Tidebound = tight, event-driven fishing**: server-wide storm events, day/night cycle, shiny variants, fabled boss fish with a tug minigame, weekly catch contests. These are *cheap to build* (timers, tables, one minigame) and create *screenshot-worthy moments* — the exact fuel TikTok/Shorts need.
3. **Assets are the #1 solo-dev killer. Fishing is the least-asset-dependent genre in gaming.** Water is a Roblox material. Islands = terrain sculpting. Fish = procedural parts (body + tail + fins) tinted per species — zero external 3D modeling. Rods = 3–4 parts + texture decals. All textures = AI-generated images applied as decals (legal, original). This collapses dev time dramatically.
4. **Server logic is simple and robust**: no hitboxes, no pathfinding, no matchmaking. Cast → roll → minigame → reward. This is exactly the kind of deterministic state machine AI writes well and we can secure against exploits.
5. **Retention systems map 1:1 onto the fantasy**: bestiary (collection), shiny hunt (rare chase), nightly cycle (routine), storm events (urgency), weekly contest (competition). Every retention lever from §5 has a native home.
6. **Monetization is ethical by construction**: QoL gamepasses (2x coins, storage, luck charm capped), cosmetics (rod skins, bobber trails, auras), and time-savers. Nothing purchasable is *required*; nothing purchasable appears on leaderboards.
7. **Long-term scalability**: 12+ update path (new zones, seasonal fish, trading, boats, prestige, private islands). The ocean is infinitely expandable — new zones are new fish tables + terrain, which is the cheapest content type to produce.
8. **The 30-day question**: month-1 revenue of 1–10K Robux (≈$3–27 net) is realistic at 1–3K DAU with 2% conversion; the compounding asset is the retained core (see revenue model doc). Fisch took 8 months to break out — we design the game to *sustain* until it does.

### Risk register (honest)

| Risk | Severity | Mitigation |
|---|---|---|
| Saturation: Fisch/Fish It! dominance | Medium | Differentiate on events + contests + shinies; target underserved mobile/casual segments; update cadence |
| No discoverability without marketing | High | Retention-first design (algorithm rewards it), TikTok/Shorts creator pipeline, thumbnail A/B, Discord community |
| AI code quality in production | Medium | Strict typing, modular services, server-authoritative design, test scripts, incremental rollout |
| Exploits (currency dupes, speedhacks) | High | Architecture doc §5: no client trust, rate limits, server RNG, position validation |
| Name/logo trademark conflicts | Low | Check name availability before publishing; fallback names listed |
| Month-1 revenue below expectations | Medium | Revenue is a lagging indicator; KPI is D1/D7/D30 + session length. Pivot only on retention data, never on day-1 revenue |

### What we will NOT do (boundaries)

- No lootboxes / no gambling-adjacent mechanics (policy + ethics).
- No copyrighted characters, music, or assets.
- No pay-to-win: nothing purchasable grants leaderboard placement; luck boosts are small and capped.
- No PvP at launch (avoids balance + toxicity + moderation overhead).
- No trading at launch (top exploit surface; added in Update 6 once the economy has liquidity and we can afford moderation tooling).

---

## 9. Phase Plan (how we execute)

| Phase | Deliverable | Status |
|---|---|---|
| 1. Planning | This document + decision | ✅ Done |
| 2. Architecture | Tech architecture + code standards (doc 04) | ✅ Done |
| 3. Core gameplay | Server services: fishing, economy, inventory, saving | 🚧 In progress (this turn) |
| 4. UI | Client controllers, HUD, shop, bestiary | Next turn |
| 5. Economy | Economy tuning + quests + streaks | Next turn |
| 6. Saving | DataStore hardening, migration, error handling | Next turn |
| 7. Monetization | Gamepasses + dev products wiring | Next turn |
| 8. Optimization | Perf, memory, network audit | Next turn |
| 9. Testing | Exploit/bug/balance test plan + execution | Next turn |
| 10. Publishing | Icon, thumbnail, logo, description, tags, marketing plan, 12-update roadmap | Next turn |

*Every phase ends with a review: find weaknesses → fix → continue. That discipline is what separates a studio from a hobbyist.*
