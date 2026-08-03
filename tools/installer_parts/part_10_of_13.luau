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

-- StarterPlayer/StarterPlayerScripts/Bootstrap
local inst = ensure('StarterPlayer/StarterPlayerScripts/Bootstrap', 'LocalScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Bootstrap (client, LocalScript)
	Client service loader + message dispatcher.
	Every server message is applied to ClientState, then fanned out to all
	controllers that registered a handler for its type.
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ClientState = require(script.Parent.Modules.ClientState)

local ctx = {
	Services = {},
	Handlers = {},
}

-- Controllers call this with dot syntax: ctx.RegisterHandler("Type", fn).
-- Attached AFTER the table is declared (Luau forbids a local referencing
-- itself inside its own initializer — this would be nil in production).
ctx.RegisterHandler = function(msgType: string, fn: (any) -> ())
	local list = ctx.Handlers[msgType]
	if not list then
		list = {}
		ctx.Handlers[msgType] = list
	end
	table.insert(list, fn)
end

-- Controller load order (Audio first so buttons can click-sound immediately)
local CONTROLLERS = { "AudioController", "CastController", "UIController", "MenuUIController" }

for _, name in pairs(CONTROLLERS) do
	local ok, controller = pcall(function()
		return require(script.Parent.Controllers[name])
	end)
	if not ok then
		warn("[Client] Failed to load controller " .. name .. ": " .. tostring(controller))
		continue
	end
	ctx.Services[name] = controller
	if controller.Init then
		controller:Init(ctx)
	end
end

-- Message dispatch
Remotes:OnClientMessage(function(message: any)
	if typeof(message) ~= "table" or typeof(message.type) ~= "string" then
		return
	end
	ClientState:Apply(message.type, message.payload)
	local list = ctx.Handlers[message.type]
	if list then
		for _, fn in pairs(list) do
			pcall(fn, message.payload)
		end
	end
end)

-- Start controllers (after UI-ready)
for _, name in pairs(CONTROLLERS) do
	local controller = ctx.Services[name]
	if controller and controller.Start then
		pcall(controller.Start, controller)
	end
end

-- Ask the server for a full snapshot (safe to repeat; server just re-syncs)
task.delay(1, function()
	ClientState:Send("SyncRequest")
end)

-- Expose context for the automated test harness (no-op in production:
-- the environment never defines __tdHarnessCtx unless the test runner injects it)
local env = getfenv()
if env.__tdHarnessCtx ~= nil then
	env.__tdHarnessCtx = ctx
end

print("[Tidebound] Client booted. Controllers: " .. table.concat(CONTROLLERS, ", "))
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Bootstrap (client, LocalScript)
	Client service loader + message dispatcher.
	Every server message is applied to ClientState, then fanned out to all
	controllers that registered a handler for its type.
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ClientState = require(script.Parent.Modules.ClientState)

local ctx = {
	Services = {},
	Handlers = {},
}

-- Controllers call this with dot syntax: ctx.RegisterHandler("Type", fn).
-- Attached AFTER the table is declared (Luau forbids a local referencing
-- itself inside its own initializer — this would be nil in production).
ctx.RegisterHandler = function(msgType: string, fn: (any) -> ())
	local list = ctx.Handlers[msgType]
	if not list then
		list = {}
		ctx.Handlers[msgType] = list
	end
	table.insert(list, fn)
end

-- Controller load order (Audio first so buttons can click-sound immediately)
local CONTROLLERS = { "AudioController", "CastController", "UIController", "MenuUIController" }

for _, name in pairs(CONTROLLERS) do
	local ok, controller = pcall(function()
		return require(script.Parent.Controllers[name])
	end)
	if not ok then
		warn("[Client] Failed to load controller " .. name .. ": " .. tostring(controller))
		continue
	end
	ctx.Services[name] = controller
	if controller.Init then
		controller:Init(ctx)
	end
end

-- Message dispatch
Remotes:OnClientMessage(function(message: any)
	if typeof(message) ~= "table" or typeof(message.type) ~= "string" then
		return
	end
	ClientState:Apply(message.type, message.payload)
	local list = ctx.Handlers[message.type]
	if list then
		for _, fn in pairs(list) do
			pcall(fn, message.payload)
		end
	end
end)

-- Start controllers (after UI-ready)
for _, name in pairs(CONTROLLERS) do
	local controller = ctx.Services[name]
	if controller and controller.Start then
		pcall(controller.Start, controller)
	end
end

-- Ask the server for a full snapshot (safe to repeat; server just re-syncs)
task.delay(1, function()
	ClientState:Send("SyncRequest")
end)

-- Expose context for the automated test harness (no-op in production:
-- the environment never defines __tdHarnessCtx unless the test runner injects it)
local env = getfenv()
if env.__tdHarnessCtx ~= nil then
	env.__tdHarnessCtx = ctx
end

print("[Tidebound] Client booted. Controllers: " .. table.concat(CONTROLLERS, ", "))
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Bootstrap')
end

-- StarterPlayer/StarterPlayerScripts/Controllers/AudioController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/AudioController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — AudioController (client, ModuleScript)
	Lazy Sound player keyed by name -> SoundId from Config.AUDIO_IDS.
	IDs are filled in after the synthesized WAVs (assets/audio/) are uploaded
	in Studio (Creator Dashboard > Audio). id == 0 = graceful silence.
	Phase 4 | AI-assisted | 2026-08-02
]]

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local AudioController = {}
AudioController.Name = "AudioController"

local sounds: { [string]: Sound } = {}

