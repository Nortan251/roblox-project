# TIDEBOUND — Game Design Document
**Phase 1 Deliverable | Working title: "Tidebound" (fallbacks: Reelbound, Castaway Cove — verify availability before publish)**

> **One-line pitch:** A chill-but-thrilling fishing collection RPG where you fill a bestiary, chase shiny variants, race to the pier when a storm hits, and compete for the biggest catch of the week — on an ocean that's alive.

---

## 1. Design Pillars (every decision must serve at least two)

1. **One-more-cast** — the loop must always be 20–40 seconds from "cast" to "reward or surprise." No dead time.
2. **Collect everything** — bestiary, shinies, zones, titles. Completionism is the retention engine.
3. **The ocean is alive** — night falls, storms roll in, fabled fish appear. The world changes so the player has reasons to return *today*.
4. **Moments worth sharing** — every session should generate at least one screenshot-worthy event (shiny aura, mythic catch, storm catch, contest win).
5. **Respect the player's wallet** — monetization is QoL + cosmetics only. The game never asks for money before minute 3 and never blocks progress behind payment.

---

## 2. Core Gameplay Loop

```
Cast (aim + power) → Wait (bobber) → Bite! → Reel minigame (tension bar)
→ Catch (rarity roll) → Sell or Keep → Coins + XP → Buy rods/baits/unlocks
→ New zone → Rarer fish → Bestiary % → Completion rewards → repeat
        ↑________________ storm events / night fish / weekly contest ___________↓
```

**Loop timing budget (target: no more than 35s per catch):**
| Step | Seconds | Notes |
|---|---|---|
| Cast + travel | 2–4 | Aim assist; power bar |
| Bite wait | 4–9 | Reduced by rod lure speed |
| Reel minigame | 4–10 | Difficulty scales with rarity × rod strength |
| Reward moment | 1–3 | Rarity burst + sound + confetti for rare+ |

**Session target: 20–30 minutes** (~40–60 catches). The session should naturally end at a "just one more cast" moment — e.g., a storm announcement, a near-complete bestiary entry, or an unclaimed daily quest.

---

## 3. The First Five Minutes (scripted, visual, no walls of text)

| Time | What happens | Systems touched |
|---|---|---|
| 0:00 | Spawn on Sunshall Cove pier. Camera already facing water. Giant glowing **"!" NPC (Old Salt)** 20 studs ahead, beacon light + bouncing arrow. HUD shows XP bar (empty but visible), coins (0), quest tracker (1 quest). | FTUE #1, #4 |
| 0:15 | Walk to NPC → one-line dialog ("Grab that bamboo rod, try the water!") → **Starter Rod + 3 Worms granted with a chime.** No menu navigation. | Onboarding |
| 0:30 | Cast: press Q or tap button → simple aim (drag up/down sets power) → release → bobber splashes. | Casting |
| 0:45–1:30 | Bite within ~6s. **Hold SPACE / tap to reel.** Tension bar rises while reeling — release when red. Catch **Sunny Minnow (Common)** → catch banner + coin popup + sound. First bestiary entry pops. | Reel minigame, bestiary |
| 1:30–3:00 | Quest tracker updates ("Sell 3 fish"). NPC glow moves to the market stall → sell → coins fly + sound. Buy **Bamboo Rod (150c)** — affordable NOW, visibly better stats. | Economy, shop |
| 3:00–5:00 | New quest: "Catch 5 fish." Player catches a **Golden Anchovy (Rare)** → big burst + announcement. Level 2 ding. A storm warning banner teases: "Storms bring strange fish…" | XP, virality hook |
| 5:00 | Player has caught 5–8 fish, bought a rod, seen rarity burst, leveled up, and knows the daily quest exists. **They have a reason to come back tomorrow.** | Retention |

**Hard rules:** no text walls, no modal tutorial, every action has sound + particle feedback, first upgrade costs ≤5 minutes of play, spawn always faces the action.

---

## 4. World & Zones (launch: 6 zones + secrets)

