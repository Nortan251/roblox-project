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
	Full-screen panels: Shop (rods/baits/upgrades), Bestiary (zones + details),
	Inventory (sell/auto-sell), Quests (daily/weekly/streak).
	All prices/stats come from the shared catalogs — nothing hardcoded here.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)

local MenuUIController = {}
MenuUIController.Name = "MenuUIController"

local player = Players.LocalPlayer
local gui: ScreenGui
local openPanel: string? = nil
local panelFrame: Frame?
local zoneFilter = "sunshall"
local currentDetail: string? = nil

local ZONE_ORDER = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }
local AUTO_SELL_OPTIONS = { "off", "common", "uncommon", "rare" }

-- ── Core panel scaffolding ───────────────────────────────────────────────

local function makePanel(title: string): Frame
	-- Remove previous panel
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
	MenuUIController:Refresh()
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
		MenuUIController:Close()
	else
		self:Open(name)
	end
end

-- ══════════════════════ SHOP ══════════════════════

local shopTab = "rods"

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
		end, { size = UDim2.fromScale(0.22, 0.72), pos = UDim2.fromScale(0.76, 0.14), color = if owned then Theme.Success elseif affordable then Theme.Accent else Theme.BgPanelLight, textSize = 12 })
		if equipped then
			btn.BackgroundColor3 = Theme.Accent2
		end
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
	UiKit.Label(panel, "🛒 The Bigger Tackle Box gamepass adds +50 slots instantly (store, Phase 7).",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.93), Theme.TextDim, nil, 12)
end

local function shopPearlsTab(panel: Frame)
	local s = ClientState:Get()
	UiKit.Label(panel, "🐚 Pearls: " .. Util.formatNumber(s.pearls), UDim2.fromScale(0.5, 0.08), UDim2.fromScale(0.25, 0.2), Theme.Accent, Theme.FontBold, 20)
	UiKit.Label(panel, "Earn pearls from quests, streaks, achievements, storms & the weekly contest.",
		UDim2.fromScale(0.8, 0.06), UDim2.fromScale(0.1, 0.3), Theme.Text, nil, 14)
	UiKit.Label(panel, "Cosmetics (rod skins, bobber trails, auras) and pearl packs arrive in the Phase 7 shop update.",
		UDim2.fromScale(0.8, 0.06), UDim2.fromScale(0.1, 0.38), Theme.TextDim, nil, 13)
end

