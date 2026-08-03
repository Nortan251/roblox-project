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

-- StarterPlayer/StarterPlayerScripts/Controllers/GuideController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/GuideController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — GuideController (client, ModuleScript)
	The guided tutorial popup (bottom-center, above the XP bar).
	Server-driven: WorldInteractionsService sends GuideUpdate messages.
	Also opens panels when the server says so (OpenPanel).
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local GuideController = {}
GuideController.Name = "GuideController"

local player = Players.LocalPlayer
local gui: ScreenGui
local frame: Frame
local label: TextLabel
local dismissBtn: TextButton

function GuideController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "GuideGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 4,
		Parent = player.PlayerGui,
	})
	frame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.1), UDim2.fromScale(0.5, 0.76), Theme.BgPanel, 12)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundTransparency = 0.15
	frame.Visible = false
	label = UiKit.Label(frame, "", UDim2.fromScale(0.9, 0.6), UDim2.fromScale(0.05, 0.1), Theme.Text, Theme.FontBold, 15)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextWrapped = true
	dismissBtn = UiKit.Button(frame, "Got it!", function()
		ClientState:Send("GuideDone")
		frame.Visible = false
	end, { size = UDim2.fromScale(0.22, 0.28), pos = UDim2.fromScale(0.39, 0.66), color = Theme.Accent, textSize = 13 })
end

function GuideController:HandleGuideUpdate(payload: any)
	if payload.active and typeof(payload.text) == "string" then
		label.Text = payload.text
		frame.Visible = true
	else
		frame.Visible = false
	end
end

function GuideController:HandleOpenPanel(payload: any)
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	if payload and typeof(payload.panel) == "string" then
		menu:Open(payload.panel)
	end
end

function GuideController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("GuideUpdate", function(payload)
		self:HandleGuideUpdate(payload)
	end)
	ctx.RegisterHandler("OpenPanel", function(payload)
		self:HandleOpenPanel(payload)
	end)
end

function GuideController:Start()
	self:BuildUI()
end

function GuideController:Stop()
	if gui then
		gui:Destroy()
	end
end

return GuideController
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — GuideController (client, ModuleScript)
	The guided tutorial popup (bottom-center, above the XP bar).
	Server-driven: WorldInteractionsService sends GuideUpdate messages.
	Also opens panels when the server says so (OpenPanel).
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local GuideController = {}
GuideController.Name = "GuideController"

local player = Players.LocalPlayer
local gui: ScreenGui
local frame: Frame
local label: TextLabel
local dismissBtn: TextButton

function GuideController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "GuideGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 4,
		Parent = player.PlayerGui,
	})
	frame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.1), UDim2.fromScale(0.5, 0.76), Theme.BgPanel, 12)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundTransparency = 0.15
	frame.Visible = false
	label = UiKit.Label(frame, "", UDim2.fromScale(0.9, 0.6), UDim2.fromScale(0.05, 0.1), Theme.Text, Theme.FontBold, 15)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextWrapped = true
	dismissBtn = UiKit.Button(frame, "Got it!", function()
		ClientState:Send("GuideDone")
		frame.Visible = false
	end, { size = UDim2.fromScale(0.22, 0.28), pos = UDim2.fromScale(0.39, 0.66), color = Theme.Accent, textSize = 13 })
end

function GuideController:HandleGuideUpdate(payload: any)
	if payload.active and typeof(payload.text) == "string" then
		label.Text = payload.text
		frame.Visible = true
	else
		frame.Visible = false
	end
end

function GuideController:HandleOpenPanel(payload: any)
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	if payload and typeof(payload.panel) == "string" then
		menu:Open(payload.panel)
	end
end

function GuideController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("GuideUpdate", function(payload)
		self:HandleGuideUpdate(payload)
	end)
	ctx.RegisterHandler("OpenPanel", function(payload)
		self:HandleOpenPanel(payload)
	end)
end

function GuideController:Start()
	self:BuildUI()
end

function GuideController:Stop()
	if gui then
		gui:Destroy()
	end
end

return GuideController
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/GuideController')
end

-- StarterPlayer/StarterPlayerScripts/Controllers/CastController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/CastController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — CastController (client, ModuleScript)
	Casting + reeling input. Server-authoritative: we only send intents.
	- Hold Q / mouse / CAST button to charge power, release to cast.
	- While reeling: hold to reel (progress rises, tension rises), release to rest.
	- Auto-reel button consumes premium tokens (never required).
	Phase 4 | AI-assisted | 2026-08-02
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local CastController = {}
CastController.Name = "CastController"