| Zone | Unlock | Vibe | Fish count | Notes |
|---|---|---|---|---|
| Sunshall Cove | Free (tutorial) | Golden beach, calm | 7 | Tutorial + market + Old Salt |
| Whisper Shallows | Level 3 | Turquoise, seagrass, kelp | 7 | First night-fish exposure |
| The Drop | Level 8 | Deep blue, cliffs, fog | 7 | First epic-heavy zone |
| Ember Falls | Level 15 | Volcanic, red sky, waterfalls | 7 | Fire-lit night ambience |
| Frostreach | Level 24 | Icebergs, aurora | 7 | Aurora night visuals |
| Abyssal Trench | Level 35 | Near-black water, bioluminescence | 8 | Mythic zone + The Old One |
| **Hidden Isles ×2** | Secret | Behind waterfall / in sea cave | 4 | One-time pearl chests, bragging rights |

Movement: swim speed base; **rowboat** (cheap, Level 5) doubles speed; **motorboat** (expensive, Level 18) is 3.5× and enables storm racing. Boats are coin-purchased (sinks) — boats do NOT gate content (all zones reachable by swimming; boats just save time).

**Day/Night cycle:** 20 min day / 6 min night (server-time driven, same for everyone — creates shared moments). Night changes ambience, spawns **bioluminescent family** fish in every zone, +5% luck mood. Announcements at transitions.

**Storm events:** every 25–45 min (randomized), 8-min duration, announced 60s ahead ("A storm is brewing…"). During storms: exclusive **storm family** fish everywhere, +50% XP, harder reel minigame, dramatic sky. Storms are the #1 "tell your friend" moment and the #1 daily hook.

---

## 5. Player Progression

### Levels & XP
- Max level **50 at launch**. XP from catching (defined per fish), level-up = burst + +2 inventory slots? No — inventory slots via upgrades only. Level-up reward: small coin bonus + unlocks (zones, rods, cosmetics, titles).
- XP curve: `xpForLevel(n) = round(100 * n^1.6)`. Totals: L10 ≈ 5.6K XP (~1.5–2h), L25 ≈ 138K (~15–20h), L50 ≈ 1.9M (~60–80h of mixed play). Max level reachable by a casual player in ~2–3 months — that's the design intent (long-term goal), with constant intermediate rewards.

### Rods (the core upgrade ladder)
| Rod | Cost (coins) | Luck | Strength | Lure (−s) | Unlock |
|---|---|---|---|---|---|
| Bamboo | 150 | +0% | 2 | 0 | Free (starter) |
| River Oak | 450 | +3% | 3 | 1 | L2 |
| Coral Reed | 1,400 | +7% | 4 | 2 | L6 |
| Storm Runner | 4,000 | +12% | 5 | 3 | L12 |
| Ember Spine | 11,000 | +18% | 6 | 4 | L20 |
| Frostbound | 28,000 | +25% | 7 | 5 | L28 |
| Abyss Caller | 70,000 | +35% | 8 | 6 | L36 |
| Leviathan | 150,000 | +50% | 10 | 7 | L45 + 100 bestiary % in zone 6 |

- **Luck** shifts rarity weights (cap total luck multiplier at 2.5× on epic+ — prevents runaway).
- **Strength** sets minigame difficulty (more forgiving tension for rarer fish).
- **Lure** reduces bite wait.

### Baits (consumables, coin-purchased)
None / Worm (family: bottom feeders) / Shrimp (family: swimmers) / Squid (family: night + deep) / Golden Lure (family: any + big luck boost; also premium/streak reward). Bait is a skill layer: bestiary entries have "preferred bait" hints.

### Titles (social currency, unlockable)
e.g., "First Catch," "Storm Chaser" (10 storm fish), "Shiny Hunter" (5 shinies), "Old One's Witness," "Contest Winner," "Bestiary Master." Titles show above the head (toggleable) — cheap to build, huge identity value.

---

## 6. Currencies & Economy (summary — full model in doc 03)

