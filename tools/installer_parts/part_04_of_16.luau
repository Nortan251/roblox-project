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

-- ServerScriptService/Bootstrap
local inst = ensure('ServerScriptService/Bootstrap', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — Bootstrap (server)
	Service lifecycle manager + message router.
	1. Require all services. 2. Init all. 3. Start all. 4. Route client messages.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local ctx = {
	Services = {},
	MessageHandlers = {},
}

-- Dependency order: security → data → economy → inventory → quests → events → leaderboards → fishing → shop
local ORDER = {
	"SecurityService",
	"DataService",
	"EconomyService",
	"InventoryService",
	"QuestService",
	"EventService",
	"LeaderboardService",
	"WorldInteractionsService",
	"AutoTerrainService",
	"FishingService",
	"TravelService",
	"AmbienceService",
	"ShopService",
}

-- Load
for _, name in pairs(ORDER) do
	local ok, module = pcall(function()
		return require(script.Parent.Services[name])
	end)
	if not ok then
		warn("[Bootstrap] Failed to require " .. name .. ": " .. tostring(module))
		continue
	end
	ctx.Services[name] = module
end

-- Init
for _, name  in pairs(ORDER) do
	local service = ctx.Services[name]
	if service and service.Init then
		service:Init(ctx)
	end
end

-- Start
for _, name  in pairs(ORDER) do
	local service = ctx.Services[name]
	if service and service.Start then
		service:Start()
	end
end

-- ── Message router ───────────────────────────────────────────────────────

Remotes:OnServerMessage(function(player: Player, message: any)
	local security = ctx.Services.SecurityService
	local ok, reason = security:ValidateMessage(message)
	if not ok then
		security:Flag(player, reason or "invalid message")
		return
	end
	if not security:CheckRate(player, message.type) then
		return
	end
	local handler = ctx.MessageHandlers[message.type]
	if not handler then
		return
	end
	local runOk, err = pcall(handler, player, message.payload)
	if not runOk then
		warn("[Bootstrap] Handler error (" .. message.type .. ") for " .. player.Name .. ": " .. tostring(err))
	end
end)

-- Full state snapshot request (client calls after UI init)
ctx.MessageHandlers.GuideDone = function(player: Player)
	local world = ctx.Services.WorldInteractionsService
	if world and world.OnGuideDone then
		world:OnGuideDone(player)
	end
end

ctx.MessageHandlers.SyncRequest = function(player: Player)
	local data = ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	ctx.Services.EconomyService:Sync(player)
	ctx.Services.InventoryService:SendInventory(player)
	ctx.Services.QuestService:SendQuestUpdate(player)
	Remotes:SendToClient(player, { type = "WorldState", payload = ctx.Services.EventService:GetWorldState() })
end

-- Initial snapshot on profile ready (covers players joining after boot)
ctx.Services.DataService:OnProfileReady(function(player: Player, _data: any)
	task.wait(0.2)
	ctx.Services.EconomyService:Sync(player)
	ctx.Services.InventoryService:SendInventory(player)
	ctx.Services.QuestService:SendQuestUpdate(player)
	Remotes:SendToClient(player, { type = "WorldState", payload = ctx.Services.EventService:GetWorldState() })
	local world = ctx.Services.WorldInteractionsService
	if world and world.SendGuide then
		world:SendGuide(player)
	end
end)

-- Graceful shutdown: save everything
game:BindToClose(function()
	for i = #ORDER, 1, -1 do
		local service = ctx.Services[ORDER[i]]
		if service and service.Stop then
			pcall(service.Stop, service)
		end
	end
end)

print("[Tidebound] Server booted. Services: " .. table.concat(ORDER, ", "))

-- ── BOOT BEACON (diagnostic: proves server code runs in the live game) ──
-- 1) Analytics counter -> visible in Creator Dashboard > Analytics
local AnalyticsService = game:GetService("AnalyticsService")
pcall(function()
	AnalyticsService:ReportCounter("TideboundServerBoot", 1)
end)
-- 2) Floating sign above spawn -> visible to every player in-world
task.delay(4, function()
	local beacon = Instance.new("Part")
	beacon.Name = "BootBeacon"
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.CanQuery = false
	beacon.CanTouch = false
	beacon.Size = Vector3.new(1, 1, 1)
	beacon.Transparency = 1
	beacon.CFrame = CFrame.new(0, 14, 66)
	beacon.Parent = Workspace
	local bg = Instance.new("BillboardGui")
	bg.Name = "BeaconGUI"
	bg.Size = UDim2.new(0, 600, 0, 120)
	bg.AlwaysOnTop = true
	bg.Parent = beacon
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = "TIDEBOUND ONLINE — v14\n(server scripts running)"
	lbl.TextColor3 = Color3.fromRGB(90, 220, 170)
	lbl.TextSize = 32
	lbl.Font = Enum.Font.GothamBold
	lbl.TextStrokeTransparency = 0
	lbl.Parent = bg
end)
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — Bootstrap (server)
	Service lifecycle manager + message router.
	1. Require all services. 2. Init all. 3. Start all. 4. Route client messages.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local ctx = {
	Services = {},
	MessageHandlers = {},
}

