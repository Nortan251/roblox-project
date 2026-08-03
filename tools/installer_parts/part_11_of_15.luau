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

-- ServerScriptService/Services/WorldInteractionsService
local inst = ensure('ServerScriptService/Services/WorldInteractionsService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — WorldInteractionsService
	Makes the world ALIVE: proximity prompts + clickable interactables.
	- Old Salt (tutorial NPC): guided first-catch dialog → quest line
	- Market stall: opens the shop panel
	- Sign: opens the travel (map) panel
	- Crate: free daily pearl? no — free starter bait once
	- Old Salt dialog uses REAL guided steps (server-driven, no UI hacking)
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldInteractionsService = {}
WorldInteractionsService.Name = "WorldInteractionsService"

-- Old Salt guided tutorial steps (server-driven)
local GUIDE_STEPS = {
	{ prompt = "Grab the starter rod and cast it! Hold Q (or tap CAST) to charge, release to throw.", waitFor = "firstCast" },
	{ prompt = "When the bobber splashes — HOLD to reel it in! Release to rest the tension.", waitFor = "firstReel" },
	{ prompt = "Nice catch! Open your BAG (top-right) and Sell it, or keep it for the bestiary.", waitFor = "firstCatch" },
	{ prompt = "Open the SHOP (top-right) and grab the River Oak Rod — your first upgrade!", waitFor = "firstBuy" },
	{ prompt = "Check the QUESTS tab every day for rewards — and race the storms for rare fish!", waitFor = "done" },
}

function WorldInteractionsService:GetGuideStep(data: any): number
	local flags = data.flags
	if not flags.tutorialDone then
		if not flags.guideFirstCast then
			return 1
		elseif not flags.guideFirstReel then
			return 2
		elseif not flags.guideFirstCatch then
			return 3
		elseif not flags.guideFirstBuy then
			return 4
		else
			return 5
		end
	end
	return 0
end

function WorldInteractionsService:SendGuide(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local step = self:GetGuideStep(data)
	if step == 0 then
		Remotes:SendToClient(player, {
			type = "GuideUpdate",
			payload = { active = false, text = "" },
		})
		return
	end
	Remotes:SendToClient(player, {
		type = "GuideUpdate",
		payload = { active = true, text = GUIDE_STEPS[step].prompt, step = step },
	})
end

-- Called by other services when the player does the guided action
function WorldInteractionsService:OnCast(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCast then
		data.flags.guideFirstCast = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnReelStart(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstReel then
		data.flags.guideFirstReel = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstCatch(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCatch then
		data.flags.guideFirstCatch = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstBuy(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstBuy then
		data.flags.guideFirstBuy = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnGuideDone(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data then
		data.flags.tutorialDone = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

-- World interactables (ProximityPrompts) — called by FishingService/Bootstrap after map build
local PROMPTS = {
	{
		partName = "OldSaltBody",
		promptName = "TalkToOldSalt",
		text = "Talk to Old Salt",
		action = "talk",
	},
	{
		partName = "StallTable",
		promptName = "OpenShop",
		text = "Open Shop",
		action = "shop",
	},
	{
		partName = "SignBoard",
		promptName = "OpenMap",
		text = "Open Map",
		action = "travel",
	},
	{
		partName = "ChestBase",
		promptName = "OpenChest",
		text = "Open the Sunken Chest",
		action = "chest",
		chestKey = "abyss",
	},
	{
		partName = "IsleChest",
		promptName = "OpenIsleChest",
		text = "Open the Isle Chest",
		action = "chest",
		chestKey = "isle",
	},
	{
		partName = "GrottoChest",
		promptName = "OpenGrottoChest",
		text = "Open the Grotto Chest",
		action = "chest",
		chestKey = "grotto",
	},
}

function WorldInteractionsService:SetupPrompts()
	task.spawn(function()
		task.wait(2)
		for _, def in ipairs(PROMPTS) do
			local part = Workspace:FindFirstChild(def.partName) :: BasePart?
			if part then
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = def.promptName
				prompt.ActionText = def.text
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.ObjectText = def.partName
				prompt.Parent = part
				prompt.Triggered:Connect(function(player)
					self:OnPrompt(player, def.action, def.chestKey)
				end)
			end
		end
	end)
end

function WorldInteractionsService:OnPrompt(player: Player, action: string, chestKey: string?)
	if action == "talk" then
		self:SendGuide(player)
	elseif action == "shop" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "shop" } })
	elseif action == "travel" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "travel" } })
	elseif action == "chest" and chestKey then
		self:OpenChest(player, chestKey)
	end
end

-- Secret chests: one-time pearl reward per account (world collectibles)
function WorldInteractionsService:OpenChest(player: Player, chestKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if data.flags.chestsClaimed[chestKey] then
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "chestEmpty", text = "This chest is empty — you already claimed it!" },
		})
		return
	end
	data.flags.chestsClaimed[chestKey] = true
	local pearls = chestKey == "abyss" and 15 or 10
	self.ctx.Services.EconomyService:AddPearls(player, pearls, "chest:" .. chestKey)
	Remotes:SendToClient(player, {
		type = "EventBanner",
		payload = { kind = "chest", text = "💎 You found " .. pearls .. " pearls in the chest!" },
	})
end

function WorldInteractionsService:Init(ctx)
	self.ctx = ctx
end

function WorldInteractionsService:Start()
	self:SetupPrompts()
end

function WorldInteractionsService:Stop()
end

