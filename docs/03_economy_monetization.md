# TIDEBOUND — Economy, Monetization & Revenue Model
**Phase 1/5 Deliverable | All numbers are server-side config, tunable post-launch**

> **Philosophy:** The player should never feel the economy. They feel the *pace*. If they're always 5 minutes from the next rod or the next bestiary %, the economy is working. Monetization only sells *comfort, flair, and time* — never power over other players.

---

## 1. Economy Foundations

### 1.1 Sources of Coins (income per hour, by progression stage)

| Stage | Player state | Coins/hour (active fishing) | Notes |
|---|---|---|---|
| Early (L1–8, zones 1–2) | Bamboo–Coral rod | 500–900 | ~40–50 catches/hr, avg 12–18c/fish |
| Mid (L9–20, zones 3–4) | Storm–Ember rod | 1,800–3,200 | ~45 catches/hr, avg 40–70c/fish |
| Late (L21–35, zones 5–6) | Frost–Abyss rod | 5,500–9,000 | ~45 catches/hr, avg 120–200c/fish |
| Endgame (L36–50) | Leviathan + Golden Lure | 12,000–20,000 | Bestiary-focused, plus contest |

Assumptions: 1 catch per 25–35s (incl. sell trips), sell-everything strategy, no gamepasses. Quest/streak income adds ~15–25% on top for daily players.

### 1.2 Sinks (where coins go)

| Sink | Cost | Pacing intent |
|---|---|---|
| River Oak rod | 450 | Day 1 (first session) |
| Coral Reed rod | 1,400 | Day 1–2 |
| Storm Runner rod | 4,000 | Day 2–4 |
| Ember Spine rod | 11,000 | Week 1–2 |
| Frostbound rod | 28,000 | Week 2–3 |
| Abyss Caller rod | 70,000 | Week 3–5 |
| Leviathan rod | 150,000 | Week 5–8 |
| Rowboat | 1,200 | Day 1–2 |
| Motorboat | 15,000 | Week 2–3 |
| Storage +10 ×3 | 2K / 8K / 25K | Week 1 / 2 / 4 |
| Baits (bulk) | 100–500/stack | Constant trickle |
| Cosmetic bobbers (coin tier) | 500–2,500 | Cosmetic sink for F2P players |

**Rule: the next rod should cost ~30–60 minutes of that stage's income.** At every tier, the *next* tier takes longer than the *last* one did (soft exponential curve), so mid-game players feel progression without hitting a wall.

### 1.3 Rarity & Value Model

Rarity weights per zone (base): Common 500 / Uncommon 280 / Rare 140 / Epic 60 / Legendary 17 / Mythic 3 (per 1000 rolls).

- **Luck** modifies epic/legendary/mythic weights only, formula: `weight * (1 + luck% )`, **capped at 2.5× combined** (rod + charm + bait + night mood) — the cap is the anti-P2W guarantee: a paying player can at most double their epic+ rate, never more, and never touches common/uncommon which keeps the early-game economy stable.
- **Weight roll (kg)**: `min + rand()^1.7 * (max - min)` — skewed toward small fish (realistic feel, keeps top-weight leaderboards meaningful).
- **Value**: `baseValue * kg`. Shiny: **×3 value** + bestiary shiny slot.
- **XP**: fixed per fish def (rarity-based, zone-scaled), e.g. common 8–15, uncommon 20–30, rare 45–70, epic 100–150, legendary 250–350, mythic 600–900.
- **Bait modifiers**: preferred-family bait doubles that family's weight (not value); Golden Lure adds +20% luck and +15% weight.