local player = Players.LocalPlayer
local gui: ScreenGui
local castButton: TextButton
local reelFrame: Frame
local powerBarFill: Frame
local progressFill: Frame
local tensionFill: Frame
local reelHint: TextLabel
local autoReelButton: TextButton

local charging = false
local chargeStart = 0
local isReeling = false
local lastHold = false
local lastHoldSent = false
local inputConnections: { RBXScriptConnection } = {}

local function canAct(): boolean
	return not ClientState:Get().uiOpen
end

-- ── UI ───────────────────────────────────────────────────────────────────

function CastController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "CastGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 5,
		Parent = player.PlayerGui,
	})

	-- Power bar (above cast button)
	local powerBar = UiKit.Frame(gui, UDim2.fromScale(0.28, 0.05), UDim2.fromScale(1, 0.5), Theme.BgPanel, 8)
	powerBar.Position = UDim2.fromScale(0.5, 0.62)
	powerBar.AnchorPoint = Vector2.new(0.5, 0.5)
	powerBar.BackgroundTransparency = 0.6
	powerBar.Visible = false
	powerBarFill = UiKit.Frame(powerBar, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	powerBarFill.AnchorPoint = Vector2.new(0, 0)

	-- Cast button (mobile-first; also clickable on desktop)
	castButton = UiKit.New("TextButton", {
		Name = "CastButton",
		Text = "🎣\nCAST",
		Size = UDim2.fromScale(0.2, 0.14),
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = 18,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = gui,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = castButton })
	local castPad = UiKit.New("UIPadding", { PaddingBottom = UDim.new(0, 18), PaddingRight = UDim.new(0, 18), Parent = castButton })

	-- Reel frame (hidden until a bite)
	reelFrame = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.22), UDim2.fromScale(0.5, 0.78), Theme.BgPanel, 12)
	reelFrame.AnchorPoint = Vector2.new(0.5, 1)
	reelFrame.Visible = false

	reelHint = UiKit.Label(reelFrame, "HOLD to reel — release to rest!", UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), Theme.Text)
	UiKit.Label(reelFrame, "PROGRESS", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.22), Theme.TextDim, nil, 12)
	local progressBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.4), Theme.BgPanelLight, 6)
	progressFill = UiKit.Frame(progressBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Success, 6)
	UiKit.Label(reelFrame, "TENSION", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.55), Theme.TextDim, nil, 12)
	local tensionBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.73), Theme.BgPanelLight, 6)
	tensionFill = UiKit.Frame(tensionBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Danger, 6)

	autoReelButton = UiKit.Button(reelFrame, "⚡ AUTO-REEL", function()
		ClientState:Send("AutoReel")
	end, { size = UDim2.fromScale(0.16, 0.24), pos = UDim2.fromScale(0.84, 0.6), color = Theme.Accent2, textSize = 12 })
end

-- ── Input ────────────────────────────────────────────────────────────────

local function isCastInput(input: InputObject): boolean
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		return true
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		return true
	end
	return false
end

local function beginCharge()
	if not canAct() or isReeling then
		return
	end
	charging = true
	chargeStart = os.clock()
	powerBar.Visible = true
	powerBar.Parent.Visible = true
	powerBarFill.Size = UDim2.fromScale(0, 1)
end

local function endCharge()
	if not charging then
		return
	end
	charging = false
	powerBar.Visible = false
	local heldFor = os.clock() - chargeStart
	local power = Util.clamp(heldFor / Config.CAST_POWER_TIME, 0, 1)
	if heldFor < 0.1 then
		power = Config.QUICK_CAST_POWER -- tap = quick cast
	end
	-- Direction: camera look, flattened to the water plane
	local camera = Workspace.CurrentCamera
	local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude < 0.1 then
		look = Vector3.new(0, 0, -1)
	end
	ClientState:Send("Cast", { dir = look.Unit, power = power })
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("cast_splash")
	end)
end

local function onHoldChange(held: boolean)
	lastHold = held
	if isReeling and lastHoldSent ~= held then
		lastHoldSent = held
		ClientState:Send("ReelHold", { held = held })
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function CastController:HandleBite(_payload: any)
	isReeling = true
	lastHoldSent = nil
	reelFrame.Visible = true
	castButton.Visible = false
	progressFill.Size = UDim2.fromScale(0, 1)
	tensionFill.Size = UDim2.fromScale(0, 1)
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("bite")
	end)
end

