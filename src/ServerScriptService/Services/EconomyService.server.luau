--!strict
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
