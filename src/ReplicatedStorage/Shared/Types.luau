--!strict
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
