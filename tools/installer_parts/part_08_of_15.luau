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

print("[Installer] Part 8/15 complete - next: 9")