-- Built-in Roblox sounds (shipped with every client — no upload required).
-- Custom uploaded WAVs (Config.AUDIO_IDS) override these when set.
local DEFAULT_PATHS: { [string]: string } = {
	ui_click = "rbxasset://sounds/clickfast.mp3",
	ui_error = "rbxasset://sounds/collide.mp3",
	cast_splash = "rbxasset://sounds/impact_water.mp3",
	bite = "rbxasset://sounds/Kerplunk.mp3",
	reel_tick = "rbxasset://sounds/clickfast.mp3",
	catch_common = "rbxasset://sounds/Kerplunk.mp3",
	catch_rare = "rbxasset://sounds/electronicpingshort.mp3",
	catch_mythic = "rbxasset://sounds/electronicpingshort.mp3",
	levelup = "rbxasset://sounds/electronicpingshort.mp3",
	coins = "rbxasset://sounds/clickfast.mp3",
	streak = "rbxasset://sounds/electronicpingshort.mp3",
	storm = "rbxasset://sounds/impact_explosion_02.mp3",
	achievement = "rbxasset://sounds/electronicpingshort.mp3",
	buy = "rbxasset://sounds/clickfast.mp3",
}

function AudioController:Play(name: string, opts: { volume: number?, looped: boolean?, pitch: number? }?)
	local id = Config.AUDIO_IDS[name]
	local path = ""
	if id and id > 0 then
		path = "rbxassetid://" .. tostring(id)
	else
		path = DEFAULT_PATHS[name] or ""
	end
	if path == "" then
		return
	end
	local snd = sounds[name]
	if not snd then
		snd = Instance.new("Sound")
		snd.Name = "Tidebound_" .. name
		snd.SoundId = path
		snd.Parent = SoundService
		sounds[name] = snd
	end
	snd.Volume = (opts and opts.volume) or 0.6
	snd.Looped = (opts and opts.looped) == true
	if opts and opts.pitch then
		snd.PlaybackSpeed = opts.pitch
	end
	snd:Play()
end

-- Convenience: play one of a set (used for catch rarity sounds)
function AudioController:PlayCatch(rarity: string, shiny: boolean)
	if shiny or rarity == "mythic" then
		self:Play("catch_mythic")
	elseif rarity == "legendary" or rarity == "epic" then
		self:Play("catch_rare")
	else
		self:Play("catch_common")
	end
end

function AudioController:Init(ctx)
	self.ctx = ctx
end

function AudioController:Start()
end

return AudioController
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — AudioController (client, ModuleScript)
	Lazy Sound player keyed by name -> SoundId from Config.AUDIO_IDS.
	IDs are filled in after the synthesized WAVs (assets/audio/) are uploaded
	in Studio (Creator Dashboard > Audio). id == 0 = graceful silence.
	Phase 4 | AI-assisted | 2026-08-02
]]

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local AudioController = {}
AudioController.Name = "AudioController"

local sounds: { [string]: Sound } = {}

-- Built-in Roblox sounds (shipped with every client — no upload required).
-- Custom uploaded WAVs (Config.AUDIO_IDS) override these when set.
local DEFAULT_PATHS: { [string]: string } = {
	ui_click = "rbxasset://sounds/clickfast.mp3",
	ui_error = "rbxasset://sounds/collide.mp3",
	cast_splash = "rbxasset://sounds/impact_water.mp3",
	bite = "rbxasset://sounds/Kerplunk.mp3",
	reel_tick = "rbxasset://sounds/clickfast.mp3",
	catch_common = "rbxasset://sounds/Kerplunk.mp3",
	catch_rare = "rbxasset://sounds/electronicpingshort.mp3",
	catch_mythic = "rbxasset://sounds/electronicpingshort.mp3",
	levelup = "rbxasset://sounds/electronicpingshort.mp3",
	coins = "rbxasset://sounds/clickfast.mp3",
	streak = "rbxasset://sounds/electronicpingshort.mp3",
	storm = "rbxasset://sounds/impact_explosion_02.mp3",
	achievement = "rbxasset://sounds/electronicpingshort.mp3",
	buy = "rbxasset://sounds/clickfast.mp3",
}

function AudioController:Play(name: string, opts: { volume: number?, looped: boolean?, pitch: number? }?)
	local id = Config.AUDIO_IDS[name]
	local path = ""
	if id and id > 0 then
		path = "rbxassetid://" .. tostring(id)
	else
		path = DEFAULT_PATHS[name] or ""
	end
	if path == "" then
		return
	end
	local snd = sounds[name]
	if not snd then
		snd = Instance.new("Sound")
		snd.Name = "Tidebound_" .. name
		snd.SoundId = path
		snd.Parent = SoundService
		sounds[name] = snd
	end
	snd.Volume = (opts and opts.volume) or 0.6
	snd.Looped = (opts and opts.looped) == true
	if opts and opts.pitch then
		snd.PlaybackSpeed = opts.pitch
	end
	snd:Play()
end

-- Convenience: play one of a set (used for catch rarity sounds)
function AudioController:PlayCatch(rarity: string, shiny: boolean)
	if shiny or rarity == "mythic" then
		self:Play("catch_mythic")
	elseif rarity == "legendary" or rarity == "epic" then
		self:Play("catch_rare")
	else
		self:Play("catch_common")
	end
end

function AudioController:Init(ctx)
	self.ctx = ctx
end

function AudioController:Start()
end

return AudioController
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/AudioController')
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

print("[Installer] Part 10/13 complete - next: 11")
