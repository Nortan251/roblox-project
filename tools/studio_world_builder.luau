--[[
	Tidebound — Studio World Builder (run ONCE in Studio)
	=====================================================
	Builds REAL terrain for the Tidebound world: Sunshall island with a
	village plateau, a bay for the dock, beach ring, and forested hills,
	plus themed islands for every fishing zone.

	HOW TO USE:
	1. Open the Tidebound place in Roblox Studio (File > Open From File >
	   tidebound_full.rbxl).
	2. View > Command Bar. Paste this ENTIRE file. Press Enter.
	3. Wait — it prints progress in the Output window (~1-2 minutes).
	4. Press Play to check, then File > Publish to Roblox As... to save it live.

	SAFE TO RE-RUN (it clears terrain first). Purely additive to the game.
]]

local Terrain = workspace.Terrain

local function noise(x, z)
	-- cheap pseudo-noise (sum of sines)
	return math.sin(x * 0.06) * math.cos(z * 0.05) * 1.5
		+ math.sin((x + z) * 0.025) * 1.2
		+ math.sin((x - z) * 0.04) * 0.8
end

local function fillColumn(cx, cz, h, material)
	if h <= 0.05 then return end
	local region = Region3.new(
		Vector3.new(cx - 2, -4, cz - 2),
		Vector3.new(cx + 2, h, cz + 2)
	)
	Terrain:FillBlock(region, material, Enum.OrientationAxis.Y)
end

local function buildIsland(cx, cz, radius, maxH, materialFn)
	local count = 0
	for gx = cx - radius, cx + radius, 4 do
		for gz = cz - radius, cz + radius, 4 do
			local dx, dz = gx - cx, gz - cz
			local d = math.sqrt(dx * dx + dz * dz)
			if d <= radius then
				local t = 1 - d / radius
				local h = t * maxH + noise(gx, gz) * 1.5
				if h < 0.05 then h = 0.05 end
				fillColumn(gx, gz, h, materialFn(h))
				count += 1
				if count % 400 == 0 then
					print("[Tidebound] terrain: " .. count .. " cells...")
					task.wait()
				end
			end
		end
	end
	return count
end

print("[Tidebound] Clearing old terrain...")
Terrain:Clear()

-- ══════════════════════ SUNSHALL ISLAND ══════════════════════
-- Layout: bay for the dock (z < 105), flat village plateau (105..195),
-- hills behind and on the sides, beach ring at the water edge.
local SUNSHALL_X, SUNSHALL_Z, SUNSHALL_R = 0, 150, 138
print("[Tidebound] Building Sunshall island (bay + village plateau + hills)...")
local count = 0
for gx = SUNSHALL_X - SUNSHALL_R, SUNSHALL_X + SUNSHALL_R, 4 do
	for gz = SUNSHALL_Z - SUNSHALL_R, SUNSHALL_Z + SUNSHALL_R, 4 do
		local dx, dz = gx - SUNSHALL_X, gz - SUNSHALL_Z
		local d = math.sqrt(dx * dx + dz * dz)
		if d <= SUNSHALL_R then
			local base
			-- Bay (dock area, north)
			if math.abs(dx) <= 46 and dz <= -42 then
				base = 0.15
			-- Village plateau
			elseif math.abs(dx) <= 72 and dz >= -40 and dz <= 48 then
				base = 0.6
			-- Ramp from bay to plateau
			elseif math.abs(dx) <= 72 and dz > -46 and dz < -40 then
				base = 0.15 + (dz + 46) / 6 * 0.45
			-- Hills: back + sides
			elseif dz > 48 then
				base = 0.6 + (dz - 48) / 90 * 9
			else
				base = 0.6 + (math.abs(dx) - 72) / 66 * 8
			end
			local n = noise(gx, gz)
			local plateau = (math.abs(dx) <= 72 and dz >= -40 and dz <= 48)
			local h = base + n * (plateau and 0.15 or 1.4)
			if h < 0.1 then h = 0.1 end
			if h > 12 then h = 12 end
			local mat
			if h < 1 then
				mat = Enum.Material.Sand
			elseif h < 4.2 then
				mat = Enum.Material.Grass
			else
				mat = Enum.Material.Rock
			end
			fillColumn(gx, gz, h, mat)
			count += 1
			if count % 500 == 0 then
				print("[Tidebound] Sunshall: " .. count .. " cells...")
				task.wait()
			end
		end
	end
end
print("[Tidebound] Smoothing Sunshall...")
Terrain:Smooth(Region3.new(Vector3.new(-140, -5, 10), Vector3.new(140, 15, 290)), 3)

-- ══════════════════════ ZONE ISLANDS ══════════════════════
local zones = {
	{ name = "Whisper Shallows", cx = 0,    cz = -1000, r = 62,  maxH = 6,  mat = Enum.Material.Sand },
	{ name = "The Drop",         cx = 0,    cz = -2000, r = 62,  maxH = 8,  mat = Enum.Material.Slate },
	{ name = "Ember Falls",      cx = 0,    cz = -3000, r = 62,  maxH = 9,  mat = Enum.Material.Basalt },
	{ name = "Frostreach",       cx = 0,    cz = -4000, r = 62,  maxH = 7,  mat = Enum.Material.Snow },
	{ name = "Abyssal Trench",   cx = 0,    cz = -5000, r = 62,  maxH = 6,  mat = Enum.Material.Rock },
	{ name = "Hidden Isle",      cx = 800,  cz = -3000, r = 46,  maxH = 5,  mat = Enum.Material.Sand },
	{ name = "Sunken Grotto",    cx = 800,  cz = -2000, r = 46,  maxH = 6,  mat = Enum.Material.Slate },
}
for _, zone in ipairs(zones) do
	print("[Tidebound] Building " .. zone.name .. "...")
	buildIsland(zone.cx, zone.cz, zone.r, zone.maxH, function(h)
		return h < 1.2 and Enum.Material.Sand or zone.mat
	end)
	Terrain:Smooth(Region3.new(
		Vector3.new(zone.cx - zone.r - 5, -5, zone.cz - zone.r - 5),
		Vector3.new(zone.cx + zone.r + 5, 12, zone.cz + zone.r + 5)
	), 2)
end

print("")
print("✅ [Tidebound] World terrain complete!")
print("   - Sunshall: bay + village plateau + hills + beach")
print("   - 7 zone islands with themed terrain")
print("Next: press Play to check, then File > Publish to Roblox As...")
