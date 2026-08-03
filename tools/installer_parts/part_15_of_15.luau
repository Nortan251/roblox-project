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

-- StarterPlayer/StarterPlayerScripts/Modules/Theme
local inst = ensure('StarterPlayer/StarterPlayerScripts/Modules/Theme', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Theme (client)
	Single source of UI colors/fonts so every panel looks consistent.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = {
	Bg = Color3.fromRGB(10, 22, 36),
	BgPanel = Color3.fromRGB(20, 38, 58),
	BgPanelLight = Color3.fromRGB(30, 52, 76),
	Accent = Color3.fromRGB(64, 210, 210),
	Accent2 = Color3.fromRGB(255, 190, 60),
	Text = Color3.fromRGB(235, 245, 255),
	TextDim = Color3.fromRGB(150, 170, 190),
	Danger = Color3.fromRGB(255, 96, 96),
	Success = Color3.fromRGB(96, 220, 130),
	Storm = Color3.fromRGB(150, 180, 255),
	Night = Color3.fromRGB(120, 100, 220),
	Gold = Color3.fromRGB(255, 210, 90),
	Rarity = {
		common = Color3.fromRGB(178, 188, 198),
		uncommon = Color3.fromRGB(110, 212, 122),
		rare = Color3.fromRGB(92, 162, 255),
		epic = Color3.fromRGB(192, 112, 255),
		legendary = Color3.fromRGB(255, 200, 64),
		mythic = Color3.fromRGB(255, 92, 130),
	},
	RarityName = {
		common = "Common",
		uncommon = "Uncommon",
		rare = "Rare",
		epic = "Epic",
		legendary = "Legendary",
		mythic = "Mythic",
	},
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
	FontTitle = Enum.Font.GothamBlack,
}

return Theme
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Theme (client)
	Single source of UI colors/fonts so every panel looks consistent.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = {
	Bg = Color3.fromRGB(10, 22, 36),
	BgPanel = Color3.fromRGB(20, 38, 58),
	BgPanelLight = Color3.fromRGB(30, 52, 76),
	Accent = Color3.fromRGB(64, 210, 210),
	Accent2 = Color3.fromRGB(255, 190, 60),
	Text = Color3.fromRGB(235, 245, 255),
	TextDim = Color3.fromRGB(150, 170, 190),
	Danger = Color3.fromRGB(255, 96, 96),
	Success = Color3.fromRGB(96, 220, 130),
	Storm = Color3.fromRGB(150, 180, 255),
	Night = Color3.fromRGB(120, 100, 220),
	Gold = Color3.fromRGB(255, 210, 90),
	Rarity = {
		common = Color3.fromRGB(178, 188, 198),
		uncommon = Color3.fromRGB(110, 212, 122),
		rare = Color3.fromRGB(92, 162, 255),
		epic = Color3.fromRGB(192, 112, 255),
		legendary = Color3.fromRGB(255, 200, 64),
		mythic = Color3.fromRGB(255, 92, 130),
	},
	RarityName = {
		common = "Common",
		uncommon = "Uncommon",
		rare = "Rare",
		epic = "Epic",
		legendary = "Legendary",
		mythic = "Mythic",
	},
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
	FontTitle = Enum.Font.GothamBlack,
}

return Theme
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Modules/Theme')
end

-- StarterPlayer/StarterPlayerScripts/Modules/UiKit
local inst = ensure('StarterPlayer/StarterPlayerScripts/Modules/UiKit', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — UiKit (client)
	One toolkit for building UI: frames, labels, buttons, scrolling lists.
	Every controller uses this — no duplicated UI code anywhere.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = require(script.Parent.Theme)

local UiKit = {}

-- Generic instance builder with property table
function UiKit.New(className: string, props: { [string]: any }?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

-- Frame with optional corner radius + automatic UIListLayout
function UiKit.Frame(parent: Instance, size: UDim2, pos: UDim2, color: Color3?, radius: number?): Frame
	local f = UiKit.New("Frame", {
		Name = "Frame",
		Size = size,
		Position = pos,
		BackgroundColor3 = color or Theme.BgPanel,
		BorderSizePixel = 0,
		Parent = parent,
	})
	if radius and radius > 0 then
		UiKit.New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = f })
	end
	return f
end

-- Label
function UiKit.Label(parent: Instance, text: string, size: UDim2, pos: UDim2, color: Color3?, font: Enum.Font?, textSize: number?): TextLabel
	return UiKit.New("TextLabel", {
		Name = "Label",
		Text = text,
		Size = size,
		Position = pos,
		BackgroundTransparency = 1,
		TextColor3 = color or Theme.Text,
		Font = font or Theme.Font,
		TextSize = textSize or 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	})
end

-- Button with hover feedback + click sound
function UiKit.Button(parent: Instance, text: string, onClick: () -> (), opts: { size: UDim2?, pos: UDim2?, color: Color3?, textSize: number? }?): TextButton
	local btn = UiKit.New("TextButton", {
		Name = "Button",
		Text = text,
		Size = opts and opts.size or UDim2.fromScale(0.5, 0.5),
		Position = opts and opts.pos or UDim2.fromScale(0, 0),
		BackgroundColor3 = opts and opts.color or Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = opts and opts.textSize or 16,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = parent,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	btn.MouseButton1Click:Connect(function()
		pcall(function()
			require(script.Parent.Parent.Controllers.AudioController):Play("ui_click")
		end)
		onClick()
	end)
	-- Hover feedback (guarded for stub environments)
	pcall(function()
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = (opts and opts.color or Theme.Accent):Lerp(Color3.new(1, 1, 1), 0.18)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = opts and opts.color or Theme.Accent
		end)
	end)
	return btn
end

-- Scrolling frame with list layout + padding
function UiKit.Scroll(parent: Instance, size: UDim2, pos: UDim2, padding: number?, bg: Color3?): ScrollingFrame
	local sf = UiKit.New("ScrollingFrame", {
		Name = "Scroll",
		Size = size,
		Position = pos,
		BackgroundColor3 = bg or Theme.BgPanelLight,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 6,
		Parent = parent,
	})
	UiKit.New("UIListLayout", {
		Padding = UDim.new(0, padding or 8),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sf,
	})
	UiKit.New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = sf })
	return sf