### 1.4 Anti-Inflation & Anti-Exploit Economics (hard rules)
1. **No trading at launch** (Update 6) — no cross-player value transfer until moderation tooling exists.
2. **Server-authoritative RNG** — clients never roll anything; exploiters cannot "force" rares (architecture doc §5).
3. **Pearls are non-farmable by design**: drop rate 0.5% on epic+ only (~1 pearl per 3–4 hours of active play), chest pearls one-time, contest rewards weekly-capped. Max theoretical free pearls: ~40/week at hardcore play — enough for a small cosmetic a month, never enough to skip progression.
4. **Sell price = 100% of fish value, always** (no mysterious "tax") — but fish value is *tuned* at the source. Transparency prevents rage-quits and simplifies balance.
5. **Coins cap** at 9,999,999 (integer safety + exploit ceiling). Pearls cap 99,999.
6. **All economy mutations pass through one service** (EconomyService) — single choke point for validation, logging, and anomaly detection. Server logs any transaction > 10× expected value → flagged for review.

### 1.5 Daily Income & Progression Speed (expected, no purchases)

| Day | Session (30 min) | Cumulative state |
|---|---|---|
| 1 | ~400c + quests | River Oak, Rowboat, L3 |
| 2 | ~600c + streak | Coral Reed (partial) |
| 3 | ~700c | Coral Reed done, zone 3 unlocked |
| 5 | ~900c | Storm Runner, motorboat partial |
| 7 | ~1,200c + streak D7 | Storm Runner + baits, L12+ |
| 14 | ~1,800c | Ember Spine, zone 4–5 |
| 30 | ~2,800c | Frostbound, Abyssal Trench partial |
| 60 | ~5,000c | Abyss Caller, bestiary 60–80% |

**Design intent:** a 30-min/day player feels *meaningful* progress every single session for the first month; the 2–3h/day grinder reaches Leviathan in ~4–6 weeks; the completionist plays 3+ months chasing shinies. This pacing maximizes the window in which monetization is attractive (players buy *during* the climb, not after).

---

## 2. Monetization Design (ethical by construction)

**Guiding rules:**
- Nothing purchasable is required to complete any content.
- Nothing purchasable affects leaderboards, contests, or PvP (there is no PvP).
- No lootboxes, no random-purchase mechanics, no "pity timer" gambling skins. Roblox policy + ethics both agree.
- All boosts are small, capped, and framed as time-savers.
- Prices per the 2026 ladder: Entry 25–75 / Core 99–249 / Premium 249–499 / VIP 499–999 R$.

### 2.1 Gamepasses (60–70% of revenue surface)

| Gamepass | Price (R$) | What it does | Why players buy it | Ethics check |
|---|---|---|---|---|
| **Double Catch** | 349 | 2× coins from selling fish | The universal "respect my time" purchase; every simulator's core pass | Time-saver, no exclusivity |
| **Bigger Tackle Box** | 149 | +50 inventory slots | Removes the #1 friction of long sessions | QoL |
| **Lucky Charm** | 199 | +15% luck (inside the 2.5× cap) | Improves shiny/mythic odds slightly | Capped, small; grindable via rods alone |
| **VIP Angler** | 449 | +10% XP, VIP dock, exclusive rod skin, gold name tag | Status + fastest leveling; the "fan" pass | XP boost is small; status is cosmetic |
| **Golden Lure Pass** | 249 | Permanent access to Golden Lure bait (best bait) | Best-in-slot bait without buying consumables | Consumable is buyable with coins anyway (free path exists) |
| **Starter Pack** | 99 | 500 coins + 5 Golden Lures + exclusive bobber | First-purchase hook at an impulse price | Pure head-start + cosmetic |
| **Cosmetic Bundles** (rod skins ×3, boat skins ×2) | 99–299 | Visual only | "I want to look cool" — the biggest F2P→payer driver | Cosmetic only |

### 2.2 Developer Products (30–40% — recurring from engaged players)

| Product | Price (R$) | What it is | Why it's fair |
|---|---|---|---|
| Pearl Pack 100 | 99 | 100 pearls | Clean currency pack (bonus on bigger packs) |
| Pearl Pack 450 | 399 | 450 pearls | Volume discount |
| Pearl Pack 1,000 | 799 | 1,000 pearls | Volume discount |
| Auto-Reel Token ×100 | 149 | Skip the reel minigame 100 times | Removes friction for the impatient; fish must still bite; no rarity change |
| XP Boost (2h) | 49 | +50% XP | Time-saver, small |
| Limited seasonal cosmetics | 149–299 | e.g., Ghostfin Rod (Halloween), Aurora Bobber (Winter) | FOMO-lite: returns yearly, announced in advance |

