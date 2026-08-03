--!strict
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