function CastController:HandleReelState(payload: any)
	if not isReeling then
		return
	end
	local p = Util.clamp(payload.progress or 0, 0, 100) / 100
	local t = Util.clamp(payload.tension or 0, 0, 100) / 100
	progressFill.Size = UDim2.fromScale(p, 1)
	tensionFill.Size = UDim2.fromScale(t, 1)
	if payload.fishName and payload.fishName ~= "" then
		local rarity = payload.rarity or "common"
		reelHint.Text = payload.fishName .. " — " .. (Theme.RarityName[rarity] or rarity)
		reelHint.TextColor3 = Theme.Rarity[rarity] or Theme.Text
	end
end

function CastController:HandleCatchResult(_payload: any)
	isReeling = false
	lastHoldSent = nil
	reelFrame.Visible = false
	castButton.Visible = true
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function CastController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("Bite", function(payload)
		self:HandleBite(payload)
	end)
	ctx.RegisterHandler("ReelState", function(payload)
		self:HandleReelState(payload)
	end)
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
end

function CastController:Start()
	self:BuildUI()

	table.insert(inputConnections, UserInputService.InputBegan:Connect(function(input)
		if isCastInput(input) then
			beginCharge()
		end
		if isCastInput(input) then
			onHoldChange(true)
		end
	end))
	table.insert(inputConnections, UserInputService.InputEnded:Connect(function(input)
		if isCastInput(input) then
			endCharge()
			onHoldChange(false)
		end
	end))

	castButton.MouseButton1Down:Connect(function()
		beginCharge()
	end)
	castButton.MouseButton1Up:Connect(function()
		endCharge()
	end)

	-- Power bar animation
	RunService.RenderStepped:Connect(function(_dt)
		if charging then
			local power = Util.clamp((os.clock() - chargeStart) / Config.CAST_POWER_TIME, 0, 1)
			powerBarFill.Size = UDim2.fromScale(power, 1)
		end
	end)
end

function CastController:Stop()
	for _, conn in inputConnections do
		conn:Disconnect()
	end
	if gui then
		gui:Destroy()
	end
end

return CastController
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — CastController (client, ModuleScript)
	Casting + reeling input. Server-authoritative: we only send intents.
	- Hold Q / mouse / CAST button to charge power, release to cast.
	- While reeling: hold to reel (progress rises, tension rises), release to rest.
	- Auto-reel button consumes premium tokens (never required).
	Phase 4 | AI-assisted | 2026-08-02
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local CastController = {}
CastController.Name = "CastController"

local player = Players.LocalPlayer
local gui: ScreenGui
local castButton: TextButton
local reelFrame: Frame
local powerBarFill: Frame
local progressFill: Frame
local tensionFill: Frame
local reelHint: TextLabel
local autoReelButton: TextButton

local charging = false
local chargeStart = 0
local isReeling = false
local lastHold = false
local lastHoldSent = false
local inputConnections: { RBXScriptConnection } = {}

local function canAct(): boolean
	return not ClientState:Get().uiOpen
end

-- ── UI ───────────────────────────────────────────────────────────────────

function CastController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "CastGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 5,
		Parent = player.PlayerGui,
	})

	-- Power bar (above cast button)
	local powerBar = UiKit.Frame(gui, UDim2.fromScale(0.28, 0.05), UDim2.fromScale(1, 0.5), Theme.BgPanel, 8)
	powerBar.Position = UDim2.fromScale(0.5, 0.62)
	powerBar.AnchorPoint = Vector2.new(0.5, 0.5)
	powerBar.BackgroundTransparency = 0.6
	powerBar.Visible = false
	powerBarFill = UiKit.Frame(powerBar, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	powerBarFill.AnchorPoint = Vector2.new(0, 0)

	-- Cast button (mobile-first; also clickable on desktop)
	castButton = UiKit.New("TextButton", {
		Name = "CastButton",
		Text = "🎣\nCAST",
		Size = UDim2.fromScale(0.2, 0.14),
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = 18,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = gui,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = castButton })
	local castPad = UiKit.New("UIPadding", { PaddingBottom = UDim.new(0, 18), PaddingRight = UDim.new(0, 18), Parent = castButton })

	-- Reel frame (hidden until a bite)
	reelFrame = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.22), UDim2.fromScale(0.5, 0.78), Theme.BgPanel, 12)
	reelFrame.AnchorPoint = Vector2.new(0.5, 1)
	reelFrame.Visible = false

	reelHint = UiKit.Label(reelFrame, "HOLD to reel — release to rest!", UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), Theme.Text)
	UiKit.Label(reelFrame, "PROGRESS", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.22), Theme.TextDim, nil, 12)
	local progressBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.4), Theme.BgPanelLight, 6)
	progressFill = UiKit.Frame(progressBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Success, 6)
	UiKit.Label(reelFrame, "TENSION", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.55), Theme.TextDim, nil, 12)
	local tensionBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.73), Theme.BgPanelLight, 6)
	tensionFill = UiKit.Frame(tensionBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Danger, 6)

	autoReelButton = UiKit.Button(reelFrame, "⚡ AUTO-REEL", function()
		ClientState:Send("AutoReel")
	end, { size = UDim2.fromScale(0.16, 0.24), pos = UDim2.fromScale(0.84, 0.6), color = Theme.Accent2, textSize = 12 })