| Currency | Type | Sources | Sinks | Notes |
|---|---|---|---|---|
| **Coins** | Soft | Selling fish, quests, chests, level-ups, streak | Rods, boats, baits, storage upgrades, cosmetic bobbers, zone convenience | The main progression currency. Designed so a casual 30-min session earns 300–800 coins early game |
| **Pearls** | Premium (optional) | Purchases, weekly contest, streak day 7, rare drops (0.5% on epic+), achievements, secret chests (one-time) | Cosmetics (rod skins, bobber trails, auras, boat skins, name colors), XP boosts, auto-reel tokens | Never required. 100 pearls = 99 R$ pack. Cosmetic price range 25–400 |
| **XP** | Progression | Catches | Levels (unlocks) | See §5 |
| **Rarity/Shiny** | Meta | RNG rolls | Bestiary completion | The real "currency" of the game: collection |

**Anti-inflation rules (hard constraints):**
1. Coin sinks grow faster than sources at every tier (rod costs scale ~2.5–3× each tier; income scales ~1.4× per zone).
2. No player-to-player coin transfer at launch (no trading until Update 6).
3. Shiny value ×3 but shinies are caught at 2% — no shiny selling loops that break pacing.
4. Pearl drop rate capped (0.5% on epic+ only) — pearls can never be efficiently farmed; chest pearls are one-time per account.
5. All prices/drops defined in server-only catalogs (client receives display copies only).

---

## 7. Inventory
- **40 slots** default; sell individually or **"Sell All Commons"** (one tap — respects player time).
- Storage upgrades: +10 slots ×3 tiers (coins: 2K/8K/25K); **Bigger Tackle Box gamepass +50**.
- Auto-sell toggle for common/uncommon (QoL, set-and-forget).
- Duplicates are sellable; bestiary progress is tracked on *catch*, not on *keep* — so inventory pressure never blocks collection.

---

## 8. Collection / Bestiary
- One entry per species: name, rarity, weight range, preferred bait, description (flavor), zone.
- Each entry has **normal + shiny** variants — the shiny slot is the long-tail grind.
- Zone completion % → rewards at 100% per zone (pearls + title); **global 100% = "Bestiary Master" title + legendary rod discount + statue at pier** (visible to all = flex).
- Bestiary is the psychological anchor: "I'm at 94% for The Drop… one more night session."

---

## 9. Quests, Streaks, Achievements

### Daily (3/day, refreshed at 00:00 UTC, 1 free reroll)
Pool of templates: catch N fish / catch N in zone X / catch N night fish / catch 1 rare+ / sell N coins / catch N storm fish (storm-day specials) / catch N of family Y. Rewards: coins (scaled), 1–2 pearls on the hardest slot, bait.

### Weekly (3/week): catch 100 fish, catch 5 epic+, complete a zone bestiary to 50%. Rewards: 25–50 pearls + exclusive weekly bobber cosmetic (collection item!).

### Login streak (7-day cycle, resets if a day is missed)
D1 50c → D2 100c → D3 200c + worms → D4 350c → D5 500c → D6 750c + shrimp → **D7 1,000c + 25 pearls + 1 Golden Lure**. Day 7 is the "holy grail" that pulls players through the week. (Standard, non-manipulative — no fake timers, no dark patterns; the reward is real and stated.)

### Achievements (~30 at launch)
First Catch / First Shiny / Storm Chaser (10 storm fish) / Night Owl (20 night fish) / Zone Masters ×6 / 1,000 Fish / 100K Coins Earned / Old One's Witness / Secret Finder ×2 / Rod Collector (all rods) / Contest Winner / Pearls Earned (100). Rewards: pearls + titles + 2 exclusive cosmetic bobbers.

---

## 10. Secrets & Hidden Content (discovery virality)
1. **The Old One** — catch 50 "deep family" fish → 2% chance in Abyssal Trench of a fabled 3-stage tug fight. Mythic, server announcement, unique drop (the only fish with a guaranteed shiny-on-catch variant: "The Pale One"). Players WILL make YouTube videos about how to unlock it.
2. **Hidden Isle of Whispers** — behind the Ember Falls waterfall. 2 unique fish + one-time chest (25 pearls + exclusive bobber).
3. **The Sunken Grotto** — inside a sea cave at The Drop. 2 unique fish + "Cursed Bobber" (next catch rarity rerolls; 50% upgrade, 50% downgrade — a gambling-adjacent *free* joke item; it's player-skill-neutral fun and gives streamers content. It's not purchasable, so no policy issue).
4. **Golden spots** — shimmering water patches that guarantee a rare+ catch (rotating, 3 min duration, announced subtly). Reward exploration.

