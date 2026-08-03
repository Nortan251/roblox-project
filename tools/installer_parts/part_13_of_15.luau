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

-- StarterPlayer/StarterPlayerScripts/Controllers/UIController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/UIController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — UIController (client, ModuleScript)
	HUD + gameplay overlays: coins/pearls/XP bar, event banners, catch card
	(screenshot engine), feed, level-up, streak, achievement toasts.
	Panels (shop/bestiary/inventory/quests) live in MenuUIController.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local UIController = {}
UIController.Name = "UIController"

local player = Players.LocalPlayer
local gui: ScreenGui

local coinLabel: TextLabel
local pearlLabel: TextLabel
local streakLabel: TextLabel
local xpFill: Frame
local xpText: TextLabel
local bannerFrame: Frame
local bannerText: TextLabel
local hintLabel: TextLabel
local hintDismissed = false
local feedFrame: Frame
local stormChip: TextLabel
local cardContainer: Frame

-- ── UI build ─────────────────────────────────────────────────────────────

function UIController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "HudGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1,
		Parent = player.PlayerGui,
	})

	-- Top-left: currencies
	coinLabel = UiKit.Label(gui, "🪙 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.01), Theme.Gold, Theme.FontBold, 17)
	coinLabel.TextXAlignment = Enum.TextXAlignment.Left
	pearlLabel = UiKit.Label(gui, "🐚 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.06), Theme.Accent, Theme.FontBold, 17)
	pearlLabel.TextXAlignment = Enum.TextXAlignment.Left
	streakLabel = UiKit.Label(gui, "🔥 0", UDim2.fromScale(0.16, 0.04), UDim2.fromScale(0.01, 0.11), Theme.Accent2, Theme.FontBold, 15)
	streakLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Top-right: panel buttons
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	local function panelButton(name: string, label: string, order: number)
		local rowIdx = math.ceil(order / 5)
		local colIdx = (order - 1) % 5
		local btn = UiKit.Button(gui, label, function()
			menu:Toggle(name)
		end, { size = UDim2.fromScale(0.1, 0.04), pos = UDim2.fromScale(1 - 0.105 * (colIdx + 1), 0.01 + 0.045 * (rowIdx - 1)), color = Theme.BgPanelLight, textSize = 11 })
		btn.AnchorPoint = Vector2.new(1, 0)
		btn.TextColor3 = Theme.Text
		return btn
	end
	panelButton("travel", "🗺 Map", 1)
	panelButton("quests", "📜 Quests", 2)
	panelButton("shop", "🎣 Shop", 3)
	panelButton("bestiary", "📖 Bestiary", 4)
	panelButton("inventory", "🎒 Bag", 5)
	panelButton("store", "🛒 Store", 6)
	panelButton("pearls", "🐚 Pearls", 7)
	panelButton("achievements", "🏅 Medals", 8)
	panelButton("contest", "🏆 Contest", 9)
	panelButton("profile", "👤 Profile", 10)

	-- XP bar (bottom center) — the "always visible progress" FTUE element
	local xpBg = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.035), UDim2.fromScale(0.5, 1), Theme.BgPanel, 8)
	xpBg.AnchorPoint = Vector2.new(0.5, 1)
	xpBg.BackgroundTransparency = 0.5
	xpFill = UiKit.Frame(xpBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	xpText = UiKit.Label(xpBg, "Lv 1", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 13)

	-- Storm countdown chip
	stormChip = UiKit.Label(gui, "", UDim2.fromScale(0.22, 0.04), UDim2.fromScale(0.5, 0.06), Theme.Storm, Theme.FontBold, 14)
	stormChip.AnchorPoint = Vector2.new(0.5, 0)

	-- First-catch hint (dismisses on the player's first catch)
	hintLabel = UiKit.Label(gui, "🎣 Hold Q (or tap CAST) to charge — release to cast!", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.5, 0.9), Theme.Gold, Theme.FontBold, 15)
	hintLabel.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Banner (top-center, animated)
	bannerFrame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.07), UDim2.fromScale(0.5, 0.12), Theme.BgPanel, 10)
	bannerFrame.AnchorPoint = Vector2.new(0.5, 0)
	bannerFrame.Visible = false
	bannerText = UiKit.Label(bannerFrame, "", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 18)

	-- Feed (bottom-left)
	feedFrame = UiKit.New("Frame", {
		Name = "Feed",
		Size = UDim2.fromScale(0.34, 0.5),
		Position = UDim2.fromScale(0.01, 0.5),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	UiKit.New("UIListLayout", { Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Parent = feedFrame })

	-- Catch card container (center overlay)
	cardContainer = UiKit.New("Frame", {
		Name = "CatchCardContainer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	})
end

-- ── HUD refresh (reads ClientState) ──────────────────────────────────────

function UIController:RefreshHud()
	local s = ClientState:Get()
	coinLabel.Text = "🪙 " .. Util.formatNumber(s.coins)
	pearlLabel.Text = "🐚 " .. Util.formatNumber(s.pearls)
	if s.streak > 1 then
		streakLabel.Text = "🔥 " .. s.streak .. " day streak"
		streakLabel.Visible = true
	else
		streakLabel.Visible = false
	end
	local needed = Util.xpForLevel(s.level, Config.XP_BASE, Config.XP_EXPONENT)
	xpFill.Size = UDim2.fromScale(Util.clamp(s.xp / needed, 0, 1), 1)
	xpText.Text = "Lv " .. s.level .. "  " .. Util.formatNumber(s.xp) .. "/" .. Util.formatNumber(needed)
end

-- ── Banner / feed / toasts ───────────────────────────────────────────────

local bannerTween: Tween? = nil

function UIController:ShowBanner(text: string, color: Color3, duration: number)
	bannerText.Text = text
	bannerFrame.BackgroundColor3 = color
	bannerFrame.Visible = true
	bannerFrame.Size = UDim2.fromScale(0.6, 0.07)
	bannerFrame.Position = UDim2.fromScale(0.5, -0.1)
	local tween = TweenService:Create(bannerFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.12),
	})
	tween:Play()
	task.delay(duration or 4, function()
		if bannerFrame and bannerFrame.Visible then
			local out = TweenService:Create(bannerFrame, TweenInfo.new(0.3), { Position = UDim2.fromScale(0.5, -0.1) })
			out:Play()
			task.delay(0.3, function()
				if bannerFrame then
					bannerFrame.Visible = false
				end
			end)
		end
	end)
end

function UIController:AddFeed(text: string, color: Color3?)
	local entry = UiKit.Frame(feedFrame, UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0), Theme.BgPanel, 6)
	entry.BackgroundTransparency = 0.35
	local label = UiKit.Label(entry, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), color or Theme.Text, nil, 13)
	label.TextXAlignment = Enum.TextXAlignment.Left
	UiKit.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = entry })
	-- Cap feed length
	local children = feedFrame:GetChildren()
	for i = 1, #children - Config.MAX_FEED_MESSAGES do
		if children[i]:IsA("Frame") then
			children[i]:Destroy()
		end
	end
	-- Fade out
	task.delay(8, function()
		if entry and entry.Parent then
			entry:Destroy()
		end
	end)