-- Dependency order: security → data → economy → inventory → quests → events → leaderboards → fishing → shop
local ORDER = {
	"SecurityService",
	"DataService",
	"EconomyService",
	"InventoryService",
	"QuestService",
	"EventService",
	"LeaderboardService",
	"WorldInteractionsService",
	"AutoTerrainService",
	"FishingService",
	"TravelService",
	"AmbienceService",
	"ShopService",
}

-- Load
for _, name in pairs(ORDER) do
	local ok, module = pcall(function()
		return require(script.Parent.Services[name])
	end)
	if not ok then
		warn("[Bootstrap] Failed to require " .. name .. ": " .. tostring(module))
		continue
	end
	ctx.Services[name] = module
end

-- Init
for _, name  in pairs(ORDER) do
	local service = ctx.Services[name]
	if service and service.Init then
		service:Init(ctx)
	end
end

-- Start
for _, name  in pairs(ORDER) do
	local service = ctx.Services[name]
	if service and service.Start then
		service:Start()
	end
end

-- ── Message router ───────────────────────────────────────────────────────

Remotes:OnServerMessage(function(player: Player, message: any)
	local security = ctx.Services.SecurityService
	local ok, reason = security:ValidateMessage(message)
	if not ok then
		security:Flag(player, reason or "invalid message")
		return
	end
	if not security:CheckRate(player, message.type) then
		return
	end
	local handler = ctx.MessageHandlers[message.type]
	if not handler then
		return
	end
	local runOk, err = pcall(handler, player, message.payload)
	if not runOk then
		warn("[Bootstrap] Handler error (" .. message.type .. ") for " .. player.Name .. ": " .. tostring(err))
	end
end)

-- Full state snapshot request (client calls after UI init)
ctx.MessageHandlers.GuideDone = function(player: Player)
	local world = ctx.Services.WorldInteractionsService
	if world and world.OnGuideDone then
		world:OnGuideDone(player)
	end
end

ctx.MessageHandlers.SyncRequest = function(player: Player)
	local data = ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	ctx.Services.EconomyService:Sync(player)
	ctx.Services.InventoryService:SendInventory(player)
	ctx.Services.QuestService:SendQuestUpdate(player)
	Remotes:SendToClient(player, { type = "WorldState", payload = ctx.Services.EventService:GetWorldState() })
end

-- Initial snapshot on profile ready (covers players joining after boot)
ctx.Services.DataService:OnProfileReady(function(player: Player, _data: any)
	task.wait(0.2)
	ctx.Services.EconomyService:Sync(player)
	ctx.Services.InventoryService:SendInventory(player)
	ctx.Services.QuestService:SendQuestUpdate(player)
	Remotes:SendToClient(player, { type = "WorldState", payload = ctx.Services.EventService:GetWorldState() })
	local world = ctx.Services.WorldInteractionsService
	if world and world.SendGuide then
		world:SendGuide(player)
	end
end)