local function shopPanel()
	local panel = makePanel("🎣 SHOP")
	-- Tabs
	local tabs = { { "rods", "Rods" }, { "baits", "Baits" }, { "upgrades", "Upgrades" }, { "pearls", "Pearls" } }
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
	elseif shopTab == "upgrades" then
		shopUpgradesTab(panel)
	else
		shopPearlsTab(panel)
	end
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
	local grid = UiKit.New("UIGridLayout", {
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
		-- Rarity accent bar
		local accent = UiKit.Frame(tile, UDim2.fromScale(1, 0.04), UDim2.fromScale(0, 0), Theme.Rarity[def.rarity], 0)
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

	UiKit.Label(panel, def.name .. (shinyCaught and " ✨" or ""), UDim2.fromScale(0.5, 0.07), UDim2.fromScale(0.48, 0.14), Theme.Rarity[def.rarity], Theme.FontTitle, 22)
	UiKit.Label(panel, (Theme.RarityName[def.rarity] or ""):upper() .. " • " .. (ZoneCatalog.Get(def.zone) and ZoneCatalog.Get(def.zone).name or def.zone),
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
	-- Zone chips
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

-- ══════════════════════ INVENTORY ══════════════════════

local function inventoryPanel()
	local panel = makePanel("🎒 BAG")
	local s = ClientState:Get()

	-- Capacity
	UiKit.Label(panel, "Capacity: " .. #s.inventory .. " / " .. s.invSlots, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.1), Theme.Text, Theme.FontBold, 14)
	local capBg = UiKit.Frame(panel, UDim2.fromScale(0.4, 0.03), UDim2.fromScale(0.04, 0.16), Theme.BgPanelLight, 6)
	UiKit.Frame(capBg, UDim2.fromScale(Util.clamp(#s.inventory / math.max(1, s.invSlots), 0, 1), 1), UDim2.fromScale(0, 0), Theme.Accent, 6)

	-- Auto-sell selector
	UiKit.Label(panel, "Auto-sell (≤ rarity):", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.46, 0.1), Theme.TextDim, nil, 13)
	for i, opt in ipairs(AUTO_SELL_OPTIONS) do
		UiKit.Button(panel, opt:upper(), function()
			ClientState:Send("SetAutoSell", { maxRarity = opt == "off" and nil or opt })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.09, 0.045), pos = UDim2.fromScale(0.46 + 0.095 * (i - 1), 0.16), color = if (s.autoSell or "off") == opt then Theme.Accent2 else Theme.BgPanelLight, textSize = 11 })
	end

	-- Bulk sell buttons
	local bulk = { { "common", "Sell Commons" }, { "uncommon", "Sell Uncommons" }, { "rare", "Sell Rares" }, { "all", "Sell All (keeps ✨)" } }
	for i, b in ipairs(bulk) do
		UiKit.Button(panel, b[2], function()
			ClientState:Send("SellAll", { maxRarity = if b[1] == "all" then "epic" else b[1] })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.19, 0.05), pos = UDim2.fromScale(0.04 + 0.2 * (i - 1), 0.21), color = Theme.Accent, textSize = 12 })
	end

	-- Item list
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.68), UDim2.fromScale(0.04, 0.28), 6)
	local items = s.inventory
	table.sort(items, function(a, b)
		return a.caughtAt > b.caughtAt
	end)
	if #items == 0 then
		UiKit.Label(scroll, "Your bag is empty. Go catch something! 🎣", UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0), Theme.TextDim, nil, 14)
	end
	for _, item in ipairs(items) do
		local def = FishCatalog.Get(item.fishId)
		if def then
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.95, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Frame(row, UDim2.fromScale(0.02, 0.7), UDim2.fromScale(0.01, 0.15), Theme.Rarity[def.rarity], 2)
			UiKit.Label(row, (item.shiny and "✨ " or "") .. def.name, UDim2.fromScale(0.3, 1), UDim2.fromScale(0.05, 0), Theme.Text, Theme.FontBold, 13)
			UiKit.Label(row, item.weight .. " kg  •  ~" .. Util.formatNumber(def.baseValue * item.weight * (item.shiny and Config.SHINY_VALUE_MULT or 1)) .. " 🪙",
				UDim2.fromScale(0.4, 0.6), UDim2.fromScale(0.38, 0.05), Theme.TextDim, nil, 12)
			UiKit.Button(row, "Sell", function()
				ClientState:Send("SellFish", { ids = { item.uid } })
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.12, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = Theme.Danger, textSize = 12 })
		end
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

	-- Streak strip
	UiKit.Label(panel, "🔥 Login streak: Day " .. s.streak, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.09), Theme.Accent2, Theme.FontBold, 16)
	for i = 1, 7 do
		local reward = Config.STREAK_REWARDS[i]
		local day = UiKit.Frame(panel, UDim2.fromScale(0.06, 0.09), UDim2.fromScale(0.04 + 0.07 * (i - 1), 0.15), if i == s.streak then Theme.Accent2 elseif i < s.streak then Theme.Success else Theme.BgPanelLight, 30)
		day.BackgroundTransparency = if i < s.streak then 0.4 else 0
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

	-- Daily
	UiKit.Label(panel, "DAILY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.25), Theme.Accent, Theme.FontTitle, 14)
	local dailyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.3), 4)
	for i, q in ipairs(s.dailyQuests) do
		local template = require(ReplicatedStorage.Shared.Data.QuestCatalog).GetDailyTemplate(q.templateId)
		local desc = q.templateId
		if template then
			desc = template.desc
			desc = string.gsub(desc, "{n}", tostring(template.target))
			if q.params and q.params.zone then
				desc = string.gsub(desc, "{zone}", (ZoneCatalog.Get(q.params.zone) and ZoneCatalog.Get(q.params.zone).name or q.params.zone))
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
	end, { size = UDim2.fromScale(0.3, 0.045), pos = UDim2.fromScale(0.62, 0.25), color = Theme.BgPanelLight, textSize = 12 })

	-- Weekly
	UiKit.Label(panel, "WEEKLY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.61), Theme.Gold, Theme.FontTitle, 14)
	local weeklyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.66), 4)
	for i, q in ipairs(s.weeklyQuests) do
		local template = require(ReplicatedStorage.Shared.Data.QuestCatalog).GetWeeklyTemplate(q.templateId)
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

-- ══════════════════════ Refresh & lifecycle ══════════════════════


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

function MenuUIController:Refresh()
	if not openPanel then
		return
	end
	local panel = makePanel("")
	if openPanel == "shop" then
		shopPanel()
	elseif openPanel == "travel" then
		travelPanel()
	elseif openPanel == "bestiary" then
		bestiaryPanel()
	elseif openPanel == "inventory" then
		inventoryPanel()
	elseif openPanel == "quests" then
		questsPanel()
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
	Full-screen panels: Shop (rods/baits/upgrades), Bestiary (zones + details),
	Inventory (sell/auto-sell), Quests (daily/weekly/streak).
	All prices/stats come from the shared catalogs — nothing hardcoded here.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)

