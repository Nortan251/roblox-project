--!strict
--[[
	Tidebound — EventService
	Shared world clock: day/night cycle + storm scheduler.
	Single source of truth for time-of-day and storm state on this server.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Workspace = game:GetService("Workspace")

local EventService = {}
EventService.Name = "EventService"

local timeOfDay: "day" | "night" = "day"
local isStorm = false
local nextStormAt = 0
local stormEndsAt = 0
local stormWarningSent = false

-- Golden spot state
local goldenActive = false
local goldenX = 0
local goldenZ = 0
local goldenZoneId = ""
local goldenExpiresAt = 0
local nextGoldenAt = 0
local goldenPart: BasePart? = nil

local CYCLE_LENGTH = Config.DAY_LENGTH + Config.NIGHT_LENGTH

function EventService:GetTimeOfDay(): "day" | "night"
	return timeOfDay
end

function EventService:IsStorm(): boolean
	return isStorm
end

function EventService:GetWorldState(): { timeOfDay: string, isStorm: boolean, stormIn: number }
	return {
		timeOfDay = timeOfDay,
		isStorm = isStorm,
		stormIn = math.max(0, nextStormAt - os.clock()),
	}
end

-- ── Golden spots ─────────────────────────────────────────────────────────

function EventService:IsGoldenAt(position: Vector3): boolean
	if not goldenActive then
		return false
	end
	local dx = position.X - goldenX
	local dz = position.Z - goldenZ
	return (dx * dx + dz * dz) <= (Config.GOLDEN_SPOT_RADIUS * Config.GOLDEN_SPOT_RADIUS)
end

function EventService:GetGoldenSpot(): { active: boolean, x: number, z: number, zoneId: string }
	return { active = goldenActive, x = goldenX, z = goldenZ, zoneId = goldenZoneId }
end

function EventService:SpawnGoldenSpot()
	-- Pick a random zone with a region part
	local zones = {}
	for _, child in pairs(Workspace:GetChildren()) do
		if child:IsA("BasePart") and string.sub(child.Name, 1, 11) == "ZoneRegion_" then
			table.insert(zones, child)
		end
	end
	if #zones == 0 then
		nextGoldenAt = os.clock() + Config.GOLDEN_SPOT_INTERVAL_MAX
		return
	end
	local region = zones[math.random(1, #zones)] :: BasePart
	local center = region.CFrame.Position
	local jx = math.random(-80, 80)
	local jz = math.random(-80, 80)
	goldenX = center.X + jx
	goldenZ = center.Z + jz
	goldenZoneId = string.sub(region.Name, 12)
	goldenActive = true
	goldenExpiresAt = os.clock() + Config.GOLDEN_SPOT_DURATION

	-- Visual: shimmering disc
	local disc = Instance.new("Part")
	disc.Name = "GoldenSpot"
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanQuery = false
	disc.CanTouch = false
	disc.Size = Vector3.new(14, 0.3, 14)
	disc.Material = Enum.Material.Neon
	disc.Color = Color3.fromRGB(255, 215, 80)
	disc.Transparency = 0.3
	disc.CFrame = CFrame.new(goldenX, 0.2, goldenZ)
	disc.Parent = Workspace
	local mesh = Instance.new("CylinderMesh")
	mesh.Parent = disc
	local gl = Instance.new("PointLight")
	gl.Color = Color3.fromRGB(255, 220, 110)
	gl.Brightness = 1.4
	gl.Range = 34
	gl.Parent = disc
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Rate = 22
	pe.Lifetime = NumberRange.new(0.8, 1.6)
	pe.Speed = NumberRange.new(0.5, 2)
	pe.Size = NumberSequence.new(0.15, 0.45)
	pe.Transparency = NumberSequence.new(0.1, 1)
	pe.Color = ColorSequence.new(Color3.fromRGB(255, 230, 140))
	pe.Parent = disc
	goldenPart = disc

	Remotes:SendToAll({
		type = "GoldenSpot",
		payload = self:GetGoldenSpot(),
	})
	Remotes:SendToAll({
		type = "EventBanner",
		payload = { kind = "golden", text = "✨ A golden shimmer appears in " .. goldenZoneId .. "! Cast there for luck!" },
	})
end

function EventService:ClearGoldenSpot()
	goldenActive = false
	if goldenPart then
		goldenPart:Destroy()
		goldenPart = nil
	end
	Remotes:SendToAll({
		type = "GoldenSpot",
		payload = self:GetGoldenSpot(),
	})
end

function EventService:BroadcastWorldState()
	Remotes:SendToAll({ type = "WorldState", payload = self:GetWorldState() })
end

function EventService:Init(ctx)
	self.ctx = ctx
end

function EventService:Start()
	local cycleStart = os.clock()
	local lastPhase = "day"
	nextStormAt = os.clock() + math.random(Config.STORM_MIN_DELAY, Config.STORM_MAX_DELAY)
	nextGoldenAt = os.clock() + math.random(Config.GOLDEN_SPOT_INTERVAL_MIN, Config.GOLDEN_SPOT_INTERVAL_MAX)

	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.clock()

			-- Golden spots
			if goldenActive then
				if now >= goldenExpiresAt then
					self:ClearGoldenSpot()
				end
			elseif now >= nextGoldenAt then
				self:SpawnGoldenSpot()
			end

			-- Day / night
			local phase: "day" | "night" = "day"
			if (now - cycleStart) % CYCLE_LENGTH >= Config.DAY_LENGTH then
				phase = "night"
			end
			if phase ~= lastPhase then
				lastPhase = phase
				timeOfDay = phase
				if phase == "night" then
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "night", text = "The sun sets. Night fish are surfacing..." },
					})
				else
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "day", text = "Dawn breaks over the water." },
					})
				end
				self:BroadcastWorldState()
			end

			-- Storm scheduling
			if not isStorm then
				if not stormWarningSent and now >= nextStormAt - Config.STORM_WARNING then
					stormWarningSent = true
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "stormWarning", text = "A storm is brewing... strange fish are coming." },
					})
				end
				if now >= nextStormAt then
					isStorm = true
					stormEndsAt = now + Config.STORM_DURATION
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "storm", text = "THE STORM HAS ARRIVED! Storm fish are surfacing everywhere. +50% XP!" },
					})
					self:BroadcastWorldState()
				end
			else
				if now >= stormEndsAt then
					isStorm = false
					stormWarningSent = false
					nextStormAt = now + math.random(Config.STORM_MIN_DELAY, Config.STORM_MAX_DELAY)
					Remotes:SendToAll({
						type = "EventBanner",
						payload = { kind = "stormEnd", text = "The storm passes. The sea returns to its secrets." },
					})
					self:BroadcastWorldState()
				end
			end
		end
	end)
end

function EventService:Stop()
end

return EventService