---

## 11. Social Mechanics (cheap but effective)
- **Fishing Parties**: 2+ players within 20 studs of each other's bobber → +10% XP each (stacks to +20%). Drives friends to play *together* — the highest-retention social behavior on the platform.
- **Global catch feed**: mythic/shiny catches broadcast server-wide with player name + fish ("☀️ Player_X caught a SHINY Leviathan — 142kg!").
- **Emotes at the pier** (wave, cheer, flex) — zero-cost social glue.
- **Showcase pier**: your last 3 best catches displayed on your private dock slot (visible to all). Identity + screenshot hook.
- **Weekly contest**: auto-tracked biggest catch (weight × rarity multiplier) per week; top 10 get pearls + "Contest Winner" title; leaderboard visible at the pier. Competition with 7-day cadence = weekly return trigger.

---

## 12. Replayability & Late Game
- **The grind is the game**: shiny variants, 100% bestiary, titles, rod mastery.
- **Prestige (Update 4)**: reset zones at max level for permanent +luck and prestige titles (1–10). Extends the ladder without new content.
- **Weekly contests + rotating storm fish** keep returning players busy.
- **Fabled boss fish** (multi-stage tug) as the skill-ceiling content.
- **Late-game completionist track**: "Catch every shiny" — the whales' Everest.

---

## 13. Retention Design (the full system map)

| Lever | Mechanism | Target metric |
|---|---|---|
| FTUE 6/6 | §3 script | D1 ≥ 38% |
| Daily quests + streak | §9 | D7 ≥ 16% |
| Night cycle novelty | §4 | Session length ≥ 20 min |
| Storm events (shared urgency) | §4 | D1→D2 return spike |
| Weekly contest | §11 | Weekly return ≥ 40% of actives |
| Bestiary completion | §8 | D30 ≥ 7% |
| Party XP | §11 | Multiplayer sessions ≥ 15% |
| Update cadence | 12-update roadmap | Month-2 retention floor |

**Come-back hooks (no dark patterns):** streak day-7 reward, storm schedule ("next storm in ~12 min" at the pier clock), contest results on Monday, weekly quest reset, new weekly bobber cosmetic.

---

## 14. Virality Design (built-in, not bolted on)

| Moment | Trigger | Why it spreads |
|---|---|---|
| Mythic catch | 1-in-300+ | Server broadcast + confetti + screen shake → "OMG" clip |
| Shiny catch | 1-in-50 | Aura + sparkle trail — visually distinct in thumbnails |
| Storm catch | Event | FOMO: "storm's up, join now" |
| The Old One fight | Secret unlock | How-to content, discovery content |
| Weekly contest win | Monday | Bragging rights screenshot |
| Catch Card | Every rare+ catch | Auto-generated share card with fish art + stats — *designed to be screenshotted* |
| Golden spots | Random | "Look at this spot!!" |

**Catch Card detail:** on any epic+ catch, a stylized card pops (fish silhouette, rarity glow, weight, player name, "Tidebound") — one screenshot, zero effort. This is our cheapest viral engine and it ships in the core UI.

---

## 15. What's Deliberately NOT in v1
- Trading (Update 6 — exploit surface + moderation cost)
- PvP / fishing duels (Update 8)
- Guilds/clans (Update 9+)
- User-generated content
- Private islands (Update 7)
- Voice chat integration

Every omission is a *cost decision*: v1 must ship in 6–8 weeks with maximum polish per hour of dev time. The roadmap (publishing doc) sequences these so the game grows *with* its audience instead of drowning in scope.

---

## 16. Success Metrics (what we measure from day 1)
- D1/D7/D30 retention (Creator Hub)
- Average session length (target 20–30 min)
- Catches per session (target 40+)
- Daily quest completion rate (target ≥ 50% of actives)
- Storm event participation (target ≥ 30% of online players)
- Conversion rate (target 2%+), Robux/visit (target 3+)
- Weekly contest participation (target ≥ 25% of weekly actives)
- Shiny/mythic catch rate vs. config (drift = exploit or bug signal)
