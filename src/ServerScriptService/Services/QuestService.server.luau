--!strict
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
