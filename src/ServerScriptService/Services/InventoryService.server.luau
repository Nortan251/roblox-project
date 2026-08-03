--!strict
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
