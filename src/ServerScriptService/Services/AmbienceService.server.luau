--!strict
--[[
	Tidebound — AmbienceService
	Cheap "living world" on the server (no client involvement):
	- gently bobs every BuoyBall_* part
	- spawns and orbits seagulls over each zone
	All parts are anchored; updates are low-frequency. Zero physics cost.
	Phase 5 | AI-assisted | 2026-08-03
]]

local Workspace = game:GetService("Workspace")

local AmbienceService = {}
AmbienceService.Name = "AmbienceService"

local ZONES = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }

local buoys: { BasePart } = {}
local gulls: { { part: BasePart, center: Vector3, speed: number, radius: number, height: number, offset: number } } = {}

local function makeGull(name: string, parent: Instance): BasePart
	local gull = Instance.new("Part")
	gull.Name = name
	gull.Anchored = true
	gull.CanCollide = false
	gull.CanQuery = false
	gull.CanTouch = false
	gull.Size = Vector3.new(1.8, 0.35, 2.4)
	gull.Material = Enum.Material.SmoothPlastic
	gull.Color = Color3.fromRGB(240, 240, 246)
	gull.Shape = Enum.PartType.Block
	gull.Parent = parent
	-- wing accent (dark tip)
	local wing = Instance.new("WedgePart")
	wing.Name = "Wing"
	wing.Anchored = true
	wing.CanCollide = false
	wing.CanQuery = false
	wing.Size = Vector3.new(1.6, 0.12, 1.1)
	wing.Material = Enum.Material.SmoothPlastic
	wing.Color = Color3.fromRGB(80, 84, 92)
	wing.CFrame = CFrame.new(0, 0.1, -0.4) * CFrame.Angles(0, 0, 0.5)
	wing.Parent = gull
	return gull
end

function AmbienceService:Start()
	task.spawn(function()
		task.wait(3) -- let the world settle

		-- Collect buoys
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("BasePart") and string.sub(child.Name, 1, 9) == "BuoyBall_" then
				table.insert(buoys, child)
			end
		end

		-- Spawn gulls per zone
		for _, zid in ipairs(ZONES) do
			local region = Workspace:FindFirstChild("ZoneRegion_" .. zid) :: BasePart?
			if region then
				local center = region:GetPivot().Position
				for i = 1, 2 do
					local gull = makeGull("Gull_" .. zid .. "_" .. i, Workspace)
					table.insert(gulls, {
						part = gull,
						center = center,
						speed = 0.14 + i * 0.05,
						radius = 34 + i * 10,
						height = 24 + i * 5,
						offset = i * 2.1,
					})
				end
			end
		end

		-- Living loop
		local t = 0
		while true do
			task.wait(0.5)
			t += 0.5
			for _, b in buoys do
				local pos = b:GetPivot().Position
				b:PivotTo(CFrame.new(pos.X, pos.Y + math.sin(t * 1.7 + pos.X * 0.05) * 0.35, pos.Z))
			end
			for _, g in gulls do
				local a = t * g.speed + g.offset
				local pos = g.center + Vector3.new(math.cos(a) * g.radius, g.height + math.sin(a * 0.6) * 2.5, math.sin(a) * g.radius)
				local look = CFrame.lookAt(pos, g.center + Vector3.new(0, g.height - 2, 0))
				g.part:PivotTo(look)
			end
		end
	end)
end

function AmbienceService:Init(ctx)
	self.ctx = ctx
end

function AmbienceService:Stop()
end

return AmbienceService