return WorldInteractionsService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — WorldInteractionsService
	Makes the world ALIVE: proximity prompts + clickable interactables.
	- Old Salt (tutorial NPC): guided first-catch dialog → quest line
	- Market stall: opens the shop panel
	- Sign: opens the travel (map) panel
	- Crate: free daily pearl? no — free starter bait once
	- Old Salt dialog uses REAL guided steps (server-driven, no UI hacking)
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldInteractionsService = {}
WorldInteractionsService.Name = "WorldInteractionsService"

-- Old Salt guided tutorial steps (server-driven)
local GUIDE_STEPS = {
	{ prompt = "Grab the starter rod and cast it! Hold Q (or tap CAST) to charge, release to throw.", waitFor = "firstCast" },
	{ prompt = "When the bobber splashes — HOLD to reel it in! Release to rest the tension.", waitFor = "firstReel" },
	{ prompt = "Nice catch! Open your BAG (top-right) and Sell it, or keep it for the bestiary.", waitFor = "firstCatch" },
	{ prompt = "Open the SHOP (top-right) and grab the River Oak Rod — your first upgrade!", waitFor = "firstBuy" },
	{ prompt = "Check the QUESTS tab every day for rewards — and race the storms for rare fish!", waitFor = "done" },
}

function WorldInteractionsService:GetGuideStep(data: any): number
	local flags = data.flags
	if not flags.tutorialDone then
		if not flags.guideFirstCast then
			return 1
		elseif not flags.guideFirstReel then
			return 2
		elseif not flags.guideFirstCatch then
			return 3
		elseif not flags.guideFirstBuy then
			return 4
		else
			return 5
		end
	end
	return 0
end

function WorldInteractionsService:SendGuide(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local step = self:GetGuideStep(data)
	if step == 0 then
		Remotes:SendToClient(player, {
			type = "GuideUpdate",
			payload = { active = false, text = "" },
		})
		return
	end
	Remotes:SendToClient(player, {
		type = "GuideUpdate",
		payload = { active = true, text = GUIDE_STEPS[step].prompt, step = step },
	})
end

-- Called by other services when the player does the guided action
function WorldInteractionsService:OnCast(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCast then
		data.flags.guideFirstCast = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnReelStart(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstReel then
		data.flags.guideFirstReel = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstCatch(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCatch then
		data.flags.guideFirstCatch = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstBuy(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstBuy then
		data.flags.guideFirstBuy = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnGuideDone(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data then
		data.flags.tutorialDone = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

-- World interactables (ProximityPrompts) — called by FishingService/Bootstrap after map build
local PROMPTS = {
	{
		partName = "OldSaltBody",
		promptName = "TalkToOldSalt",
		text = "Talk to Old Salt",
		action = "talk",
	},
	{
		partName = "StallTable",
		promptName = "OpenShop",
		text = "Open Shop",
		action = "shop",
	},
	{
		partName = "SignBoard",
		promptName = "OpenMap",
		text = "Open Map",
		action = "travel",
	},
	{
		partName = "ChestBase",
		promptName = "OpenChest",
		text = "Open the Sunken Chest",
		action = "chest",
		chestKey = "abyss",
	},
	{
		partName = "IsleChest",
		promptName = "OpenIsleChest",
		text = "Open the Isle Chest",
		action = "chest",
		chestKey = "isle",
	},
	{
		partName = "GrottoChest",
		promptName = "OpenGrottoChest",
		text = "Open the Grotto Chest",
		action = "chest",
		chestKey = "grotto",
	},
}

function WorldInteractionsService:SetupPrompts()
	task.spawn(function()
		task.wait(2)
		for _, def in ipairs(PROMPTS) do
			local part = Workspace:FindFirstChild(def.partName) :: BasePart?
			if part then
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = def.promptName
				prompt.ActionText = def.text
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.ObjectText = def.partName
				prompt.Parent = part
				prompt.Triggered:Connect(function(player)
					self:OnPrompt(player, def.action, def.chestKey)
				end)
			end
		end
	end)
end

function WorldInteractionsService:OnPrompt(player: Player, action: string, chestKey: string?)
	if action == "talk" then
		self:SendGuide(player)
	elseif action == "shop" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "shop" } })
	elseif action == "travel" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "travel" } })
	elseif action == "chest" and chestKey then
		self:OpenChest(player, chestKey)
	end
end

-- Secret chests: one-time pearl reward per account (world collectibles)
function WorldInteractionsService:OpenChest(player: Player, chestKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if data.flags.chestsClaimed[chestKey] then
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "chestEmpty", text = "This chest is empty — you already claimed it!" },
		})
		return
	end
	data.flags.chestsClaimed[chestKey] = true
	local pearls = chestKey == "abyss" and 15 or 10
	self.ctx.Services.EconomyService:AddPearls(player, pearls, "chest:" .. chestKey)
	Remotes:SendToClient(player, {
		type = "EventBanner",
		payload = { kind = "chest", text = "💎 You found " .. pearls .. " pearls in the chest!" },
	})
end

function WorldInteractionsService:Init(ctx)
	self.ctx = ctx
end

function WorldInteractionsService:Start()
	self:SetupPrompts()
end

function WorldInteractionsService:Stop()
end

return WorldInteractionsService
]==]
	print('[Installer] Wrote ServerScriptService/Services/WorldInteractionsService')
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
local CONTROLLERS = { "AudioController", "GuideController", "CastController", "UIController", "MenuUIController" }

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
local CONTROLLERS = { "AudioController", "GuideController", "CastController", "UIController", "MenuUIController" }

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

print("[Installer] Part 11/15 complete - next: 12")