local MenuUIController = {}
MenuUIController.Name = "MenuUIController"

local player = Players.LocalPlayer
local gui: ScreenGui
local openPanel: string? = nil
local panelFrame: Frame?
local zoneFilter = "sunshall"
local currentDetail: string? = nil

local ZONE_ORDER = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }
local AUTO_SELL_OPTIONS = { "off", "common", "uncommon", "rare" }

-- ── Core panel scaffolding ───────────────────────────────────────────────

local function makePanel(title: string): Frame
	-- Remove previous panel
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
	MenuUIController:Refresh()
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
		MenuUIController:Close()
	else
		self:Open(name)
	end
end

-- ══════════════════════ SHOP ══════════════════════

local shopTab = "rods"

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
		end, { size = UDim2.fromScale(0.22, 0.72), pos = UDim2.fromScale(0.76, 0.14), color = if owned then Theme.Success elseif affordable then Theme.Accent else Theme.BgPanelLight, textSize = 12 })
		if equipped then
			btn.BackgroundColor3 = Theme.Accent2
		end
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
	UiKit.Label(panel, "🛒 The Bigger Tackle Box gamepass adds +50 slots instantly (store, Phase 7).",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.93), Theme.TextDim, nil, 12)
end

local function shopPearlsTab(panel: Frame)
	local s = ClientState:Get()
	UiKit.Label(panel, "🐚 Pearls: " .. Util.formatNumber(s.pearls), UDim2.fromScale(0.5, 0.08), UDim2.fromScale(0.25, 0.2), Theme.Accent, Theme.FontBold, 20)
	UiKit.Label(panel, "Earn pearls from quests, streaks, achievements, storms & the weekly contest.",
		UDim2.fromScale(0.8, 0.06), UDim2.fromScale(0.1, 0.3), Theme.Text, nil, 14)
	UiKit.Label(panel, "Cosmetics (rod skins, bobber trails, auras) and pearl packs arrive in the Phase 7 shop update.",
		UDim2.fromScale(0.8, 0.06), UDim2.fromScale(0.1, 0.38), Theme.TextDim, nil, 13)
end

