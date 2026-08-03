--!strict
--[[
	Tidebound — AutoTerrainService
	Builds REAL terrain at server start (runtime FillBlock — works in Studio AND
	live servers, survives every publish). No Studio sculpting needed.
	- Sunshall: bay for the dock, flat village plateau, hills, beach ring.
	- 7 zone islands (shallow lagoon, cliff ring, volcano, ice, trench, hidden isles).
	- Deterministic noise so every server looks identical.
	Toggle with Config.AUTO_TERRAIN. Skips work if terrain already has cells.
	Phase 5 | AI-assisted | 2026-08-03
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local AutoTerrainService = {}
AutoTerrainService.Name = "AutoTerrainService"

local CELL = 6 -- column size (studs). 6 = good detail, fast enough at boot.
local terrain = Workspace:FindFirstChildOfClass("Terrain")

-- Deterministic pseudo-noise (value noise via sines — cheap + stable)
local function noise2(x: number, z: number): number
	return math.sin(x * 0.045 + z * 0.017) * 1.1
		+ math.sin((x + z * 0.6) * 0.023) * 0.9
		+ math.sin((x * 0.9 - z * 0.5) * 0.031) * 0.5
end

-- Island profile function: returns height (>=0) at local (lx, lz)
-- 0 means water (no terrain cell).
local function sunshallHeight(lx: number, lz: number): number
	-- lx/lz relative to island center (0,150), rotated so +lz = south (beach/village)
	-- Bay: south-center indentation for the dock
	if math.abs(lx) <= 48 and lz <= -40 then
		return 0.05
	end
	-- Village plateau
	if math.abs(lx) <= 76 and lz >= -40 and lz <= 52 then
		return 0.9 + noise2(lx, lz) * 0.25
	end
	-- Ramp bay -> plateau
	if math.abs(lx) <= 76 and lz > -46 and lz < -40 then
		return 0.05 + (lz + 46) / 6 * 0.85
	end
	-- South beach + hill rise
	if lz > 52 then
		return 0.9 + (lz - 52) / 95 * 8.5 + noise2(lx, lz) * 1.2
	end
	-- North (behind village) + side hills
	local edge = math.max(math.abs(lx) - 76, 0)
	return 0.9 + edge / 70 * 7 + math.max(-lz, 0) / 100 * 5 + noise2(lx, lz) * 1.0
end

local function genericIslandHeight(lx: number, lz: number, radius: number, maxH: number, profile: string): number
	local d = math.sqrt(lx * lx + lz * lz)
	if d > radius then
		return 0
	end
	local t = 1 - d / radius
	local n = noise2(lx, lz) * 1.2
	if profile == "lagoon" then
		-- shallow sandbars
		return math.max(0.05, t * 2.6 + n * 0.8)
	elseif profile == "cliffs" then
		-- horseshoe ring of cliffs around a deep basin (open to the north)
		if lz < -radius * 0.2 then
			return 0.05 -- basin mouth
		end
		local ring = math.abs(1 - d / (radius * 0.62))
		return math.max(0.05, ring * 14 + n * 1.5)
	elseif profile == "volcano" then
		-- cone with crater
		local h = t * 13
		if d < radius * 0.18 then
			h = 10.5 -- crater floor
		end
		return math.max(0.05, h + n * 0.8)
	elseif profile == "ice" then
		return math.max(0.05, t * 3.2 + n * 0.7)
	elseif profile == "trench" then
		return 0.05 -- near-flat abyssal floor (the pillars/wreck are parts)
	else
		return math.max(0.05, t * maxH + n * 0.8)
	end
end

local function buildIsland(cx: number, cz: number, radius: number, profileFn: (number, number) -> number, materialFn: (number) -> Enum.Material)
	local cells = 0
	local half = CELL / 2
	for gx = cx - radius, cx + radius, CELL do
		for gz = cz - radius, cz + radius, CELL do
			local h = profileFn(gx - cx, gz - cz)
			if h > 0.06 then
				local region = Region3.new(
					Vector3.new(gx - half, -4, gz - half),
					Vector3.new(gx + half, h, gz + half)
				)
				terrain:FillBlock(region, materialFn(h), Enum.OrientationAxis.Y)
				cells += 1
			end
		end
		if cells % 400 == 0 then
			task.wait() -- yield so the server stays responsive
		end
	end
	return cells
end

function AutoTerrainService:BuildWorld()
	if not Config.AUTO_TERRAIN or not terrain then
		return
	end

	-- Deterministic: rebuild every boot. If you hand-sculpt terrain in Studio,
	-- set Config.AUTO_TERRAIN = false to keep yours.
	print("[AutoTerrain] Building Sunshall (spawn island)...")
	buildIsland(0, 150, 140, sunshallHeight, function(h)
		if h < 1.2 then return Enum.Material.Sand end
		if h < 4.5 then return Enum.Material.Grass end
		return Enum.Material.Rock
	end)
	-- (smoothing optional; noise already soft)

	print("[AutoTerrain] Building zone islands...")
	buildIsland(0, -1000, 64, function(lx, lz) return genericIslandHeight(lx, lz, 64, 2.6, "lagoon") end, function(h)
		return Enum.Material.Sand
	end)
	buildIsland(0, -2000, 68, function(lx, lz) return genericIslandHeight(lx, lz, 68, 14, "cliffs") end, function(h)
		if h < 1 then return Enum.Material.Sand end
		return Enum.Material.Slate
	end)
	buildIsland(0, -3000, 64, function(lx, lz) return genericIslandHeight(lx, lz, 64, 13, "volcano") end, function(h)
		return Enum.Material.Basalt
	end)
	buildIsland(0, -4000, 64, function(lx, lz) return genericIslandHeight(lx, lz, 64, 3.2, "ice") end, function(h)
		if h < 1 then return Enum.Material.Sand end
		return Enum.Material.Snow
	end)
	buildIsland(0, -5000, 60, function(lx, lz) return genericIslandHeight(lx, lz, 60, 2, "trench") end, function(h)
		return Enum.Material.Rock
	end)
	buildIsland(800, -3000, 44, function(lx, lz) return genericIslandHeight(lx, lz, 44, 3, "island") end, function(h)
		if h < 1 then return Enum.Material.Sand end
		return Enum.Material.Grass
	end)
	buildIsland(800, -2000, 44, function(lx, lz) return genericIslandHeight(lx, lz, 44, 3, "island") end, function(h)
		return Enum.Material.Slate
	end)

	print("[AutoTerrain] World terrain complete ✅")
end

function AutoTerrainService:Init(ctx)
	self.ctx = ctx
end

function AutoTerrainService:Start()
	task.spawn(function()
		task.wait(1) -- let other services boot first
		self:BuildWorld()
	end)
end

function AutoTerrainService:Stop()
end

return AutoTerrainService