end

function UIController:Toast(text: string, color: Color3?)
	local t = UiKit.Frame(gui, UDim2.fromScale(0.42, 0.055), UDim2.fromScale(0.5, 0.22), color or Theme.Accent, 10)
	t.AnchorPoint = Vector2.new(0.5, 0)
	t.BackgroundTransparency = 0.25
	UiKit.Label(t, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.new(1, 1, 1), Theme.FontBold, 15)
	task.delay(3, function()
		if t and t.Parent then
			t:Destroy()
		end
	end)
end

-- ── Catch card (screenshot engine) ───────────────────────────────────────

function UIController:ShowCatchCard(payload: any)
	local fishId = payload.fishId
	local def = FishCatalog.Get(fishId)
	if not def then
		return
	end
	local shiny = payload.shiny == true
	local rarity = payload.rarity or "common"
	local color = Theme.Rarity[rarity] or Theme.Text

	cardContainer.Visible = true
	for _, child in pairs(cardContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local backdrop = UiKit.Frame(cardContainer, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(5, 10, 18), 0)
	backdrop.BackgroundTransparency = 0.35

	local card = UiKit.Frame(backdrop, UDim2.fromScale(0.34, 0.5), UDim2.fromScale(0.5, 0.5), Theme.BgPanel, 16)
	card.AnchorPoint = Vector2.new(0.5, 0.5)

	local rarityTag = UiKit.Label(card, (shiny and "✨ SHINY " or "") .. (Theme.RarityName[rarity] or rarity):upper(), UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.03), color, Theme.FontTitle, 16)

	-- Fish visual in a viewport
	local vp = UiKit.New("ViewportFrame", {
		Name = "FishViewport",
		Size = UDim2.fromScale(1, 0.5),
		Position = UDim2.fromScale(0, 0.12),
		BackgroundColor3 = Theme.Bg,
		Parent = card,
	})
	local ok, model = pcall(FishVisuals.Build, fishId, shiny)
	if ok and model then
		model.Parent = vp
		vp.CurrentCamera = Instance.new("Camera")
		vp.CurrentCamera.CFrame = FishVisuals.FrameCamera(model, 4.5)
	end

	UiKit.Label(card, payload.name or def.name, UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0.6), Theme.Text, Theme.FontTitle, 22)
	UiKit.Label(card, "⚖ " .. payload.weight .. " kg", UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0.7), Theme.Text, Theme.FontBold, 15)
	UiKit.Label(card, "+" .. Util.formatNumber(payload.coins or 0) .. " 🪙   +" .. (payload.xp or 0) .. " XP   +" .. (payload.pearls or 0) .. " 🐚",
		UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.78), Theme.Gold, Theme.FontBold, 14)
	UiKit.Button(card, "Nice! ✨", function()
		cardContainer.Visible = false
	end, { size = UDim2.fromScale(0.4, 0.09), pos = UDim2.fromScale(0.3, 0.88), color = Theme.Accent, textSize = 14 })

	-- Auto-dismiss for rares; mythics/shiny stay until dismissed (screenshot time)
	if rarity ~= "mythic" and not shiny then
		task.delay(Config.CATCH_CARD_MS / 1000, function()
			if cardContainer.Visible then
				cardContainer.Visible = false
			end
		end)
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function UIController:HandleCatchResult(payload: any)
	if not hintDismissed and hintLabel then
		hintDismissed = true
		hintLabel.Visible = false
	end
	if payload.snapped then
		self:Toast("The line snapped! Reel when tension is low.", Theme.Danger)
		return
	end
	local idx = Config.RARITY_INDEX[payload.rarity or "common"] or 1
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	audio:PlayCatch(payload.rarity or "common", payload.shiny == true)
	if payload.golden then
		self:Toast("✨ Golden catch! +10% value", Theme.Gold)
	end
	if payload.autoSold then
		self:AddFeed("(auto-sold) " .. payload.name .. " — +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.TextDim)
	elseif payload.overflowSold then
		self:AddFeed("(bag full — sold oldest) " .. payload.name, Theme.TextDim)
	end
	if idx >= 4 or payload.shiny then
		self:ShowCatchCard(payload)
	else
		self:Toast(payload.name .. " — " .. payload.weight .. "kg  +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.Rarity[payload.rarity] or Theme.Text)
	end
end

function UIController:HandleEventBanner(payload: any)
	local kind = payload.kind
	local text = payload.text or ""
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	if kind == "storm" then
		self:ShowBanner("⛈ " .. text, Theme.Storm, 5)
		audio:Play("storm")
	elseif kind == "stormWarning" then
		self:ShowBanner("🌩 " .. text, Theme.Storm, 4)
	elseif kind == "night" then
		self:ShowBanner("🌙 " .. text, Theme.Night, 4)
	elseif kind == "day" then
		self:ShowBanner("🌅 " .. text, Theme.Gold, 3)
	elseif kind == "stormEnd" then
		self:ShowBanner("☀ " .. text, Theme.Text, 3)
	elseif kind == "zoneComplete" then
		self:ShowBanner("🏆 " .. text, Theme.Success, 4)
	elseif kind == "zoneEnter" then
		self:ShowBanner("🌊 " .. text, Theme.Accent, 3)
	elseif kind == "travelDenied" then
		self:Toast(text, Theme.Danger)
	elseif kind == "oldOne" then
		self:ShowBanner("🐋 " .. text, Theme.Success, 5)
		audio:Play("catch_mythic")
	else
		self:ShowBanner(text, Theme.Accent, 4)
	end
end

function UIController:HandleLevelUp(payload: any)
	self:ShowBanner("⬆ LEVEL UP! You reached level " .. payload.level .. " (+" .. payload.coinsGranted .. " 🪙)", Theme.Accent2, 3.5)
	require(script.Parent.Parent.Controllers.AudioController):Play("levelup")
end

function UIController:HandleStreakUpdate(payload: any)
	local day = payload.streak or 1
	if day == 1 then
		return -- day-1 streak is just "welcome back", no popup
	end
	self:Toast("🔥 Day " .. day .. " streak! Rewards claimed.", Theme.Accent2)
	require(script.Parent.Parent.Controllers.AudioController):Play("streak")
end

function UIController:HandleAchievementUnlock(payload: any)
	self:ShowBanner("🏅 Achievement: " .. payload.name, Theme.Gold, 4)
	require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
end

function UIController:HandleFeedMessage(payload: any)
	self:AddFeed(payload.text or "", payload.kind == "announce" and Theme.Accent2 or Theme.TextDim)
end

function UIController:HandleBestiaryUpdate(payload: any)
	if payload.bestiaryNew then
		local def = FishCatalog.Get(payload.fishId)
		self:Toast("📖 New bestiary entry: " .. (def and def.name or "?") .. (payload.shiny and " (SHINY!)" or ""), Theme.Accent)
		require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
	end
end

function UIController:HandleGoldenSpot(payload: any)
	if payload.active then
		self:ShowBanner("✨ Golden shimmer: " .. payload.zoneId .. "!", Theme.Gold, 4)
	end
end

function UIController:HandleWorldState(payload: any)
	-- Storm countdown chip updates
	if payload.stormIn and payload.stormIn > 0 and payload.stormIn <= 90 and not payload.isStorm then
		stormChip.Text = "🌩 storm in " .. math.ceil(payload.stormIn) .. "s"
		stormChip.Visible = true
	else
		stormChip.Visible = false
	end
end

function UIController:HandlePassGranted(_payload: any)
	self:Toast("✅ Purchase complete — thank you for supporting Tidebound!", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

function UIController:HandleProductGranted(_payload: any)
	self:Toast("✅ Delivered! Check your bag.", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function UIController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
	ctx.RegisterHandler("EventBanner", function(payload)
		self:HandleEventBanner(payload)
	end)
	ctx.RegisterHandler("LevelUp", function(payload)
		self:HandleLevelUp(payload)
	end)
	ctx.RegisterHandler("StreakUpdate", function(payload)
		self:HandleStreakUpdate(payload)
	end)
	ctx.RegisterHandler("AchievementUnlock", function(payload)
		self:HandleAchievementUnlock(payload)
	end)
	ctx.RegisterHandler("FeedMessage", function(payload)
		self:HandleFeedMessage(payload)
	end)
	ctx.RegisterHandler("BestiaryUpdate", function(payload)
		self:HandleBestiaryUpdate(payload)
	end)
	ctx.RegisterHandler("WorldState", function(payload)
		self:HandleWorldState(payload)
	end)
	ctx.RegisterHandler("GoldenSpot", function(payload)
		self:HandleGoldenSpot(payload)
	end)
	ctx.RegisterHandler("PassGranted", function(payload)
		self:HandlePassGranted(payload)
	end)
	ctx.RegisterHandler("ProductGranted", function(payload)
		self:HandleProductGranted(payload)
	end)
end

function UIController:Start()
	self:BuildUI()
	self:RefreshHud()
	ClientState:Subscribe(function(msgType, _payload)
		if msgType == "StateSync" or msgType == "QuestUpdate" or msgType == "InventorySync" then
			self:RefreshHud()
		end
	end)
end

function UIController:Stop()
	if gui then
		gui:Destroy()
	end
end

return UIController
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — UIController (client, ModuleScript)
	HUD + gameplay overlays: coins/pearls/XP bar, event banners, catch card
	(screenshot engine), feed, level-up, streak, achievement toasts.
	Panels (shop/bestiary/inventory/quests) live in MenuUIController.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local UIController = {}
UIController.Name = "UIController"

local player = Players.LocalPlayer
local gui: ScreenGui

local coinLabel: TextLabel
local pearlLabel: TextLabel
local streakLabel: TextLabel
local xpFill: Frame
local xpText: TextLabel
local bannerFrame: Frame
local bannerText: TextLabel
local hintLabel: TextLabel
local hintDismissed = false
local feedFrame: Frame
local stormChip: TextLabel
local cardContainer: Frame

-- ── UI build ─────────────────────────────────────────────────────────────

function UIController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "HudGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1,
		Parent = player.PlayerGui,
	})

	-- Top-left: currencies
	coinLabel = UiKit.Label(gui, "🪙 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.01), Theme.Gold, Theme.FontBold, 17)
	coinLabel.TextXAlignment = Enum.TextXAlignment.Left
	pearlLabel = UiKit.Label(gui, "🐚 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.06), Theme.Accent, Theme.FontBold, 17)
	pearlLabel.TextXAlignment = Enum.TextXAlignment.Left
	streakLabel = UiKit.Label(gui, "🔥 0", UDim2.fromScale(0.16, 0.04), UDim2.fromScale(0.01, 0.11), Theme.Accent2, Theme.FontBold, 15)
	streakLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Top-right: panel buttons
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	local function panelButton(name: string, label: string, order: number)
		local rowIdx = math.ceil(order / 5)
		local colIdx = (order - 1) % 5
		local btn = UiKit.Button(gui, label, function()
			menu:Toggle(name)
		end, { size = UDim2.fromScale(0.1, 0.04), pos = UDim2.fromScale(1 - 0.105 * (colIdx + 1), 0.01 + 0.045 * (rowIdx - 1)), color = Theme.BgPanelLight, textSize = 11 })
		btn.AnchorPoint = Vector2.new(1, 0)
		btn.TextColor3 = Theme.Text
		return btn
	end
	panelButton("travel", "🗺 Map", 1)
	panelButton("quests", "📜 Quests", 2)
	panelButton("shop", "🎣 Shop", 3)
	panelButton("bestiary", "📖 Bestiary", 4)
	panelButton("inventory", "🎒 Bag", 5)
	panelButton("store", "🛒 Store", 6)
	panelButton("pearls", "🐚 Pearls", 7)
	panelButton("achievements", "🏅 Medals", 8)
	panelButton("contest", "🏆 Contest", 9)
	panelButton("profile", "👤 Profile", 10)

	-- XP bar (bottom center) — the "always visible progress" FTUE element
	local xpBg = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.035), UDim2.fromScale(0.5, 1), Theme.BgPanel, 8)
	xpBg.AnchorPoint = Vector2.new(0.5, 1)
	xpBg.BackgroundTransparency = 0.5
	xpFill = UiKit.Frame(xpBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	xpText = UiKit.Label(xpBg, "Lv 1", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 13)

	-- Storm countdown chip
	stormChip = UiKit.Label(gui, "", UDim2.fromScale(0.22, 0.04), UDim2.fromScale(0.5, 0.06), Theme.Storm, Theme.FontBold, 14)
	stormChip.AnchorPoint = Vector2.new(0.5, 0)

	-- First-catch hint (dismisses on the player's first catch)
	hintLabel = UiKit.Label(gui, "🎣 Hold Q (or tap CAST) to charge — release to cast!", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.5, 0.9), Theme.Gold, Theme.FontBold, 15)
	hintLabel.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Banner (top-center, animated)
	bannerFrame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.07), UDim2.fromScale(0.5, 0.12), Theme.BgPanel, 10)
	bannerFrame.AnchorPoint = Vector2.new(0.5, 0)
	bannerFrame.Visible = false
	bannerText = UiKit.Label(bannerFrame, "", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 18)

	-- Feed (bottom-left)
	feedFrame = UiKit.New("Frame", {
		Name = "Feed",
		Size = UDim2.fromScale(0.34, 0.5),
		Position = UDim2.fromScale(0.01, 0.5),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	UiKit.New("UIListLayout", { Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Parent = feedFrame })

	-- Catch card container (center overlay)
	cardContainer = UiKit.New("Frame", {
		Name = "CatchCardContainer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	})
end

-- ── HUD refresh (reads ClientState) ──────────────────────────────────────

function UIController:RefreshHud()
	local s = ClientState:Get()
	coinLabel.Text = "🪙 " .. Util.formatNumber(s.coins)
	pearlLabel.Text = "🐚 " .. Util.formatNumber(s.pearls)
	if s.streak > 1 then
		streakLabel.Text = "🔥 " .. s.streak .. " day streak"
		streakLabel.Visible = true
	else
		streakLabel.Visible = false
	end
	local needed = Util.xpForLevel(s.level, Config.XP_BASE, Config.XP_EXPONENT)
	xpFill.Size = UDim2.fromScale(Util.clamp(s.xp / needed, 0, 1), 1)
	xpText.Text = "Lv " .. s.level .. "  " .. Util.formatNumber(s.xp) .. "/" .. Util.formatNumber(needed)
end

-- ── Banner / feed / toasts ───────────────────────────────────────────────

local bannerTween: Tween? = nil

function UIController:ShowBanner(text: string, color: Color3, duration: number)
	bannerText.Text = text
	bannerFrame.BackgroundColor3 = color
	bannerFrame.Visible = true
	bannerFrame.Size = UDim2.fromScale(0.6, 0.07)
	bannerFrame.Position = UDim2.fromScale(0.5, -0.1)
	local tween = TweenService:Create(bannerFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.12),
	})
	tween:Play()
	task.delay(duration or 4, function()
		if bannerFrame and bannerFrame.Visible then
			local out = TweenService:Create(bannerFrame, TweenInfo.new(0.3), { Position = UDim2.fromScale(0.5, -0.1) })
			out:Play()
			task.delay(0.3, function()
				if bannerFrame then
					bannerFrame.Visible = false
				end
			end)
		end
	end)
end

function UIController:AddFeed(text: string, color: Color3?)
	local entry = UiKit.Frame(feedFrame, UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0), Theme.BgPanel, 6)
	entry.BackgroundTransparency = 0.35
	local label = UiKit.Label(entry, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), color or Theme.Text, nil, 13)
	label.TextXAlignment = Enum.TextXAlignment.Left
	UiKit.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = entry })
	-- Cap feed length
	local children = feedFrame:GetChildren()
	for i = 1, #children - Config.MAX_FEED_MESSAGES do
		if children[i]:IsA("Frame") then
			children[i]:Destroy()
		end
	end
	-- Fade out
	task.delay(8, function()
		if entry and entry.Parent then
			entry:Destroy()
		end
	end)