local function shopPanel()
	local panel = makePanel("🎣 SHOP")
	-- Tabs
	local tabs = { { "rods", "Rods" }, { "baits", "Baits" }, { "upgrades", "Upgrades" }, { "pearls", "Pearls" } }
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
	elseif shopTab == "upgrades" then
		shopUpgradesTab(panel)
	else
		shopPearlsTab(panel)
	end
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
	local grid = UiKit.New("UIGridLayout", {
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
		-- Rarity accent bar
		local accent = UiKit.Frame(tile, UDim2.fromScale(1, 0.04), UDim2.fromScale(0, 0), Theme.Rarity[def.rarity], 0)
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

	UiKit.Label(panel, def.name .. (shinyCaught and " ✨" or ""), UDim2.fromScale(0.5, 0.07), UDim2.fromScale(0.48, 0.14), Theme.Rarity[def.rarity], Theme.FontTitle, 22)
	UiKit.Label(panel, (Theme.RarityName[def.rarity] or ""):upper() .. " • " .. (ZoneCatalog.Get(def.zone) and ZoneCatalog.Get(def.zone).name or def.zone),
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
	-- Zone chips
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

-- ══════════════════════ INVENTORY ══════════════════════

local function inventoryPanel()
	local panel = makePanel("🎒 BAG")
	local s = ClientState:Get()

	-- Capacity
	UiKit.Label(panel, "Capacity: " .. #s.inventory .. " / " .. s.invSlots, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.1), Theme.Text, Theme.FontBold, 14)
	local capBg = UiKit.Frame(panel, UDim2.fromScale(0.4, 0.03), UDim2.fromScale(0.04, 0.16), Theme.BgPanelLight, 6)
	UiKit.Frame(capBg, UDim2.fromScale(Util.clamp(#s.inventory / math.max(1, s.invSlots), 0, 1), 1), UDim2.fromScale(0, 0), Theme.Accent, 6)

	-- Auto-sell selector
	UiKit.Label(panel, "Auto-sell (≤ rarity):", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.46, 0.1), Theme.TextDim, nil, 13)
	for i, opt in ipairs(AUTO_SELL_OPTIONS) do
		UiKit.Button(panel, opt:upper(), function()
			ClientState:Send("SetAutoSell", { maxRarity = opt == "off" and nil or opt })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.09, 0.045), pos = UDim2.fromScale(0.46 + 0.095 * (i - 1), 0.16), color = if (s.autoSell or "off") == opt then Theme.Accent2 else Theme.BgPanelLight, textSize = 11 })
	end

	-- Bulk sell buttons
	local bulk = { { "common", "Sell Commons" }, { "uncommon", "Sell Uncommons" }, { "rare", "Sell Rares" }, { "all", "Sell All (keeps ✨)" } }
	for i, b in ipairs(bulk) do
		UiKit.Button(panel, b[2], function()
			ClientState:Send("SellAll", { maxRarity = if b[1] == "all" then "epic" else b[1] })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.19, 0.05), pos = UDim2.fromScale(0.04 + 0.2 * (i - 1), 0.21), color = Theme.Accent, textSize = 12 })
	end

	-- Item list
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.68), UDim2.fromScale(0.04, 0.28), 6)
	local items = s.inventory
	table.sort(items, function(a, b)
		return a.caughtAt > b.caughtAt
	end)
	if #items == 0 then
		UiKit.Label(scroll, "Your bag is empty. Go catch something! 🎣", UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0), Theme.TextDim, nil, 14)
	end
	for _, item in ipairs(items) do
		local def = FishCatalog.Get(item.fishId)
		if def then
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.95, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Frame(row, UDim2.fromScale(0.02, 0.7), UDim2.fromScale(0.01, 0.15), Theme.Rarity[def.rarity], 2)
			UiKit.Label(row, (item.shiny and "✨ " or "") .. def.name, UDim2.fromScale(0.3, 1), UDim2.fromScale(0.05, 0), Theme.Text, Theme.FontBold, 13)
			UiKit.Label(row, item.weight .. " kg  •  ~" .. Util.formatNumber(def.baseValue * item.weight * (item.shiny and Config.SHINY_VALUE_MULT or 1)) .. " 🪙",
				UDim2.fromScale(0.4, 0.6), UDim2.fromScale(0.38, 0.05), Theme.TextDim, nil, 12)
			UiKit.Button(row, "Sell", function()
				ClientState:Send("SellFish", { ids = { item.uid } })
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.12, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = Theme.Danger, textSize = 12 })
		end
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

	-- Streak strip
	UiKit.Label(panel, "🔥 Login streak: Day " .. s.streak, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.09), Theme.Accent2, Theme.FontBold, 16)
	for i = 1, 7 do
		local reward = Config.STREAK_REWARDS[i]
		local day = UiKit.Frame(panel, UDim2.fromScale(0.06, 0.09), UDim2.fromScale(0.04 + 0.07 * (i - 1), 0.15), if i == s.streak then Theme.Accent2 elseif i < s.streak then Theme.Success else Theme.BgPanelLight, 30)
		day.BackgroundTransparency = if i < s.streak then 0.4 else 0
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

	-- Daily
	UiKit.Label(panel, "DAILY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.25), Theme.Accent, Theme.FontTitle, 14)
	local dailyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.3), 4)
	for i, q in ipairs(s.dailyQuests) do
		local template = require(ReplicatedStorage.Shared.Data.QuestCatalog).GetDailyTemplate(q.templateId)
		local desc = q.templateId
		if template then
			desc = template.desc
			desc = string.gsub(desc, "{n}", tostring(template.target))
			if q.params and q.params.zone then
				desc = string.gsub(desc, "{zone}", (ZoneCatalog.Get(q.params.zone) and ZoneCatalog.Get(q.params.zone).name or q.params.zone))
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
	end, { size = UDim2.fromScale(0.3, 0.045), pos = UDim2.fromScale(0.62, 0.25), color = Theme.BgPanelLight, textSize = 12 })

	-- Weekly
	UiKit.Label(panel, "WEEKLY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.61), Theme.Gold, Theme.FontTitle, 14)
	local weeklyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.66), 4)
	for i, q in ipairs(s.weeklyQuests) do
		local template = require(ReplicatedStorage.Shared.Data.QuestCatalog).GetWeeklyTemplate(q.templateId)
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

-- ══════════════════════ Refresh & lifecycle ══════════════════════


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

function MenuUIController:Refresh()
	if not openPanel then
		return
	end
	local panel = makePanel("")
	if openPanel == "shop" then
		shopPanel()
	elseif openPanel == "travel" then
		travelPanel()
	elseif openPanel == "bestiary" then
		bestiaryPanel()
	elseif openPanel == "inventory" then
		inventoryPanel()
	elseif openPanel == "quests" then
		questsPanel()
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

print("[Installer] Part 11/12 complete - next: 12")