-- Graceful shutdown: save everything
game:BindToClose(function()
	for i = #ORDER, 1, -1 do
		local service = ctx.Services[ORDER[i]]
		if service and service.Stop then
			pcall(service.Stop, service)
		end
	end
end)

print("[Tidebound] Server booted. Services: " .. table.concat(ORDER, ", "))

-- ── BOOT BEACON (diagnostic: proves server code runs in the live game) ──
-- 1) Analytics counter -> visible in Creator Dashboard > Analytics
local AnalyticsService = game:GetService("AnalyticsService")
pcall(function()
	AnalyticsService:ReportCounter("TideboundServerBoot", 1)
end)
-- 2) Floating sign above spawn -> visible to every player in-world
task.delay(4, function()
	local beacon = Instance.new("Part")
	beacon.Name = "BootBeacon"
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.CanQuery = false
	beacon.CanTouch = false
	beacon.Size = Vector3.new(1, 1, 1)
	beacon.Transparency = 1
	beacon.CFrame = CFrame.new(0, 14, 66)
	beacon.Parent = Workspace
	local bg = Instance.new("BillboardGui")
	bg.Name = "BeaconGUI"
	bg.Size = UDim2.new(0, 600, 0, 120)
	bg.AlwaysOnTop = true
	bg.Parent = beacon
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = "TIDEBOUND ONLINE — v14\n(server scripts running)"
	lbl.TextColor3 = Color3.fromRGB(90, 220, 170)
	lbl.TextSize = 32
	lbl.Font = Enum.Font.GothamBold
	lbl.TextStrokeTransparency = 0
	lbl.Parent = bg
end)
]==]
	print('[Installer] Wrote ServerScriptService/Bootstrap')
end

-- ServerScriptService/Services/SecurityService
local inst = ensure('ServerScriptService/Services/SecurityService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — SecurityService
	Defense layer 1-3: message validation, rate limiting, kick policy.
	The server NEVER trusts client payloads; every message passes through here.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local SecurityService = {}
SecurityService.Name = "SecurityService"

local WINDOW = 10 -- seconds
type Bucket = { count: number, windowStart: number, violations: number }
local buckets: { [number]: { [string]: Bucket } } = {}

-- Valid message types (unknown types are rejected outright)
local VALID_TYPES: { [string]: boolean } = {
	Cast = true,
	ReelHold = true,
	AutoReel = true,
	SellFish = true,
	SellAll = true,
	SetAutoSell = true,
	BuyRod = true,
	BuyBait = true,
	BuyUpgrade = true,
	EquipRod = true,
	EquipBait = true,
	ClaimDaily = true,
	ClaimWeekly = true,
	RerollQuest = true,
	FastTravel = true,
	GuideDone = true,
	BuyCosmetic = true,
	EquipCosmetic = true,
	EquipTitle = true,
	GetContestTop = true,
	SyncRequest = true,
}

-- Validate the envelope; returns (ok, reason)
function SecurityService:ValidateMessage(message: any): (boolean, string?)
	if typeof(message) ~= "table" then
		return false, "malformed message"
	end
	local msgType = message.type
	if typeof(msgType) ~= "string" or not VALID_TYPES[msgType] then
		return false, "unknown type: " .. tostring(msgType)
	end
	local payload = message.payload
	if payload ~= nil and typeof(payload) ~= "table" and typeof(payload) ~= "Vector3" and typeof(payload) ~= "boolean" then
		return false, "bad payload"
	end
	return true
end

-- Token-bucket rate limit per player per message type.
-- Returns true if the message may proceed.
function SecurityService:CheckRate(player: Player, msgType: string): boolean
	local limit = Config.RATE_LIMITS[msgType]
	if not limit or limit <= 0 then
		return false
	end
	local now = os.clock()
	local playerBuckets = buckets[player.UserId]
	if not playerBuckets then
		playerBuckets = {}
		buckets[player.UserId] = playerBuckets
	end
	local bucket = playerBuckets[msgType]
	if not bucket or (now - bucket.windowStart) >= WINDOW then
		playerBuckets[msgType] = { count = 1, windowStart = now, violations = 0 }
		return true
	end
	bucket.count += 1
	if bucket.count > limit then
		bucket.violations += 1
		if bucket.violations >= 3 then
			warn("[Security] Kicking " .. player.Name .. " (rate abuse: " .. msgType .. ")")
			player:Kick("Too many requests. Please play fair!")
			buckets[player.UserId] = nil
		end
		return false
	end
	return true
end

-- Soft violation: warn and ignore (used for impossible values)
function SecurityService:Flag(player: Player, reason: string)
	warn("[Security] Flag: " .. player.Name .. " | " .. reason)
end

function SecurityService:Init(ctx)
	self.ctx = ctx
end

function SecurityService:Start()
	-- Clean up buckets on leave
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		buckets[player.UserId] = nil
	end)
