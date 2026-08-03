--!strict
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
