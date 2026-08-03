--!strict
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