end

-- Row separator
function UiKit.Separator(parent: Instance, width: UDim2): Frame
	return UiKit.Frame(parent, width, UDim2.fromScale(0.5, 0), Theme.BgPanelLight, 0)
end

return UiKit
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — UiKit (client)
	One toolkit for building UI: frames, labels, buttons, scrolling lists.
	Every controller uses this — no duplicated UI code anywhere.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = require(script.Parent.Theme)

local UiKit = {}

-- Generic instance builder with property table
function UiKit.New(className: string, props: { [string]: any }?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

-- Frame with optional corner radius + automatic UIListLayout
function UiKit.Frame(parent: Instance, size: UDim2, pos: UDim2, color: Color3?, radius: number?): Frame
	local f = UiKit.New("Frame", {
		Name = "Frame",
		Size = size,
		Position = pos,
		BackgroundColor3 = color or Theme.BgPanel,
		BorderSizePixel = 0,
		Parent = parent,
	})
	if radius and radius > 0 then
		UiKit.New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = f })
	end
	return f
end

-- Label
function UiKit.Label(parent: Instance, text: string, size: UDim2, pos: UDim2, color: Color3?, font: Enum.Font?, textSize: number?): TextLabel
	return UiKit.New("TextLabel", {
		Name = "Label",
		Text = text,
		Size = size,
		Position = pos,
		BackgroundTransparency = 1,
		TextColor3 = color or Theme.Text,
		Font = font or Theme.Font,
		TextSize = textSize or 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	})
end

-- Button with hover feedback + click sound
function UiKit.Button(parent: Instance, text: string, onClick: () -> (), opts: { size: UDim2?, pos: UDim2?, color: Color3?, textSize: number? }?): TextButton
	local btn = UiKit.New("TextButton", {
		Name = "Button",
		Text = text,
		Size = opts and opts.size or UDim2.fromScale(0.5, 0.5),
		Position = opts and opts.pos or UDim2.fromScale(0, 0),
		BackgroundColor3 = opts and opts.color or Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = opts and opts.textSize or 16,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = parent,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	btn.MouseButton1Click:Connect(function()
		pcall(function()
			require(script.Parent.Parent.Controllers.AudioController):Play("ui_click")
		end)
		onClick()
	end)
	-- Hover feedback (guarded for stub environments)
	pcall(function()
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = (opts and opts.color or Theme.Accent):Lerp(Color3.new(1, 1, 1), 0.18)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = opts and opts.color or Theme.Accent
		end)
	end)
	return btn
end

-- Scrolling frame with list layout + padding
function UiKit.Scroll(parent: Instance, size: UDim2, pos: UDim2, padding: number?, bg: Color3?): ScrollingFrame
	local sf = UiKit.New("ScrollingFrame", {
		Name = "Scroll",
		Size = size,
		Position = pos,
		BackgroundColor3 = bg or Theme.BgPanelLight,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 6,
		Parent = parent,
	})
	UiKit.New("UIListLayout", {
		Padding = UDim.new(0, padding or 8),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sf,
	})
	UiKit.New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = sf })
	return sf
