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

print("[Installer] Part 12/13 complete - next: 13")