### 2.3 What Pearls buy (the premium shop)
Rod skins (75–300), bobber trails (50–150), catch auras (100–250), boat skins (150–350), name colors (25), emotes (50–100), titles (75–150), showcase pier decorations (100–400). **All cosmetic or trivial-QoL.** The shop has a "free pearls earned so far" counter — this converts free players into future buyers by *demonstrating* the premium economy is optional (classic, ethical, effective).

### 2.4 Conversion & Revenue Estimates (state the assumptions!)

Assumptions (2026 industry data, simulator genre):
- Conversion rate: **2%** of players make ≥1 purchase (range 1.5–3%).
- Average revenue per paying player in month 1: **75–150 R$** (≈ one Core pass or pass + small pack).
- Premium payouts ignored (upside only).
- 30% platform fee → net 70%; DevEx $0.0038/R$.

**Monthly net revenue ≈ DAU × 30 × 2% × 75–150 R$ × 0.70**
| DAU | Conversion | Spend/player/mo | Gross R$/mo | Net R$/mo | Net USD/mo |
|---|---|---|---|---|---|
| 250 | 2% | 100 R$ | 15,000 | 10,500 | ~$40 |
| 1,000 | 2% | 100 R$ | 60,000 | 42,000 | ~$160 |
| 2,500 | 2% | 120 R$ | 180,000 | 126,000 | ~$480 |
| 5,000 | 2% | 120 R$ | 360,000 | 252,000 | ~$960 |
| 10,000 | 2.5% | 150 R$ | 1,125,000 | 787,500 | ~$3,000 |

*Reality check: these are steady-state numbers. Month 1 will be below them — the market research doc's honest month-1 range is 1–10K R$ (~$3–27) at 1–3K DAU, because month 1 is about retention + discovery, not extraction.*

### 2.5 DAU required for Robux/day targets (user's question, answered plainly)

Using: buyers/day ≈ DAU × 2% × (1/4 buy each day on average? No — we model *daily purchase events*): daily Robux ≈ DAU × conversion × avg purchase/day. With 2% of *daily actives* making a purchase of avg **40 R$** on ~1 of every 3 active days (≈13 R$/player-month), we get **Robux/day ≈ DAU × 0.87**.

| Target (R$/day) | Required DAU (base case) | Required DAU (optimistic: 2.5% conv, 60 R$ avg) | USD/day (net, base) |
|---|---|---|---|
| 100 | ~115 | ~65 | ~$0.27 |
| 500 | ~575 | ~330 | ~$1.33 |
| 1,000 | ~1,150 | ~660 | ~$2.66 |
| 5,000 | ~5,750 | ~3,300 | ~$13.30 |
| 10,000 | ~11,500 | ~6,600 | ~$26.60 |

**All assumptions stated:** conversion 2% (sim genre benchmark), avg purchase 40 R$, buyer purchases every 3rd active day, 30% fee + $0.0038 DevEx. Every variable is tracked post-launch and the model updates with real data. **No guarantee of revenue is implied or possible — this is a probability-weighted plan, not a promise.** Fisch took ~8 months to break out; our plan is designed to survive that runway.

---

## 3. Economy Tuning Playbook (post-launch, data-driven)
1. Track coins/hour per zone and rod tier weekly (server logs). If a tier takes >90 min of that tier's income to clear → buff income or cut cost by 15%.
2. Track pearl earn rate; if >50 free pearls/week/player → cut drop rate 20%.
3. Track "sell all commons" usage vs storage pressure; tune auto-sell defaults.
4. Weekly contest participation <25% → raise rewards until it hurts the pearl budget; cap at 15% of weekly pearl supply.
5. Conversion <1.5% → audit first-purchase friction (Starter Pack visibility at minute 3, not before).
6. All changes logged in a public changelog (community trust = retention).