end

-- Row separator
function UiKit.Separator(parent: Instance, width: UDim2): Frame
	return UiKit.Frame(parent, width, UDim2.fromScale(0.5, 0), Theme.BgPanelLight, 0)
end

return UiKit
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Modules/UiKit')
end

-- StarterPlayer/StarterPlayerScripts/Modules/ClientState
local inst = ensure('StarterPlayer/StarterPlayerScripts/Modules/ClientState', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Modules/ClientState')
end

-- StarterPlayer/StarterPlayerScripts/Modules/FishVisuals
local inst = ensure('StarterPlayer/StarterPlayerScripts/Modules/FishVisuals', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — FishVisuals (client)
	Builds a low-poly procedural fish model from a FishDef — no external models.
	Used by the catch card (ViewportFrame) and bestiary details.
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local FishVisuals = {}

local function part(className: string, name: string, parent: Instance?, color: Color3?, size: Vector3?)
	local p = Instance.new(className)
	p.Name = name
	p.Parent = parent
	if color then
		p.Color = color
	end
	if size then
		p.Size = size
	end
	return p
end

-- Build a fish model. Returns the Model (unparented; caller parents it).
function FishVisuals.Build(fishId: string, shiny: boolean): Model
	local def = FishCatalog.Get(fishId)
	local model = Instance.new("Model")
	model.Name = "Fish_" .. fishId

	local color = def and def.color or Color3.fromRGB(120, 160, 200)
	local accent = def and def.accent or Color3.fromRGB(255, 255, 255)
	local scale = def and def.bodyScale or 1

	if shiny then
		color = Color3.fromRGB(
			math.min(255, color.R * 255 * 1.35 + 60),
			math.min(255, color.G * 255 * 1.35 + 60),
			math.min(255, color.B * 255 * 1.35 + 60)
		)
	end

	local length = 1.2 + scale * 0.8

	-- Body (slightly tapered via two wedges + core)
	local body = part("Part", "Body", model, color, Vector3.new(length, 0.5 + scale * 0.18, 0.35 + scale * 0.12))
	body.Shape = Enum.PartType.Block

	-- Belly (lighter)
	local belly = part("Part", "Belly", model, color:Lerp(Color3.new(1, 1, 1), 0.55), Vector3.new(length * 0.8, 0.18, 0.3 + scale * 0.1))

	-- Tail (accent wedge)
	local tail = part("WedgePart", "Tail", model, accent, Vector3.new(length * 0.32, 0.4 + scale * 0.14, 0.06))
	tail.Material = Enum.Material.SmoothPlastic

	-- Dorsal fin
	local fin = part("WedgePart", "DorsalFin", model, accent, Vector3.new(length * 0.25, 0.3, 0.05))

	-- Eyes
	local eyeL = part("Part", "EyeL", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeL.Shape = Enum.PartType.Ball
	local eyeR = part("Part", "EyeR", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeR.Shape = Enum.PartType.Ball

	-- Shiny sparkle trail
	if shiny then
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Name = "ShinySparkle"
		sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparkle.Rate = 24
		sparkle.Lifetime = NumberRange.new(0.6, 1.2)
		sparkle.Speed = NumberRange.new(0.5, 2)
		sparkle.Size = NumberRange.new(0.06, 0.18)
		sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 240, 160), Color3.fromRGB(255, 255, 255))
		sparkle.Transparency = NumberSequence.new(0.2, 1)
		sparkle.Parent = body
	end

	-- Layout: fish points +X (nose forward)
	body.CFrame = CFrame.new(0, 0, 0)
	belly.CFrame = CFrame.new(0, -0.28, 0)
	tail.CFrame = CFrame.new(-length * 0.62, 0.05, 0) * CFrame.Angles(0, math.pi / 2, 0)
	fin.CFrame = CFrame.new(0, 0.34, 0) * CFrame.Angles(-math.pi / 2.4, 0, 0)
	eyeL.CFrame = CFrame.new(length * 0.48, 0.08, 0.14)
	eyeR.CFrame = CFrame.new(length * 0.48, 0.08, -0.14)

	model.PrimaryPart = body
	return model
end

-- Center a model in a viewport: returns the camera CFrame to frame it.
function FishVisuals.FrameCamera(model: Model, distance: number): CFrame
	local pivot = model:GetPivot()
	local size = model:GetExtentsSize()
	local d = distance or (size.Magnitude + 2.5)
	return CFrame.new(pivot.Position + Vector3.new(0, 0.4, d), pivot.Position)
end

return FishVisuals
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — FishVisuals (client)
	Builds a low-poly procedural fish model from a FishDef — no external models.
	Used by the catch card (ViewportFrame) and bestiary details.
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local FishVisuals = {}

local function part(className: string, name: string, parent: Instance?, color: Color3?, size: Vector3?)
	local p = Instance.new(className)
	p.Name = name
	p.Parent = parent
	if color then
		p.Color = color
	end
	if size then
		p.Size = size
	end
	return p
end

-- Build a fish model. Returns the Model (unparented; caller parents it).
function FishVisuals.Build(fishId: string, shiny: boolean): Model
	local def = FishCatalog.Get(fishId)
	local model = Instance.new("Model")
	model.Name = "Fish_" .. fishId

	local color = def and def.color or Color3.fromRGB(120, 160, 200)
	local accent = def and def.accent or Color3.fromRGB(255, 255, 255)
	local scale = def and def.bodyScale or 1

	if shiny then
		color = Color3.fromRGB(
			math.min(255, color.R * 255 * 1.35 + 60),
			math.min(255, color.G * 255 * 1.35 + 60),
			math.min(255, color.B * 255 * 1.35 + 60)
		)
	end

	local length = 1.2 + scale * 0.8

	-- Body (slightly tapered via two wedges + core)
	local body = part("Part", "Body", model, color, Vector3.new(length, 0.5 + scale * 0.18, 0.35 + scale * 0.12))
	body.Shape = Enum.PartType.Block

	-- Belly (lighter)
	local belly = part("Part", "Belly", model, color:Lerp(Color3.new(1, 1, 1), 0.55), Vector3.new(length * 0.8, 0.18, 0.3 + scale * 0.1))

	-- Tail (accent wedge)
	local tail = part("WedgePart", "Tail", model, accent, Vector3.new(length * 0.32, 0.4 + scale * 0.14, 0.06))
	tail.Material = Enum.Material.SmoothPlastic

	-- Dorsal fin
	local fin = part("WedgePart", "DorsalFin", model, accent, Vector3.new(length * 0.25, 0.3, 0.05))

	-- Eyes
	local eyeL = part("Part", "EyeL", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeL.Shape = Enum.PartType.Ball
	local eyeR = part("Part", "EyeR", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeR.Shape = Enum.PartType.Ball

	-- Shiny sparkle trail
	if shiny then
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Name = "ShinySparkle"
		sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparkle.Rate = 24
		sparkle.Lifetime = NumberRange.new(0.6, 1.2)
		sparkle.Speed = NumberRange.new(0.5, 2)
		sparkle.Size = NumberRange.new(0.06, 0.18)
		sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 240, 160), Color3.fromRGB(255, 255, 255))
		sparkle.Transparency = NumberSequence.new(0.2, 1)
		sparkle.Parent = body
	end

	-- Layout: fish points +X (nose forward)
	body.CFrame = CFrame.new(0, 0, 0)
	belly.CFrame = CFrame.new(0, -0.28, 0)
	tail.CFrame = CFrame.new(-length * 0.62, 0.05, 0) * CFrame.Angles(0, math.pi / 2, 0)
	fin.CFrame = CFrame.new(0, 0.34, 0) * CFrame.Angles(-math.pi / 2.4, 0, 0)
	eyeL.CFrame = CFrame.new(length * 0.48, 0.08, 0.14)
	eyeR.CFrame = CFrame.new(length * 0.48, 0.08, -0.14)

	model.PrimaryPart = body
	return model
end

-- Center a model in a viewport: returns the camera CFrame to frame it.
function FishVisuals.FrameCamera(model: Model, distance: number): CFrame
	local pivot = model:GetPivot()
	local size = model:GetExtentsSize()
	local d = distance or (size.Magnitude + 2.5)
	return CFrame.new(pivot.Position + Vector3.new(0, 0.4, d), pivot.Position)
end

return FishVisuals
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Modules/FishVisuals')
end

print("[Installer] Part 15/15 complete - next: 16")
