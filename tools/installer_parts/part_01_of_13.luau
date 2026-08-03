--[[
	Tidebound - Installer part (paste into Studio Command Bar)
	Creates/updates scripts. Idempotent; safe to run parts in any order,
	but run them in order 01..NN. Watch the Output window for part messages.
]]
local function getSvc(n) return game:GetService(n) end
local rs = getSvc("ReplicatedStorage")
local sss = getSvc("ServerScriptService")
local sp = getSvc("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local starter = getSvc("StarterPlayer")

-- Idempotent ensure: walks the LIVE explorer tree from the service root.
-- (NOTE: paths use the SERVICE root, e.g. 'StarterPlayer/StarterPlayerScripts/...'
-- so StarterPlayerScripts is found as a CHILD of the StarterPlayer service.)
local function ensure(logical, cls)
	local parts = {}
	for p in logical:gmatch("[^/]+") do table.insert(parts, p) end
	local root = parts[1] == "ReplicatedStorage" and rs
		or parts[1] == "ServerScriptService" and sss
		or parts[1] == "StarterPlayer" and starter
	if not root then return nil end
	local current = root
	for i = 2, #parts do
		local child = current:FindFirstChild(parts[i])
		if not child then
			child = Instance.new(i == #parts and cls or "Folder")
			child.Name = parts[i]
			child.Parent = current
		end
		current = child
	end
	return current
end

-- ReplicatedStorage/Shared/Config
local inst = ensure('ReplicatedStorage/Shared/Config', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Config
	ALL tunable game constants live here. Rebalance by editing this file only.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Config = {}

-- ── Save system ──────────────────────────────────────────────────────────
Config.SAVE_VERSION = 1
Config.SAVE_KEY_PREFIX = "TD_Save_v"
Config.AUTOSAVE_INTERVAL = 90 -- seconds

-- ── Leveling ─────────────────────────────────────────────────────────────
Config.XP_BASE = 100 -- xp needed from level N to N+1 = XP_BASE * N^XP_EXPONENT
Config.XP_EXPONENT = 1.6
Config.MAX_LEVEL = 50
Config.LEVEL_UP_COINS = 50 + 10 -- flat bonus on level up (scaled by level in code)

-- ── Rarity / luck ────────────────────────────────────────────────────────
Config.RARITIES = { "common", "uncommon", "rare", "epic", "legendary", "mythic" }
Config.RARITY_INDEX = { common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5, mythic = 6 }
Config.RARITY_WEIGHTS = { common = 500, uncommon = 280, rare = 140, epic = 60, legendary = 17, mythic = 3 }
Config.LUCK_CAP = 2.5 -- max combined luck multiplier on epic+ (anti-P2W cap)
Config.SHINY_CHANCE = 0.02 -- 2% shiny variant on any catch
Config.SHINY_VALUE_MULT = 3
Config.BAIT_FAMILY_MULT = 2.0 -- preferred bait doubles family weight
Config.GOLDEN_LURE_LUCK = 0.20
Config.GOLDEN_LURE_WEIGHT_MULT = 1.15
Config.NIGHT_LUCK = 0.05 -- +5% luck mood at night

-- ── Fishing timing ───────────────────────────────────────────────────────
Config.CAST_COOLDOWN = 1.2
Config.WAIT_MIN = 4.0 -- seconds before bite (base)
Config.WAIT_MAX = 9.0
Config.WAIT_FLOOR = 2.5 -- rod lure speed can't reduce below this
Config.REEL_TICK = 0.1 -- server simulation step
Config.REEL_STATE_SEND = 0.16 -- client state push interval
Config.PROGRESS_MAX = 100
Config.TENSION_MAX = 100
Config.TENSION_RISE_BASE = 34 -- tension/s at strength 1, common fish
Config.TENSION_RISE_PER_RARITY = 0.22 -- extra rise per rarity step
Config.TENSION_DECAY = 46 -- tension/s while released
Config.PROGRESS_RATE_BASE = 8 -- progress/s at strength 0
Config.PROGRESS_RATE_PER_STRENGTH = 1 -- +progress/s per strength point
Config.REEL_POSITION_RADIUS = 60 -- player must stay near own bobber
Config.WATER_Y = 0 -- bobber floats at this height

-- ── Economy caps ─────────────────────────────────────────────────────────
Config.COIN_CAP = 9999999
Config.PEARL_CAP = 99999
Config.INVENTORY_START = 40
Config.INVENTORY_CAP = 200
Config.INVENTORY_UPGRADES = {
	{ slots = 10, cost = 2000 },
	{ slots = 10, cost = 8000 },
	{ slots = 10, cost = 25000 },
}
Config.PEARL_DROP_CHANCE = 0.005 -- 0.5% per epic+ catch
Config.PEARL_DROP_MIN_RARITY = "epic"

-- ── Quests / streaks ─────────────────────────────────────────────────────
Config.DAILY_QUESTS = 3
Config.WEEKLY_QUESTS = 3
Config.STREAK_REWARDS = {
	{ coins = 50 },
	{ coins = 100 },
	{ coins = 200, worm = 5 },
	{ coins = 350 },
	{ coins = 500 },
	{ coins = 750, shrimp = 3 },
	{ coins = 1000, pearls = 25, golden = 1 },
}

-- ── Day / night & storms ─────────────────────────────────────────────────
Config.DAY_LENGTH = 1200 -- 20 min
Config.NIGHT_LENGTH = 360 -- 6 min
Config.STORM_MIN_DELAY = 1500 -- 25 min
Config.STORM_MAX_DELAY = 2700 -- 45 min
Config.STORM_DURATION = 480 -- 8 min
Config.STORM_WARNING = 60 -- seconds of warning
Config.STORM_XP_MULT = 1.5
Config.STORM_PEARL_CHANCE = 0.05 -- storm fish drop pearls 5%

-- ── Baits (coin shop) ────────────────────────────────────────────────────
Config.BAITS = {
	worm = { name = "Worm", cost = 50, count = 10 },
	shrimp = { name = "Shrimp", cost = 120, count = 10 },
	squid = { name = "Squid", cost = 300, count = 10 },
	golden = { name = "Golden Lure", cost = 500, count = 3 },
}

-- ── Rate limits (messages per 10s window per player) ─────────────────────
Config.RATE_LIMITS = {
	Cast = 6,
	ReelHold = 100,
	AutoReel = 5,
	SellFish = 25,
	SellAll = 6,
	SetAutoSell = 4,
	BuyRod = 6,
	BuyBait = 10,
	BuyUpgrade = 6,
	BuyCosmetic = 10,
	EquipRod = 8,
	EquipBait = 8,
	EquipCosmetic = 10,
	ClaimDaily = 6,
	ClaimWeekly = 6,
	RerollQuest = 3,
	FastTravel = 8,
	Purchase = 6,
	BuyCosmetic = 10,
	EquipCosmetic = 10,
	EquipTitle = 8,
	GetContestTop = 10,
}

-- ── Golden spots (limited-time shimmer locations) ─────────────────────────
Config.GOLDEN_SPOT_INTERVAL_MIN = 300 -- 5 min
Config.GOLDEN_SPOT_INTERVAL_MAX = 600 -- 10 min
Config.GOLDEN_SPOT_DURATION = 90 -- seconds a spot stays
Config.GOLDEN_SPOT_RADIUS = 30 -- studs around the shimmer
Config.GOLDEN_SPOT_LUCK = 0.20 -- +20% luck while casting there
Config.GOLDEN_SPOT_VALUE_MULT = 1.1 -- +10% sell value

-- ── Monetization (fill IDs from Creator Dashboard, Phase 7) ──────────────
Config.GAMEPASS_IDS = {
	double_catch = 0, -- 349 R$ : 2x coins
	bigger_tackle_box = 0, -- 149 R$ : +50 inventory
	lucky_charm = 0, -- 199 R$ : +15% luck
	vip_angler = 0, -- 449 R$ : +10% XP, VIP dock, skin, tag
	golden_lure_pass = 0, -- 249 R$ : permanent Golden Lure
	starter_pack = 0, -- 99 R$ : 500c + 5 golden lures + bobber
}
Config.PRODUCT_IDS = {
	pearls_100 = 0, -- 99 R$
	pearls_450 = 0, -- 399 R$
	pearls_1000 = 0, -- 799 R$
	auto_reel_tokens = 0, -- 149 R$ : x100
	xp_boost_2h = 0, -- 49 R$
}
Config.PEARL_PACKS = {
	{ id = "pearls_100", pearls = 100 },
	{ id = "pearls_450", pearls = 450 },
	{ id = "pearls_1000", pearls = 1000 },
}
Config.AUTO_REEL_TOKEN_PACK = 100
Config.XP_BOOST_DURATION = 7200
Config.XP_BOOST_MULT = 1.5
Config.DOUBLE_COINS_MULT = 2.0
Config.LUCKY_CHARM_LUCK = 0.15
Config.VIP_XP_MULT = 1.1
Config.STARTER_PACK = { coins = 500, golden = 5 }

-- ── Weekly contest ───────────────────────────────────────────────────────
Config.CONTEST_REWARDS = { 50, 40, 30, 25, 20, 15, 12, 10, 8, 5 } -- pearls, top 10
Config.CONTEST_MULTIPLIER_BASE = 1.0 -- score = weightKg * (base + rarityIndex)

-- ── Client UI / input ────────────────────────────────────────────────────
Config.CAST_POWER_TIME = 1.2 -- seconds to charge cast power 0→1
Config.QUICK_CAST_POWER = 0.55 -- power used when tapping without holding
Config.MAX_FEED_MESSAGES = 5 -- feed entries kept on screen
Config.CATCH_CARD_MS = 3500 -- catch card auto-dismiss (epic+)

-- ── Audio (fill IDs after uploading assets/audio/*.wav in Studio) ───────
-- 0 = sound disabled (graceful silence until the ID is set)
Config.AUDIO_IDS = {
	ui_click = 0,
	ui_error = 0,
	cast_splash = 0,
	bite = 0,
	reel_tick = 0,
	catch_common = 0,
	catch_rare = 0,
	catch_mythic = 0,
	levelup = 0,
	coins = 0,
	streak = 0,
	storm = 0,
	achievement = 0,
	buy = 0,
}

return Config
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Config
	ALL tunable game constants live here. Rebalance by editing this file only.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Config = {}

-- ── Save system ──────────────────────────────────────────────────────────
Config.SAVE_VERSION = 1
Config.SAVE_KEY_PREFIX = "TD_Save_v"
Config.AUTOSAVE_INTERVAL = 90 -- seconds

-- ── Leveling ─────────────────────────────────────────────────────────────
Config.XP_BASE = 100 -- xp needed from level N to N+1 = XP_BASE * N^XP_EXPONENT
Config.XP_EXPONENT = 1.6
Config.MAX_LEVEL = 50
Config.LEVEL_UP_COINS = 50 + 10 -- flat bonus on level up (scaled by level in code)

-- ── Rarity / luck ────────────────────────────────────────────────────────
Config.RARITIES = { "common", "uncommon", "rare", "epic", "legendary", "mythic" }
Config.RARITY_INDEX = { common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5, mythic = 6 }
Config.RARITY_WEIGHTS = { common = 500, uncommon = 280, rare = 140, epic = 60, legendary = 17, mythic = 3 }
Config.LUCK_CAP = 2.5 -- max combined luck multiplier on epic+ (anti-P2W cap)
Config.SHINY_CHANCE = 0.02 -- 2% shiny variant on any catch
Config.SHINY_VALUE_MULT = 3
Config.BAIT_FAMILY_MULT = 2.0 -- preferred bait doubles family weight
Config.GOLDEN_LURE_LUCK = 0.20
Config.GOLDEN_LURE_WEIGHT_MULT = 1.15
Config.NIGHT_LUCK = 0.05 -- +5% luck mood at night

-- ── Fishing timing ───────────────────────────────────────────────────────
Config.CAST_COOLDOWN = 1.2
Config.WAIT_MIN = 4.0 -- seconds before bite (base)
Config.WAIT_MAX = 9.0
Config.WAIT_FLOOR = 2.5 -- rod lure speed can't reduce below this
Config.REEL_TICK = 0.1 -- server simulation step
Config.REEL_STATE_SEND = 0.16 -- client state push interval
Config.PROGRESS_MAX = 100
Config.TENSION_MAX = 100
Config.TENSION_RISE_BASE = 34 -- tension/s at strength 1, common fish
Config.TENSION_RISE_PER_RARITY = 0.22 -- extra rise per rarity step
Config.TENSION_DECAY = 46 -- tension/s while released
Config.PROGRESS_RATE_BASE = 8 -- progress/s at strength 0
Config.PROGRESS_RATE_PER_STRENGTH = 1 -- +progress/s per strength point
Config.REEL_POSITION_RADIUS = 60 -- player must stay near own bobber
Config.WATER_Y = 0 -- bobber floats at this height

-- ── Economy caps ─────────────────────────────────────────────────────────
Config.COIN_CAP = 9999999
Config.PEARL_CAP = 99999
Config.INVENTORY_START = 40
Config.INVENTORY_CAP = 200
Config.INVENTORY_UPGRADES = {
	{ slots = 10, cost = 2000 },
	{ slots = 10, cost = 8000 },
	{ slots = 10, cost = 25000 },
}
Config.PEARL_DROP_CHANCE = 0.005 -- 0.5% per epic+ catch
Config.PEARL_DROP_MIN_RARITY = "epic"

-- ── Quests / streaks ─────────────────────────────────────────────────────
Config.DAILY_QUESTS = 3
Config.WEEKLY_QUESTS = 3
Config.STREAK_REWARDS = {
	{ coins = 50 },
	{ coins = 100 },
	{ coins = 200, worm = 5 },
	{ coins = 350 },
	{ coins = 500 },
	{ coins = 750, shrimp = 3 },
	{ coins = 1000, pearls = 25, golden = 1 },
}

-- ── Day / night & storms ─────────────────────────────────────────────────
Config.DAY_LENGTH = 1200 -- 20 min
Config.NIGHT_LENGTH = 360 -- 6 min
Config.STORM_MIN_DELAY = 1500 -- 25 min
Config.STORM_MAX_DELAY = 2700 -- 45 min
Config.STORM_DURATION = 480 -- 8 min
Config.STORM_WARNING = 60 -- seconds of warning
Config.STORM_XP_MULT = 1.5
Config.STORM_PEARL_CHANCE = 0.05 -- storm fish drop pearls 5%

-- ── Baits (coin shop) ────────────────────────────────────────────────────
Config.BAITS = {
	worm = { name = "Worm", cost = 50, count = 10 },
	shrimp = { name = "Shrimp", cost = 120, count = 10 },
	squid = { name = "Squid", cost = 300, count = 10 },
	golden = { name = "Golden Lure", cost = 500, count = 3 },
}

-- ── Rate limits (messages per 10s window per player) ─────────────────────
Config.RATE_LIMITS = {
	Cast = 6,
	ReelHold = 100,
	AutoReel = 5,
	SellFish = 25,
	SellAll = 6,
	SetAutoSell = 4,
	BuyRod = 6,
	BuyBait = 10,
	BuyUpgrade = 6,
	BuyCosmetic = 10,
	EquipRod = 8,
	EquipBait = 8,
	EquipCosmetic = 10,
	ClaimDaily = 6,
	ClaimWeekly = 6,
	RerollQuest = 3,
	FastTravel = 8,
	Purchase = 6,
	BuyCosmetic = 10,
	EquipCosmetic = 10,
	EquipTitle = 8,
	GetContestTop = 10,
}

-- ── Golden spots (limited-time shimmer locations) ─────────────────────────
Config.GOLDEN_SPOT_INTERVAL_MIN = 300 -- 5 min
Config.GOLDEN_SPOT_INTERVAL_MAX = 600 -- 10 min
Config.GOLDEN_SPOT_DURATION = 90 -- seconds a spot stays
Config.GOLDEN_SPOT_RADIUS = 30 -- studs around the shimmer
Config.GOLDEN_SPOT_LUCK = 0.20 -- +20% luck while casting there
Config.GOLDEN_SPOT_VALUE_MULT = 1.1 -- +10% sell value

-- ── Monetization (fill IDs from Creator Dashboard, Phase 7) ──────────────
Config.GAMEPASS_IDS = {
	double_catch = 0, -- 349 R$ : 2x coins
	bigger_tackle_box = 0, -- 149 R$ : +50 inventory
	lucky_charm = 0, -- 199 R$ : +15% luck
	vip_angler = 0, -- 449 R$ : +10% XP, VIP dock, skin, tag
	golden_lure_pass = 0, -- 249 R$ : permanent Golden Lure
	starter_pack = 0, -- 99 R$ : 500c + 5 golden lures + bobber
}
Config.PRODUCT_IDS = {
	pearls_100 = 0, -- 99 R$
	pearls_450 = 0, -- 399 R$
	pearls_1000 = 0, -- 799 R$
	auto_reel_tokens = 0, -- 149 R$ : x100
	xp_boost_2h = 0, -- 49 R$
}
Config.PEARL_PACKS = {
	{ id = "pearls_100", pearls = 100 },
	{ id = "pearls_450", pearls = 450 },
	{ id = "pearls_1000", pearls = 1000 },
}
Config.AUTO_REEL_TOKEN_PACK = 100
Config.XP_BOOST_DURATION = 7200
Config.XP_BOOST_MULT = 1.5
Config.DOUBLE_COINS_MULT = 2.0
Config.LUCKY_CHARM_LUCK = 0.15
Config.VIP_XP_MULT = 1.1
Config.STARTER_PACK = { coins = 500, golden = 5 }

-- ── Weekly contest ───────────────────────────────────────────────────────
Config.CONTEST_REWARDS = { 50, 40, 30, 25, 20, 15, 12, 10, 8, 5 } -- pearls, top 10
Config.CONTEST_MULTIPLIER_BASE = 1.0 -- score = weightKg * (base + rarityIndex)

-- ── Client UI / input ────────────────────────────────────────────────────
Config.CAST_POWER_TIME = 1.2 -- seconds to charge cast power 0→1
Config.QUICK_CAST_POWER = 0.55 -- power used when tapping without holding
Config.MAX_FEED_MESSAGES = 5 -- feed entries kept on screen
Config.CATCH_CARD_MS = 3500 -- catch card auto-dismiss (epic+)

-- ── Audio (fill IDs after uploading assets/audio/*.wav in Studio) ───────
-- 0 = sound disabled (graceful silence until the ID is set)
Config.AUDIO_IDS = {
	ui_click = 0,
	ui_error = 0,
	cast_splash = 0,
	bite = 0,
	reel_tick = 0,
	catch_common = 0,
	catch_rare = 0,
	catch_mythic = 0,
	levelup = 0,
	coins = 0,
	streak = 0,
	storm = 0,
	achievement = 0,
	buy = 0,
}

return Config
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Config')
end

-- ReplicatedStorage/Shared/Types
local inst = ensure('ReplicatedStorage/Shared/Types', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Shared Types
	Single source of type truth for both server and client.
	Phase 2 | AI-assisted | 2026-08-02
]]

export type Rarity = "common" | "uncommon" | "rare" | "epic" | "legendary" | "mythic"

export type FishDef = {
	id: string,
	name: string,
	rarity: Rarity,
	baseValue: number, -- coins at 1 kg
	minWeight: number, -- kg
	maxWeight: number, -- kg
	xp: number,
	zone: string,
	time: "any" | "night",
	family: string,
	bait: string?, -- preferred bait id (worm/shrimp/squid/golden)
	desc: string,
	color: Color3,
	accent: Color3,
	bodyScale: number, -- display length multiplier
	stormOnly: boolean?,
}

export type RodDef = {
	id: string,
	name: string,
	cost: number,
	luck: number, -- 0..1 additive
	strength: number, -- 2..10
	lure: number, -- seconds removed from bite wait
	unlockLevel: number,
	desc: string,
	color: Color3,
}

export type ZoneDef = {
	id: string,
	name: string,
	unlockLevel: number,
	desc: string,
	fishIds: { string },
	nightFishIds: { string }?,
	stormFishIds: { string }?,
}

export type InventoryFish = {
	uid: number,
	fishId: string,
	weight: number, -- kg (1 decimal)
	shiny: boolean,
	caughtAt: number, -- os.time()
}

export type BestiaryEntry = {
	caught: number,
	shiny: boolean,
	maxWeight: number,
}

export type QuestProgress = {
	templateId: string,
	params: { [string]: string }, -- e.g. { zone = "drop" }
	progress: number,
	done: boolean,
	claimed: boolean,
}

export type Stats = {
	totalCatch: number,
	totalCoinsEarned: number,
	totalPearlsEarned: number,
	nightFish: number,
	stormFish: number,
	shinyFish: number,
	deepFish: number,
	epicPlus: number,
	zoneCounts: { [string]: number },
	familyCounts: { [string]: number },
	bestCatch: { weight: number, fishId: string, rarity: Rarity, weekKey: string },
}

export type ProfileData = {
	v: number,
	coins: number,
	pearls: number,
	xp: number,
	level: number,
	streak: number,
	streakLastDay: string, -- YYYY-MM-DD (UTC)
	rods: { [string]: boolean },
	equippedRod: string,
	baits: { [string]: number },
	inventory: { InventoryFish },
	nextUid: number,
	bestiary: { [string]: BestiaryEntry },
	dailyQuests: { QuestProgress },
	weeklyQuests: { QuestProgress },
	questDay: string, -- YYYY-MM-DD
	questWeek: string, -- YYYY-Www
	achievements: { [string]: boolean },
	titles: { [string]: boolean },
	equippedTitle: string?,
	stats: Stats,
	cosmetics: { bobber: string, trail: string?, aura: string?, rodSkin: string?, nameColor: string? },
	flags: {
		tutorialDone: boolean,
		autoSell: string?, -- max rarity auto-sold, or nil
		equippedBait: string?, -- worm/shrimp/squid/golden, nil = none
		ownedPasses: { [string]: boolean },
		tokens: number, -- auto-reel tokens
		xpBoostUntil: number, -- os.time()
		chestsClaimed: { [string]: boolean },
		prestige: number,
		rerollsUsed: number, -- daily quest rerolls
		zoneRewards: { [string]: boolean }, -- 100% bestiary rewards claimed
		receipts: { [string]: boolean }, -- purchase idempotency
		contestWins: number,
		starterClaimed: boolean,
		invUpgradeTier: number, -- 0..3 inventory upgrades bought
		cosmeticsOwned: { [string]: boolean },
	},
}

export type C2SMessage = { type: string, payload: any }
export type S2CMessage = { type: string, payload: any }

-- Public snapshot sent to the client on join (never the raw profile)
export type PublicProfile = {
	coins: number,
	pearls: number,
	xp: number,
	level: number,
	equippedRod: string,
	rods: { [string]: boolean },
	baits: { [string]: number },
	inventory: { InventoryFish },
	bestiary: { [string]: BestiaryEntry },
	dailyQuests: { QuestProgress },
	weeklyQuests: { QuestProgress },
	achievements: { [string]: boolean },
	titles: { [string]: boolean },
	equippedTitle: string?,
	stats: Stats,
	cosmetics: any,
	flags: any,
}

return {}
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Shared Types
	Single source of type truth for both server and client.
	Phase 2 | AI-assisted | 2026-08-02
]]

export type Rarity = "common" | "uncommon" | "rare" | "epic" | "legendary" | "mythic"

export type FishDef = {
	id: string,
	name: string,
	rarity: Rarity,
	baseValue: number, -- coins at 1 kg
	minWeight: number, -- kg
	maxWeight: number, -- kg
	xp: number,
	zone: string,
	time: "any" | "night",
	family: string,
	bait: string?, -- preferred bait id (worm/shrimp/squid/golden)
	desc: string,
	color: Color3,
	accent: Color3,
	bodyScale: number, -- display length multiplier
	stormOnly: boolean?,
}

export type RodDef = {
	id: string,
	name: string,
	cost: number,
	luck: number, -- 0..1 additive
	strength: number, -- 2..10
	lure: number, -- seconds removed from bite wait
	unlockLevel: number,
	desc: string,
	color: Color3,
}

export type ZoneDef = {
	id: string,
	name: string,
	unlockLevel: number,
	desc: string,
	fishIds: { string },
	nightFishIds: { string }?,
	stormFishIds: { string }?,
}

export type InventoryFish = {
	uid: number,
	fishId: string,
	weight: number, -- kg (1 decimal)
	shiny: boolean,
	caughtAt: number, -- os.time()
}

export type BestiaryEntry = {
	caught: number,
	shiny: boolean,
	maxWeight: number,
}

export type QuestProgress = {
	templateId: string,
	params: { [string]: string }, -- e.g. { zone = "drop" }
	progress: number,
	done: boolean,
	claimed: boolean,
}

export type Stats = {
	totalCatch: number,
	totalCoinsEarned: number,
	totalPearlsEarned: number,
	nightFish: number,
	stormFish: number,
	shinyFish: number,
	deepFish: number,
	epicPlus: number,
	zoneCounts: { [string]: number },
	familyCounts: { [string]: number },
	bestCatch: { weight: number, fishId: string, rarity: Rarity, weekKey: string },
}

export type ProfileData = {
	v: number,
	coins: number,
	pearls: number,
	xp: number,
	level: number,
	streak: number,
	streakLastDay: string, -- YYYY-MM-DD (UTC)
	rods: { [string]: boolean },
	equippedRod: string,
	baits: { [string]: number },
	inventory: { InventoryFish },
	nextUid: number,
	bestiary: { [string]: BestiaryEntry },
	dailyQuests: { QuestProgress },
	weeklyQuests: { QuestProgress },
	questDay: string, -- YYYY-MM-DD
	questWeek: string, -- YYYY-Www
	achievements: { [string]: boolean },
	titles: { [string]: boolean },
	equippedTitle: string?,
	stats: Stats,
	cosmetics: { bobber: string, trail: string?, aura: string?, rodSkin: string?, nameColor: string? },
	flags: {
		tutorialDone: boolean,
		autoSell: string?, -- max rarity auto-sold, or nil
		equippedBait: string?, -- worm/shrimp/squid/golden, nil = none
		ownedPasses: { [string]: boolean },
		tokens: number, -- auto-reel tokens
		xpBoostUntil: number, -- os.time()
		chestsClaimed: { [string]: boolean },
		prestige: number,
		rerollsUsed: number, -- daily quest rerolls
		zoneRewards: { [string]: boolean }, -- 100% bestiary rewards claimed
		receipts: { [string]: boolean }, -- purchase idempotency
		contestWins: number,
		starterClaimed: boolean,
		invUpgradeTier: number, -- 0..3 inventory upgrades bought
		cosmeticsOwned: { [string]: boolean },
	},
}

export type C2SMessage = { type: string, payload: any }
export type S2CMessage = { type: string, payload: any }

-- Public snapshot sent to the client on join (never the raw profile)
export type PublicProfile = {
	coins: number,
	pearls: number,
	xp: number,
	level: number,
	equippedRod: string,
	rods: { [string]: boolean },
	baits: { [string]: number },
	inventory: { InventoryFish },
	bestiary: { [string]: BestiaryEntry },
	dailyQuests: { QuestProgress },
	weeklyQuests: { QuestProgress },
	achievements: { [string]: boolean },
	titles: { [string]: boolean },
	equippedTitle: string?,
	stats: Stats,
	cosmetics: any,
	flags: any,
}

return {}
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Types')
end

-- ReplicatedStorage/Shared/Util
local inst = ensure('ReplicatedStorage/Shared/Util', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Util
	Pure, dependency-free helpers shared by server and client.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Util = {}

-- Clamp a number to [min, max]
function Util.clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

-- Round to N decimals
function Util.round(value: number, decimals: number): number
	local mult = 10 ^ decimals
	return math.floor(value * mult + 0.5) / mult
end

-- Format big numbers: 1234 -> "1.2K", 2500000 -> "2.5M"
function Util.formatNumber(value: number): string
	if value >= 1000000 then
		return string.format("%.1fM", value / 1000000)
	elseif value >= 1000 then
		return string.format("%.1fK", value / 1000)
	end
	return tostring(math.floor(value))
end

-- Weighted random pick from { key = weight }. Returns key or nil if empty.
function Util.weightedPick(weights: { [string]: number }): string?
	local total = 0
	for _, w  in pairs(weights) do
		total += w
	end
	if total <= 0 then
		return nil
	end
	local roll = math.random() * total
	for key, w  in pairs(weights) do
		roll -= w
		if roll <= 0 then
			return key
		end
	end
	-- Fallback: last key (floating point safety)
	local last: string? = nil
	for key, _  in pairs(weights) do
		last = key
	end
	return last
end

-- True with probability p (0..1)
function Util.rollChance(p: number): boolean
	return math.random() < p
end

-- UTC date key "YYYY-MM-DD"
function Util.todayKey(): string
	return os.date("!%Y-%m-%d", os.time())
end

-- UTC week key "YYYY-Www" (matches the same week everywhere on the server)
function Util.weekKey(): string
	return os.date("!%Y-W%W", os.time())
end

-- Yesterday's UTC date key (for streak logic)
function Util.yesterdayKey(): string
	return os.date("!%Y-%m-%d", os.time() - 86400)
end

-- Safe number guard: nil/NaN/Infinity -> fallback
function Util.safeNumber(value: any, fallback: number): number
	if typeof(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge then
		return value
	end
	return fallback
end

-- Shallow copy of a table (catalogs are immutable; copies are for display)
function Util.shallowCopy<T>(t: { [string]: T }): { [string]: T }
	local out: { [string]: T } = {}
	for k, v  in pairs(t) do
		out[k] = v
	end
	return out
end

-- List of keys in a table
function Util.keys(t: { [any]: any }): { any }
	local out = {}
	for k, _  in pairs(t) do
		table.insert(out, k)
	end
	return out
end

-- Weight roll for a fish: skewed toward the low end (min + rand^1.7 * range)
function Util.rollWeight(min: number, max: number): number
	local t = math.random() ^ 1.7
	return Util.round(min + t * (max - min), 1)
end

-- XP needed to advance FROM `level` TO `level + 1`
function Util.xpForLevel(level: number, xpBase: number, exponent: number): number
	return math.floor(xpBase * (level ^ exponent))
end

return Util
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Util
	Pure, dependency-free helpers shared by server and client.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Util = {}

-- Clamp a number to [min, max]
function Util.clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

-- Round to N decimals
function Util.round(value: number, decimals: number): number
	local mult = 10 ^ decimals
	return math.floor(value * mult + 0.5) / mult
end

-- Format big numbers: 1234 -> "1.2K", 2500000 -> "2.5M"
function Util.formatNumber(value: number): string
	if value >= 1000000 then
		return string.format("%.1fM", value / 1000000)
	elseif value >= 1000 then
		return string.format("%.1fK", value / 1000)
	end
	return tostring(math.floor(value))
end

-- Weighted random pick from { key = weight }. Returns key or nil if empty.
function Util.weightedPick(weights: { [string]: number }): string?
	local total = 0
	for _, w  in pairs(weights) do
		total += w
	end
	if total <= 0 then
		return nil
	end
	local roll = math.random() * total
	for key, w  in pairs(weights) do
		roll -= w
		if roll <= 0 then
			return key
		end
	end
	-- Fallback: last key (floating point safety)
	local last: string? = nil
	for key, _  in pairs(weights) do
		last = key
	end
	return last
end

-- True with probability p (0..1)
function Util.rollChance(p: number): boolean
	return math.random() < p
end

-- UTC date key "YYYY-MM-DD"
function Util.todayKey(): string
	return os.date("!%Y-%m-%d", os.time())
end

-- UTC week key "YYYY-Www" (matches the same week everywhere on the server)
function Util.weekKey(): string
	return os.date("!%Y-W%W", os.time())
end

-- Yesterday's UTC date key (for streak logic)
function Util.yesterdayKey(): string
	return os.date("!%Y-%m-%d", os.time() - 86400)
end

-- Safe number guard: nil/NaN/Infinity -> fallback
function Util.safeNumber(value: any, fallback: number): number
	if typeof(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge then
		return value
	end
	return fallback
end

-- Shallow copy of a table (catalogs are immutable; copies are for display)
function Util.shallowCopy<T>(t: { [string]: T }): { [string]: T }
	local out: { [string]: T } = {}
	for k, v  in pairs(t) do
		out[k] = v
	end
	return out
end

-- List of keys in a table
function Util.keys(t: { [any]: any }): { any }
	local out = {}
	for k, _  in pairs(t) do
		table.insert(out, k)
	end
	return out
end

-- Weight roll for a fish: skewed toward the low end (min + rand^1.7 * range)
function Util.rollWeight(min: number, max: number): number
	local t = math.random() ^ 1.7
	return Util.round(min + t * (max - min), 1)
end

-- XP needed to advance FROM `level` TO `level + 1`
function Util.xpForLevel(level: number, xpBase: number, exponent: number): number
	return math.floor(xpBase * (level ^ exponent))
end

return Util
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Util')
end

-- ReplicatedStorage/Shared/Remotes
local inst = ensure('ReplicatedStorage/Shared/Remotes', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Remotes
	Single RemoteEvent per direction with a typed message envelope.
	Security: ALL messages funnel through one router and are validated server-side.
	Phase 2 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ensure the remotes folder exists (idempotent on both client and server)
local folder = ReplicatedStorage:FindFirstChild("TideboundRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "TideboundRemotes"
	folder.Parent = ReplicatedStorage
end

local c2s = folder:FindFirstChild("ClientToServer")
if not c2s then
	c2s = Instance.new("RemoteEvent")
	c2s.Name = "ClientToServer"
	c2s.Parent = folder
end

local s2c = folder:FindFirstChild("ServerToClient")
if not s2c then
	s2c = Instance.new("RemoteEvent")
	s2c.Name = "ServerToClient"
	s2c.Parent = folder
end

local Remotes = {
	ClientToServer = c2s :: RemoteEvent,
	ServerToClient = s2c :: RemoteEvent,
}

-- Client -> Server
function Remotes:SendToServer(message)
	self.ClientToServer:FireServer(message)
end

-- Server -> one client
function Remotes:SendToClient(player: Player, message)
	self.ServerToClient:FireClient(player, message)
end

-- Server -> all clients
function Remotes:SendToAll(message)
	self.ServerToClient:FireAllClients(message)
end

-- Server: subscribe to client messages. Handler(player, message).
function Remotes:OnServerMessage(handler: (Player, any) -> ())
	return self.ClientToServer.OnServerEvent:Connect(function(player, message)
		handler(player, message)
	end)
end

-- Client: subscribe to server messages. Handler(message).
function Remotes:OnClientMessage(handler: (any) -> ())
	return self.ServerToClient.OnClientEvent:Connect(function(message)
		handler(message)
	end)
end

return Remotes
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Remotes
	Single RemoteEvent per direction with a typed message envelope.
	Security: ALL messages funnel through one router and are validated server-side.
	Phase 2 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ensure the remotes folder exists (idempotent on both client and server)
local folder = ReplicatedStorage:FindFirstChild("TideboundRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "TideboundRemotes"
	folder.Parent = ReplicatedStorage
end

local c2s = folder:FindFirstChild("ClientToServer")
if not c2s then
	c2s = Instance.new("RemoteEvent")
	c2s.Name = "ClientToServer"
	c2s.Parent = folder
end

local s2c = folder:FindFirstChild("ServerToClient")
if not s2c then
	s2c = Instance.new("RemoteEvent")
	s2c.Name = "ServerToClient"
	s2c.Parent = folder
end

local Remotes = {
	ClientToServer = c2s :: RemoteEvent,
	ServerToClient = s2c :: RemoteEvent,
}

-- Client -> Server
function Remotes:SendToServer(message)
	self.ClientToServer:FireServer(message)
end

-- Server -> one client
function Remotes:SendToClient(player: Player, message)
	self.ServerToClient:FireClient(player, message)
end

-- Server -> all clients
function Remotes:SendToAll(message)
	self.ServerToClient:FireAllClients(message)
end

-- Server: subscribe to client messages. Handler(player, message).
function Remotes:OnServerMessage(handler: (Player, any) -> ())
	return self.ClientToServer.OnServerEvent:Connect(function(player, message)
		handler(player, message)
	end)
end

-- Client: subscribe to server messages. Handler(message).
function Remotes:OnClientMessage(handler: (any) -> ())
	return self.ServerToClient.OnClientEvent:Connect(function(message)
		handler(message)
	end)
end

return Remotes
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Remotes')
end

print("[Installer] Part 1/13 complete - next: 2")
