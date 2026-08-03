--!strict
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