end

function SecurityService:Stop()
end

return SecurityService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — SecurityService
	Defense layer 1-3: message validation, rate limiting, kick policy.
	The server NEVER trusts client payloads; every message passes through here.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local SecurityService = {}
SecurityService.Name = "SecurityService"

local WINDOW = 10 -- seconds
type Bucket = { count: number, windowStart: number, violations: number }
local buckets: { [number]: { [string]: Bucket } } = {}

-- Valid message types (unknown types are rejected outright)
local VALID_TYPES: { [string]: boolean } = {
	Cast = true,
	ReelHold = true,
	AutoReel = true,
	SellFish = true,
	SellAll = true,
	SetAutoSell = true,
	BuyRod = true,
	BuyBait = true,
	BuyUpgrade = true,
	EquipRod = true,
	EquipBait = true,
	ClaimDaily = true,
	ClaimWeekly = true,
	RerollQuest = true,
	FastTravel = true,
	GuideDone = true,
	BuyCosmetic = true,
	EquipCosmetic = true,
	EquipTitle = true,
	GetContestTop = true,
	SyncRequest = true,
}

-- Validate the envelope; returns (ok, reason)
function SecurityService:ValidateMessage(message: any): (boolean, string?)
	if typeof(message) ~= "table" then
		return false, "malformed message"
	end
	local msgType = message.type
	if typeof(msgType) ~= "string" or not VALID_TYPES[msgType] then
		return false, "unknown type: " .. tostring(msgType)
	end
	local payload = message.payload
	if payload ~= nil and typeof(payload) ~= "table" and typeof(payload) ~= "Vector3" and typeof(payload) ~= "boolean" then
		return false, "bad payload"
	end
	return true
end

-- Token-bucket rate limit per player per message type.
-- Returns true if the message may proceed.
function SecurityService:CheckRate(player: Player, msgType: string): boolean
	local limit = Config.RATE_LIMITS[msgType]
	if not limit or limit <= 0 then
		return false
	end
	local now = os.clock()
	local playerBuckets = buckets[player.UserId]
	if not playerBuckets then
		playerBuckets = {}
		buckets[player.UserId] = playerBuckets
	end
	local bucket = playerBuckets[msgType]
	if not bucket or (now - bucket.windowStart) >= WINDOW then
		playerBuckets[msgType] = { count = 1, windowStart = now, violations = 0 }
		return true
	end
	bucket.count += 1
	if bucket.count > limit then
		bucket.violations += 1
		if bucket.violations >= 3 then
			warn("[Security] Kicking " .. player.Name .. " (rate abuse: " .. msgType .. ")")
			player:Kick("Too many requests. Please play fair!")
			buckets[player.UserId] = nil
		end
		return false
	end
	return true
end

-- Soft violation: warn and ignore (used for impossible values)
function SecurityService:Flag(player: Player, reason: string)
	warn("[Security] Flag: " .. player.Name .. " | " .. reason)
end

function SecurityService:Init(ctx)
	self.ctx = ctx
end

function SecurityService:Start()
	-- Clean up buckets on leave
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		buckets[player.UserId] = nil
	end)
end

function SecurityService:Stop()
end

return SecurityService
]==]
	print('[Installer] Wrote ServerScriptService/Services/SecurityService')
end

print("[Installer] Part 4/16 complete - next: 5")