end

-- ── Input ────────────────────────────────────────────────────────────────

local function isCastInput(input: InputObject): boolean
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		return true
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		return true
	end
	return false
end

local function beginCharge()
	if not canAct() or isReeling then
		return
	end
	charging = true
	chargeStart = os.clock()
	powerBar.Visible = true
	powerBar.Parent.Visible = true
	powerBarFill.Size = UDim2.fromScale(0, 1)
end

local function endCharge()
	if not charging then
		return
	end
	charging = false
	powerBar.Visible = false
	local heldFor = os.clock() - chargeStart
	local power = Util.clamp(heldFor / Config.CAST_POWER_TIME, 0, 1)
	if heldFor < 0.1 then
		power = Config.QUICK_CAST_POWER -- tap = quick cast
	end
	-- Direction: camera look, flattened to the water plane
	local camera = Workspace.CurrentCamera
	local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude < 0.1 then
		look = Vector3.new(0, 0, -1)
	end
	ClientState:Send("Cast", { dir = look.Unit, power = power })
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("cast_splash")
	end)
end

local function onHoldChange(held: boolean)
	lastHold = held
	if isReeling and lastHoldSent ~= held then
		lastHoldSent = held
		ClientState:Send("ReelHold", { held = held })
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function CastController:HandleBite(_payload: any)
	isReeling = true
	lastHoldSent = nil
	reelFrame.Visible = true
	castButton.Visible = false
	progressFill.Size = UDim2.fromScale(0, 1)
	tensionFill.Size = UDim2.fromScale(0, 1)
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("bite")
	end)
end

function CastController:HandleReelState(payload: any)
	if not isReeling then
		return
	end
	local p = Util.clamp(payload.progress or 0, 0, 100) / 100
	local t = Util.clamp(payload.tension or 0, 0, 100) / 100
	progressFill.Size = UDim2.fromScale(p, 1)
	tensionFill.Size = UDim2.fromScale(t, 1)
	if payload.fishName and payload.fishName ~= "" then
		local rarity = payload.rarity or "common"
		reelHint.Text = payload.fishName .. " — " .. (Theme.RarityName[rarity] or rarity)
		reelHint.TextColor3 = Theme.Rarity[rarity] or Theme.Text
	end
end

function CastController:HandleCatchResult(_payload: any)
	isReeling = false
	lastHoldSent = nil
	reelFrame.Visible = false
	castButton.Visible = true
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function CastController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("Bite", function(payload)
		self:HandleBite(payload)
	end)
	ctx.RegisterHandler("ReelState", function(payload)
		self:HandleReelState(payload)
	end)
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
end

function CastController:Start()
	self:BuildUI()

	table.insert(inputConnections, UserInputService.InputBegan:Connect(function(input)
		if isCastInput(input) then
			beginCharge()
		end
		if isCastInput(input) then
			onHoldChange(true)
		end
	end))
	table.insert(inputConnections, UserInputService.InputEnded:Connect(function(input)
		if isCastInput(input) then
			endCharge()
			onHoldChange(false)
		end
	end))

	castButton.MouseButton1Down:Connect(function()
		beginCharge()
	end)
	castButton.MouseButton1Up:Connect(function()
		endCharge()
	end)

	-- Power bar animation
	RunService.RenderStepped:Connect(function(_dt)
		if charging then
			local power = Util.clamp((os.clock() - chargeStart) / Config.CAST_POWER_TIME, 0, 1)
			powerBarFill.Size = UDim2.fromScale(power, 1)
		end
	end)
end

function CastController:Stop()
	for _, conn in inputConnections do
		conn:Disconnect()
	end
	if gui then
		gui:Destroy()
	end
end

return CastController
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/CastController')
end

print("[Installer] Part 12/15 complete - next: 13")
