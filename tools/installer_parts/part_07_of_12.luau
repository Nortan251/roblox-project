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

function LeaderboardService:Init(ctx)
	self.ctx = ctx
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

function LeaderboardService:Init(ctx)
	self.ctx = ctx
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

print("[Installer] Part 7/12 complete - next: 8")
