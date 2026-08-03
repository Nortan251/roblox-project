--[[
	Tidebound — Studio Installer (GENERATED, do not hand-edit)
	Paste this ENTIRE file into Studio's Command Bar (View > Command Bar)
	while signed in. It creates/updates every script for the game.
	Safe to run multiple times (idempotent).
]]

local function getSvc(n) return game:GetService(n) end
local rs = getSvc('ReplicatedStorage')
local sss = getSvc('ServerScriptService')
local sp = getSvc('StarterPlayer'):WaitForChild('StarterPlayerScripts')

-- Build the instance tree; returns each instance by logical path
local created = {}
local starter = getSvc('StarterPlayer')
local function ensure(logical, cls)
	local pathParts = {}
	for part in logical:gmatch('[^/]+') do table.insert(pathParts, part) end
	local root = pathParts[1] == 'ReplicatedStorage' and rs
		or pathParts[1] == 'ServerScriptService' and sss
		or pathParts[1] == 'StarterPlayer' and starter
	if not root then return nil end
	local current = root
	for i = 2, #pathParts do
		local child = current:FindFirstChild(pathParts[i])
		if not child then
			child = Instance.new(i == #pathParts and cls or 'Folder')
			child.Name = pathParts[i]
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
Config.AUTO_TERRAIN = false -- baked island is in the place; runtime terrain optional

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
Config.AUTO_TERRAIN = false -- baked island is in the place; runtime terrain optional

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
		guideFirstCast: boolean,
		guideFirstReel: boolean,
		guideFirstCatch: boolean,
		guideFirstBuy: boolean,
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
		guideFirstCast: boolean,
		guideFirstReel: boolean,
		guideFirstCatch: boolean,
		guideFirstBuy: boolean,
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

-- ReplicatedStorage/Shared/Data/FishCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/FishCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — FishCatalog
	All fish definitions. Content DB — add species here for new updates.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Types = require(script.Parent.Parent.Types)

local FISH: { [string]: Types.FishDef } = {}

local function fish(
	id: string,
	name: string,
	rarity: Types.Rarity,
	baseValue: number,
	minWeight: number,
	maxWeight: number,
	xp: number,
	zone: string,
	family: string,
	desc: string,
	color: Color3,
	accent: Color3,
	bodyScale: number,
	opts: { time: "any" | "night", bait: string?, stormOnly: boolean? }?
): Types.FishDef
	local def: Types.FishDef = {
		id = id,
		name = name,
		rarity = rarity,
		baseValue = baseValue,
		minWeight = minWeight,
		maxWeight = maxWeight,
		xp = xp,
		zone = zone,
		time = opts and opts.time or "any",
		bait = opts and opts.bait,
		family = family,
		desc = desc,
		color = color,
		accent = accent,
		bodyScale = bodyScale,
		stormOnly = opts and opts.stormOnly,
	}
	FISH[id] = def
	return def
end

-- ═══════════ SUNSHALL COVE (starter) ═══════════
fish("sunsail_minnow", "Sunsail Minnow", "common", 4, 0.2, 0.8, 8, "sunshall", "shoal",
	"A cheerful little fish that follows boats. Perfect first catch.", Color3.fromRGB(210, 200, 120), Color3.fromRGB(255, 240, 160), 0.7)
fish("reef_perch", "Reef Perch", "common", 5, 0.5, 1.5, 9, "sunshall", "reef",
	"Stubborn but plentiful. Hides among the pier posts.", Color3.fromRGB(190, 120, 80), Color3.fromRGB(120, 80, 60), 0.9)
fish("cove_carp", "Cove Carp", "uncommon", 10, 1.0, 3.0, 20, "sunshall", "carp",
	"Lazy bottom feeder. Loves worms.", Color3.fromRGB(140, 160, 130), Color3.fromRGB(90, 110, 85), 1.1, { bait = "worm" })
fish("striped_grunt", "Striped Grunt", "uncommon", 9, 0.8, 2.2, 18, "sunshall", "reef",
	"Makes a grunting sound when annoyed. Locals find it hilarious.", Color3.fromRGB(150, 160, 170), Color3.fromRGB(60, 70, 80), 1.0)
fish("golden_anchovy", "Golden Anchovy", "rare", 25, 0.1, 0.4, 50, "sunshall", "shoal",
	"A tiny flash of gold. Worth far more than its size suggests.", Color3.fromRGB(255, 205, 60), Color3.fromRGB(255, 250, 200), 0.5)
fish("moon_koi", "Moon Koi", "rare", 40, 1.5, 4.0, 65, "sunshall", "koi",
	"Only swims in moonlight. Its scales glow like the moon's reflection.", Color3.fromRGB(190, 200, 255), Color3.fromRGB(120, 140, 255), 1.3, { time = "night" })
fish("sunsong_sturgeon", "Sunsong Sturgeon", "epic", 90, 5.0, 12.0, 140, "sunshall", "sturgeon",
	"An ancient fish said to hum along with the sunrise.", Color3.fromRGB(110, 140, 170), Color3.fromRGB(200, 220, 235), 2.2, { bait = "shrimp" })
fish("gilded_bass", "Gilded Bass", "legendary", 220, 8.0, 20.0, 320, "sunshall", "bass",
	"Legend says whoever catches it is blessed with good luck for a week.", Color3.fromRGB(255, 190, 40), Color3.fromRGB(255, 240, 150), 1.8)

-- ═══════════ WHISPER SHALLOWS ═══════════
fish("shimmerfin", "Whisper Shimmerfin", "common", 7, 0.4, 1.2, 12, "whisper", "shoal",
	"Its scales shimmer like the shallow water it calls home.", Color3.fromRGB(120, 200, 210), Color3.fromRGB(200, 255, 250), 0.8)
fish("drift_mackerel", "Drift Mackerel", "common", 8, 1.0, 3.0, 14, "whisper", "shoal",
	"Travels in huge schools. Where you see one, you see hundreds.", Color3.fromRGB(80, 130, 190), Color3.fromRGB(40, 70, 110), 1.2)
fish("seagrass_snapper", "Seagrass Snapper", "uncommon", 13, 2.0, 6.0, 24, "whisper", "reef",
	"Patient ambush hunter of the seagrass beds.", Color3.fromRGB(230, 120, 90), Color3.fromRGB(160, 70, 50), 1.3)
fish("silver_carp", "Silver Carp", "uncommon", 12, 2.0, 5.0, 22, "whisper", "carp",
	"Leaps out of the water when startled. Bring worms.", Color3.fromRGB(190, 200, 210), Color3.fromRGB(120, 130, 140), 1.2, { bait = "worm" })
fish("whisper_lanternfish", "Whisper Lanternfish", "rare", 45, 0.3, 0.9, 70, "whisper", "glow",
	"A living firefly of the shallows. Only visible after dark.", Color3.fromRGB(120, 255, 200), Color3.fromRGB(255, 255, 220), 0.6, { time = "night" })
fish("moonlit_koi", "Moonlit Koi", "rare", 55, 2.0, 6.0, 80, "whisper", "koi",
	"A paler cousin of the Moon Koi, with a violet sheen.", Color3.fromRGB(180, 170, 255), Color3.fromRGB(90, 80, 200), 1.4, { time = "night" })
fish("kelp_serpent", "Kelp Serpent", "epic", 95, 10.0, 25.0, 150, "whisper", "serpent",
	"A long, sinewy hunter that mimics kelp. Do not touch the fins.", Color3.fromRGB(60, 140, 90), Color3.fromRGB(30, 80, 50), 3.0, { bait = "squid" })
fish("tide_hunter", "Tide Hunter", "legendary", 240, 15.0, 40.0, 340, "whisper", "hunter",
	"Follows the tide in from the deep. Fast, angry, unforgettable.", Color3.fromRGB(70, 100, 140), Color3.fromRGB(20, 30, 50), 2.6)

-- ═══════════ THE DROP ═══════════
fish("deep_darter", "Deep Darter", "common", 12, 1.0, 4.0, 18, "drop", "shoal",
	"The first sign you've left the shallows behind.", Color3.fromRGB(60, 90, 140), Color3.fromRGB(30, 50, 80), 1.1)
fish("cliff_cod", "Cliff Cod", "uncommon", 18, 3.0, 8.0, 30, "drop", "cod",
	"Bulky, dependable, slightly grumpy.", Color3.fromRGB(110, 120, 110), Color3.fromRGB(70, 80, 70), 1.6, { bait = "worm" })
fish("drop_anglerfish", "Drop Anglerfish", "rare", 55, 3.0, 9.0, 85, "drop", "angler",
	"Carries its own lantern. The light is a lie.", Color3.fromRGB(50, 50, 70), Color3.fromRGB(120, 255, 220), 1.4, { bait = "squid" })
fish("abyssal_squid", "Abyssal Squid", "rare", 60, 2.0, 7.0, 90, "drop", "squid",
	"Ghost-pale tentacles that dance in the dark water.", Color3.fromRGB(220, 220, 240), Color3.fromRGB(255, 150, 200), 1.5, { time = "night", bait = "squid" })
fish("trench_eel", "Trench Eel", "epic", 110, 8.0, 20.0, 170, "drop", "eel",
	"Slips through crevices no fish should fit through.", Color3.fromRGB(40, 80, 90), Color3.fromRGB(120, 200, 200), 2.4, { bait = "squid" })
fish("fog_wraith", "Fog Wraith", "legendary", 260, 20.0, 50.0, 360, "drop", "wraith",
	"Some say it is not a fish at all, but the fog that got lost.", Color3.fromRGB(200, 210, 225), Color3.fromRGB(255, 255, 255), 2.8, { time = "night" })

-- ═══════════ EMBER FALLS ═══════════
fish("ember_trout", "Ember Trout", "common", 16, 1.0, 5.0, 22, "ember", "trout",
	"Thrives in water warmed by volcanic vents.", Color3.fromRGB(230, 120, 50), Color3.fromRGB(255, 180, 80), 1.0)
fish("ash_gar", "Ash Gar", "uncommon", 24, 3.0, 9.0, 35, "ember", "gar",
	"A needle-nosed predator of the ash-strewn shore.", Color3.fromRGB(90, 90, 100), Color3.fromRGB(50, 50, 55), 1.8, { bait = "worm" })
fish("magma_eel", "Magma Eel", "rare", 70, 4.0, 12.0, 100, "ember", "eel",
	"Glows like cooling lava. Handle with respect.", Color3.fromRGB(255, 90, 30), Color3.fromRGB(255, 200, 60), 2.0, { bait = "squid" })
fish("cinder_salmon", "Cinder Salmon", "rare", 80, 5.0, 14.0, 110, "ember", "salmon",
	"Swims UP the waterfalls. No one knows how.", Color3.fromRGB(240, 140, 90), Color3.fromRGB(255, 220, 180), 1.5, { bait = "shrimp" })
fish("ember_pike", "Ember Pike", "epic", 140, 10.0, 25.0, 200, "ember", "pike",
	"A furnace of muscle and teeth.", Color3.fromRGB(180, 70, 30), Color3.fromRGB(255, 140, 60), 2.2)
fish("magma_whale", "Magma Whale", "legendary", 300, 60.0, 140.0, 400, "ember", "whale",
	"The gentle giant of the caldera. Its song melts ice from miles away.", Color3.fromRGB(120, 60, 40), Color3.fromRGB(255, 120, 50), 4.5)
fish("ember_leviathan", "Ember Leviathan", "legendary", 320, 40.0, 90.0, 420, "ember", "leviathan",
	"Legends say the volcano itself once had a heartbeat.", Color3.fromRGB(90, 40, 30), Color3.fromRGB(255, 90, 20), 3.8)
fish("storm_krakenling", "Storm Krakenling", "mythic", 1200, 50.0, 120.0, 1000, "ember", "storm",
	"Born in the lightning. Only appears when the sky tears open.", Color3.fromRGB(60, 90, 180), Color3.fromRGB(200, 220, 255), 3.5, { stormOnly = true })

-- ═══════════ FROSTREACH ═══════════
fish("frostling_pike", "Frostling Pike", "common", 22, 2.0, 7.0, 28, "frost", "pike",
	"Cold-blooded in every sense. Aggressive year-round.", Color3.fromRGB(140, 190, 210), Color3.fromRGB(80, 120, 140), 1.6)
fish("iceback_herring", "Iceback Herring", "common", 30, 1.0, 4.0, 40, "frost", "shoal",
	"Its back freezes into a natural armor plate.", Color3.fromRGB(170, 200, 230), Color3.fromRGB(230, 245, 255), 0.9)
fish("snowcap_char", "Snowcap Char", "rare", 95, 4.0, 12.0, 130, "frost", "char",
	"Wears a white 'cap' that looks knitted by glaciers.", Color3.fromRGB(220, 80, 60), Color3.fromRGB(255, 255, 255), 1.3, { bait = "worm" })
fish("aurora_koi", "Aurora Koi", "rare", 110, 3.0, 10.0, 140, "frost", "koi",
	"Drinks the northern lights. Swim under the aurora to see it shine.", Color3.fromRGB(120, 255, 160), Color3.fromRGB(255, 120, 240), 1.4, { time = "night" })
fish("glacier_eel", "Glacier Eel", "epic", 180, 15.0, 35.0, 240, "frost", "eel",
	"Sleeps for years inside the ice. Wakes hungry.", Color3.fromRGB(90, 140, 180), Color3.fromRGB(200, 230, 255), 2.6, { bait = "squid" })
fish("frost_whale", "Frost Whale", "legendary", 380, 80.0, 180.0, 480, "frost", "whale",
	"An iceberg with a heartbeat. The sea freezes where it dives.", Color3.fromRGB(160, 190, 220), Color3.fromRGB(235, 245, 255), 4.8)
fish("frost_leviathan", "Frostbound Leviathan", "legendary", 400, 60.0, 150.0, 500, "frost", "leviathan",
	"Scars on its hide match the cracks in the ancient ice sheets.", Color3.fromRGB(120, 150, 190), Color3.fromRGB(255, 255, 255), 4.2)
fish("aurora_serpent", "Aurora Serpent", "mythic", 1500, 40.0, 100.0, 1200, "frost", "serpent",
	"A ribbon of living light. Seeing one is a once-in-a-lifetime gift.", Color3.fromRGB(100, 255, 200), Color3.fromRGB(255, 140, 255), 3.6, { time = "night" })

-- ═══════════ ABYSSAL TRENCH ═══════════
fish("trench_fangtooth", "Trench Fangtooth", "common", 30, 1.0, 5.0, 35, "abyss", "fang",
	"All teeth and no patience.", Color3.fromRGB(70, 70, 90), Color3.fromRGB(200, 60, 60), 1.2)
fish("void_lanternfish", "Void Lanternfish", "uncommon", 40, 0.5, 2.0, 50, "abyss", "glow",
	"A constellation swimming in the dark.", Color3.fromRGB(80, 120, 255), Color3.fromRGB(200, 220, 255), 0.8)
fish("abyssal_angler", "Abyssal Angler", "rare", 120, 6.0, 16.0, 160, "abyss", "angler",
	"The deep's most successful liar.", Color3.fromRGB(60, 60, 80), Color3.fromRGB(80, 255, 200), 1.8, { bait = "squid" })
fish("gloom_serpent", "Gloom Serpent", "epic", 220, 20.0, 45.0, 280, "abyss", "serpent",
	"Feeds on the silence of the trench.", Color3.fromRGB(50, 60, 90), Color3.fromRGB(140, 160, 220), 3.2, { bait = "squid" })
fish("abyssal_hunter", "Abyssal Hunter", "legendary", 480, 50.0, 130.0, 600, "abyss", "hunter",
	"Nothing in the trench is faster. Nothing is safer either.", Color3.fromRGB(40, 50, 70), Color3.fromRGB(120, 60, 200), 3.4)
fish("trench_devil", "Trench Devil", "legendary", 520, 60.0, 150.0, 620, "abyss", "devil",
	"When the trench goes silent, it is hunting.", Color3.fromRGB(140, 40, 60), Color3.fromRGB(255, 80, 60), 3.6, { time = "night" })
fish("leviathan_abyss", "Abyssal Leviathan", "mythic", 2200, 150.0, 400.0, 2000, "abyss", "leviathan",
	"The reason sailors check under the boat at night.", Color3.fromRGB(50, 70, 110), Color3.fromRGB(100, 200, 255), 5.0)
fish("stormcaller_eel", "Stormcaller Eel", "mythic", 2000, 80.0, 200.0, 1800, "abyss", "storm",
	"Some storms aren't weather. They're this.", Color3.fromRGB(40, 60, 140), Color3.fromRGB(220, 230, 255), 4.0, { stormOnly = true })
fish("old_one", "The Old One", "mythic", 2500, 200.0, 500.0, 2500, "abyss", "old",
	"Older than the islands. Older than the ocean. It remembers your name.",
	Color3.fromRGB(30, 90, 70), Color3.fromRGB(160, 255, 200), 5.5)

-- ═══════════ HIDDEN ISLES & GROTTO (secrets) ═══════════
fish("mistfin", "Mistfin", "rare", 90, 1.0, 4.0, 130, "hidden_isles", "mist",
	"A fish that looks like fog over water. Found only at the hidden isle.", Color3.fromRGB(210, 220, 230), Color3.fromRGB(255, 255, 255), 1.0)
fish("isle_song", "Isle Song", "legendary", 350, 15.0, 35.0, 450, "hidden_isles", "mist",
	"Its scales hum a melody the wind keeps forgetting.", Color3.fromRGB(150, 200, 255), Color3.fromRGB(255, 240, 200), 2.4)
fish("grotto_glowfin", "Grotto Glowfin", "rare", 100, 1.0, 3.0, 140, "sunken_grotto", "glow",
	"The grotto's only light source. Catch it and the cave goes dark.", Color3.fromRGB(120, 255, 255), Color3.fromRGB(255, 255, 160), 0.9)
fish("sunken_king", "Sunken King", "legendary", 450, 30.0, 70.0, 550, "sunken_grotto", "king",
	"Once the ruler of a drowned court. Now it guards what sank with it.", Color3.fromRGB(180, 160, 90), Color3.fromRGB(120, 90, 40), 3.0)

-- ═══════════ UNIVERSAL STORM FISH (any zone during a storm) ═══════════
fish("storm_sprat", "Storm Sprat", "uncommon", 20, 0.3, 1.0, 30, "storm_any", "storm",
	"Rides the storm waves for fun. Reckless little thing.", Color3.fromRGB(150, 160, 190), Color3.fromRGB(230, 240, 255), 0.7, { stormOnly = true })
fish("gale_herring", "Gale Herring", "rare", 85, 2.0, 6.0, 120, "storm_any", "storm",
	"Swims faster than the wind. Almost.", Color3.fromRGB(120, 140, 200), Color3.fromRGB(200, 220, 255), 1.2, { stormOnly = true })

-- ═══════════ Catalog API ═══════════

local FishCatalog = {}

function FishCatalog.Get(id: string): Types.FishDef?
	return FISH[id]
end

function FishCatalog.GetAll(): { [string]: Types.FishDef }
	return FISH
end

-- All fish catchable in a zone under current conditions.
-- `storm` adds storm fish; `night` adds night-only fish.
function FishCatalog.GetZoneFish(zoneId: string, night: boolean, storm: boolean): { Types.FishDef }
	local out: { Types.FishDef } = {}
	for _, def  in pairs(FISH) do
		local inZone = def.zone == zoneId
		local isUniversalStorm = def.zone == "storm_any"
		local isStormFish = def.stormOnly == true
		if inZone or (storm and isUniversalStorm) then
			if isStormFish and not storm then
				continue
			end
			if def.time == "night" and not night then
				continue
			end
			table.insert(out, def)
		end
	end
	return out
end

function FishCatalog.CountInZone(zoneId: string): number
	local n = 0
	for _, def  in pairs(FISH) do
		if def.zone == zoneId then
			n += 1
		end
	end
	return n
end

return FishCatalog
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — FishCatalog
	All fish definitions. Content DB — add species here for new updates.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Types = require(script.Parent.Parent.Types)

local FISH: { [string]: Types.FishDef } = {}

local function fish(
	id: string,
	name: string,
	rarity: Types.Rarity,
	baseValue: number,
	minWeight: number,
	maxWeight: number,
	xp: number,
	zone: string,
	family: string,
	desc: string,
	color: Color3,
	accent: Color3,
	bodyScale: number,
	opts: { time: "any" | "night", bait: string?, stormOnly: boolean? }?
): Types.FishDef
	local def: Types.FishDef = {
		id = id,
		name = name,
		rarity = rarity,
		baseValue = baseValue,
		minWeight = minWeight,
		maxWeight = maxWeight,
		xp = xp,
		zone = zone,
		time = opts and opts.time or "any",
		bait = opts and opts.bait,
		family = family,
		desc = desc,
		color = color,
		accent = accent,
		bodyScale = bodyScale,
		stormOnly = opts and opts.stormOnly,
	}
	FISH[id] = def
	return def
end

-- ═══════════ SUNSHALL COVE (starter) ═══════════
fish("sunsail_minnow", "Sunsail Minnow", "common", 4, 0.2, 0.8, 8, "sunshall", "shoal",
	"A cheerful little fish that follows boats. Perfect first catch.", Color3.fromRGB(210, 200, 120), Color3.fromRGB(255, 240, 160), 0.7)
fish("reef_perch", "Reef Perch", "common", 5, 0.5, 1.5, 9, "sunshall", "reef",
	"Stubborn but plentiful. Hides among the pier posts.", Color3.fromRGB(190, 120, 80), Color3.fromRGB(120, 80, 60), 0.9)
fish("cove_carp", "Cove Carp", "uncommon", 10, 1.0, 3.0, 20, "sunshall", "carp",
	"Lazy bottom feeder. Loves worms.", Color3.fromRGB(140, 160, 130), Color3.fromRGB(90, 110, 85), 1.1, { bait = "worm" })
fish("striped_grunt", "Striped Grunt", "uncommon", 9, 0.8, 2.2, 18, "sunshall", "reef",
	"Makes a grunting sound when annoyed. Locals find it hilarious.", Color3.fromRGB(150, 160, 170), Color3.fromRGB(60, 70, 80), 1.0)
fish("golden_anchovy", "Golden Anchovy", "rare", 25, 0.1, 0.4, 50, "sunshall", "shoal",
	"A tiny flash of gold. Worth far more than its size suggests.", Color3.fromRGB(255, 205, 60), Color3.fromRGB(255, 250, 200), 0.5)
fish("moon_koi", "Moon Koi", "rare", 40, 1.5, 4.0, 65, "sunshall", "koi",
	"Only swims in moonlight. Its scales glow like the moon's reflection.", Color3.fromRGB(190, 200, 255), Color3.fromRGB(120, 140, 255), 1.3, { time = "night" })
fish("sunsong_sturgeon", "Sunsong Sturgeon", "epic", 90, 5.0, 12.0, 140, "sunshall", "sturgeon",
	"An ancient fish said to hum along with the sunrise.", Color3.fromRGB(110, 140, 170), Color3.fromRGB(200, 220, 235), 2.2, { bait = "shrimp" })
fish("gilded_bass", "Gilded Bass", "legendary", 220, 8.0, 20.0, 320, "sunshall", "bass",
	"Legend says whoever catches it is blessed with good luck for a week.", Color3.fromRGB(255, 190, 40), Color3.fromRGB(255, 240, 150), 1.8)

-- ═══════════ WHISPER SHALLOWS ═══════════
fish("shimmerfin", "Whisper Shimmerfin", "common", 7, 0.4, 1.2, 12, "whisper", "shoal",
	"Its scales shimmer like the shallow water it calls home.", Color3.fromRGB(120, 200, 210), Color3.fromRGB(200, 255, 250), 0.8)
fish("drift_mackerel", "Drift Mackerel", "common", 8, 1.0, 3.0, 14, "whisper", "shoal",
	"Travels in huge schools. Where you see one, you see hundreds.", Color3.fromRGB(80, 130, 190), Color3.fromRGB(40, 70, 110), 1.2)
fish("seagrass_snapper", "Seagrass Snapper", "uncommon", 13, 2.0, 6.0, 24, "whisper", "reef",
	"Patient ambush hunter of the seagrass beds.", Color3.fromRGB(230, 120, 90), Color3.fromRGB(160, 70, 50), 1.3)
fish("silver_carp", "Silver Carp", "uncommon", 12, 2.0, 5.0, 22, "whisper", "carp",
	"Leaps out of the water when startled. Bring worms.", Color3.fromRGB(190, 200, 210), Color3.fromRGB(120, 130, 140), 1.2, { bait = "worm" })
fish("whisper_lanternfish", "Whisper Lanternfish", "rare", 45, 0.3, 0.9, 70, "whisper", "glow",
	"A living firefly of the shallows. Only visible after dark.", Color3.fromRGB(120, 255, 200), Color3.fromRGB(255, 255, 220), 0.6, { time = "night" })
fish("moonlit_koi", "Moonlit Koi", "rare", 55, 2.0, 6.0, 80, "whisper", "koi",
	"A paler cousin of the Moon Koi, with a violet sheen.", Color3.fromRGB(180, 170, 255), Color3.fromRGB(90, 80, 200), 1.4, { time = "night" })
fish("kelp_serpent", "Kelp Serpent", "epic", 95, 10.0, 25.0, 150, "whisper", "serpent",
	"A long, sinewy hunter that mimics kelp. Do not touch the fins.", Color3.fromRGB(60, 140, 90), Color3.fromRGB(30, 80, 50), 3.0, { bait = "squid" })
fish("tide_hunter", "Tide Hunter", "legendary", 240, 15.0, 40.0, 340, "whisper", "hunter",
	"Follows the tide in from the deep. Fast, angry, unforgettable.", Color3.fromRGB(70, 100, 140), Color3.fromRGB(20, 30, 50), 2.6)

-- ═══════════ THE DROP ═══════════
fish("deep_darter", "Deep Darter", "common", 12, 1.0, 4.0, 18, "drop", "shoal",
	"The first sign you've left the shallows behind.", Color3.fromRGB(60, 90, 140), Color3.fromRGB(30, 50, 80), 1.1)
fish("cliff_cod", "Cliff Cod", "uncommon", 18, 3.0, 8.0, 30, "drop", "cod",
	"Bulky, dependable, slightly grumpy.", Color3.fromRGB(110, 120, 110), Color3.fromRGB(70, 80, 70), 1.6, { bait = "worm" })
fish("drop_anglerfish", "Drop Anglerfish", "rare", 55, 3.0, 9.0, 85, "drop", "angler",
	"Carries its own lantern. The light is a lie.", Color3.fromRGB(50, 50, 70), Color3.fromRGB(120, 255, 220), 1.4, { bait = "squid" })
fish("abyssal_squid", "Abyssal Squid", "rare", 60, 2.0, 7.0, 90, "drop", "squid",
	"Ghost-pale tentacles that dance in the dark water.", Color3.fromRGB(220, 220, 240), Color3.fromRGB(255, 150, 200), 1.5, { time = "night", bait = "squid" })
fish("trench_eel", "Trench Eel", "epic", 110, 8.0, 20.0, 170, "drop", "eel",
	"Slips through crevices no fish should fit through.", Color3.fromRGB(40, 80, 90), Color3.fromRGB(120, 200, 200), 2.4, { bait = "squid" })
fish("fog_wraith", "Fog Wraith", "legendary", 260, 20.0, 50.0, 360, "drop", "wraith",
	"Some say it is not a fish at all, but the fog that got lost.", Color3.fromRGB(200, 210, 225), Color3.fromRGB(255, 255, 255), 2.8, { time = "night" })

-- ═══════════ EMBER FALLS ═══════════
fish("ember_trout", "Ember Trout", "common", 16, 1.0, 5.0, 22, "ember", "trout",
	"Thrives in water warmed by volcanic vents.", Color3.fromRGB(230, 120, 50), Color3.fromRGB(255, 180, 80), 1.0)
fish("ash_gar", "Ash Gar", "uncommon", 24, 3.0, 9.0, 35, "ember", "gar",
	"A needle-nosed predator of the ash-strewn shore.", Color3.fromRGB(90, 90, 100), Color3.fromRGB(50, 50, 55), 1.8, { bait = "worm" })
fish("magma_eel", "Magma Eel", "rare", 70, 4.0, 12.0, 100, "ember", "eel",
	"Glows like cooling lava. Handle with respect.", Color3.fromRGB(255, 90, 30), Color3.fromRGB(255, 200, 60), 2.0, { bait = "squid" })
fish("cinder_salmon", "Cinder Salmon", "rare", 80, 5.0, 14.0, 110, "ember", "salmon",
	"Swims UP the waterfalls. No one knows how.", Color3.fromRGB(240, 140, 90), Color3.fromRGB(255, 220, 180), 1.5, { bait = "shrimp" })
fish("ember_pike", "Ember Pike", "epic", 140, 10.0, 25.0, 200, "ember", "pike",
	"A furnace of muscle and teeth.", Color3.fromRGB(180, 70, 30), Color3.fromRGB(255, 140, 60), 2.2)
fish("magma_whale", "Magma Whale", "legendary", 300, 60.0, 140.0, 400, "ember", "whale",
	"The gentle giant of the caldera. Its song melts ice from miles away.", Color3.fromRGB(120, 60, 40), Color3.fromRGB(255, 120, 50), 4.5)
fish("ember_leviathan", "Ember Leviathan", "legendary", 320, 40.0, 90.0, 420, "ember", "leviathan",
	"Legends say the volcano itself once had a heartbeat.", Color3.fromRGB(90, 40, 30), Color3.fromRGB(255, 90, 20), 3.8)
fish("storm_krakenling", "Storm Krakenling", "mythic", 1200, 50.0, 120.0, 1000, "ember", "storm",
	"Born in the lightning. Only appears when the sky tears open.", Color3.fromRGB(60, 90, 180), Color3.fromRGB(200, 220, 255), 3.5, { stormOnly = true })

-- ═══════════ FROSTREACH ═══════════
fish("frostling_pike", "Frostling Pike", "common", 22, 2.0, 7.0, 28, "frost", "pike",
	"Cold-blooded in every sense. Aggressive year-round.", Color3.fromRGB(140, 190, 210), Color3.fromRGB(80, 120, 140), 1.6)
fish("iceback_herring", "Iceback Herring", "common", 30, 1.0, 4.0, 40, "frost", "shoal",
	"Its back freezes into a natural armor plate.", Color3.fromRGB(170, 200, 230), Color3.fromRGB(230, 245, 255), 0.9)
fish("snowcap_char", "Snowcap Char", "rare", 95, 4.0, 12.0, 130, "frost", "char",
	"Wears a white 'cap' that looks knitted by glaciers.", Color3.fromRGB(220, 80, 60), Color3.fromRGB(255, 255, 255), 1.3, { bait = "worm" })
fish("aurora_koi", "Aurora Koi", "rare", 110, 3.0, 10.0, 140, "frost", "koi",
	"Drinks the northern lights. Swim under the aurora to see it shine.", Color3.fromRGB(120, 255, 160), Color3.fromRGB(255, 120, 240), 1.4, { time = "night" })
fish("glacier_eel", "Glacier Eel", "epic", 180, 15.0, 35.0, 240, "frost", "eel",
	"Sleeps for years inside the ice. Wakes hungry.", Color3.fromRGB(90, 140, 180), Color3.fromRGB(200, 230, 255), 2.6, { bait = "squid" })
fish("frost_whale", "Frost Whale", "legendary", 380, 80.0, 180.0, 480, "frost", "whale",
	"An iceberg with a heartbeat. The sea freezes where it dives.", Color3.fromRGB(160, 190, 220), Color3.fromRGB(235, 245, 255), 4.8)
fish("frost_leviathan", "Frostbound Leviathan", "legendary", 400, 60.0, 150.0, 500, "frost", "leviathan",
	"Scars on its hide match the cracks in the ancient ice sheets.", Color3.fromRGB(120, 150, 190), Color3.fromRGB(255, 255, 255), 4.2)
fish("aurora_serpent", "Aurora Serpent", "mythic", 1500, 40.0, 100.0, 1200, "frost", "serpent",
	"A ribbon of living light. Seeing one is a once-in-a-lifetime gift.", Color3.fromRGB(100, 255, 200), Color3.fromRGB(255, 140, 255), 3.6, { time = "night" })

-- ═══════════ ABYSSAL TRENCH ═══════════
fish("trench_fangtooth", "Trench Fangtooth", "common", 30, 1.0, 5.0, 35, "abyss", "fang",
	"All teeth and no patience.", Color3.fromRGB(70, 70, 90), Color3.fromRGB(200, 60, 60), 1.2)
fish("void_lanternfish", "Void Lanternfish", "uncommon", 40, 0.5, 2.0, 50, "abyss", "glow",
	"A constellation swimming in the dark.", Color3.fromRGB(80, 120, 255), Color3.fromRGB(200, 220, 255), 0.8)
fish("abyssal_angler", "Abyssal Angler", "rare", 120, 6.0, 16.0, 160, "abyss", "angler",
	"The deep's most successful liar.", Color3.fromRGB(60, 60, 80), Color3.fromRGB(80, 255, 200), 1.8, { bait = "squid" })
fish("gloom_serpent", "Gloom Serpent", "epic", 220, 20.0, 45.0, 280, "abyss", "serpent",
	"Feeds on the silence of the trench.", Color3.fromRGB(50, 60, 90), Color3.fromRGB(140, 160, 220), 3.2, { bait = "squid" })
fish("abyssal_hunter", "Abyssal Hunter", "legendary", 480, 50.0, 130.0, 600, "abyss", "hunter",
	"Nothing in the trench is faster. Nothing is safer either.", Color3.fromRGB(40, 50, 70), Color3.fromRGB(120, 60, 200), 3.4)
fish("trench_devil", "Trench Devil", "legendary", 520, 60.0, 150.0, 620, "abyss", "devil",
	"When the trench goes silent, it is hunting.", Color3.fromRGB(140, 40, 60), Color3.fromRGB(255, 80, 60), 3.6, { time = "night" })
fish("leviathan_abyss", "Abyssal Leviathan", "mythic", 2200, 150.0, 400.0, 2000, "abyss", "leviathan",
	"The reason sailors check under the boat at night.", Color3.fromRGB(50, 70, 110), Color3.fromRGB(100, 200, 255), 5.0)
fish("stormcaller_eel", "Stormcaller Eel", "mythic", 2000, 80.0, 200.0, 1800, "abyss", "storm",
	"Some storms aren't weather. They're this.", Color3.fromRGB(40, 60, 140), Color3.fromRGB(220, 230, 255), 4.0, { stormOnly = true })
fish("old_one", "The Old One", "mythic", 2500, 200.0, 500.0, 2500, "abyss", "old",
	"Older than the islands. Older than the ocean. It remembers your name.",
	Color3.fromRGB(30, 90, 70), Color3.fromRGB(160, 255, 200), 5.5)

-- ═══════════ HIDDEN ISLES & GROTTO (secrets) ═══════════
fish("mistfin", "Mistfin", "rare", 90, 1.0, 4.0, 130, "hidden_isles", "mist",
	"A fish that looks like fog over water. Found only at the hidden isle.", Color3.fromRGB(210, 220, 230), Color3.fromRGB(255, 255, 255), 1.0)
fish("isle_song", "Isle Song", "legendary", 350, 15.0, 35.0, 450, "hidden_isles", "mist",
	"Its scales hum a melody the wind keeps forgetting.", Color3.fromRGB(150, 200, 255), Color3.fromRGB(255, 240, 200), 2.4)
fish("grotto_glowfin", "Grotto Glowfin", "rare", 100, 1.0, 3.0, 140, "sunken_grotto", "glow",
	"The grotto's only light source. Catch it and the cave goes dark.", Color3.fromRGB(120, 255, 255), Color3.fromRGB(255, 255, 160), 0.9)
fish("sunken_king", "Sunken King", "legendary", 450, 30.0, 70.0, 550, "sunken_grotto", "king",
	"Once the ruler of a drowned court. Now it guards what sank with it.", Color3.fromRGB(180, 160, 90), Color3.fromRGB(120, 90, 40), 3.0)

-- ═══════════ UNIVERSAL STORM FISH (any zone during a storm) ═══════════
fish("storm_sprat", "Storm Sprat", "uncommon", 20, 0.3, 1.0, 30, "storm_any", "storm",
	"Rides the storm waves for fun. Reckless little thing.", Color3.fromRGB(150, 160, 190), Color3.fromRGB(230, 240, 255), 0.7, { stormOnly = true })
fish("gale_herring", "Gale Herring", "rare", 85, 2.0, 6.0, 120, "storm_any", "storm",
	"Swims faster than the wind. Almost.", Color3.fromRGB(120, 140, 200), Color3.fromRGB(200, 220, 255), 1.2, { stormOnly = true })

-- ═══════════ Catalog API ═══════════

local FishCatalog = {}

function FishCatalog.Get(id: string): Types.FishDef?
	return FISH[id]
end

function FishCatalog.GetAll(): { [string]: Types.FishDef }
	return FISH
end

-- All fish catchable in a zone under current conditions.
-- `storm` adds storm fish; `night` adds night-only fish.
function FishCatalog.GetZoneFish(zoneId: string, night: boolean, storm: boolean): { Types.FishDef }
	local out: { Types.FishDef } = {}
	for _, def  in pairs(FISH) do
		local inZone = def.zone == zoneId
		local isUniversalStorm = def.zone == "storm_any"
		local isStormFish = def.stormOnly == true
		if inZone or (storm and isUniversalStorm) then
			if isStormFish and not storm then
				continue
			end
			if def.time == "night" and not night then
				continue
			end
			table.insert(out, def)
		end
	end
	return out
end

function FishCatalog.CountInZone(zoneId: string): number
	local n = 0
	for _, def  in pairs(FISH) do
		if def.zone == zoneId then
			n += 1
		end
	end
	return n
end

return FishCatalog
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/FishCatalog')
end

-- ReplicatedStorage/Shared/Data/RodCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/RodCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — RodCatalog
	The core upgrade ladder. Each rod: luck, strength, lure speed.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Types = require(script.Parent.Parent.Types)

local RODS: { [string]: Types.RodDef } = {}

local function rod(
	id: string,
	name: string,
	cost: number,
	luck: number,
	strength: number,
	lure: number,
	unlockLevel: number,
	desc: string,
	color: Color3
): Types.RodDef
	local def: Types.RodDef = {
		id = id,
		name = name,
		cost = cost,
		luck = luck,
		strength = strength,
		lure = lure,
		unlockLevel = unlockLevel,
		desc = desc,
		color = color,
	}
	RODS[id] = def
	return def
end

rod("bamboo", "Bamboo Rod", 0, 0.00, 2, 0, 1, "The Old Salt's gift. Simple, honest, reliable.", Color3.fromRGB(180, 150, 90))
rod("river_oak", "River Oak Rod", 150, 0.03, 3, 1, 2, "Carved from driftwood. A touch more reach.", Color3.fromRGB(140, 100, 60))
rod("coral_reed", "Coral Reed Rod", 450, 0.07, 4, 2, 6, "Grows back every season, stronger each time.", Color3.fromRGB(255, 140, 160))
rod("storm_runner", "Storm Runner Rod", 1400, 0.12, 5, 3, 12, "Forged from a ship's mast that survived a hurricane.", Color3.fromRGB(90, 120, 200))
rod("ember_spine", "Ember Spine Rod", 4000, 0.18, 6, 4, 20, "Tempered in volcanic springs. Warm to the touch.", Color3.fromRGB(255, 90, 40))
rod("frostbound", "Frostbound Rod", 11000, 0.25, 7, 5, 28, "Cut from the heart of a glacier. Never thaws.", Color3.fromRGB(170, 210, 255))
rod("abyss_caller", "Abyss Caller Rod", 28000, 0.35, 8, 6, 36, "Whispers to the deep. The deep whispers back.", Color3.fromRGB(110, 70, 200))
rod("leviathan", "Leviathan Rod", 70000, 0.50, 10, 7, 45, "Woven from the sinew of a leviathan. It remembers how to fight.", Color3.fromRGB(40, 140, 120))

local RodCatalog = {}

function RodCatalog.Get(id: string): Types.RodDef?
	return RODS[id]
end

function RodCatalog.GetAll(): { [string]: Types.RodDef }
	return RODS
end

-- Rods sorted by cost (for shop display)
function RodCatalog.GetSorted(): { Types.RodDef }
	local out: { Types.RodDef } = {}
	for _, def  in pairs(RODS) do
		table.insert(out, def)
	end
	table.sort(out, function(a, b)
		return a.cost < b.cost
	end)
	return out
end

return RodCatalog
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — RodCatalog
	The core upgrade ladder. Each rod: luck, strength, lure speed.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Types = require(script.Parent.Parent.Types)

local RODS: { [string]: Types.RodDef } = {}

local function rod(
	id: string,
	name: string,
	cost: number,
	luck: number,
	strength: number,
	lure: number,
	unlockLevel: number,
	desc: string,
	color: Color3
): Types.RodDef
	local def: Types.RodDef = {
		id = id,
		name = name,
		cost = cost,
		luck = luck,
		strength = strength,
		lure = lure,
		unlockLevel = unlockLevel,
		desc = desc,
		color = color,
	}
	RODS[id] = def
	return def
end

rod("bamboo", "Bamboo Rod", 0, 0.00, 2, 0, 1, "The Old Salt's gift. Simple, honest, reliable.", Color3.fromRGB(180, 150, 90))
rod("river_oak", "River Oak Rod", 150, 0.03, 3, 1, 2, "Carved from driftwood. A touch more reach.", Color3.fromRGB(140, 100, 60))
rod("coral_reed", "Coral Reed Rod", 450, 0.07, 4, 2, 6, "Grows back every season, stronger each time.", Color3.fromRGB(255, 140, 160))
rod("storm_runner", "Storm Runner Rod", 1400, 0.12, 5, 3, 12, "Forged from a ship's mast that survived a hurricane.", Color3.fromRGB(90, 120, 200))
rod("ember_spine", "Ember Spine Rod", 4000, 0.18, 6, 4, 20, "Tempered in volcanic springs. Warm to the touch.", Color3.fromRGB(255, 90, 40))
rod("frostbound", "Frostbound Rod", 11000, 0.25, 7, 5, 28, "Cut from the heart of a glacier. Never thaws.", Color3.fromRGB(170, 210, 255))
rod("abyss_caller", "Abyss Caller Rod", 28000, 0.35, 8, 6, 36, "Whispers to the deep. The deep whispers back.", Color3.fromRGB(110, 70, 200))
rod("leviathan", "Leviathan Rod", 70000, 0.50, 10, 7, 45, "Woven from the sinew of a leviathan. It remembers how to fight.", Color3.fromRGB(40, 140, 120))

local RodCatalog = {}

function RodCatalog.Get(id: string): Types.RodDef?
	return RODS[id]
end

function RodCatalog.GetAll(): { [string]: Types.RodDef }
	return RODS
end

-- Rods sorted by cost (for shop display)
function RodCatalog.GetSorted(): { Types.RodDef }
	local out: { Types.RodDef } = {}
	for _, def  in pairs(RODS) do
		table.insert(out, def)
	end
	table.sort(out, function(a, b)
		return a.cost < b.cost
	end)
	return out
end

return RodCatalog
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/RodCatalog')
end

-- ReplicatedStorage/Shared/Data/ZoneCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/ZoneCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — ZoneCatalog
	Zone definitions + the name of the region Part the builder places in Studio.
	Region parts: anchored, transparent, CanCollide=false, named "ZoneRegion_<id>".
	Phase 2 | AI-assisted | 2026-08-02
]]

local Types = require(script.Parent.Parent.Types)

local ZONES: { [string]: Types.ZoneDef } = {
	sunshall = {
		id = "sunshall",
		name = "Sunshall Cove",
		unlockLevel = 1,
		desc = "Golden beach, calm water, and the smell of salt and story.",
		fishIds = { "sunsail_minnow", "reef_perch", "cove_carp", "striped_grunt", "golden_anchovy", "moon_koi", "sunsong_sturgeon", "gilded_bass" },
		nightFishIds = { "moon_koi" },
	},
	whisper = {
		id = "whisper",
		name = "Whisper Shallows",
		unlockLevel = 3,
		desc = "Turquoise water and kelp that hums with hidden life.",
		fishIds = { "shimmerfin", "drift_mackerel", "seagrass_snapper", "silver_carp", "whisper_lanternfish", "moonlit_koi", "kelp_serpent", "tide_hunter" },
		nightFishIds = { "whisper_lanternfish", "moonlit_koi" },
	},
	drop = {
		id = "drop",
		name = "The Drop",
		unlockLevel = 8,
		desc = "The shelf ends here. So does the light.",
		fishIds = { "deep_darter", "cliff_cod", "drop_anglerfish", "abyssal_squid", "trench_eel", "fog_wraith" },
		nightFishIds = { "abyssal_squid", "fog_wraith" },
	},
	ember = {
		id = "ember",
		name = "Ember Falls",
		unlockLevel = 15,
		desc = "Volcanic waters under a red sky. The fish here glow like coals.",
		fishIds = { "ember_trout", "ash_gar", "magma_eel", "cinder_salmon", "ember_pike", "magma_whale", "ember_leviathan", "storm_krakenling" },
		stormFishIds = { "storm_krakenling" },
	},
	frost = {
		id = "frost",
		name = "Frostreach",
		unlockLevel = 24,
		desc = "Icebergs and aurora. The cold here has teeth.",
		fishIds = { "frostling_pike", "iceback_herring", "snowcap_char", "aurora_koi", "glacier_eel", "frost_whale", "frost_leviathan", "aurora_serpent" },
		nightFishIds = { "aurora_koi", "aurora_serpent" },
	},
	abyss = {
		id = "abyss",
		name = "Abyssal Trench",
		unlockLevel = 35,
		desc = "Near-black water, bioluminescent ghosts, and the oldest things in the sea.",
		fishIds = { "trench_fangtooth", "void_lanternfish", "abyssal_angler", "gloom_serpent", "abyssal_hunter", "trench_devil", "leviathan_abyss", "stormcaller_eel", "old_one" },
		nightFishIds = { "trench_devil" },
		stormFishIds = { "stormcaller_eel" },
	},
	hidden_isles = {
		id = "hidden_isles",
		name = "Hidden Isle of Whispers",
		unlockLevel = 1,
		desc = "Behind the waterfall at Ember Falls. Nobody believes you when you find it.",
		fishIds = { "mistfin", "isle_song" },
	},
	sunken_grotto = {
		id = "sunken_grotto",
		name = "The Sunken Grotto",
		unlockLevel = 1,
		desc = "Inside a sea cave at The Drop. The water here remembers a drowned court.",
		fishIds = { "grotto_glowfin", "sunken_king" },
	},
}

-- Families that count toward "deep" knowledge (unlocks The Old One)
local DEEP_FAMILIES = {
	eel = true,
	serpent = true,
	squid = true,
	angler = true,
	abyss = true,
	fang = true,
	devil = true,
	wraith = true,
	glow = true,
	old = true,
}

local ZoneCatalog = {}

function ZoneCatalog.Get(id: string): Types.ZoneDef?
	return ZONES[id]
end

function ZoneCatalog.GetAll(): { [string]: Types.ZoneDef }
	return ZONES
end

function ZoneCatalog.IsDeepFamily(family: string): boolean
	return DEEP_FAMILIES[family] == true
end

-- Region part name for a zone (builder places these in Studio)
function ZoneCatalog.RegionPartName(zoneId: string): string
	return "ZoneRegion_" .. zoneId
end

return ZoneCatalog
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — ZoneCatalog
	Zone definitions + the name of the region Part the builder places in Studio.
	Region parts: anchored, transparent, CanCollide=false, named "ZoneRegion_<id>".
	Phase 2 | AI-assisted | 2026-08-02
]]

local Types = require(script.Parent.Parent.Types)

local ZONES: { [string]: Types.ZoneDef } = {
	sunshall = {
		id = "sunshall",
		name = "Sunshall Cove",
		unlockLevel = 1,
		desc = "Golden beach, calm water, and the smell of salt and story.",
		fishIds = { "sunsail_minnow", "reef_perch", "cove_carp", "striped_grunt", "golden_anchovy", "moon_koi", "sunsong_sturgeon", "gilded_bass" },
		nightFishIds = { "moon_koi" },
	},
	whisper = {
		id = "whisper",
		name = "Whisper Shallows",
		unlockLevel = 3,
		desc = "Turquoise water and kelp that hums with hidden life.",
		fishIds = { "shimmerfin", "drift_mackerel", "seagrass_snapper", "silver_carp", "whisper_lanternfish", "moonlit_koi", "kelp_serpent", "tide_hunter" },
		nightFishIds = { "whisper_lanternfish", "moonlit_koi" },
	},
	drop = {
		id = "drop",
		name = "The Drop",
		unlockLevel = 8,
		desc = "The shelf ends here. So does the light.",
		fishIds = { "deep_darter", "cliff_cod", "drop_anglerfish", "abyssal_squid", "trench_eel", "fog_wraith" },
		nightFishIds = { "abyssal_squid", "fog_wraith" },
	},
	ember = {
		id = "ember",
		name = "Ember Falls",
		unlockLevel = 15,
		desc = "Volcanic waters under a red sky. The fish here glow like coals.",
		fishIds = { "ember_trout", "ash_gar", "magma_eel", "cinder_salmon", "ember_pike", "magma_whale", "ember_leviathan", "storm_krakenling" },
		stormFishIds = { "storm_krakenling" },
	},
	frost = {
		id = "frost",
		name = "Frostreach",
		unlockLevel = 24,
		desc = "Icebergs and aurora. The cold here has teeth.",
		fishIds = { "frostling_pike", "iceback_herring", "snowcap_char", "aurora_koi", "glacier_eel", "frost_whale", "frost_leviathan", "aurora_serpent" },
		nightFishIds = { "aurora_koi", "aurora_serpent" },
	},
	abyss = {
		id = "abyss",
		name = "Abyssal Trench",
		unlockLevel = 35,
		desc = "Near-black water, bioluminescent ghosts, and the oldest things in the sea.",
		fishIds = { "trench_fangtooth", "void_lanternfish", "abyssal_angler", "gloom_serpent", "abyssal_hunter", "trench_devil", "leviathan_abyss", "stormcaller_eel", "old_one" },
		nightFishIds = { "trench_devil" },
		stormFishIds = { "stormcaller_eel" },
	},
	hidden_isles = {
		id = "hidden_isles",
		name = "Hidden Isle of Whispers",
		unlockLevel = 1,
		desc = "Behind the waterfall at Ember Falls. Nobody believes you when you find it.",
		fishIds = { "mistfin", "isle_song" },
	},
	sunken_grotto = {
		id = "sunken_grotto",
		name = "The Sunken Grotto",
		unlockLevel = 1,
		desc = "Inside a sea cave at The Drop. The water here remembers a drowned court.",
		fishIds = { "grotto_glowfin", "sunken_king" },
	},
}

-- Families that count toward "deep" knowledge (unlocks The Old One)
local DEEP_FAMILIES = {
	eel = true,
	serpent = true,
	squid = true,
	angler = true,
	abyss = true,
	fang = true,
	devil = true,
	wraith = true,
	glow = true,
	old = true,
}

local ZoneCatalog = {}

function ZoneCatalog.Get(id: string): Types.ZoneDef?
	return ZONES[id]
end

function ZoneCatalog.GetAll(): { [string]: Types.ZoneDef }
	return ZONES
end

function ZoneCatalog.IsDeepFamily(family: string): boolean
	return DEEP_FAMILIES[family] == true
end

-- Region part name for a zone (builder places these in Studio)
function ZoneCatalog.RegionPartName(zoneId: string): string
	return "ZoneRegion_" .. zoneId
end

return ZoneCatalog
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/ZoneCatalog')
end

-- ReplicatedStorage/Shared/Data/QuestCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/QuestCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — QuestCatalog
	Daily/weekly quest templates + achievements. Data-driven; add more in updates.
	Phase 2 | AI-assisted | 2026-08-02
]]

local QuestCatalog = {}

-- type: catchTotal | catchZone | catchNight | catchRarity | catchFamily | catchStorm | sellCoins | catchShiny
-- param: { zone = "drop" } or { family = "eel" } — resolved at roll time
local DAILY_POOL: { { id: string, desc: string, type: string, target: number, rewards: { coins: number?, pearls: number?, bait: string? }, param: string? } } = {
	{ id = "d_catch_total", desc = "Catch {n} fish", type = "catchTotal", target = 10, rewards = { coins = 150 } },
	{ id = "d_catch_zone", desc = "Catch {n} fish in {zone}", type = "catchZone", target = 8, rewards = { coins = 200 }, param = "zone" },
	{ id = "d_catch_night", desc = "Catch {n} fish at night", type = "catchNight", target = 5, rewards = { coins = 250 } },
	{ id = "d_catch_rare", desc = "Catch a Rare or better fish", type = "catchRarity", target = 1, rewards = { coins = 300, pearls = 1 } },
	{ id = "d_sell_coins", desc = "Earn {n} coins from selling", type = "sellCoins", target = 400, rewards = { coins = 200 } },
	{ id = "d_catch_family", desc = "Catch {n} {family} fish", type = "catchFamily", target = 6, rewards = { coins = 220, bait = "worm" }, param = "family" },
	{ id = "d_catch_storm", desc = "Catch {n} fish during a storm", type = "catchStorm", target = 3, rewards = { coins = 350, pearls = 2 } },
	{ id = "d_catch_shiny", desc = "Catch a Shiny fish", type = "catchShiny", target = 1, rewards = { coins = 500, pearls = 5 } },
}

local WEEKLY_POOL: { { id: string, desc: string, type: string, target: number, rewards: { pearls: number }, param: string? } } = {
	{ id = "w_catch_100", desc = "Catch 100 fish", type = "catchTotal", target = 100, rewards = { pearls = 25 } },
	{ id = "w_catch_epic", desc = "Catch 5 Epic or better fish", type = "catchRarity", target = 5, rewards = { pearls = 30 } },
	{ id = "w_sell_5000", desc = "Earn 5,000 coins from selling", type = "sellCoins", target = 5000, rewards = { pearls = 20 } },
	{ id = "w_shiny_hunt", desc = "Catch 3 Shiny fish", type = "catchShiny", target = 3, rewards = { pearls = 40 } },
	{ id = "w_zone_master", desc = "Complete 50% of any zone bestiary", type = "zoneProgress", target = 50, rewards = { pearls = 25 } },
}

-- Achievements: id, name, desc, rewards, condition(profile-ish stats)
-- Conditions are evaluated by QuestService hooks using server-side stats only.
local ACHIEVEMENTS: { { id: string, name: string, desc: string, rewards: { pearls: number?, title: string? } } } = {
	{ id = "first_catch", name = "First Cast", desc = "Catch your first fish", rewards = { pearls = 5 } },
	{ id = "first_shiny", name = "Shiny Hunter", desc = "Catch your first Shiny fish", rewards = { pearls = 10, title = "Shiny Hunter" } },
	{ id = "fish_100", name = "Getting the Hang", desc = "Catch 100 fish", rewards = { pearls = 10 } },
	{ id = "fish_1000", name = "Master Angler", desc = "Catch 1,000 fish", rewards = { pearls = 25, title = "Master Angler" } },
	{ id = "coins_10k", name = "Coin Collector", desc = "Earn 10,000 coins total", rewards = { pearls = 10 } },
	{ id = "coins_100k", name = "Dock Tycoon", desc = "Earn 100,000 coins total", rewards = { pearls = 25, title = "Dock Tycoon" } },
	{ id = "night_owl", name = "Night Owl", desc = "Catch 20 fish at night", rewards = { pearls = 10, title = "Night Owl" } },
	{ id = "storm_chaser", name = "Storm Chaser", desc = "Catch 10 fish during storms", rewards = { pearls = 15, title = "Storm Chaser" } },
	{ id = "deep_diver", name = "Deep Diver", desc = "Catch 50 deep-water fish", rewards = { pearls = 15 } },
	{ id = "old_one_witness", name = "The Old One's Witness", desc = "Catch The Old One", rewards = { pearls = 50, title = "Old One's Witness" } },
	{ id = "secret_finder", name = "Isle Finder", desc = "Find the Hidden Isle of Whispers", rewards = { pearls = 20, title = "Isle Finder" } },
	{ id = "grotto_finder", name = "Grotto Diver", desc = "Find the Sunken Grotto", rewards = { pearls = 20, title = "Grotto Diver" } },
	{ id = "level_10", name = "Level 10", desc = "Reach level 10", rewards = { pearls = 10 } },
	{ id = "level_25", name = "Level 25", desc = "Reach level 25", rewards = { pearls = 20 } },
	{ id = "level_50", name = "Level 50", desc = "Reach the max level", rewards = { pearls = 40, title = "Tidebound Legend" } },
	{ id = "rod_collector", name = "Rod Collector", desc = "Own every rod", rewards = { pearls = 30, title = "Rod Collector" } },
	{ id = "zone_master", name = "Zone Master", desc = "Complete any zone bestiary 100%", rewards = { pearls = 25, title = "Zone Master" } },
	{ id = "all_zones", name = "Bestiary Master", desc = "Complete every zone bestiary 100%", rewards = { pearls = 100, title = "Bestiary Master" } },
	{ id = "contest_winner", name = "Weekly Champion", desc = "Win the weekly catch contest", rewards = { pearls = 50, title = "Weekly Champion" } },
	{ id = "pearl_earner", name = "Pearl Diver", desc = "Earn 100 pearls", rewards = { title = "Pearl Diver" } },
	{ id = "shiny_10", name = "Shiny Collector", desc = "Catch 10 Shiny fish", rewards = { pearls = 30, title = "Shiny Collector" } },
}

QuestCatalog.DAILY_POOL = DAILY_POOL
QuestCatalog.WEEKLY_POOL = WEEKLY_POOL
QuestCatalog.ACHIEVEMENTS = ACHIEVEMENTS

function QuestCatalog.GetDailyTemplate(id: string)
	for _, t  in pairs(DAILY_POOL) do
		if t.id == id then
			return t
		end
	end
	return nil
end

function QuestCatalog.GetWeeklyTemplate(id: string)
	for _, t  in pairs(WEEKLY_POOL) do
		if t.id == id then
			return t
		end
	end
	return nil
end

-- Random template from a pool, excluding ones already rolled this cycle
function QuestCatalog.RollTemplates(pool: { any }, exclude: { [string]: boolean }): { any }
	local available: { any } = {}
	for _, t  in pairs(pool) do
		if not exclude[t.id] then
			table.insert(available, t)
		end
	end
	-- Shuffle (Fisher-Yates)
	for i = #available, 2, -1 do
		local j = math.random(1, i)
		available[i], available[j] = available[j], available[i]
	end
	return available
end

-- Build a human-readable description from a template + params
function QuestCatalog.FormatDesc(template: any, params: { [string]: string }): string
	local desc = template.desc
	desc = string.gsub(desc, "{n}", tostring(template.target))
	if params and params.zone then
		desc = string.gsub(desc, "{zone}", params.zone)
	end
	if params and params.family then
		desc = string.gsub(desc, "{family}", params.family)
	end
	return desc
end

return QuestCatalog
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — QuestCatalog
	Daily/weekly quest templates + achievements. Data-driven; add more in updates.
	Phase 2 | AI-assisted | 2026-08-02
]]

local QuestCatalog = {}

-- type: catchTotal | catchZone | catchNight | catchRarity | catchFamily | catchStorm | sellCoins | catchShiny
-- param: { zone = "drop" } or { family = "eel" } — resolved at roll time
local DAILY_POOL: { { id: string, desc: string, type: string, target: number, rewards: { coins: number?, pearls: number?, bait: string? }, param: string? } } = {
	{ id = "d_catch_total", desc = "Catch {n} fish", type = "catchTotal", target = 10, rewards = { coins = 150 } },
	{ id = "d_catch_zone", desc = "Catch {n} fish in {zone}", type = "catchZone", target = 8, rewards = { coins = 200 }, param = "zone" },
	{ id = "d_catch_night", desc = "Catch {n} fish at night", type = "catchNight", target = 5, rewards = { coins = 250 } },
	{ id = "d_catch_rare", desc = "Catch a Rare or better fish", type = "catchRarity", target = 1, rewards = { coins = 300, pearls = 1 } },
	{ id = "d_sell_coins", desc = "Earn {n} coins from selling", type = "sellCoins", target = 400, rewards = { coins = 200 } },
	{ id = "d_catch_family", desc = "Catch {n} {family} fish", type = "catchFamily", target = 6, rewards = { coins = 220, bait = "worm" }, param = "family" },
	{ id = "d_catch_storm", desc = "Catch {n} fish during a storm", type = "catchStorm", target = 3, rewards = { coins = 350, pearls = 2 } },
	{ id = "d_catch_shiny", desc = "Catch a Shiny fish", type = "catchShiny", target = 1, rewards = { coins = 500, pearls = 5 } },
}

local WEEKLY_POOL: { { id: string, desc: string, type: string, target: number, rewards: { pearls: number }, param: string? } } = {
	{ id = "w_catch_100", desc = "Catch 100 fish", type = "catchTotal", target = 100, rewards = { pearls = 25 } },
	{ id = "w_catch_epic", desc = "Catch 5 Epic or better fish", type = "catchRarity", target = 5, rewards = { pearls = 30 } },
	{ id = "w_sell_5000", desc = "Earn 5,000 coins from selling", type = "sellCoins", target = 5000, rewards = { pearls = 20 } },
	{ id = "w_shiny_hunt", desc = "Catch 3 Shiny fish", type = "catchShiny", target = 3, rewards = { pearls = 40 } },
	{ id = "w_zone_master", desc = "Complete 50% of any zone bestiary", type = "zoneProgress", target = 50, rewards = { pearls = 25 } },
}

-- Achievements: id, name, desc, rewards, condition(profile-ish stats)
-- Conditions are evaluated by QuestService hooks using server-side stats only.
local ACHIEVEMENTS: { { id: string, name: string, desc: string, rewards: { pearls: number?, title: string? } } } = {
	{ id = "first_catch", name = "First Cast", desc = "Catch your first fish", rewards = { pearls = 5 } },
	{ id = "first_shiny", name = "Shiny Hunter", desc = "Catch your first Shiny fish", rewards = { pearls = 10, title = "Shiny Hunter" } },
	{ id = "fish_100", name = "Getting the Hang", desc = "Catch 100 fish", rewards = { pearls = 10 } },
	{ id = "fish_1000", name = "Master Angler", desc = "Catch 1,000 fish", rewards = { pearls = 25, title = "Master Angler" } },
	{ id = "coins_10k", name = "Coin Collector", desc = "Earn 10,000 coins total", rewards = { pearls = 10 } },
	{ id = "coins_100k", name = "Dock Tycoon", desc = "Earn 100,000 coins total", rewards = { pearls = 25, title = "Dock Tycoon" } },
	{ id = "night_owl", name = "Night Owl", desc = "Catch 20 fish at night", rewards = { pearls = 10, title = "Night Owl" } },
	{ id = "storm_chaser", name = "Storm Chaser", desc = "Catch 10 fish during storms", rewards = { pearls = 15, title = "Storm Chaser" } },
	{ id = "deep_diver", name = "Deep Diver", desc = "Catch 50 deep-water fish", rewards = { pearls = 15 } },
	{ id = "old_one_witness", name = "The Old One's Witness", desc = "Catch The Old One", rewards = { pearls = 50, title = "Old One's Witness" } },
	{ id = "secret_finder", name = "Isle Finder", desc = "Find the Hidden Isle of Whispers", rewards = { pearls = 20, title = "Isle Finder" } },
	{ id = "grotto_finder", name = "Grotto Diver", desc = "Find the Sunken Grotto", rewards = { pearls = 20, title = "Grotto Diver" } },
	{ id = "level_10", name = "Level 10", desc = "Reach level 10", rewards = { pearls = 10 } },
	{ id = "level_25", name = "Level 25", desc = "Reach level 25", rewards = { pearls = 20 } },
	{ id = "level_50", name = "Level 50", desc = "Reach the max level", rewards = { pearls = 40, title = "Tidebound Legend" } },
	{ id = "rod_collector", name = "Rod Collector", desc = "Own every rod", rewards = { pearls = 30, title = "Rod Collector" } },
	{ id = "zone_master", name = "Zone Master", desc = "Complete any zone bestiary 100%", rewards = { pearls = 25, title = "Zone Master" } },
	{ id = "all_zones", name = "Bestiary Master", desc = "Complete every zone bestiary 100%", rewards = { pearls = 100, title = "Bestiary Master" } },
	{ id = "contest_winner", name = "Weekly Champion", desc = "Win the weekly catch contest", rewards = { pearls = 50, title = "Weekly Champion" } },
	{ id = "pearl_earner", name = "Pearl Diver", desc = "Earn 100 pearls", rewards = { title = "Pearl Diver" } },
	{ id = "shiny_10", name = "Shiny Collector", desc = "Catch 10 Shiny fish", rewards = { pearls = 30, title = "Shiny Collector" } },
}

QuestCatalog.DAILY_POOL = DAILY_POOL
QuestCatalog.WEEKLY_POOL = WEEKLY_POOL
QuestCatalog.ACHIEVEMENTS = ACHIEVEMENTS

function QuestCatalog.GetDailyTemplate(id: string)
	for _, t  in pairs(DAILY_POOL) do
		if t.id == id then
			return t
		end
	end
	return nil
end

function QuestCatalog.GetWeeklyTemplate(id: string)
	for _, t  in pairs(WEEKLY_POOL) do
		if t.id == id then
			return t
		end
	end
	return nil
end

-- Random template from a pool, excluding ones already rolled this cycle
function QuestCatalog.RollTemplates(pool: { any }, exclude: { [string]: boolean }): { any }
	local available: { any } = {}
	for _, t  in pairs(pool) do
		if not exclude[t.id] then
			table.insert(available, t)
		end
	end
	-- Shuffle (Fisher-Yates)
	for i = #available, 2, -1 do
		local j = math.random(1, i)
		available[i], available[j] = available[j], available[i]
	end
	return available
end

-- Build a human-readable description from a template + params
function QuestCatalog.FormatDesc(template: any, params: { [string]: string }): string
	local desc = template.desc
	desc = string.gsub(desc, "{n}", tostring(template.target))
	if params and params.zone then
		desc = string.gsub(desc, "{zone}", params.zone)
	end
	if params and params.family then
		desc = string.gsub(desc, "{family}", params.family)
	end
	return desc
end

return QuestCatalog
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/QuestCatalog')
end

-- ReplicatedStorage/Shared/Data/CosmeticsCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/CosmeticsCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — CosmeticsCatalog
	Every purchasable cosmetic (pearl shop). Types: bobber, trail, aura, rodSkin, nameColor.
	Cosmetics are 100% visual — never affect gameplay values.
	Phase 7 | AI-assisted | 2026-08-03
]]

local Types = require(script.Parent.Parent.Types)

export type CosmeticDef = {
	id: string,
	name: string,
	kind: "bobber" | "trail" | "aura" | "rodSkin" | "nameColor",
	price: number, -- pearls (0 = default, free)
	color: Color3,
	desc: string,
}

local COSMETICS: { [string]: CosmeticDef } = {}

local function c(
	id: string,
	name: string,
	kind: "bobber" | "trail" | "aura" | "rodSkin" | "nameColor",
	price: number,
	color: Color3,
	desc: string
): CosmeticDef
	local def: CosmeticDef = { id = id, name = name, kind = kind, price = price, color = color, desc = desc }
	COSMETICS[id] = def
	return def
end

-- Bobbers (visual on the bobber)
c("bobber_classic", "Classic Bobber", "bobber", 0, Color3.fromRGB(255, 220, 80), "The old faithful. Gold never goes out of style.")
c("bobber_coral", "Coral Bobber", "bobber", 40, Color3.fromRGB(255, 120, 160), "Carved from living reef. A favorite of the shallows.")
c("bobber_aurora", "Aurora Bobber", "bobber", 90, Color3.fromRGB(120, 255, 190), "Catches the northern lights. Even at noon.")
c("bobber_void", "Void Bobber", "bobber", 150, Color3.fromRGB(150, 90, 255), "Fishing in the dark just got darker.")

-- Trails (particles behind the bobber)
c("trail_bubbles", "Bubble Trail", "trail", 60, Color3.fromRGB(200, 235, 255), "A stream of bubbles marks your cast.")
c("trail_stars", "Starlight Trail", "trail", 110, Color3.fromRGB(255, 240, 160), "A sprinkle of stardust follows your line.")

-- Auras (particle glow on catch)
c("aura_ember", "Ember Aura", "aura", 130, Color3.fromRGB(255, 140, 50), "Your catches arrive wreathed in embers.")
c("aura_ghost", "Ghostlight Aura", "aura", 130, Color3.fromRGB(160, 200, 255), "A cold, pale light that follows the fish home.")

-- Rod skins (color of the rod handle you hold)
c("rodskin_oak", "Oak Grip", "rodSkin", 50, Color3.fromRGB(150, 105, 60), "Classic wood. Warm, familiar, dependable.")
c("rodskin_obsidian", "Obsidian Grip", "rodSkin", 80, Color3.fromRGB(45, 45, 55), "Black as the trench it was forged in.")
c("rodskin_royal", "Royal Grip", "rodSkin", 150, Color3.fromRGB(200, 170, 60), "Gold trim for the angler who knows it.")

-- Name colors (profile + title displays)
c("name_aqua", "Aqua Name", "nameColor", 25, Color3.fromRGB(90, 220, 255), "A splash of color for your name.")
c("name_rose", "Rose Name", "nameColor", 25, Color3.fromRGB(255, 130, 160), "Soft and unmistakable.")
c("name_gold", "Gold Name", "nameColor", 60, Color3.fromRGB(255, 200, 60), "For those who always land the big one.")

local CosmeticsCatalog = {}

function CosmeticsCatalog.Get(id: string): CosmeticDef?
	return COSMETICS[id]
end

function CosmeticsCatalog.GetAll(): { [string]: CosmeticDef }
	return COSMETICS
end

function CosmeticsCatalog.GetByKind(kind: string): { CosmeticDef }
	local out: { CosmeticDef } = {}
	for _, def in pairs(COSMETICS) do
		if def.kind == kind then
			table.insert(out, def)
		end
	end
	table.sort(out, function(a, b)
		return a.price < b.price
	end)
	return out
end

function CosmeticsCatalog.DefaultFor(kind: string): string?
	if kind == "bobber" then
		return "bobber_classic"
	end
	return nil
end

return CosmeticsCatalog
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — CosmeticsCatalog
	Every purchasable cosmetic (pearl shop). Types: bobber, trail, aura, rodSkin, nameColor.
	Cosmetics are 100% visual — never affect gameplay values.
	Phase 7 | AI-assisted | 2026-08-03
]]

local Types = require(script.Parent.Parent.Types)

export type CosmeticDef = {
	id: string,
	name: string,
	kind: "bobber" | "trail" | "aura" | "rodSkin" | "nameColor",
	price: number, -- pearls (0 = default, free)
	color: Color3,
	desc: string,
}

local COSMETICS: { [string]: CosmeticDef } = {}

local function c(
	id: string,
	name: string,
	kind: "bobber" | "trail" | "aura" | "rodSkin" | "nameColor",
	price: number,
	color: Color3,
	desc: string
): CosmeticDef
	local def: CosmeticDef = { id = id, name = name, kind = kind, price = price, color = color, desc = desc }
	COSMETICS[id] = def
	return def
end

-- Bobbers (visual on the bobber)
c("bobber_classic", "Classic Bobber", "bobber", 0, Color3.fromRGB(255, 220, 80), "The old faithful. Gold never goes out of style.")
c("bobber_coral", "Coral Bobber", "bobber", 40, Color3.fromRGB(255, 120, 160), "Carved from living reef. A favorite of the shallows.")
c("bobber_aurora", "Aurora Bobber", "bobber", 90, Color3.fromRGB(120, 255, 190), "Catches the northern lights. Even at noon.")
c("bobber_void", "Void Bobber", "bobber", 150, Color3.fromRGB(150, 90, 255), "Fishing in the dark just got darker.")

-- Trails (particles behind the bobber)
c("trail_bubbles", "Bubble Trail", "trail", 60, Color3.fromRGB(200, 235, 255), "A stream of bubbles marks your cast.")
c("trail_stars", "Starlight Trail", "trail", 110, Color3.fromRGB(255, 240, 160), "A sprinkle of stardust follows your line.")

-- Auras (particle glow on catch)
c("aura_ember", "Ember Aura", "aura", 130, Color3.fromRGB(255, 140, 50), "Your catches arrive wreathed in embers.")
c("aura_ghost", "Ghostlight Aura", "aura", 130, Color3.fromRGB(160, 200, 255), "A cold, pale light that follows the fish home.")

-- Rod skins (color of the rod handle you hold)
c("rodskin_oak", "Oak Grip", "rodSkin", 50, Color3.fromRGB(150, 105, 60), "Classic wood. Warm, familiar, dependable.")
c("rodskin_obsidian", "Obsidian Grip", "rodSkin", 80, Color3.fromRGB(45, 45, 55), "Black as the trench it was forged in.")
c("rodskin_royal", "Royal Grip", "rodSkin", 150, Color3.fromRGB(200, 170, 60), "Gold trim for the angler who knows it.")

-- Name colors (profile + title displays)
c("name_aqua", "Aqua Name", "nameColor", 25, Color3.fromRGB(90, 220, 255), "A splash of color for your name.")
c("name_rose", "Rose Name", "nameColor", 25, Color3.fromRGB(255, 130, 160), "Soft and unmistakable.")
c("name_gold", "Gold Name", "nameColor", 60, Color3.fromRGB(255, 200, 60), "For those who always land the big one.")

local CosmeticsCatalog = {}

function CosmeticsCatalog.Get(id: string): CosmeticDef?
	return COSMETICS[id]
end

function CosmeticsCatalog.GetAll(): { [string]: CosmeticDef }
	return COSMETICS
end

function CosmeticsCatalog.GetByKind(kind: string): { CosmeticDef }
	local out: { CosmeticDef } = {}
	for _, def in pairs(COSMETICS) do
		if def.kind == kind then
			table.insert(out, def)
		end
	end
	table.sort(out, function(a, b)
		return a.price < b.price
	end)
	return out
end

function CosmeticsCatalog.DefaultFor(kind: string): string?
	if kind == "bobber" then
		return "bobber_classic"
	end
	return nil
end

return CosmeticsCatalog
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/CosmeticsCatalog')
end

-- ServerScriptService/Services/SecurityService
local inst = ensure('ServerScriptService/Services/SecurityService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — SecurityService
	Defense layer 1-3: message validation, rate limiting, kick policy.
	The server NEVER trusts client payloads; every message passes through here.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local SecurityService = {}
SecurityService.Name = "SecurityService"

local WINDOW = 10 -- seconds
type Bucket = { count: number, windowStart: number, violations: number }
local buckets: { [number]: { [string]: Bucket } } = {}

-- Valid message types (unknown types are rejected outright)
local VALID_TYPES: { [string]: boolean } = {
	Cast = true,
	ReelHold = true,
	AutoReel = true,
	SellFish = true,
	SellAll = true,
	SetAutoSell = true,
	BuyRod = true,
	BuyBait = true,
	BuyUpgrade = true,
	EquipRod = true,
	EquipBait = true,
	ClaimDaily = true,
	ClaimWeekly = true,
	RerollQuest = true,
	FastTravel = true,
	GuideDone = true,
	BuyCosmetic = true,
	EquipCosmetic = true,
	EquipTitle = true,
	GetContestTop = true,
	SyncRequest = true,
}

-- Validate the envelope; returns (ok, reason)
function SecurityService:ValidateMessage(message: any): (boolean, string?)
	if typeof(message) ~= "table" then
		return false, "malformed message"
	end
	local msgType = message.type
	if typeof(msgType) ~= "string" or not VALID_TYPES[msgType] then
		return false, "unknown type: " .. tostring(msgType)
	end
	local payload = message.payload
	if payload ~= nil and typeof(payload) ~= "table" and typeof(payload) ~= "Vector3" and typeof(payload) ~= "boolean" then
		return false, "bad payload"
	end
	return true
end

-- Token-bucket rate limit per player per message type.
-- Returns true if the message may proceed.
function SecurityService:CheckRate(player: Player, msgType: string): boolean
	local limit = Config.RATE_LIMITS[msgType]
	if not limit or limit <= 0 then
		return false
	end
	local now = os.clock()
	local playerBuckets = buckets[player.UserId]
	if not playerBuckets then
		playerBuckets = {}
		buckets[player.UserId] = playerBuckets
	end
	local bucket = playerBuckets[msgType]
	if not bucket or (now - bucket.windowStart) >= WINDOW then
		playerBuckets[msgType] = { count = 1, windowStart = now, violations = 0 }
		return true
	end
	bucket.count += 1
	if bucket.count > limit then
		bucket.violations += 1
		if bucket.violations >= 3 then
			warn("[Security] Kicking " .. player.Name .. " (rate abuse: " .. msgType .. ")")
			player:Kick("Too many requests. Please play fair!")
			buckets[player.UserId] = nil
		end
		return false
	end
	return true
end

-- Soft violation: warn and ignore (used for impossible values)
function SecurityService:Flag(player: Player, reason: string)
	warn("[Security] Flag: " .. player.Name .. " | " .. reason)
end

function SecurityService:Init(ctx)
	self.ctx = ctx
end

function SecurityService:Start()
	-- Clean up buckets on leave
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		buckets[player.UserId] = nil
	end)
end

function SecurityService:Stop()
end

return SecurityService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — SecurityService
	Defense layer 1-3: message validation, rate limiting, kick policy.
	The server NEVER trusts client payloads; every message passes through here.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local SecurityService = {}
SecurityService.Name = "SecurityService"

local WINDOW = 10 -- seconds
type Bucket = { count: number, windowStart: number, violations: number }
local buckets: { [number]: { [string]: Bucket } } = {}

-- Valid message types (unknown types are rejected outright)
local VALID_TYPES: { [string]: boolean } = {
	Cast = true,
	ReelHold = true,
	AutoReel = true,
	SellFish = true,
	SellAll = true,
	SetAutoSell = true,
	BuyRod = true,
	BuyBait = true,
	BuyUpgrade = true,
	EquipRod = true,
	EquipBait = true,
	ClaimDaily = true,
	ClaimWeekly = true,
	RerollQuest = true,
	FastTravel = true,
	GuideDone = true,
	BuyCosmetic = true,
	EquipCosmetic = true,
	EquipTitle = true,
	GetContestTop = true,
	SyncRequest = true,
}

-- Validate the envelope; returns (ok, reason)
function SecurityService:ValidateMessage(message: any): (boolean, string?)
	if typeof(message) ~= "table" then
		return false, "malformed message"
	end
	local msgType = message.type
	if typeof(msgType) ~= "string" or not VALID_TYPES[msgType] then
		return false, "unknown type: " .. tostring(msgType)
	end
	local payload = message.payload
	if payload ~= nil and typeof(payload) ~= "table" and typeof(payload) ~= "Vector3" and typeof(payload) ~= "boolean" then
		return false, "bad payload"
	end
	return true
end

-- Token-bucket rate limit per player per message type.
-- Returns true if the message may proceed.
function SecurityService:CheckRate(player: Player, msgType: string): boolean
	local limit = Config.RATE_LIMITS[msgType]
	if not limit or limit <= 0 then
		return false
	end
	local now = os.clock()
	local playerBuckets = buckets[player.UserId]
	if not playerBuckets then
		playerBuckets = {}
		buckets[player.UserId] = playerBuckets
	end
	local bucket = playerBuckets[msgType]
	if not bucket or (now - bucket.windowStart) >= WINDOW then
		playerBuckets[msgType] = { count = 1, windowStart = now, violations = 0 }
		return true
	end
	bucket.count += 1
	if bucket.count > limit then
		bucket.violations += 1
		if bucket.violations >= 3 then
			warn("[Security] Kicking " .. player.Name .. " (rate abuse: " .. msgType .. ")")
			player:Kick("Too many requests. Please play fair!")
			buckets[player.UserId] = nil
		end
		return false
	end
	return true
end

-- Soft violation: warn and ignore (used for impossible values)
function SecurityService:Flag(player: Player, reason: string)
	warn("[Security] Flag: " .. player.Name .. " | " .. reason)
end

function SecurityService:Init(ctx)
	self.ctx = ctx
end

function SecurityService:Start()
	-- Clean up buckets on leave
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		buckets[player.UserId] = nil
	end)
end

function SecurityService:Stop()
end

return SecurityService
]==]
	print('[Installer] Wrote ServerScriptService/Services/SecurityService')
end

-- ServerScriptService/Services/DataService
local inst = ensure('ServerScriptService/Services/DataService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — DataService
	Player profile lifecycle: load on join, autosave, save on leave/shutdown.
	Single owner of the DataStore. All other services read/write through profiles.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)

local DataService = {}
DataService.Name = "DataService"

local playersAlive = true -- set false on shutdown; autosave loops check it

local store = DataStoreService:GetDataStore("TideboundSaves")
local profiles: { [number]: { player: Player, data: Types.ProfileData, dirty: boolean } } = {}
local profileReadyCallbacks: { ((Player, Types.ProfileData) -> ()) } = {}

-- ── Default profile for new players ──────────────────────────────────────

function DataService:NewData(): Types.ProfileData
	local data: Types.ProfileData = {
		v = Config.SAVE_VERSION,
		coins = 0,
		pearls = 0,
		xp = 0,
		level = 1,
		streak = 0,
		streakLastDay = "",
		rods = { bamboo = true },
		equippedRod = "bamboo",
		baits = { worm = 3 },
		inventory = {},
		nextUid = 1,
		bestiary = {},
		dailyQuests = {},
		weeklyQuests = {},
		questDay = "",
		questWeek = "",
		achievements = {},
		titles = {},
		equippedTitle = nil,
		stats = {
			totalCatch = 0,
			totalCoinsEarned = 0,
			totalPearlsEarned = 0,
			nightFish = 0,
			stormFish = 0,
			shinyFish = 0,
			deepFish = 0,
			epicPlus = 0,
			zoneCounts = {},
			familyCounts = {},
			bestCatch = { weight = 0, fishId = "", rarity = "common", weekKey = "" },
		},
		cosmetics = { bobber = "classic" },
		flags = {
			tutorialDone = false,
			autoSell = nil,
			equippedBait = nil,
			ownedPasses = {},
			tokens = 0,
			xpBoostUntil = 0,
			chestsClaimed = {},
			prestige = 0,
			rerollsUsed = 0,
			zoneRewards = {},
			receipts = {},
			contestWins = 0,
			starterClaimed = false,
			invUpgradeTier = 0,
			cosmeticsOwned = {},
			guideFirstCast = false,
			guideFirstReel = false,
			guideFirstCatch = false,
			guideFirstBuy = false,
		},
	}
	return data
end

-- Merge a decoded save into a fresh default (schema evolution + corruption defense)
function DataService:Sanitize(raw: any): Types.ProfileData
	local data = self:NewData()
	if typeof(raw) ~= "table" then
		return data
	end
	-- Top-level scalars
	data.coins = Util.safeNumber(raw.coins, 0)
	data.pearls = Util.safeNumber(raw.pearls, 0)
	data.xp = Util.safeNumber(raw.xp, 0)
	data.level = math.clamp(Util.safeNumber(raw.level, 1), 1, Config.MAX_LEVEL)
	data.streak = math.clamp(Util.safeNumber(raw.streak, 0), 0, 7)
	if typeof(raw.streakLastDay) == "string" then
		data.streakLastDay = raw.streakLastDay
	end
	if typeof(raw.equippedRod) == "string" and RodCatalog.Get(raw.equippedRod) then
		data.equippedRod = raw.equippedRod
	end
	if typeof(raw.rods) == "table" then
		for id, owned  in pairs(raw.rods) do
			if owned and RodCatalog.Get(id) then
				data.rods[id] = true
			end
		end
	end
	if typeof(raw.baits) == "table" then
		for id, count  in pairs(raw.baits) do
			if Config.BAITS[id] and Util.safeNumber(count, 0) > 0 then
				data.baits[id] = math.floor(Util.safeNumber(count, 0))
			end
		end
	end
	if typeof(raw.inventory) == "table" then
		for _, item  in pairs(raw.inventory) do
			if typeof(item) ~= "table" or #data.inventory >= Config.INVENTORY_CAP then
				continue
			end
			local uid = Util.safeNumber(item.uid, 0)
			local fishId = typeof(item.fishId) == "string" and item.fishId or ""
			local weight = Util.safeNumber(item.weight, 0)
			if uid > 0 and fishId ~= "" and weight > 0 then
				table.insert(data.inventory, {
					uid = uid,
					fishId = fishId,
					weight = weight,
					shiny = item.shiny == true,
					caughtAt = Util.safeNumber(item.caughtAt, os.time()),
				})
				data.nextUid = math.max(data.nextUid, uid + 1)
			end
		end
	end
	if typeof(raw.bestiary) == "table" then
		for fishId, entry  in pairs(raw.bestiary) do
			if typeof(entry) == "table" then
				data.bestiary[fishId] = {
					caught = math.floor(Util.safeNumber(entry.caught, 0)),
					shiny = entry.shiny == true,
					maxWeight = Util.safeNumber(entry.maxWeight, 0),
				}
			end
		end
	end
	if typeof(raw.quests) == "table" then
		data.dailyQuests = raw.quests.daily or {}
		data.weeklyQuests = raw.quests.weekly or {}
	end
	if typeof(raw.questDay) == "string" then
		data.questDay = raw.questDay
	end
	if typeof(raw.questWeek) == "string" then
		data.questWeek = raw.questWeek
	end
	if typeof(raw.achievements) == "table" then
		for id, done  in pairs(raw.achievements) do
			if done then
				data.achievements[id] = true
			end
		end
	end
	if typeof(raw.titles) == "table" then
		for id, owned  in pairs(raw.titles) do
			if owned then
				data.titles[id] = true
			end
		end
	end
	if typeof(raw.equippedTitle) == "string" then
		data.equippedTitle = raw.equippedTitle
	end
	if typeof(raw.stats) == "table" then
		local s = raw.stats
		data.stats.totalCatch = math.floor(Util.safeNumber(s.totalCatch, 0))
		data.stats.totalCoinsEarned = math.floor(Util.safeNumber(s.totalCoinsEarned, 0))
		data.stats.totalPearlsEarned = math.floor(Util.safeNumber(s.totalPearlsEarned, 0))
		data.stats.nightFish = math.floor(Util.safeNumber(s.nightFish, 0))
		data.stats.stormFish = math.floor(Util.safeNumber(s.stormFish, 0))
		data.stats.shinyFish = math.floor(Util.safeNumber(s.shinyFish, 0))
		data.stats.deepFish = math.floor(Util.safeNumber(s.deepFish, 0))
		data.stats.epicPlus = math.floor(Util.safeNumber(s.epicPlus, 0))
		if typeof(s.zoneCounts) == "table" then
			for k, v  in pairs(s.zoneCounts) do
				data.stats.zoneCounts[k] = math.floor(Util.safeNumber(v, 0))
			end
		end
		if typeof(s.familyCounts) == "table" then
			for k, v  in pairs(s.familyCounts) do
				data.stats.familyCounts[k] = math.floor(Util.safeNumber(v, 0))
			end
		end
		if typeof(s.bestCatch) == "table" then
			data.stats.bestCatch = {
				weight = Util.safeNumber(s.bestCatch.weight, 0),
				fishId = typeof(s.bestCatch.fishId) == "string" and s.bestCatch.fishId or "",
				rarity = "common",
				weekKey = typeof(s.bestCatch.weekKey) == "string" and s.bestCatch.weekKey or "",
			}
		end
	end
	if typeof(raw.cosmetics) == "table" then
		data.cosmetics = raw.cosmetics
	end
	if typeof(raw.flags) == "table" then
		local f = raw.flags
		data.flags.tutorialDone = f.tutorialDone == true
		if typeof(f.autoSell) == "string" then
			data.flags.autoSell = f.autoSell
		end
		if typeof(f.equippedBait) == "string" and Config.BAITS[f.equippedBait] then
			data.flags.equippedBait = f.equippedBait
		end
		if typeof(f.ownedPasses) == "table" then
			for k, v  in pairs(f.ownedPasses) do
				if v then
					data.flags.ownedPasses[k] = true
				end
			end
		end
		data.flags.tokens = math.floor(Util.safeNumber(f.tokens, 0))
		data.flags.xpBoostUntil = math.floor(Util.safeNumber(f.xpBoostUntil, 0))
		if typeof(f.chestsClaimed) == "table" then
			for k, v  in pairs(f.chestsClaimed) do
				if v then
					data.flags.chestsClaimed[k] = true
				end
			end
		end
		data.flags.prestige = math.floor(Util.safeNumber(f.prestige, 0))
		data.flags.rerollsUsed = math.floor(Util.safeNumber(f.rerollsUsed, 0))
		if typeof(f.zoneRewards) == "table" then
			for k, v  in pairs(f.zoneRewards) do
				if v then
					data.flags.zoneRewards[k] = true
				end
			end
		end
		if typeof(f.receipts) == "table" then
			for k, v  in pairs(f.receipts) do
				if v then
					data.flags.receipts[k] = true
				end
			end
		end
		data.flags.contestWins = math.floor(Util.safeNumber(f.contestWins, 0))
		data.flags.starterClaimed = f.starterClaimed == true
		data.flags.invUpgradeTier = math.clamp(math.floor(Util.safeNumber(f.invUpgradeTier, 0)), 0, 3)
		if typeof(f.cosmeticsOwned) == "table" then
			for k, v in pairs(f.cosmeticsOwned) do
				if v then
					data.flags.cosmeticsOwned[k] = true
				end
			end
		end
		data.flags.guideFirstCast = f.guideFirstCast == true
		data.flags.guideFirstReel = f.guideFirstReel == true
		data.flags.guideFirstCatch = f.guideFirstCatch == true
		data.flags.guideFirstBuy = f.guideFirstBuy == true
	end
	return data
end

-- ── Load / save ──────────────────────────────────────────────────────────

function DataService:LoadProfile(player: Player): Types.ProfileData
	local key = Config.SAVE_KEY_PREFIX .. Config.SAVE_VERSION .. "_" .. player.UserId
	local ok, result = pcall(function()
		return store:GetAsync(key)
	end)
	if ok and result ~= nil then
		local decodeOk, decoded = pcall(function()
			return HttpService:JSONDecode(result)
		end)
		if decodeOk then
			return self:Sanitize(decoded)
		end
		warn("[DataService] Corrupt save for " .. player.Name .. ", using defaults")
	end
	return self:NewData()
end

function DataService:SaveProfile(player: Player): boolean
	local profile = profiles[player.UserId]
	if not profile then
		return false
	end
	local key = Config.SAVE_KEY_PREFIX .. Config.SAVE_VERSION .. "_" .. player.UserId
	local encodeOk, encoded = pcall(function()
		return HttpService:JSONEncode(profile.data)
	end)
	if not encodeOk then
		warn("[DataService] Encode failed for " .. player.Name)
		return false
	end
	local attempts = { 0, 1, 5, 15 }
	for i, delay  in pairs(attempts) do
		if i > 1 then
			task.wait(delay)
		end
		local ok, err = pcall(function()
			store:SetAsync(key, encoded)
		end)
		if ok then
			profile.dirty = false
			return true
		end
		warn("[DataService] Save retry " .. i .. " failed for " .. player.Name .. ": " .. tostring(err))
	end
	return false
end

-- ── Public API ───────────────────────────────────────────────────────────

function DataService:GetProfile(player: Player)
	return profiles[player.UserId]
end

function DataService:GetData(player: Player): Types.ProfileData?
	local profile = profiles[player.UserId]
	if profile then
		return profile.data
	end
	return nil
end

function DataService:MarkDirty(player: Player)
	local profile = profiles[player.UserId]
	if profile then
		profile.dirty = true
	end
end

function DataService:OnProfileReady(callback: (Player, Types.ProfileData) -> ())
	table.insert(profileReadyCallbacks, callback)
end

function DataService:SaveAll()
	for _, profile  in pairs(profiles) do
		self:SaveProfile(profile.player)
	end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function DataService:Init(ctx)
	self.ctx = ctx
end

function DataService:Start()
	local loadedPlayers: { [number]: boolean } = {}

	local function onPlayerAdded(player: Player)
		if loadedPlayers[player.UserId] then
			return
		end
		loadedPlayers[player.UserId] = true
		local data = self:LoadProfile(player)
		profiles[player.UserId] = { player = player, data = data, dirty = false }
		for _, cb  in pairs(profileReadyCallbacks) do
			task.spawn(cb, player, data)
		end
		-- Autosave loop
		task.spawn(function()
			while playersAlive do
				task.wait(Config.AUTOSAVE_INTERVAL)
				local profile = profiles[player.UserId]
				if profile and profile.dirty then
					self:SaveProfile(player)
				end
			end
		end)
	end

	local function onPlayerRemoving(player: Player)
		-- Persist before the player is destroyed.
		local profile = profiles[player.UserId]
		if profile then
			self:SaveProfile(player)
		end
		profiles[player.UserId] = nil
		loadedPlayers[player.UserId] = nil
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	-- Load players already present at boot AFTER other services have
	-- registered their profile-ready callbacks (they Start after us).
	task.spawn(function()
		task.wait(1)
		for _, player  in pairs(Players:GetPlayers()) do
			onPlayerAdded(player)
		end
	end)
end

function DataService:Stop()
	playersAlive = false
	self:SaveAll()
	task.wait(1)
end

return DataService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — DataService
	Player profile lifecycle: load on join, autosave, save on leave/shutdown.
	Single owner of the DataStore. All other services read/write through profiles.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)

local DataService = {}
DataService.Name = "DataService"

local playersAlive = true -- set false on shutdown; autosave loops check it

local store = DataStoreService:GetDataStore("TideboundSaves")
local profiles: { [number]: { player: Player, data: Types.ProfileData, dirty: boolean } } = {}
local profileReadyCallbacks: { ((Player, Types.ProfileData) -> ()) } = {}

-- ── Default profile for new players ──────────────────────────────────────

function DataService:NewData(): Types.ProfileData
	local data: Types.ProfileData = {
		v = Config.SAVE_VERSION,
		coins = 0,
		pearls = 0,
		xp = 0,
		level = 1,
		streak = 0,
		streakLastDay = "",
		rods = { bamboo = true },
		equippedRod = "bamboo",
		baits = { worm = 3 },
		inventory = {},
		nextUid = 1,
		bestiary = {},
		dailyQuests = {},
		weeklyQuests = {},
		questDay = "",
		questWeek = "",
		achievements = {},
		titles = {},
		equippedTitle = nil,
		stats = {
			totalCatch = 0,
			totalCoinsEarned = 0,
			totalPearlsEarned = 0,
			nightFish = 0,
			stormFish = 0,
			shinyFish = 0,
			deepFish = 0,
			epicPlus = 0,
			zoneCounts = {},
			familyCounts = {},
			bestCatch = { weight = 0, fishId = "", rarity = "common", weekKey = "" },
		},
		cosmetics = { bobber = "classic" },
		flags = {
			tutorialDone = false,
			autoSell = nil,
			equippedBait = nil,
			ownedPasses = {},
			tokens = 0,
			xpBoostUntil = 0,
			chestsClaimed = {},
			prestige = 0,
			rerollsUsed = 0,
			zoneRewards = {},
			receipts = {},
			contestWins = 0,
			starterClaimed = false,
			invUpgradeTier = 0,
			cosmeticsOwned = {},
			guideFirstCast = false,
			guideFirstReel = false,
			guideFirstCatch = false,
			guideFirstBuy = false,
		},
	}
	return data
end

-- Merge a decoded save into a fresh default (schema evolution + corruption defense)
function DataService:Sanitize(raw: any): Types.ProfileData
	local data = self:NewData()
	if typeof(raw) ~= "table" then
		return data
	end
	-- Top-level scalars
	data.coins = Util.safeNumber(raw.coins, 0)
	data.pearls = Util.safeNumber(raw.pearls, 0)
	data.xp = Util.safeNumber(raw.xp, 0)
	data.level = math.clamp(Util.safeNumber(raw.level, 1), 1, Config.MAX_LEVEL)
	data.streak = math.clamp(Util.safeNumber(raw.streak, 0), 0, 7)
	if typeof(raw.streakLastDay) == "string" then
		data.streakLastDay = raw.streakLastDay
	end
	if typeof(raw.equippedRod) == "string" and RodCatalog.Get(raw.equippedRod) then
		data.equippedRod = raw.equippedRod
	end
	if typeof(raw.rods) == "table" then
		for id, owned  in pairs(raw.rods) do
			if owned and RodCatalog.Get(id) then
				data.rods[id] = true
			end
		end
	end
	if typeof(raw.baits) == "table" then
		for id, count  in pairs(raw.baits) do
			if Config.BAITS[id] and Util.safeNumber(count, 0) > 0 then
				data.baits[id] = math.floor(Util.safeNumber(count, 0))
			end
		end
	end
	if typeof(raw.inventory) == "table" then
		for _, item  in pairs(raw.inventory) do
			if typeof(item) ~= "table" or #data.inventory >= Config.INVENTORY_CAP then
				continue
			end
			local uid = Util.safeNumber(item.uid, 0)
			local fishId = typeof(item.fishId) == "string" and item.fishId or ""
			local weight = Util.safeNumber(item.weight, 0)
			if uid > 0 and fishId ~= "" and weight > 0 then
				table.insert(data.inventory, {
					uid = uid,
					fishId = fishId,
					weight = weight,
					shiny = item.shiny == true,
					caughtAt = Util.safeNumber(item.caughtAt, os.time()),
				})
				data.nextUid = math.max(data.nextUid, uid + 1)
			end
		end
	end
	if typeof(raw.bestiary) == "table" then
		for fishId, entry  in pairs(raw.bestiary) do
			if typeof(entry) == "table" then
				data.bestiary[fishId] = {
					caught = math.floor(Util.safeNumber(entry.caught, 0)),
					shiny = entry.shiny == true,
					maxWeight = Util.safeNumber(entry.maxWeight, 0),
				}
			end
		end
	end
	if typeof(raw.quests) == "table" then
		data.dailyQuests = raw.quests.daily or {}
		data.weeklyQuests = raw.quests.weekly or {}
	end
	if typeof(raw.questDay) == "string" then
		data.questDay = raw.questDay
	end
	if typeof(raw.questWeek) == "string" then
		data.questWeek = raw.questWeek
	end
	if typeof(raw.achievements) == "table" then
		for id, done  in pairs(raw.achievements) do
			if done then
				data.achievements[id] = true
			end
		end
	end
	if typeof(raw.titles) == "table" then
		for id, owned  in pairs(raw.titles) do
			if owned then
				data.titles[id] = true
			end
		end
	end
	if typeof(raw.equippedTitle) == "string" then
		data.equippedTitle = raw.equippedTitle
	end
	if typeof(raw.stats) == "table" then
		local s = raw.stats
		data.stats.totalCatch = math.floor(Util.safeNumber(s.totalCatch, 0))
		data.stats.totalCoinsEarned = math.floor(Util.safeNumber(s.totalCoinsEarned, 0))
		data.stats.totalPearlsEarned = math.floor(Util.safeNumber(s.totalPearlsEarned, 0))
		data.stats.nightFish = math.floor(Util.safeNumber(s.nightFish, 0))
		data.stats.stormFish = math.floor(Util.safeNumber(s.stormFish, 0))
		data.stats.shinyFish = math.floor(Util.safeNumber(s.shinyFish, 0))
		data.stats.deepFish = math.floor(Util.safeNumber(s.deepFish, 0))
		data.stats.epicPlus = math.floor(Util.safeNumber(s.epicPlus, 0))
		if typeof(s.zoneCounts) == "table" then
			for k, v  in pairs(s.zoneCounts) do
				data.stats.zoneCounts[k] = math.floor(Util.safeNumber(v, 0))
			end
		end
		if typeof(s.familyCounts) == "table" then
			for k, v  in pairs(s.familyCounts) do
				data.stats.familyCounts[k] = math.floor(Util.safeNumber(v, 0))
			end
		end
		if typeof(s.bestCatch) == "table" then
			data.stats.bestCatch = {
				weight = Util.safeNumber(s.bestCatch.weight, 0),
				fishId = typeof(s.bestCatch.fishId) == "string" and s.bestCatch.fishId or "",
				rarity = "common",
				weekKey = typeof(s.bestCatch.weekKey) == "string" and s.bestCatch.weekKey or "",
			}
		end
	end
	if typeof(raw.cosmetics) == "table" then
		data.cosmetics = raw.cosmetics
	end
	if typeof(raw.flags) == "table" then
		local f = raw.flags
		data.flags.tutorialDone = f.tutorialDone == true
		if typeof(f.autoSell) == "string" then
			data.flags.autoSell = f.autoSell
		end
		if typeof(f.equippedBait) == "string" and Config.BAITS[f.equippedBait] then
			data.flags.equippedBait = f.equippedBait
		end
		if typeof(f.ownedPasses) == "table" then
			for k, v  in pairs(f.ownedPasses) do
				if v then
					data.flags.ownedPasses[k] = true
				end
			end
		end
		data.flags.tokens = math.floor(Util.safeNumber(f.tokens, 0))
		data.flags.xpBoostUntil = math.floor(Util.safeNumber(f.xpBoostUntil, 0))
		if typeof(f.chestsClaimed) == "table" then
			for k, v  in pairs(f.chestsClaimed) do
				if v then
					data.flags.chestsClaimed[k] = true
				end
			end
		end
		data.flags.prestige = math.floor(Util.safeNumber(f.prestige, 0))
		data.flags.rerollsUsed = math.floor(Util.safeNumber(f.rerollsUsed, 0))
		if typeof(f.zoneRewards) == "table" then
			for k, v  in pairs(f.zoneRewards) do
				if v then
					data.flags.zoneRewards[k] = true
				end
			end
		end
		if typeof(f.receipts) == "table" then
			for k, v  in pairs(f.receipts) do
				if v then
					data.flags.receipts[k] = true
				end
			end
		end
		data.flags.contestWins = math.floor(Util.safeNumber(f.contestWins, 0))
		data.flags.starterClaimed = f.starterClaimed == true
		data.flags.invUpgradeTier = math.clamp(math.floor(Util.safeNumber(f.invUpgradeTier, 0)), 0, 3)
		if typeof(f.cosmeticsOwned) == "table" then
			for k, v in pairs(f.cosmeticsOwned) do
				if v then
					data.flags.cosmeticsOwned[k] = true
				end
			end
		end
		data.flags.guideFirstCast = f.guideFirstCast == true
		data.flags.guideFirstReel = f.guideFirstReel == true
		data.flags.guideFirstCatch = f.guideFirstCatch == true
		data.flags.guideFirstBuy = f.guideFirstBuy == true
	end
	return data
end

-- ── Load / save ──────────────────────────────────────────────────────────

function DataService:LoadProfile(player: Player): Types.ProfileData
	local key = Config.SAVE_KEY_PREFIX .. Config.SAVE_VERSION .. "_" .. player.UserId
	local ok, result = pcall(function()
		return store:GetAsync(key)
	end)
	if ok and result ~= nil then
		local decodeOk, decoded = pcall(function()
			return HttpService:JSONDecode(result)
		end)
		if decodeOk then
			return self:Sanitize(decoded)
		end
		warn("[DataService] Corrupt save for " .. player.Name .. ", using defaults")
	end
	return self:NewData()
end

function DataService:SaveProfile(player: Player): boolean
	local profile = profiles[player.UserId]
	if not profile then
		return false
	end
	local key = Config.SAVE_KEY_PREFIX .. Config.SAVE_VERSION .. "_" .. player.UserId
	local encodeOk, encoded = pcall(function()
		return HttpService:JSONEncode(profile.data)
	end)
	if not encodeOk then
		warn("[DataService] Encode failed for " .. player.Name)
		return false
	end
	local attempts = { 0, 1, 5, 15 }
	for i, delay  in pairs(attempts) do
		if i > 1 then
			task.wait(delay)
		end
		local ok, err = pcall(function()
			store:SetAsync(key, encoded)
		end)
		if ok then
			profile.dirty = false
			return true
		end
		warn("[DataService] Save retry " .. i .. " failed for " .. player.Name .. ": " .. tostring(err))
	end
	return false
end

-- ── Public API ───────────────────────────────────────────────────────────

function DataService:GetProfile(player: Player)
	return profiles[player.UserId]
end

function DataService:GetData(player: Player): Types.ProfileData?
	local profile = profiles[player.UserId]
	if profile then
		return profile.data
	end
	return nil
end

function DataService:MarkDirty(player: Player)
	local profile = profiles[player.UserId]
	if profile then
		profile.dirty = true
	end
end

function DataService:OnProfileReady(callback: (Player, Types.ProfileData) -> ())
	table.insert(profileReadyCallbacks, callback)
end

function DataService:SaveAll()
	for _, profile  in pairs(profiles) do
		self:SaveProfile(profile.player)
	end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function DataService:Init(ctx)
	self.ctx = ctx
end

function DataService:Start()
	local loadedPlayers: { [number]: boolean } = {}

	local function onPlayerAdded(player: Player)
		if loadedPlayers[player.UserId] then
			return
		end
		loadedPlayers[player.UserId] = true
		local data = self:LoadProfile(player)
		profiles[player.UserId] = { player = player, data = data, dirty = false }
		for _, cb  in pairs(profileReadyCallbacks) do
			task.spawn(cb, player, data)
		end
		-- Autosave loop
		task.spawn(function()
			while playersAlive do
				task.wait(Config.AUTOSAVE_INTERVAL)
				local profile = profiles[player.UserId]
				if profile and profile.dirty then
					self:SaveProfile(player)
				end
			end
		end)
	end

	local function onPlayerRemoving(player: Player)
		-- Persist before the player is destroyed.
		local profile = profiles[player.UserId]
		if profile then
			self:SaveProfile(player)
		end
		profiles[player.UserId] = nil
		loadedPlayers[player.UserId] = nil
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	-- Load players already present at boot AFTER other services have
	-- registered their profile-ready callbacks (they Start after us).
	task.spawn(function()
		task.wait(1)
		for _, player  in pairs(Players:GetPlayers()) do
			onPlayerAdded(player)
		end
	end)
end

function DataService:Stop()
	playersAlive = false
	self:SaveAll()
	task.wait(1)
end

return DataService
]==]
	print('[Installer] Wrote ServerScriptService/Services/DataService')
end

-- ServerScriptService/Services/EconomyService
local inst = ensure('ServerScriptService/Services/EconomyService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — EconomyService
	The ONLY place currencies change. All grants/spends are validated here.
	Guards: caps, non-negativity, integer enforcement, anomaly logging.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local EconomyService = {}
EconomyService.Name = "EconomyService"

local function validAmount(amount: any): boolean
	return typeof(amount) == "number" and amount == amount and amount > 0 and amount < 1e9
end

-- ── Coins ────────────────────────────────────────────────────────────────

function EconomyService:AddCoins(player: Player, amount: number, reason: string): number
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return 0
	end
	data.coins = math.min(Config.COIN_CAP, math.floor(data.coins + amount))
	data.stats.totalCoinsEarned = math.min(Config.COIN_CAP * 2, data.stats.totalCoinsEarned + math.floor(amount))
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	if amount > 10000 then
		warn("[Economy] Large coin grant " .. player.Name .. " +" .. amount .. " (" .. reason .. ")")
	end
	return data.coins
end

function EconomyService:SpendCoins(player: Player, amount: number, reason: string): boolean
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return false
	end
	if data.coins < amount then
		self.ctx.Services.SecurityService:Flag(player, "spend with insufficient coins (" .. reason .. ")")
		return false
	end
	data.coins = math.floor(data.coins - amount)
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return true
end

-- ── Pearls ───────────────────────────────────────────────────────────────

function EconomyService:AddPearls(player: Player, amount: number, reason: string): number
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return 0
	end
	data.pearls = math.min(Config.PEARL_CAP, math.floor(data.pearls + amount))
	data.stats.totalPearlsEarned = math.min(Config.PEARL_CAP * 2, data.stats.totalPearlsEarned + math.floor(amount))
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return data.pearls
end

function EconomyService:SpendPearls(player: Player, amount: number, reason: string): boolean
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return false
	end
	if data.pearls < amount then
		self.ctx.Services.SecurityService:Flag(player, "spend with insufficient pearls (" .. reason .. ")")
		return false
	end
	data.pearls = math.floor(data.pearls - amount)
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return true
end

-- ── XP & levels ──────────────────────────────────────────────────────────

function EconomyService:AddXP(player: Player, amount: number, reason: string): { newLevel: number, leveledUp: boolean, coinsGranted: number }
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return { newLevel = data and data.level or 1, leveledUp = false, coinsGranted = 0 }
	end
	local xpGained = math.floor(amount)
	data.xp = data.xp + xpGained
	local leveledUp = false
	local coinsGranted = 0
	while data.level < Config.MAX_LEVEL do
		local needed = Util.xpForLevel(data.level, Config.XP_BASE, Config.XP_EXPONENT)
		if data.xp < needed then
			break
		end
		data.xp -= needed
		data.level += 1
		leveledUp = true
		coinsGranted += Config.LEVEL_UP_COINS
	end
	if leveledUp then
		data.coins = math.min(Config.COIN_CAP, data.coins + coinsGranted)
		Remotes:SendToClient(player, { type = "LevelUp", payload = { level = data.level, coinsGranted = coinsGranted } })
		local questService = self.ctx.Services.QuestService
		if questService then
			questService:OnLevelUp(player, data.level)
		end
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return { newLevel = data.level, leveledUp = leveledUp, coinsGranted = coinsGranted }
end

-- ── State sync ───────────────────────────────────────────────────────────

-- Push the public subset of the profile to the client (change-based, throttled by caller)
function EconomyService:Sync(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	Remotes:SendToClient(player, {
		type = "StateSync",
		payload = {
			coins = data.coins,
			pearls = data.pearls,
			xp = data.xp,
			level = data.level,
			equippedRod = data.equippedRod,
			rods = data.rods,
			baits = data.baits,
			equippedBait = data.flags.equippedBait,
			tokens = data.flags.tokens,
			xpBoostUntil = data.flags.xpBoostUntil,
			invUpgradeTier = data.flags.invUpgradeTier,
		},
	})
end

function EconomyService:Init(ctx)
	self.ctx = ctx
end

function EconomyService:Start()
end

function EconomyService:Stop()
end

return EconomyService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — EconomyService
	The ONLY place currencies change. All grants/spends are validated here.
	Guards: caps, non-negativity, integer enforcement, anomaly logging.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local EconomyService = {}
EconomyService.Name = "EconomyService"

local function validAmount(amount: any): boolean
	return typeof(amount) == "number" and amount == amount and amount > 0 and amount < 1e9
end

-- ── Coins ────────────────────────────────────────────────────────────────

function EconomyService:AddCoins(player: Player, amount: number, reason: string): number
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return 0
	end
	data.coins = math.min(Config.COIN_CAP, math.floor(data.coins + amount))
	data.stats.totalCoinsEarned = math.min(Config.COIN_CAP * 2, data.stats.totalCoinsEarned + math.floor(amount))
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	if amount > 10000 then
		warn("[Economy] Large coin grant " .. player.Name .. " +" .. amount .. " (" .. reason .. ")")
	end
	return data.coins
end

function EconomyService:SpendCoins(player: Player, amount: number, reason: string): boolean
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return false
	end
	if data.coins < amount then
		self.ctx.Services.SecurityService:Flag(player, "spend with insufficient coins (" .. reason .. ")")
		return false
	end
	data.coins = math.floor(data.coins - amount)
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return true
end

-- ── Pearls ───────────────────────────────────────────────────────────────

function EconomyService:AddPearls(player: Player, amount: number, reason: string): number
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return 0
	end
	data.pearls = math.min(Config.PEARL_CAP, math.floor(data.pearls + amount))
	data.stats.totalPearlsEarned = math.min(Config.PEARL_CAP * 2, data.stats.totalPearlsEarned + math.floor(amount))
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return data.pearls
end

function EconomyService:SpendPearls(player: Player, amount: number, reason: string): boolean
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return false
	end
	if data.pearls < amount then
		self.ctx.Services.SecurityService:Flag(player, "spend with insufficient pearls (" .. reason .. ")")
		return false
	end
	data.pearls = math.floor(data.pearls - amount)
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return true
end

-- ── XP & levels ──────────────────────────────────────────────────────────

function EconomyService:AddXP(player: Player, amount: number, reason: string): { newLevel: number, leveledUp: boolean, coinsGranted: number }
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return { newLevel = data and data.level or 1, leveledUp = false, coinsGranted = 0 }
	end
	local xpGained = math.floor(amount)
	data.xp = data.xp + xpGained
	local leveledUp = false
	local coinsGranted = 0
	while data.level < Config.MAX_LEVEL do
		local needed = Util.xpForLevel(data.level, Config.XP_BASE, Config.XP_EXPONENT)
		if data.xp < needed then
			break
		end
		data.xp -= needed
		data.level += 1
		leveledUp = true
		coinsGranted += Config.LEVEL_UP_COINS
	end
	if leveledUp then
		data.coins = math.min(Config.COIN_CAP, data.coins + coinsGranted)
		Remotes:SendToClient(player, { type = "LevelUp", payload = { level = data.level, coinsGranted = coinsGranted } })
		local questService = self.ctx.Services.QuestService
		if questService then
			questService:OnLevelUp(player, data.level)
		end
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return { newLevel = data.level, leveledUp = leveledUp, coinsGranted = coinsGranted }
end

-- ── State sync ───────────────────────────────────────────────────────────

-- Push the public subset of the profile to the client (change-based, throttled by caller)
function EconomyService:Sync(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	Remotes:SendToClient(player, {
		type = "StateSync",
		payload = {
			coins = data.coins,
			pearls = data.pearls,
			xp = data.xp,
			level = data.level,
			equippedRod = data.equippedRod,
			rods = data.rods,
			baits = data.baits,
			equippedBait = data.flags.equippedBait,
			tokens = data.flags.tokens,
			xpBoostUntil = data.flags.xpBoostUntil,
			invUpgradeTier = data.flags.invUpgradeTier,
		},
	})
end

function EconomyService:Init(ctx)
	self.ctx = ctx
end

function EconomyService:Start()
end

function EconomyService:Stop()
end

return EconomyService
]==]
	print('[Installer] Wrote ServerScriptService/Services/EconomyService')
end

-- ServerScriptService/Services/InventoryService
local inst = ensure('ServerScriptService/Services/InventoryService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — InventoryService
	Fish inventory, bestiary, sell logic, and catch resolution.
	Owns: add/sell fish, bestiary entries, zone completion, catch stats.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)

local InventoryService = {}
InventoryService.Name = "InventoryService"

local RARITY_INDEX = Config.RARITY_INDEX

-- ── Bestiary helpers ─────────────────────────────────────────────────────

function InventoryService:GetZoneCompletion(data: Types.ProfileData, zoneId: string): number
	local zone = ZoneCatalog.Get(zoneId)
	if not zone then
		return 0
	end
	local total = #zone.fishIds
	if total == 0 then
		return 0
	end
	local caught = 0
	for _, fishId  in pairs(zone.fishIds) do
		local entry = data.bestiary[fishId]
		if entry and entry.caught > 0 then
			caught += 1
		end
	end
	return math.floor(caught / total * 100)
end

function InventoryService:GetGlobalCompletion(data: Types.ProfileData): number
	local total = 0
	local caught = 0
	for _, def  in pairs(FishCatalog.GetAll()) do
		if def.zone == "storm_any" then
			continue -- universal storm fish don't count toward bestiary %
		end
		total += 1
		local entry = data.bestiary[def.id]
		if entry and entry.caught > 0 then
			caught += 1
		end
	end
	if total == 0 then
		return 0
	end
	return math.floor(caught / total * 100)
end

-- ── Catch resolution (called by FishingService) ──────────────────────────

export type CatchOutcome = {
	uid: number,
	value: number,
	coins: number,
	xp: number,
	pearls: number,
	autoSold: boolean,
	overflowSold: boolean,
	bestiaryNew: boolean,
	zonePct: number,
	shiny: boolean,
}

function InventoryService:AddCatch(
	player: Player,
	fishDef: Types.FishDef,
	weight: number,
	shiny: boolean,
	isNight: boolean,
	isStorm: boolean,
	golden: boolean?
): CatchOutcome?
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return nil
	end
	local ctx = self.ctx

	-- Bestiary
	local entry = data.bestiary[fishDef.id]
	local bestiaryNew = entry == nil or entry.caught == 0
	if not entry then
		entry = { caught = 0, shiny = false, maxWeight = 0 }
		data.bestiary[fishDef.id] = entry
	end
	entry.caught += 1
	if shiny then
		entry.shiny = true
	end
	if weight > entry.maxWeight then
		entry.maxWeight = weight
	end

	-- Stats
	local stats = data.stats
	stats.totalCatch += 1
	stats.zoneCounts[fishDef.zone] = (stats.zoneCounts[fishDef.zone] or 0) + 1
	stats.familyCounts[fishDef.family] = (stats.familyCounts[fishDef.family] or 0) + 1
	if isNight then
		stats.nightFish += 1
	end
	if isStorm then
		stats.stormFish += 1
	end
	if shiny then
		stats.shinyFish += 1
	end
	if (RARITY_INDEX[fishDef.rarity] or 1) >= 4 then
		stats.epicPlus += 1
	end
	if ZoneCatalog.IsDeepFamily(fishDef.family) then
		stats.deepFish += 1
	end

	-- Value / coins / xp
	local value = Util.round(fishDef.baseValue * weight, 0)
	if shiny then
		value = math.floor(value * Config.SHINY_VALUE_MULT)
	end
	if golden then
		value = math.floor(value * Config.GOLDEN_SPOT_VALUE_MULT)
	end
	local coins = value
	if data.flags.ownedPasses.double_catch then
		coins = math.floor(coins * Config.DOUBLE_COINS_MULT)
	end
	local xp = fishDef.xp
	if isStorm then
		xp = math.floor(xp * Config.STORM_XP_MULT)
	end
	if data.flags.ownedPasses.vip_angler then
		xp = math.floor(xp * Config.VIP_XP_MULT)
	end
	if os.time() < data.flags.xpBoostUntil then
		xp = math.floor(xp * Config.XP_BOOST_MULT)
	end

	-- Auto-sell / inventory
	local autoSold = false
	local overflowSold = false
	local uid = 0
	local autoSellRarity = data.flags.autoSell
	if autoSellRarity and (RARITY_INDEX[fishDef.rarity] or 1) <= (RARITY_INDEX[autoSellRarity] or 1) then
		autoSold = true
	else
		if #data.inventory >= Config.INVENTORY_CAP then
			-- Overflow: sell the oldest common/uncommon to make room
			local soldValue = 0
			for i, item  in pairs(data.inventory) do
				local def = FishCatalog.Get(item.fishId)
				if def and (RARITY_INDEX[def.rarity] or 1) <= 2 then
					soldValue = math.floor(def.baseValue * item.weight)
					if item.shiny then
						soldValue *= Config.SHINY_VALUE_MULT
					end
					table.remove(data.inventory, i)
					stats.totalCoinsEarned += soldValue
					break
				end
			end
			if soldValue > 0 then
				overflowSold = true
				coins += soldValue
			else
				autoSold = true -- inventory full of rares; this catch sells itself
			end
		end
		if not autoSold then
			uid = data.nextUid
			data.nextUid += 1
			table.insert(data.inventory, {
				uid = uid,
				fishId = fishDef.id,
				weight = weight,
				shiny = shiny,
				caughtAt = os.time(),
			})
		end
	end

	-- Economy
	local economy = ctx.Services.EconomyService
	economy:AddCoins(player, coins, "catch:" .. fishDef.id)
	economy:AddXP(player, xp, "catch:" .. fishDef.id)

	-- Pearl drops (rare, capped by design)
	local pearls = 0
	if (RARITY_INDEX[fishDef.rarity] or 1) >= (RARITY_INDEX[Config.PEARL_DROP_MIN_RARITY] or 4) and Util.rollChance(Config.PEARL_DROP_CHANCE) then
		pearls += 1
		economy:AddPearls(player, 1, "drop")
	end
	if isStorm and Util.rollChance(Config.STORM_PEARL_CHANCE) then
		pearls += 1
		economy:AddPearls(player, 1, "storm")
	end

	-- Zone completion rewards
	local zonePct = self:GetZoneCompletion(data, fishDef.zone)
	if zonePct >= 100 and not data.flags.zoneRewards[fishDef.zone] then
		data.flags.zoneRewards[fishDef.zone] = true
		economy:AddPearls(player, 10, "zone_complete:" .. fishDef.zone)
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "zoneComplete", text = "Bestiary complete in " .. fishDef.zone .. "! +10 pearls" },
		})
	end

	-- Quest / achievement hooks
	local questService = ctx.Services.QuestService
	if questService then
		questService:OnFishCaught(player, fishDef, isNight, isStorm, shiny)
	end

	-- Guide: first catch
	local world = ctx.Services.WorldInteractionsService
	if world and world.OnFirstCatch then
		world:OnFirstCatch(player)
	end

	-- Weekly contest submission
	local leaderboardService = ctx.Services.LeaderboardService
	if leaderboardService and not autoSold then
		leaderboardService:SubmitCatch(player, weight, fishDef.id, fishDef.rarity)
	end

	ctx.Services.DataService:MarkDirty(player)
	Remotes:SendToClient(player, { type = "BestiaryUpdate", payload = { fishId = fishDef.id, shiny = shiny, zonePct = zonePct, bestiaryNew = bestiaryNew } })

	return {
		uid = uid,
		value = value,
		coins = coins,
		xp = xp,
		pearls = pearls,
		autoSold = autoSold,
		overflowSold = overflowSold,
		bestiaryNew = bestiaryNew,
		zonePct = zonePct,
		shiny = shiny,
	}
end

-- ── Selling ──────────────────────────────────────────────────────────────

function InventoryService:SellFish(player: Player, ids: { number }): (boolean, string?)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return false, "no profile"
	end
	if typeof(ids) ~= "table" or #ids == 0 or #ids > 50 then
		return false, "bad ids"
	end
	local seen: { [number]: boolean } = {}
	local total = 0
	local sold = 0
	for _, uid  in pairs(ids) do
		if typeof(uid) ~= "number" or seen[uid] then
			continue
		end
		seen[uid] = true
		for i, item  in pairs(data.inventory) do
			if item.uid == uid then
				local def = FishCatalog.Get(item.fishId)
				if def then
					local v = math.floor(def.baseValue * item.weight)
					if item.shiny then
						v *= Config.SHINY_VALUE_MULT
					end
					total += v
				end
				table.remove(data.inventory, i)
				sold += 1
				break
			end
		end
	end
	if sold == 0 then
		return false, "no valid fish"
	end
	local economy = self.ctx.Services.EconomyService
	economy:AddCoins(player, total, "sell")
	local questService = self.ctx.Services.QuestService
	if questService then
		questService:OnSell(player, total)
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendInventory(player)
	return true
end

function InventoryService:SellAll(player: Player, maxRarity: string): (boolean, string?)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return false, "no profile"
	end
	local maxIdx = RARITY_INDEX[maxRarity] or 2
	local total = 0
	local kept: { Types.InventoryFish } = {}
	for _, item  in pairs(data.inventory) do
		local def = FishCatalog.Get(item.fishId)
		local idx = def and (RARITY_INDEX[def.rarity] or 1) or 1
		if idx <= maxIdx and not item.shiny then
			if def then
				local v = math.floor(def.baseValue * item.weight)
				total += v
			end
		else
			table.insert(kept, item)
		end
	end
	if total <= 0 then
		return false, "nothing to sell"
	end
	data.inventory = kept
	local economy = self.ctx.Services.EconomyService
	economy:AddCoins(player, total, "sell_all")
	local questService = self.ctx.Services.QuestService
	if questService then
		questService:OnSell(player, total)
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendInventory(player)
	return true
end

function InventoryService:SetAutoSell(player: Player, maxRarity: string?)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if maxRarity == nil then
		data.flags.autoSell = nil
	elseif RARITY_INDEX[maxRarity] then
		data.flags.autoSell = maxRarity
	else
		return
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendInventory(player)
end

-- Push inventory + bestiary snapshot to a client
function InventoryService:SendInventory(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local upgradeSlots = 0
	for i = 1, data.flags.invUpgradeTier do
		local tier = Config.INVENTORY_UPGRADES[i]
		if tier then
			upgradeSlots += tier.slots
		end
	end
	local passSlots = data.flags.ownedPasses.bigger_tackle_box and 50 or 0
	Remotes:SendToClient(player, {
		type = "InventorySync",
		payload = {
			inventory = data.inventory,
			bestiary = data.bestiary,
			globalPct = self:GetGlobalCompletion(data),
			autoSell = data.flags.autoSell,
			invSlots = Config.INVENTORY_START + upgradeSlots + passSlots,
			achievements = data.achievements,
			titles = data.titles,
			equippedTitle = data.equippedTitle,
			cosmetics = data.cosmetics,
			cosmeticsOwned = data.flags.cosmeticsOwned,
			stats = {
				totalCatch = data.stats.totalCatch,
				totalCoinsEarned = data.stats.totalCoinsEarned,
				totalPearlsEarned = data.stats.totalPearlsEarned,
				shinyFish = data.stats.shinyFish,
				stormFish = data.stats.stormFish,
				nightFish = data.stats.nightFish,
				deepFish = data.stats.deepFish,
				bestCatch = data.stats.bestCatch,
			},
		},
	})
end

function InventoryService:Init(ctx)
	self.ctx = ctx
end

function InventoryService:Start()
end

function InventoryService:Stop()
end

return InventoryService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — InventoryService
	Fish inventory, bestiary, sell logic, and catch resolution.
	Owns: add/sell fish, bestiary entries, zone completion, catch stats.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)

local InventoryService = {}
InventoryService.Name = "InventoryService"

local RARITY_INDEX = Config.RARITY_INDEX

-- ── Bestiary helpers ─────────────────────────────────────────────────────

function InventoryService:GetZoneCompletion(data: Types.ProfileData, zoneId: string): number
	local zone = ZoneCatalog.Get(zoneId)
	if not zone then
		return 0
	end
	local total = #zone.fishIds
	if total == 0 then
		return 0
	end
	local caught = 0
	for _, fishId  in pairs(zone.fishIds) do
		local entry = data.bestiary[fishId]
		if entry and entry.caught > 0 then
			caught += 1
		end
	end
	return math.floor(caught / total * 100)
end

function InventoryService:GetGlobalCompletion(data: Types.ProfileData): number
	local total = 0
	local caught = 0
	for _, def  in pairs(FishCatalog.GetAll()) do
		if def.zone == "storm_any" then
			continue -- universal storm fish don't count toward bestiary %
		end
		total += 1
		local entry = data.bestiary[def.id]
		if entry and entry.caught > 0 then
			caught += 1
		end
	end
	if total == 0 then
		return 0
	end
	return math.floor(caught / total * 100)
end

-- ── Catch resolution (called by FishingService) ──────────────────────────

export type CatchOutcome = {
	uid: number,
	value: number,
	coins: number,
	xp: number,
	pearls: number,
	autoSold: boolean,
	overflowSold: boolean,
	bestiaryNew: boolean,
	zonePct: number,
	shiny: boolean,
}

function InventoryService:AddCatch(
	player: Player,
	fishDef: Types.FishDef,
	weight: number,
	shiny: boolean,
	isNight: boolean,
	isStorm: boolean,
	golden: boolean?
): CatchOutcome?
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return nil
	end
	local ctx = self.ctx

	-- Bestiary
	local entry = data.bestiary[fishDef.id]
	local bestiaryNew = entry == nil or entry.caught == 0
	if not entry then
		entry = { caught = 0, shiny = false, maxWeight = 0 }
		data.bestiary[fishDef.id] = entry
	end
	entry.caught += 1
	if shiny then
		entry.shiny = true
	end
	if weight > entry.maxWeight then
		entry.maxWeight = weight
	end

	-- Stats
	local stats = data.stats
	stats.totalCatch += 1
	stats.zoneCounts[fishDef.zone] = (stats.zoneCounts[fishDef.zone] or 0) + 1
	stats.familyCounts[fishDef.family] = (stats.familyCounts[fishDef.family] or 0) + 1
	if isNight then
		stats.nightFish += 1
	end
	if isStorm then
		stats.stormFish += 1
	end
	if shiny then
		stats.shinyFish += 1
	end
	if (RARITY_INDEX[fishDef.rarity] or 1) >= 4 then
		stats.epicPlus += 1
	end
	if ZoneCatalog.IsDeepFamily(fishDef.family) then
		stats.deepFish += 1
	end

	-- Value / coins / xp
	local value = Util.round(fishDef.baseValue * weight, 0)
	if shiny then
		value = math.floor(value * Config.SHINY_VALUE_MULT)
	end
	if golden then
		value = math.floor(value * Config.GOLDEN_SPOT_VALUE_MULT)
	end
	local coins = value
	if data.flags.ownedPasses.double_catch then
		coins = math.floor(coins * Config.DOUBLE_COINS_MULT)
	end
	local xp = fishDef.xp
	if isStorm then
		xp = math.floor(xp * Config.STORM_XP_MULT)
	end
	if data.flags.ownedPasses.vip_angler then
		xp = math.floor(xp * Config.VIP_XP_MULT)
	end
	if os.time() < data.flags.xpBoostUntil then
		xp = math.floor(xp * Config.XP_BOOST_MULT)
	end

	-- Auto-sell / inventory
	local autoSold = false
	local overflowSold = false
	local uid = 0
	local autoSellRarity = data.flags.autoSell
	if autoSellRarity and (RARITY_INDEX[fishDef.rarity] or 1) <= (RARITY_INDEX[autoSellRarity] or 1) then
		autoSold = true
	else
		if #data.inventory >= Config.INVENTORY_CAP then
			-- Overflow: sell the oldest common/uncommon to make room
			local soldValue = 0
			for i, item  in pairs(data.inventory) do
				local def = FishCatalog.Get(item.fishId)
				if def and (RARITY_INDEX[def.rarity] or 1) <= 2 then
					soldValue = math.floor(def.baseValue * item.weight)
					if item.shiny then
						soldValue *= Config.SHINY_VALUE_MULT
					end
					table.remove(data.inventory, i)
					stats.totalCoinsEarned += soldValue
					break
				end
			end
			if soldValue > 0 then
				overflowSold = true
				coins += soldValue
			else
				autoSold = true -- inventory full of rares; this catch sells itself
			end
		end
		if not autoSold then
			uid = data.nextUid
			data.nextUid += 1
			table.insert(data.inventory, {
				uid = uid,
				fishId = fishDef.id,
				weight = weight,
				shiny = shiny,
				caughtAt = os.time(),
			})
		end
	end

	-- Economy
	local economy = ctx.Services.EconomyService
	economy:AddCoins(player, coins, "catch:" .. fishDef.id)
	economy:AddXP(player, xp, "catch:" .. fishDef.id)

	-- Pearl drops (rare, capped by design)
	local pearls = 0
	if (RARITY_INDEX[fishDef.rarity] or 1) >= (RARITY_INDEX[Config.PEARL_DROP_MIN_RARITY] or 4) and Util.rollChance(Config.PEARL_DROP_CHANCE) then
		pearls += 1
		economy:AddPearls(player, 1, "drop")
	end
	if isStorm and Util.rollChance(Config.STORM_PEARL_CHANCE) then
		pearls += 1
		economy:AddPearls(player, 1, "storm")
	end

	-- Zone completion rewards
	local zonePct = self:GetZoneCompletion(data, fishDef.zone)
	if zonePct >= 100 and not data.flags.zoneRewards[fishDef.zone] then
		data.flags.zoneRewards[fishDef.zone] = true
		economy:AddPearls(player, 10, "zone_complete:" .. fishDef.zone)
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "zoneComplete", text = "Bestiary complete in " .. fishDef.zone .. "! +10 pearls" },
		})
	end

	-- Quest / achievement hooks
	local questService = ctx.Services.QuestService
	if questService then
		questService:OnFishCaught(player, fishDef, isNight, isStorm, shiny)
	end

	-- Guide: first catch
	local world = ctx.Services.WorldInteractionsService
	if world and world.OnFirstCatch then
		world:OnFirstCatch(player)
	end

	-- Weekly contest submission
	local leaderboardService = ctx.Services.LeaderboardService
	if leaderboardService and not autoSold then
		leaderboardService:SubmitCatch(player, weight, fishDef.id, fishDef.rarity)
	end

	ctx.Services.DataService:MarkDirty(player)
	Remotes:SendToClient(player, { type = "BestiaryUpdate", payload = { fishId = fishDef.id, shiny = shiny, zonePct = zonePct, bestiaryNew = bestiaryNew } })

	return {
		uid = uid,
		value = value,
		coins = coins,
		xp = xp,
		pearls = pearls,
		autoSold = autoSold,
		overflowSold = overflowSold,
		bestiaryNew = bestiaryNew,
		zonePct = zonePct,
		shiny = shiny,
	}
end

-- ── Selling ──────────────────────────────────────────────────────────────

function InventoryService:SellFish(player: Player, ids: { number }): (boolean, string?)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return false, "no profile"
	end
	if typeof(ids) ~= "table" or #ids == 0 or #ids > 50 then
		return false, "bad ids"
	end
	local seen: { [number]: boolean } = {}
	local total = 0
	local sold = 0
	for _, uid  in pairs(ids) do
		if typeof(uid) ~= "number" or seen[uid] then
			continue
		end
		seen[uid] = true
		for i, item  in pairs(data.inventory) do
			if item.uid == uid then
				local def = FishCatalog.Get(item.fishId)
				if def then
					local v = math.floor(def.baseValue * item.weight)
					if item.shiny then
						v *= Config.SHINY_VALUE_MULT
					end
					total += v
				end
				table.remove(data.inventory, i)
				sold += 1
				break
			end
		end
	end
	if sold == 0 then
		return false, "no valid fish"
	end
	local economy = self.ctx.Services.EconomyService
	economy:AddCoins(player, total, "sell")
	local questService = self.ctx.Services.QuestService
	if questService then
		questService:OnSell(player, total)
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendInventory(player)
	return true
end

function InventoryService:SellAll(player: Player, maxRarity: string): (boolean, string?)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return false, "no profile"
	end
	local maxIdx = RARITY_INDEX[maxRarity] or 2
	local total = 0
	local kept: { Types.InventoryFish } = {}
	for _, item  in pairs(data.inventory) do
		local def = FishCatalog.Get(item.fishId)
		local idx = def and (RARITY_INDEX[def.rarity] or 1) or 1
		if idx <= maxIdx and not item.shiny then
			if def then
				local v = math.floor(def.baseValue * item.weight)
				total += v
			end
		else
			table.insert(kept, item)
		end
	end
	if total <= 0 then
		return false, "nothing to sell"
	end
	data.inventory = kept
	local economy = self.ctx.Services.EconomyService
	economy:AddCoins(player, total, "sell_all")
	local questService = self.ctx.Services.QuestService
	if questService then
		questService:OnSell(player, total)
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendInventory(player)
	return true
end

function InventoryService:SetAutoSell(player: Player, maxRarity: string?)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if maxRarity == nil then
		data.flags.autoSell = nil
	elseif RARITY_INDEX[maxRarity] then
		data.flags.autoSell = maxRarity
	else
		return
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendInventory(player)
end

-- Push inventory + bestiary snapshot to a client
function InventoryService:SendInventory(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local upgradeSlots = 0
	for i = 1, data.flags.invUpgradeTier do
		local tier = Config.INVENTORY_UPGRADES[i]
		if tier then
			upgradeSlots += tier.slots
		end
	end
	local passSlots = data.flags.ownedPasses.bigger_tackle_box and 50 or 0
	Remotes:SendToClient(player, {
		type = "InventorySync",
		payload = {
			inventory = data.inventory,
			bestiary = data.bestiary,
			globalPct = self:GetGlobalCompletion(data),
			autoSell = data.flags.autoSell,
			invSlots = Config.INVENTORY_START + upgradeSlots + passSlots,
			achievements = data.achievements,
			titles = data.titles,
			equippedTitle = data.equippedTitle,
			cosmetics = data.cosmetics,
			cosmeticsOwned = data.flags.cosmeticsOwned,
			stats = {
				totalCatch = data.stats.totalCatch,
				totalCoinsEarned = data.stats.totalCoinsEarned,
				totalPearlsEarned = data.stats.totalPearlsEarned,
				shinyFish = data.stats.shinyFish,
				stormFish = data.stats.stormFish,
				nightFish = data.stats.nightFish,
				deepFish = data.stats.deepFish,
				bestCatch = data.stats.bestCatch,
			},
		},
	})
end

function InventoryService:Init(ctx)
	self.ctx = ctx
end

function InventoryService:Start()
end

function InventoryService:Stop()
end

return InventoryService
]==]
	print('[Installer] Wrote ServerScriptService/Services/InventoryService')
end

-- ServerScriptService/Services/QuestService
local inst = ensure('ServerScriptService/Services/QuestService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — QuestService
	Daily/weekly quests, login streak, achievements. All server-side.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local QuestCatalog = require(ReplicatedStorage.Shared.Data.QuestCatalog)

local QuestService = {}
QuestService.Name = "QuestService"

-- Families available for "catch family" quests
local FAMILIES = {
	"shoal", "reef", "carp", "koi", "sturgeon", "bass", "serpent", "glow",
	"hunter", "cod", "squid", "angler", "eel", "wraith", "trout", "gar",
	"salmon", "pike", "whale", "leviathan", "storm", "char", "fang", "devil", "mist",
}
local MAIN_ZONES = { "sunshall", "whisper", "drop", "ember", "frost", "abyss" }

-- ── Quest rollover ───────────────────────────────────────────────────────

function QuestService:RollDaily(data: Types.ProfileData)
	local exclude: { [string]: boolean } = {}
	for _, q  in pairs(data.dailyQuests) do
		exclude[q.templateId] = true
	end
	local pool = QuestCatalog.RollTemplates(QuestCatalog.DAILY_POOL, exclude)
	data.dailyQuests = {}
	for i = 1, Config.DAILY_QUESTS do
		local t = pool[i]
		if not t then
			break
		end
		local params: { [string]: string } = {}
		if t.param == "zone" then
			params.zone = MAIN_ZONES[math.random(1, #MAIN_ZONES)]
		elseif t.param == "family" then
			params.family = FAMILIES[math.random(1, #FAMILIES)]
		end
		table.insert(data.dailyQuests, {
			templateId = t.id,
			params = params,
			progress = 0,
			done = false,
			claimed = false,
		})
	end
end

function QuestService:RollWeekly(data: Types.ProfileData)
	local exclude: { [string]: boolean } = {}
	for _, q  in pairs(data.weeklyQuests) do
		exclude[q.templateId] = true
	end
	local pool = QuestCatalog.RollTemplates(QuestCatalog.WEEKLY_POOL, exclude)
	data.weeklyQuests = {}
	for i = 1, Config.WEEKLY_QUESTS do
		local t = pool[i]
		if not t then
			break
		end
		table.insert(data.weeklyQuests, {
			templateId = t.id,
			params = {},
			progress = 0,
			done = false,
			claimed = false,
		})
	end
end

-- Called on join and before any quest-touching action
function QuestService:EnsureRollovers(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local changed = false

	local today = Util.todayKey()
	if data.questDay ~= today then
		self:RollDaily(data)
		data.questDay = today
		data.flags.rerollsUsed = 0
		changed = true
	end
	local week = Util.weekKey()
	if data.questWeek ~= week then
		self:RollWeekly(data)
		data.questWeek = week
		changed = true
	end

	-- Login streak (day-based; cycle resets at 7)
	if data.streakLastDay ~= today then
		if data.streakLastDay == Util.yesterdayKey() then
			data.streak = if data.streak >= 7 then 1 else data.streak + 1
		else
			data.streak = 1
		end
		local reward = Config.STREAK_REWARDS[data.streak] or { coins = 50 }
		if reward.coins then
			self.ctx.Services.EconomyService:AddCoins(player, reward.coins, "streak")
		end
		if reward.pearls then
			self.ctx.Services.EconomyService:AddPearls(player, reward.pearls, "streak")
		end
		for _, baitId in ipairs({ "worm", "shrimp", "squid", "golden" }) do
			local n = reward[baitId]
			if n then
				data.baits[baitId] = (data.baits[baitId] or 0) + n
			end
		end
		data.streakLastDay = today
		changed = true
		Remotes:SendToClient(player, {
			type = "StreakUpdate",
			payload = { streak = data.streak, reward = reward },
		})
	end

	if changed then
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendQuestUpdate(player)
	end
end

-- ── Quest progress hooks ─────────────────────────────────────────────────

function QuestService:OnFishCaught(player: Player, def: Types.FishDef, isNight: boolean, isStorm: boolean, shiny: boolean)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local idx = Config.RARITY_INDEX[def.rarity] or 1
	local function advance(list: { Types.QuestProgress }, pool: any)
		for _, q  in pairs(list) do
			if q.claimed or q.done then
				continue
			end
			local t = pool(q.templateId)
			if not t then
				continue
			end
			local matched = false
			if t.type == "catchTotal" then
				matched = true
			elseif t.type == "catchZone" then
				matched = q.params.zone == def.zone
			elseif t.type == "catchNight" then
				matched = isNight
			elseif t.type == "catchRarity" then
				matched = idx >= 4
			elseif t.type == "catchStorm" then
				matched = isStorm
			elseif t.type == "catchFamily" then
				matched = q.params.family == def.family
			elseif t.type == "catchShiny" then
				matched = shiny
			end
			if matched then
				q.progress += 1
				if q.progress >= t.target then
					q.done = true
				end
			end
		end
	end
	advance(data.dailyQuests, QuestCatalog.GetDailyTemplate)
	advance(data.weeklyQuests, QuestCatalog.GetWeeklyTemplate)
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
	self:CheckAchievements(player)
end

function QuestService:OnSell(player: Player, coins: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local function advance(list: { Types.QuestProgress }, pool: any)
		for _, q  in pairs(list) do
			if q.claimed or q.done then
				continue
			end
			local t = pool(q.templateId)
			if t and t.type == "sellCoins" then
				q.progress += coins
				if q.progress >= t.target then
					q.done = true
				end
			end
		end
	end
	advance(data.dailyQuests, QuestCatalog.GetDailyTemplate)
	advance(data.weeklyQuests, QuestCatalog.GetWeeklyTemplate)
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

function QuestService:OnLevelUp(player: Player, _level: number)
	self:CheckAchievements(player)
end

function QuestService:OnZoneComplete(player: Player, _zoneId: string)
	self:CheckAchievements(player)
end

-- ── Claims & reroll ──────────────────────────────────────────────────────

function QuestService:ClaimDaily(player: Player, slot: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local q = data.dailyQuests[slot]
	if not q or not q.done or q.claimed then
		return
	end
	local t = QuestCatalog.GetDailyTemplate(q.templateId)
	if not t then
		return
	end
	self:GrantRewards(player, t.rewards)
	q.claimed = true
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

function QuestService:ClaimWeekly(player: Player, slot: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local q = data.weeklyQuests[slot]
	if not q or not q.done or q.claimed then
		return
	end
	local t = QuestCatalog.GetWeeklyTemplate(q.templateId)
	if not t then
		return
	end
	self:GrantRewards(player, t.rewards)
	q.claimed = true
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

function QuestService:GrantRewards(player: Player, rewards: { coins: number?, pearls: number?, bait: string? })
	if rewards.coins then
		self.ctx.Services.EconomyService:AddCoins(player, rewards.coins, "quest")
	end
	if rewards.pearls then
		self.ctx.Services.EconomyService:AddPearls(player, rewards.pearls, "quest")
	end
	if rewards.bait then
		local data = self.ctx.Services.DataService:GetData(player)
		if data then
			data.baits[rewards.bait] = (data.baits[rewards.bait] or 0) + 5
		end
	end
end

function QuestService:RerollQuest(player: Player, slot: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if data.flags.rerollsUsed >= 1 then
		return
	end
	local current = data.dailyQuests[slot]
	if not current then
		return
	end
	local exclude: { [string]: boolean } = {}
	for _, q  in pairs(data.dailyQuests) do
		exclude[q.templateId] = true
	end
	local pool = QuestCatalog.RollTemplates(QuestCatalog.DAILY_POOL, exclude)
	local t = pool[1]
	if not t then
		return
	end
	local params: { [string]: string } = {}
	if t.param == "zone" then
		params.zone = MAIN_ZONES[math.random(1, #MAIN_ZONES)]
	elseif t.param == "family" then
		params.family = FAMILIES[math.random(1, #FAMILIES)]
	end
	data.dailyQuests[slot] = {
		templateId = t.id,
		params = params,
		progress = 0,
		done = false,
		claimed = false,
	}
	data.flags.rerollsUsed = 1
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

-- ── Achievements ─────────────────────────────────────────────────────────

local CONDITIONS: { [string]: (Types.ProfileData) -> boolean } = {
	first_catch = function(d)
		return d.stats.totalCatch >= 1
	end,
	first_shiny = function(d)
		return d.stats.shinyFish >= 1
	end,
	fish_100 = function(d)
		return d.stats.totalCatch >= 100
	end,
	fish_1000 = function(d)
		return d.stats.totalCatch >= 1000
	end,
	coins_10k = function(d)
		return d.stats.totalCoinsEarned >= 10000
	end,
	coins_100k = function(d)
		return d.stats.totalCoinsEarned >= 100000
	end,
	night_owl = function(d)
		return d.stats.nightFish >= 20
	end,
	storm_chaser = function(d)
		return d.stats.stormFish >= 10
	end,
	deep_diver = function(d)
		return d.stats.deepFish >= 50
	end,
	old_one_witness = function(d)
		local e = d.bestiary.old_one
		return e ~= nil and e.caught > 0
	end,
	secret_finder = function(d)
		local e = d.bestiary.mistfin
		return e ~= nil and e.caught > 0
	end,
	grotto_finder = function(d)
		local e = d.bestiary.grotto_glowfin
		return e ~= nil and e.caught > 0
	end,
	level_10 = function(d)
		return d.level >= 10
	end,
	level_25 = function(d)
		return d.level >= 25
	end,
	level_50 = function(d)
		return d.level >= Config.MAX_LEVEL
	end,
	rod_collector = function(d)
		for _, def in pairs(require(ReplicatedStorage.Shared.Data.RodCatalog).GetAll()) do
			if not d.rods[def.id] then
				return false
			end
		end
		return true
	end,
	zone_master = function(d)
		for _, _  in pairs(d.flags.zoneRewards) do
			return true
		end
		return false
	end,
	all_zones = function(d)
		for _, zoneId  in pairs(MAIN_ZONES) do
			if not d.flags.zoneRewards[zoneId] then
				return false
			end
		end
		return true
	end,
	contest_winner = function(d)
		return d.flags.contestWins >= 1
	end,
	pearl_earner = function(d)
		return d.stats.totalPearlsEarned >= 100
	end,
	shiny_10 = function(d)
		return d.stats.shinyFish >= 10
	end,
}

function QuestService:CheckAchievements(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local changed = false
	for _, def  in pairs(QuestCatalog.ACHIEVEMENTS) do
		if data.achievements[def.id] then
			continue
		end
		local cond = CONDITIONS[def.id]
		if cond and cond(data) then
			data.achievements[def.id] = true
			if def.rewards.pearls then
				self.ctx.Services.EconomyService:AddPearls(player, def.rewards.pearls, "achievement:" .. def.id)
			end
			if def.rewards.title then
				data.titles[def.rewards.title] = true
				if not data.equippedTitle then
					data.equippedTitle = def.rewards.title
				end
			end
			Remotes:SendToClient(player, {
				type = "AchievementUnlock",
				payload = { id = def.id, name = def.name, desc = def.desc },
			})
			changed = true
		end
	end
	if changed then
		self.ctx.Services.DataService:MarkDirty(player)
	end
end

-- ── Sync ─────────────────────────────────────────────────────────────────

function QuestService:SendQuestUpdate(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	Remotes:SendToClient(player, {
		type = "QuestUpdate",
		payload = {
			daily = data.dailyQuests,
			weekly = data.weeklyQuests,
			streak = data.streak,
		},
	})
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function QuestService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.ClaimDaily = function(player, payload)
		self:ClaimDaily(player, Util.safeNumber(payload and payload.slot, 1))
	end
	ctx.MessageHandlers.ClaimWeekly = function(player, payload)
		self:ClaimWeekly(player, Util.safeNumber(payload and payload.slot, 1))
	end
	ctx.MessageHandlers.RerollQuest = function(player, payload)
		self:RerollQuest(player, Util.safeNumber(payload and payload.slot, 1))
	end
end

function QuestService:Start()
	self.ctx.Services.DataService:OnProfileReady(function(player, _data)
		self:EnsureRollovers(player)
		self:CheckAchievements(player)
	end)
end

function QuestService:Stop()
end

return QuestService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — QuestService
	Daily/weekly quests, login streak, achievements. All server-side.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local QuestCatalog = require(ReplicatedStorage.Shared.Data.QuestCatalog)

local QuestService = {}
QuestService.Name = "QuestService"

-- Families available for "catch family" quests
local FAMILIES = {
	"shoal", "reef", "carp", "koi", "sturgeon", "bass", "serpent", "glow",
	"hunter", "cod", "squid", "angler", "eel", "wraith", "trout", "gar",
	"salmon", "pike", "whale", "leviathan", "storm", "char", "fang", "devil", "mist",
}
local MAIN_ZONES = { "sunshall", "whisper", "drop", "ember", "frost", "abyss" }

-- ── Quest rollover ───────────────────────────────────────────────────────

function QuestService:RollDaily(data: Types.ProfileData)
	local exclude: { [string]: boolean } = {}
	for _, q  in pairs(data.dailyQuests) do
		exclude[q.templateId] = true
	end
	local pool = QuestCatalog.RollTemplates(QuestCatalog.DAILY_POOL, exclude)
	data.dailyQuests = {}
	for i = 1, Config.DAILY_QUESTS do
		local t = pool[i]
		if not t then
			break
		end
		local params: { [string]: string } = {}
		if t.param == "zone" then
			params.zone = MAIN_ZONES[math.random(1, #MAIN_ZONES)]
		elseif t.param == "family" then
			params.family = FAMILIES[math.random(1, #FAMILIES)]
		end
		table.insert(data.dailyQuests, {
			templateId = t.id,
			params = params,
			progress = 0,
			done = false,
			claimed = false,
		})
	end
end

function QuestService:RollWeekly(data: Types.ProfileData)
	local exclude: { [string]: boolean } = {}
	for _, q  in pairs(data.weeklyQuests) do
		exclude[q.templateId] = true
	end
	local pool = QuestCatalog.RollTemplates(QuestCatalog.WEEKLY_POOL, exclude)
	data.weeklyQuests = {}
	for i = 1, Config.WEEKLY_QUESTS do
		local t = pool[i]
		if not t then
			break
		end
		table.insert(data.weeklyQuests, {
			templateId = t.id,
			params = {},
			progress = 0,
			done = false,
			claimed = false,
		})
	end
end

-- Called on join and before any quest-touching action
function QuestService:EnsureRollovers(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local changed = false

	local today = Util.todayKey()
	if data.questDay ~= today then
		self:RollDaily(data)
		data.questDay = today
		data.flags.rerollsUsed = 0
		changed = true
	end
	local week = Util.weekKey()
	if data.questWeek ~= week then
		self:RollWeekly(data)
		data.questWeek = week
		changed = true
	end

	-- Login streak (day-based; cycle resets at 7)
	if data.streakLastDay ~= today then
		if data.streakLastDay == Util.yesterdayKey() then
			data.streak = if data.streak >= 7 then 1 else data.streak + 1
		else
			data.streak = 1
		end
		local reward = Config.STREAK_REWARDS[data.streak] or { coins = 50 }
		if reward.coins then
			self.ctx.Services.EconomyService:AddCoins(player, reward.coins, "streak")
		end
		if reward.pearls then
			self.ctx.Services.EconomyService:AddPearls(player, reward.pearls, "streak")
		end
		for _, baitId in ipairs({ "worm", "shrimp", "squid", "golden" }) do
			local n = reward[baitId]
			if n then
				data.baits[baitId] = (data.baits[baitId] or 0) + n
			end
		end
		data.streakLastDay = today
		changed = true
		Remotes:SendToClient(player, {
			type = "StreakUpdate",
			payload = { streak = data.streak, reward = reward },
		})
	end

	if changed then
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendQuestUpdate(player)
	end
end

-- ── Quest progress hooks ─────────────────────────────────────────────────

function QuestService:OnFishCaught(player: Player, def: Types.FishDef, isNight: boolean, isStorm: boolean, shiny: boolean)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local idx = Config.RARITY_INDEX[def.rarity] or 1
	local function advance(list: { Types.QuestProgress }, pool: any)
		for _, q  in pairs(list) do
			if q.claimed or q.done then
				continue
			end
			local t = pool(q.templateId)
			if not t then
				continue
			end
			local matched = false
			if t.type == "catchTotal" then
				matched = true
			elseif t.type == "catchZone" then
				matched = q.params.zone == def.zone
			elseif t.type == "catchNight" then
				matched = isNight
			elseif t.type == "catchRarity" then
				matched = idx >= 4
			elseif t.type == "catchStorm" then
				matched = isStorm
			elseif t.type == "catchFamily" then
				matched = q.params.family == def.family
			elseif t.type == "catchShiny" then
				matched = shiny
			end
			if matched then
				q.progress += 1
				if q.progress >= t.target then
					q.done = true
				end
			end
		end
	end
	advance(data.dailyQuests, QuestCatalog.GetDailyTemplate)
	advance(data.weeklyQuests, QuestCatalog.GetWeeklyTemplate)
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
	self:CheckAchievements(player)
end

function QuestService:OnSell(player: Player, coins: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local function advance(list: { Types.QuestProgress }, pool: any)
		for _, q  in pairs(list) do
			if q.claimed or q.done then
				continue
			end
			local t = pool(q.templateId)
			if t and t.type == "sellCoins" then
				q.progress += coins
				if q.progress >= t.target then
					q.done = true
				end
			end
		end
	end
	advance(data.dailyQuests, QuestCatalog.GetDailyTemplate)
	advance(data.weeklyQuests, QuestCatalog.GetWeeklyTemplate)
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

function QuestService:OnLevelUp(player: Player, _level: number)
	self:CheckAchievements(player)
end

function QuestService:OnZoneComplete(player: Player, _zoneId: string)
	self:CheckAchievements(player)
end

-- ── Claims & reroll ──────────────────────────────────────────────────────

function QuestService:ClaimDaily(player: Player, slot: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local q = data.dailyQuests[slot]
	if not q or not q.done or q.claimed then
		return
	end
	local t = QuestCatalog.GetDailyTemplate(q.templateId)
	if not t then
		return
	end
	self:GrantRewards(player, t.rewards)
	q.claimed = true
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

function QuestService:ClaimWeekly(player: Player, slot: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local q = data.weeklyQuests[slot]
	if not q or not q.done or q.claimed then
		return
	end
	local t = QuestCatalog.GetWeeklyTemplate(q.templateId)
	if not t then
		return
	end
	self:GrantRewards(player, t.rewards)
	q.claimed = true
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

function QuestService:GrantRewards(player: Player, rewards: { coins: number?, pearls: number?, bait: string? })
	if rewards.coins then
		self.ctx.Services.EconomyService:AddCoins(player, rewards.coins, "quest")
	end
	if rewards.pearls then
		self.ctx.Services.EconomyService:AddPearls(player, rewards.pearls, "quest")
	end
	if rewards.bait then
		local data = self.ctx.Services.DataService:GetData(player)
		if data then
			data.baits[rewards.bait] = (data.baits[rewards.bait] or 0) + 5
		end
	end
end

function QuestService:RerollQuest(player: Player, slot: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if data.flags.rerollsUsed >= 1 then
		return
	end
	local current = data.dailyQuests[slot]
	if not current then
		return
	end
	local exclude: { [string]: boolean } = {}
	for _, q  in pairs(data.dailyQuests) do
		exclude[q.templateId] = true
	end
	local pool = QuestCatalog.RollTemplates(QuestCatalog.DAILY_POOL, exclude)
	local t = pool[1]
	if not t then
		return
	end
	local params: { [string]: string } = {}
	if t.param == "zone" then
		params.zone = MAIN_ZONES[math.random(1, #MAIN_ZONES)]
	elseif t.param == "family" then
		params.family = FAMILIES[math.random(1, #FAMILIES)]
	end
	data.dailyQuests[slot] = {
		templateId = t.id,
		params = params,
		progress = 0,
		done = false,
		claimed = false,
	}
	data.flags.rerollsUsed = 1
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

-- ── Achievements ─────────────────────────────────────────────────────────

local CONDITIONS: { [string]: (Types.ProfileData) -> boolean } = {
	first_catch = function(d)
		return d.stats.totalCatch >= 1
	end,
	first_shiny = function(d)
		return d.stats.shinyFish >= 1
	end,
	fish_100 = function(d)
		return d.stats.totalCatch >= 100
	end,
	fish_1000 = function(d)
		return d.stats.totalCatch >= 1000
	end,
	coins_10k = function(d)
		return d.stats.totalCoinsEarned >= 10000
	end,
	coins_100k = function(d)
		return d.stats.totalCoinsEarned >= 100000
	end,
	night_owl = function(d)
		return d.stats.nightFish >= 20
	end,
	storm_chaser = function(d)
		return d.stats.stormFish >= 10
	end,
	deep_diver = function(d)
		return d.stats.deepFish >= 50
	end,
	old_one_witness = function(d)
		local e = d.bestiary.old_one
		return e ~= nil and e.caught > 0
	end,
	secret_finder = function(d)
		local e = d.bestiary.mistfin
		return e ~= nil and e.caught > 0
	end,
	grotto_finder = function(d)
		local e = d.bestiary.grotto_glowfin
		return e ~= nil and e.caught > 0
	end,
	level_10 = function(d)
		return d.level >= 10
	end,
	level_25 = function(d)
		return d.level >= 25
	end,
	level_50 = function(d)
		return d.level >= Config.MAX_LEVEL
	end,
	rod_collector = function(d)
		for _, def in pairs(require(ReplicatedStorage.Shared.Data.RodCatalog).GetAll()) do
			if not d.rods[def.id] then
				return false
			end
		end
		return true
	end,
	zone_master = function(d)
		for _, _  in pairs(d.flags.zoneRewards) do
			return true
		end
		return false
	end,
	all_zones = function(d)
		for _, zoneId  in pairs(MAIN_ZONES) do
			if not d.flags.zoneRewards[zoneId] then
				return false
			end
		end
		return true
	end,
	contest_winner = function(d)
		return d.flags.contestWins >= 1
	end,
	pearl_earner = function(d)
		return d.stats.totalPearlsEarned >= 100
	end,
	shiny_10 = function(d)
		return d.stats.shinyFish >= 10
	end,
}

function QuestService:CheckAchievements(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local changed = false
	for _, def  in pairs(QuestCatalog.ACHIEVEMENTS) do
		if data.achievements[def.id] then
			continue
		end
		local cond = CONDITIONS[def.id]
		if cond and cond(data) then
			data.achievements[def.id] = true
			if def.rewards.pearls then
				self.ctx.Services.EconomyService:AddPearls(player, def.rewards.pearls, "achievement:" .. def.id)
			end
			if def.rewards.title then
				data.titles[def.rewards.title] = true
				if not data.equippedTitle then
					data.equippedTitle = def.rewards.title
				end
			end
			Remotes:SendToClient(player, {
				type = "AchievementUnlock",
				payload = { id = def.id, name = def.name, desc = def.desc },
			})
			changed = true
		end
	end
	if changed then
		self.ctx.Services.DataService:MarkDirty(player)
	end
end

-- ── Sync ─────────────────────────────────────────────────────────────────

function QuestService:SendQuestUpdate(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	Remotes:SendToClient(player, {
		type = "QuestUpdate",
		payload = {
			daily = data.dailyQuests,
			weekly = data.weeklyQuests,
			streak = data.streak,
		},
	})
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function QuestService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.ClaimDaily = function(player, payload)
		self:ClaimDaily(player, Util.safeNumber(payload and payload.slot, 1))
	end
	ctx.MessageHandlers.ClaimWeekly = function(player, payload)
		self:ClaimWeekly(player, Util.safeNumber(payload and payload.slot, 1))
	end
	ctx.MessageHandlers.RerollQuest = function(player, payload)
		self:RerollQuest(player, Util.safeNumber(payload and payload.slot, 1))
	end
end

function QuestService:Start()
	self.ctx.Services.DataService:OnProfileReady(function(player, _data)
		self:EnsureRollovers(player)
		self:CheckAchievements(player)
	end)
end

function QuestService:Stop()
end

return QuestService
]==]
	print('[Installer] Wrote ServerScriptService/Services/QuestService')
end

-- ServerScriptService/Services/EventService
local inst = ensure('ServerScriptService/Services/EventService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — EventService
	Shared world clock: day/night cycle + storm scheduler.
	Single source of truth for time-of-day and storm state on this server.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Workspace = game:GetService("Workspace")

local EventService = {}
EventService.Name = "EventService"

local timeOfDay: "day" | "night" = "day"
local isStorm = false
local nextStormAt = 0
local stormEndsAt = 0
local stormWarningSent = false

-- Golden spot state
local goldenActive = false
local goldenX = 0
local goldenZ = 0
local goldenZoneId = ""
local goldenExpiresAt = 0
local nextGoldenAt = 0
local goldenPart: BasePart? = nil

local CYCLE_LENGTH = Config.DAY_LENGTH + Config.NIGHT_LENGTH

function EventService:GetTimeOfDay(): "day" | "night"
	return timeOfDay
end

function EventService:IsStorm(): boolean
	return isStorm
end

function EventService:GetWorldState(): { timeOfDay: string, isStorm: boolean, stormIn: number }
	return {
		timeOfDay = timeOfDay,
		isStorm = isStorm,
		stormIn = math.max(0, nextStormAt - os.clock()),
	}
end

-- ── Golden spots ─────────────────────────────────────────────────────────

function EventService:IsGoldenAt(position: Vector3): boolean
	if not goldenActive then
		return false
	end
	local dx = position.X - goldenX
	local dz = position.Z - goldenZ
	return (dx * dx + dz * dz) <= (Config.GOLDEN_SPOT_RADIUS * Config.GOLDEN_SPOT_RADIUS)
end

function EventService:GetGoldenSpot(): { active: boolean, x: number, z: number, zoneId: string }
	return { active = goldenActive, x = goldenX, z = goldenZ, zoneId = goldenZoneId }
end

function EventService:SpawnGoldenSpot()
	-- Pick a random zone with a region part
	local zones = {}
	for _, child in pairs(Workspace:GetChildren()) do
		if child:IsA("BasePart") and string.sub(child.Name, 1, 11) == "ZoneRegion_" then
			table.insert(zones, child)
		end
	end
	if #zones == 0 then
		nextGoldenAt = os.clock() + Config.GOLDEN_SPOT_INTERVAL_MAX
		return
	end
	local region = zones[math.random(1, #zones)] :: BasePart
	local center = region.CFrame.Position
	local jx = math.random(-80, 80)
	local jz = math.random(-80, 80)
	goldenX = center.X + jx
	goldenZ = center.Z + jz
	goldenZoneId = string.sub(region.Name, 12)
	goldenActive = true
	goldenExpiresAt = os.clock() + Config.GOLDEN_SPOT_DURATION

	-- Visual: shimmering disc
	local disc = Instance.new("Part")
	disc.Name = "GoldenSpot"
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanQuery = false
	disc.CanTouch = false
	disc.Size = Vector3.new(14, 0.3, 14)
	disc.Material = Enum.Material.Neon
	disc.Color = Color3.fromRGB(255, 215, 80)
	disc.Transparency = 0.3
	disc.CFrame = CFrame.new(goldenX, 0.2, goldenZ)
	disc.Parent = Workspace
	local mesh = Instance.new("CylinderMesh")
	mesh.Parent = disc
	local gl = Instance.new("PointLight")
	gl.Color = Color3.fromRGB(255, 220, 110)
	gl.Brightness = 1.4
	gl.Range = 34
	gl.Parent = disc
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Rate = 22
	pe.Lifetime = NumberRange.new(0.8, 1.6)
	pe.Speed = NumberRange.new(0.5, 2)
	pe.Size = NumberSequence.new(0.15, 0.45)
	pe.Transparency = NumberSequence.new(0.1, 1)
	pe.Color = ColorSequence.new(Color3.fromRGB(255, 230, 140))
	pe.Parent = disc
	goldenPart = disc

	Remotes:SendToAll({
		type = "GoldenSpot",
		payload = self:GetGoldenSpot(),
	})
	Remotes:SendToAll({
		type = "EventBanner",
		payload = { kind = "golden", text = "✨ A golden shimmer appears in " .. goldenZoneId .. "! Cast there for luck!" },
	})
end

function EventService:ClearGoldenSpot()
	goldenActive = false
	if goldenPart then
		goldenPart:Destroy()
		goldenPart = nil
	end
	Remotes:SendToAll({
		type = "GoldenSpot",
		payload = self:GetGoldenSpot(),
	})
end

function EventService:BroadcastWorldState()
	Remotes:SendToAll({ type = "WorldState", payload = self:GetWorldState() })
end

function EventService:Init(ctx)
	self.ctx = ctx
end

function EventService:Start()
	local cycleStart = os.clock()
	local lastPhase = "day"
	nextStormAt = os.clock() + math.random(Config.STORM_MIN_DELAY, Config.STORM_MAX_DELAY)
	nextGoldenAt = os.clock() + math.random(Config.GOLDEN_SPOT_INTERVAL_MIN, Config.GOLDEN_SPOT_INTERVAL_MAX)

	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.clock()

			-- Golden spots
			if goldenActive then
				if now >= goldenExpiresAt then
					self:ClearGoldenSpot()
				end
			elseif now >= nextGoldenAt then
				self:SpawnGoldenSpot()
			end

			-- Day / night
			local phase: "day" | "night" = "day"
			if (now - cycleStart) % CYCLE_LENGTH >= Config.DAY_LENGTH then
				phase = "night"
			end
			if phase ~= lastPhase then
				lastPhase = phase
				timeOfDay = phase
				if phase == "night" then
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "night", text = "The sun sets. Night fish are surfacing..." },
					})
				else
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "day", text = "Dawn breaks over the water." },
					})
				end
				self:BroadcastWorldState()
			end

			-- Storm scheduling
			if not isStorm then
				if not stormWarningSent and now >= nextStormAt - Config.STORM_WARNING then
					stormWarningSent = true
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "stormWarning", text = "A storm is brewing... strange fish are coming." },
					})
				end
				if now >= nextStormAt then
					isStorm = true
					stormEndsAt = now + Config.STORM_DURATION
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "storm", text = "THE STORM HAS ARRIVED! Storm fish are surfacing everywhere. +50% XP!" },
					})
					self:BroadcastWorldState()
				end
			else
				if now >= stormEndsAt then
					isStorm = false
					stormWarningSent = false
					nextStormAt = now + math.random(Config.STORM_MIN_DELAY, Config.STORM_MAX_DELAY)
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "stormEnd", text = "The storm passes. The sea returns to its secrets." },
					})
					self:BroadcastWorldState()
				end
			end
		end
	end)
end

function EventService:Stop()
end

return EventService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — EventService
	Shared world clock: day/night cycle + storm scheduler.
	Single source of truth for time-of-day and storm state on this server.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Workspace = game:GetService("Workspace")

local EventService = {}
EventService.Name = "EventService"

local timeOfDay: "day" | "night" = "day"
local isStorm = false
local nextStormAt = 0
local stormEndsAt = 0
local stormWarningSent = false

-- Golden spot state
local goldenActive = false
local goldenX = 0
local goldenZ = 0
local goldenZoneId = ""
local goldenExpiresAt = 0
local nextGoldenAt = 0
local goldenPart: BasePart? = nil

local CYCLE_LENGTH = Config.DAY_LENGTH + Config.NIGHT_LENGTH

function EventService:GetTimeOfDay(): "day" | "night"
	return timeOfDay
end

function EventService:IsStorm(): boolean
	return isStorm
end

function EventService:GetWorldState(): { timeOfDay: string, isStorm: boolean, stormIn: number }
	return {
		timeOfDay = timeOfDay,
		isStorm = isStorm,
		stormIn = math.max(0, nextStormAt - os.clock()),
	}
end

-- ── Golden spots ─────────────────────────────────────────────────────────

function EventService:IsGoldenAt(position: Vector3): boolean
	if not goldenActive then
		return false
	end
	local dx = position.X - goldenX
	local dz = position.Z - goldenZ
	return (dx * dx + dz * dz) <= (Config.GOLDEN_SPOT_RADIUS * Config.GOLDEN_SPOT_RADIUS)
end

function EventService:GetGoldenSpot(): { active: boolean, x: number, z: number, zoneId: string }
	return { active = goldenActive, x = goldenX, z = goldenZ, zoneId = goldenZoneId }
end

function EventService:SpawnGoldenSpot()
	-- Pick a random zone with a region part
	local zones = {}
	for _, child in pairs(Workspace:GetChildren()) do
		if child:IsA("BasePart") and string.sub(child.Name, 1, 11) == "ZoneRegion_" then
			table.insert(zones, child)
		end
	end
	if #zones == 0 then
		nextGoldenAt = os.clock() + Config.GOLDEN_SPOT_INTERVAL_MAX
		return
	end
	local region = zones[math.random(1, #zones)] :: BasePart
	local center = region.CFrame.Position
	local jx = math.random(-80, 80)
	local jz = math.random(-80, 80)
	goldenX = center.X + jx
	goldenZ = center.Z + jz
	goldenZoneId = string.sub(region.Name, 12)
	goldenActive = true
	goldenExpiresAt = os.clock() + Config.GOLDEN_SPOT_DURATION

	-- Visual: shimmering disc
	local disc = Instance.new("Part")
	disc.Name = "GoldenSpot"
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanQuery = false
	disc.CanTouch = false
	disc.Size = Vector3.new(14, 0.3, 14)
	disc.Material = Enum.Material.Neon
	disc.Color = Color3.fromRGB(255, 215, 80)
	disc.Transparency = 0.3
	disc.CFrame = CFrame.new(goldenX, 0.2, goldenZ)
	disc.Parent = Workspace
	local mesh = Instance.new("CylinderMesh")
	mesh.Parent = disc
	local gl = Instance.new("PointLight")
	gl.Color = Color3.fromRGB(255, 220, 110)
	gl.Brightness = 1.4
	gl.Range = 34
	gl.Parent = disc
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Rate = 22
	pe.Lifetime = NumberRange.new(0.8, 1.6)
	pe.Speed = NumberRange.new(0.5, 2)
	pe.Size = NumberSequence.new(0.15, 0.45)
	pe.Transparency = NumberSequence.new(0.1, 1)
	pe.Color = ColorSequence.new(Color3.fromRGB(255, 230, 140))
	pe.Parent = disc
	goldenPart = disc

	Remotes:SendToAll({
		type = "GoldenSpot",
		payload = self:GetGoldenSpot(),
	})
	Remotes:SendToAll({
		type = "EventBanner",
		payload = { kind = "golden", text = "✨ A golden shimmer appears in " .. goldenZoneId .. "! Cast there for luck!" },
	})
end

function EventService:ClearGoldenSpot()
	goldenActive = false
	if goldenPart then
		goldenPart:Destroy()
		goldenPart = nil
	end
	Remotes:SendToAll({
		type = "GoldenSpot",
		payload = self:GetGoldenSpot(),
	})
end

function EventService:BroadcastWorldState()
	Remotes:SendToAll({ type = "WorldState", payload = self:GetWorldState() })
end

function EventService:Init(ctx)
	self.ctx = ctx
end

function EventService:Start()
	local cycleStart = os.clock()
	local lastPhase = "day"
	nextStormAt = os.clock() + math.random(Config.STORM_MIN_DELAY, Config.STORM_MAX_DELAY)
	nextGoldenAt = os.clock() + math.random(Config.GOLDEN_SPOT_INTERVAL_MIN, Config.GOLDEN_SPOT_INTERVAL_MAX)

	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.clock()

			-- Golden spots
			if goldenActive then
				if now >= goldenExpiresAt then
					self:ClearGoldenSpot()
				end
			elseif now >= nextGoldenAt then
				self:SpawnGoldenSpot()
			end

			-- Day / night
			local phase: "day" | "night" = "day"
			if (now - cycleStart) % CYCLE_LENGTH >= Config.DAY_LENGTH then
				phase = "night"
			end
			if phase ~= lastPhase then
				lastPhase = phase
				timeOfDay = phase
				if phase == "night" then
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "night", text = "The sun sets. Night fish are surfacing..." },
					})
				else
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "day", text = "Dawn breaks over the water." },
					})
				end
				self:BroadcastWorldState()
			end

			-- Storm scheduling
			if not isStorm then
				if not stormWarningSent and now >= nextStormAt - Config.STORM_WARNING then
					stormWarningSent = true
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "stormWarning", text = "A storm is brewing... strange fish are coming." },
					})
				end
				if now >= nextStormAt then
					isStorm = true
					stormEndsAt = now + Config.STORM_DURATION
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "storm", text = "THE STORM HAS ARRIVED! Storm fish are surfacing everywhere. +50% XP!" },
					})
					self:BroadcastWorldState()
				end
			else
				if now >= stormEndsAt then
					isStorm = false
					stormWarningSent = false
					nextStormAt = now + math.random(Config.STORM_MIN_DELAY, Config.STORM_MAX_DELAY)
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "stormEnd", text = "The storm passes. The sea returns to its secrets." },
					})
					self:BroadcastWorldState()
				end
			end
		end
	end)
end

function EventService:Stop()
end

return EventService
]==]
	print('[Installer] Wrote ServerScriptService/Services/EventService')
end

-- ServerScriptService/Services/LeaderboardService
local inst = ensure('ServerScriptService/Services/LeaderboardService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — LeaderboardService
	leaderstats (Level / Coins / Bestiary) + weekly catch contest.
	Contest: auto-tracked best catch per week, top 10 rewarded at rollover.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local LeaderboardService = {}
LeaderboardService.Name = "LeaderboardService"

local contestStore = DataStoreService:GetOrderedDataStore("TD_Contest")
local lastFinalizedWeek = ""
local statsValues: { [number]: { level: number, coins: number, bestiary: number } } = {}

-- ── leaderstats ──────────────────────────────────────────────────────────

function LeaderboardService:SetupLeaderstats(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	local function ensure(name: string, value: number)
		local v = leaderstats:FindFirstChild(name)
		if not v then
			v = Instance.new("IntValue")
			v.Name = name
			v.Parent = leaderstats
		end
		v.Value = value
	end
	ensure("Level", 1)
	ensure("Coins", 0)
	ensure("Bestiary", 0)
	statsValues[player.UserId] = { level = 1, coins = 0, bestiary = 0 }
end

function LeaderboardService:UpdateLeaderstats(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local stats = statsValues[player.UserId]
	if not stats then
		return
	end
	if stats.level ~= data.level then
		stats.level = data.level
	end
	if stats.coins ~= data.coins then
		stats.coins = data.coins
	end
	local pct = self.ctx.Services.InventoryService:GetGlobalCompletion(data)
	if stats.bestiary ~= pct then
		stats.bestiary = pct
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local lv = leaderstats:FindFirstChild("Level")
		local cv = leaderstats:FindFirstChild("Coins")
		local bv = leaderstats:FindFirstChild("Bestiary")
		if lv then
			lv.Value = stats.level
		end
		if cv then
			cv.Value = stats.coins
		end
		if bv then
			bv.Value = stats.bestiary
		end
	end
end

-- ── Weekly contest ───────────────────────────────────────────────────────

function LeaderboardService:SubmitCatch(player: Player, weight: number, fishId: string, rarity: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local week = Util.weekKey()
	local idx = Config.RARITY_INDEX[rarity] or 1
	local score = math.floor(weight * (Config.CONTEST_MULTIPLIER_BASE + idx))
	local best = data.stats.bestCatch
	if best.weekKey ~= week or score > (best.weight * (Config.CONTEST_MULTIPLIER_BASE + (Config.RARITY_INDEX[best.rarity] or 1))) then
		data.stats.bestCatch = {
			weight = weight,
			fishId = fishId,
			rarity = rarity,
			weekKey = week,
		}
		self.ctx.Services.DataService:MarkDirty(player)
		local ok, err = pcall(function()
			contestStore:SetAsync(tostring(player.UserId), score)
		end)
		if not ok then
			warn("[Leaderboard] contest SetAsync failed: " .. tostring(err))
		end
	end
end

function LeaderboardService:FinalizeWeek(week: string)
	local ok, pages = pcall(function()
		return contestStore:GetSortedAsync(false, 100)
	end)
	if not ok then
		warn("[Leaderboard] contest read failed")
		return
	end
	local results = {}
	local ok2, err2 = pcall(function()
		results = pages:GetCurrentPage()
	end)
	if not ok2 then
		warn("[Leaderboard] contest page failed: " .. tostring(err2))
		return
	end
	local winners: { string } = {}
	for i, entry in ipairs(results) do
		if i > 10 then
			break
		end
		local userId = tonumber(entry.key)
		local player = userId and Players:GetPlayerByUserId(userId)
		if player then
			local pearls = Config.CONTEST_REWARDS[i]
			if pearls then
				self.ctx.Services.EconomyService:AddPearls(player, pearls, "contest")
			end
			table.insert(winners, player.Name)
			if i == 1 then
				local data = self.ctx.Services.DataService:GetData(player)
				if data then
					data.flags.contestWins += 1
					data.titles["Weekly Champion"] = true
					if not data.equippedTitle then
						data.equippedTitle = "Weekly Champion"
					end
					self.ctx.Services.DataService:MarkDirty(player)
					self.ctx.Services.QuestService:CheckAchievements(player)
				end
			end
		end
	end
	if #winners > 0 then
		Remotes:SendToAll({
			type = "FeedMessage",
			payload = { kind = "announce", text = "🏆 Weekly catch contest winners: " .. table.concat(winners, ", ") .. "! See you next week." },
		})
	end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function LeaderboardService:SendContestTop(player: Player)
	local ok, pages = pcall(function()
		return contestStore:GetSortedAsync(false, 10)
	end)
	if not ok then
		return
	end
	local results = {}
	local ok2, err2 = pcall(function()
		results = pages:GetCurrentPage()
	end)
	if not ok2 then
		warn("[Leaderboard] contest page failed: " .. tostring(err2))
		return
	end
	local entries: { { name: string, score: number } } = {}
	for i, entry in ipairs(results) do
		if i > 10 then
			break
		end
		local userId = tonumber(entry.key)
		local name = "Player " .. tostring(entry.key)
		if userId then
			local okN, nm = pcall(function()
				return Players:GetNameByUserIdAsync(userId)
			end)
			if okN and typeof(nm) == "string" then
				name = nm
			end
		end
		table.insert(entries, { name = name, score = entry.value })
	end
	Remotes:SendToClient(player, {
		type = "ContestTop",
		payload = { week = Util.weekKey(), entries = entries },
	})
end

function LeaderboardService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.GetContestTop = function(player, _payload)
		self:SendContestTop(player)
	end
end

function LeaderboardService:Start()
	self.ctx.Services.DataService:OnProfileReady(function(player, _data)
		self:SetupLeaderstats(player)
	end)

	lastFinalizedWeek = Util.weekKey()

	-- Periodic updates + week rollover check
	task.spawn(function()
		while true do
			task.wait(5)
			for _, player  in pairs(Players:GetPlayers()) do
				self:UpdateLeaderstats(player)
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(60)
			local week = Util.weekKey()
			if week ~= lastFinalizedWeek then
				self:FinalizeWeek(lastFinalizedWeek)
				lastFinalizedWeek = week
			end
		end
	end)
end

function LeaderboardService:Stop()
end

return LeaderboardService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — LeaderboardService
	leaderstats (Level / Coins / Bestiary) + weekly catch contest.
	Contest: auto-tracked best catch per week, top 10 rewarded at rollover.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local LeaderboardService = {}
LeaderboardService.Name = "LeaderboardService"

local contestStore = DataStoreService:GetOrderedDataStore("TD_Contest")
local lastFinalizedWeek = ""
local statsValues: { [number]: { level: number, coins: number, bestiary: number } } = {}

-- ── leaderstats ──────────────────────────────────────────────────────────

function LeaderboardService:SetupLeaderstats(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	local function ensure(name: string, value: number)
		local v = leaderstats:FindFirstChild(name)
		if not v then
			v = Instance.new("IntValue")
			v.Name = name
			v.Parent = leaderstats
		end
		v.Value = value
	end
	ensure("Level", 1)
	ensure("Coins", 0)
	ensure("Bestiary", 0)
	statsValues[player.UserId] = { level = 1, coins = 0, bestiary = 0 }
end

function LeaderboardService:UpdateLeaderstats(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local stats = statsValues[player.UserId]
	if not stats then
		return
	end
	if stats.level ~= data.level then
		stats.level = data.level
	end
	if stats.coins ~= data.coins then
		stats.coins = data.coins
	end
	local pct = self.ctx.Services.InventoryService:GetGlobalCompletion(data)
	if stats.bestiary ~= pct then
		stats.bestiary = pct
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local lv = leaderstats:FindFirstChild("Level")
		local cv = leaderstats:FindFirstChild("Coins")
		local bv = leaderstats:FindFirstChild("Bestiary")
		if lv then
			lv.Value = stats.level
		end
		if cv then
			cv.Value = stats.coins
		end
		if bv then
			bv.Value = stats.bestiary
		end
	end
end

-- ── Weekly contest ───────────────────────────────────────────────────────

function LeaderboardService:SubmitCatch(player: Player, weight: number, fishId: string, rarity: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local week = Util.weekKey()
	local idx = Config.RARITY_INDEX[rarity] or 1
	local score = math.floor(weight * (Config.CONTEST_MULTIPLIER_BASE + idx))
	local best = data.stats.bestCatch
	if best.weekKey ~= week or score > (best.weight * (Config.CONTEST_MULTIPLIER_BASE + (Config.RARITY_INDEX[best.rarity] or 1))) then
		data.stats.bestCatch = {
			weight = weight,
			fishId = fishId,
			rarity = rarity,
			weekKey = week,
		}
		self.ctx.Services.DataService:MarkDirty(player)
		local ok, err = pcall(function()
			contestStore:SetAsync(tostring(player.UserId), score)
		end)
		if not ok then
			warn("[Leaderboard] contest SetAsync failed: " .. tostring(err))
		end
	end
end

function LeaderboardService:FinalizeWeek(week: string)
	local ok, pages = pcall(function()
		return contestStore:GetSortedAsync(false, 100)
	end)
	if not ok then
		warn("[Leaderboard] contest read failed")
		return
	end
	local results = {}
	local ok2, err2 = pcall(function()
		results = pages:GetCurrentPage()
	end)
	if not ok2 then
		warn("[Leaderboard] contest page failed: " .. tostring(err2))
		return
	end
	local winners: { string } = {}
	for i, entry in ipairs(results) do
		if i > 10 then
			break
		end
		local userId = tonumber(entry.key)
		local player = userId and Players:GetPlayerByUserId(userId)
		if player then
			local pearls = Config.CONTEST_REWARDS[i]
			if pearls then
				self.ctx.Services.EconomyService:AddPearls(player, pearls, "contest")
			end
			table.insert(winners, player.Name)
			if i == 1 then
				local data = self.ctx.Services.DataService:GetData(player)
				if data then
					data.flags.contestWins += 1
					data.titles["Weekly Champion"] = true
					if not data.equippedTitle then
						data.equippedTitle = "Weekly Champion"
					end
					self.ctx.Services.DataService:MarkDirty(player)
					self.ctx.Services.QuestService:CheckAchievements(player)
				end
			end
		end
	end
	if #winners > 0 then
		Remotes:SendToAll({
			type = "FeedMessage",
			payload = { kind = "announce", text = "🏆 Weekly catch contest winners: " .. table.concat(winners, ", ") .. "! See you next week." },
		})
	end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function LeaderboardService:SendContestTop(player: Player)
	local ok, pages = pcall(function()
		return contestStore:GetSortedAsync(false, 10)
	end)
	if not ok then
		return
	end
	local results = {}
	local ok2, err2 = pcall(function()
		results = pages:GetCurrentPage()
	end)
	if not ok2 then
		warn("[Leaderboard] contest page failed: " .. tostring(err2))
		return
	end
	local entries: { { name: string, score: number } } = {}
	for i, entry in ipairs(results) do
		if i > 10 then
			break
		end
		local userId = tonumber(entry.key)
		local name = "Player " .. tostring(entry.key)
		if userId then
			local okN, nm = pcall(function()
				return Players:GetNameByUserIdAsync(userId)
			end)
			if okN and typeof(nm) == "string" then
				name = nm
			end
		end
		table.insert(entries, { name = name, score = entry.value })
	end
	Remotes:SendToClient(player, {
		type = "ContestTop",
		payload = { week = Util.weekKey(), entries = entries },
	})
end

function LeaderboardService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.GetContestTop = function(player, _payload)
		self:SendContestTop(player)
	end
end

function LeaderboardService:Start()
	self.ctx.Services.DataService:OnProfileReady(function(player, _data)
		self:SetupLeaderstats(player)
	end)

	lastFinalizedWeek = Util.weekKey()

	-- Periodic updates + week rollover check
	task.spawn(function()
		while true do
			task.wait(5)
			for _, player  in pairs(Players:GetPlayers()) do
				self:UpdateLeaderstats(player)
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(60)
			local week = Util.weekKey()
			if week ~= lastFinalizedWeek then
				self:FinalizeWeek(lastFinalizedWeek)
				lastFinalizedWeek = week
			end
		end
	end)
end

function LeaderboardService:Stop()
end

return LeaderboardService
]==]
	print('[Installer] Wrote ServerScriptService/Services/LeaderboardService')
end

-- ServerScriptService/Services/ShopService
local inst = ensure('ServerScriptService/Services/ShopService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — ShopService
	Monetization: gamepasses, developer products, coin/pearl purchases.
	- ProcessReceipt with idempotency (receipt cache per player)
	- Pass ownership checked on join (UserOwnsGamePassAsync)
	- All purchases funnel through EconomyService (single choke point)
	Phase 3/7 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local CosmeticsCatalog = require(ReplicatedStorage.Shared.Data.CosmeticsCatalog)

local ShopService = {}
ShopService.Name = "ShopService"

-- Receipts that arrived before the profile was loaded: applied on load
local pendingReceipts: { [number]: { any } } = {}

-- ── Pass / product grants ────────────────────────────────────────────────

function ShopService:GrantGamepass(player: Player, passKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	data.flags.ownedPasses[passKey] = true
	if passKey == "starter_pack" and not data.flags.starterClaimed then
		data.flags.starterClaimed = true
		self.ctx.Services.EconomyService:AddCoins(player, Config.STARTER_PACK.coins, "starter_pack")
		data.baits.golden = (data.baits.golden or 0) + Config.STARTER_PACK.golden
	end
	self.ctx.Services.DataService:MarkDirty(player)
	Remotes:SendToClient(player, { type = "PassGranted", payload = { passId = passKey } })
	warn("[Shop] Gamepass granted: " .. player.Name .. " | " .. passKey)
end

function ShopService:GrantProduct(player: Player, productKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local economy = self.ctx.Services.EconomyService
	for _, pack  in pairs(Config.PEARL_PACKS) do
		if pack.id == productKey then
			economy:AddPearls(player, pack.pearls, "purchase:" .. productKey)
			Remotes:SendToClient(player, { type = "ProductGranted", payload = { productId = productKey } })
			return
		end
	end
	if productKey == "auto_reel_tokens" then
		data.flags.tokens = math.min(9999, data.flags.tokens + Config.AUTO_REEL_TOKEN_PACK)
		self.ctx.Services.DataService:MarkDirty(player)
		Remotes:SendToClient(player, { type = "ProductGranted", payload = { productId = productKey } })
	elseif productKey == "xp_boost_2h" then
		data.flags.xpBoostUntil = math.max(data.flags.xpBoostUntil, os.time() + Config.XP_BOOST_DURATION)
		self.ctx.Services.DataService:MarkDirty(player)
		Remotes:SendToClient(player, { type = "ProductGranted", payload = { productId = productKey } })
	end
end

function ShopService:HandleReceipt(receiptInfo: any): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	local profile = player and self.ctx.Services.DataService:GetProfile(player)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if not profile then
		-- Profile not loaded yet: queue and apply on load
		local queue = pendingReceipts[receiptInfo.PlayerId] or {}
		table.insert(queue, receiptInfo)
		pendingReceipts[receiptInfo.PlayerId] = queue
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local data = profile.data

	-- Idempotency: never grant the same purchase twice
	local receiptKey = tostring(receiptInfo.PurchaseId)
	if data.flags.receipts[receiptKey] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	data.flags.receipts[receiptKey] = true
	self.ctx.Services.DataService:MarkDirty(player)

	if receiptInfo.PurchaseType == Enum.PurchaseType.GamePass then
		local passKey: string? = nil
		for key, id  in pairs(Config.GAMEPASS_IDS) do
			if id == receiptInfo.PurchaseId then
				passKey = key
				break
			end
		end
		if passKey then
			self:GrantGamepass(player, passKey)
		end
	elseif receiptInfo.PurchaseType == Enum.PurchaseType.Product then
		local productKey: string? = nil
		for key, id  in pairs(Config.PRODUCT_IDS) do
			if id == receiptInfo.PurchaseId then
				productKey = key
				break
			end
		end
		if productKey then
			self:GrantProduct(player, productKey)
		end
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Check pass ownership at join (covers out-of-game purchases)
function ShopService:CheckPassOwnership(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	task.spawn(function()
		for key, passId  in pairs(Config.GAMEPASS_IDS) do
			if passId <= 0 then
				continue
			end
			local ok, owned = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
			end)
			if ok and owned and not data.flags.ownedPasses[key] then
				self:GrantGamepass(player, key)
			end
		end
	end)
end

-- ── Coin / pearl purchases (message-driven) ──────────────────────────────

function ShopService:BuyRod(player: Player, rodId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(rodId) ~= "string" then
		return
	end
	local def = RodCatalog.Get(rodId)
	if not def then
		self.ctx.Services.SecurityService:Flag(player, "buy unknown rod")
		return
	end
	if data.rods[rodId] then
		return
	end
	if data.level < def.unlockLevel then
		return
	end
	if not self.ctx.Services.EconomyService:SpendCoins(player, def.cost, "rod:" .. rodId) then
		return
	end
	data.rods[rodId] = true
	data.equippedRod = rodId
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.EconomyService:Sync(player)
	local fishing = self.ctx.Services.FishingService
	if fishing and fishing.UpdateRodColor then
		fishing:UpdateRodColor(player)
	end
	local world = self.ctx.Services.WorldInteractionsService
	if world and world.OnFirstBuy then
		world:OnFirstBuy(player)
	end
end

function ShopService:EquipRod(player: Player, rodId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(rodId) ~= "string" then
		return
	end
	if data.rods[rodId] and RodCatalog.Get(rodId) then
		data.equippedRod = rodId
		self.ctx.Services.DataService:MarkDirty(player)
		self.ctx.Services.EconomyService:Sync(player)
	end
end

function ShopService:BuyBait(player: Player, baitId: any, count: any)
	local data = self.ctx.Services.DataService:GetData(player)
	local baitDef = typeof(baitId) == "string" and Config.BAITS[baitId]
	if not data or not baitDef then
		return
	end
	count = math.clamp(math.floor(Util.safeNumber(count, 1)), 1, 10)
	local cost = baitDef.cost * count
	if not self.ctx.Services.EconomyService:SpendCoins(player, cost, "bait:" .. baitId) then
		return
	end
	data.baits[baitId] = (data.baits[baitId] or 0) + count
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.EconomyService:Sync(player)
end

function ShopService:EquipBait(player: Player, baitId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if baitId == nil then
		data.flags.equippedBait = nil
	elseif typeof(baitId) == "string" and Config.BAITS[baitId] then
		local count = data.baits[baitId] or 0
		if count <= 0 and not (baitId == "golden" and data.flags.ownedPasses.golden_lure_pass) then
			return
		end
		data.flags.equippedBait = baitId
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.EconomyService:Sync(player)
end

function ShopService:BuyUpgrade(player: Player, tier: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(tier) ~= "number" then
		return
	end
	tier = math.floor(tier)
	if tier < 1 or tier > #Config.INVENTORY_UPGRADES then
		return
	end
	if data.flags.invUpgradeTier + 1 ~= tier then
		return -- must buy in order
	end
	local def = Config.INVENTORY_UPGRADES[tier]
	if not self.ctx.Services.EconomyService:SpendCoins(player, def.cost, "storage:" .. tier) then
		return
	end
	data.flags.invUpgradeTier = tier
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.InventoryService:SendInventory(player)
end

-- ── Cosmetics & titles ───────────────────────────────────────────────────

function ShopService:BuyCosmetic(player: Player, cosmeticId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(cosmeticId) ~= "string" then
		return
	end
	local def = CosmeticsCatalog.Get(cosmeticId)
	if not def or def.price <= 0 then
		return
	end
	if data.flags.cosmeticsOwned[cosmeticId] then
		return -- already owned
	end
	if not self.ctx.Services.EconomyService:SpendPearls(player, def.price, "cosmetic:" .. cosmeticId) then
		return
	end
	data.flags.cosmeticsOwned[cosmeticId] = true
	-- Buying a cosmetic equips it immediately (satisfying + clear)
	data.cosmetics[def.kind] = def.id
	if def.kind == "rodSkin" then
		local fishing = self.ctx.Services.FishingService
		if fishing and fishing.UpdateRodColor then
			fishing:UpdateRodColor(player)
		end
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.InventoryService:SendInventory(player)
end

function ShopService:EquipCosmetic(player: Player, cosmeticId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(cosmeticId) ~= "string" then
		return
	end
	local def = CosmeticsCatalog.Get(cosmeticId)
	if not def then
		return
	end
	if not data.flags.cosmeticsOwned[cosmeticId] and def.price > 0 then
		return -- must own it first
	end
	data.cosmetics[def.kind] = def.id
	if def.kind == "rodSkin" then
		local fishing = self.ctx.Services.FishingService
		if fishing and fishing.UpdateRodColor then
			fishing:UpdateRodColor(player)
		end
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.InventoryService:SendInventory(player)
end

function ShopService:EquipTitle(player: Player, title: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(title) ~= "string" then
		return
	end
	if data.titles[title] then
		data.equippedTitle = title
		self.ctx.Services.DataService:MarkDirty(player)
		self.ctx.Services.InventoryService:SendInventory(player)
	end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function ShopService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.BuyRod = function(player, payload)
		self:BuyRod(player, payload and payload.rodId)
	end
	ctx.MessageHandlers.EquipRod = function(player, payload)
		self:EquipRod(player, payload and payload.rodId)
	end
	ctx.MessageHandlers.BuyBait = function(player, payload)
		self:BuyBait(player, payload and payload.baitId, payload and payload.count)
	end
	ctx.MessageHandlers.EquipBait = function(player, payload)
		self:EquipBait(player, payload and payload.baitId)
	end
	ctx.MessageHandlers.BuyUpgrade = function(player, payload)
		self:BuyUpgrade(player, payload and payload.tier)
	end
	ctx.MessageHandlers.BuyCosmetic = function(player, payload)
		self:BuyCosmetic(player, payload and payload.cosmeticId)
	end
	ctx.MessageHandlers.EquipCosmetic = function(player, payload)
		self:EquipCosmetic(player, payload and payload.cosmeticId)
	end
	ctx.MessageHandlers.EquipTitle = function(player, payload)
		self:EquipTitle(player, payload and payload.title)
	end
end

function ShopService:Start()
	MarketplaceService.ProcessReceipt:Connect(function(receiptInfo)
		return self:HandleReceipt(receiptInfo)
	end)

	self.ctx.Services.DataService:OnProfileReady(function(player, _data)
		-- Apply receipts that arrived before the profile loaded
		local queue = pendingReceipts[player.UserId]
		if queue then
			pendingReceipts[player.UserId] = nil
			for _, receiptInfo  in pairs(queue) do
				self:HandleReceipt(receiptInfo)
			end
		end
		self:CheckPassOwnership(player)
	end)
end

function ShopService:Stop()
end

return ShopService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — ShopService
	Monetization: gamepasses, developer products, coin/pearl purchases.
	- ProcessReceipt with idempotency (receipt cache per player)
	- Pass ownership checked on join (UserOwnsGamePassAsync)
	- All purchases funnel through EconomyService (single choke point)
	Phase 3/7 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local CosmeticsCatalog = require(ReplicatedStorage.Shared.Data.CosmeticsCatalog)

local ShopService = {}
ShopService.Name = "ShopService"

-- Receipts that arrived before the profile was loaded: applied on load
local pendingReceipts: { [number]: { any } } = {}

-- ── Pass / product grants ────────────────────────────────────────────────

function ShopService:GrantGamepass(player: Player, passKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	data.flags.ownedPasses[passKey] = true
	if passKey == "starter_pack" and not data.flags.starterClaimed then
		data.flags.starterClaimed = true
		self.ctx.Services.EconomyService:AddCoins(player, Config.STARTER_PACK.coins, "starter_pack")
		data.baits.golden = (data.baits.golden or 0) + Config.STARTER_PACK.golden
	end
	self.ctx.Services.DataService:MarkDirty(player)
	Remotes:SendToClient(player, { type = "PassGranted", payload = { passId = passKey } })
	warn("[Shop] Gamepass granted: " .. player.Name .. " | " .. passKey)
end

function ShopService:GrantProduct(player: Player, productKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local economy = self.ctx.Services.EconomyService
	for _, pack  in pairs(Config.PEARL_PACKS) do
		if pack.id == productKey then
			economy:AddPearls(player, pack.pearls, "purchase:" .. productKey)
			Remotes:SendToClient(player, { type = "ProductGranted", payload = { productId = productKey } })
			return
		end
	end
	if productKey == "auto_reel_tokens" then
		data.flags.tokens = math.min(9999, data.flags.tokens + Config.AUTO_REEL_TOKEN_PACK)
		self.ctx.Services.DataService:MarkDirty(player)
		Remotes:SendToClient(player, { type = "ProductGranted", payload = { productId = productKey } })
	elseif productKey == "xp_boost_2h" then
		data.flags.xpBoostUntil = math.max(data.flags.xpBoostUntil, os.time() + Config.XP_BOOST_DURATION)
		self.ctx.Services.DataService:MarkDirty(player)
		Remotes:SendToClient(player, { type = "ProductGranted", payload = { productId = productKey } })
	end
end

function ShopService:HandleReceipt(receiptInfo: any): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	local profile = player and self.ctx.Services.DataService:GetProfile(player)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if not profile then
		-- Profile not loaded yet: queue and apply on load
		local queue = pendingReceipts[receiptInfo.PlayerId] or {}
		table.insert(queue, receiptInfo)
		pendingReceipts[receiptInfo.PlayerId] = queue
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local data = profile.data

	-- Idempotency: never grant the same purchase twice
	local receiptKey = tostring(receiptInfo.PurchaseId)
	if data.flags.receipts[receiptKey] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	data.flags.receipts[receiptKey] = true
	self.ctx.Services.DataService:MarkDirty(player)

	if receiptInfo.PurchaseType == Enum.PurchaseType.GamePass then
		local passKey: string? = nil
		for key, id  in pairs(Config.GAMEPASS_IDS) do
			if id == receiptInfo.PurchaseId then
				passKey = key
				break
			end
		end
		if passKey then
			self:GrantGamepass(player, passKey)
		end
	elseif receiptInfo.PurchaseType == Enum.PurchaseType.Product then
		local productKey: string? = nil
		for key, id  in pairs(Config.PRODUCT_IDS) do
			if id == receiptInfo.PurchaseId then
				productKey = key
				break
			end
		end
		if productKey then
			self:GrantProduct(player, productKey)
		end
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Check pass ownership at join (covers out-of-game purchases)
function ShopService:CheckPassOwnership(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	task.spawn(function()
		for key, passId  in pairs(Config.GAMEPASS_IDS) do
			if passId <= 0 then
				continue
			end
			local ok, owned = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
			end)
			if ok and owned and not data.flags.ownedPasses[key] then
				self:GrantGamepass(player, key)
			end
		end
	end)
end

-- ── Coin / pearl purchases (message-driven) ──────────────────────────────

function ShopService:BuyRod(player: Player, rodId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(rodId) ~= "string" then
		return
	end
	local def = RodCatalog.Get(rodId)
	if not def then
		self.ctx.Services.SecurityService:Flag(player, "buy unknown rod")
		return
	end
	if data.rods[rodId] then
		return
	end
	if data.level < def.unlockLevel then
		return
	end
	if not self.ctx.Services.EconomyService:SpendCoins(player, def.cost, "rod:" .. rodId) then
		return
	end
	data.rods[rodId] = true
	data.equippedRod = rodId
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.EconomyService:Sync(player)
	local fishing = self.ctx.Services.FishingService
	if fishing and fishing.UpdateRodColor then
		fishing:UpdateRodColor(player)
	end
	local world = self.ctx.Services.WorldInteractionsService
	if world and world.OnFirstBuy then
		world:OnFirstBuy(player)
	end
end

function ShopService:EquipRod(player: Player, rodId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(rodId) ~= "string" then
		return
	end
	if data.rods[rodId] and RodCatalog.Get(rodId) then
		data.equippedRod = rodId
		self.ctx.Services.DataService:MarkDirty(player)
		self.ctx.Services.EconomyService:Sync(player)
	end
end

function ShopService:BuyBait(player: Player, baitId: any, count: any)
	local data = self.ctx.Services.DataService:GetData(player)
	local baitDef = typeof(baitId) == "string" and Config.BAITS[baitId]
	if not data or not baitDef then
		return
	end
	count = math.clamp(math.floor(Util.safeNumber(count, 1)), 1, 10)
	local cost = baitDef.cost * count
	if not self.ctx.Services.EconomyService:SpendCoins(player, cost, "bait:" .. baitId) then
		return
	end
	data.baits[baitId] = (data.baits[baitId] or 0) + count
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.EconomyService:Sync(player)
end

function ShopService:EquipBait(player: Player, baitId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if baitId == nil then
		data.flags.equippedBait = nil
	elseif typeof(baitId) == "string" and Config.BAITS[baitId] then
		local count = data.baits[baitId] or 0
		if count <= 0 and not (baitId == "golden" and data.flags.ownedPasses.golden_lure_pass) then
			return
		end
		data.flags.equippedBait = baitId
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.EconomyService:Sync(player)
end

function ShopService:BuyUpgrade(player: Player, tier: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(tier) ~= "number" then
		return
	end
	tier = math.floor(tier)
	if tier < 1 or tier > #Config.INVENTORY_UPGRADES then
		return
	end
	if data.flags.invUpgradeTier + 1 ~= tier then
		return -- must buy in order
	end
	local def = Config.INVENTORY_UPGRADES[tier]
	if not self.ctx.Services.EconomyService:SpendCoins(player, def.cost, "storage:" .. tier) then
		return
	end
	data.flags.invUpgradeTier = tier
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.InventoryService:SendInventory(player)
end

-- ── Cosmetics & titles ───────────────────────────────────────────────────

function ShopService:BuyCosmetic(player: Player, cosmeticId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(cosmeticId) ~= "string" then
		return
	end
	local def = CosmeticsCatalog.Get(cosmeticId)
	if not def or def.price <= 0 then
		return
	end
	if data.flags.cosmeticsOwned[cosmeticId] then
		return -- already owned
	end
	if not self.ctx.Services.EconomyService:SpendPearls(player, def.price, "cosmetic:" .. cosmeticId) then
		return
	end
	data.flags.cosmeticsOwned[cosmeticId] = true
	-- Buying a cosmetic equips it immediately (satisfying + clear)
	data.cosmetics[def.kind] = def.id
	if def.kind == "rodSkin" then
		local fishing = self.ctx.Services.FishingService
		if fishing and fishing.UpdateRodColor then
			fishing:UpdateRodColor(player)
		end
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.InventoryService:SendInventory(player)
end

function ShopService:EquipCosmetic(player: Player, cosmeticId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(cosmeticId) ~= "string" then
		return
	end
	local def = CosmeticsCatalog.Get(cosmeticId)
	if not def then
		return
	end
	if not data.flags.cosmeticsOwned[cosmeticId] and def.price > 0 then
		return -- must own it first
	end
	data.cosmetics[def.kind] = def.id
	if def.kind == "rodSkin" then
		local fishing = self.ctx.Services.FishingService
		if fishing and fishing.UpdateRodColor then
			fishing:UpdateRodColor(player)
		end
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.InventoryService:SendInventory(player)
end

function ShopService:EquipTitle(player: Player, title: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(title) ~= "string" then
		return
	end
	if data.titles[title] then
		data.equippedTitle = title
		self.ctx.Services.DataService:MarkDirty(player)
		self.ctx.Services.InventoryService:SendInventory(player)
	end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function ShopService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.BuyRod = function(player, payload)
		self:BuyRod(player, payload and payload.rodId)
	end
	ctx.MessageHandlers.EquipRod = function(player, payload)
		self:EquipRod(player, payload and payload.rodId)
	end
	ctx.MessageHandlers.BuyBait = function(player, payload)
		self:BuyBait(player, payload and payload.baitId, payload and payload.count)
	end
	ctx.MessageHandlers.EquipBait = function(player, payload)
		self:EquipBait(player, payload and payload.baitId)
	end
	ctx.MessageHandlers.BuyUpgrade = function(player, payload)
		self:BuyUpgrade(player, payload and payload.tier)
	end
	ctx.MessageHandlers.BuyCosmetic = function(player, payload)
		self:BuyCosmetic(player, payload and payload.cosmeticId)
	end
	ctx.MessageHandlers.EquipCosmetic = function(player, payload)
		self:EquipCosmetic(player, payload and payload.cosmeticId)
	end
	ctx.MessageHandlers.EquipTitle = function(player, payload)
		self:EquipTitle(player, payload and payload.title)
	end
end

function ShopService:Start()
	MarketplaceService.ProcessReceipt:Connect(function(receiptInfo)
		return self:HandleReceipt(receiptInfo)
	end)

	self.ctx.Services.DataService:OnProfileReady(function(player, _data)
		-- Apply receipts that arrived before the profile loaded
		local queue = pendingReceipts[player.UserId]
		if queue then
			pendingReceipts[player.UserId] = nil
			for _, receiptInfo  in pairs(queue) do
				self:HandleReceipt(receiptInfo)
			end
		end
		self:CheckPassOwnership(player)
	end)
end

function ShopService:Stop()
end

return ShopService
]==]
	print('[Installer] Wrote ServerScriptService/Services/ShopService')
end

-- ServerScriptService/Services/TravelService
local inst = ensure('ServerScriptService/Services/TravelService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — TravelService
	Fast travel between zones. Server-authoritative teleport:
	validates zone + unlock level + cooldown, cancels in-flight casts,
	moves the character, announces arrival. Prevents the "swim 1000 studs" grind.
	Phase 5 | AI-assisted | 2026-08-03
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local TravelService = {}
TravelService.Name = "TravelService"

local TRAVEL_COOLDOWN = 3 -- seconds between travels
local lastTravel: { [number]: number } = {}

function TravelService:HandleFastTravel(player: Player, payload: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local zoneId = payload and payload.zone
	if typeof(zoneId) ~= "string" then
		self.ctx.Services.SecurityService:Flag(player, "travel: bad zone")
		return
	end
	local zone = ZoneCatalog.Get(zoneId)
	if not zone then
		return
	end

	-- Unlock check
	if data.level < zone.unlockLevel then
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "travelDenied", text = "Reach level " .. zone.unlockLevel .. " to unlock " .. zone.name .. "!" },
		})
		return
	end

	-- Cooldown
	local now = os.clock()
	if (lastTravel[player.UserId] or 0) + TRAVEL_COOLDOWN > now then
		return
	end
	lastTravel[player.UserId] = now

	-- Character check
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not root or not humanoid then
		return
	end

	-- Cancel any in-flight cast (bobber cleanup is FishingService's job)
	local fishing = self.ctx.Services.FishingService
	if fishing then
		fishing:Cleanup(player.UserId, true)
	end

	-- Destination: zone region center (fallback to a sane spot)
	local dest = Vector3.new(0, 3, -5000)
	local region = Workspace:FindFirstChild("ZoneRegion_" .. zoneId) :: BasePart?
	if region then
		local pos = region:GetPivot().Position
		dest = Vector3.new(pos.X, 3, pos.Z)
	end

	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	root.CFrame = CFrame.new(dest)
	task.wait(0.15)
	root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

	Remotes:SendToClient(player, {
		type = "EventBanner",
		payload = { kind = "zoneEnter", text = "Welcome to " .. zone.name .. "!" },
	})
end

function TravelService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.FastTravel = function(player, payload)
		self:HandleFastTravel(player, payload)
	end
end

function TravelService:Start()
end

function TravelService:Stop()
end

return TravelService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — TravelService
	Fast travel between zones. Server-authoritative teleport:
	validates zone + unlock level + cooldown, cancels in-flight casts,
	moves the character, announces arrival. Prevents the "swim 1000 studs" grind.
	Phase 5 | AI-assisted | 2026-08-03
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local TravelService = {}
TravelService.Name = "TravelService"

local TRAVEL_COOLDOWN = 3 -- seconds between travels
local lastTravel: { [number]: number } = {}

function TravelService:HandleFastTravel(player: Player, payload: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local zoneId = payload and payload.zone
	if typeof(zoneId) ~= "string" then
		self.ctx.Services.SecurityService:Flag(player, "travel: bad zone")
		return
	end
	local zone = ZoneCatalog.Get(zoneId)
	if not zone then
		return
	end

	-- Unlock check
	if data.level < zone.unlockLevel then
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "travelDenied", text = "Reach level " .. zone.unlockLevel .. " to unlock " .. zone.name .. "!" },
		})
		return
	end

	-- Cooldown
	local now = os.clock()
	if (lastTravel[player.UserId] or 0) + TRAVEL_COOLDOWN > now then
		return
	end
	lastTravel[player.UserId] = now

	-- Character check
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not root or not humanoid then
		return
	end

	-- Cancel any in-flight cast (bobber cleanup is FishingService's job)
	local fishing = self.ctx.Services.FishingService
	if fishing then
		fishing:Cleanup(player.UserId, true)
	end

	-- Destination: zone region center (fallback to a sane spot)
	local dest = Vector3.new(0, 3, -5000)
	local region = Workspace:FindFirstChild("ZoneRegion_" .. zoneId) :: BasePart?
	if region then
		local pos = region:GetPivot().Position
		dest = Vector3.new(pos.X, 3, pos.Z)
	end

	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	root.CFrame = CFrame.new(dest)
	task.wait(0.15)
	root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

	Remotes:SendToClient(player, {
		type = "EventBanner",
		payload = { kind = "zoneEnter", text = "Welcome to " .. zone.name .. "!" },
	})
end

function TravelService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.FastTravel = function(player, payload)
		self:HandleFastTravel(player, payload)
	end
end

function TravelService:Start()
end

function TravelService:Stop()
end

return TravelService
]==]
	print('[Installer] Wrote ServerScriptService/Services/TravelService')
end

-- ServerScriptService/Services/AmbienceService
local inst = ensure('ServerScriptService/Services/AmbienceService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — AmbienceService
	Cheap "living world" on the server (no client involvement):
	- bobs every BuoyBall_* part
	- spawns and orbits seagulls over each zone
	- ANIMATED NPCs: Old Salt casts his rod; two villagers walk the village
	- FISH SCHOOLS: fish that visibly swim in every zone + near the dock
	All parts are anchored; updates are low-frequency. Zero physics cost.
	Phase 5 | AI-assisted | 2026-08-03
]]

local Workspace = game:GetService("Workspace")

local AmbienceService = {}
AmbienceService.Name = "AmbienceService"

local ZONES = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }

local buoys: { BasePart } = {}
local gulls: { { part: BasePart, center: Vector3, speed: number, radius: number, height: number, offset: number } } = {}
local npcs: { { parts: { BasePart }, path: { Vector3 }, speed: number, phase: number } } = {}
local fishSchools: { { parts: { BasePart }, center: Vector3, radius: number, speed: number, phase: number, depth: number, color: Color3 } } = {}

local function makeGull(name: string, parent: Instance): BasePart
	local gull = Instance.new("Part")
	gull.Name = name
	gull.Anchored = true
	gull.CanCollide = false
	gull.CanQuery = false
	gull.CanTouch = false
	gull.Size = Vector3.new(1.8, 0.35, 2.4)
	gull.Material = Enum.Material.SmoothPlastic
	gull.Color = Color3.fromRGB(240, 240, 246)
	gull.Shape = Enum.PartType.Block
	gull.Parent = parent
	local wing = Instance.new("WedgePart")
	wing.Name = "Wing"
	wing.Anchored = true
	wing.CanCollide = false
	wing.CanQuery = false
	wing.Size = Vector3.new(1.6, 0.12, 1.1)
	wing.Material = Enum.Material.SmoothPlastic
	wing.Color = Color3.fromRGB(80, 84, 92)
	wing.CFrame = CFrame.new(0, 0.1, -0.4) * CFrame.Angles(0, 0, 0.5)
	wing.Parent = gull
	return gull
end

-- Build a simple fish model (smooth body + tail fin)
local function makeFish(name: string, parent: Instance, color: Color3): BasePart
	local body = Instance.new("Part")
	body.Name = name
	body.Anchored = true
	body.CanCollide = false
	body.CanQuery = false
	body.CanTouch = false
	body.Size = Vector3.new(1.6, 0.7, 0.5)
	body.Material = Enum.Material.SmoothPlastic
	body.Color = color
	body.Parent = parent
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = body
	local tail = Instance.new("WedgePart")
	tail.Name = "Tail"
	tail.Anchored = true
	tail.CanCollide = false
	tail.CanQuery = false
	tail.Size = Vector3.new(0.7, 0.5, 0.12)
	tail.Material = Enum.Material.SmoothPlastic
	tail.Color = color:Lerp(Color3.new(0.4, 0.4, 0.4), 0.3)
	tail.CFrame = CFrame.new(-1.1, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	tail.Parent = body
	return body
end

-- Build a simple cloaked villager NPC (no legs needed — cloak covers)
local function makeVillager(name: string, parent: Instance, robeColor: Color3): { BasePart }
	local cloak = Instance.new("Part")
	cloak.Name = name .. "_Cloak"
	cloak.Anchored = true
	cloak.CanCollide = false
	cloak.CanQuery = false
	cloak.Size = Vector3.new(1.6, 3.2, 1.2)
	cloak.Material = Enum.Material.SmoothPlastic
	cloak.Color = robeColor
	cloak.Shape = Enum.PartType.Cylinder
	cloak.Parent = parent
	local head = Instance.new("Part")
	head.Name = name .. "_Head"
	head.Anchored = true
	head.CanCollide = false
	head.CanQuery = false
	head.Size = Vector3.new(1.1, 1.1, 1.1)
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(255, 220, 190)
	head.Shape = Enum.PartType.Ball
	head.Parent = parent
	local hat = Instance.new("Part")
	hat.Name = name .. "_Hat"
	hat.Anchored = true
	hat.CanCollide = false
	hat.CanQuery = false
	hat.Size = Vector3.new(1.4, 0.5, 1.4)
	hat.Material = Enum.Material.SmoothPlastic
	hat.Color = Color3.fromRGB(70, 70, 78)
	hat.Shape = Enum.PartType.Cylinder
	hat.Parent = parent
	-- left/right arms (swing while walking)
	local armL = Instance.new("Part")
	armL.Name = name .. "_ArmL"
	armL.Anchored = true
	armL.CanCollide = false
	armL.CanQuery = false
	armL.Size = Vector3.new(0.5, 1.6, 0.5)
	armL.Material = Enum.Material.SmoothPlastic
	armL.Color = robeColor
	armL.Parent = parent
	local armR = Instance.new("Part")
	armR.Name = name .. "_ArmR"
	armR.Anchored = true
	armR.CanCollide = false
	armR.CanQuery = false
	armR.Size = Vector3.new(0.5, 1.6, 0.5)
	armR.Material = Enum.Material.SmoothPlastic
	armR.Color = robeColor
	armR.Parent = parent
	return { cloak, head, hat, armL, armR }
end

function AmbienceService:Start()
	task.spawn(function()
		task.wait(3) -- let the world settle

		-- Collect buoys
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("BasePart") and string.sub(child.Name, 1, 9) == "BuoyBall_" then
				table.insert(buoys, child)
			end
		end

		-- Gulls per zone
		for _, zid in ipairs(ZONES) do
			local region = Workspace:FindFirstChild("ZoneRegion_" .. zid) :: BasePart?
			if region then
				local center = region:GetPivot().Position
				for i = 1, 2 do
					local gull = makeGull("Gull_" .. zid .. "_" .. i, Workspace)
					table.insert(gulls, {
						part = gull,
						center = center,
						speed = 0.14 + i * 0.05,
						radius = 34 + i * 10,
						height = 24 + i * 5,
						offset = i * 2.1,
					})
				end
			end
		end

		-- Fish schools (every zone + dock)
		local fishColors = {
			{ 90, 190, 220 }, { 230, 160, 90 }, { 160, 220, 140 }, { 220, 130, 170 },
			{ 150, 160, 220 }, { 240, 210, 110 }, { 120, 200, 180 }, { 200, 150, 220 },
		}
		local spots = { { 0, 30, "Dock" } }
		for _, zid in ipairs(ZONES) do
			local region = Workspace:FindFirstChild("ZoneRegion_" .. zid) :: BasePart?
			if region then
				local center = region:GetPivot().Position
				table.insert(spots, { center.X, center.Z, zid })
			end
		end
		for si, spot in ipairs(spots) do
			local school = { parts = {}, center = Vector3.new(spot[1], -1.6, spot[2]), radius = 26 + (si % 3) * 8, speed = 0.35 + (si % 4) * 0.12, phase = si * 1.7, depth = -1.6, color = Color3.fromRGB(fishColors[(si - 1) % 8 + 1][1], fishColors[(si - 1) % 8 + 1][2], fishColors[(si - 1) % 8 + 1][3]) }
			for f = 1, 8 do
				local fish = makeFish("Fish_" .. spot[3] .. "_" .. f, Workspace, school.color)
				fish.CFrame = CFrame.new(school.center.X, school.center.Y, school.center.Z)
				table.insert(school.parts, fish)
			end
			table.insert(fishSchools, school)
		end

		-- Animated NPCs
		-- Old Salt: casting loop (rod swings + slight bob)
		local saltBody = Workspace:FindFirstChild("OldSaltBody") :: BasePart?
		local saltRod = Workspace:FindFirstChild("OldSaltRod") :: BasePart?
		if saltBody then
			table.insert(npcs, { parts = { saltBody, saltRod or saltBody }, path = {}, speed = 0, phase = 0 })
		end

		-- Villagers walking the village path
		local villagerPaths = {
			{ Vector3.new(0, 1.2, 55), Vector3.new(-20, 1.2, 72), Vector3.new(-45, 1.4, 100), Vector3.new(-45, 1.6, 140) },
			{ Vector3.new(12, 1.2, 84), Vector3.new(42, 1.4, 118), Vector3.new(42, 1.6, 133) },
		}
		local robeColors = { Color3.fromRGB(70, 110, 160), Color3.fromRGB(150, 90, 60) }
		for i, path in ipairs(villagerPaths) do
			local parts = makeVillager("Villager" .. i, Workspace, robeColors[i])
			table.insert(npcs, { parts = parts, path = path, speed = 2.2 + i * 0.4, phase = i * 3.1 })
		end

		-- Living loop
		local t = 0
		while true do
			task.wait(0.25)
			t += 0.25

			-- Buoys bob
			for _, b in pairs(buoys) do
				local pos = b:GetPivot().Position
				b:PivotTo(CFrame.new(pos.X, pos.Y + math.sin(t * 1.7 + pos.X * 0.05) * 0.35, pos.Z))
			end

			-- Gulls orbit
			for _, g in pairs(gulls) do
				local a = t * g.speed + g.offset
				local pos = g.center + Vector3.new(math.cos(a) * g.radius, g.height + math.sin(a * 0.6) * 2.5, math.sin(a) * g.radius)
				g.part:PivotTo(CFrame.lookAt(pos, g.center + Vector3.new(0, g.height - 2, 0)))
			end

			-- Old Salt casts
			if #npcs > 0 and npcs[1].parts[2] then
				local rod = npcs[1].parts[2]
				local swing = math.sin(t * 2.4) * 0.9
				local base = CFrame.new(-18.4, 1.2, 70.8)
				rod:PivotTo(base * CFrame.Angles(0, 0, 0.6 + swing * 0.5))
				npcs[1].parts[1]:PivotTo(CFrame.new(-20, 0.05 + math.sin(t * 2.4) * 0.06, 70))
			end

			-- Villagers walk
			for i = 2, #npcs do
				local n = npcs[i]
				local path = n.path
				if #path > 1 then
					local tt = (t * n.speed * 0.05 + n.phase) % 1
					local seg = tt * (#path - 1)
					local idx = math.floor(seg) + 1
					local frac = seg - math.floor(seg)
					local a = path[math.min(idx, #path)]
					local b = path[math.min(idx + 1, #path)]
					local pos = a:Lerp(b, frac)
					local look = (b - a).Unit
					local bob = math.abs(math.sin(seg * 6)) * 0.15
					for pi, part in ipairs(n.parts) do
						local off = Vector3.new(0, 1.2 + bob, 0)
						if pi == 2 then
							off = Vector3.new(0, 2.3 + bob, 0)
						elseif pi == 3 then
							off = Vector3.new(0, 2.75 + bob, 0)
						elseif pi == 4 then
							off = Vector3.new(-0.6, 1.7 + bob + math.sin(seg * 7) * 0.3, 0)
						elseif pi == 5 then
							off = Vector3.new(0.6, 1.7 + bob + math.sin(seg * 7 + 3.14) * 0.3, 0)
						end
						part:PivotTo(CFrame.lookAt(pos + off, pos + off + look))
					end
				end
			end

			-- Fish swim in circles
			for _, school in pairs(fishSchools) do
				for fi, fish in ipairs(school.parts) do
					local a = t * school.speed + school.phase + fi * 0.35
					local pos = school.center + Vector3.new(
						math.cos(a) * school.radius,
						math.sin(a * 1.3 + fi) * 0.6,
						math.sin(a) * school.radius
					)
					local nextA = a + 0.1
					local nextPos = school.center + Vector3.new(
						math.cos(nextA) * school.radius,
						math.sin(nextA * 1.3 + fi) * 0.6,
						math.sin(nextA) * school.radius
					)
					fish:PivotTo(CFrame.lookAt(pos, nextPos))
				end
			end
		end
	end)
end

function AmbienceService:Init(ctx)
	self.ctx = ctx
end

function AmbienceService:Stop()
end

return AmbienceService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — AmbienceService
	Cheap "living world" on the server (no client involvement):
	- bobs every BuoyBall_* part
	- spawns and orbits seagulls over each zone
	- ANIMATED NPCs: Old Salt casts his rod; two villagers walk the village
	- FISH SCHOOLS: fish that visibly swim in every zone + near the dock
	All parts are anchored; updates are low-frequency. Zero physics cost.
	Phase 5 | AI-assisted | 2026-08-03
]]

local Workspace = game:GetService("Workspace")

local AmbienceService = {}
AmbienceService.Name = "AmbienceService"

local ZONES = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }

local buoys: { BasePart } = {}
local gulls: { { part: BasePart, center: Vector3, speed: number, radius: number, height: number, offset: number } } = {}
local npcs: { { parts: { BasePart }, path: { Vector3 }, speed: number, phase: number } } = {}
local fishSchools: { { parts: { BasePart }, center: Vector3, radius: number, speed: number, phase: number, depth: number, color: Color3 } } = {}

local function makeGull(name: string, parent: Instance): BasePart
	local gull = Instance.new("Part")
	gull.Name = name
	gull.Anchored = true
	gull.CanCollide = false
	gull.CanQuery = false
	gull.CanTouch = false
	gull.Size = Vector3.new(1.8, 0.35, 2.4)
	gull.Material = Enum.Material.SmoothPlastic
	gull.Color = Color3.fromRGB(240, 240, 246)
	gull.Shape = Enum.PartType.Block
	gull.Parent = parent
	local wing = Instance.new("WedgePart")
	wing.Name = "Wing"
	wing.Anchored = true
	wing.CanCollide = false
	wing.CanQuery = false
	wing.Size = Vector3.new(1.6, 0.12, 1.1)
	wing.Material = Enum.Material.SmoothPlastic
	wing.Color = Color3.fromRGB(80, 84, 92)
	wing.CFrame = CFrame.new(0, 0.1, -0.4) * CFrame.Angles(0, 0, 0.5)
	wing.Parent = gull
	return gull
end

-- Build a simple fish model (smooth body + tail fin)
local function makeFish(name: string, parent: Instance, color: Color3): BasePart
	local body = Instance.new("Part")
	body.Name = name
	body.Anchored = true
	body.CanCollide = false
	body.CanQuery = false
	body.CanTouch = false
	body.Size = Vector3.new(1.6, 0.7, 0.5)
	body.Material = Enum.Material.SmoothPlastic
	body.Color = color
	body.Parent = parent
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = body
	local tail = Instance.new("WedgePart")
	tail.Name = "Tail"
	tail.Anchored = true
	tail.CanCollide = false
	tail.CanQuery = false
	tail.Size = Vector3.new(0.7, 0.5, 0.12)
	tail.Material = Enum.Material.SmoothPlastic
	tail.Color = color:Lerp(Color3.new(0.4, 0.4, 0.4), 0.3)
	tail.CFrame = CFrame.new(-1.1, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	tail.Parent = body
	return body
end

-- Build a simple cloaked villager NPC (no legs needed — cloak covers)
local function makeVillager(name: string, parent: Instance, robeColor: Color3): { BasePart }
	local cloak = Instance.new("Part")
	cloak.Name = name .. "_Cloak"
	cloak.Anchored = true
	cloak.CanCollide = false
	cloak.CanQuery = false
	cloak.Size = Vector3.new(1.6, 3.2, 1.2)
	cloak.Material = Enum.Material.SmoothPlastic
	cloak.Color = robeColor
	cloak.Shape = Enum.PartType.Cylinder
	cloak.Parent = parent
	local head = Instance.new("Part")
	head.Name = name .. "_Head"
	head.Anchored = true
	head.CanCollide = false
	head.CanQuery = false
	head.Size = Vector3.new(1.1, 1.1, 1.1)
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(255, 220, 190)
	head.Shape = Enum.PartType.Ball
	head.Parent = parent
	local hat = Instance.new("Part")
	hat.Name = name .. "_Hat"
	hat.Anchored = true
	hat.CanCollide = false
	hat.CanQuery = false
	hat.Size = Vector3.new(1.4, 0.5, 1.4)
	hat.Material = Enum.Material.SmoothPlastic
	hat.Color = Color3.fromRGB(70, 70, 78)
	hat.Shape = Enum.PartType.Cylinder
	hat.Parent = parent
	-- left/right arms (swing while walking)
	local armL = Instance.new("Part")
	armL.Name = name .. "_ArmL"
	armL.Anchored = true
	armL.CanCollide = false
	armL.CanQuery = false
	armL.Size = Vector3.new(0.5, 1.6, 0.5)
	armL.Material = Enum.Material.SmoothPlastic
	armL.Color = robeColor
	armL.Parent = parent
	local armR = Instance.new("Part")
	armR.Name = name .. "_ArmR"
	armR.Anchored = true
	armR.CanCollide = false
	armR.CanQuery = false
	armR.Size = Vector3.new(0.5, 1.6, 0.5)
	armR.Material = Enum.Material.SmoothPlastic
	armR.Color = robeColor
	armR.Parent = parent
	return { cloak, head, hat, armL, armR }
end

function AmbienceService:Start()
	task.spawn(function()
		task.wait(3) -- let the world settle

		-- Collect buoys
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("BasePart") and string.sub(child.Name, 1, 9) == "BuoyBall_" then
				table.insert(buoys, child)
			end
		end

		-- Gulls per zone
		for _, zid in ipairs(ZONES) do
			local region = Workspace:FindFirstChild("ZoneRegion_" .. zid) :: BasePart?
			if region then
				local center = region:GetPivot().Position
				for i = 1, 2 do
					local gull = makeGull("Gull_" .. zid .. "_" .. i, Workspace)
					table.insert(gulls, {
						part = gull,
						center = center,
						speed = 0.14 + i * 0.05,
						radius = 34 + i * 10,
						height = 24 + i * 5,
						offset = i * 2.1,
					})
				end
			end
		end

		-- Fish schools (every zone + dock)
		local fishColors = {
			{ 90, 190, 220 }, { 230, 160, 90 }, { 160, 220, 140 }, { 220, 130, 170 },
			{ 150, 160, 220 }, { 240, 210, 110 }, { 120, 200, 180 }, { 200, 150, 220 },
		}
		local spots = { { 0, 30, "Dock" } }
		for _, zid in ipairs(ZONES) do
			local region = Workspace:FindFirstChild("ZoneRegion_" .. zid) :: BasePart?
			if region then
				local center = region:GetPivot().Position
				table.insert(spots, { center.X, center.Z, zid })
			end
		end
		for si, spot in ipairs(spots) do
			local school = { parts = {}, center = Vector3.new(spot[1], -1.6, spot[2]), radius = 26 + (si % 3) * 8, speed = 0.35 + (si % 4) * 0.12, phase = si * 1.7, depth = -1.6, color = Color3.fromRGB(fishColors[(si - 1) % 8 + 1][1], fishColors[(si - 1) % 8 + 1][2], fishColors[(si - 1) % 8 + 1][3]) }
			for f = 1, 8 do
				local fish = makeFish("Fish_" .. spot[3] .. "_" .. f, Workspace, school.color)
				fish.CFrame = CFrame.new(school.center.X, school.center.Y, school.center.Z)
				table.insert(school.parts, fish)
			end
			table.insert(fishSchools, school)
		end

		-- Animated NPCs
		-- Old Salt: casting loop (rod swings + slight bob)
		local saltBody = Workspace:FindFirstChild("OldSaltBody") :: BasePart?
		local saltRod = Workspace:FindFirstChild("OldSaltRod") :: BasePart?
		if saltBody then
			table.insert(npcs, { parts = { saltBody, saltRod or saltBody }, path = {}, speed = 0, phase = 0 })
		end

		-- Villagers walking the village path
		local villagerPaths = {
			{ Vector3.new(0, 1.2, 55), Vector3.new(-20, 1.2, 72), Vector3.new(-45, 1.4, 100), Vector3.new(-45, 1.6, 140) },
			{ Vector3.new(12, 1.2, 84), Vector3.new(42, 1.4, 118), Vector3.new(42, 1.6, 133) },
		}
		local robeColors = { Color3.fromRGB(70, 110, 160), Color3.fromRGB(150, 90, 60) }
		for i, path in ipairs(villagerPaths) do
			local parts = makeVillager("Villager" .. i, Workspace, robeColors[i])
			table.insert(npcs, { parts = parts, path = path, speed = 2.2 + i * 0.4, phase = i * 3.1 })
		end

		-- Living loop
		local t = 0
		while true do
			task.wait(0.25)
			t += 0.25

			-- Buoys bob
			for _, b in pairs(buoys) do
				local pos = b:GetPivot().Position
				b:PivotTo(CFrame.new(pos.X, pos.Y + math.sin(t * 1.7 + pos.X * 0.05) * 0.35, pos.Z))
			end

			-- Gulls orbit
			for _, g in pairs(gulls) do
				local a = t * g.speed + g.offset
				local pos = g.center + Vector3.new(math.cos(a) * g.radius, g.height + math.sin(a * 0.6) * 2.5, math.sin(a) * g.radius)
				g.part:PivotTo(CFrame.lookAt(pos, g.center + Vector3.new(0, g.height - 2, 0)))
			end

			-- Old Salt casts
			if #npcs > 0 and npcs[1].parts[2] then
				local rod = npcs[1].parts[2]
				local swing = math.sin(t * 2.4) * 0.9
				local base = CFrame.new(-18.4, 1.2, 70.8)
				rod:PivotTo(base * CFrame.Angles(0, 0, 0.6 + swing * 0.5))
				npcs[1].parts[1]:PivotTo(CFrame.new(-20, 0.05 + math.sin(t * 2.4) * 0.06, 70))
			end

			-- Villagers walk
			for i = 2, #npcs do
				local n = npcs[i]
				local path = n.path
				if #path > 1 then
					local tt = (t * n.speed * 0.05 + n.phase) % 1
					local seg = tt * (#path - 1)
					local idx = math.floor(seg) + 1
					local frac = seg - math.floor(seg)
					local a = path[math.min(idx, #path)]
					local b = path[math.min(idx + 1, #path)]
					local pos = a:Lerp(b, frac)
					local look = (b - a).Unit
					local bob = math.abs(math.sin(seg * 6)) * 0.15
					for pi, part in ipairs(n.parts) do
						local off = Vector3.new(0, 1.2 + bob, 0)
						if pi == 2 then
							off = Vector3.new(0, 2.3 + bob, 0)
						elseif pi == 3 then
							off = Vector3.new(0, 2.75 + bob, 0)
						elseif pi == 4 then
							off = Vector3.new(-0.6, 1.7 + bob + math.sin(seg * 7) * 0.3, 0)
						elseif pi == 5 then
							off = Vector3.new(0.6, 1.7 + bob + math.sin(seg * 7 + 3.14) * 0.3, 0)
						end
						part:PivotTo(CFrame.lookAt(pos + off, pos + off + look))
					end
				end
			end

			-- Fish swim in circles
			for _, school in pairs(fishSchools) do
				for fi, fish in ipairs(school.parts) do
					local a = t * school.speed + school.phase + fi * 0.35
					local pos = school.center + Vector3.new(
						math.cos(a) * school.radius,
						math.sin(a * 1.3 + fi) * 0.6,
						math.sin(a) * school.radius
					)
					local nextA = a + 0.1
					local nextPos = school.center + Vector3.new(
						math.cos(nextA) * school.radius,
						math.sin(nextA * 1.3 + fi) * 0.6,
						math.sin(nextA) * school.radius
					)
					fish:PivotTo(CFrame.lookAt(pos, nextPos))
				end
			end
		end
	end)
end

function AmbienceService:Init(ctx)
	self.ctx = ctx
end

function AmbienceService:Stop()
end

return AmbienceService
]==]
	print('[Installer] Wrote ServerScriptService/Services/AmbienceService')
end

-- ServerScriptService/Services/FishingService
local inst = ensure('ServerScriptService/Services/FishingService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — FishingService
	The heart of the game. Server-authoritative cast → bite → reel → catch.
	- Server owns ALL RNG (fish pick, shiny roll, weight, timing).
	- Client only sends intents: Cast, ReelHold, AutoReel.
	- Reel minigame is simulated on the server at Config.REEL_TICK granularity.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)
local CosmeticsCatalog = require(ReplicatedStorage.Shared.Data.CosmeticsCatalog)

local FishingService = {}
FishingService.Name = "FishingService"

-- ── State ────────────────────────────────────────────────────────────────

type CastState = {
	player: Player,
	bobber: Part,
	zoneId: string,
	phase: "waiting" | "reeling",
	waitUntil: number,
	fishId: string,
	fishName: string,
	rarity: Types.Rarity,
	shiny: boolean,
	weight: number,
	progress: number,
	tension: number,
	holding: boolean,
	progressRate: number,
	tensionRate: number,
	lastSend: number,
	golden: boolean,
}

local casts: { [number]: CastState } = {}
local lastCastTime: { [number]: number } = {}
local zoneRegions: { [string]: BasePart? } = {}
local warnedRegions = false

-- ── Zone helpers ─────────────────────────────────────────────────────────

function FishingService:RefreshRegions()
	zoneRegions = {}
	for zoneId  in pairs(ZoneCatalog.GetAll()) do
		zoneRegions[zoneId] = Workspace:FindFirstChild(ZoneCatalog.RegionPartName(zoneId)) :: BasePart?
	end
	warnedRegions = false
end

function FishingService:GetZoneAt(position: Vector3): string?
	for zoneId, region  in pairs(zoneRegions) do
		if region then
			local localPos = region.CFrame:PointToObjectSpace(position)
			local size = region.Size
			if math.abs(localPos.X) <= size.X / 2 and math.abs(localPos.Y) <= size.Y / 2 and math.abs(localPos.Z) <= size.Z / 2 then
				return zoneId
			end
		end
	end
	return nil
end

-- ── Fish picking (server-only RNG) ───────────────────────────────────────

function FishingService:PickFish(zoneId: string, data: Types.ProfileData, extraLuck: number?): { fishId: string, shiny: boolean, weight: number }
	local eventService = self.ctx.Services.EventService
	local isNight = eventService and eventService:GetTimeOfDay() == "night" or false
	local isStorm = eventService and eventService:IsStorm() or false
	extraLuck = extraLuck or 0

	local candidates = FishCatalog.GetZoneFish(zoneId, isNight, isStorm)
	if #candidates == 0 then
		return { fishId = "sunsail_minnow", shiny = false, weight = 0.5 } -- safety fallback
	end

	-- Luck stack (capped)
	local rod = RodCatalog.Get(data.equippedRod)
	local totalLuck = (rod and rod.luck or 0) + extraLuck
	if data.flags.ownedPasses.lucky_charm then
		totalLuck += Config.LUCKY_CHARM_LUCK
	end
	if isNight then
		totalLuck += Config.NIGHT_LUCK
	end
	local bait = data.flags.equippedBait
	local isGolden = bait == "golden"
	if isGolden then
		totalLuck += Config.GOLDEN_LURE_LUCK
	end

	-- Weights per fish
	local weights: { [string]: number } = {}
	for _, def  in pairs(candidates) do
		local base = Config.RARITY_WEIGHTS[def.rarity] or 1
		local w = base
		local idx = Config.RARITY_INDEX[def.rarity] or 1
		if idx >= 4 and totalLuck > 0 then
			w = base * Util.clamp(1 + totalLuck, 1, Config.LUCK_CAP)
		end
		-- Bait preference: double the family's weight
		if bait and def.bait == bait then
			w *= Config.BAIT_FAMILY_MULT
		end
		if isGolden then
			w *= Config.GOLDEN_LURE_WEIGHT_MULT
		end
		weights[def.id] = w
	end

	-- The Old One is NEVER in the normal loot table — it only appears via its
	-- secret trigger (50 deep-water fish caught, then a 2% roll). This keeps it
	-- a discovered secret rather than an ordinary mythic.
	weights["old_one"] = nil
	local pickedId = Util.weightedPick(weights)
	if zoneId == "abyss" and data.stats.deepFish >= 50 and Util.rollChance(0.02) then
		pickedId = "old_one"
	end
	local def = FishCatalog.Get(pickedId or "sunsail_minnow")
	if not def then
		def = FishCatalog.Get("sunsail_minnow") :: Types.FishDef
	end

	-- Weight roll (skewed small); golden lure adds heft
	local weight = Util.rollWeight(def.minWeight, def.maxWeight)
	if isGolden then
		weight = Util.round(weight * Config.GOLDEN_LURE_WEIGHT_MULT, 1)
	end

	local shiny = Util.rollChance(Config.SHINY_CHANCE)
	return { fishId = def.id, shiny = shiny, weight = weight }
end

-- ── Cast (intent from client) ────────────────────────────────────────────

function FishingService:HandleCast(player: Player, payload: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local uid = player.UserId

	-- State + cooldown
	if casts[uid] then
		return
	end
	local now = os.clock()
	if (lastCastTime[uid] or 0) + Config.CAST_COOLDOWN > now then
		return
	end

	-- Payload validation
	local dir = payload and payload.dir
	local power = payload and payload.power
	if typeof(dir) ~= "Vector3" then
		self.ctx.Services.SecurityService:Flag(player, "cast: bad dir")
		return
	end
	if dir.Magnitude < 0.4 or dir.Magnitude > 2.0 then
		self.ctx.Services.SecurityService:Flag(player, "cast: bad magnitude")
		return
	end
	power = Util.clamp(Util.safeNumber(power, 0.5), 0, 1)

	-- Position validation (must be inside a fishing region)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end
	local zoneId = self:GetZoneAt(root.Position)
	if not zoneId then
		return
	end

	-- Rod check
	local rod = RodCatalog.Get(data.equippedRod)
	if not rod or not data.rods[data.equippedRod] then
		return
	end

	-- Guide: first cast
	local world = self.ctx.Services.WorldInteractionsService
	if world and world.OnCast then
		world:OnCast(player)
	end

	-- Consume bait (equipped bait, 1 per cast; Golden Lure Pass makes golden free)
	local equippedBait = data.flags.equippedBait
	if equippedBait then
		local count = data.baits[equippedBait] or 0
		if count <= 0 and not (equippedBait == "golden" and data.flags.ownedPasses.golden_lure_pass) then
			data.flags.equippedBait = nil
		elseif count > 0 then
			data.baits[equippedBait] = count - 1
			if data.baits[equippedBait] == 0 and not (equippedBait == "golden" and data.flags.ownedPasses.golden_lure_pass) then
				data.flags.equippedBait = nil
			end
			self.ctx.Services.DataService:MarkDirty(player)
		end
	end

	-- Bobber (with cosmetic colors + trail)
	local bobber = Instance.new("Part")
	bobber.Name = "Bobber_" .. player.Name
	bobber.Size = Vector3.new(0.8, 0.8, 0.8)
	bobber.Shape = Enum.PartType.Ball
	bobber.Material = Enum.Material.Neon
	local bobberColor = Color3.fromRGB(255, 220, 80)
	local bobberDef = data.cosmetics.bobber and CosmeticsCatalog.Get(data.cosmetics.bobber)
	if bobberDef then
		bobberColor = bobberDef.color
	end
	bobber.Color = bobberColor
	bobber.Anchored = true
	bobber.CanCollide = false
	bobber.CanQuery = false
	bobber.CanTouch = false
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = bobber
	local trailDef = data.cosmetics.trail and CosmeticsCatalog.Get(data.cosmetics.trail)
	if trailDef then
		local pe = Instance.new("ParticleEmitter")
		pe.Name = "TrailFX"
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Rate = 30
		pe.Lifetime = NumberRange.new(0.4, 0.9)
		pe.Speed = NumberRange.new(0.5, 2)
		pe.Size = NumberSequence.new(0.08, 0.28)
		pe.Transparency = NumberSequence.new(0.3, 1)
		pe.Color = ColorSequence.new(trailDef.color)
		pe.Parent = bobber
	end
	local castDist = 12 + 18 * power
	local targetPos = root.Position + dir.Unit * castDist
	bobber.CFrame = CFrame.new(targetPos.X, Config.WATER_Y + 0.6, targetPos.Z)
	bobber.Parent = Workspace

	-- State
	local waitTime = Util.clamp(
		math.random() * (Config.WAIT_MAX - Config.WAIT_MIN) + Config.WAIT_MIN - rod.lure,
		Config.WAIT_FLOOR,
		Config.WAIT_MAX
	)
	casts[uid] = {
		player = player,
		bobber = bobber,
		zoneId = zoneId,
		phase = "waiting",
		waitUntil = now + waitTime,
		fishId = "",
		fishName = "",
		rarity = "common",
		shiny = false,
		weight = 0,
		progress = 0,
		tension = 0,
		holding = false,
		progressRate = 0,
		tensionRate = 0,
		lastSend = 0,
		golden = false,
	}
	lastCastTime[uid] = now

	-- Simulation loop
	task.spawn(function()
		self:RunCast(uid)
	end)
end

-- ── Cast simulation ──────────────────────────────────────────────────────

function FishingService:RunCast(uid: number)
	local state = casts[uid]
	if not state then
		return
	end
	local data = self.ctx.Services.DataService:GetData(state.player)
	local lastTick = os.clock()
	while casts[uid] do
		task.wait(Config.REEL_TICK)
		local now = os.clock()
		local dt = now - lastTick
		lastTick = now
		state = casts[uid]
		if not state then
			return
		end
		data = data or self.ctx.Services.DataService:GetData(state.player)
		if not data then
			self:Cleanup(uid, false)
			return
		end

		if state.phase == "waiting" then
			if now >= state.waitUntil then
				self:StartBite(uid)
			end
		elseif state.phase == "reeling" then
			-- Anti-exploit: player must stay near their own bobber
			local character = state.player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not root then
				self:Cleanup(uid, false)
				return
			end
			if (root.Position - state.bobber.Position).Magnitude > Config.REEL_POSITION_RADIUS then
				self:Cleanup(uid, false)
				return
			end

			-- Simulate
			if state.holding then
				state.progress += state.progressRate * dt
				state.tension += state.tensionRate * dt
			else
				state.tension = math.max(0, state.tension - Config.TENSION_DECAY * dt)
			end

			if state.tension >= Config.TENSION_MAX then
				-- Line snapped
				Remotes:SendToClient(state.player, { type = "CatchResult", payload = { snapped = true } })
				self:Cleanup(uid, true)
				return
			end
			if state.progress >= Config.PROGRESS_MAX then
				self:ResolveCatch(uid)
				return
			end

			-- Push reel state (throttled)
			if now - state.lastSend >= Config.REEL_STATE_SEND then
				state.lastSend = now
				Remotes:SendToClient(state.player, {
					type = "ReelState",
					payload = {
						progress = state.progress,
						tension = state.tension,
						fishName = state.fishName,
						rarity = state.rarity,
					},
				})
			end
		end
	end
end

function FishingService:StartBite(uid: number)
	local state = casts[uid]
	if not state then
		return
	end
	local data = self.ctx.Services.DataService:GetData(state.player)
	if not data then
		return
	end
	local eventSvc = self.ctx.Services.EventService
	state.golden = eventSvc ~= nil and eventSvc:IsGoldenAt(state.bobber.Position) == true or false
	local roll = self:PickFish(state.zoneId, data, state.golden and Config.GOLDEN_SPOT_LUCK or 0)
	local def = FishCatalog.Get(roll.fishId)
	if not def then
		self:Cleanup(uid, false)
		return
	end
	local rod = RodCatalog.Get(data.equippedRod) :: Types.RodDef

	state.phase = "reeling"
	local world = self.ctx.Services.WorldInteractionsService
	if world and world.OnReelStart then
		world:OnReelStart(state.player)
	end
	state.fishId = def.id
	state.fishName = def.name
	state.rarity = def.rarity
	state.shiny = roll.shiny
	state.weight = roll.weight
	local idx = Config.RARITY_INDEX[def.rarity] or 1
	state.tensionRate = Config.TENSION_RISE_BASE * (1 + Config.TENSION_RISE_PER_RARITY * (idx - 1)) / rod.strength
	state.progressRate = Config.PROGRESS_RATE_BASE + Config.PROGRESS_RATE_PER_STRENGTH * rod.strength

	-- Old One teaser
	if def.id == "old_one" then
		Remotes:SendToClient(state.player, { type = "EventBanner", payload = { kind = "oldOne", text = "Something ancient takes the line..." } })
	end

	-- Bite!
	Remotes:SendToClient(state.player, {
		type = "Bite",
		payload = {
			strength = rod.strength,
			rarity = def.rarity,
			fishName = def.name,
		},
	})
end

-- ── Catch resolution ─────────────────────────────────────────────────────

function FishingService:ResolveCatch(uid: number)
	local state = casts[uid]
	if not state then
		return
	end
	local data = self.ctx.Services.DataService:GetData(state.player)
	if not data then
		self:Cleanup(uid, false)
		return
	end
	local def = FishCatalog.Get(state.fishId)
	if not def then
		self:Cleanup(uid, false)
		return
	end

	local eventService = self.ctx.Services.EventService
	local isNight = eventService and eventService:GetTimeOfDay() == "night" or false
	local isStorm = eventService and eventService:IsStorm() or false

	local outcome = self.ctx.Services.InventoryService:AddCatch(
		state.player,
		def,
		state.weight,
		state.shiny,
		isNight,
		isStorm,
		state.golden
	)

	-- Catch aura (cosmetic)
	local auraDef = data.cosmetics.aura and CosmeticsCatalog.Get(data.cosmetics.aura)
	if auraDef then
		local fx = Instance.new("Part")
		fx.Name = "CatchAura"
		fx.Anchored = true
		fx.CanCollide = false
		fx.CanQuery = false
		fx.Size = Vector3.new(0.5, 0.5, 0.5)
		fx.Transparency = 1
		fx.CFrame = state.bobber.CFrame
		fx.Parent = Workspace
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Rate = 40
		pe.Lifetime = NumberRange.new(0.5, 1.1)
		pe.Speed = NumberRange.new(2, 5)
		pe.Size = NumberSequence.new(0.3, 0.9)
		pe.Transparency = NumberSequence.new(0.2, 1)
		pe.Color = ColorSequence.new(auraDef.color)
		pe.Parent = fx
		task.delay(1.4, function()
			if fx and fx.Parent then
				fx:Destroy()
			end
		end)
	end

	-- Result to the catcher
	Remotes:SendToClient(state.player, {
		type = "CatchResult",
		payload = {
			snapped = false,
			fishId = def.id,
			name = def.name,
			rarity = def.rarity,
			weight = state.weight,
			shiny = state.shiny,
			value = outcome and outcome.value or 0,
			coins = outcome and outcome.coins or 0,
			xp = outcome and outcome.xp or 0,
			pearls = outcome and outcome.pearls or 0,
			autoSold = outcome and outcome.autoSold or false,
			overflowSold = outcome and outcome.overflowSold or false,
			zonePct = outcome and outcome.zonePct or 0,
			golden = state.golden,
		},
	})

	-- Feed + announcements (virality layer)
	local idx = Config.RARITY_INDEX[def.rarity] or 1
	if state.shiny or idx >= 6 then
		Remotes:SendToAll({
			type = "FeedMessage",
			payload = {
				kind = "announce",
				text = state.player.Name .. " caught " .. (state.shiny and "a SHINY " or "a MYTHIC ") .. def.name .. " — " .. state.weight .. "kg!",
			},
		})
	elseif idx >= 4 then
		Remotes:SendToAll({
			type = "FeedMessage",
			payload = {
				kind = "chat",
				text = state.player.Name .. " caught a " .. def.name .. " (" .. state.weight .. "kg)",
			},
		})
	end

	self:Cleanup(uid, true)
end

-- ── Reel input (client intents) ──────────────────────────────────────────

function FishingService:HandleReelHold(player: Player, payload: any)
	local state = casts[player.UserId]
	if not state or state.phase ~= "reeling" then
		return
	end
	state.holding = payload and payload.held == true
end

function FishingService:HandleAutoReel(player: Player)
	local state = casts[player.UserId]
	local data = self.ctx.Services.DataService:GetData(player)
	if not state or state.phase ~= "reeling" or not data then
		return
	end
	if data.flags.tokens <= 0 then
		return
	end
	data.flags.tokens -= 1
	self.ctx.Services.DataService:MarkDirty(player)
	self:ResolveCatch(player.UserId)
end

-- ── Rod tool (visible fishing rod) ───────────────────────────────────────

function FishingService:UpdateRodColor(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	local character = player.Character
	if not data or not character then
		return
	end
	local tool = character:FindFirstChild("FishingRod")
	local handle = tool and tool:FindFirstChild("Handle") :: BasePart?
	if not handle then
		return
	end
	local rod = RodCatalog.Get(data.equippedRod)
	local color = rod and rod.color or Color3.fromRGB(150, 110, 70)
	local skin = data.cosmetics.rodSkin and CosmeticsCatalog.Get(data.cosmetics.rodSkin)
	if skin then
		color = skin.color
	end
	handle.Color = color
end

function FishingService:EnsureRodTool(player: Player)
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not humanoid then
		return
	end
	local existing = character:FindFirstChild("FishingRod")
	if existing then
		self:UpdateRodColor(player)
		return
	end
	local tool = Instance.new("Tool")
	tool.Name = "FishingRod"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.45, 6.5, 0.45)
	handle.Material = Enum.Material.Wood
	handle.Color = Color3.fromRGB(150, 110, 70)
	handle.Shape = Enum.PartType.Cylinder
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	tool.Parent = character
	task.wait(0.1)
	pcall(function()
		humanoid:EquipTool(tool)
	end)
	self:UpdateRodColor(player)
end

-- ── Cleanup ──────────────────────────────────────────────────────────────

function FishingService:Cleanup(uid: number, destroyBobber: boolean)
	local state = casts[uid]
	if not state then
		return
	end
	if destroyBobber and state.bobber then
		state.bobber:Destroy()
	end
	casts[uid] = nil
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function FishingService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.Cast = function(player, payload)
		self:HandleCast(player, payload)
	end
	ctx.MessageHandlers.ReelHold = function(player, payload)
		self:HandleReelHold(player, payload)
	end
	ctx.MessageHandlers.AutoReel = function(player, _payload)
		self:HandleAutoReel(player)
	end
end

function FishingService:Start()
	self:RefreshRegions()
	-- Keep region cache fresh if the builder edits live
	Workspace.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") and string.sub(desc.Name, 1, 11) == "ZoneRegion_" then
			self:RefreshRegions()
		end
	end)
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(_character)
			self:EnsureRodTool(player)
		end)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			task.spawn(function()
				task.wait(0.5)
				self:EnsureRodTool(player)
			end)
		end
	end
	Players.PlayerRemoving:Connect(function(player)
		self:Cleanup(player.UserId, true)
	end)
	if not warnedRegions then
		local count = 0
		for _, region  in pairs(zoneRegions) do
			if region then
				count += 1
			end
		end
		if count < 6 then
			warn("[Fishing] Only " .. count .. " zone regions found. Place ZoneRegion_<zone> parts in Workspace (see src/README.md).")
		end
	end
end

function FishingService:Stop()
	for uid, state  in pairs(casts) do
		self:Cleanup(uid, true)
	end
end

return FishingService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — FishingService
	The heart of the game. Server-authoritative cast → bite → reel → catch.
	- Server owns ALL RNG (fish pick, shiny roll, weight, timing).
	- Client only sends intents: Cast, ReelHold, AutoReel.
	- Reel minigame is simulated on the server at Config.REEL_TICK granularity.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)
local CosmeticsCatalog = require(ReplicatedStorage.Shared.Data.CosmeticsCatalog)

local FishingService = {}
FishingService.Name = "FishingService"

-- ── State ────────────────────────────────────────────────────────────────

type CastState = {
	player: Player,
	bobber: Part,
	zoneId: string,
	phase: "waiting" | "reeling",
	waitUntil: number,
	fishId: string,
	fishName: string,
	rarity: Types.Rarity,
	shiny: boolean,
	weight: number,
	progress: number,
	tension: number,
	holding: boolean,
	progressRate: number,
	tensionRate: number,
	lastSend: number,
	golden: boolean,
}

local casts: { [number]: CastState } = {}
local lastCastTime: { [number]: number } = {}
local zoneRegions: { [string]: BasePart? } = {}
local warnedRegions = false

-- ── Zone helpers ─────────────────────────────────────────────────────────

function FishingService:RefreshRegions()
	zoneRegions = {}
	for zoneId  in pairs(ZoneCatalog.GetAll()) do
		zoneRegions[zoneId] = Workspace:FindFirstChild(ZoneCatalog.RegionPartName(zoneId)) :: BasePart?
	end
	warnedRegions = false
end

function FishingService:GetZoneAt(position: Vector3): string?
	for zoneId, region  in pairs(zoneRegions) do
		if region then
			local localPos = region.CFrame:PointToObjectSpace(position)
			local size = region.Size
			if math.abs(localPos.X) <= size.X / 2 and math.abs(localPos.Y) <= size.Y / 2 and math.abs(localPos.Z) <= size.Z / 2 then
				return zoneId
			end
		end
	end
	return nil
end

-- ── Fish picking (server-only RNG) ───────────────────────────────────────

function FishingService:PickFish(zoneId: string, data: Types.ProfileData, extraLuck: number?): { fishId: string, shiny: boolean, weight: number }
	local eventService = self.ctx.Services.EventService
	local isNight = eventService and eventService:GetTimeOfDay() == "night" or false
	local isStorm = eventService and eventService:IsStorm() or false
	extraLuck = extraLuck or 0

	local candidates = FishCatalog.GetZoneFish(zoneId, isNight, isStorm)
	if #candidates == 0 then
		return { fishId = "sunsail_minnow", shiny = false, weight = 0.5 } -- safety fallback
	end

	-- Luck stack (capped)
	local rod = RodCatalog.Get(data.equippedRod)
	local totalLuck = (rod and rod.luck or 0) + extraLuck
	if data.flags.ownedPasses.lucky_charm then
		totalLuck += Config.LUCKY_CHARM_LUCK
	end
	if isNight then
		totalLuck += Config.NIGHT_LUCK
	end
	local bait = data.flags.equippedBait
	local isGolden = bait == "golden"
	if isGolden then
		totalLuck += Config.GOLDEN_LURE_LUCK
	end

	-- Weights per fish
	local weights: { [string]: number } = {}
	for _, def  in pairs(candidates) do
		local base = Config.RARITY_WEIGHTS[def.rarity] or 1
		local w = base
		local idx = Config.RARITY_INDEX[def.rarity] or 1
		if idx >= 4 and totalLuck > 0 then
			w = base * Util.clamp(1 + totalLuck, 1, Config.LUCK_CAP)
		end
		-- Bait preference: double the family's weight
		if bait and def.bait == bait then
			w *= Config.BAIT_FAMILY_MULT
		end
		if isGolden then
			w *= Config.GOLDEN_LURE_WEIGHT_MULT
		end
		weights[def.id] = w
	end

	-- The Old One is NEVER in the normal loot table — it only appears via its
	-- secret trigger (50 deep-water fish caught, then a 2% roll). This keeps it
	-- a discovered secret rather than an ordinary mythic.
	weights["old_one"] = nil
	local pickedId = Util.weightedPick(weights)
	if zoneId == "abyss" and data.stats.deepFish >= 50 and Util.rollChance(0.02) then
		pickedId = "old_one"
	end
	local def = FishCatalog.Get(pickedId or "sunsail_minnow")
	if not def then
		def = FishCatalog.Get("sunsail_minnow") :: Types.FishDef
	end

	-- Weight roll (skewed small); golden lure adds heft
	local weight = Util.rollWeight(def.minWeight, def.maxWeight)
	if isGolden then
		weight = Util.round(weight * Config.GOLDEN_LURE_WEIGHT_MULT, 1)
	end

	local shiny = Util.rollChance(Config.SHINY_CHANCE)
	return { fishId = def.id, shiny = shiny, weight = weight }
end

-- ── Cast (intent from client) ────────────────────────────────────────────

function FishingService:HandleCast(player: Player, payload: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local uid = player.UserId

	-- State + cooldown
	if casts[uid] then
		return
	end
	local now = os.clock()
	if (lastCastTime[uid] or 0) + Config.CAST_COOLDOWN > now then
		return
	end

	-- Payload validation
	local dir = payload and payload.dir
	local power = payload and payload.power
	if typeof(dir) ~= "Vector3" then
		self.ctx.Services.SecurityService:Flag(player, "cast: bad dir")
		return
	end
	if dir.Magnitude < 0.4 or dir.Magnitude > 2.0 then
		self.ctx.Services.SecurityService:Flag(player, "cast: bad magnitude")
		return
	end
	power = Util.clamp(Util.safeNumber(power, 0.5), 0, 1)

	-- Position validation (must be inside a fishing region)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end
	local zoneId = self:GetZoneAt(root.Position)
	if not zoneId then
		return
	end

	-- Rod check
	local rod = RodCatalog.Get(data.equippedRod)
	if not rod or not data.rods[data.equippedRod] then
		return
	end

	-- Guide: first cast
	local world = self.ctx.Services.WorldInteractionsService
	if world and world.OnCast then
		world:OnCast(player)
	end

	-- Consume bait (equipped bait, 1 per cast; Golden Lure Pass makes golden free)
	local equippedBait = data.flags.equippedBait
	if equippedBait then
		local count = data.baits[equippedBait] or 0
		if count <= 0 and not (equippedBait == "golden" and data.flags.ownedPasses.golden_lure_pass) then
			data.flags.equippedBait = nil
		elseif count > 0 then
			data.baits[equippedBait] = count - 1
			if data.baits[equippedBait] == 0 and not (equippedBait == "golden" and data.flags.ownedPasses.golden_lure_pass) then
				data.flags.equippedBait = nil
			end
			self.ctx.Services.DataService:MarkDirty(player)
		end
	end

	-- Bobber (with cosmetic colors + trail)
	local bobber = Instance.new("Part")
	bobber.Name = "Bobber_" .. player.Name
	bobber.Size = Vector3.new(0.8, 0.8, 0.8)
	bobber.Shape = Enum.PartType.Ball
	bobber.Material = Enum.Material.Neon
	local bobberColor = Color3.fromRGB(255, 220, 80)
	local bobberDef = data.cosmetics.bobber and CosmeticsCatalog.Get(data.cosmetics.bobber)
	if bobberDef then
		bobberColor = bobberDef.color
	end
	bobber.Color = bobberColor
	bobber.Anchored = true
	bobber.CanCollide = false
	bobber.CanQuery = false
	bobber.CanTouch = false
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = bobber
	local trailDef = data.cosmetics.trail and CosmeticsCatalog.Get(data.cosmetics.trail)
	if trailDef then
		local pe = Instance.new("ParticleEmitter")
		pe.Name = "TrailFX"
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Rate = 30
		pe.Lifetime = NumberRange.new(0.4, 0.9)
		pe.Speed = NumberRange.new(0.5, 2)
		pe.Size = NumberSequence.new(0.08, 0.28)
		pe.Transparency = NumberSequence.new(0.3, 1)
		pe.Color = ColorSequence.new(trailDef.color)
		pe.Parent = bobber
	end
	local castDist = 12 + 18 * power
	local targetPos = root.Position + dir.Unit * castDist
	bobber.CFrame = CFrame.new(targetPos.X, Config.WATER_Y + 0.6, targetPos.Z)
	bobber.Parent = Workspace

	-- State
	local waitTime = Util.clamp(
		math.random() * (Config.WAIT_MAX - Config.WAIT_MIN) + Config.WAIT_MIN - rod.lure,
		Config.WAIT_FLOOR,
		Config.WAIT_MAX
	)
	casts[uid] = {
		player = player,
		bobber = bobber,
		zoneId = zoneId,
		phase = "waiting",
		waitUntil = now + waitTime,
		fishId = "",
		fishName = "",
		rarity = "common",
		shiny = false,
		weight = 0,
		progress = 0,
		tension = 0,
		holding = false,
		progressRate = 0,
		tensionRate = 0,
		lastSend = 0,
		golden = false,
	}
	lastCastTime[uid] = now

	-- Simulation loop
	task.spawn(function()
		self:RunCast(uid)
	end)
end

-- ── Cast simulation ──────────────────────────────────────────────────────

function FishingService:RunCast(uid: number)
	local state = casts[uid]
	if not state then
		return
	end
	local data = self.ctx.Services.DataService:GetData(state.player)
	local lastTick = os.clock()
	while casts[uid] do
		task.wait(Config.REEL_TICK)
		local now = os.clock()
		local dt = now - lastTick
		lastTick = now
		state = casts[uid]
		if not state then
			return
		end
		data = data or self.ctx.Services.DataService:GetData(state.player)
		if not data then
			self:Cleanup(uid, false)
			return
		end

		if state.phase == "waiting" then
			if now >= state.waitUntil then
				self:StartBite(uid)
			end
		elseif state.phase == "reeling" then
			-- Anti-exploit: player must stay near their own bobber
			local character = state.player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not root then
				self:Cleanup(uid, false)
				return
			end
			if (root.Position - state.bobber.Position).Magnitude > Config.REEL_POSITION_RADIUS then
				self:Cleanup(uid, false)
				return
			end

			-- Simulate
			if state.holding then
				state.progress += state.progressRate * dt
				state.tension += state.tensionRate * dt
			else
				state.tension = math.max(0, state.tension - Config.TENSION_DECAY * dt)
			end

			if state.tension >= Config.TENSION_MAX then
				-- Line snapped
				Remotes:SendToClient(state.player, { type = "CatchResult", payload = { snapped = true } })
				self:Cleanup(uid, true)
				return
			end
			if state.progress >= Config.PROGRESS_MAX then
				self:ResolveCatch(uid)
				return
			end

			-- Push reel state (throttled)
			if now - state.lastSend >= Config.REEL_STATE_SEND then
				state.lastSend = now
				Remotes:SendToClient(state.player, {
					type = "ReelState",
					payload = {
						progress = state.progress,
						tension = state.tension,
						fishName = state.fishName,
						rarity = state.rarity,
					},
				})
			end
		end
	end
end

function FishingService:StartBite(uid: number)
	local state = casts[uid]
	if not state then
		return
	end
	local data = self.ctx.Services.DataService:GetData(state.player)
	if not data then
		return
	end
	local eventSvc = self.ctx.Services.EventService
	state.golden = eventSvc ~= nil and eventSvc:IsGoldenAt(state.bobber.Position) == true or false
	local roll = self:PickFish(state.zoneId, data, state.golden and Config.GOLDEN_SPOT_LUCK or 0)
	local def = FishCatalog.Get(roll.fishId)
	if not def then
		self:Cleanup(uid, false)
		return
	end
	local rod = RodCatalog.Get(data.equippedRod) :: Types.RodDef

	state.phase = "reeling"
	local world = self.ctx.Services.WorldInteractionsService
	if world and world.OnReelStart then
		world:OnReelStart(state.player)
	end
	state.fishId = def.id
	state.fishName = def.name
	state.rarity = def.rarity
	state.shiny = roll.shiny
	state.weight = roll.weight
	local idx = Config.RARITY_INDEX[def.rarity] or 1
	state.tensionRate = Config.TENSION_RISE_BASE * (1 + Config.TENSION_RISE_PER_RARITY * (idx - 1)) / rod.strength
	state.progressRate = Config.PROGRESS_RATE_BASE + Config.PROGRESS_RATE_PER_STRENGTH * rod.strength

	-- Old One teaser
	if def.id == "old_one" then
		Remotes:SendToClient(state.player, { type = "EventBanner", payload = { kind = "oldOne", text = "Something ancient takes the line..." } })
	end

	-- Bite!
	Remotes:SendToClient(state.player, {
		type = "Bite",
		payload = {
			strength = rod.strength,
			rarity = def.rarity,
			fishName = def.name,
		},
	})
end

-- ── Catch resolution ─────────────────────────────────────────────────────

function FishingService:ResolveCatch(uid: number)
	local state = casts[uid]
	if not state then
		return
	end
	local data = self.ctx.Services.DataService:GetData(state.player)
	if not data then
		self:Cleanup(uid, false)
		return
	end
	local def = FishCatalog.Get(state.fishId)
	if not def then
		self:Cleanup(uid, false)
		return
	end

	local eventService = self.ctx.Services.EventService
	local isNight = eventService and eventService:GetTimeOfDay() == "night" or false
	local isStorm = eventService and eventService:IsStorm() or false

	local outcome = self.ctx.Services.InventoryService:AddCatch(
		state.player,
		def,
		state.weight,
		state.shiny,
		isNight,
		isStorm,
		state.golden
	)

	-- Catch aura (cosmetic)
	local auraDef = data.cosmetics.aura and CosmeticsCatalog.Get(data.cosmetics.aura)
	if auraDef then
		local fx = Instance.new("Part")
		fx.Name = "CatchAura"
		fx.Anchored = true
		fx.CanCollide = false
		fx.CanQuery = false
		fx.Size = Vector3.new(0.5, 0.5, 0.5)
		fx.Transparency = 1
		fx.CFrame = state.bobber.CFrame
		fx.Parent = Workspace
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Rate = 40
		pe.Lifetime = NumberRange.new(0.5, 1.1)
		pe.Speed = NumberRange.new(2, 5)
		pe.Size = NumberSequence.new(0.3, 0.9)
		pe.Transparency = NumberSequence.new(0.2, 1)
		pe.Color = ColorSequence.new(auraDef.color)
		pe.Parent = fx
		task.delay(1.4, function()
			if fx and fx.Parent then
				fx:Destroy()
			end
		end)
	end

	-- Result to the catcher
	Remotes:SendToClient(state.player, {
		type = "CatchResult",
		payload = {
			snapped = false,
			fishId = def.id,
			name = def.name,
			rarity = def.rarity,
			weight = state.weight,
			shiny = state.shiny,
			value = outcome and outcome.value or 0,
			coins = outcome and outcome.coins or 0,
			xp = outcome and outcome.xp or 0,
			pearls = outcome and outcome.pearls or 0,
			autoSold = outcome and outcome.autoSold or false,
			overflowSold = outcome and outcome.overflowSold or false,
			zonePct = outcome and outcome.zonePct or 0,
			golden = state.golden,
		},
	})

	-- Feed + announcements (virality layer)
	local idx = Config.RARITY_INDEX[def.rarity] or 1
	if state.shiny or idx >= 6 then
		Remotes:SendToAll({
			type = "FeedMessage",
			payload = {
				kind = "announce",
				text = state.player.Name .. " caught " .. (state.shiny and "a SHINY " or "a MYTHIC ") .. def.name .. " — " .. state.weight .. "kg!",
			},
		})
	elseif idx >= 4 then
		Remotes:SendToAll({
			type = "FeedMessage",
			payload = {
				kind = "chat",
				text = state.player.Name .. " caught a " .. def.name .. " (" .. state.weight .. "kg)",
			},
		})
	end

	self:Cleanup(uid, true)
end

-- ── Reel input (client intents) ──────────────────────────────────────────

function FishingService:HandleReelHold(player: Player, payload: any)
	local state = casts[player.UserId]
	if not state or state.phase ~= "reeling" then
		return
	end
	state.holding = payload and payload.held == true
end

function FishingService:HandleAutoReel(player: Player)
	local state = casts[player.UserId]
	local data = self.ctx.Services.DataService:GetData(player)
	if not state or state.phase ~= "reeling" or not data then
		return
	end
	if data.flags.tokens <= 0 then
		return
	end
	data.flags.tokens -= 1
	self.ctx.Services.DataService:MarkDirty(player)
	self:ResolveCatch(player.UserId)
end

-- ── Rod tool (visible fishing rod) ───────────────────────────────────────

function FishingService:UpdateRodColor(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	local character = player.Character
	if not data or not character then
		return
	end
	local tool = character:FindFirstChild("FishingRod")
	local handle = tool and tool:FindFirstChild("Handle") :: BasePart?
	if not handle then
		return
	end
	local rod = RodCatalog.Get(data.equippedRod)
	local color = rod and rod.color or Color3.fromRGB(150, 110, 70)
	local skin = data.cosmetics.rodSkin and CosmeticsCatalog.Get(data.cosmetics.rodSkin)
	if skin then
		color = skin.color
	end
	handle.Color = color
end

function FishingService:EnsureRodTool(player: Player)
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not humanoid then
		return
	end
	local existing = character:FindFirstChild("FishingRod")
	if existing then
		self:UpdateRodColor(player)
		return
	end
	local tool = Instance.new("Tool")
	tool.Name = "FishingRod"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.45, 6.5, 0.45)
	handle.Material = Enum.Material.Wood
	handle.Color = Color3.fromRGB(150, 110, 70)
	handle.Shape = Enum.PartType.Cylinder
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	tool.Parent = character
	task.wait(0.1)
	pcall(function()
		humanoid:EquipTool(tool)
	end)
	self:UpdateRodColor(player)
end

-- ── Cleanup ──────────────────────────────────────────────────────────────

function FishingService:Cleanup(uid: number, destroyBobber: boolean)
	local state = casts[uid]
	if not state then
		return
	end
	if destroyBobber and state.bobber then
		state.bobber:Destroy()
	end
	casts[uid] = nil
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function FishingService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.Cast = function(player, payload)
		self:HandleCast(player, payload)
	end
	ctx.MessageHandlers.ReelHold = function(player, payload)
		self:HandleReelHold(player, payload)
	end
	ctx.MessageHandlers.AutoReel = function(player, _payload)
		self:HandleAutoReel(player)
	end
end

function FishingService:Start()
	self:RefreshRegions()
	-- Keep region cache fresh if the builder edits live
	Workspace.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") and string.sub(desc.Name, 1, 11) == "ZoneRegion_" then
			self:RefreshRegions()
		end
	end)
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(_character)
			self:EnsureRodTool(player)
		end)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			task.spawn(function()
				task.wait(0.5)
				self:EnsureRodTool(player)
			end)
		end
	end
	Players.PlayerRemoving:Connect(function(player)
		self:Cleanup(player.UserId, true)
	end)
	if not warnedRegions then
		local count = 0
		for _, region  in pairs(zoneRegions) do
			if region then
				count += 1
			end
		end
		if count < 6 then
			warn("[Fishing] Only " .. count .. " zone regions found. Place ZoneRegion_<zone> parts in Workspace (see src/README.md).")
		end
	end
end

function FishingService:Stop()
	for uid, state  in pairs(casts) do
		self:Cleanup(uid, true)
	end
end

return FishingService
]==]
	print('[Installer] Wrote ServerScriptService/Services/FishingService')
end

-- ServerScriptService/Services/WorldInteractionsService
local inst = ensure('ServerScriptService/Services/WorldInteractionsService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — WorldInteractionsService
	Makes the world ALIVE: proximity prompts + clickable interactables.
	- Old Salt (tutorial NPC): guided first-catch dialog → quest line
	- Market stall: opens the shop panel
	- Sign: opens the travel (map) panel
	- Crate: free daily pearl? no — free starter bait once
	- Old Salt dialog uses REAL guided steps (server-driven, no UI hacking)
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldInteractionsService = {}
WorldInteractionsService.Name = "WorldInteractionsService"

-- Old Salt guided tutorial steps (server-driven)
local GUIDE_STEPS = {
	{ prompt = "Grab the starter rod and cast it! Hold Q (or tap CAST) to charge, release to throw.", waitFor = "firstCast" },
	{ prompt = "When the bobber splashes — HOLD to reel it in! Release to rest the tension.", waitFor = "firstReel" },
	{ prompt = "Nice catch! Open your BAG (top-right) and Sell it, or keep it for the bestiary.", waitFor = "firstCatch" },
	{ prompt = "Open the SHOP (top-right) and grab the River Oak Rod — your first upgrade!", waitFor = "firstBuy" },
	{ prompt = "Check the QUESTS tab every day for rewards — and race the storms for rare fish!", waitFor = "done" },
}

function WorldInteractionsService:GetGuideStep(data: any): number
	local flags = data.flags
	if not flags.tutorialDone then
		if not flags.guideFirstCast then
			return 1
		elseif not flags.guideFirstReel then
			return 2
		elseif not flags.guideFirstCatch then
			return 3
		elseif not flags.guideFirstBuy then
			return 4
		else
			return 5
		end
	end
	return 0
end

function WorldInteractionsService:SendGuide(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local step = self:GetGuideStep(data)
	if step == 0 then
		Remotes:SendToClient(player, {
			type = "GuideUpdate",
			payload = { active = false, text = "" },
		})
		return
	end
	Remotes:SendToClient(player, {
		type = "GuideUpdate",
		payload = { active = true, text = GUIDE_STEPS[step].prompt, step = step },
	})
end

-- Called by other services when the player does the guided action
function WorldInteractionsService:OnCast(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCast then
		data.flags.guideFirstCast = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnReelStart(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstReel then
		data.flags.guideFirstReel = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstCatch(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCatch then
		data.flags.guideFirstCatch = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstBuy(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstBuy then
		data.flags.guideFirstBuy = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnGuideDone(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data then
		data.flags.tutorialDone = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

-- World interactables (ProximityPrompts) — called by FishingService/Bootstrap after map build
local PROMPTS = {
	{
		partName = "OldSaltBody",
		promptName = "TalkToOldSalt",
		text = "Talk to Old Salt",
		action = "talk",
	},
	{
		partName = "StallTable",
		promptName = "OpenShop",
		text = "Open Shop",
		action = "shop",
	},
	{
		partName = "SignBoard",
		promptName = "OpenMap",
		text = "Open Map",
		action = "travel",
	},
	{
		partName = "ChestBase",
		promptName = "OpenChest",
		text = "Open the Sunken Chest",
		action = "chest",
		chestKey = "abyss",
	},
	{
		partName = "IsleChest",
		promptName = "OpenIsleChest",
		text = "Open the Isle Chest",
		action = "chest",
		chestKey = "isle",
	},
	{
		partName = "GrottoChest",
		promptName = "OpenGrottoChest",
		text = "Open the Grotto Chest",
		action = "chest",
		chestKey = "grotto",
	},
}

function WorldInteractionsService:SetupPrompts()
	task.spawn(function()
		task.wait(2)
		for _, def in ipairs(PROMPTS) do
			local part = Workspace:FindFirstChild(def.partName) :: BasePart?
			if part then
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = def.promptName
				prompt.ActionText = def.text
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.ObjectText = def.partName
				prompt.Parent = part
				prompt.Triggered:Connect(function(player)
					self:OnPrompt(player, def.action, def.chestKey)
				end)
			end
		end
	end)
end

function WorldInteractionsService:OnPrompt(player: Player, action: string, chestKey: string?)
	if action == "talk" then
		self:SendGuide(player)
	elseif action == "shop" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "shop" } })
	elseif action == "travel" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "travel" } })
	elseif action == "chest" and chestKey then
		self:OpenChest(player, chestKey)
	end
end

-- Secret chests: one-time pearl reward per account (world collectibles)
function WorldInteractionsService:OpenChest(player: Player, chestKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if data.flags.chestsClaimed[chestKey] then
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "chestEmpty", text = "This chest is empty — you already claimed it!" },
		})
		return
	end
	data.flags.chestsClaimed[chestKey] = true
	local pearls = chestKey == "abyss" and 15 or 10
	self.ctx.Services.EconomyService:AddPearls(player, pearls, "chest:" .. chestKey)
	Remotes:SendToClient(player, {
		type = "EventBanner",
		payload = { kind = "chest", text = "💎 You found " .. pearls .. " pearls in the chest!" },
	})
end

function WorldInteractionsService:Init(ctx)
	self.ctx = ctx
end

function WorldInteractionsService:Start()
	self:SetupPrompts()
end

function WorldInteractionsService:Stop()
end

return WorldInteractionsService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — WorldInteractionsService
	Makes the world ALIVE: proximity prompts + clickable interactables.
	- Old Salt (tutorial NPC): guided first-catch dialog → quest line
	- Market stall: opens the shop panel
	- Sign: opens the travel (map) panel
	- Crate: free daily pearl? no — free starter bait once
	- Old Salt dialog uses REAL guided steps (server-driven, no UI hacking)
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldInteractionsService = {}
WorldInteractionsService.Name = "WorldInteractionsService"

-- Old Salt guided tutorial steps (server-driven)
local GUIDE_STEPS = {
	{ prompt = "Grab the starter rod and cast it! Hold Q (or tap CAST) to charge, release to throw.", waitFor = "firstCast" },
	{ prompt = "When the bobber splashes — HOLD to reel it in! Release to rest the tension.", waitFor = "firstReel" },
	{ prompt = "Nice catch! Open your BAG (top-right) and Sell it, or keep it for the bestiary.", waitFor = "firstCatch" },
	{ prompt = "Open the SHOP (top-right) and grab the River Oak Rod — your first upgrade!", waitFor = "firstBuy" },
	{ prompt = "Check the QUESTS tab every day for rewards — and race the storms for rare fish!", waitFor = "done" },
}

function WorldInteractionsService:GetGuideStep(data: any): number
	local flags = data.flags
	if not flags.tutorialDone then
		if not flags.guideFirstCast then
			return 1
		elseif not flags.guideFirstReel then
			return 2
		elseif not flags.guideFirstCatch then
			return 3
		elseif not flags.guideFirstBuy then
			return 4
		else
			return 5
		end
	end
	return 0
end

function WorldInteractionsService:SendGuide(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local step = self:GetGuideStep(data)
	if step == 0 then
		Remotes:SendToClient(player, {
			type = "GuideUpdate",
			payload = { active = false, text = "" },
		})
		return
	end
	Remotes:SendToClient(player, {
		type = "GuideUpdate",
		payload = { active = true, text = GUIDE_STEPS[step].prompt, step = step },
	})
end

-- Called by other services when the player does the guided action
function WorldInteractionsService:OnCast(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCast then
		data.flags.guideFirstCast = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnReelStart(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstReel then
		data.flags.guideFirstReel = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstCatch(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCatch then
		data.flags.guideFirstCatch = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstBuy(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstBuy then
		data.flags.guideFirstBuy = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnGuideDone(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data then
		data.flags.tutorialDone = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

-- World interactables (ProximityPrompts) — called by FishingService/Bootstrap after map build
local PROMPTS = {
	{
		partName = "OldSaltBody",
		promptName = "TalkToOldSalt",
		text = "Talk to Old Salt",
		action = "talk",
	},
	{
		partName = "StallTable",
		promptName = "OpenShop",
		text = "Open Shop",
		action = "shop",
	},
	{
		partName = "SignBoard",
		promptName = "OpenMap",
		text = "Open Map",
		action = "travel",
	},
	{
		partName = "ChestBase",
		promptName = "OpenChest",
		text = "Open the Sunken Chest",
		action = "chest",
		chestKey = "abyss",
	},
	{
		partName = "IsleChest",
		promptName = "OpenIsleChest",
		text = "Open the Isle Chest",
		action = "chest",
		chestKey = "isle",
	},
	{
		partName = "GrottoChest",
		promptName = "OpenGrottoChest",
		text = "Open the Grotto Chest",
		action = "chest",
		chestKey = "grotto",
	},
}

function WorldInteractionsService:SetupPrompts()
	task.spawn(function()
		task.wait(2)
		for _, def in ipairs(PROMPTS) do
			local part = Workspace:FindFirstChild(def.partName) :: BasePart?
			if part then
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = def.promptName
				prompt.ActionText = def.text
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.ObjectText = def.partName
				prompt.Parent = part
				prompt.Triggered:Connect(function(player)
					self:OnPrompt(player, def.action, def.chestKey)
				end)
			end
		end
	end)
end

function WorldInteractionsService:OnPrompt(player: Player, action: string, chestKey: string?)
	if action == "talk" then
		self:SendGuide(player)
	elseif action == "shop" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "shop" } })
	elseif action == "travel" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "travel" } })
	elseif action == "chest" and chestKey then
		self:OpenChest(player, chestKey)
	end
end

-- Secret chests: one-time pearl reward per account (world collectibles)
function WorldInteractionsService:OpenChest(player: Player, chestKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if data.flags.chestsClaimed[chestKey] then
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "chestEmpty", text = "This chest is empty — you already claimed it!" },
		})
		return
	end
	data.flags.chestsClaimed[chestKey] = true
	local pearls = chestKey == "abyss" and 15 or 10
	self.ctx.Services.EconomyService:AddPearls(player, pearls, "chest:" .. chestKey)
	Remotes:SendToClient(player, {
		type = "EventBanner",
		payload = { kind = "chest", text = "💎 You found " .. pearls .. " pearls in the chest!" },
	})
end

function WorldInteractionsService:Init(ctx)
	self.ctx = ctx
end

function WorldInteractionsService:Start()
	self:SetupPrompts()
end

function WorldInteractionsService:Stop()
end

return WorldInteractionsService
]==]
	print('[Installer] Wrote ServerScriptService/Services/WorldInteractionsService')
end

-- ServerScriptService/Services/AutoTerrainService
local inst = ensure('ServerScriptService/Services/AutoTerrainService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — AutoTerrainService
	Builds REAL terrain at server start (runtime FillBlock — works in Studio AND
	live servers, survives every publish). No Studio sculpting needed.
	- Sunshall: bay for the dock, flat village plateau, hills, beach ring.
	- 7 zone islands (shallow lagoon, cliff ring, volcano, ice, trench, hidden isles).
	- Deterministic noise so every server looks identical.
	Toggle with Config.AUTO_TERRAIN. Skips work if terrain already has cells.
	Phase 5 | AI-assisted | 2026-08-03
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local AutoTerrainService = {}
AutoTerrainService.Name = "AutoTerrainService"

local CELL = 6 -- column size (studs). 6 = good detail, fast enough at boot.
local terrain = Workspace:FindFirstChildOfClass("Terrain")

-- Deterministic pseudo-noise (value noise via sines — cheap + stable)
local function noise2(x: number, z: number): number
	return math.sin(x * 0.045 + z * 0.017) * 1.1
		+ math.sin((x + z * 0.6) * 0.023) * 0.9
		+ math.sin((x * 0.9 - z * 0.5) * 0.031) * 0.5
end

-- Island profile function: returns height (>=0) at local (lx, lz)
-- 0 means water (no terrain cell).
local function sunshallHeight(lx: number, lz: number): number
	-- lx/lz relative to island center (0,150), rotated so +lz = south (beach/village)
	-- Bay: south-center indentation for the dock
	if math.abs(lx) <= 48 and lz <= -40 then
		return 0.05
	end
	-- Village plateau
	if math.abs(lx) <= 76 and lz >= -40 and lz <= 52 then
		return 0.9 + noise2(lx, lz) * 0.25
	end
	-- Ramp bay -> plateau
	if math.abs(lx) <= 76 and lz > -46 and lz < -40 then
		return 0.05 + (lz + 46) / 6 * 0.85
	end
	-- South beach + hill rise
	if lz > 52 then
		return 0.9 + (lz - 52) / 95 * 8.5 + noise2(lx, lz) * 1.2
	end
	-- North (behind village) + side hills
	local edge = math.max(math.abs(lx) - 76, 0)
	return 0.9 + edge / 70 * 7 + math.max(-lz, 0) / 100 * 5 + noise2(lx, lz) * 1.0
end

local function genericIslandHeight(lx: number, lz: number, radius: number, maxH: number, profile: string): number
	local d = math.sqrt(lx * lx + lz * lz)
	if d > radius then
		return 0
	end
	local t = 1 - d / radius
	local n = noise2(lx, lz) * 1.2
	if profile == "lagoon" then
		-- shallow sandbars
		return math.max(0.05, t * 2.6 + n * 0.8)
	elseif profile == "cliffs" then
		-- horseshoe ring of cliffs around a deep basin (open to the north)
		if lz < -radius * 0.2 then
			return 0.05 -- basin mouth
		end
		local ring = math.abs(1 - d / (radius * 0.62))
		return math.max(0.05, ring * 14 + n * 1.5)
	elseif profile == "volcano" then
		-- cone with crater
		local h = t * 13
		if d < radius * 0.18 then
			h = 10.5 -- crater floor
		end
		return math.max(0.05, h + n * 0.8)
	elseif profile == "ice" then
		return math.max(0.05, t * 3.2 + n * 0.7)
	elseif profile == "trench" then
		return 0.05 -- near-flat abyssal floor (the pillars/wreck are parts)
	else
		return math.max(0.05, t * maxH + n * 0.8)
	end
end

local function buildIsland(cx: number, cz: number, radius: number, profileFn: (number, number) -> number, materialFn: (number) -> Enum.Material)
	local cells = 0
	local half = CELL / 2
	for gx = cx - radius, cx + radius, CELL do
		for gz = cz - radius, cz + radius, CELL do
			local h = profileFn(gx - cx, gz - cz)
			if h > 0.06 then
				local region = Region3.new(
					Vector3.new(gx - half, -4, gz - half),
					Vector3.new(gx + half, h, gz + half)
				)
				terrain:FillBlock(region, materialFn(h), Enum.OrientationAxis.Y)
				cells += 1
			end
		end
		if cells % 400 == 0 then
			task.wait() -- yield so the server stays responsive
		end
	end
	return cells
end

function AutoTerrainService:BuildWorld()
	if not Config.AUTO_TERRAIN or not terrain then
		return
	end

	-- Deterministic: rebuild every boot. If you hand-sculpt terrain in Studio,
	-- set Config.AUTO_TERRAIN = false to keep yours.
	print("[AutoTerrain] Building Sunshall (spawn island)...")
	buildIsland(0, 150, 140, sunshallHeight, function(h)
		if h < 1.2 then return Enum.Material.Sand end
		if h < 4.5 then return Enum.Material.Grass end
		return Enum.Material.Rock
	end)
	-- (smoothing optional; noise already soft)

	print("[AutoTerrain] Building zone islands...")
	buildIsland(0, -1000, 64, function(lx, lz) return genericIslandHeight(lx, lz, 64, 2.6, "lagoon") end, function(h)
		return Enum.Material.Sand
	end)
	buildIsland(0, -2000, 68, function(lx, lz) return genericIslandHeight(lx, lz, 68, 14, "cliffs") end, function(h)
		if h < 1 then return Enum.Material.Sand end
		return Enum.Material.Slate
	end)
	buildIsland(0, -3000, 64, function(lx, lz) return genericIslandHeight(lx, lz, 64, 13, "volcano") end, function(h)
		return Enum.Material.Basalt
	end)
	buildIsland(0, -4000, 64, function(lx, lz) return genericIslandHeight(lx, lz, 64, 3.2, "ice") end, function(h)
		if h < 1 then return Enum.Material.Sand end
		return Enum.Material.Snow
	end)
	buildIsland(0, -5000, 60, function(lx, lz) return genericIslandHeight(lx, lz, 60, 2, "trench") end, function(h)
		return Enum.Material.Rock
	end)
	buildIsland(800, -3000, 44, function(lx, lz) return genericIslandHeight(lx, lz, 44, 3, "island") end, function(h)
		if h < 1 then return Enum.Material.Sand end
		return Enum.Material.Grass
	end)
	buildIsland(800, -2000, 44, function(lx, lz) return genericIslandHeight(lx, lz, 44, 3, "island") end, function(h)
		return Enum.Material.Slate
	end)

	print("[AutoTerrain] World terrain complete ✅")
end

function AutoTerrainService:Init(ctx)
	self.ctx = ctx
end

function AutoTerrainService:Start()
	task.spawn(function()
		task.wait(1) -- let other services boot first
		self:BuildWorld()
	end)
end

function AutoTerrainService:Stop()
end

return AutoTerrainService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — AutoTerrainService
	Builds REAL terrain at server start (runtime FillBlock — works in Studio AND
	live servers, survives every publish). No Studio sculpting needed.
	- Sunshall: bay for the dock, flat village plateau, hills, beach ring.
	- 7 zone islands (shallow lagoon, cliff ring, volcano, ice, trench, hidden isles).
	- Deterministic noise so every server looks identical.
	Toggle with Config.AUTO_TERRAIN. Skips work if terrain already has cells.
	Phase 5 | AI-assisted | 2026-08-03
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local AutoTerrainService = {}
AutoTerrainService.Name = "AutoTerrainService"

local CELL = 6 -- column size (studs). 6 = good detail, fast enough at boot.
local terrain = Workspace:FindFirstChildOfClass("Terrain")

-- Deterministic pseudo-noise (value noise via sines — cheap + stable)
local function noise2(x: number, z: number): number
	return math.sin(x * 0.045 + z * 0.017) * 1.1
		+ math.sin((x + z * 0.6) * 0.023) * 0.9
		+ math.sin((x * 0.9 - z * 0.5) * 0.031) * 0.5
end

-- Island profile function: returns height (>=0) at local (lx, lz)
-- 0 means water (no terrain cell).
local function sunshallHeight(lx: number, lz: number): number
	-- lx/lz relative to island center (0,150), rotated so +lz = south (beach/village)
	-- Bay: south-center indentation for the dock
	if math.abs(lx) <= 48 and lz <= -40 then
		return 0.05
	end
	-- Village plateau
	if math.abs(lx) <= 76 and lz >= -40 and lz <= 52 then
		return 0.9 + noise2(lx, lz) * 0.25
	end
	-- Ramp bay -> plateau
	if math.abs(lx) <= 76 and lz > -46 and lz < -40 then
		return 0.05 + (lz + 46) / 6 * 0.85
	end
	-- South beach + hill rise
	if lz > 52 then
		return 0.9 + (lz - 52) / 95 * 8.5 + noise2(lx, lz) * 1.2
	end
	-- North (behind village) + side hills
	local edge = math.max(math.abs(lx) - 76, 0)
	return 0.9 + edge / 70 * 7 + math.max(-lz, 0) / 100 * 5 + noise2(lx, lz) * 1.0
end

local function genericIslandHeight(lx: number, lz: number, radius: number, maxH: number, profile: string): number
	local d = math.sqrt(lx * lx + lz * lz)
	if d > radius then
		return 0
	end
	local t = 1 - d / radius
	local n = noise2(lx, lz) * 1.2
	if profile == "lagoon" then
		-- shallow sandbars
		return math.max(0.05, t * 2.6 + n * 0.8)
	elseif profile == "cliffs" then
		-- horseshoe ring of cliffs around a deep basin (open to the north)
		if lz < -radius * 0.2 then
			return 0.05 -- basin mouth
		end
		local ring = math.abs(1 - d / (radius * 0.62))
		return math.max(0.05, ring * 14 + n * 1.5)
	elseif profile == "volcano" then
		-- cone with crater
		local h = t * 13
		if d < radius * 0.18 then
			h = 10.5 -- crater floor
		end
		return math.max(0.05, h + n * 0.8)
	elseif profile == "ice" then
		return math.max(0.05, t * 3.2 + n * 0.7)
	elseif profile == "trench" then
		return 0.05 -- near-flat abyssal floor (the pillars/wreck are parts)
	else
		return math.max(0.05, t * maxH + n * 0.8)
	end
end

local function buildIsland(cx: number, cz: number, radius: number, profileFn: (number, number) -> number, materialFn: (number) -> Enum.Material)
	local cells = 0
	local half = CELL / 2
	for gx = cx - radius, cx + radius, CELL do
		for gz = cz - radius, cz + radius, CELL do
			local h = profileFn(gx - cx, gz - cz)
			if h > 0.06 then
				local region = Region3.new(
					Vector3.new(gx - half, -4, gz - half),
					Vector3.new(gx + half, h, gz + half)
				)
				terrain:FillBlock(region, materialFn(h), Enum.OrientationAxis.Y)
				cells += 1
			end
		end
		if cells % 400 == 0 then
			task.wait() -- yield so the server stays responsive
		end
	end
	return cells
end

function AutoTerrainService:BuildWorld()
	if not Config.AUTO_TERRAIN or not terrain then
		return
	end

	-- Deterministic: rebuild every boot. If you hand-sculpt terrain in Studio,
	-- set Config.AUTO_TERRAIN = false to keep yours.
	print("[AutoTerrain] Building Sunshall (spawn island)...")
	buildIsland(0, 150, 140, sunshallHeight, function(h)
		if h < 1.2 then return Enum.Material.Sand end
		if h < 4.5 then return Enum.Material.Grass end
		return Enum.Material.Rock
	end)
	-- (smoothing optional; noise already soft)

	print("[AutoTerrain] Building zone islands...")
	buildIsland(0, -1000, 64, function(lx, lz) return genericIslandHeight(lx, lz, 64, 2.6, "lagoon") end, function(h)
		return Enum.Material.Sand
	end)
	buildIsland(0, -2000, 68, function(lx, lz) return genericIslandHeight(lx, lz, 68, 14, "cliffs") end, function(h)
		if h < 1 then return Enum.Material.Sand end
		return Enum.Material.Slate
	end)
	buildIsland(0, -3000, 64, function(lx, lz) return genericIslandHeight(lx, lz, 64, 13, "volcano") end, function(h)
		return Enum.Material.Basalt
	end)
	buildIsland(0, -4000, 64, function(lx, lz) return genericIslandHeight(lx, lz, 64, 3.2, "ice") end, function(h)
		if h < 1 then return Enum.Material.Sand end
		return Enum.Material.Snow
	end)
	buildIsland(0, -5000, 60, function(lx, lz) return genericIslandHeight(lx, lz, 60, 2, "trench") end, function(h)
		return Enum.Material.Rock
	end)
	buildIsland(800, -3000, 44, function(lx, lz) return genericIslandHeight(lx, lz, 44, 3, "island") end, function(h)
		if h < 1 then return Enum.Material.Sand end
		return Enum.Material.Grass
	end)
	buildIsland(800, -2000, 44, function(lx, lz) return genericIslandHeight(lx, lz, 44, 3, "island") end, function(h)
		return Enum.Material.Slate
	end)

	print("[AutoTerrain] World terrain complete ✅")
end

function AutoTerrainService:Init(ctx)
	self.ctx = ctx
end

function AutoTerrainService:Start()
	task.spawn(function()
		task.wait(1) -- let other services boot first
		self:BuildWorld()
	end)
end

function AutoTerrainService:Stop()
end

return AutoTerrainService
]==]
	print('[Installer] Wrote ServerScriptService/Services/AutoTerrainService')
end

-- ServerScriptService/Bootstrap
local inst = ensure('ServerScriptService/Bootstrap', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Bootstrap (server)
	Service lifecycle manager + message router.
	1. Require all services. 2. Init all. 3. Start all. 4. Route client messages.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local ctx = {
	Services = {},
	MessageHandlers = {},
}

-- Dependency order: security → data → economy → inventory → quests → events → leaderboards → fishing → shop
local ORDER = {
	"SecurityService",
	"DataService",
	"EconomyService",
	"InventoryService",
	"QuestService",
	"EventService",
	"LeaderboardService",
	"WorldInteractionsService",
	"AutoTerrainService",
	"FishingService",
	"TravelService",
	"AmbienceService",
	"ShopService",
}

-- Load
for _, name in pairs(ORDER) do
	local ok, module = pcall(function()
		return require(script.Parent.Services[name])
	end)
	if not ok then
		warn("[Bootstrap] Failed to require " .. name .. ": " .. tostring(module))
		continue
	end
	ctx.Services[name] = module
end

-- Init
for _, name  in pairs(ORDER) do
	local service = ctx.Services[name]
	if service and service.Init then
		service:Init(ctx)
	end
end

-- Start
for _, name  in pairs(ORDER) do
	local service = ctx.Services[name]
	if service and service.Start then
		service:Start()
	end
end

-- ── Message router ───────────────────────────────────────────────────────

Remotes:OnServerMessage(function(player: Player, message: any)
	local security = ctx.Services.SecurityService
	local ok, reason = security:ValidateMessage(message)
	if not ok then
		security:Flag(player, reason or "invalid message")
		return
	end
	if not security:CheckRate(player, message.type) then
		return
	end
	local handler = ctx.MessageHandlers[message.type]
	if not handler then
		return
	end
	local runOk, err = pcall(handler, player, message.payload)
	if not runOk then
		warn("[Bootstrap] Handler error (" .. message.type .. ") for " .. player.Name .. ": " .. tostring(err))
	end
end)

-- Full state snapshot request (client calls after UI init)
ctx.MessageHandlers.GuideDone = function(player: Player)
	local world = ctx.Services.WorldInteractionsService
	if world and world.OnGuideDone then
		world:OnGuideDone(player)
	end
end

ctx.MessageHandlers.SyncRequest = function(player: Player)
	local data = ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	ctx.Services.EconomyService:Sync(player)
	ctx.Services.InventoryService:SendInventory(player)
	ctx.Services.QuestService:SendQuestUpdate(player)
	Remotes:SendToClient(player, { type = "WorldState", payload = ctx.Services.EventService:GetWorldState() })
end

-- Initial snapshot on profile ready (covers players joining after boot)
ctx.Services.DataService:OnProfileReady(function(player: Player, _data: any)
	task.wait(0.2)
	ctx.Services.EconomyService:Sync(player)
	ctx.Services.InventoryService:SendInventory(player)
	ctx.Services.QuestService:SendQuestUpdate(player)
	Remotes:SendToClient(player, { type = "WorldState", payload = ctx.Services.EventService:GetWorldState() })
	local world = ctx.Services.WorldInteractionsService
	if world and world.SendGuide then
		world:SendGuide(player)
	end
end)

-- Graceful shutdown: save everything
game:BindToClose(function()
	for i = #ORDER, 1, -1 do
		local service = ctx.Services[ORDER[i]]
		if service and service.Stop then
			pcall(service.Stop, service)
		end
	end
end)

print("[Tidebound] Server booted. Services: " .. table.concat(ORDER, ", "))

-- ── BOOT BEACON (diagnostic: proves server code runs in the live game) ──
-- 1) Analytics counter -> visible in Creator Dashboard > Analytics
local AnalyticsService = game:GetService("AnalyticsService")
pcall(function()
	AnalyticsService:ReportCounter("TideboundServerBoot", 1)
end)
-- 2) Floating sign above spawn -> visible to every player in-world
task.delay(4, function()
	local beacon = Instance.new("Part")
	beacon.Name = "BootBeacon"
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.CanQuery = false
	beacon.CanTouch = false
	beacon.Size = Vector3.new(1, 1, 1)
	beacon.Transparency = 1
	beacon.CFrame = CFrame.new(0, 14, 66)
	beacon.Parent = Workspace
	local bg = Instance.new("BillboardGui")
	bg.Name = "BeaconGUI"
	bg.Size = UDim2.new(0, 600, 0, 120)
	bg.AlwaysOnTop = true
	bg.Parent = beacon
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = "TIDEBOUND ONLINE — v14\n(server scripts running)"
	lbl.TextColor3 = Color3.fromRGB(90, 220, 170)
	lbl.TextSize = 32
	lbl.Font = Enum.Font.GothamBold
	lbl.TextStrokeTransparency = 0
	lbl.Parent = bg
end)
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Bootstrap (server)
	Service lifecycle manager + message router.
	1. Require all services. 2. Init all. 3. Start all. 4. Route client messages.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local ctx = {
	Services = {},
	MessageHandlers = {},
}

-- Dependency order: security → data → economy → inventory → quests → events → leaderboards → fishing → shop
local ORDER = {
	"SecurityService",
	"DataService",
	"EconomyService",
	"InventoryService",
	"QuestService",
	"EventService",
	"LeaderboardService",
	"WorldInteractionsService",
	"AutoTerrainService",
	"FishingService",
	"TravelService",
	"AmbienceService",
	"ShopService",
}

-- Load
for _, name in pairs(ORDER) do
	local ok, module = pcall(function()
		return require(script.Parent.Services[name])
	end)
	if not ok then
		warn("[Bootstrap] Failed to require " .. name .. ": " .. tostring(module))
		continue
	end
	ctx.Services[name] = module
end

-- Init
for _, name  in pairs(ORDER) do
	local service = ctx.Services[name]
	if service and service.Init then
		service:Init(ctx)
	end
end

-- Start
for _, name  in pairs(ORDER) do
	local service = ctx.Services[name]
	if service and service.Start then
		service:Start()
	end
end

-- ── Message router ───────────────────────────────────────────────────────

Remotes:OnServerMessage(function(player: Player, message: any)
	local security = ctx.Services.SecurityService
	local ok, reason = security:ValidateMessage(message)
	if not ok then
		security:Flag(player, reason or "invalid message")
		return
	end
	if not security:CheckRate(player, message.type) then
		return
	end
	local handler = ctx.MessageHandlers[message.type]
	if not handler then
		return
	end
	local runOk, err = pcall(handler, player, message.payload)
	if not runOk then
		warn("[Bootstrap] Handler error (" .. message.type .. ") for " .. player.Name .. ": " .. tostring(err))
	end
end)

-- Full state snapshot request (client calls after UI init)
ctx.MessageHandlers.GuideDone = function(player: Player)
	local world = ctx.Services.WorldInteractionsService
	if world and world.OnGuideDone then
		world:OnGuideDone(player)
	end
end

ctx.MessageHandlers.SyncRequest = function(player: Player)
	local data = ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	ctx.Services.EconomyService:Sync(player)
	ctx.Services.InventoryService:SendInventory(player)
	ctx.Services.QuestService:SendQuestUpdate(player)
	Remotes:SendToClient(player, { type = "WorldState", payload = ctx.Services.EventService:GetWorldState() })
end

-- Initial snapshot on profile ready (covers players joining after boot)
ctx.Services.DataService:OnProfileReady(function(player: Player, _data: any)
	task.wait(0.2)
	ctx.Services.EconomyService:Sync(player)
	ctx.Services.InventoryService:SendInventory(player)
	ctx.Services.QuestService:SendQuestUpdate(player)
	Remotes:SendToClient(player, { type = "WorldState", payload = ctx.Services.EventService:GetWorldState() })
	local world = ctx.Services.WorldInteractionsService
	if world and world.SendGuide then
		world:SendGuide(player)
	end
end)

-- Graceful shutdown: save everything
game:BindToClose(function()
	for i = #ORDER, 1, -1 do
		local service = ctx.Services[ORDER[i]]
		if service and service.Stop then
			pcall(service.Stop, service)
		end
	end
end)

print("[Tidebound] Server booted. Services: " .. table.concat(ORDER, ", "))

-- ── BOOT BEACON (diagnostic: proves server code runs in the live game) ──
-- 1) Analytics counter -> visible in Creator Dashboard > Analytics
local AnalyticsService = game:GetService("AnalyticsService")
pcall(function()
	AnalyticsService:ReportCounter("TideboundServerBoot", 1)
end)
-- 2) Floating sign above spawn -> visible to every player in-world
task.delay(4, function()
	local beacon = Instance.new("Part")
	beacon.Name = "BootBeacon"
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.CanQuery = false
	beacon.CanTouch = false
	beacon.Size = Vector3.new(1, 1, 1)
	beacon.Transparency = 1
	beacon.CFrame = CFrame.new(0, 14, 66)
	beacon.Parent = Workspace
	local bg = Instance.new("BillboardGui")
	bg.Name = "BeaconGUI"
	bg.Size = UDim2.new(0, 600, 0, 120)
	bg.AlwaysOnTop = true
	bg.Parent = beacon
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = "TIDEBOUND ONLINE — v14\n(server scripts running)"
	lbl.TextColor3 = Color3.fromRGB(90, 220, 170)
	lbl.TextSize = 32
	lbl.Font = Enum.Font.GothamBold
	lbl.TextStrokeTransparency = 0
	lbl.Parent = bg
end)
]==]
	print('[Installer] Wrote ServerScriptService/Bootstrap')
end

-- StarterPlayer/StarterPlayerScripts/Bootstrap
local inst = ensure('StarterPlayer/StarterPlayerScripts/Bootstrap', 'LocalScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Bootstrap (client, LocalScript)
	Client service loader + message dispatcher.
	Every server message is applied to ClientState, then fanned out to all
	controllers that registered a handler for its type.
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ClientState = require(script.Parent.Modules.ClientState)

local ctx = {
	Services = {},
	Handlers = {},
}

-- Controllers call this with dot syntax: ctx.RegisterHandler("Type", fn).
-- Attached AFTER the table is declared (Luau forbids a local referencing
-- itself inside its own initializer — this would be nil in production).
ctx.RegisterHandler = function(msgType: string, fn: (any) -> ())
	local list = ctx.Handlers[msgType]
	if not list then
		list = {}
		ctx.Handlers[msgType] = list
	end
	table.insert(list, fn)
end

-- Controller load order (Audio first so buttons can click-sound immediately)
local CONTROLLERS = { "AudioController", "GuideController", "CastController", "UIController", "MenuUIController" }

for _, name in pairs(CONTROLLERS) do
	local ok, controller = pcall(function()
		return require(script.Parent.Controllers[name])
	end)
	if not ok then
		warn("[Client] Failed to load controller " .. name .. ": " .. tostring(controller))
		continue
	end
	ctx.Services[name] = controller
	if controller.Init then
		controller:Init(ctx)
	end
end

-- Message dispatch
Remotes:OnClientMessage(function(message: any)
	if typeof(message) ~= "table" or typeof(message.type) ~= "string" then
		return
	end
	ClientState:Apply(message.type, message.payload)
	local list = ctx.Handlers[message.type]
	if list then
		for _, fn in pairs(list) do
			pcall(fn, message.payload)
		end
	end
end)

-- Start controllers (after UI-ready)
for _, name in pairs(CONTROLLERS) do
	local controller = ctx.Services[name]
	if controller and controller.Start then
		pcall(controller.Start, controller)
	end
end

-- Ask the server for a full snapshot (safe to repeat; server just re-syncs)
task.delay(1, function()
	ClientState:Send("SyncRequest")
end)

-- Expose context for the automated test harness (no-op in production:
-- the environment never defines __tdHarnessCtx unless the test runner injects it)
local env = getfenv()
if env.__tdHarnessCtx ~= nil then
	env.__tdHarnessCtx = ctx
end

print("[Tidebound] Client booted. Controllers: " .. table.concat(CONTROLLERS, ", "))
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Bootstrap (client, LocalScript)
	Client service loader + message dispatcher.
	Every server message is applied to ClientState, then fanned out to all
	controllers that registered a handler for its type.
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ClientState = require(script.Parent.Modules.ClientState)

local ctx = {
	Services = {},
	Handlers = {},
}

-- Controllers call this with dot syntax: ctx.RegisterHandler("Type", fn).
-- Attached AFTER the table is declared (Luau forbids a local referencing
-- itself inside its own initializer — this would be nil in production).
ctx.RegisterHandler = function(msgType: string, fn: (any) -> ())
	local list = ctx.Handlers[msgType]
	if not list then
		list = {}
		ctx.Handlers[msgType] = list
	end
	table.insert(list, fn)
end

-- Controller load order (Audio first so buttons can click-sound immediately)
local CONTROLLERS = { "AudioController", "GuideController", "CastController", "UIController", "MenuUIController" }

for _, name in pairs(CONTROLLERS) do
	local ok, controller = pcall(function()
		return require(script.Parent.Controllers[name])
	end)
	if not ok then
		warn("[Client] Failed to load controller " .. name .. ": " .. tostring(controller))
		continue
	end
	ctx.Services[name] = controller
	if controller.Init then
		controller:Init(ctx)
	end
end

-- Message dispatch
Remotes:OnClientMessage(function(message: any)
	if typeof(message) ~= "table" or typeof(message.type) ~= "string" then
		return
	end
	ClientState:Apply(message.type, message.payload)
	local list = ctx.Handlers[message.type]
	if list then
		for _, fn in pairs(list) do
			pcall(fn, message.payload)
		end
	end
end)

-- Start controllers (after UI-ready)
for _, name in pairs(CONTROLLERS) do
	local controller = ctx.Services[name]
	if controller and controller.Start then
		pcall(controller.Start, controller)
	end
end

-- Ask the server for a full snapshot (safe to repeat; server just re-syncs)
task.delay(1, function()
	ClientState:Send("SyncRequest")
end)

-- Expose context for the automated test harness (no-op in production:
-- the environment never defines __tdHarnessCtx unless the test runner injects it)
local env = getfenv()
if env.__tdHarnessCtx ~= nil then
	env.__tdHarnessCtx = ctx
end

print("[Tidebound] Client booted. Controllers: " .. table.concat(CONTROLLERS, ", "))
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Bootstrap')
end

-- StarterPlayer/StarterPlayerScripts/Controllers/AudioController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/AudioController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — AudioController (client, ModuleScript)
	Lazy Sound player keyed by name -> SoundId from Config.AUDIO_IDS.
	IDs are filled in after the synthesized WAVs (assets/audio/) are uploaded
	in Studio (Creator Dashboard > Audio). id == 0 = graceful silence.
	Phase 4 | AI-assisted | 2026-08-02
]]

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local AudioController = {}
AudioController.Name = "AudioController"

local sounds: { [string]: Sound } = {}

-- Built-in Roblox sounds (shipped with every client — no upload required).
-- Custom uploaded WAVs (Config.AUDIO_IDS) override these when set.
local DEFAULT_PATHS: { [string]: string } = {
	ui_click = "rbxasset://sounds/clickfast.mp3",
	ui_error = "rbxasset://sounds/collide.mp3",
	cast_splash = "rbxasset://sounds/impact_water.mp3",
	bite = "rbxasset://sounds/Kerplunk.mp3",
	reel_tick = "rbxasset://sounds/clickfast.mp3",
	catch_common = "rbxasset://sounds/Kerplunk.mp3",
	catch_rare = "rbxasset://sounds/electronicpingshort.mp3",
	catch_mythic = "rbxasset://sounds/electronicpingshort.mp3",
	levelup = "rbxasset://sounds/electronicpingshort.mp3",
	coins = "rbxasset://sounds/clickfast.mp3",
	streak = "rbxasset://sounds/electronicpingshort.mp3",
	storm = "rbxasset://sounds/impact_explosion_02.mp3",
	achievement = "rbxasset://sounds/electronicpingshort.mp3",
	buy = "rbxasset://sounds/clickfast.mp3",
}

function AudioController:Play(name: string, opts: { volume: number?, looped: boolean?, pitch: number? }?)
	local id = Config.AUDIO_IDS[name]
	local path = ""
	if id and id > 0 then
		path = "rbxassetid://" .. tostring(id)
	else
		path = DEFAULT_PATHS[name] or ""
	end
	if path == "" then
		return
	end
	local snd = sounds[name]
	if not snd then
		snd = Instance.new("Sound")
		snd.Name = "Tidebound_" .. name
		snd.SoundId = path
		snd.Parent = SoundService
		sounds[name] = snd
	end
	snd.Volume = (opts and opts.volume) or 0.6
	snd.Looped = (opts and opts.looped) == true
	if opts and opts.pitch then
		snd.PlaybackSpeed = opts.pitch
	end
	snd:Play()
end

-- Convenience: play one of a set (used for catch rarity sounds)
function AudioController:PlayCatch(rarity: string, shiny: boolean)
	if shiny or rarity == "mythic" then
		self:Play("catch_mythic")
	elseif rarity == "legendary" or rarity == "epic" then
		self:Play("catch_rare")
	else
		self:Play("catch_common")
	end
end

function AudioController:Init(ctx)
	self.ctx = ctx
end

function AudioController:Start()
end

return AudioController
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — AudioController (client, ModuleScript)
	Lazy Sound player keyed by name -> SoundId from Config.AUDIO_IDS.
	IDs are filled in after the synthesized WAVs (assets/audio/) are uploaded
	in Studio (Creator Dashboard > Audio). id == 0 = graceful silence.
	Phase 4 | AI-assisted | 2026-08-02
]]

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local AudioController = {}
AudioController.Name = "AudioController"

local sounds: { [string]: Sound } = {}

-- Built-in Roblox sounds (shipped with every client — no upload required).
-- Custom uploaded WAVs (Config.AUDIO_IDS) override these when set.
local DEFAULT_PATHS: { [string]: string } = {
	ui_click = "rbxasset://sounds/clickfast.mp3",
	ui_error = "rbxasset://sounds/collide.mp3",
	cast_splash = "rbxasset://sounds/impact_water.mp3",
	bite = "rbxasset://sounds/Kerplunk.mp3",
	reel_tick = "rbxasset://sounds/clickfast.mp3",
	catch_common = "rbxasset://sounds/Kerplunk.mp3",
	catch_rare = "rbxasset://sounds/electronicpingshort.mp3",
	catch_mythic = "rbxasset://sounds/electronicpingshort.mp3",
	levelup = "rbxasset://sounds/electronicpingshort.mp3",
	coins = "rbxasset://sounds/clickfast.mp3",
	streak = "rbxasset://sounds/electronicpingshort.mp3",
	storm = "rbxasset://sounds/impact_explosion_02.mp3",
	achievement = "rbxasset://sounds/electronicpingshort.mp3",
	buy = "rbxasset://sounds/clickfast.mp3",
}

function AudioController:Play(name: string, opts: { volume: number?, looped: boolean?, pitch: number? }?)
	local id = Config.AUDIO_IDS[name]
	local path = ""
	if id and id > 0 then
		path = "rbxassetid://" .. tostring(id)
	else
		path = DEFAULT_PATHS[name] or ""
	end
	if path == "" then
		return
	end
	local snd = sounds[name]
	if not snd then
		snd = Instance.new("Sound")
		snd.Name = "Tidebound_" .. name
		snd.SoundId = path
		snd.Parent = SoundService
		sounds[name] = snd
	end
	snd.Volume = (opts and opts.volume) or 0.6
	snd.Looped = (opts and opts.looped) == true
	if opts and opts.pitch then
		snd.PlaybackSpeed = opts.pitch
	end
	snd:Play()
end

-- Convenience: play one of a set (used for catch rarity sounds)
function AudioController:PlayCatch(rarity: string, shiny: boolean)
	if shiny or rarity == "mythic" then
		self:Play("catch_mythic")
	elseif rarity == "legendary" or rarity == "epic" then
		self:Play("catch_rare")
	else
		self:Play("catch_common")
	end
end

function AudioController:Init(ctx)
	self.ctx = ctx
end

function AudioController:Start()
end

return AudioController
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/AudioController')
end

-- StarterPlayer/StarterPlayerScripts/Controllers/GuideController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/GuideController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — GuideController (client, ModuleScript)
	The guided tutorial popup (bottom-center, above the XP bar).
	Server-driven: WorldInteractionsService sends GuideUpdate messages.
	Also opens panels when the server says so (OpenPanel).
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local GuideController = {}
GuideController.Name = "GuideController"

local player = Players.LocalPlayer
local gui: ScreenGui
local frame: Frame
local label: TextLabel
local dismissBtn: TextButton

function GuideController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "GuideGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 4,
		Parent = player.PlayerGui,
	})
	frame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.1), UDim2.fromScale(0.5, 0.76), Theme.BgPanel, 12)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundTransparency = 0.15
	frame.Visible = false
	label = UiKit.Label(frame, "", UDim2.fromScale(0.9, 0.6), UDim2.fromScale(0.05, 0.1), Theme.Text, Theme.FontBold, 15)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextWrapped = true
	dismissBtn = UiKit.Button(frame, "Got it!", function()
		ClientState:Send("GuideDone")
		frame.Visible = false
	end, { size = UDim2.fromScale(0.22, 0.28), pos = UDim2.fromScale(0.39, 0.66), color = Theme.Accent, textSize = 13 })
end

function GuideController:HandleGuideUpdate(payload: any)
	if payload.active and typeof(payload.text) == "string" then
		label.Text = payload.text
		frame.Visible = true
	else
		frame.Visible = false
	end
end

function GuideController:HandleOpenPanel(payload: any)
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	if payload and typeof(payload.panel) == "string" then
		menu:Open(payload.panel)
	end
end

function GuideController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("GuideUpdate", function(payload)
		self:HandleGuideUpdate(payload)
	end)
	ctx.RegisterHandler("OpenPanel", function(payload)
		self:HandleOpenPanel(payload)
	end)
end

function GuideController:Start()
	self:BuildUI()
end

function GuideController:Stop()
	if gui then
		gui:Destroy()
	end
end

return GuideController
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — GuideController (client, ModuleScript)
	The guided tutorial popup (bottom-center, above the XP bar).
	Server-driven: WorldInteractionsService sends GuideUpdate messages.
	Also opens panels when the server says so (OpenPanel).
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local GuideController = {}
GuideController.Name = "GuideController"

local player = Players.LocalPlayer
local gui: ScreenGui
local frame: Frame
local label: TextLabel
local dismissBtn: TextButton

function GuideController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "GuideGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 4,
		Parent = player.PlayerGui,
	})
	frame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.1), UDim2.fromScale(0.5, 0.76), Theme.BgPanel, 12)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundTransparency = 0.15
	frame.Visible = false
	label = UiKit.Label(frame, "", UDim2.fromScale(0.9, 0.6), UDim2.fromScale(0.05, 0.1), Theme.Text, Theme.FontBold, 15)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextWrapped = true
	dismissBtn = UiKit.Button(frame, "Got it!", function()
		ClientState:Send("GuideDone")
		frame.Visible = false
	end, { size = UDim2.fromScale(0.22, 0.28), pos = UDim2.fromScale(0.39, 0.66), color = Theme.Accent, textSize = 13 })
end

function GuideController:HandleGuideUpdate(payload: any)
	if payload.active and typeof(payload.text) == "string" then
		label.Text = payload.text
		frame.Visible = true
	else
		frame.Visible = false
	end
end

function GuideController:HandleOpenPanel(payload: any)
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	if payload and typeof(payload.panel) == "string" then
		menu:Open(payload.panel)
	end
end

function GuideController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("GuideUpdate", function(payload)
		self:HandleGuideUpdate(payload)
	end)
	ctx.RegisterHandler("OpenPanel", function(payload)
		self:HandleOpenPanel(payload)
	end)
end

function GuideController:Start()
	self:BuildUI()
end

function GuideController:Stop()
	if gui then
		gui:Destroy()
	end
end

return GuideController
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/GuideController')
end

-- StarterPlayer/StarterPlayerScripts/Controllers/CastController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/CastController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — CastController (client, ModuleScript)
	Casting + reeling input. Server-authoritative: we only send intents.
	- Hold Q / mouse / CAST button to charge power, release to cast.
	- While reeling: hold to reel (progress rises, tension rises), release to rest.
	- Auto-reel button consumes premium tokens (never required).
	Phase 4 | AI-assisted | 2026-08-02
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local CastController = {}
CastController.Name = "CastController"

local player = Players.LocalPlayer
local gui: ScreenGui
local castButton: TextButton
local reelFrame: Frame
local powerBarFill: Frame
local progressFill: Frame
local tensionFill: Frame
local reelHint: TextLabel
local autoReelButton: TextButton

local charging = false
local chargeStart = 0
local isReeling = false
local lastHold = false
local lastHoldSent = false
local inputConnections: { RBXScriptConnection } = {}

local function canAct(): boolean
	return not ClientState:Get().uiOpen
end

-- ── UI ───────────────────────────────────────────────────────────────────

function CastController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "CastGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 5,
		Parent = player.PlayerGui,
	})

	-- Power bar (above cast button)
	local powerBar = UiKit.Frame(gui, UDim2.fromScale(0.28, 0.05), UDim2.fromScale(1, 0.5), Theme.BgPanel, 8)
	powerBar.Position = UDim2.fromScale(0.5, 0.62)
	powerBar.AnchorPoint = Vector2.new(0.5, 0.5)
	powerBar.BackgroundTransparency = 0.6
	powerBar.Visible = false
	powerBarFill = UiKit.Frame(powerBar, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	powerBarFill.AnchorPoint = Vector2.new(0, 0)

	-- Cast button (mobile-first; also clickable on desktop)
	castButton = UiKit.New("TextButton", {
		Name = "CastButton",
		Text = "🎣\nCAST",
		Size = UDim2.fromScale(0.2, 0.14),
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = 18,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = gui,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = castButton })
	local castPad = UiKit.New("UIPadding", { PaddingBottom = UDim.new(0, 18), PaddingRight = UDim.new(0, 18), Parent = castButton })

	-- Reel frame (hidden until a bite)
	reelFrame = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.22), UDim2.fromScale(0.5, 0.78), Theme.BgPanel, 12)
	reelFrame.AnchorPoint = Vector2.new(0.5, 1)
	reelFrame.Visible = false

	reelHint = UiKit.Label(reelFrame, "HOLD to reel — release to rest!", UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), Theme.Text)
	UiKit.Label(reelFrame, "PROGRESS", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.22), Theme.TextDim, nil, 12)
	local progressBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.4), Theme.BgPanelLight, 6)
	progressFill = UiKit.Frame(progressBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Success, 6)
	UiKit.Label(reelFrame, "TENSION", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.55), Theme.TextDim, nil, 12)
	local tensionBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.73), Theme.BgPanelLight, 6)
	tensionFill = UiKit.Frame(tensionBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Danger, 6)

	autoReelButton = UiKit.Button(reelFrame, "⚡ AUTO-REEL", function()
		ClientState:Send("AutoReel")
	end, { size = UDim2.fromScale(0.16, 0.24), pos = UDim2.fromScale(0.84, 0.6), color = Theme.Accent2, textSize = 12 })
end

-- ── Input ────────────────────────────────────────────────────────────────

local function isCastInput(input: InputObject): boolean
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		return true
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		return true
	end
	return false
end

local function beginCharge()
	if not canAct() or isReeling then
		return
	end
	charging = true
	chargeStart = os.clock()
	powerBar.Visible = true
	powerBar.Parent.Visible = true
	powerBarFill.Size = UDim2.fromScale(0, 1)
end

local function endCharge()
	if not charging then
		return
	end
	charging = false
	powerBar.Visible = false
	local heldFor = os.clock() - chargeStart
	local power = Util.clamp(heldFor / Config.CAST_POWER_TIME, 0, 1)
	if heldFor < 0.1 then
		power = Config.QUICK_CAST_POWER -- tap = quick cast
	end
	-- Direction: camera look, flattened to the water plane
	local camera = Workspace.CurrentCamera
	local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude < 0.1 then
		look = Vector3.new(0, 0, -1)
	end
	ClientState:Send("Cast", { dir = look.Unit, power = power })
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("cast_splash")
	end)
end

local function onHoldChange(held: boolean)
	lastHold = held
	if isReeling and lastHoldSent ~= held then
		lastHoldSent = held
		ClientState:Send("ReelHold", { held = held })
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function CastController:HandleBite(_payload: any)
	isReeling = true
	lastHoldSent = nil
	reelFrame.Visible = true
	castButton.Visible = false
	progressFill.Size = UDim2.fromScale(0, 1)
	tensionFill.Size = UDim2.fromScale(0, 1)
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("bite")
	end)
end

function CastController:HandleReelState(payload: any)
	if not isReeling then
		return
	end
	local p = Util.clamp(payload.progress or 0, 0, 100) / 100
	local t = Util.clamp(payload.tension or 0, 0, 100) / 100
	progressFill.Size = UDim2.fromScale(p, 1)
	tensionFill.Size = UDim2.fromScale(t, 1)
	if payload.fishName and payload.fishName ~= "" then
		local rarity = payload.rarity or "common"
		reelHint.Text = payload.fishName .. " — " .. (Theme.RarityName[rarity] or rarity)
		reelHint.TextColor3 = Theme.Rarity[rarity] or Theme.Text
	end
end

function CastController:HandleCatchResult(_payload: any)
	isReeling = false
	lastHoldSent = nil
	reelFrame.Visible = false
	castButton.Visible = true
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function CastController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("Bite", function(payload)
		self:HandleBite(payload)
	end)
	ctx.RegisterHandler("ReelState", function(payload)
		self:HandleReelState(payload)
	end)
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
end

function CastController:Start()
	self:BuildUI()

	table.insert(inputConnections, UserInputService.InputBegan:Connect(function(input)
		if isCastInput(input) then
			beginCharge()
		end
		if isCastInput(input) then
			onHoldChange(true)
		end
	end))
	table.insert(inputConnections, UserInputService.InputEnded:Connect(function(input)
		if isCastInput(input) then
			endCharge()
			onHoldChange(false)
		end
	end))

	castButton.MouseButton1Down:Connect(function()
		beginCharge()
	end)
	castButton.MouseButton1Up:Connect(function()
		endCharge()
	end)

	-- Power bar animation
	RunService.RenderStepped:Connect(function(_dt)
		if charging then
			local power = Util.clamp((os.clock() - chargeStart) / Config.CAST_POWER_TIME, 0, 1)
			powerBarFill.Size = UDim2.fromScale(power, 1)
		end
	end)
end

function CastController:Stop()
	for _, conn in pairs(inputConnections) do
		conn:Disconnect()
	end
	if gui then
		gui:Destroy()
	end
end

return CastController
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — CastController (client, ModuleScript)
	Casting + reeling input. Server-authoritative: we only send intents.
	- Hold Q / mouse / CAST button to charge power, release to cast.
	- While reeling: hold to reel (progress rises, tension rises), release to rest.
	- Auto-reel button consumes premium tokens (never required).
	Phase 4 | AI-assisted | 2026-08-02
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local CastController = {}
CastController.Name = "CastController"

local player = Players.LocalPlayer
local gui: ScreenGui
local castButton: TextButton
local reelFrame: Frame
local powerBarFill: Frame
local progressFill: Frame
local tensionFill: Frame
local reelHint: TextLabel
local autoReelButton: TextButton

local charging = false
local chargeStart = 0
local isReeling = false
local lastHold = false
local lastHoldSent = false
local inputConnections: { RBXScriptConnection } = {}

local function canAct(): boolean
	return not ClientState:Get().uiOpen
end

-- ── UI ───────────────────────────────────────────────────────────────────

function CastController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "CastGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 5,
		Parent = player.PlayerGui,
	})

	-- Power bar (above cast button)
	local powerBar = UiKit.Frame(gui, UDim2.fromScale(0.28, 0.05), UDim2.fromScale(1, 0.5), Theme.BgPanel, 8)
	powerBar.Position = UDim2.fromScale(0.5, 0.62)
	powerBar.AnchorPoint = Vector2.new(0.5, 0.5)
	powerBar.BackgroundTransparency = 0.6
	powerBar.Visible = false
	powerBarFill = UiKit.Frame(powerBar, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	powerBarFill.AnchorPoint = Vector2.new(0, 0)

	-- Cast button (mobile-first; also clickable on desktop)
	castButton = UiKit.New("TextButton", {
		Name = "CastButton",
		Text = "🎣\nCAST",
		Size = UDim2.fromScale(0.2, 0.14),
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = 18,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = gui,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = castButton })
	local castPad = UiKit.New("UIPadding", { PaddingBottom = UDim.new(0, 18), PaddingRight = UDim.new(0, 18), Parent = castButton })

	-- Reel frame (hidden until a bite)
	reelFrame = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.22), UDim2.fromScale(0.5, 0.78), Theme.BgPanel, 12)
	reelFrame.AnchorPoint = Vector2.new(0.5, 1)
	reelFrame.Visible = false

	reelHint = UiKit.Label(reelFrame, "HOLD to reel — release to rest!", UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), Theme.Text)
	UiKit.Label(reelFrame, "PROGRESS", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.22), Theme.TextDim, nil, 12)
	local progressBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.4), Theme.BgPanelLight, 6)
	progressFill = UiKit.Frame(progressBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Success, 6)
	UiKit.Label(reelFrame, "TENSION", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.55), Theme.TextDim, nil, 12)
	local tensionBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.73), Theme.BgPanelLight, 6)
	tensionFill = UiKit.Frame(tensionBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Danger, 6)

	autoReelButton = UiKit.Button(reelFrame, "⚡ AUTO-REEL", function()
		ClientState:Send("AutoReel")
	end, { size = UDim2.fromScale(0.16, 0.24), pos = UDim2.fromScale(0.84, 0.6), color = Theme.Accent2, textSize = 12 })
end

-- ── Input ────────────────────────────────────────────────────────────────

local function isCastInput(input: InputObject): boolean
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		return true
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		return true
	end
	return false
end

local function beginCharge()
	if not canAct() or isReeling then
		return
	end
	charging = true
	chargeStart = os.clock()
	powerBar.Visible = true
	powerBar.Parent.Visible = true
	powerBarFill.Size = UDim2.fromScale(0, 1)
end

local function endCharge()
	if not charging then
		return
	end
	charging = false
	powerBar.Visible = false
	local heldFor = os.clock() - chargeStart
	local power = Util.clamp(heldFor / Config.CAST_POWER_TIME, 0, 1)
	if heldFor < 0.1 then
		power = Config.QUICK_CAST_POWER -- tap = quick cast
	end
	-- Direction: camera look, flattened to the water plane
	local camera = Workspace.CurrentCamera
	local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude < 0.1 then
		look = Vector3.new(0, 0, -1)
	end
	ClientState:Send("Cast", { dir = look.Unit, power = power })
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("cast_splash")
	end)
end

local function onHoldChange(held: boolean)
	lastHold = held
	if isReeling and lastHoldSent ~= held then
		lastHoldSent = held
		ClientState:Send("ReelHold", { held = held })
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function CastController:HandleBite(_payload: any)
	isReeling = true
	lastHoldSent = nil
	reelFrame.Visible = true
	castButton.Visible = false
	progressFill.Size = UDim2.fromScale(0, 1)
	tensionFill.Size = UDim2.fromScale(0, 1)
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("bite")
	end)
end

function CastController:HandleReelState(payload: any)
	if not isReeling then
		return
	end
	local p = Util.clamp(payload.progress or 0, 0, 100) / 100
	local t = Util.clamp(payload.tension or 0, 0, 100) / 100
	progressFill.Size = UDim2.fromScale(p, 1)
	tensionFill.Size = UDim2.fromScale(t, 1)
	if payload.fishName and payload.fishName ~= "" then
		local rarity = payload.rarity or "common"
		reelHint.Text = payload.fishName .. " — " .. (Theme.RarityName[rarity] or rarity)
		reelHint.TextColor3 = Theme.Rarity[rarity] or Theme.Text
	end
end

function CastController:HandleCatchResult(_payload: any)
	isReeling = false
	lastHoldSent = nil
	reelFrame.Visible = false
	castButton.Visible = true
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function CastController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("Bite", function(payload)
		self:HandleBite(payload)
	end)
	ctx.RegisterHandler("ReelState", function(payload)
		self:HandleReelState(payload)
	end)
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
end

function CastController:Start()
	self:BuildUI()

	table.insert(inputConnections, UserInputService.InputBegan:Connect(function(input)
		if isCastInput(input) then
			beginCharge()
		end
		if isCastInput(input) then
			onHoldChange(true)
		end
	end))
	table.insert(inputConnections, UserInputService.InputEnded:Connect(function(input)
		if isCastInput(input) then
			endCharge()
			onHoldChange(false)
		end
	end))

	castButton.MouseButton1Down:Connect(function()
		beginCharge()
	end)
	castButton.MouseButton1Up:Connect(function()
		endCharge()
	end)

	-- Power bar animation
	RunService.RenderStepped:Connect(function(_dt)
		if charging then
			local power = Util.clamp((os.clock() - chargeStart) / Config.CAST_POWER_TIME, 0, 1)
			powerBarFill.Size = UDim2.fromScale(power, 1)
		end
	end)
end

function CastController:Stop()
	for _, conn in pairs(inputConnections) do
		conn:Disconnect()
	end
	if gui then
		gui:Destroy()
	end
end

return CastController
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/CastController')
end

-- StarterPlayer/StarterPlayerScripts/Controllers/UIController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/UIController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — UIController (client, ModuleScript)
	HUD + gameplay overlays: coins/pearls/XP bar, event banners, catch card
	(screenshot engine), feed, level-up, streak, achievement toasts.
	Panels (shop/bestiary/inventory/quests) live in MenuUIController.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local UIController = {}
UIController.Name = "UIController"

local player = Players.LocalPlayer
local gui: ScreenGui

local coinLabel: TextLabel
local pearlLabel: TextLabel
local streakLabel: TextLabel
local xpFill: Frame
local xpText: TextLabel
local bannerFrame: Frame
local bannerText: TextLabel
local hintLabel: TextLabel
local hintDismissed = false
local feedFrame: Frame
local stormChip: TextLabel
local cardContainer: Frame

-- ── UI build ─────────────────────────────────────────────────────────────

function UIController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "HudGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1,
		Parent = player.PlayerGui,
	})

	-- Top-left: currencies
	coinLabel = UiKit.Label(gui, "🪙 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.01), Theme.Gold, Theme.FontBold, 17)
	coinLabel.TextXAlignment = Enum.TextXAlignment.Left
	pearlLabel = UiKit.Label(gui, "🐚 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.06), Theme.Accent, Theme.FontBold, 17)
	pearlLabel.TextXAlignment = Enum.TextXAlignment.Left
	streakLabel = UiKit.Label(gui, "🔥 0", UDim2.fromScale(0.16, 0.04), UDim2.fromScale(0.01, 0.11), Theme.Accent2, Theme.FontBold, 15)
	streakLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Top-right: panel buttons
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	local function panelButton(name: string, label: string, order: number)
		local rowIdx = math.ceil(order / 5)
		local colIdx = (order - 1) % 5
		local btn = UiKit.Button(gui, label, function()
			menu:Toggle(name)
		end, { size = UDim2.fromScale(0.1, 0.04), pos = UDim2.fromScale(1 - 0.105 * (colIdx + 1), 0.01 + 0.045 * (rowIdx - 1)), color = Theme.BgPanelLight, textSize = 11 })
		btn.AnchorPoint = Vector2.new(1, 0)
		btn.TextColor3 = Theme.Text
		return btn
	end
	panelButton("travel", "🗺 Map", 1)
	panelButton("quests", "📜 Quests", 2)
	panelButton("shop", "🎣 Shop", 3)
	panelButton("bestiary", "📖 Bestiary", 4)
	panelButton("inventory", "🎒 Bag", 5)
	panelButton("store", "🛒 Store", 6)
	panelButton("pearls", "🐚 Pearls", 7)
	panelButton("achievements", "🏅 Medals", 8)
	panelButton("contest", "🏆 Contest", 9)
	panelButton("profile", "👤 Profile", 10)

	-- XP bar (bottom center) — the "always visible progress" FTUE element
	local xpBg = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.035), UDim2.fromScale(0.5, 1), Theme.BgPanel, 8)
	xpBg.AnchorPoint = Vector2.new(0.5, 1)
	xpBg.BackgroundTransparency = 0.5
	xpFill = UiKit.Frame(xpBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	xpText = UiKit.Label(xpBg, "Lv 1", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 13)

	-- Storm countdown chip
	stormChip = UiKit.Label(gui, "", UDim2.fromScale(0.22, 0.04), UDim2.fromScale(0.5, 0.06), Theme.Storm, Theme.FontBold, 14)
	stormChip.AnchorPoint = Vector2.new(0.5, 0)

	-- Version label (diagnostic: proves client code runs)
	local versionLabel = UiKit.Label(gui, "v14", UDim2.fromScale(0.06, 0.03), UDim2.fromScale(0.02, 0.96), Theme.TextDim, nil, 12)
	versionLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- First-catch hint (dismisses on the player's first catch)
	hintLabel = UiKit.Label(gui, "🎣 Hold Q (or tap CAST) to charge — release to cast!", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.5, 0.9), Theme.Gold, Theme.FontBold, 15)
	hintLabel.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Banner (top-center, animated)
	bannerFrame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.07), UDim2.fromScale(0.5, 0.12), Theme.BgPanel, 10)
	bannerFrame.AnchorPoint = Vector2.new(0.5, 0)
	bannerFrame.Visible = false
	bannerText = UiKit.Label(bannerFrame, "", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 18)

	-- Feed (bottom-left)
	feedFrame = UiKit.New("Frame", {
		Name = "Feed",
		Size = UDim2.fromScale(0.34, 0.5),
		Position = UDim2.fromScale(0.01, 0.5),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	UiKit.New("UIListLayout", { Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Parent = feedFrame })

	-- Catch card container (center overlay)
	cardContainer = UiKit.New("Frame", {
		Name = "CatchCardContainer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	})
end

-- ── HUD refresh (reads ClientState) ──────────────────────────────────────

function UIController:RefreshHud()
	local s = ClientState:Get()
	coinLabel.Text = "🪙 " .. Util.formatNumber(s.coins)
	pearlLabel.Text = "🐚 " .. Util.formatNumber(s.pearls)
	if s.streak > 1 then
		streakLabel.Text = "🔥 " .. s.streak .. " day streak"
		streakLabel.Visible = true
	else
		streakLabel.Visible = false
	end
	local needed = Util.xpForLevel(s.level, Config.XP_BASE, Config.XP_EXPONENT)
	xpFill.Size = UDim2.fromScale(Util.clamp(s.xp / needed, 0, 1), 1)
	xpText.Text = "Lv " .. s.level .. "  " .. Util.formatNumber(s.xp) .. "/" .. Util.formatNumber(needed)
end

-- ── Banner / feed / toasts ───────────────────────────────────────────────

local bannerTween: Tween? = nil

function UIController:ShowBanner(text: string, color: Color3, duration: number)
	bannerText.Text = text
	bannerFrame.BackgroundColor3 = color
	bannerFrame.Visible = true
	bannerFrame.Size = UDim2.fromScale(0.6, 0.07)
	bannerFrame.Position = UDim2.fromScale(0.5, -0.1)
	local tween = TweenService:Create(bannerFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.12),
	})
	tween:Play()
	task.delay(duration or 4, function()
		if bannerFrame and bannerFrame.Visible then
			local out = TweenService:Create(bannerFrame, TweenInfo.new(0.3), { Position = UDim2.fromScale(0.5, -0.1) })
			out:Play()
			task.delay(0.3, function()
				if bannerFrame then
					bannerFrame.Visible = false
				end
			end)
		end
	end)
end

function UIController:AddFeed(text: string, color: Color3?)
	local entry = UiKit.Frame(feedFrame, UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0), Theme.BgPanel, 6)
	entry.BackgroundTransparency = 0.35
	local label = UiKit.Label(entry, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), color or Theme.Text, nil, 13)
	label.TextXAlignment = Enum.TextXAlignment.Left
	UiKit.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = entry })
	-- Cap feed length
	local children = feedFrame:GetChildren()
	for i = 1, #children - Config.MAX_FEED_MESSAGES do
		if children[i]:IsA("Frame") then
			children[i]:Destroy()
		end
	end
	-- Fade out
	task.delay(8, function()
		if entry and entry.Parent then
			entry:Destroy()
		end
	end)
end

function UIController:Toast(text: string, color: Color3?)
	local t = UiKit.Frame(gui, UDim2.fromScale(0.42, 0.055), UDim2.fromScale(0.5, 0.22), color or Theme.Accent, 10)
	t.AnchorPoint = Vector2.new(0.5, 0)
	t.BackgroundTransparency = 0.25
	UiKit.Label(t, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.new(1, 1, 1), Theme.FontBold, 15)
	task.delay(3, function()
		if t and t.Parent then
			t:Destroy()
		end
	end)
end

-- ── Catch card (screenshot engine) ───────────────────────────────────────

function UIController:ShowCatchCard(payload: any)
	local fishId = payload.fishId
	local def = FishCatalog.Get(fishId)
	if not def then
		return
	end
	local shiny = payload.shiny == true
	local rarity = payload.rarity or "common"
	local color = Theme.Rarity[rarity] or Theme.Text

	cardContainer.Visible = true
	for _, child in pairs(cardContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local backdrop = UiKit.Frame(cardContainer, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(5, 10, 18), 0)
	backdrop.BackgroundTransparency = 0.35

	local card = UiKit.Frame(backdrop, UDim2.fromScale(0.34, 0.5), UDim2.fromScale(0.5, 0.5), Theme.BgPanel, 16)
	card.AnchorPoint = Vector2.new(0.5, 0.5)

	local rarityTag = UiKit.Label(card, (shiny and "✨ SHINY " or "") .. (Theme.RarityName[rarity] or rarity):upper(), UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.03), color, Theme.FontTitle, 16)

	-- Fish visual in a viewport
	local vp = UiKit.New("ViewportFrame", {
		Name = "FishViewport",
		Size = UDim2.fromScale(1, 0.5),
		Position = UDim2.fromScale(0, 0.12),
		BackgroundColor3 = Theme.Bg,
		Parent = card,
	})
	local ok, model = pcall(FishVisuals.Build, fishId, shiny)
	if ok and model then
		model.Parent = vp
		vp.CurrentCamera = Instance.new("Camera")
		vp.CurrentCamera.CFrame = FishVisuals.FrameCamera(model, 4.5)
	end

	UiKit.Label(card, payload.name or def.name, UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0.6), Theme.Text, Theme.FontTitle, 22)
	UiKit.Label(card, "⚖ " .. payload.weight .. " kg", UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0.7), Theme.Text, Theme.FontBold, 15)
	UiKit.Label(card, "+" .. Util.formatNumber(payload.coins or 0) .. " 🪙   +" .. (payload.xp or 0) .. " XP   +" .. (payload.pearls or 0) .. " 🐚",
		UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.78), Theme.Gold, Theme.FontBold, 14)
	UiKit.Button(card, "Nice! ✨", function()
		cardContainer.Visible = false
	end, { size = UDim2.fromScale(0.4, 0.09), pos = UDim2.fromScale(0.3, 0.88), color = Theme.Accent, textSize = 14 })

	-- Auto-dismiss for rares; mythics/shiny stay until dismissed (screenshot time)
	if rarity ~= "mythic" and not shiny then
		task.delay(Config.CATCH_CARD_MS / 1000, function()
			if cardContainer.Visible then
				cardContainer.Visible = false
			end
		end)
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function UIController:HandleCatchResult(payload: any)
	if not hintDismissed and hintLabel then
		hintDismissed = true
		hintLabel.Visible = false
	end
	if payload.snapped then
		self:Toast("The line snapped! Reel when tension is low.", Theme.Danger)
		return
	end
	local idx = Config.RARITY_INDEX[payload.rarity or "common"] or 1
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	audio:PlayCatch(payload.rarity or "common", payload.shiny == true)
	if payload.golden then
		self:Toast("✨ Golden catch! +10% value", Theme.Gold)
	end
	if payload.autoSold then
		self:AddFeed("(auto-sold) " .. payload.name .. " — +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.TextDim)
	elseif payload.overflowSold then
		self:AddFeed("(bag full — sold oldest) " .. payload.name, Theme.TextDim)
	end
	if idx >= 4 or payload.shiny then
		self:ShowCatchCard(payload)
	else
		self:Toast(payload.name .. " — " .. payload.weight .. "kg  +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.Rarity[payload.rarity] or Theme.Text)
	end
end

function UIController:HandleEventBanner(payload: any)
	local kind = payload.kind
	local text = payload.text or ""
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	if kind == "storm" then
		self:ShowBanner("⛈ " .. text, Theme.Storm, 5)
		audio:Play("storm")
	elseif kind == "stormWarning" then
		self:ShowBanner("🌩 " .. text, Theme.Storm, 4)
	elseif kind == "night" then
		self:ShowBanner("🌙 " .. text, Theme.Night, 4)
	elseif kind == "day" then
		self:ShowBanner("🌅 " .. text, Theme.Gold, 3)
	elseif kind == "stormEnd" then
		self:ShowBanner("☀ " .. text, Theme.Text, 3)
	elseif kind == "zoneComplete" then
		self:ShowBanner("🏆 " .. text, Theme.Success, 4)
	elseif kind == "zoneEnter" then
		self:ShowBanner("🌊 " .. text, Theme.Accent, 3)
	elseif kind == "travelDenied" then
		self:Toast(text, Theme.Danger)
	elseif kind == "oldOne" then
		self:ShowBanner("🐋 " .. text, Theme.Success, 5)
		audio:Play("catch_mythic")
	else
		self:ShowBanner(text, Theme.Accent, 4)
	end
end

function UIController:HandleLevelUp(payload: any)
	self:ShowBanner("⬆ LEVEL UP! You reached level " .. payload.level .. " (+" .. payload.coinsGranted .. " 🪙)", Theme.Accent2, 3.5)
	require(script.Parent.Parent.Controllers.AudioController):Play("levelup")
end

function UIController:HandleStreakUpdate(payload: any)
	local day = payload.streak or 1
	if day == 1 then
		return -- day-1 streak is just "welcome back", no popup
	end
	self:Toast("🔥 Day " .. day .. " streak! Rewards claimed.", Theme.Accent2)
	require(script.Parent.Parent.Controllers.AudioController):Play("streak")
end

function UIController:HandleAchievementUnlock(payload: any)
	self:ShowBanner("🏅 Achievement: " .. payload.name, Theme.Gold, 4)
	require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
end

function UIController:HandleFeedMessage(payload: any)
	self:AddFeed(payload.text or "", payload.kind == "announce" and Theme.Accent2 or Theme.TextDim)
end

function UIController:HandleBestiaryUpdate(payload: any)
	if payload.bestiaryNew then
		local def = FishCatalog.Get(payload.fishId)
		self:Toast("📖 New bestiary entry: " .. (def and def.name or "?") .. (payload.shiny and " (SHINY!)" or ""), Theme.Accent)
		require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
	end
end

function UIController:HandleGoldenSpot(payload: any)
	if payload.active then
		self:ShowBanner("✨ Golden shimmer: " .. payload.zoneId .. "!", Theme.Gold, 4)
	end
end

function UIController:HandleWorldState(payload: any)
	-- Storm countdown chip updates
	if payload.stormIn and payload.stormIn > 0 and payload.stormIn <= 90 and not payload.isStorm then
		stormChip.Text = "🌩 storm in " .. math.ceil(payload.stormIn) .. "s"
		stormChip.Visible = true
	else
		stormChip.Visible = false
	end
end

function UIController:HandlePassGranted(_payload: any)
	self:Toast("✅ Purchase complete — thank you for supporting Tidebound!", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

function UIController:HandleProductGranted(_payload: any)
	self:Toast("✅ Delivered! Check your bag.", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function UIController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
	ctx.RegisterHandler("EventBanner", function(payload)
		self:HandleEventBanner(payload)
	end)
	ctx.RegisterHandler("LevelUp", function(payload)
		self:HandleLevelUp(payload)
	end)
	ctx.RegisterHandler("StreakUpdate", function(payload)
		self:HandleStreakUpdate(payload)
	end)
	ctx.RegisterHandler("AchievementUnlock", function(payload)
		self:HandleAchievementUnlock(payload)
	end)
	ctx.RegisterHandler("FeedMessage", function(payload)
		self:HandleFeedMessage(payload)
	end)
	ctx.RegisterHandler("BestiaryUpdate", function(payload)
		self:HandleBestiaryUpdate(payload)
	end)
	ctx.RegisterHandler("WorldState", function(payload)
		self:HandleWorldState(payload)
	end)
	ctx.RegisterHandler("GoldenSpot", function(payload)
		self:HandleGoldenSpot(payload)
	end)
	ctx.RegisterHandler("PassGranted", function(payload)
		self:HandlePassGranted(payload)
	end)
	ctx.RegisterHandler("ProductGranted", function(payload)
		self:HandleProductGranted(payload)
	end)
end

function UIController:Start()
	self:BuildUI()
	self:RefreshHud()
	ClientState:Subscribe(function(msgType, _payload)
		if msgType == "StateSync" or msgType == "QuestUpdate" or msgType == "InventorySync" then
			self:RefreshHud()
		end
	end)
end

function UIController:Stop()
	if gui then
		gui:Destroy()
	end
end

return UIController
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — UIController (client, ModuleScript)
	HUD + gameplay overlays: coins/pearls/XP bar, event banners, catch card
	(screenshot engine), feed, level-up, streak, achievement toasts.
	Panels (shop/bestiary/inventory/quests) live in MenuUIController.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local UIController = {}
UIController.Name = "UIController"

local player = Players.LocalPlayer
local gui: ScreenGui

local coinLabel: TextLabel
local pearlLabel: TextLabel
local streakLabel: TextLabel
local xpFill: Frame
local xpText: TextLabel
local bannerFrame: Frame
local bannerText: TextLabel
local hintLabel: TextLabel
local hintDismissed = false
local feedFrame: Frame
local stormChip: TextLabel
local cardContainer: Frame

-- ── UI build ─────────────────────────────────────────────────────────────

function UIController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "HudGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1,
		Parent = player.PlayerGui,
	})

	-- Top-left: currencies
	coinLabel = UiKit.Label(gui, "🪙 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.01), Theme.Gold, Theme.FontBold, 17)
	coinLabel.TextXAlignment = Enum.TextXAlignment.Left
	pearlLabel = UiKit.Label(gui, "🐚 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.06), Theme.Accent, Theme.FontBold, 17)
	pearlLabel.TextXAlignment = Enum.TextXAlignment.Left
	streakLabel = UiKit.Label(gui, "🔥 0", UDim2.fromScale(0.16, 0.04), UDim2.fromScale(0.01, 0.11), Theme.Accent2, Theme.FontBold, 15)
	streakLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Top-right: panel buttons
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	local function panelButton(name: string, label: string, order: number)
		local rowIdx = math.ceil(order / 5)
		local colIdx = (order - 1) % 5
		local btn = UiKit.Button(gui, label, function()
			menu:Toggle(name)
		end, { size = UDim2.fromScale(0.1, 0.04), pos = UDim2.fromScale(1 - 0.105 * (colIdx + 1), 0.01 + 0.045 * (rowIdx - 1)), color = Theme.BgPanelLight, textSize = 11 })
		btn.AnchorPoint = Vector2.new(1, 0)
		btn.TextColor3 = Theme.Text
		return btn
	end
	panelButton("travel", "🗺 Map", 1)
	panelButton("quests", "📜 Quests", 2)
	panelButton("shop", "🎣 Shop", 3)
	panelButton("bestiary", "📖 Bestiary", 4)
	panelButton("inventory", "🎒 Bag", 5)
	panelButton("store", "🛒 Store", 6)
	panelButton("pearls", "🐚 Pearls", 7)
	panelButton("achievements", "🏅 Medals", 8)
	panelButton("contest", "🏆 Contest", 9)
	panelButton("profile", "👤 Profile", 10)

	-- XP bar (bottom center) — the "always visible progress" FTUE element
	local xpBg = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.035), UDim2.fromScale(0.5, 1), Theme.BgPanel, 8)
	xpBg.AnchorPoint = Vector2.new(0.5, 1)
	xpBg.BackgroundTransparency = 0.5
	xpFill = UiKit.Frame(xpBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	xpText = UiKit.Label(xpBg, "Lv 1", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 13)

	-- Storm countdown chip
	stormChip = UiKit.Label(gui, "", UDim2.fromScale(0.22, 0.04), UDim2.fromScale(0.5, 0.06), Theme.Storm, Theme.FontBold, 14)
	stormChip.AnchorPoint = Vector2.new(0.5, 0)

	-- Version label (diagnostic: proves client code runs)
	local versionLabel = UiKit.Label(gui, "v14", UDim2.fromScale(0.06, 0.03), UDim2.fromScale(0.02, 0.96), Theme.TextDim, nil, 12)
	versionLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- First-catch hint (dismisses on the player's first catch)
	hintLabel = UiKit.Label(gui, "🎣 Hold Q (or tap CAST) to charge — release to cast!", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.5, 0.9), Theme.Gold, Theme.FontBold, 15)
	hintLabel.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Banner (top-center, animated)
	bannerFrame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.07), UDim2.fromScale(0.5, 0.12), Theme.BgPanel, 10)
	bannerFrame.AnchorPoint = Vector2.new(0.5, 0)
	bannerFrame.Visible = false
	bannerText = UiKit.Label(bannerFrame, "", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 18)

	-- Feed (bottom-left)
	feedFrame = UiKit.New("Frame", {
		Name = "Feed",
		Size = UDim2.fromScale(0.34, 0.5),
		Position = UDim2.fromScale(0.01, 0.5),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	UiKit.New("UIListLayout", { Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Parent = feedFrame })

	-- Catch card container (center overlay)
	cardContainer = UiKit.New("Frame", {
		Name = "CatchCardContainer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	})
end

-- ── HUD refresh (reads ClientState) ──────────────────────────────────────

function UIController:RefreshHud()
	local s = ClientState:Get()
	coinLabel.Text = "🪙 " .. Util.formatNumber(s.coins)
	pearlLabel.Text = "🐚 " .. Util.formatNumber(s.pearls)
	if s.streak > 1 then
		streakLabel.Text = "🔥 " .. s.streak .. " day streak"
		streakLabel.Visible = true
	else
		streakLabel.Visible = false
	end
	local needed = Util.xpForLevel(s.level, Config.XP_BASE, Config.XP_EXPONENT)
	xpFill.Size = UDim2.fromScale(Util.clamp(s.xp / needed, 0, 1), 1)
	xpText.Text = "Lv " .. s.level .. "  " .. Util.formatNumber(s.xp) .. "/" .. Util.formatNumber(needed)
end

-- ── Banner / feed / toasts ───────────────────────────────────────────────

local bannerTween: Tween? = nil

function UIController:ShowBanner(text: string, color: Color3, duration: number)
	bannerText.Text = text
	bannerFrame.BackgroundColor3 = color
	bannerFrame.Visible = true
	bannerFrame.Size = UDim2.fromScale(0.6, 0.07)
	bannerFrame.Position = UDim2.fromScale(0.5, -0.1)
	local tween = TweenService:Create(bannerFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.12),
	})
	tween:Play()
	task.delay(duration or 4, function()
		if bannerFrame and bannerFrame.Visible then
			local out = TweenService:Create(bannerFrame, TweenInfo.new(0.3), { Position = UDim2.fromScale(0.5, -0.1) })
			out:Play()
			task.delay(0.3, function()
				if bannerFrame then
					bannerFrame.Visible = false
				end
			end)
		end
	end)
end

function UIController:AddFeed(text: string, color: Color3?)
	local entry = UiKit.Frame(feedFrame, UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0), Theme.BgPanel, 6)
	entry.BackgroundTransparency = 0.35
	local label = UiKit.Label(entry, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), color or Theme.Text, nil, 13)
	label.TextXAlignment = Enum.TextXAlignment.Left
	UiKit.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = entry })
	-- Cap feed length
	local children = feedFrame:GetChildren()
	for i = 1, #children - Config.MAX_FEED_MESSAGES do
		if children[i]:IsA("Frame") then
			children[i]:Destroy()
		end
	end
	-- Fade out
	task.delay(8, function()
		if entry and entry.Parent then
			entry:Destroy()
		end
	end)
end

function UIController:Toast(text: string, color: Color3?)
	local t = UiKit.Frame(gui, UDim2.fromScale(0.42, 0.055), UDim2.fromScale(0.5, 0.22), color or Theme.Accent, 10)
	t.AnchorPoint = Vector2.new(0.5, 0)
	t.BackgroundTransparency = 0.25
	UiKit.Label(t, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.new(1, 1, 1), Theme.FontBold, 15)
	task.delay(3, function()
		if t and t.Parent then
			t:Destroy()
		end
	end)
end

-- ── Catch card (screenshot engine) ───────────────────────────────────────

function UIController:ShowCatchCard(payload: any)
	local fishId = payload.fishId
	local def = FishCatalog.Get(fishId)
	if not def then
		return
	end
	local shiny = payload.shiny == true
	local rarity = payload.rarity or "common"
	local color = Theme.Rarity[rarity] or Theme.Text

	cardContainer.Visible = true
	for _, child in pairs(cardContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local backdrop = UiKit.Frame(cardContainer, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(5, 10, 18), 0)
	backdrop.BackgroundTransparency = 0.35

	local card = UiKit.Frame(backdrop, UDim2.fromScale(0.34, 0.5), UDim2.fromScale(0.5, 0.5), Theme.BgPanel, 16)
	card.AnchorPoint = Vector2.new(0.5, 0.5)

	local rarityTag = UiKit.Label(card, (shiny and "✨ SHINY " or "") .. (Theme.RarityName[rarity] or rarity):upper(), UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.03), color, Theme.FontTitle, 16)

	-- Fish visual in a viewport
	local vp = UiKit.New("ViewportFrame", {
		Name = "FishViewport",
		Size = UDim2.fromScale(1, 0.5),
		Position = UDim2.fromScale(0, 0.12),
		BackgroundColor3 = Theme.Bg,
		Parent = card,
	})
	local ok, model = pcall(FishVisuals.Build, fishId, shiny)
	if ok and model then
		model.Parent = vp
		vp.CurrentCamera = Instance.new("Camera")
		vp.CurrentCamera.CFrame = FishVisuals.FrameCamera(model, 4.5)
	end

	UiKit.Label(card, payload.name or def.name, UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0.6), Theme.Text, Theme.FontTitle, 22)
	UiKit.Label(card, "⚖ " .. payload.weight .. " kg", UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0.7), Theme.Text, Theme.FontBold, 15)
	UiKit.Label(card, "+" .. Util.formatNumber(payload.coins or 0) .. " 🪙   +" .. (payload.xp or 0) .. " XP   +" .. (payload.pearls or 0) .. " 🐚",
		UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.78), Theme.Gold, Theme.FontBold, 14)
	UiKit.Button(card, "Nice! ✨", function()
		cardContainer.Visible = false
	end, { size = UDim2.fromScale(0.4, 0.09), pos = UDim2.fromScale(0.3, 0.88), color = Theme.Accent, textSize = 14 })

	-- Auto-dismiss for rares; mythics/shiny stay until dismissed (screenshot time)
	if rarity ~= "mythic" and not shiny then
		task.delay(Config.CATCH_CARD_MS / 1000, function()
			if cardContainer.Visible then
				cardContainer.Visible = false
			end
		end)
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function UIController:HandleCatchResult(payload: any)
	if not hintDismissed and hintLabel then
		hintDismissed = true
		hintLabel.Visible = false
	end
	if payload.snapped then
		self:Toast("The line snapped! Reel when tension is low.", Theme.Danger)
		return
	end
	local idx = Config.RARITY_INDEX[payload.rarity or "common"] or 1
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	audio:PlayCatch(payload.rarity or "common", payload.shiny == true)
	if payload.golden then
		self:Toast("✨ Golden catch! +10% value", Theme.Gold)
	end
	if payload.autoSold then
		self:AddFeed("(auto-sold) " .. payload.name .. " — +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.TextDim)
	elseif payload.overflowSold then
		self:AddFeed("(bag full — sold oldest) " .. payload.name, Theme.TextDim)
	end
	if idx >= 4 or payload.shiny then
		self:ShowCatchCard(payload)
	else
		self:Toast(payload.name .. " — " .. payload.weight .. "kg  +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.Rarity[payload.rarity] or Theme.Text)
	end
end

function UIController:HandleEventBanner(payload: any)
	local kind = payload.kind
	local text = payload.text or ""
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	if kind == "storm" then
		self:ShowBanner("⛈ " .. text, Theme.Storm, 5)
		audio:Play("storm")
	elseif kind == "stormWarning" then
		self:ShowBanner("🌩 " .. text, Theme.Storm, 4)
	elseif kind == "night" then
		self:ShowBanner("🌙 " .. text, Theme.Night, 4)
	elseif kind == "day" then
		self:ShowBanner("🌅 " .. text, Theme.Gold, 3)
	elseif kind == "stormEnd" then
		self:ShowBanner("☀ " .. text, Theme.Text, 3)
	elseif kind == "zoneComplete" then
		self:ShowBanner("🏆 " .. text, Theme.Success, 4)
	elseif kind == "zoneEnter" then
		self:ShowBanner("🌊 " .. text, Theme.Accent, 3)
	elseif kind == "travelDenied" then
		self:Toast(text, Theme.Danger)
	elseif kind == "oldOne" then
		self:ShowBanner("🐋 " .. text, Theme.Success, 5)
		audio:Play("catch_mythic")
	else
		self:ShowBanner(text, Theme.Accent, 4)
	end
end

function UIController:HandleLevelUp(payload: any)
	self:ShowBanner("⬆ LEVEL UP! You reached level " .. payload.level .. " (+" .. payload.coinsGranted .. " 🪙)", Theme.Accent2, 3.5)
	require(script.Parent.Parent.Controllers.AudioController):Play("levelup")
end

function UIController:HandleStreakUpdate(payload: any)
	local day = payload.streak or 1
	if day == 1 then
		return -- day-1 streak is just "welcome back", no popup
	end
	self:Toast("🔥 Day " .. day .. " streak! Rewards claimed.", Theme.Accent2)
	require(script.Parent.Parent.Controllers.AudioController):Play("streak")
end

function UIController:HandleAchievementUnlock(payload: any)
	self:ShowBanner("🏅 Achievement: " .. payload.name, Theme.Gold, 4)
	require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
end

function UIController:HandleFeedMessage(payload: any)
	self:AddFeed(payload.text or "", payload.kind == "announce" and Theme.Accent2 or Theme.TextDim)
end

function UIController:HandleBestiaryUpdate(payload: any)
	if payload.bestiaryNew then
		local def = FishCatalog.Get(payload.fishId)
		self:Toast("📖 New bestiary entry: " .. (def and def.name or "?") .. (payload.shiny and " (SHINY!)" or ""), Theme.Accent)
		require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
	end
end

function UIController:HandleGoldenSpot(payload: any)
	if payload.active then
		self:ShowBanner("✨ Golden shimmer: " .. payload.zoneId .. "!", Theme.Gold, 4)
	end
end

function UIController:HandleWorldState(payload: any)
	-- Storm countdown chip updates
	if payload.stormIn and payload.stormIn > 0 and payload.stormIn <= 90 and not payload.isStorm then
		stormChip.Text = "🌩 storm in " .. math.ceil(payload.stormIn) .. "s"
		stormChip.Visible = true
	else
		stormChip.Visible = false
	end
end

function UIController:HandlePassGranted(_payload: any)
	self:Toast("✅ Purchase complete — thank you for supporting Tidebound!", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

function UIController:HandleProductGranted(_payload: any)
	self:Toast("✅ Delivered! Check your bag.", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function UIController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
	ctx.RegisterHandler("EventBanner", function(payload)
		self:HandleEventBanner(payload)
	end)
	ctx.RegisterHandler("LevelUp", function(payload)
		self:HandleLevelUp(payload)
	end)
	ctx.RegisterHandler("StreakUpdate", function(payload)
		self:HandleStreakUpdate(payload)
	end)
	ctx.RegisterHandler("AchievementUnlock", function(payload)
		self:HandleAchievementUnlock(payload)
	end)
	ctx.RegisterHandler("FeedMessage", function(payload)
		self:HandleFeedMessage(payload)
	end)
	ctx.RegisterHandler("BestiaryUpdate", function(payload)
		self:HandleBestiaryUpdate(payload)
	end)
	ctx.RegisterHandler("WorldState", function(payload)
		self:HandleWorldState(payload)
	end)
	ctx.RegisterHandler("GoldenSpot", function(payload)
		self:HandleGoldenSpot(payload)
	end)
	ctx.RegisterHandler("PassGranted", function(payload)
		self:HandlePassGranted(payload)
	end)
	ctx.RegisterHandler("ProductGranted", function(payload)
		self:HandleProductGranted(payload)
	end)
end

function UIController:Start()
	self:BuildUI()
	self:RefreshHud()
	ClientState:Subscribe(function(msgType, _payload)
		if msgType == "StateSync" or msgType == "QuestUpdate" or msgType == "InventorySync" then
			self:RefreshHud()
		end
	end)
end

function UIController:Stop()
	if gui then
		gui:Destroy()
	end
end

return UIController
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/UIController')
end

-- StarterPlayer/StarterPlayerScripts/Controllers/MenuUIController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/MenuUIController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — MenuUIController (client, ModuleScript)
	Full-screen panels: Shop (rods/baits/upgrades), Pearls (cosmetics),
	Store (Robux gamepasses + dev products), Bestiary, Bag (filters/sort),
	Quests, Achievements, Contest, Travel, Profile (titles + stats).
	All prices/stats come from shared catalogs — nothing hardcoded here.
	Phase 7 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)
local QuestCatalog = require(ReplicatedStorage.Shared.Data.QuestCatalog)
local CosmeticsCatalog = require(ReplicatedStorage.Shared.Data.CosmeticsCatalog)

local MenuUIController = {}
MenuUIController.Name = "MenuUIController"

local player = Players.LocalPlayer
local gui: ScreenGui
local openPanel: string? = nil
local panelFrame: Frame?
local zoneFilter = "sunshall"
local currentDetail: string? = nil
local shopTab = "rods"
local bagFilter = "all"
local bagSort = "new"
local contestRequested = false

local ZONE_ORDER = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }
local AUTO_SELL_OPTIONS = { "off", "common", "uncommon", "rare" }
local BAG_FILTERS = { "all", "common", "uncommon", "rare", "epic", "legendary", "shiny" }

-- ── Core panel scaffolding ───────────────────────────────────────────────

local function makePanel(title: string): Frame
	if panelFrame then
		panelFrame:Destroy()
	end
	local panel = UiKit.Frame(gui, UDim2.fromScale(0.8, 0.86), UDim2.fromScale(0.5, 0.5), Theme.Bg, 18)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panelFrame = panel
	UiKit.Label(panel, title, UDim2.fromScale(0.5, 0.06), UDim2.fromScale(0.25, 0.01), Theme.Text, Theme.FontTitle, 24)
	UiKit.Button(panel, "✕", function()
		MenuUIController:Close()
	end, { size = UDim2.fromScale(0.05, 0.05), pos = UDim2.fromScale(0.94, 0.01), color = Theme.Danger, textSize = 16 })
	return panel
end

function MenuUIController:Open(name: string)
	openPanel = name
	ClientState:Get().uiOpen = true
	if name == "contest" then
		contestRequested = false
	end
	self:Refresh()
end

function MenuUIController:Close()
	openPanel = nil
	ClientState:Get().uiOpen = false
	if panelFrame then
		panelFrame:Destroy()
		panelFrame = nil
	end
end

function MenuUIController:Toggle(name: string)
	if openPanel == name then
		self:Close()
	else
		self:Open(name)
	end
end

-- ══════════════════════ SHOP ══════════════════════

local function shopRodsTab(panel: Frame)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.12), 6)
	local s = ClientState:Get()
	for _, rod in ipairs(RodCatalog.GetSorted()) do
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.9, 0.13), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, rod.name, UDim2.fromScale(0.3, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 17)
		UiKit.Label(row, "Luck +" .. math.floor(rod.luck * 100) .. "%  •  Str " .. rod.strength .. "  •  Lure -" .. rod.lure .. "s",
			UDim2.fromScale(0.44, 0.5), UDim2.fromScale(0.32, 0.05), Theme.TextDim, nil, 13)
		local owned = s.rods[rod.id] == true
		local equipped = s.equippedRod == rod.id
		local affordable = s.coins >= rod.cost
		local levelOk = s.level >= rod.unlockLevel
		local statusText = if equipped then "EQUIPPED"
			elseif owned then "Equip"
			else "Buy • " .. Util.formatNumber(rod.cost) .. " 🪙"
		if not owned and not affordable then
			statusText = statusText .. "\n(need " .. Util.formatNumber(rod.cost - s.coins) .. " more)"
		end
		if not owned and not levelOk then
			statusText = statusText .. "\n(Lv " .. rod.unlockLevel .. " req)"
		end
		local btn = UiKit.Button(row, statusText, function()
			if owned then
				ClientState:Send("EquipRod", { rodId = rod.id })
				MenuUIController:Refresh()
			elseif levelOk then
				ClientState:Send("BuyRod", { rodId = rod.id })
				MenuUIController:Refresh()
			end
		end, { size = UDim2.fromScale(0.22, 0.72), pos = UDim2.fromScale(0.76, 0.14), color = if equipped then Theme.Accent2 elseif owned then Theme.Success elseif affordable then Theme.Accent else Theme.BgPanelLight, textSize = 12 })
	end
end

local function shopBaitsTab(panel: Frame)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.12), 6)
	local s = ClientState:Get()
	for id, def in pairs(Config.BAITS) do
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, def.name, UDim2.fromScale(0.25, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 16)
		UiKit.Label(row, "Price: " .. def.cost .. " 🪙 / " .. def.count .. "x   •   Owned: " .. (s.baits[id] or 0),
			UDim2.fromScale(0.45, 0.5), UDim2.fromScale(0.28, 0.05), Theme.TextDim, nil, 13)
		local equipped = s.equippedBait == id
		UiKit.Button(row, "Equip", function()
			ClientState:Send("EquipBait", { baitId = id })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.1, 0.6), pos = UDim2.fromScale(0.72, 0.2), color = if equipped then Theme.Accent2 else Theme.Success, textSize = 12 })
		UiKit.Button(row, "+" .. def.count, function()
			ClientState:Send("BuyBait", { baitId = id, count = def.count })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.09, 0.6), pos = UDim2.fromScale(0.83, 0.2), color = Theme.Accent, textSize = 12 })
	end
	UiKit.Label(panel, "💡 Equipped bait is consumed per cast. Golden Lure: +luck & +weight!",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.93), Theme.TextDim, nil, 12)
end

local function shopUpgradesTab(panel: Frame)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.12), 6)
	local s = ClientState:Get()
	for i, def in ipairs(Config.INVENTORY_UPGRADES) do
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, "Tackle Box +" .. def.slots .. " slots", UDim2.fromScale(0.4, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 16)
		local tierOwned = s.invUpgradeTier >= i
		local canBuy = s.invUpgradeTier + 1 == i
		local btnText = if tierOwned then "OWNED" else (if canBuy then "Upgrade • " .. Util.formatNumber(def.cost) .. " 🪙" else "🔒")
		UiKit.Button(row, btnText, function()
			ClientState:Send("BuyUpgrade", { tier = i })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.22, 0.6), pos = UDim2.fromScale(0.76, 0.2), color = if canBuy then Theme.Accent else Theme.BgPanelLight, textSize = 12 })
	end
	UiKit.Label(panel, "The Bigger Tackle Box gamepass adds +50 slots instantly (Store tab).",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.93), Theme.TextDim, nil, 12)
end

local function shopPanel()
	local panel = makePanel("🎣 SHOP")
	local tabs = { { "rods", "Rods" }, { "baits", "Baits" }, { "upgrades", "Upgrades" } }
	for i, tab in ipairs(tabs) do
		UiKit.Button(panel, tab[2], function()
			shopTab = tab[1]
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.18, 0.05), pos = UDim2.fromScale(0.04 + 0.19 * (i - 1), 0.06), color = if shopTab == tab[1] then Theme.Accent else Theme.BgPanelLight, textSize = 14 })
	end
	if shopTab == "rods" then
		shopRodsTab(panel)
	elseif shopTab == "baits" then
		shopBaitsTab(panel)
	else
		shopUpgradesTab(panel)
	end
end

-- ══════════════════════ PEARLS (cosmetics) ══════════════════════

local KIND_ORDER = { "bobber", "trail", "aura", "rodSkin", "nameColor" }
local KIND_LABELS = {
	bobber = "Bobbers", trail = "Trails", aura = "Auras", rodSkin = "Rod Grips", nameColor = "Name Colors",
}

local function pearlsPanel()
	local panel = makePanel("🐚 PEARL SHOP")
	local s = ClientState:Get()
	UiKit.Label(panel, "Your pearls: " .. Util.formatNumber(s.pearls) .. " 🐚", UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.06), Theme.Accent, Theme.FontBold, 16)

	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.74), UDim2.fromScale(0.03, 0.13), 6)
	local yOffset = 0
	for _, kind in ipairs(KIND_ORDER) do
		UiKit.Label(scroll, "— " .. KIND_LABELS[kind] .. " —", UDim2.fromScale(0.9, 0.04), UDim2.fromScale(0.02, 0), Theme.TextDim, Theme.FontBold, 13)
		for _, def in ipairs(CosmeticsCatalog.GetByKind(kind)) do
			local owned = s.cosmeticsOwned[def.id] == true
			local equipped = s.cosmetics[def.kind] == def.id
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.92, 0.11), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			-- color swatch
			local swatch = UiKit.Frame(row, UDim2.fromScale(0.04, 0.5), UDim2.fromScale(0.02, 0.25), def.color, 4)
			swatch.BorderSizePixel = 0
			UiKit.Label(row, def.name, UDim2.fromScale(0.3, 0.5), UDim2.fromScale(0.08, 0.05), Theme.Text, Theme.FontBold, 15)
			UiKit.Label(row, def.desc, UDim2.fromScale(0.5, 0.4), UDim2.fromScale(0.08, 0.5), Theme.TextDim, nil, 11)
			local btnText = if equipped then "EQUIPPED" else (if owned then "Equip" else def.price .. " 🐚")
			UiKit.Button(row, btnText, function()
				if owned then
					ClientState:Send("EquipCosmetic", { cosmeticId = def.id })
				else
					ClientState:Send("BuyCosmetic", { cosmeticId = def.id })
				end
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.16, 0.6), pos = UDim2.fromScale(0.8, 0.2), color = if equipped then Theme.Accent2 elseif owned then Theme.Success else Theme.Accent, textSize = 12 })
		end
	end
	UiKit.Label(panel, "Cosmetics are visual only — they never affect your catch rates.",
		UDim2.fromScale(0.9, 0.04), UDim2.fromScale(0.05, 0.9), Theme.TextDim, nil, 12)
end

-- ══════════════════════ STORE (Robux) ══════════════════════

local function storePanel()
	local panel = makePanel("🛒 STORE")
	local s = ClientState:Get()
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.8), UDim2.fromScale(0.03, 0.08), 6)

	local passNames = {
		double_catch = "Double Catch — 2x coins from selling fish",
		bigger_tackle_box = "Bigger Tackle Box — +50 inventory slots",
		lucky_charm = "Lucky Charm — +15% luck (capped, fair)",
		vip_angler = "VIP Angler — +10% XP, exclusive rod skin, gold name",
		golden_lure_pass = "Golden Lure Pass — permanent best bait",
		starter_pack = "Starter Pack — 500 coins + 5 Golden Lures + bobber",
	}
	local productNames = {
		pearls_100 = "100 Pearls",
		pearls_450 = "450 Pearls",
		pearls_1000 = "1000 Pearls",
		auto_reel_tokens = "Auto-Reel Tokens (x100)",
		xp_boost_2h = "XP Boost (2 hours)",
	}

	local shown = 0
	for key, id in pairs(Config.GAMEPASS_IDS) do
		if id > 0 then
			shown += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.92, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, passNames[key] or key, UDim2.fromScale(0.72, 0.6), UDim2.fromScale(0.03, 0.1), Theme.Text, Theme.FontBold, 14)
			local owned = s.cosmeticsOwned["pass_" .. key] == true
			UiKit.Button(row, "Get", function()
				pcall(function()
					MarketplaceService:PromptGamePassPurchase(player, id)
				end)
			end, { size = UDim2.fromScale(0.14, 0.6), pos = UDim2.fromScale(0.8, 0.2), color = Theme.Accent2, textSize = 13 })
		end
	end
	for key, id in pairs(Config.PRODUCT_IDS) do
		if id > 0 then
			shown += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.92, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, productNames[key] or key, UDim2.fromScale(0.72, 0.6), UDim2.fromScale(0.03, 0.1), Theme.Text, Theme.FontBold, 14)
			UiKit.Button(row, "Get", function()
				pcall(function()
					MarketplaceService:PromptProductPurchase(player, id)
				end)
			end, { size = UDim2.fromScale(0.14, 0.6), pos = UDim2.fromScale(0.8, 0.2), color = Theme.Accent, textSize = 13 })
		end
	end
	if shown == 0 then
		UiKit.Label(scroll, "The store is being stocked — the pearl shop is already open! 🐚",
			UDim2.fromScale(0.9, 0.08), UDim2.fromScale(0.03, 0.05), Theme.TextDim, nil, 14)
	end
	UiKit.Label(panel, "All purchases are one-time, cosmetic or time-saving. Nothing is pay-to-win.",
		UDim2.fromScale(0.9, 0.04), UDim2.fromScale(0.05, 0.9), Theme.TextDim, nil, 12)
end

-- ══════════════════════ BESTIARY ══════════════════════

local function zoneCompletion(zoneId: string): number
	local s = ClientState:Get()
	local zone = ZoneCatalog.Get(zoneId)
	if not zone then
		return 0
	end
	local total = #zone.fishIds
	local caught = 0
	for _, fishId in ipairs(zone.fishIds) do
		local entry = s.bestiary[fishId]
		if entry and entry.caught > 0 then
			caught += 1
		end
	end
	if total == 0 then
		return 0
	end
	return math.floor(caught / total * 100)
end

local function bestiaryGrid(panel: Frame, zoneId: string)
	UiKit.Label(panel, "Zone completion: " .. zoneCompletion(zoneId) .. "%", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.04, 0.1), Theme.Accent, Theme.FontBold, 15)
	UiKit.Label(panel, "💡 Shiny variants exist for every fish. Complete zones for pearl rewards!",
		UDim2.fromScale(0.8, 0.05), UDim2.fromScale(0.04, 0.15), Theme.TextDim, nil, 12)
	local zone = ZoneCatalog.Get(zoneId)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.72), UDim2.fromScale(0.03, 0.22), 8)
	UiKit.New("UIGridLayout", {
		CellSize = UDim2.fromScale(0.23, 0.28),
		CellPadding = UDim2.fromScale(0.015, 0.02),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroll,
	})
	local s = ClientState:Get()
	for _, fishId in ipairs(zone.fishIds) do
		local def = FishCatalog.Get(fishId)
		local entry = s.bestiary[fishId]
		local caught = entry and entry.caught or 0
		local tile = UiKit.Frame(scroll, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.BgPanel, 10)
		if caught == 0 then
			tile.BackgroundColor3 = Theme.BgPanelLight
			tile.BackgroundTransparency = 0.6
		end
		UiKit.Frame(tile, UDim2.fromScale(1, 0.04), UDim2.fromScale(0, 0), Theme.Rarity[def.rarity], 0)
		UiKit.Label(tile, if caught > 0 then def.name else "???", UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0.25), if caught > 0 then Theme.Text else Theme.TextDim, Theme.FontBold, 13)
		UiKit.Label(tile, "caught: " .. caught .. (entry and entry.shiny and " ✨" or ""), UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.55), Theme.TextDim, nil, 11)
		local btn = UiKit.Button(tile, "View", function()
			currentDetail = fishId
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.6, 0.2), pos = UDim2.fromScale(0.2, 0.76), color = Theme.BgPanelLight, textSize = 11 })
		if caught == 0 then
			btn.BackgroundTransparency = 0.7
		end
	end
end

local function bestiaryDetail(panel: Frame, fishId: string)
	local def = FishCatalog.Get(fishId)
	local s = ClientState:Get()
	local entry = s.bestiary[fishId]
	local caught = entry and entry.caught or 0
	local shinyCaught = entry and entry.shiny or false
	UiKit.Button(panel, "← Back", function()
		currentDetail = nil
		MenuUIController:Refresh()
	end, { size = UDim2.fromScale(0.1, 0.05), pos = UDim2.fromScale(0.02, 0.06), color = Theme.BgPanelLight, textSize = 14 })
	local vp = UiKit.New("ViewportFrame", {
		Name = "DetailViewport",
		Size = UDim2.fromScale(0.4, 0.42),
		Position = UDim2.fromScale(0.05, 0.14),
		BackgroundColor3 = Theme.Bg,
		Parent = panel,
	})
	local ok, model = pcall(FishVisuals.Build, fishId, shinyCaught)
	if ok and model then
		model.Parent = vp
		vp.CurrentCamera = Instance.new("Camera")
		vp.CurrentCamera.CFrame = FishVisuals.FrameCamera(model, 4)
	end
	local zoneName = ZoneCatalog.Get(def.zone)
	UiKit.Label(panel, def.name .. (shinyCaught and " ✨" or ""), UDim2.fromScale(0.5, 0.07), UDim2.fromScale(0.48, 0.14), Theme.Rarity[def.rarity], Theme.FontTitle, 22)
	UiKit.Label(panel, (Theme.RarityName[def.rarity] or ""):upper() .. " • " .. (zoneName and zoneName.name or def.zone),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.21), Theme.TextDim, Theme.FontBold, 13)
	UiKit.Label(panel, "⚖ " .. def.minWeight .. "–" .. def.maxWeight .. " kg   •   💰 " .. def.baseValue .. " 🪙/kg   •   ✨ " .. def.xp .. " XP",
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.27), Theme.Text, nil, 13)
	UiKit.Label(panel, "🎯 Bait: " .. (def.bait and (Config.BAITS[def.bait] and Config.BAITS[def.bait].name or def.bait) or "any"),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.33), Theme.TextDim, nil, 13)
	UiKit.Label(panel, "🌙 Night-only: " .. (def.time == "night" and "yes" or "no") .. (def.stormOnly and "   ⛈ Storm-only: yes" or ""),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.39), Theme.TextDim, nil, 13)
	UiKit.Label(panel, "📖 " .. def.desc, UDim2.fromScale(0.9, 0.16), UDim2.fromScale(0.48, 0.45), Theme.Text, nil, 14)
	UiKit.Label(panel, "Best: " .. (entry and entry.maxWeight or 0) .. " kg   •   Caught: " .. caught .. (shinyCaught and " (incl. SHINY)" or ""),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.62), Theme.Gold, Theme.FontBold, 14)
end

local function bestiaryPanel()
	local panel = makePanel("📖 BESTIARY")
	for i, zoneId in ipairs(ZONE_ORDER) do
		local zone = ZoneCatalog.Get(zoneId)
		UiKit.Button(panel, zone.name, function()
			zoneFilter = zoneId
			currentDetail = nil
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.16, 0.05), pos = UDim2.fromScale(0.02 + 0.1 * (i - 1), 0.06), color = if zoneFilter == zoneId then Theme.Accent else Theme.BgPanelLight, textSize = 11 })
	end
	if currentDetail then
		bestiaryDetail(panel, currentDetail)
	else
		bestiaryGrid(panel, zoneFilter)
	end
end

-- ══════════════════════ BAG ══════════════════════

local function matchesFilter(item: any, def: any): boolean
	if bagFilter == "all" then
		return true
	end
	if bagFilter == "shiny" then
		return item.shiny == true
	end
	return def.rarity == bagFilter
end

local function inventoryPanel()
	local panel = makePanel("🎒 BAG")
	local s = ClientState:Get()
	UiKit.Label(panel, "Capacity: " .. #s.inventory .. " / " .. s.invSlots, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.08), Theme.Text, Theme.FontBold, 14)
	local capBg = UiKit.Frame(panel, UDim2.fromScale(0.4, 0.03), UDim2.fromScale(0.04, 0.14), Theme.BgPanelLight, 6)
	UiKit.Frame(capBg, UDim2.fromScale(Util.clamp(#s.inventory / math.max(1, s.invSlots), 0, 1), 1), UDim2.fromScale(0, 0), Theme.Accent, 6)

	-- Filters
	for i, f in ipairs(BAG_FILTERS) do
		UiKit.Button(panel, f:upper(), function()
			bagFilter = f
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.08, 0.04), pos = UDim2.fromScale(0.04 + 0.085 * (i - 1), 0.18), color = if bagFilter == f then Theme.Accent2 else Theme.BgPanelLight, textSize = 10 })
	end
	-- Sort
	UiKit.Button(panel, if bagSort == "new" then "Newest" else "Biggest", function()
		bagSort = if bagSort == "new" then "big" else "new"
		MenuUIController:Refresh()
	end, { size = UDim2.fromScale(0.1, 0.04), pos = UDim2.fromScale(0.72, 0.18), color = Theme.BgPanelLight, textSize = 10 })

	-- Auto-sell
	UiKit.Label(panel, "Auto-sell (≤ rarity):", UDim2.fromScale(0.18, 0.04), UDim2.fromScale(0.04, 0.24), Theme.TextDim, nil, 12)
	for i, opt in ipairs(AUTO_SELL_OPTIONS) do
		UiKit.Button(panel, opt:upper(), function()
			ClientState:Send("SetAutoSell", { maxRarity = opt == "off" and nil or opt })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.09, 0.04), pos = UDim2.fromScale(0.22 + 0.095 * (i - 1), 0.24), color = if (s.autoSell or "off") == opt then Theme.Accent2 else Theme.BgPanelLight, textSize = 10 })
	end

	-- Bulk sell
	local bulk = { { "common", "Sell Commons" }, { "uncommon", "Sell Uncommons" }, { "rare", "Sell Rares" }, { "all", "Sell All (keeps ✨)" } }
	for i, b in ipairs(bulk) do
		UiKit.Button(panel, b[2], function()
			ClientState:Send("SellAll", { maxRarity = if b[1] == "all" then "epic" else b[1] })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.19, 0.045), pos = UDim2.fromScale(0.04 + 0.2 * (i - 1), 0.29), color = Theme.Accent, textSize = 12 })
	end

	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.58), UDim2.fromScale(0.04, 0.36), 6)
	local items = s.inventory
	table.sort(items, function(a, b)
		if bagSort == "big" then
			return a.weight > b.weight
		end
		return a.caughtAt > b.caughtAt
	end)
	local shown = 0
	for _, item in ipairs(items) do
		local def = FishCatalog.Get(item.fishId)
		if def and matchesFilter(item, def) then
			shown += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.95, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Frame(row, UDim2.fromScale(0.02, 0.7), UDim2.fromScale(0.01, 0.15), Theme.Rarity[def.rarity], 2)
			UiKit.Label(row, (item.shiny and "✨ " or "") .. def.name, UDim2.fromScale(0.3, 1), UDim2.fromScale(0.05, 0), Theme.Text, Theme.FontBold, 13)
			UiKit.Label(row, item.weight .. " kg  •  ~" .. Util.formatNumber(math.floor(def.baseValue * item.weight * (item.shiny and Config.SHINY_VALUE_MULT or 1))) .. " 🪙",
				UDim2.fromScale(0.4, 0.6), UDim2.fromScale(0.38, 0.05), Theme.TextDim, nil, 12)
			UiKit.Button(row, "Sell", function()
				ClientState:Send("SellFish", { ids = { item.uid } })
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.12, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = Theme.Danger, textSize = 12 })
		end
	end
	if shown == 0 then
		UiKit.Label(scroll, "No fish match this filter. Go catch some! 🎣", UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0), Theme.TextDim, nil, 14)
	end
end

-- ══════════════════════ QUESTS ══════════════════════

local function questRow(parent: Instance, q: any, template: any, desc: string, claimFn: () -> ())
	local row = UiKit.Frame(parent, UDim2.fromScale(0.95, 0.11), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
	UiKit.Label(row, desc, UDim2.fromScale(0.72, 0.5), UDim2.fromScale(0.02, 0.05), Theme.Text, Theme.FontBold, 14)
	local progress = template and math.min(q.progress / template.target, 1) or 0
	local barBg = UiKit.Frame(row, UDim2.fromScale(0.72, 0.16), UDim2.fromScale(0.02, 0.55), Theme.BgPanelLight, 4)
	UiKit.Frame(barBg, UDim2.fromScale(progress, 1), UDim2.fromScale(0, 0), Theme.Accent, 4)
	UiKit.Label(row, Util.formatNumber(q.progress) .. "/" .. (template and Util.formatNumber(template.target) or "?"), UDim2.fromScale(0.2, 0.3), UDim2.fromScale(0.54, 0.6), Theme.TextDim, nil, 11)
	local btn = UiKit.Button(row, if q.claimed then "✓" else (if q.done then "Claim" else "…"), claimFn,
		{ size = UDim2.fromScale(0.14, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = if q.claimed then Theme.BgPanelLight elseif q.done then Theme.Success else Theme.BgPanelLight, textSize = 12 })
	if q.claimed then
		btn.TextColor3 = Theme.TextDim
	end
	return row
end

local function questsPanel()
	local panel = makePanel("📜 QUESTS")
	local s = ClientState:Get()
	UiKit.Label(panel, "🔥 Login streak: Day " .. s.streak, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.07), Theme.Accent2, Theme.FontBold, 16)
	for i = 1, 7 do
		local reward = Config.STREAK_REWARDS[i]
		local day = UiKit.Frame(panel, UDim2.fromScale(0.06, 0.09), UDim2.fromScale(0.04 + 0.07 * (i - 1), 0.13), if i == s.streak then Theme.Accent2 elseif i < s.streak then Theme.Success else Theme.BgPanelLight, 30)
		if i < s.streak then
			day.BackgroundTransparency = 0.4
		end
		UiKit.Label(day, "D" .. i, UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0.05), Theme.Text, Theme.FontBold, 12)
		local rewardText = ""
		if reward.coins then
			rewardText = reward.coins .. "🪙"
		end
		if reward.pearls then
			rewardText = rewardText .. (rewardText ~= "" and " " or "") .. reward.pearls .. "🐚"
		end
		UiKit.Label(day, rewardText, UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0.5), Theme.TextDim, nil, 9)
	end
	UiKit.Label(panel, "DAILY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.23), Theme.Accent, Theme.FontTitle, 14)
	local dailyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.28), 4)
	for i, q in ipairs(s.dailyQuests) do
		local template = QuestCatalog.GetDailyTemplate(q.templateId)
		local desc = q.templateId
		if template then
			desc = template.desc
			desc = string.gsub(desc, "{n}", tostring(template.target))
			if q.params and q.params.zone then
				local zn = ZoneCatalog.Get(q.params.zone)
				desc = string.gsub(desc, "{zone}", (zn and zn.name or q.params.zone))
			end
			if q.params and q.params.family then
				desc = string.gsub(desc, "{family}", q.params.family)
			end
		end
		questRow(dailyScroll, q, template, desc, function()
			ClientState:Send("ClaimDaily", { slot = i })
			MenuUIController:Refresh()
		end)
	end
	UiKit.Button(panel, "↻ Reroll one daily (1/day)", function()
		ClientState:Send("RerollQuest", { slot = 1 })
		MenuUIController:Refresh()
	end, { size = UDim2.fromScale(0.3, 0.045), pos = UDim2.fromScale(0.62, 0.23), color = Theme.BgPanelLight, textSize = 12 })
	UiKit.Label(panel, "WEEKLY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.59), Theme.Gold, Theme.FontTitle, 14)
	local weeklyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.64), 4)
	for i, q in ipairs(s.weeklyQuests) do
		local template = QuestCatalog.GetWeeklyTemplate(q.templateId)
		local desc = q.templateId
		if template then
			desc = string.gsub(template.desc, "{n}", tostring(template.target))
		end
		questRow(weeklyScroll, q, template, desc, function()
			ClientState:Send("ClaimWeekly", { slot = i })
			MenuUIController:Refresh()
		end)
	end
end

-- ══════════════════════ ACHIEVEMENTS ══════════════════════

local function achievementsPanel()
	local panel = makePanel("🏅 ACHIEVEMENTS")
	local s = ClientState:Get()
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.82), UDim2.fromScale(0.03, 0.08), 6)
	local unlockedCount = 0
	for _, def in pairs(QuestCatalog.ACHIEVEMENTS) do
		local done = s.achievements[def.id] == true
		if done then
			unlockedCount += 1
		end
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.94, 0.1), UDim2.fromScale(0, 0), if done then Theme.BgPanel else Theme.BgPanelLight, 8)
		if not done then
			row.BackgroundTransparency = 0.5
		end
		UiKit.Label(row, (done and "🏅 " or "🔒 ") .. def.name, UDim2.fromScale(0.4, 0.6), UDim2.fromScale(0.03, 0.05), if done then Theme.Gold else Theme.TextDim, Theme.FontBold, 14)
		UiKit.Label(row, def.desc, UDim2.fromScale(0.45, 0.5), UDim2.fromScale(0.03, 0.5), Theme.TextDim, nil, 11)
		local rewardText = ""
		if def.rewards.pearls then
			rewardText = rewardText .. def.rewards.pearls .. " 🐚"
		end
		if def.rewards.title then
			rewardText = rewardText .. (rewardText ~= "" and " + " or "") .. "Title: " .. def.rewards.title
		end
		UiKit.Label(row, rewardText, UDim2.fromScale(0.28, 0.5), UDim2.fromScale(0.7, 0.5), Theme.Accent, nil, 11)
	end
	UiKit.Label(panel, "Unlocked: " .. unlockedCount .. " / " .. #QuestCatalog.ACHIEVEMENTS,
		UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.03, 0.02), Theme.Text, Theme.FontBold, 14)
end

-- ══════════════════════ CONTEST ══════════════════════

local function contestPanel()
	local panel = makePanel("🏆 WEEKLY CONTEST")
	local s = ClientState:Get()
	if not contestRequested then
		contestRequested = true
		ClientState:Send("GetContestTop")
	end
	UiKit.Label(panel, "Biggest catch of the week wins! Week: " .. (s.contestTop and s.contestTop.week or "…"),
		UDim2.fromScale(0.6, 0.05), UDim2.fromScale(0.04, 0.06), Theme.Accent2, Theme.FontBold, 14)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.68), UDim2.fromScale(0.03, 0.13), 6)
	local entries = s.contestTop and s.contestTop.entries or nil
	if entries and #entries > 0 then
		for i, e in ipairs(entries) do
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.94, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, (i == 1 and "🥇 " or i == 2 and "🥈 " or i == 3 and "🥉 " or "   ") .. "#" .. i .. "  " .. e.name,
				UDim2.fromScale(0.6, 1), UDim2.fromScale(0.03, 0), if i <= 3 then Theme.Gold else Theme.Text, Theme.FontBold, 15)
			UiKit.Label(row, Util.formatNumber(e.score) .. " pts", UDim2.fromScale(0.25, 1), UDim2.fromScale(0.72, 0), Theme.Accent, Theme.FontBold, 14)
		end
	else
		UiKit.Label(scroll, "No catches yet this week — be the first! 🎣", UDim2.fromScale(0.9, 0.1), UDim2.fromScale(0.05, 0.05), Theme.TextDim, nil, 14)
	end
	UiKit.Button(panel, "↻ Refresh", function()
		contestRequested = true
		ClientState:Send("GetContestTop")
		task.delay(0.5, function()
			MenuUIController:Refresh()
		end)
	end, { size = UDim2.fromScale(0.16, 0.05), pos = UDim2.fromScale(0.42, 0.84), color = Theme.Accent, textSize = 13 })
	UiKit.Label(panel, "Top 10 win pearls every Monday. Score = weight × rarity bonus.",
		UDim2.fromScale(0.8, 0.05), UDim2.fromScale(0.1, 0.9), Theme.TextDim, nil, 12)
end

-- ══════════════════════ TRAVEL ══════════════════════

local function travelPanel()
	local panel = makePanel("🗺 TRAVEL")
	local s = ClientState:Get()
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.76), UDim2.fromScale(0.03, 0.1), 6)
	for _, zoneId in ipairs(ZONE_ORDER) do
		local zone = ZoneCatalog.Get(zoneId)
		local unlocked = s.level >= zone.unlockLevel
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.95, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, zone.name, UDim2.fromScale(0.5, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 16)
		UiKit.Label(row, if unlocked then "Level " .. zone.unlockLevel .. " • Ready" else "Requires level " .. zone.unlockLevel,
			UDim2.fromScale(0.3, 0.6), UDim2.fromScale(0.5, 0.05), if unlocked then Theme.Success else Theme.TextDim, nil, 13)
		UiKit.Button(row, "Go! ⚡", function()
			ClientState:Send("FastTravel", { zone = zoneId })
			MenuUIController:Close()
		end, { size = UDim2.fromScale(0.16, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = if unlocked then Theme.Accent else Theme.BgPanelLight, textSize = 13 })
	end
	UiKit.Label(panel, "Fast travel is free — unlock zones by leveling up!",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.88), Theme.TextDim, nil, 13)
end

-- ══════════════════════ PROFILE ══════════════════════

local function profilePanel()
	local panel = makePanel("👤 PROFILE")
	local s = ClientState:Get()
	UiKit.Label(panel, player.Name .. (s.equippedTitle and (" — " .. s.equippedTitle) or ""),
		UDim2.fromScale(0.6, 0.06), UDim2.fromScale(0.2, 0.04), Theme.Text, Theme.FontTitle, 22)

	-- Stats
	local st = s.stats or {}
	local statsText = string.format(
		"Fish caught: %s   •   Coins earned: %s   •   Pearls earned: %s\nShinies: %s   •   Storm fish: %s   •   Night fish: %s   •   Deep fish: %s",
		Util.formatNumber(st.totalCatch or 0),
		Util.formatNumber(st.totalCoinsEarned or 0),
		Util.formatNumber(st.totalPearlsEarned or 0),
		Util.formatNumber(st.shinyFish or 0),
		Util.formatNumber(st.stormFish or 0),
		Util.formatNumber(st.nightFish or 0),
		Util.formatNumber(st.deepFish or 0)
	)
	UiKit.Label(panel, statsText, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0.05, 0.12), Theme.Text, nil, 13)
	local bc = st.bestCatch
	if bc and bc.fishId ~= "" then
		local bdef = FishCatalog.Get(bc.fishId)
		UiKit.Label(panel, "🏆 Best catch: " .. (bdef and bdef.name or bc.fishId) .. " — " .. bc.weight .. " kg",
			UDim2.fromScale(0.6, 0.05), UDim2.fromScale(0.05, 0.24), Theme.Gold, Theme.FontBold, 14)
	end

	-- Titles
	UiKit.Label(panel, "TITLES", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.05, 0.3), Theme.Accent, Theme.FontTitle, 14)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.9, 0.5), UDim2.fromScale(0.05, 0.35), 6)
	local titleCount = 0
	for title, owned in pairs(s.titles) do
		if owned then
			titleCount += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.94, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, title, UDim2.fromScale(0.6, 1), UDim2.fromScale(0.03, 0), Theme.Text, Theme.FontBold, 14)
			local equipped = s.equippedTitle == title
			UiKit.Button(row, if equipped then "EQUIPPED" else "Equip", function()
				ClientState:Send("EquipTitle", { title = title })
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.18, 0.6), pos = UDim2.fromScale(0.78, 0.2), color = if equipped then Theme.Accent2 else Theme.Success, textSize = 12 })
		end
	end
	if titleCount == 0 then
		UiKit.Label(scroll, "No titles yet. Complete achievements to earn them!", UDim2.fromScale(0.9, 0.1), UDim2.fromScale(0.05, 0.05), Theme.TextDim, nil, 13)
	end
end

-- ══════════════════════ Refresh & lifecycle ══════════════════════

function MenuUIController:Refresh()
	if not openPanel then
		return
	end
	makePanel("")
	if openPanel == "shop" then
		shopPanel()
	elseif openPanel == "pearls" then
		pearlsPanel()
	elseif openPanel == "store" then
		storePanel()
	elseif openPanel == "bestiary" then
		bestiaryPanel()
	elseif openPanel == "inventory" then
		inventoryPanel()
	elseif openPanel == "quests" then
		questsPanel()
	elseif openPanel == "achievements" then
		achievementsPanel()
	elseif openPanel == "contest" then
		contestPanel()
	elseif openPanel == "travel" then
		travelPanel()
	elseif openPanel == "profile" then
		profilePanel()
	end
end

function MenuUIController:Init(ctx)
	self.ctx = ctx
end

function MenuUIController:Start()
	gui = UiKit.New("ScreenGui", {
		Name = "MenuGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 2,
		Parent = player.PlayerGui,
	})
end

function MenuUIController:Stop()
	if gui then
		gui:Destroy()
	end
end

return MenuUIController
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — MenuUIController (client, ModuleScript)
	Full-screen panels: Shop (rods/baits/upgrades), Pearls (cosmetics),
	Store (Robux gamepasses + dev products), Bestiary, Bag (filters/sort),
	Quests, Achievements, Contest, Travel, Profile (titles + stats).
	All prices/stats come from shared catalogs — nothing hardcoded here.
	Phase 7 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)
local QuestCatalog = require(ReplicatedStorage.Shared.Data.QuestCatalog)
local CosmeticsCatalog = require(ReplicatedStorage.Shared.Data.CosmeticsCatalog)

local MenuUIController = {}
MenuUIController.Name = "MenuUIController"

local player = Players.LocalPlayer
local gui: ScreenGui
local openPanel: string? = nil
local panelFrame: Frame?
local zoneFilter = "sunshall"
local currentDetail: string? = nil
local shopTab = "rods"
local bagFilter = "all"
local bagSort = "new"
local contestRequested = false

local ZONE_ORDER = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }
local AUTO_SELL_OPTIONS = { "off", "common", "uncommon", "rare" }
local BAG_FILTERS = { "all", "common", "uncommon", "rare", "epic", "legendary", "shiny" }

-- ── Core panel scaffolding ───────────────────────────────────────────────

local function makePanel(title: string): Frame
	if panelFrame then
		panelFrame:Destroy()
	end
	local panel = UiKit.Frame(gui, UDim2.fromScale(0.8, 0.86), UDim2.fromScale(0.5, 0.5), Theme.Bg, 18)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panelFrame = panel
	UiKit.Label(panel, title, UDim2.fromScale(0.5, 0.06), UDim2.fromScale(0.25, 0.01), Theme.Text, Theme.FontTitle, 24)
	UiKit.Button(panel, "✕", function()
		MenuUIController:Close()
	end, { size = UDim2.fromScale(0.05, 0.05), pos = UDim2.fromScale(0.94, 0.01), color = Theme.Danger, textSize = 16 })
	return panel
end

function MenuUIController:Open(name: string)
	openPanel = name
	ClientState:Get().uiOpen = true
	if name == "contest" then
		contestRequested = false
	end
	self:Refresh()
end

function MenuUIController:Close()
	openPanel = nil
	ClientState:Get().uiOpen = false
	if panelFrame then
		panelFrame:Destroy()
		panelFrame = nil
	end
end

function MenuUIController:Toggle(name: string)
	if openPanel == name then
		self:Close()
	else
		self:Open(name)
	end
end

-- ══════════════════════ SHOP ══════════════════════

local function shopRodsTab(panel: Frame)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.12), 6)
	local s = ClientState:Get()
	for _, rod in ipairs(RodCatalog.GetSorted()) do
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.9, 0.13), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, rod.name, UDim2.fromScale(0.3, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 17)
		UiKit.Label(row, "Luck +" .. math.floor(rod.luck * 100) .. "%  •  Str " .. rod.strength .. "  •  Lure -" .. rod.lure .. "s",
			UDim2.fromScale(0.44, 0.5), UDim2.fromScale(0.32, 0.05), Theme.TextDim, nil, 13)
		local owned = s.rods[rod.id] == true
		local equipped = s.equippedRod == rod.id
		local affordable = s.coins >= rod.cost
		local levelOk = s.level >= rod.unlockLevel
		local statusText = if equipped then "EQUIPPED"
			elseif owned then "Equip"
			else "Buy • " .. Util.formatNumber(rod.cost) .. " 🪙"
		if not owned and not affordable then
			statusText = statusText .. "\n(need " .. Util.formatNumber(rod.cost - s.coins) .. " more)"
		end
		if not owned and not levelOk then
			statusText = statusText .. "\n(Lv " .. rod.unlockLevel .. " req)"
		end
		local btn = UiKit.Button(row, statusText, function()
			if owned then
				ClientState:Send("EquipRod", { rodId = rod.id })
				MenuUIController:Refresh()
			elseif levelOk then
				ClientState:Send("BuyRod", { rodId = rod.id })
				MenuUIController:Refresh()
			end
		end, { size = UDim2.fromScale(0.22, 0.72), pos = UDim2.fromScale(0.76, 0.14), color = if equipped then Theme.Accent2 elseif owned then Theme.Success elseif affordable then Theme.Accent else Theme.BgPanelLight, textSize = 12 })
	end
end

local function shopBaitsTab(panel: Frame)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.12), 6)
	local s = ClientState:Get()
	for id, def in pairs(Config.BAITS) do
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, def.name, UDim2.fromScale(0.25, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 16)
		UiKit.Label(row, "Price: " .. def.cost .. " 🪙 / " .. def.count .. "x   •   Owned: " .. (s.baits[id] or 0),
			UDim2.fromScale(0.45, 0.5), UDim2.fromScale(0.28, 0.05), Theme.TextDim, nil, 13)
		local equipped = s.equippedBait == id
		UiKit.Button(row, "Equip", function()
			ClientState:Send("EquipBait", { baitId = id })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.1, 0.6), pos = UDim2.fromScale(0.72, 0.2), color = if equipped then Theme.Accent2 else Theme.Success, textSize = 12 })
		UiKit.Button(row, "+" .. def.count, function()
			ClientState:Send("BuyBait", { baitId = id, count = def.count })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.09, 0.6), pos = UDim2.fromScale(0.83, 0.2), color = Theme.Accent, textSize = 12 })
	end
	UiKit.Label(panel, "💡 Equipped bait is consumed per cast. Golden Lure: +luck & +weight!",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.93), Theme.TextDim, nil, 12)
end

local function shopUpgradesTab(panel: Frame)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.12), 6)
	local s = ClientState:Get()
	for i, def in ipairs(Config.INVENTORY_UPGRADES) do
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, "Tackle Box +" .. def.slots .. " slots", UDim2.fromScale(0.4, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 16)
		local tierOwned = s.invUpgradeTier >= i
		local canBuy = s.invUpgradeTier + 1 == i
		local btnText = if tierOwned then "OWNED" else (if canBuy then "Upgrade • " .. Util.formatNumber(def.cost) .. " 🪙" else "🔒")
		UiKit.Button(row, btnText, function()
			ClientState:Send("BuyUpgrade", { tier = i })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.22, 0.6), pos = UDim2.fromScale(0.76, 0.2), color = if canBuy then Theme.Accent else Theme.BgPanelLight, textSize = 12 })
	end
	UiKit.Label(panel, "The Bigger Tackle Box gamepass adds +50 slots instantly (Store tab).",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.93), Theme.TextDim, nil, 12)
end

local function shopPanel()
	local panel = makePanel("🎣 SHOP")
	local tabs = { { "rods", "Rods" }, { "baits", "Baits" }, { "upgrades", "Upgrades" } }
	for i, tab in ipairs(tabs) do
		UiKit.Button(panel, tab[2], function()
			shopTab = tab[1]
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.18, 0.05), pos = UDim2.fromScale(0.04 + 0.19 * (i - 1), 0.06), color = if shopTab == tab[1] then Theme.Accent else Theme.BgPanelLight, textSize = 14 })
	end
	if shopTab == "rods" then
		shopRodsTab(panel)
	elseif shopTab == "baits" then
		shopBaitsTab(panel)
	else
		shopUpgradesTab(panel)
	end
end

-- ══════════════════════ PEARLS (cosmetics) ══════════════════════

local KIND_ORDER = { "bobber", "trail", "aura", "rodSkin", "nameColor" }
local KIND_LABELS = {
	bobber = "Bobbers", trail = "Trails", aura = "Auras", rodSkin = "Rod Grips", nameColor = "Name Colors",
}

local function pearlsPanel()
	local panel = makePanel("🐚 PEARL SHOP")
	local s = ClientState:Get()
	UiKit.Label(panel, "Your pearls: " .. Util.formatNumber(s.pearls) .. " 🐚", UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.06), Theme.Accent, Theme.FontBold, 16)

	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.74), UDim2.fromScale(0.03, 0.13), 6)
	local yOffset = 0
	for _, kind in ipairs(KIND_ORDER) do
		UiKit.Label(scroll, "— " .. KIND_LABELS[kind] .. " —", UDim2.fromScale(0.9, 0.04), UDim2.fromScale(0.02, 0), Theme.TextDim, Theme.FontBold, 13)
		for _, def in ipairs(CosmeticsCatalog.GetByKind(kind)) do
			local owned = s.cosmeticsOwned[def.id] == true
			local equipped = s.cosmetics[def.kind] == def.id
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.92, 0.11), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			-- color swatch
			local swatch = UiKit.Frame(row, UDim2.fromScale(0.04, 0.5), UDim2.fromScale(0.02, 0.25), def.color, 4)
			swatch.BorderSizePixel = 0
			UiKit.Label(row, def.name, UDim2.fromScale(0.3, 0.5), UDim2.fromScale(0.08, 0.05), Theme.Text, Theme.FontBold, 15)
			UiKit.Label(row, def.desc, UDim2.fromScale(0.5, 0.4), UDim2.fromScale(0.08, 0.5), Theme.TextDim, nil, 11)
			local btnText = if equipped then "EQUIPPED" else (if owned then "Equip" else def.price .. " 🐚")
			UiKit.Button(row, btnText, function()
				if owned then
					ClientState:Send("EquipCosmetic", { cosmeticId = def.id })
				else
					ClientState:Send("BuyCosmetic", { cosmeticId = def.id })
				end
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.16, 0.6), pos = UDim2.fromScale(0.8, 0.2), color = if equipped then Theme.Accent2 elseif owned then Theme.Success else Theme.Accent, textSize = 12 })
		end
	end
	UiKit.Label(panel, "Cosmetics are visual only — they never affect your catch rates.",
		UDim2.fromScale(0.9, 0.04), UDim2.fromScale(0.05, 0.9), Theme.TextDim, nil, 12)
end

-- ══════════════════════ STORE (Robux) ══════════════════════

local function storePanel()
	local panel = makePanel("🛒 STORE")
	local s = ClientState:Get()
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.8), UDim2.fromScale(0.03, 0.08), 6)

	local passNames = {
		double_catch = "Double Catch — 2x coins from selling fish",
		bigger_tackle_box = "Bigger Tackle Box — +50 inventory slots",
		lucky_charm = "Lucky Charm — +15% luck (capped, fair)",
		vip_angler = "VIP Angler — +10% XP, exclusive rod skin, gold name",
		golden_lure_pass = "Golden Lure Pass — permanent best bait",
		starter_pack = "Starter Pack — 500 coins + 5 Golden Lures + bobber",
	}
	local productNames = {
		pearls_100 = "100 Pearls",
		pearls_450 = "450 Pearls",
		pearls_1000 = "1000 Pearls",
		auto_reel_tokens = "Auto-Reel Tokens (x100)",
		xp_boost_2h = "XP Boost (2 hours)",
	}

	local shown = 0
	for key, id in pairs(Config.GAMEPASS_IDS) do
		if id > 0 then
			shown += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.92, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, passNames[key] or key, UDim2.fromScale(0.72, 0.6), UDim2.fromScale(0.03, 0.1), Theme.Text, Theme.FontBold, 14)
			local owned = s.cosmeticsOwned["pass_" .. key] == true
			UiKit.Button(row, "Get", function()
				pcall(function()
					MarketplaceService:PromptGamePassPurchase(player, id)
				end)
			end, { size = UDim2.fromScale(0.14, 0.6), pos = UDim2.fromScale(0.8, 0.2), color = Theme.Accent2, textSize = 13 })
		end
	end
	for key, id in pairs(Config.PRODUCT_IDS) do
		if id > 0 then
			shown += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.92, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, productNames[key] or key, UDim2.fromScale(0.72, 0.6), UDim2.fromScale(0.03, 0.1), Theme.Text, Theme.FontBold, 14)
			UiKit.Button(row, "Get", function()
				pcall(function()
					MarketplaceService:PromptProductPurchase(player, id)
				end)
			end, { size = UDim2.fromScale(0.14, 0.6), pos = UDim2.fromScale(0.8, 0.2), color = Theme.Accent, textSize = 13 })
		end
	end
	if shown == 0 then
		UiKit.Label(scroll, "The store is being stocked — the pearl shop is already open! 🐚",
			UDim2.fromScale(0.9, 0.08), UDim2.fromScale(0.03, 0.05), Theme.TextDim, nil, 14)
	end
	UiKit.Label(panel, "All purchases are one-time, cosmetic or time-saving. Nothing is pay-to-win.",
		UDim2.fromScale(0.9, 0.04), UDim2.fromScale(0.05, 0.9), Theme.TextDim, nil, 12)
end

-- ══════════════════════ BESTIARY ══════════════════════

local function zoneCompletion(zoneId: string): number
	local s = ClientState:Get()
	local zone = ZoneCatalog.Get(zoneId)
	if not zone then
		return 0
	end
	local total = #zone.fishIds
	local caught = 0
	for _, fishId in ipairs(zone.fishIds) do
		local entry = s.bestiary[fishId]
		if entry and entry.caught > 0 then
			caught += 1
		end
	end
	if total == 0 then
		return 0
	end
	return math.floor(caught / total * 100)
end

local function bestiaryGrid(panel: Frame, zoneId: string)
	UiKit.Label(panel, "Zone completion: " .. zoneCompletion(zoneId) .. "%", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.04, 0.1), Theme.Accent, Theme.FontBold, 15)
	UiKit.Label(panel, "💡 Shiny variants exist for every fish. Complete zones for pearl rewards!",
		UDim2.fromScale(0.8, 0.05), UDim2.fromScale(0.04, 0.15), Theme.TextDim, nil, 12)
	local zone = ZoneCatalog.Get(zoneId)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.72), UDim2.fromScale(0.03, 0.22), 8)
	UiKit.New("UIGridLayout", {
		CellSize = UDim2.fromScale(0.23, 0.28),
		CellPadding = UDim2.fromScale(0.015, 0.02),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroll,
	})
	local s = ClientState:Get()
	for _, fishId in ipairs(zone.fishIds) do
		local def = FishCatalog.Get(fishId)
		local entry = s.bestiary[fishId]
		local caught = entry and entry.caught or 0
		local tile = UiKit.Frame(scroll, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.BgPanel, 10)
		if caught == 0 then
			tile.BackgroundColor3 = Theme.BgPanelLight
			tile.BackgroundTransparency = 0.6
		end
		UiKit.Frame(tile, UDim2.fromScale(1, 0.04), UDim2.fromScale(0, 0), Theme.Rarity[def.rarity], 0)
		UiKit.Label(tile, if caught > 0 then def.name else "???", UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0.25), if caught > 0 then Theme.Text else Theme.TextDim, Theme.FontBold, 13)
		UiKit.Label(tile, "caught: " .. caught .. (entry and entry.shiny and " ✨" or ""), UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.55), Theme.TextDim, nil, 11)
		local btn = UiKit.Button(tile, "View", function()
			currentDetail = fishId
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.6, 0.2), pos = UDim2.fromScale(0.2, 0.76), color = Theme.BgPanelLight, textSize = 11 })
		if caught == 0 then
			btn.BackgroundTransparency = 0.7
		end
	end
end

local function bestiaryDetail(panel: Frame, fishId: string)
	local def = FishCatalog.Get(fishId)
	local s = ClientState:Get()
	local entry = s.bestiary[fishId]
	local caught = entry and entry.caught or 0
	local shinyCaught = entry and entry.shiny or false
	UiKit.Button(panel, "← Back", function()
		currentDetail = nil
		MenuUIController:Refresh()
	end, { size = UDim2.fromScale(0.1, 0.05), pos = UDim2.fromScale(0.02, 0.06), color = Theme.BgPanelLight, textSize = 14 })
	local vp = UiKit.New("ViewportFrame", {
		Name = "DetailViewport",
		Size = UDim2.fromScale(0.4, 0.42),
		Position = UDim2.fromScale(0.05, 0.14),
		BackgroundColor3 = Theme.Bg,
		Parent = panel,
	})
	local ok, model = pcall(FishVisuals.Build, fishId, shinyCaught)
	if ok and model then
		model.Parent = vp
		vp.CurrentCamera = Instance.new("Camera")
		vp.CurrentCamera.CFrame = FishVisuals.FrameCamera(model, 4)
	end
	local zoneName = ZoneCatalog.Get(def.zone)
	UiKit.Label(panel, def.name .. (shinyCaught and " ✨" or ""), UDim2.fromScale(0.5, 0.07), UDim2.fromScale(0.48, 0.14), Theme.Rarity[def.rarity], Theme.FontTitle, 22)
	UiKit.Label(panel, (Theme.RarityName[def.rarity] or ""):upper() .. " • " .. (zoneName and zoneName.name or def.zone),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.21), Theme.TextDim, Theme.FontBold, 13)
	UiKit.Label(panel, "⚖ " .. def.minWeight .. "–" .. def.maxWeight .. " kg   •   💰 " .. def.baseValue .. " 🪙/kg   •   ✨ " .. def.xp .. " XP",
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.27), Theme.Text, nil, 13)
	UiKit.Label(panel, "🎯 Bait: " .. (def.bait and (Config.BAITS[def.bait] and Config.BAITS[def.bait].name or def.bait) or "any"),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.33), Theme.TextDim, nil, 13)
	UiKit.Label(panel, "🌙 Night-only: " .. (def.time == "night" and "yes" or "no") .. (def.stormOnly and "   ⛈ Storm-only: yes" or ""),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.39), Theme.TextDim, nil, 13)
	UiKit.Label(panel, "📖 " .. def.desc, UDim2.fromScale(0.9, 0.16), UDim2.fromScale(0.48, 0.45), Theme.Text, nil, 14)
	UiKit.Label(panel, "Best: " .. (entry and entry.maxWeight or 0) .. " kg   •   Caught: " .. caught .. (shinyCaught and " (incl. SHINY)" or ""),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.62), Theme.Gold, Theme.FontBold, 14)
end

local function bestiaryPanel()
	local panel = makePanel("📖 BESTIARY")
	for i, zoneId in ipairs(ZONE_ORDER) do
		local zone = ZoneCatalog.Get(zoneId)
		UiKit.Button(panel, zone.name, function()
			zoneFilter = zoneId
			currentDetail = nil
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.16, 0.05), pos = UDim2.fromScale(0.02 + 0.1 * (i - 1), 0.06), color = if zoneFilter == zoneId then Theme.Accent else Theme.BgPanelLight, textSize = 11 })
	end
	if currentDetail then
		bestiaryDetail(panel, currentDetail)
	else
		bestiaryGrid(panel, zoneFilter)
	end
end

-- ══════════════════════ BAG ══════════════════════

local function matchesFilter(item: any, def: any): boolean
	if bagFilter == "all" then
		return true
	end
	if bagFilter == "shiny" then
		return item.shiny == true
	end
	return def.rarity == bagFilter
end

local function inventoryPanel()
	local panel = makePanel("🎒 BAG")
	local s = ClientState:Get()
	UiKit.Label(panel, "Capacity: " .. #s.inventory .. " / " .. s.invSlots, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.08), Theme.Text, Theme.FontBold, 14)
	local capBg = UiKit.Frame(panel, UDim2.fromScale(0.4, 0.03), UDim2.fromScale(0.04, 0.14), Theme.BgPanelLight, 6)
	UiKit.Frame(capBg, UDim2.fromScale(Util.clamp(#s.inventory / math.max(1, s.invSlots), 0, 1), 1), UDim2.fromScale(0, 0), Theme.Accent, 6)

	-- Filters
	for i, f in ipairs(BAG_FILTERS) do
		UiKit.Button(panel, f:upper(), function()
			bagFilter = f
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.08, 0.04), pos = UDim2.fromScale(0.04 + 0.085 * (i - 1), 0.18), color = if bagFilter == f then Theme.Accent2 else Theme.BgPanelLight, textSize = 10 })
	end
	-- Sort
	UiKit.Button(panel, if bagSort == "new" then "Newest" else "Biggest", function()
		bagSort = if bagSort == "new" then "big" else "new"
		MenuUIController:Refresh()
	end, { size = UDim2.fromScale(0.1, 0.04), pos = UDim2.fromScale(0.72, 0.18), color = Theme.BgPanelLight, textSize = 10 })

	-- Auto-sell
	UiKit.Label(panel, "Auto-sell (≤ rarity):", UDim2.fromScale(0.18, 0.04), UDim2.fromScale(0.04, 0.24), Theme.TextDim, nil, 12)
	for i, opt in ipairs(AUTO_SELL_OPTIONS) do
		UiKit.Button(panel, opt:upper(), function()
			ClientState:Send("SetAutoSell", { maxRarity = opt == "off" and nil or opt })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.09, 0.04), pos = UDim2.fromScale(0.22 + 0.095 * (i - 1), 0.24), color = if (s.autoSell or "off") == opt then Theme.Accent2 else Theme.BgPanelLight, textSize = 10 })
	end

	-- Bulk sell
	local bulk = { { "common", "Sell Commons" }, { "uncommon", "Sell Uncommons" }, { "rare", "Sell Rares" }, { "all", "Sell All (keeps ✨)" } }
	for i, b in ipairs(bulk) do
		UiKit.Button(panel, b[2], function()
			ClientState:Send("SellAll", { maxRarity = if b[1] == "all" then "epic" else b[1] })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.19, 0.045), pos = UDim2.fromScale(0.04 + 0.2 * (i - 1), 0.29), color = Theme.Accent, textSize = 12 })
	end

	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.58), UDim2.fromScale(0.04, 0.36), 6)
	local items = s.inventory
	table.sort(items, function(a, b)
		if bagSort == "big" then
			return a.weight > b.weight
		end
		return a.caughtAt > b.caughtAt
	end)
	local shown = 0
	for _, item in ipairs(items) do
		local def = FishCatalog.Get(item.fishId)
		if def and matchesFilter(item, def) then
			shown += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.95, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Frame(row, UDim2.fromScale(0.02, 0.7), UDim2.fromScale(0.01, 0.15), Theme.Rarity[def.rarity], 2)
			UiKit.Label(row, (item.shiny and "✨ " or "") .. def.name, UDim2.fromScale(0.3, 1), UDim2.fromScale(0.05, 0), Theme.Text, Theme.FontBold, 13)
			UiKit.Label(row, item.weight .. " kg  •  ~" .. Util.formatNumber(math.floor(def.baseValue * item.weight * (item.shiny and Config.SHINY_VALUE_MULT or 1))) .. " 🪙",
				UDim2.fromScale(0.4, 0.6), UDim2.fromScale(0.38, 0.05), Theme.TextDim, nil, 12)
			UiKit.Button(row, "Sell", function()
				ClientState:Send("SellFish", { ids = { item.uid } })
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.12, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = Theme.Danger, textSize = 12 })
		end
	end
	if shown == 0 then
		UiKit.Label(scroll, "No fish match this filter. Go catch some! 🎣", UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0), Theme.TextDim, nil, 14)
	end
end

-- ══════════════════════ QUESTS ══════════════════════

local function questRow(parent: Instance, q: any, template: any, desc: string, claimFn: () -> ())
	local row = UiKit.Frame(parent, UDim2.fromScale(0.95, 0.11), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
	UiKit.Label(row, desc, UDim2.fromScale(0.72, 0.5), UDim2.fromScale(0.02, 0.05), Theme.Text, Theme.FontBold, 14)
	local progress = template and math.min(q.progress / template.target, 1) or 0
	local barBg = UiKit.Frame(row, UDim2.fromScale(0.72, 0.16), UDim2.fromScale(0.02, 0.55), Theme.BgPanelLight, 4)
	UiKit.Frame(barBg, UDim2.fromScale(progress, 1), UDim2.fromScale(0, 0), Theme.Accent, 4)
	UiKit.Label(row, Util.formatNumber(q.progress) .. "/" .. (template and Util.formatNumber(template.target) or "?"), UDim2.fromScale(0.2, 0.3), UDim2.fromScale(0.54, 0.6), Theme.TextDim, nil, 11)
	local btn = UiKit.Button(row, if q.claimed then "✓" else (if q.done then "Claim" else "…"), claimFn,
		{ size = UDim2.fromScale(0.14, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = if q.claimed then Theme.BgPanelLight elseif q.done then Theme.Success else Theme.BgPanelLight, textSize = 12 })
	if q.claimed then
		btn.TextColor3 = Theme.TextDim
	end
	return row
end

local function questsPanel()
	local panel = makePanel("📜 QUESTS")
	local s = ClientState:Get()
	UiKit.Label(panel, "🔥 Login streak: Day " .. s.streak, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.07), Theme.Accent2, Theme.FontBold, 16)
	for i = 1, 7 do
		local reward = Config.STREAK_REWARDS[i]
		local day = UiKit.Frame(panel, UDim2.fromScale(0.06, 0.09), UDim2.fromScale(0.04 + 0.07 * (i - 1), 0.13), if i == s.streak then Theme.Accent2 elseif i < s.streak then Theme.Success else Theme.BgPanelLight, 30)
		if i < s.streak then
			day.BackgroundTransparency = 0.4
		end
		UiKit.Label(day, "D" .. i, UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0.05), Theme.Text, Theme.FontBold, 12)
		local rewardText = ""
		if reward.coins then
			rewardText = reward.coins .. "🪙"
		end
		if reward.pearls then
			rewardText = rewardText .. (rewardText ~= "" and " " or "") .. reward.pearls .. "🐚"
		end
		UiKit.Label(day, rewardText, UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0.5), Theme.TextDim, nil, 9)
	end
	UiKit.Label(panel, "DAILY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.23), Theme.Accent, Theme.FontTitle, 14)
	local dailyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.28), 4)
	for i, q in ipairs(s.dailyQuests) do
		local template = QuestCatalog.GetDailyTemplate(q.templateId)
		local desc = q.templateId
		if template then
			desc = template.desc
			desc = string.gsub(desc, "{n}", tostring(template.target))
			if q.params and q.params.zone then
				local zn = ZoneCatalog.Get(q.params.zone)
				desc = string.gsub(desc, "{zone}", (zn and zn.name or q.params.zone))
			end
			if q.params and q.params.family then
				desc = string.gsub(desc, "{family}", q.params.family)
			end
		end
		questRow(dailyScroll, q, template, desc, function()
			ClientState:Send("ClaimDaily", { slot = i })
			MenuUIController:Refresh()
		end)
	end
	UiKit.Button(panel, "↻ Reroll one daily (1/day)", function()
		ClientState:Send("RerollQuest", { slot = 1 })
		MenuUIController:Refresh()
	end, { size = UDim2.fromScale(0.3, 0.045), pos = UDim2.fromScale(0.62, 0.23), color = Theme.BgPanelLight, textSize = 12 })
	UiKit.Label(panel, "WEEKLY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.59), Theme.Gold, Theme.FontTitle, 14)
	local weeklyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.64), 4)
	for i, q in ipairs(s.weeklyQuests) do
		local template = QuestCatalog.GetWeeklyTemplate(q.templateId)
		local desc = q.templateId
		if template then
			desc = string.gsub(template.desc, "{n}", tostring(template.target))
		end
		questRow(weeklyScroll, q, template, desc, function()
			ClientState:Send("ClaimWeekly", { slot = i })
			MenuUIController:Refresh()
		end)
	end
end

-- ══════════════════════ ACHIEVEMENTS ══════════════════════

local function achievementsPanel()
	local panel = makePanel("🏅 ACHIEVEMENTS")
	local s = ClientState:Get()
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.82), UDim2.fromScale(0.03, 0.08), 6)
	local unlockedCount = 0
	for _, def in pairs(QuestCatalog.ACHIEVEMENTS) do
		local done = s.achievements[def.id] == true
		if done then
			unlockedCount += 1
		end
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.94, 0.1), UDim2.fromScale(0, 0), if done then Theme.BgPanel else Theme.BgPanelLight, 8)
		if not done then
			row.BackgroundTransparency = 0.5
		end
		UiKit.Label(row, (done and "🏅 " or "🔒 ") .. def.name, UDim2.fromScale(0.4, 0.6), UDim2.fromScale(0.03, 0.05), if done then Theme.Gold else Theme.TextDim, Theme.FontBold, 14)
		UiKit.Label(row, def.desc, UDim2.fromScale(0.45, 0.5), UDim2.fromScale(0.03, 0.5), Theme.TextDim, nil, 11)
		local rewardText = ""
		if def.rewards.pearls then
			rewardText = rewardText .. def.rewards.pearls .. " 🐚"
		end
		if def.rewards.title then
			rewardText = rewardText .. (rewardText ~= "" and " + " or "") .. "Title: " .. def.rewards.title
		end
		UiKit.Label(row, rewardText, UDim2.fromScale(0.28, 0.5), UDim2.fromScale(0.7, 0.5), Theme.Accent, nil, 11)
	end
	UiKit.Label(panel, "Unlocked: " .. unlockedCount .. " / " .. #QuestCatalog.ACHIEVEMENTS,
		UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.03, 0.02), Theme.Text, Theme.FontBold, 14)
end

-- ══════════════════════ CONTEST ══════════════════════

local function contestPanel()
	local panel = makePanel("🏆 WEEKLY CONTEST")
	local s = ClientState:Get()
	if not contestRequested then
		contestRequested = true
		ClientState:Send("GetContestTop")
	end
	UiKit.Label(panel, "Biggest catch of the week wins! Week: " .. (s.contestTop and s.contestTop.week or "…"),
		UDim2.fromScale(0.6, 0.05), UDim2.fromScale(0.04, 0.06), Theme.Accent2, Theme.FontBold, 14)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.68), UDim2.fromScale(0.03, 0.13), 6)
	local entries = s.contestTop and s.contestTop.entries or nil
	if entries and #entries > 0 then
		for i, e in ipairs(entries) do
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.94, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, (i == 1 and "🥇 " or i == 2 and "🥈 " or i == 3 and "🥉 " or "   ") .. "#" .. i .. "  " .. e.name,
				UDim2.fromScale(0.6, 1), UDim2.fromScale(0.03, 0), if i <= 3 then Theme.Gold else Theme.Text, Theme.FontBold, 15)
			UiKit.Label(row, Util.formatNumber(e.score) .. " pts", UDim2.fromScale(0.25, 1), UDim2.fromScale(0.72, 0), Theme.Accent, Theme.FontBold, 14)
		end
	else
		UiKit.Label(scroll, "No catches yet this week — be the first! 🎣", UDim2.fromScale(0.9, 0.1), UDim2.fromScale(0.05, 0.05), Theme.TextDim, nil, 14)
	end
	UiKit.Button(panel, "↻ Refresh", function()
		contestRequested = true
		ClientState:Send("GetContestTop")
		task.delay(0.5, function()
			MenuUIController:Refresh()
		end)
	end, { size = UDim2.fromScale(0.16, 0.05), pos = UDim2.fromScale(0.42, 0.84), color = Theme.Accent, textSize = 13 })
	UiKit.Label(panel, "Top 10 win pearls every Monday. Score = weight × rarity bonus.",
		UDim2.fromScale(0.8, 0.05), UDim2.fromScale(0.1, 0.9), Theme.TextDim, nil, 12)
end

-- ══════════════════════ TRAVEL ══════════════════════

local function travelPanel()
	local panel = makePanel("🗺 TRAVEL")
	local s = ClientState:Get()
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.76), UDim2.fromScale(0.03, 0.1), 6)
	for _, zoneId in ipairs(ZONE_ORDER) do
		local zone = ZoneCatalog.Get(zoneId)
		local unlocked = s.level >= zone.unlockLevel
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.95, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, zone.name, UDim2.fromScale(0.5, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 16)
		UiKit.Label(row, if unlocked then "Level " .. zone.unlockLevel .. " • Ready" else "Requires level " .. zone.unlockLevel,
			UDim2.fromScale(0.3, 0.6), UDim2.fromScale(0.5, 0.05), if unlocked then Theme.Success else Theme.TextDim, nil, 13)
		UiKit.Button(row, "Go! ⚡", function()
			ClientState:Send("FastTravel", { zone = zoneId })
			MenuUIController:Close()
		end, { size = UDim2.fromScale(0.16, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = if unlocked then Theme.Accent else Theme.BgPanelLight, textSize = 13 })
	end
	UiKit.Label(panel, "Fast travel is free — unlock zones by leveling up!",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.88), Theme.TextDim, nil, 13)
end

-- ══════════════════════ PROFILE ══════════════════════

local function profilePanel()
	local panel = makePanel("👤 PROFILE")
	local s = ClientState:Get()
	UiKit.Label(panel, player.Name .. (s.equippedTitle and (" — " .. s.equippedTitle) or ""),
		UDim2.fromScale(0.6, 0.06), UDim2.fromScale(0.2, 0.04), Theme.Text, Theme.FontTitle, 22)

	-- Stats
	local st = s.stats or {}
	local statsText = string.format(
		"Fish caught: %s   •   Coins earned: %s   •   Pearls earned: %s\nShinies: %s   •   Storm fish: %s   •   Night fish: %s   •   Deep fish: %s",
		Util.formatNumber(st.totalCatch or 0),
		Util.formatNumber(st.totalCoinsEarned or 0),
		Util.formatNumber(st.totalPearlsEarned or 0),
		Util.formatNumber(st.shinyFish or 0),
		Util.formatNumber(st.stormFish or 0),
		Util.formatNumber(st.nightFish or 0),
		Util.formatNumber(st.deepFish or 0)
	)
	UiKit.Label(panel, statsText, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0.05, 0.12), Theme.Text, nil, 13)
	local bc = st.bestCatch
	if bc and bc.fishId ~= "" then
		local bdef = FishCatalog.Get(bc.fishId)
		UiKit.Label(panel, "🏆 Best catch: " .. (bdef and bdef.name or bc.fishId) .. " — " .. bc.weight .. " kg",
			UDim2.fromScale(0.6, 0.05), UDim2.fromScale(0.05, 0.24), Theme.Gold, Theme.FontBold, 14)
	end

	-- Titles
	UiKit.Label(panel, "TITLES", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.05, 0.3), Theme.Accent, Theme.FontTitle, 14)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.9, 0.5), UDim2.fromScale(0.05, 0.35), 6)
	local titleCount = 0
	for title, owned in pairs(s.titles) do
		if owned then
			titleCount += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.94, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, title, UDim2.fromScale(0.6, 1), UDim2.fromScale(0.03, 0), Theme.Text, Theme.FontBold, 14)
			local equipped = s.equippedTitle == title
			UiKit.Button(row, if equipped then "EQUIPPED" else "Equip", function()
				ClientState:Send("EquipTitle", { title = title })
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.18, 0.6), pos = UDim2.fromScale(0.78, 0.2), color = if equipped then Theme.Accent2 else Theme.Success, textSize = 12 })
		end
	end
	if titleCount == 0 then
		UiKit.Label(scroll, "No titles yet. Complete achievements to earn them!", UDim2.fromScale(0.9, 0.1), UDim2.fromScale(0.05, 0.05), Theme.TextDim, nil, 13)
	end
end

-- ══════════════════════ Refresh & lifecycle ══════════════════════

function MenuUIController:Refresh()
	if not openPanel then
		return
	end
	makePanel("")
	if openPanel == "shop" then
		shopPanel()
	elseif openPanel == "pearls" then
		pearlsPanel()
	elseif openPanel == "store" then
		storePanel()
	elseif openPanel == "bestiary" then
		bestiaryPanel()
	elseif openPanel == "inventory" then
		inventoryPanel()
	elseif openPanel == "quests" then
		questsPanel()
	elseif openPanel == "achievements" then
		achievementsPanel()
	elseif openPanel == "contest" then
		contestPanel()
	elseif openPanel == "travel" then
		travelPanel()
	elseif openPanel == "profile" then
		profilePanel()
	end
end

function MenuUIController:Init(ctx)
	self.ctx = ctx
end

function MenuUIController:Start()
	gui = UiKit.New("ScreenGui", {
		Name = "MenuGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 2,
		Parent = player.PlayerGui,
	})
end

function MenuUIController:Stop()
	if gui then
		gui:Destroy()
	end
end

return MenuUIController
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/MenuUIController')
end

-- StarterPlayer/StarterPlayerScripts/Modules/Theme
local inst = ensure('StarterPlayer/StarterPlayerScripts/Modules/Theme', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Theme (client)
	Single source of UI colors/fonts so every panel looks consistent.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = {
	Bg = Color3.fromRGB(10, 22, 36),
	BgPanel = Color3.fromRGB(20, 38, 58),
	BgPanelLight = Color3.fromRGB(30, 52, 76),
	Accent = Color3.fromRGB(64, 210, 210),
	Accent2 = Color3.fromRGB(255, 190, 60),
	Text = Color3.fromRGB(235, 245, 255),
	TextDim = Color3.fromRGB(150, 170, 190),
	Danger = Color3.fromRGB(255, 96, 96),
	Success = Color3.fromRGB(96, 220, 130),
	Storm = Color3.fromRGB(150, 180, 255),
	Night = Color3.fromRGB(120, 100, 220),
	Gold = Color3.fromRGB(255, 210, 90),
	Rarity = {
		common = Color3.fromRGB(178, 188, 198),
		uncommon = Color3.fromRGB(110, 212, 122),
		rare = Color3.fromRGB(92, 162, 255),
		epic = Color3.fromRGB(192, 112, 255),
		legendary = Color3.fromRGB(255, 200, 64),
		mythic = Color3.fromRGB(255, 92, 130),
	},
	RarityName = {
		common = "Common",
		uncommon = "Uncommon",
		rare = "Rare",
		epic = "Epic",
		legendary = "Legendary",
		mythic = "Mythic",
	},
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
	FontTitle = Enum.Font.GothamBlack,
}

return Theme
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Theme (client)
	Single source of UI colors/fonts so every panel looks consistent.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = {
	Bg = Color3.fromRGB(10, 22, 36),
	BgPanel = Color3.fromRGB(20, 38, 58),
	BgPanelLight = Color3.fromRGB(30, 52, 76),
	Accent = Color3.fromRGB(64, 210, 210),
	Accent2 = Color3.fromRGB(255, 190, 60),
	Text = Color3.fromRGB(235, 245, 255),
	TextDim = Color3.fromRGB(150, 170, 190),
	Danger = Color3.fromRGB(255, 96, 96),
	Success = Color3.fromRGB(96, 220, 130),
	Storm = Color3.fromRGB(150, 180, 255),
	Night = Color3.fromRGB(120, 100, 220),
	Gold = Color3.fromRGB(255, 210, 90),
	Rarity = {
		common = Color3.fromRGB(178, 188, 198),
		uncommon = Color3.fromRGB(110, 212, 122),
		rare = Color3.fromRGB(92, 162, 255),
		epic = Color3.fromRGB(192, 112, 255),
		legendary = Color3.fromRGB(255, 200, 64),
		mythic = Color3.fromRGB(255, 92, 130),
	},
	RarityName = {
		common = "Common",
		uncommon = "Uncommon",
		rare = "Rare",
		epic = "Epic",
		legendary = "Legendary",
		mythic = "Mythic",
	},
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
	FontTitle = Enum.Font.GothamBlack,
}

return Theme
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Modules/Theme')
end

-- StarterPlayer/StarterPlayerScripts/Modules/UiKit
local inst = ensure('StarterPlayer/StarterPlayerScripts/Modules/UiKit', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — UiKit (client)
	One toolkit for building UI: frames, labels, buttons, scrolling lists.
	Every controller uses this — no duplicated UI code anywhere.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = require(script.Parent.Theme)

local UiKit = {}

-- Generic instance builder with property table
function UiKit.New(className: string, props: { [string]: any }?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

-- Frame with optional corner radius + automatic UIListLayout
function UiKit.Frame(parent: Instance, size: UDim2, pos: UDim2, color: Color3?, radius: number?): Frame
	local f = UiKit.New("Frame", {
		Name = "Frame",
		Size = size,
		Position = pos,
		BackgroundColor3 = color or Theme.BgPanel,
		BorderSizePixel = 0,
		Parent = parent,
	})
	if radius and radius > 0 then
		UiKit.New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = f })
	end
	return f
end

-- Label
function UiKit.Label(parent: Instance, text: string, size: UDim2, pos: UDim2, color: Color3?, font: Enum.Font?, textSize: number?): TextLabel
	return UiKit.New("TextLabel", {
		Name = "Label",
		Text = text,
		Size = size,
		Position = pos,
		BackgroundTransparency = 1,
		TextColor3 = color or Theme.Text,
		Font = font or Theme.Font,
		TextSize = textSize or 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	})
end

-- Button with hover feedback + click sound
function UiKit.Button(parent: Instance, text: string, onClick: () -> (), opts: { size: UDim2?, pos: UDim2?, color: Color3?, textSize: number? }?): TextButton
	local btn = UiKit.New("TextButton", {
		Name = "Button",
		Text = text,
		Size = opts and opts.size or UDim2.fromScale(0.5, 0.5),
		Position = opts and opts.pos or UDim2.fromScale(0, 0),
		BackgroundColor3 = opts and opts.color or Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = opts and opts.textSize or 16,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = parent,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	btn.MouseButton1Click:Connect(function()
		pcall(function()
			require(script.Parent.Parent.Controllers.AudioController):Play("ui_click")
		end)
		onClick()
	end)
	-- Hover feedback (guarded for stub environments)
	pcall(function()
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = (opts and opts.color or Theme.Accent):Lerp(Color3.new(1, 1, 1), 0.18)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = opts and opts.color or Theme.Accent
		end)
	end)
	return btn
end

-- Scrolling frame with list layout + padding
function UiKit.Scroll(parent: Instance, size: UDim2, pos: UDim2, padding: number?, bg: Color3?): ScrollingFrame
	local sf = UiKit.New("ScrollingFrame", {
		Name = "Scroll",
		Size = size,
		Position = pos,
		BackgroundColor3 = bg or Theme.BgPanelLight,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 6,
		Parent = parent,
	})
	UiKit.New("UIListLayout", {
		Padding = UDim.new(0, padding or 8),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sf,
	})
	UiKit.New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = sf })
	return sf
end

-- Row separator
function UiKit.Separator(parent: Instance, width: UDim2): Frame
	return UiKit.Frame(parent, width, UDim2.fromScale(0.5, 0), Theme.BgPanelLight, 0)
end

return UiKit
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — UiKit (client)
	One toolkit for building UI: frames, labels, buttons, scrolling lists.
	Every controller uses this — no duplicated UI code anywhere.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = require(script.Parent.Theme)

local UiKit = {}

-- Generic instance builder with property table
function UiKit.New(className: string, props: { [string]: any }?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

-- Frame with optional corner radius + automatic UIListLayout
function UiKit.Frame(parent: Instance, size: UDim2, pos: UDim2, color: Color3?, radius: number?): Frame
	local f = UiKit.New("Frame", {
		Name = "Frame",
		Size = size,
		Position = pos,
		BackgroundColor3 = color or Theme.BgPanel,
		BorderSizePixel = 0,
		Parent = parent,
	})
	if radius and radius > 0 then
		UiKit.New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = f })
	end
	return f
end

-- Label
function UiKit.Label(parent: Instance, text: string, size: UDim2, pos: UDim2, color: Color3?, font: Enum.Font?, textSize: number?): TextLabel
	return UiKit.New("TextLabel", {
		Name = "Label",
		Text = text,
		Size = size,
		Position = pos,
		BackgroundTransparency = 1,
		TextColor3 = color or Theme.Text,
		Font = font or Theme.Font,
		TextSize = textSize or 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	})
end

-- Button with hover feedback + click sound
function UiKit.Button(parent: Instance, text: string, onClick: () -> (), opts: { size: UDim2?, pos: UDim2?, color: Color3?, textSize: number? }?): TextButton
	local btn = UiKit.New("TextButton", {
		Name = "Button",
		Text = text,
		Size = opts and opts.size or UDim2.fromScale(0.5, 0.5),
		Position = opts and opts.pos or UDim2.fromScale(0, 0),
		BackgroundColor3 = opts and opts.color or Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = opts and opts.textSize or 16,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = parent,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	btn.MouseButton1Click:Connect(function()
		pcall(function()
			require(script.Parent.Parent.Controllers.AudioController):Play("ui_click")
		end)
		onClick()
	end)
	-- Hover feedback (guarded for stub environments)
	pcall(function()
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = (opts and opts.color or Theme.Accent):Lerp(Color3.new(1, 1, 1), 0.18)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = opts and opts.color or Theme.Accent
		end)
	end)
	return btn
end

-- Scrolling frame with list layout + padding
function UiKit.Scroll(parent: Instance, size: UDim2, pos: UDim2, padding: number?, bg: Color3?): ScrollingFrame
	local sf = UiKit.New("ScrollingFrame", {
		Name = "Scroll",
		Size = size,
		Position = pos,
		BackgroundColor3 = bg or Theme.BgPanelLight,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 6,
		Parent = parent,
	})
	UiKit.New("UIListLayout", {
		Padding = UDim.new(0, padding or 8),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sf,
	})
	UiKit.New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = sf })
	return sf
end

-- Row separator
function UiKit.Separator(parent: Instance, width: UDim2): Frame
	return UiKit.Frame(parent, width, UDim2.fromScale(0.5, 0), Theme.BgPanelLight, 0)
end

return UiKit
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Modules/UiKit')
end

-- StarterPlayer/StarterPlayerScripts/Modules/ClientState
local inst = ensure('StarterPlayer/StarterPlayerScripts/Modules/ClientState', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — ClientState (client)
	The client's cache of server state + the ONLY place UI reads numbers from.
	Server messages are applied here and listeners are notified (UI re-renders).
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local ClientState = {}

local state = {
	coins = 0,
	pearls = 0,
	xp = 0,
	level = 1,
	equippedRod = "bamboo",
	rods = {},
	baits = {},
	equippedBait = nil,
	tokens = 0,
	xpBoostUntil = 0,
	invUpgradeTier = 0,
	inventory = {},
	bestiary = {},
	globalPct = 0,
	autoSell = nil,
	invSlots = 40,
	dailyQuests = {},
	weeklyQuests = {},
	streak = 0,
	timeOfDay = "day",
	isStorm = false,
	stormIn = 0,
	achievements = {},
	titles = {},
	equippedTitle = nil,
	cosmetics = {},
	cosmeticsOwned = {},
	stats = {},
	contestTop = nil,
	goldenSpot = nil,
	uiOpen = false, -- true while a menu panel is open (blocks casting)
}

local listeners: { (string, any) -> () } = {}

function ClientState:Get()
	return state
end

function ClientState:Subscribe(cb: (string, any) -> ())
	table.insert(listeners, cb)
end

function ClientState:Notify(msgType: string, payload: any)
	for _, cb in pairs(listeners) do
		pcall(cb, msgType, payload)
	end
end

-- Client -> server (single choke point; types validated server-side)
function ClientState:Send(msgType: string, payload: any?)
	Remotes:SendToServer({ type = msgType, payload = payload })
end

-- Apply a server message to the cache. Returns true if anything changed.
function ClientState:Apply(msgType: string, payload: any): boolean
	if typeof(payload) ~= "table" then
		return false
	end
	if msgType == "StateSync" then
		state.coins = payload.coins or state.coins
		state.pearls = payload.pearls or state.pearls
		state.xp = payload.xp or state.xp
		state.level = payload.level or state.level
		state.equippedRod = payload.equippedRod or state.equippedRod
		if typeof(payload.rods) == "table" then
			state.rods = payload.rods
		end
		if typeof(payload.baits) == "table" then
			state.baits = payload.baits
		end
		state.equippedBait = payload.equippedBait
		state.tokens = payload.tokens or 0
		state.xpBoostUntil = payload.xpBoostUntil or 0
		state.invUpgradeTier = payload.invUpgradeTier or 0
	elseif msgType == "InventorySync" then
		if typeof(payload.inventory) == "table" then
			state.inventory = payload.inventory
		end
		if typeof(payload.bestiary) == "table" then
			state.bestiary = payload.bestiary
		end
		state.globalPct = payload.globalPct or 0
		state.autoSell = payload.autoSell
		state.invSlots = payload.invSlots or state.invSlots
		if typeof(payload.achievements) == "table" then
			state.achievements = payload.achievements
		end
		if typeof(payload.titles) == "table" then
			state.titles = payload.titles
		end
		state.equippedTitle = payload.equippedTitle
		if typeof(payload.cosmetics) == "table" then
			state.cosmetics = payload.cosmetics
		end
		if typeof(payload.cosmeticsOwned) == "table" then
			state.cosmeticsOwned = payload.cosmeticsOwned
		end
		if typeof(payload.stats) == "table" then
			state.stats = payload.stats
		end
	elseif msgType == "QuestUpdate" then
		if typeof(payload.daily) == "table" then
			state.dailyQuests = payload.daily
		end
		if typeof(payload.weekly) == "table" then
			state.weeklyQuests = payload.weekly
		end
		state.streak = payload.streak or 0
	elseif msgType == "WorldState" then
		state.timeOfDay = payload.timeOfDay or state.timeOfDay
		state.isStorm = payload.isStorm == true
		state.stormIn = payload.stormIn or 0
	elseif msgType == "GoldenSpot" then
		state.goldenSpot = payload
	elseif msgType == "ContestTop" then
		state.contestTop = payload
	else
		return false
	end
	self:Notify(msgType, payload)
	return true
end

return ClientState
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — ClientState (client)
	The client's cache of server state + the ONLY place UI reads numbers from.
	Server messages are applied here and listeners are notified (UI re-renders).
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local ClientState = {}

local state = {
	coins = 0,
	pearls = 0,
	xp = 0,
	level = 1,
	equippedRod = "bamboo",
	rods = {},
	baits = {},
	equippedBait = nil,
	tokens = 0,
	xpBoostUntil = 0,
	invUpgradeTier = 0,
	inventory = {},
	bestiary = {},
	globalPct = 0,
	autoSell = nil,
	invSlots = 40,
	dailyQuests = {},
	weeklyQuests = {},
	streak = 0,
	timeOfDay = "day",
	isStorm = false,
	stormIn = 0,
	achievements = {},
	titles = {},
	equippedTitle = nil,
	cosmetics = {},
	cosmeticsOwned = {},
	stats = {},
	contestTop = nil,
	goldenSpot = nil,
	uiOpen = false, -- true while a menu panel is open (blocks casting)
}

local listeners: { (string, any) -> () } = {}

function ClientState:Get()
	return state
end

function ClientState:Subscribe(cb: (string, any) -> ())
	table.insert(listeners, cb)
end

function ClientState:Notify(msgType: string, payload: any)
	for _, cb in pairs(listeners) do
		pcall(cb, msgType, payload)
	end
end

-- Client -> server (single choke point; types validated server-side)
function ClientState:Send(msgType: string, payload: any?)
	Remotes:SendToServer({ type = msgType, payload = payload })
end

-- Apply a server message to the cache. Returns true if anything changed.
function ClientState:Apply(msgType: string, payload: any): boolean
	if typeof(payload) ~= "table" then
		return false
	end
	if msgType == "StateSync" then
		state.coins = payload.coins or state.coins
		state.pearls = payload.pearls or state.pearls
		state.xp = payload.xp or state.xp
		state.level = payload.level or state.level
		state.equippedRod = payload.equippedRod or state.equippedRod
		if typeof(payload.rods) == "table" then
			state.rods = payload.rods
		end
		if typeof(payload.baits) == "table" then
			state.baits = payload.baits
		end
		state.equippedBait = payload.equippedBait
		state.tokens = payload.tokens or 0
		state.xpBoostUntil = payload.xpBoostUntil or 0
		state.invUpgradeTier = payload.invUpgradeTier or 0
	elseif msgType == "InventorySync" then
		if typeof(payload.inventory) == "table" then
			state.inventory = payload.inventory
		end
		if typeof(payload.bestiary) == "table" then
			state.bestiary = payload.bestiary
		end
		state.globalPct = payload.globalPct or 0
		state.autoSell = payload.autoSell
		state.invSlots = payload.invSlots or state.invSlots
		if typeof(payload.achievements) == "table" then
			state.achievements = payload.achievements
		end
		if typeof(payload.titles) == "table" then
			state.titles = payload.titles
		end
		state.equippedTitle = payload.equippedTitle
		if typeof(payload.cosmetics) == "table" then
			state.cosmetics = payload.cosmetics
		end
		if typeof(payload.cosmeticsOwned) == "table" then
			state.cosmeticsOwned = payload.cosmeticsOwned
		end
		if typeof(payload.stats) == "table" then
			state.stats = payload.stats
		end
	elseif msgType == "QuestUpdate" then
		if typeof(payload.daily) == "table" then
			state.dailyQuests = payload.daily
		end
		if typeof(payload.weekly) == "table" then
			state.weeklyQuests = payload.weekly
		end
		state.streak = payload.streak or 0
	elseif msgType == "WorldState" then
		state.timeOfDay = payload.timeOfDay or state.timeOfDay
		state.isStorm = payload.isStorm == true
		state.stormIn = payload.stormIn or 0
	elseif msgType == "GoldenSpot" then
		state.goldenSpot = payload
	elseif msgType == "ContestTop" then
		state.contestTop = payload
	else
		return false
	end
	self:Notify(msgType, payload)
	return true
end

return ClientState
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Modules/ClientState')
end

-- StarterPlayer/StarterPlayerScripts/Modules/FishVisuals
local inst = ensure('StarterPlayer/StarterPlayerScripts/Modules/FishVisuals', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — FishVisuals (client)
	Builds a low-poly procedural fish model from a FishDef — no external models.
	Used by the catch card (ViewportFrame) and bestiary details.
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local FishVisuals = {}

local function part(className: string, name: string, parent: Instance?, color: Color3?, size: Vector3?)
	local p = Instance.new(className)
	p.Name = name
	p.Parent = parent
	if color then
		p.Color = color
	end
	if size then
		p.Size = size
	end
	return p
end

-- Build a fish model. Returns the Model (unparented; caller parents it).
function FishVisuals.Build(fishId: string, shiny: boolean): Model
	local def = FishCatalog.Get(fishId)
	local model = Instance.new("Model")
	model.Name = "Fish_" .. fishId

	local color = def and def.color or Color3.fromRGB(120, 160, 200)
	local accent = def and def.accent or Color3.fromRGB(255, 255, 255)
	local scale = def and def.bodyScale or 1

	if shiny then
		color = Color3.fromRGB(
			math.min(255, color.R * 255 * 1.35 + 60),
			math.min(255, color.G * 255 * 1.35 + 60),
			math.min(255, color.B * 255 * 1.35 + 60)
		)
	end

	local length = 1.2 + scale * 0.8

	-- Body (slightly tapered via two wedges + core)
	local body = part("Part", "Body", model, color, Vector3.new(length, 0.5 + scale * 0.18, 0.35 + scale * 0.12))
	body.Shape = Enum.PartType.Block

	-- Belly (lighter)
	local belly = part("Part", "Belly", model, color:Lerp(Color3.new(1, 1, 1), 0.55), Vector3.new(length * 0.8, 0.18, 0.3 + scale * 0.1))

	-- Tail (accent wedge)
	local tail = part("WedgePart", "Tail", model, accent, Vector3.new(length * 0.32, 0.4 + scale * 0.14, 0.06))
	tail.Material = Enum.Material.SmoothPlastic

	-- Dorsal fin
	local fin = part("WedgePart", "DorsalFin", model, accent, Vector3.new(length * 0.25, 0.3, 0.05))

	-- Eyes
	local eyeL = part("Part", "EyeL", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeL.Shape = Enum.PartType.Ball
	local eyeR = part("Part", "EyeR", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeR.Shape = Enum.PartType.Ball

	-- Shiny sparkle trail
	if shiny then
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Name = "ShinySparkle"
		sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparkle.Rate = 24
		sparkle.Lifetime = NumberRange.new(0.6, 1.2)
		sparkle.Speed = NumberRange.new(0.5, 2)
		sparkle.Size = NumberRange.new(0.06, 0.18)
		sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 240, 160), Color3.fromRGB(255, 255, 255))
		sparkle.Transparency = NumberSequence.new(0.2, 1)
		sparkle.Parent = body
	end

	-- Layout: fish points +X (nose forward)
	body.CFrame = CFrame.new(0, 0, 0)
	belly.CFrame = CFrame.new(0, -0.28, 0)
	tail.CFrame = CFrame.new(-length * 0.62, 0.05, 0) * CFrame.Angles(0, math.pi / 2, 0)
	fin.CFrame = CFrame.new(0, 0.34, 0) * CFrame.Angles(-math.pi / 2.4, 0, 0)
	eyeL.CFrame = CFrame.new(length * 0.48, 0.08, 0.14)
	eyeR.CFrame = CFrame.new(length * 0.48, 0.08, -0.14)

	model.PrimaryPart = body
	return model
end

-- Center a model in a viewport: returns the camera CFrame to frame it.
function FishVisuals.FrameCamera(model: Model, distance: number): CFrame
	local pivot = model:GetPivot()
	local size = model:GetExtentsSize()
	local d = distance or (size.Magnitude + 2.5)
	return CFrame.new(pivot.Position + Vector3.new(0, 0.4, d), pivot.Position)
end

return FishVisuals
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — FishVisuals (client)
	Builds a low-poly procedural fish model from a FishDef — no external models.
	Used by the catch card (ViewportFrame) and bestiary details.
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local FishVisuals = {}

local function part(className: string, name: string, parent: Instance?, color: Color3?, size: Vector3?)
	local p = Instance.new(className)
	p.Name = name
	p.Parent = parent
	if color then
		p.Color = color
	end
	if size then
		p.Size = size
	end
	return p
end

-- Build a fish model. Returns the Model (unparented; caller parents it).
function FishVisuals.Build(fishId: string, shiny: boolean): Model
	local def = FishCatalog.Get(fishId)
	local model = Instance.new("Model")
	model.Name = "Fish_" .. fishId

	local color = def and def.color or Color3.fromRGB(120, 160, 200)
	local accent = def and def.accent or Color3.fromRGB(255, 255, 255)
	local scale = def and def.bodyScale or 1

	if shiny then
		color = Color3.fromRGB(
			math.min(255, color.R * 255 * 1.35 + 60),
			math.min(255, color.G * 255 * 1.35 + 60),
			math.min(255, color.B * 255 * 1.35 + 60)
		)
	end

	local length = 1.2 + scale * 0.8

	-- Body (slightly tapered via two wedges + core)
	local body = part("Part", "Body", model, color, Vector3.new(length, 0.5 + scale * 0.18, 0.35 + scale * 0.12))
	body.Shape = Enum.PartType.Block

	-- Belly (lighter)
	local belly = part("Part", "Belly", model, color:Lerp(Color3.new(1, 1, 1), 0.55), Vector3.new(length * 0.8, 0.18, 0.3 + scale * 0.1))

	-- Tail (accent wedge)
	local tail = part("WedgePart", "Tail", model, accent, Vector3.new(length * 0.32, 0.4 + scale * 0.14, 0.06))
	tail.Material = Enum.Material.SmoothPlastic

	-- Dorsal fin
	local fin = part("WedgePart", "DorsalFin", model, accent, Vector3.new(length * 0.25, 0.3, 0.05))

	-- Eyes
	local eyeL = part("Part", "EyeL", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeL.Shape = Enum.PartType.Ball
	local eyeR = part("Part", "EyeR", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeR.Shape = Enum.PartType.Ball

	-- Shiny sparkle trail
	if shiny then
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Name = "ShinySparkle"
		sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparkle.Rate = 24
		sparkle.Lifetime = NumberRange.new(0.6, 1.2)
		sparkle.Speed = NumberRange.new(0.5, 2)
		sparkle.Size = NumberRange.new(0.06, 0.18)
		sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 240, 160), Color3.fromRGB(255, 255, 255))
		sparkle.Transparency = NumberSequence.new(0.2, 1)
		sparkle.Parent = body
	end

	-- Layout: fish points +X (nose forward)
	body.CFrame = CFrame.new(0, 0, 0)
	belly.CFrame = CFrame.new(0, -0.28, 0)
	tail.CFrame = CFrame.new(-length * 0.62, 0.05, 0) * CFrame.Angles(0, math.pi / 2, 0)
	fin.CFrame = CFrame.new(0, 0.34, 0) * CFrame.Angles(-math.pi / 2.4, 0, 0)
	eyeL.CFrame = CFrame.new(length * 0.48, 0.08, 0.14)
	eyeR.CFrame = CFrame.new(length * 0.48, 0.08, -0.14)

	model.PrimaryPart = body
	return model
end

-- Center a model in a viewport: returns the camera CFrame to frame it.
function FishVisuals.FrameCamera(model: Model, distance: number): CFrame
	local pivot = model:GetPivot()
	local size = model:GetExtentsSize()
	local d = distance or (size.Magnitude + 2.5)
	return CFrame.new(pivot.Position + Vector3.new(0, 0.4, d), pivot.Position)
end

return FishVisuals
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Modules/FishVisuals')
end

-- Ensure folders exist (created on first run)
ensure('ReplicatedStorage/Shared', 'Folder')
ensure('ReplicatedStorage/Shared/Data', 'Folder')
ensure('ServerScriptService/Services', 'Folder')
ensure('StarterPlayer/StarterPlayerScripts/Controllers', 'Folder')
ensure('StarterPlayer/StarterPlayerScripts/Modules', 'Folder')

print("[Installer] Tidebound script tree ready! Now: build the map per src/README.md, then File > Publish to Roblox As...")