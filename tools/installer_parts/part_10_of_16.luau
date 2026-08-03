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

-- ServerScriptService/Services/AmbienceService
local inst = ensure('ServerScriptService/Services/AmbienceService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — AmbienceService
	Cheap "living world" on the server (no client involvement):
	- bobs every BuoyBall_* part
	- spawns and orbits seagulls over each zone
	- ANIMATED NPCs: Old Salt casts his rod; two villagers walk the village
	- FISH SCHOOLS: fish that visibly swim in every zone + near the dock
	All parts are anchored; updates are low-frequency. Zero physics cost.
	Phase 5 | AI-assisted | 2026-08-03
]]

local Workspace = game:GetService("Workspace")

local AmbienceService = {}
AmbienceService.Name = "AmbienceService"

local ZONES = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }

local buoys: { BasePart } = {}
local gulls: { { part: BasePart, center: Vector3, speed: number, radius: number, height: number, offset: number } } = {}
local npcs: { { parts: { BasePart }, path: { Vector3 }, speed: number, phase: number } } = {}
local fishSchools: { { parts: { BasePart }, center: Vector3, radius: number, speed: number, phase: number, depth: number, color: Color3 } } = {}

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

-- Build a simple fish model (smooth body + tail fin)
local function makeFish(name: string, parent: Instance, color: Color3): BasePart
	local body = Instance.new("Part")
	body.Name = name
	body.Anchored = true
	body.CanCollide = false
	body.CanQuery = false
	body.CanTouch = false
	body.Size = Vector3.new(1.6, 0.7, 0.5)
	body.Material = Enum.Material.SmoothPlastic
	body.Color = color
	body.Parent = parent
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = body
	local tail = Instance.new("WedgePart")
	tail.Name = "Tail"
	tail.Anchored = true
	tail.CanCollide = false
	tail.CanQuery = false
	tail.Size = Vector3.new(0.7, 0.5, 0.12)
	tail.Material = Enum.Material.SmoothPlastic
	tail.Color = color:Lerp(Color3.new(0.4, 0.4, 0.4), 0.3)
	tail.CFrame = CFrame.new(-1.1, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	tail.Parent = body
	return body
end

-- Build a simple cloaked villager NPC (no legs needed — cloak covers)
local function makeVillager(name: string, parent: Instance, robeColor: Color3): { BasePart }
	local cloak = Instance.new("Part")
	cloak.Name = name .. "_Cloak"
	cloak.Anchored = true
	cloak.CanCollide = false
	cloak.CanQuery = false
	cloak.Size = Vector3.new(1.6, 3.2, 1.2)
	cloak.Material = Enum.Material.SmoothPlastic
	cloak.Color = robeColor
	cloak.Shape = Enum.PartType.Cylinder
	cloak.Parent = parent
	local head = Instance.new("Part")
	head.Name = name .. "_Head"
	head.Anchored = true
	head.CanCollide = false
	head.CanQuery = false
	head.Size = Vector3.new(1.1, 1.1, 1.1)
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(255, 220, 190)
	head.Shape = Enum.PartType.Ball
	head.Parent = parent
	local hat = Instance.new("Part")
	hat.Name = name .. "_Hat"
	hat.Anchored = true
	hat.CanCollide = false
	hat.CanQuery = false
	hat.Size = Vector3.new(1.4, 0.5, 1.4)
	hat.Material = Enum.Material.SmoothPlastic
	hat.Color = Color3.fromRGB(70, 70, 78)
	hat.Shape = Enum.PartType.Cylinder
	hat.Parent = parent
	-- left/right arms (swing while walking)
	local armL = Instance.new("Part")
	armL.Name = name .. "_ArmL"
	armL.Anchored = true
	armL.CanCollide = false
	armL.CanQuery = false
	armL.Size = Vector3.new(0.5, 1.6, 0.5)
	armL.Material = Enum.Material.SmoothPlastic
	armL.Color = robeColor
	armL.Parent = parent
	local armR = Instance.new("Part")
	armR.Name = name .. "_ArmR"
	armR.Anchored = true
	armR.CanCollide = false
	armR.CanQuery = false
	armR.Size = Vector3.new(0.5, 1.6, 0.5)
	armR.Material = Enum.Material.SmoothPlastic
	armR.Color = robeColor
	armR.Parent = parent
	return { cloak, head, hat, armL, armR }
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

		-- Gulls per zone
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

		-- Fish schools (every zone + dock)
		local fishColors = {
			{ 90, 190, 220 }, { 230, 160, 90 }, { 160, 220, 140 }, { 220, 130, 170 },
			{ 150, 160, 220 }, { 240, 210, 110 }, { 120, 200, 180 }, { 200, 150, 220 },
		}
		local spots = { { 0, 30, "Dock" } }
		for _, zid in ipairs(ZONES) do
			local region = Workspace:FindFirstChild("ZoneRegion_" .. zid) :: BasePart?
			if region then
				local center = region:GetPivot().Position
				table.insert(spots, { center.X, center.Z, zid })
			end
		end
		for si, spot in ipairs(spots) do
			local school = { parts = {}, center = Vector3.new(spot[1], -1.6, spot[2]), radius = 26 + (si % 3) * 8, speed = 0.35 + (si % 4) * 0.12, phase = si * 1.7, depth = -1.6, color = Color3.fromRGB(fishColors[(si - 1) % 8 + 1][1], fishColors[(si - 1) % 8 + 1][2], fishColors[(si - 1) % 8 + 1][3]) }
			for f = 1, 8 do
				local fish = makeFish("Fish_" .. spot[3] .. "_" .. f, Workspace, school.color)
				fish.CFrame = CFrame.new(school.center.X, school.center.Y, school.center.Z)
				table.insert(school.parts, fish)
			end
			table.insert(fishSchools, school)
		end

		-- Animated NPCs
		-- Old Salt: casting loop (rod swings + slight bob)
		local saltBody = Workspace:FindFirstChild("OldSaltBody") :: BasePart?
		local saltRod = Workspace:FindFirstChild("OldSaltRod") :: BasePart?
		if saltBody then
			table.insert(npcs, { parts = { saltBody, saltRod or saltBody }, path = {}, speed = 0, phase = 0 })
		end

		-- Villagers walking the village path
		local villagerPaths = {
			{ Vector3.new(0, 1.2, 55), Vector3.new(-20, 1.2, 72), Vector3.new(-45, 1.4, 100), Vector3.new(-45, 1.6, 140) },
			{ Vector3.new(12, 1.2, 84), Vector3.new(42, 1.4, 118), Vector3.new(42, 1.6, 133) },
		}
		local robeColors = { Color3.fromRGB(70, 110, 160), Color3.fromRGB(150, 90, 60) }
		for i, path in ipairs(villagerPaths) do
			local parts = makeVillager("Villager" .. i, Workspace, robeColors[i])
			table.insert(npcs, { parts = parts, path = path, speed = 2.2 + i * 0.4, phase = i * 3.1 })
		end

		-- Living loop
		local t = 0
		while true do
			task.wait(0.25)
			t += 0.25

			-- Buoys bob
			for _, b in pairs(buoys) do
				local pos = b:GetPivot().Position
				b:PivotTo(CFrame.new(pos.X, pos.Y + math.sin(t * 1.7 + pos.X * 0.05) * 0.35, pos.Z))
			end

			-- Gulls orbit
			for _, g in pairs(gulls) do
				local a = t * g.speed + g.offset
				local pos = g.center + Vector3.new(math.cos(a) * g.radius, g.height + math.sin(a * 0.6) * 2.5, math.sin(a) * g.radius)
				g.part:PivotTo(CFrame.lookAt(pos, g.center + Vector3.new(0, g.height - 2, 0)))
			end

			-- Old Salt casts
			if #npcs > 0 and npcs[1].parts[2] then
				local rod = npcs[1].parts[2]
				local swing = math.sin(t * 2.4) * 0.9
				local base = CFrame.new(-18.4, 1.2, 70.8)
				rod:PivotTo(base * CFrame.Angles(0, 0, 0.6 + swing * 0.5))
				npcs[1].parts[1]:PivotTo(CFrame.new(-20, 0.05 + math.sin(t * 2.4) * 0.06, 70))
			end

			-- Villagers walk
			for i = 2, #npcs do
				local n = npcs[i]
				local path = n.path
				if #path > 1 then
					local tt = (t * n.speed * 0.05 + n.phase) % 1
					local seg = tt * (#path - 1)
					local idx = math.floor(seg) + 1
					local frac = seg - math.floor(seg)
					local a = path[math.min(idx, #path)]
					local b = path[math.min(idx + 1, #path)]
					local pos = a:Lerp(b, frac)
					local look = (b - a).Unit
					local bob = math.abs(math.sin(seg * 6)) * 0.15
					for pi, part in ipairs(n.parts) do
						local off = Vector3.new(0, 1.2 + bob, 0)
						if pi == 2 then
							off = Vector3.new(0, 2.3 + bob, 0)
						elseif pi == 3 then
							off = Vector3.new(0, 2.75 + bob, 0)
						elseif pi == 4 then
							off = Vector3.new(-0.6, 1.7 + bob + math.sin(seg * 7) * 0.3, 0)
						elseif pi == 5 then
							off = Vector3.new(0.6, 1.7 + bob + math.sin(seg * 7 + 3.14) * 0.3, 0)
						end
						part:PivotTo(CFrame.lookAt(pos + off, pos + off + look))
					end
				end
			end

			-- Fish swim in circles
			for _, school in pairs(fishSchools) do
				for fi, fish in ipairs(school.parts) do
					local a = t * school.speed + school.phase + fi * 0.35
					local pos = school.center + Vector3.new(
						math.cos(a) * school.radius,
						math.sin(a * 1.3 + fi) * 0.6,
						math.sin(a) * school.radius
					)
					local nextA = a + 0.1
					local nextPos = school.center + Vector3.new(
						math.cos(nextA) * school.radius,
						math.sin(nextA * 1.3 + fi) * 0.6,
						math.sin(nextA) * school.radius
					)
					fish:PivotTo(CFrame.lookAt(pos, nextPos))
				end
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
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — AmbienceService
	Cheap "living world" on the server (no client involvement):
	- bobs every BuoyBall_* part
	- spawns and orbits seagulls over each zone
	- ANIMATED NPCs: Old Salt casts his rod; two villagers walk the village
	- FISH SCHOOLS: fish that visibly swim in every zone + near the dock
	All parts are anchored; updates are low-frequency. Zero physics cost.
	Phase 5 | AI-assisted | 2026-08-03
]]

local Workspace = game:GetService("Workspace")

local AmbienceService = {}
AmbienceService.Name = "AmbienceService"

local ZONES = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }

local buoys: { BasePart } = {}
local gulls: { { part: BasePart, center: Vector3, speed: number, radius: number, height: number, offset: number } } = {}
local npcs: { { parts: { BasePart }, path: { Vector3 }, speed: number, phase: number } } = {}
local fishSchools: { { parts: { BasePart }, center: Vector3, radius: number, speed: number, phase: number, depth: number, color: Color3 } } = {}

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

-- Build a simple fish model (smooth body + tail fin)
local function makeFish(name: string, parent: Instance, color: Color3): BasePart
	local body = Instance.new("Part")
	body.Name = name
	body.Anchored = true
	body.CanCollide = false
	body.CanQuery = false
	body.CanTouch = false
	body.Size = Vector3.new(1.6, 0.7, 0.5)
	body.Material = Enum.Material.SmoothPlastic
	body.Color = color
	body.Parent = parent
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = body
	local tail = Instance.new("WedgePart")
	tail.Name = "Tail"
	tail.Anchored = true
	tail.CanCollide = false
	tail.CanQuery = false
	tail.Size = Vector3.new(0.7, 0.5, 0.12)
	tail.Material = Enum.Material.SmoothPlastic
	tail.Color = color:Lerp(Color3.new(0.4, 0.4, 0.4), 0.3)
	tail.CFrame = CFrame.new(-1.1, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	tail.Parent = body
	return body
end

-- Build a simple cloaked villager NPC (no legs needed — cloak covers)
local function makeVillager(name: string, parent: Instance, robeColor: Color3): { BasePart }
	local cloak = Instance.new("Part")
	cloak.Name = name .. "_Cloak"
	cloak.Anchored = true
	cloak.CanCollide = false
	cloak.CanQuery = false
	cloak.Size = Vector3.new(1.6, 3.2, 1.2)
	cloak.Material = Enum.Material.SmoothPlastic
	cloak.Color = robeColor
	cloak.Shape = Enum.PartType.Cylinder
	cloak.Parent = parent
	local head = Instance.new("Part")
	head.Name = name .. "_Head"
	head.Anchored = true
	head.CanCollide = false
	head.CanQuery = false
	head.Size = Vector3.new(1.1, 1.1, 1.1)
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(255, 220, 190)
	head.Shape = Enum.PartType.Ball
	head.Parent = parent
	local hat = Instance.new("Part")
	hat.Name = name .. "_Hat"
	hat.Anchored = true
	hat.CanCollide = false
	hat.CanQuery = false
	hat.Size = Vector3.new(1.4, 0.5, 1.4)
	hat.Material = Enum.Material.SmoothPlastic
	hat.Color = Color3.fromRGB(70, 70, 78)
	hat.Shape = Enum.PartType.Cylinder
	hat.Parent = parent
	-- left/right arms (swing while walking)
	local armL = Instance.new("Part")
	armL.Name = name .. "_ArmL"
	armL.Anchored = true
	armL.CanCollide = false
	armL.CanQuery = false
	armL.Size = Vector3.new(0.5, 1.6, 0.5)
	armL.Material = Enum.Material.SmoothPlastic
	armL.Color = robeColor
	armL.Parent = parent
	local armR = Instance.new("Part")
	armR.Name = name .. "_ArmR"
	armR.Anchored = true
	armR.CanCollide = false
	armR.CanQuery = false
	armR.Size = Vector3.new(0.5, 1.6, 0.5)
	armR.Material = Enum.Material.SmoothPlastic
	armR.Color = robeColor
	armR.Parent = parent
	return { cloak, head, hat, armL, armR }
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

		-- Gulls per zone
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

		-- Fish schools (every zone + dock)
		local fishColors = {
			{ 90, 190, 220 }, { 230, 160, 90 }, { 160, 220, 140 }, { 220, 130, 170 },
			{ 150, 160, 220 }, { 240, 210, 110 }, { 120, 200, 180 }, { 200, 150, 220 },
		}
		local spots = { { 0, 30, "Dock" } }
		for _, zid in ipairs(ZONES) do
			local region = Workspace:FindFirstChild("ZoneRegion_" .. zid) :: BasePart?
			if region then
				local center = region:GetPivot().Position
				table.insert(spots, { center.X, center.Z, zid })
			end
		end
		for si, spot in ipairs(spots) do
			local school = { parts = {}, center = Vector3.new(spot[1], -1.6, spot[2]), radius = 26 + (si % 3) * 8, speed = 0.35 + (si % 4) * 0.12, phase = si * 1.7, depth = -1.6, color = Color3.fromRGB(fishColors[(si - 1) % 8 + 1][1], fishColors[(si - 1) % 8 + 1][2], fishColors[(si - 1) % 8 + 1][3]) }
			for f = 1, 8 do
				local fish = makeFish("Fish_" .. spot[3] .. "_" .. f, Workspace, school.color)
				fish.CFrame = CFrame.new(school.center.X, school.center.Y, school.center.Z)
				table.insert(school.parts, fish)
			end
			table.insert(fishSchools, school)
		end

		-- Animated NPCs
		-- Old Salt: casting loop (rod swings + slight bob)
		local saltBody = Workspace:FindFirstChild("OldSaltBody") :: BasePart?
		local saltRod = Workspace:FindFirstChild("OldSaltRod") :: BasePart?
		if saltBody then
			table.insert(npcs, { parts = { saltBody, saltRod or saltBody }, path = {}, speed = 0, phase = 0 })
		end

		-- Villagers walking the village path
		local villagerPaths = {
			{ Vector3.new(0, 1.2, 55), Vector3.new(-20, 1.2, 72), Vector3.new(-45, 1.4, 100), Vector3.new(-45, 1.6, 140) },
			{ Vector3.new(12, 1.2, 84), Vector3.new(42, 1.4, 118), Vector3.new(42, 1.6, 133) },
		}
		local robeColors = { Color3.fromRGB(70, 110, 160), Color3.fromRGB(150, 90, 60) }
		for i, path in ipairs(villagerPaths) do
			local parts = makeVillager("Villager" .. i, Workspace, robeColors[i])
			table.insert(npcs, { parts = parts, path = path, speed = 2.2 + i * 0.4, phase = i * 3.1 })
		end

		-- Living loop
		local t = 0
		while true do
			task.wait(0.25)
			t += 0.25

			-- Buoys bob
			for _, b in pairs(buoys) do
				local pos = b:GetPivot().Position
				b:PivotTo(CFrame.new(pos.X, pos.Y + math.sin(t * 1.7 + pos.X * 0.05) * 0.35, pos.Z))
			end

			-- Gulls orbit
			for _, g in pairs(gulls) do
				local a = t * g.speed + g.offset
				local pos = g.center + Vector3.new(math.cos(a) * g.radius, g.height + math.sin(a * 0.6) * 2.5, math.sin(a) * g.radius)
				g.part:PivotTo(CFrame.lookAt(pos, g.center + Vector3.new(0, g.height - 2, 0)))
			end

			-- Old Salt casts
			if #npcs > 0 and npcs[1].parts[2] then
				local rod = npcs[1].parts[2]
				local swing = math.sin(t * 2.4) * 0.9
				local base = CFrame.new(-18.4, 1.2, 70.8)
				rod:PivotTo(base * CFrame.Angles(0, 0, 0.6 + swing * 0.5))
				npcs[1].parts[1]:PivotTo(CFrame.new(-20, 0.05 + math.sin(t * 2.4) * 0.06, 70))
			end

			-- Villagers walk
			for i = 2, #npcs do
				local n = npcs[i]
				local path = n.path
				if #path > 1 then
					local tt = (t * n.speed * 0.05 + n.phase) % 1
					local seg = tt * (#path - 1)
					local idx = math.floor(seg) + 1
					local frac = seg - math.floor(seg)
					local a = path[math.min(idx, #path)]
					local b = path[math.min(idx + 1, #path)]
					local pos = a:Lerp(b, frac)
					local look = (b - a).Unit
					local bob = math.abs(math.sin(seg * 6)) * 0.15
					for pi, part in ipairs(n.parts) do
						local off = Vector3.new(0, 1.2 + bob, 0)
						if pi == 2 then
							off = Vector3.new(0, 2.3 + bob, 0)
						elseif pi == 3 then
							off = Vector3.new(0, 2.75 + bob, 0)
						elseif pi == 4 then
							off = Vector3.new(-0.6, 1.7 + bob + math.sin(seg * 7) * 0.3, 0)
						elseif pi == 5 then
							off = Vector3.new(0.6, 1.7 + bob + math.sin(seg * 7 + 3.14) * 0.3, 0)
						end
						part:PivotTo(CFrame.lookAt(pos + off, pos + off + look))
					end
				end
			end

			-- Fish swim in circles
			for _, school in pairs(fishSchools) do
				for fi, fish in ipairs(school.parts) do
					local a = t * school.speed + school.phase + fi * 0.35
					local pos = school.center + Vector3.new(
						math.cos(a) * school.radius,
						math.sin(a * 1.3 + fi) * 0.6,
						math.sin(a) * school.radius
					)
					local nextA = a + 0.1
					local nextPos = school.center + Vector3.new(
						math.cos(nextA) * school.radius,
						math.sin(nextA * 1.3 + fi) * 0.6,
						math.sin(nextA) * school.radius
					)
					fish:PivotTo(CFrame.lookAt(pos, nextPos))
				end
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
]==]
	print('[Installer] Wrote ServerScriptService/Services/AmbienceService')
end

print("[Installer] Part 10/16 complete - next: 11")