end

function UIController:Toast(text: string, color: Color3?)
	local t = UiKit.Frame(gui, UDim2.fromScale(0.42, 0.055), UDim2.fromScale(0.5, 0.22), color or Theme.Accent, 10)
	t.AnchorPoint = Vector2.new(0.5, 0)
	t.BackgroundTransparency = 0.25
	UiKit.Label(t, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.new(1, 1, 1), Theme.FontBold, 15)
	task.delay(3, function()
		if t and t.Parent then
			t:Destroy()
		end
	end)
end

-- ── Catch card (screenshot engine) ───────────────────────────────────────

function UIController:ShowCatchCard(payload: any)
	local fishId = payload.fishId
	local def = FishCatalog.Get(fishId)
	if not def then
		return
	end
	local shiny = payload.shiny == true
	local rarity = payload.rarity or "common"
	local color = Theme.Rarity[rarity] or Theme.Text

	cardContainer.Visible = true
	for _, child in pairs(cardContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local backdrop = UiKit.Frame(cardContainer, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(5, 10, 18), 0)
	backdrop.BackgroundTransparency = 0.35

	local card = UiKit.Frame(backdrop, UDim2.fromScale(0.34, 0.5), UDim2.fromScale(0.5, 0.5), Theme.BgPanel, 16)
	card.AnchorPoint = Vector2.new(0.5, 0.5)

	local rarityTag = UiKit.Label(card, (shiny and "✨ SHINY " or "") .. (Theme.RarityName[rarity] or rarity):upper(), UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.03), color, Theme.FontTitle, 16)

	-- Fish visual in a viewport
	local vp = UiKit.New("ViewportFrame", {
		Name = "FishViewport",
		Size = UDim2.fromScale(1, 0.5),
		Position = UDim2.fromScale(0, 0.12),
		BackgroundColor3 = Theme.Bg,
		Parent = card,
	})
	local ok, model = pcall(FishVisuals.Build, fishId, shiny)
	if ok and model then
		model.Parent = vp
		vp.CurrentCamera = Instance.new("Camera")
		vp.CurrentCamera.CFrame = FishVisuals.FrameCamera(model, 4.5)
	end

	UiKit.Label(card, payload.name or def.name, UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0.6), Theme.Text, Theme.FontTitle, 22)
	UiKit.Label(card, "⚖ " .. payload.weight .. " kg", UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0.7), Theme.Text, Theme.FontBold, 15)
	UiKit.Label(card, "+" .. Util.formatNumber(payload.coins or 0) .. " 🪙   +" .. (payload.xp or 0) .. " XP   +" .. (payload.pearls or 0) .. " 🐚",
		UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.78), Theme.Gold, Theme.FontBold, 14)
	UiKit.Button(card, "Nice! ✨", function()
		cardContainer.Visible = false
	end, { size = UDim2.fromScale(0.4, 0.09), pos = UDim2.fromScale(0.3, 0.88), color = Theme.Accent, textSize = 14 })

	-- Auto-dismiss for rares; mythics/shiny stay until dismissed (screenshot time)
	if rarity ~= "mythic" and not shiny then
		task.delay(Config.CATCH_CARD_MS / 1000, function()
			if cardContainer.Visible then
				cardContainer.Visible = false
			end
		end)
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function UIController:HandleCatchResult(payload: any)
	if not hintDismissed and hintLabel then
		hintDismissed = true
		hintLabel.Visible = false
	end
	if payload.snapped then
		self:Toast("The line snapped! Reel when tension is low.", Theme.Danger)
		return
	end
	local idx = Config.RARITY_INDEX[payload.rarity or "common"] or 1
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	audio:PlayCatch(payload.rarity or "common", payload.shiny == true)
	if payload.golden then
		self:Toast("✨ Golden catch! +10% value", Theme.Gold)
	end
	if payload.autoSold then
		self:AddFeed("(auto-sold) " .. payload.name .. " — +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.TextDim)
	elseif payload.overflowSold then
		self:AddFeed("(bag full — sold oldest) " .. payload.name, Theme.TextDim)
	end
	if idx >= 4 or payload.shiny then
		self:ShowCatchCard(payload)
	else
		self:Toast(payload.name .. " — " .. payload.weight .. "kg  +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.Rarity[payload.rarity] or Theme.Text)
	end
end

function UIController:HandleEventBanner(payload: any)
	local kind = payload.kind
	local text = payload.text or ""
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	if kind == "storm" then
		self:ShowBanner("⛈ " .. text, Theme.Storm, 5)
		audio:Play("storm")
	elseif kind == "stormWarning" then
		self:ShowBanner("🌩 " .. text, Theme.Storm, 4)
	elseif kind == "night" then
		self:ShowBanner("🌙 " .. text, Theme.Night, 4)
	elseif kind == "day" then
		self:ShowBanner("🌅 " .. text, Theme.Gold, 3)
	elseif kind == "stormEnd" then
		self:ShowBanner("☀ " .. text, Theme.Text, 3)
	elseif kind == "zoneComplete" then
		self:ShowBanner("🏆 " .. text, Theme.Success, 4)
	elseif kind == "zoneEnter" then
		self:ShowBanner("🌊 " .. text, Theme.Accent, 3)
	elseif kind == "travelDenied" then
		self:Toast(text, Theme.Danger)
	elseif kind == "oldOne" then
		self:ShowBanner("🐋 " .. text, Theme.Success, 5)
		audio:Play("catch_mythic")
	else
		self:ShowBanner(text, Theme.Accent, 4)
	end
end

function UIController:HandleLevelUp(payload: any)
	self:ShowBanner("⬆ LEVEL UP! You reached level " .. payload.level .. " (+" .. payload.coinsGranted .. " 🪙)", Theme.Accent2, 3.5)
	require(script.Parent.Parent.Controllers.AudioController):Play("levelup")
end

function UIController:HandleStreakUpdate(payload: any)
	local day = payload.streak or 1
	if day == 1 then
		return -- day-1 streak is just "welcome back", no popup
	end
	self:Toast("🔥 Day " .. day .. " streak! Rewards claimed.", Theme.Accent2)
	require(script.Parent.Parent.Controllers.AudioController):Play("streak")
end

function UIController:HandleAchievementUnlock(payload: any)
	self:ShowBanner("🏅 Achievement: " .. payload.name, Theme.Gold, 4)
	require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
end

function UIController:HandleFeedMessage(payload: any)
	self:AddFeed(payload.text or "", payload.kind == "announce" and Theme.Accent2 or Theme.TextDim)
end

function UIController:HandleBestiaryUpdate(payload: any)
	if payload.bestiaryNew then
		local def = FishCatalog.Get(payload.fishId)
		self:Toast("📖 New bestiary entry: " .. (def and def.name or "?") .. (payload.shiny and " (SHINY!)" or ""), Theme.Accent)
		require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
	end
end

function UIController:HandleGoldenSpot(payload: any)
	if payload.active then
		self:ShowBanner("✨ Golden shimmer: " .. payload.zoneId .. "!", Theme.Gold, 4)
	end
end

function UIController:HandleWorldState(payload: any)
	-- Storm countdown chip updates
	if payload.stormIn and payload.stormIn > 0 and payload.stormIn <= 90 and not payload.isStorm then
		stormChip.Text = "🌩 storm in " .. math.ceil(payload.stormIn) .. "s"
		stormChip.Visible = true
	else
		stormChip.Visible = false
	end
end

function UIController:HandlePassGranted(_payload: any)
	self:Toast("✅ Purchase complete — thank you for supporting Tidebound!", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

function UIController:HandleProductGranted(_payload: any)
	self:Toast("✅ Delivered! Check your bag.", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function UIController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
	ctx.RegisterHandler("EventBanner", function(payload)
		self:HandleEventBanner(payload)
	end)
	ctx.RegisterHandler("LevelUp", function(payload)
		self:HandleLevelUp(payload)
	end)
	ctx.RegisterHandler("StreakUpdate", function(payload)
		self:HandleStreakUpdate(payload)
	end)
	ctx.RegisterHandler("AchievementUnlock", function(payload)
		self:HandleAchievementUnlock(payload)
	end)
	ctx.RegisterHandler("FeedMessage", function(payload)
		self:HandleFeedMessage(payload)
	end)
	ctx.RegisterHandler("BestiaryUpdate", function(payload)
		self:HandleBestiaryUpdate(payload)
	end)
	ctx.RegisterHandler("WorldState", function(payload)
		self:HandleWorldState(payload)
	end)
	ctx.RegisterHandler("GoldenSpot", function(payload)
		self:HandleGoldenSpot(payload)
	end)
	ctx.RegisterHandler("PassGranted", function(payload)
		self:HandlePassGranted(payload)
	end)
	ctx.RegisterHandler("ProductGranted", function(payload)
		self:HandleProductGranted(payload)
	end)
end

function UIController:Start()
	self:BuildUI()
	self:RefreshHud()
	ClientState:Subscribe(function(msgType, _payload)
		if msgType == "StateSync" or msgType == "QuestUpdate" or msgType == "InventorySync" then
			self:RefreshHud()
		end
	end)
end

function UIController:Stop()
	if gui then
		gui:Destroy()
	end
end

return UIController
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/UIController')
end

print("[Installer] Part 13/15 complete - next: 14")
