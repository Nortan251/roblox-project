#!/usr/bin/env python3
"""Generates tools/build_place_rbxmk.lua — an rbxmk script that builds the ENTIRE
Tidebound place (29 scripts + a RICH, PLAYABLE map) and encodes it to binary .rbxl.

v2 map fixes (2026-08-03):
- All walkable geometry (dock, spawn, market, NPCs, beach, palms, lighthouse) sits
  ABOVE the water line (water surface Y=0). Previously the dock was underwater = unplayable.
- Added Terrain instance, sand shelf, island bases (no floating sand), route buoys
  that don't block swimming, denser decoration, NumberSequence keypoint safety.

Usage:
    python3 tools/generate_rbxl_script.py
    tools/rbxmk/rbxmk run --desc-latest --allow-insecure-paths tools/build_place_rbxmk.lua
"""
import math, pathlib, random

SRC = pathlib.Path("/home/user/tidebound/src")
OUT_SCRIPT = pathlib.Path("/home/user/tidebound/tools/build_place_rbxmk.lua")
OUT_RBXL = pathlib.Path("/home/user/tidebound/tools/tidebound_full.rbxl")

TREE = {
    "ReplicatedStorage/Shared": "Folder",
    "ReplicatedStorage/Shared/Config": "ModuleScript",
    "ReplicatedStorage/Shared/Types": "ModuleScript",
    "ReplicatedStorage/Shared/Util": "ModuleScript",
    "ReplicatedStorage/Shared/Remotes": "ModuleScript",
    "ReplicatedStorage/Shared/Data": "Folder",
    "ReplicatedStorage/Shared/Data/FishCatalog": "ModuleScript",
    "ReplicatedStorage/Shared/Data/RodCatalog": "ModuleScript",
    "ReplicatedStorage/Shared/Data/ZoneCatalog": "ModuleScript",
    "ReplicatedStorage/Shared/Data/QuestCatalog": "ModuleScript",
    "ReplicatedStorage/Shared/Data/CosmeticsCatalog": "ModuleScript",
    "ServerScriptService/Bootstrap": "Script",
    "ServerScriptService/Services": "Folder",
    "ServerScriptService/Services/SecurityService": "Script",
    "ServerScriptService/Services/DataService": "Script",
    "ServerScriptService/Services/EconomyService": "Script",
    "ServerScriptService/Services/InventoryService": "Script",
    "ServerScriptService/Services/QuestService": "Script",
    "ServerScriptService/Services/EventService": "Script",
    "ServerScriptService/Services/LeaderboardService": "Script",
    "ServerScriptService/Services/ShopService": "Script",
    "ServerScriptService/Services/TravelService": "Script",
    "ServerScriptService/Services/AmbienceService": "Script",
    "ServerScriptService/Services/FishingService": "Script",
    "StarterPlayer/StarterPlayerScripts/Bootstrap": "LocalScript",
    "StarterPlayer/StarterPlayerScripts/Controllers": "Folder",
    "StarterPlayer/StarterPlayerScripts/Controllers/AudioController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/CastController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/UIController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/MenuUIController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules": "Folder",
    "StarterPlayer/StarterPlayerScripts/Modules/Theme": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules/UiKit": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules/ClientState": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules/FishVisuals": "ModuleScript",
}

def source_for(logical: str) -> str:
    parts = logical.split("/")
    base = SRC / "/".join(parts)
    for cand in (base.with_suffix(".luau"), base.with_suffix(".server.luau"), base.with_suffix(".client.luau")):
        if cand.exists():
            return cand.read_text()
    raise FileNotFoundError(logical)

def lua_string(s: str) -> str:
    assert "]===]" not in s
    return "[===[%s]===]" % s

def lua_color(c) -> str:
    return "{%d, %d, %d}" % tuple(c)

rng = random.Random(2026)

def jitter(amt: float) -> float:
    return rng.uniform(-amt, amt)

L = []
A = L.append

# ── helpers ──────────────────────────────────────────────────────────────
A("-- Tidebound place builder (GENERATED) — v2 rich playable map + 29 scripts")
A("local dm = Instance.new('DataModel')")
A("dm.Name = 'Tidebound'")
A("local ws = Instance.new('Workspace')")
A("ws.Name = 'Workspace'")
A("ws.Parent = dm")
A("local terrain = Instance.new('Terrain')")
A("terrain.Parent = ws")
A("")
A("local function part(parent, name, x, y, z, sx, sy, sz, color, mat, transp, collide, shape, rx, ry, rz)")
A("    local p = Instance.new('Part')")
A("    p.Name = name")
A("    p.Anchored = true")
A("    p.CanCollide = collide")
A("    p.CanQuery = true")
A("    p.CanTouch = false")
A("    p.Size = Vector3.new(sx, sy, sz)")
A("    p.CFrame = CFrame.new(x, y, z) * CFrame.Angles(rx or 0, ry or 0, rz or 0)")
A("    p.Color = Color3.fromRGB(color[1], color[2], color[3])")
A("    p.Material = mat")
A("    p.Transparency = transp")
A("    p.Shape = shape")
A("    p.Parent = parent")
A("    return p")
A("end")
A("local function light(parent, color, brightness, range)")
A("    local l = Instance.new('PointLight')")
A("    l.Color = Color3.fromRGB(color[1], color[2], color[3])")
A("    l.Brightness = brightness")
A("    l.Range = range")
A("    l.Parent = parent")
A("    return l")
A("end")
A("local function fx(parent, color, rate, life0, life1, speed0, speed1, size0, size1, transp0, transp1)")
A("    local pe = Instance.new('ParticleEmitter')")
A("    pe.Name = 'FX'")
A("    pe.Rate = rate")
A("    pe.Lifetime = NumberRange.new(life0, life1)")
A("    pe.Speed = NumberRange.new(speed0, speed1)")
A("    pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size0), NumberSequenceKeypoint.new(1, size1) })")
A("    pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, transp0), NumberSequenceKeypoint.new(1, transp1) })")
A("    pe.Color = ColorSequence.new(Color3.fromRGB(color[1], color[2], color[3]))")
A("    pe.Parent = parent")
A("    return pe")
A("end")
A("local function billboard(parent, text, color, offsetY)")
A("    local bg = Instance.new('BillboardGui')")
A("    bg.Name = 'Tag'")
A("    bg.AlwaysOnTop = true")
A("    bg.Size = UDim2.new(0, 300, 0, 60)")
A("    bg.StudsOffset = Vector3.new(0, offsetY, 0)")
A("    bg.MaxDistance = 400")
A("    bg.Parent = parent")
A("    local lbl = Instance.new('TextLabel')")
A("    lbl.Name = 'Label'")
A("    lbl.Text = text")
A("    lbl.BackgroundTransparency = 1")
A("    lbl.TextColor3 = Color3.fromRGB(color[1], color[2], color[3])")
A("    lbl.TextSize = 18")
A("    lbl.Font = Enum.Font.GothamBold")
A("    lbl.Size = UDim2.new(1, 0, 0, 60)")
A("    lbl.TextStrokeTransparency = 0.5")
A("    lbl.Parent = bg")
A("end")
A("")

def fmt(v):
    if isinstance(v, float):
        return repr(round(v, 2))
    return str(v)

def P(name, x, y, z, sx, sy, sz, color, mat="SmoothPlastic", transp=0, collide=True, shape="Block", rx=0, ry=0, rz=0):
    A("part(ws, " + repr(name) + ", %s, %s, %s, %s, %s, %s, %s, Enum.Material.%s, %s, %s, Enum.PartType.%s, %s, %s, %s)"
      % (fmt(x), fmt(y), fmt(z), fmt(sx), fmt(sy), fmt(sz), lua_color(color), mat, fmt(transp), "true" if collide else "false", shape, fmt(rx), fmt(ry), fmt(rz)))

def rock(name, x, z, y, s, color=(110, 110, 118)):
    P(name, x + jitter(2), y, z + jitter(2), s[0], s[1], s[2], color, "Rock", 0, True, "Block", jitter(0.15), jitter(0.2), jitter(0.15))

def rock_cluster(bx, bz, n, base_y=-1.8, color=(110, 110, 118)):
    for i in range(n):
        rock(f"Rock_{bx}_{bz}_{i}", bx + jitter(16), bz + jitter(16), base_y + rng.uniform(0, 3),
             (rng.uniform(2, 5), rng.uniform(2, 5), rng.uniform(2, 5)), color)

def palm(bx, bz, name):
    P(f"PalmTrunk_{name}", bx + jitter(3), 3.4, bz + jitter(3), 0.7, 6, 0.7, (122, 82, 44), "Wood", 0, False, "Cylinder", jitter(0.08), 0, jitter(0.08))
    ty = 5.2
    for k in range(5):
        ang = k * 1.26
        P(f"PalmLeaf_{name}_{k}", bx + jitter(3) + math.cos(ang) * 2.6, ty + 0.3, bz + jitter(3) + math.sin(ang) * 2.6,
          3.2, 0.35, 0.9, (58, 138, 60), "SmoothPlastic", 0, False, "Wedge", 0.5, 0, -ang + 1.57)
    P(f"PalmNut1_{name}", bx + jitter(3) - 0.4, ty - 0.5, bz + jitter(3) + 0.3, 0.4, 0.4, 0.4, (90, 62, 30), "SmoothPlastic", 0, False, "Ball")
    P(f"PalmNut2_{name}", bx + jitter(3) + 0.4, ty - 0.5, bz + jitter(3) - 0.3, 0.4, 0.4, 0.4, (90, 62, 30), "SmoothPlastic", 0, False, "Ball")

def buoy(bx, bz, color, name):
    P(f"BuoyPole_{name}", bx, 0.5, bz, 0.6, 8, 0.6, (90, 90, 100), "SmoothPlastic", 0, False, "Block")
    A(f"do local b = part(ws, 'BuoyBall_{name}', {fmt(bx)}, 4.6, {fmt(bz)}, 2.4, 2.4, 2.4, {lua_color(color)}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)")
    A(f"light(b, {lua_color(color)}, 0.8, 20)")
    A("end")

# ═══════════ WORLD BASE (water surface Y = 0) ═══════════
P("SeaFloor", 0, -3.5, -2500, 12000, 5, 12000, (110, 140, 170), "SmoothPlastic", 0, True, "Block")
P("WaterVisual", 0, 0, -2500, 12000, 7, 12000, (40, 130, 210), "Glass", 0.45, False, "Block")

# ═══════════ SUNSHALL COVE ═══════════
# Dock — top at +0.6, ABOVE water
P("DockPlanks", 0, 0.0, 58, 44, 1.2, 24, (150, 110, 70), "Wood", 0, True, "Block")
P("DockArm", 0, 0.0, 84, 30, 1.1, 10, (140, 100, 65), "Wood", 0, True, "Block")
for (px, pz) in [(-18, 50), (18, 50), (-18, 66), (18, 66), (-12, 80), (12, 80)]:
    P(f"DockPillar_{px}_{pz}", px, -1.1, pz, 3, 3.4, 3, (120, 90, 60), "SmoothPlastic", 0, True, "Block")
# Railings
for side in (-19, 19):
    for z in range(47, 70, 5):
        P(f"RailPost_{side}_{z}", side, 0.55, z, 0.5, 2.6, 0.5, (110, 80, 50), "Wood", 0, True, "Block")
    P(f"RailLong_{side}", side, 1.4, 58, 0.5, 0.5, 23, (110, 80, 50), "Wood", 0, True, "Block")
P("RailEnd1", 0, 1.4, 46.6, 39, 0.5, 0.5, (110, 80, 50), "Wood", 0, True, "Block")
P("RailEnd2", 0, 1.4, 69.4, 39, 0.5, 0.5, (110, 80, 50), "Wood", 0, True, "Block")
# Lanterns
for (lx, lz) in [(-20, 47), (20, 47), (-20, 69), (20, 69)]:
    A(f"do local p = part(ws, 'Lantern_{lx}_{lz}', {fmt(lx)}, 1.6, {fmt(lz)}, 0.6, 4, 0.6, {{60, 55, 50}}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder)")
    A(f"local b = part(ws, 'LanternBall_{lx}_{lz}', {fmt(lx)}, 3.8, {fmt(lz)}, 1.1, 1.1, 1.1, {{255, 180, 80}}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)")
    A(f"light(b, {{255, 170, 70}}, 1, 28)")
    A("end")
# Crates / barrels / rope
for (cx, cz) in [(8, 62), (11, 63), (9, 65), (14, 60), (16, 63)]:
    P(f"Crate_{cx}_{cz}", cx, 0.5, cz, 2, 2, 2, (140, 100, 55), "Wood", 0, True, "Block")
for (bx2, bz2) in [(-12, 63), (-9, 65), (-14, 67)]:
    P(f"Barrel_{bx2}_{bz2}", bx2, 0.4, bz2, 1.4, 2.4, 1.4, (120, 90, 55), "Wood", 0, True, "Cylinder")
for (rx2, rz2) in [(-16, 60), (-17, 62)]:
    P(f"RopeCoil_{rx2}_{rz2}", rx2, 0.5, rz2, 1.6, 0.35, 1.6, (200, 170, 90), "SmoothPlastic", 0, True, "Cylinder")
# Dock sign
P("SignPost", -14, 1.7, 45, 0.6, 5, 0.6, (100, 70, 40), "Wood", 0, True, "Block")
A("do local b = part(ws, 'SignBoard', -14, 2.8, 45, 6, 2.4, 0.4, {90, 60, 35}, Enum.Material.Wood, 0, true, Enum.PartType.Block)")
A("billboard(b, 'SUNSHALL COVE', {255, 214, 150}, 4)")
A("end")
# Market
P("StallTable", 12, 0.0, 84, 10, 1, 6, (160, 120, 70), "Wood", 0, True, "Block")
P("StallPost1", 9, 0.45, 81, 1, 2.6, 1, (140, 100, 60), "Wood", 0, True, "Block")
P("StallPost2", 15, 0.45, 87, 1, 2.6, 1, (140, 100, 60), "Wood", 0, True, "Block")
P("StallRoof", 12, 2.0, 84, 14, 0.5, 14, (200, 60, 60), "SmoothPlastic", 0, True, "Block")
P("StallSign", 12, 1.5, 84, 12, 0.3, 12, (255, 210, 90), "Neon", 0, True, "Block")
P("MarketCrate1", 16, 0.5, 82, 2, 2, 2, (140, 100, 55), "Wood", 0, True, "Block")
P("MarketCrate2", 17, 0.5, 85, 2, 2, 2, (130, 95, 50), "Wood", 0, True, "Block")
for i, (hx, hz) in enumerate([(12, 81), (13, 83), (11, 85)]):
    P(f"HangingFish{i}", hx, 1.4, hz, 0.6, 1.2, 0.3, (90, 190, 220), "Neon", 0, False, "Wedge", 0, 0, 0.2)
A("do local b = part(ws, 'MarketBoard', 12, 2.8, 91, 8, 2, 0.4, {90, 60, 35}, Enum.Material.Wood, 0, true, Enum.PartType.Block)")
A("billboard(b, 'MARKET', {255, 210, 90}, 3.5)")
A("end")
# Old Salt (above water)
P("OldSaltBody", -20, 0.05, 70, 2.4, 3, 1.4, (70, 90, 130), "SmoothPlastic", 0, True, "Block")
P("OldSaltHead", -20, 1.75, 70, 1.3, 1.3, 1.3, (255, 220, 190), "SmoothPlastic", 0, True, "Ball")
P("OldSaltHat", -20, 2.4, 70, 1.6, 0.5, 1.6, (60, 60, 60), "SmoothPlastic", 0, True, "Block")
P("OldSaltBeard", -20, 1.55, 69.4, 0.9, 0.9, 0.5, (230, 230, 230), "SmoothPlastic", 0, True, "Block")
P("OldSaltRod", -18.4, 1.2, 70.8, 0.35, 5.5, 0.35, (150, 110, 70), "Wood", 0, False, "Cylinder", 0, 0, 0.6)
P("OldSaltBucket", -21.6, 0.4, 71.6, 1.2, 1.4, 1.2, (150, 150, 155), "Metal", 0, True, "Cylinder")
# Rowboat (floating)
A("do")
A("local h = part(ws, 'RowboatHull', 24, 0.9, 56, 8, 1.1, 3, {130, 90, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Wedge, 0, 0, 0)")
A("part(ws, 'RowboatSeat1', 24, 1.45, 56, 0.5, 0.4, 2.6, {120, 85, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block)")
A("part(ws, 'RowboatSeat2', 24, 1.45, 57.5, 0.5, 0.4, 2.6, {120, 85, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block)")
A("part(ws, 'RowboatOar1', 26.2, 1.2, 55.2, 3.4, 0.25, 0.25, {160, 130, 90}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0, 0, 0.5)")
A("part(ws, 'RowboatOar2', 26.2, 1.2, 56.8, 3.4, 0.25, 0.25, {160, 130, 90}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0, 0, -0.5)")
A("end")
# Spawn (above water)
A("do")
A("local sp = Instance.new('SpawnLocation')")
A("sp.Name = 'SpawnLocation'")
A("sp.Anchored = true")
A("sp.CanCollide = true")
A("sp.Size = Vector3.new(10, 0.6, 10)")
A("sp.CFrame = CFrame.new(0, 0.2, 66)")
A("sp.Color = Color3.fromRGB(90, 220, 170)")
A("sp.Material = Enum.Material.SmoothPlastic")
A("sp.Neutral = true")
A("sp.Duration = 5")
A("sp.Parent = ws")
A("end")
# Beach: sand shelf (solid) + sand patches + path
P("SandShelf", 25, -0.05, 140, 150, 1.4, 100, (205, 190, 150), "SmoothPlastic", 0, True, "Block")
for i in range(9):
    P(f"Sand_{i}", rng.uniform(-30, 80), 0.75, rng.uniform(96, 185), rng.uniform(12, 22), 0.12, rng.uniform(12, 22), (232, 214, 160), "SmoothPlastic", 0, False, "Block")
for i in range(12):
    z = 80 + i * 1.6
    P(f"Path_{i}", rng.uniform(-4, 4), 0.45, z, rng.uniform(2.4, 3.4), 0.1, rng.uniform(2.4, 3.4), (168, 160, 140), "Slate", 0, False, "Block")
# Palms
for i in range(12):
    palm(rng.uniform(-25, 75), rng.uniform(100, 180), f"P{i}")
# Beach rocks
for i in range(14):
    rock(f"BeachRock_{i}", rng.uniform(-40, 90), rng.uniform(92, 190), 0.8 + rng.uniform(0, 2.2),
         (rng.uniform(2, 5.5), rng.uniform(1.5, 4), rng.uniform(2, 5.5)))
# Campfire
A("do")
A("local f = part(ws, 'Fire', 42, 1.5, 138, 1.6, 2.4, 1.6, {255, 140, 40}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)")
A("light(f, {255, 150, 60}, 1.2, 22)")
A("fx(f, {190, 190, 195}, 8, 0.8, 1.6, 1, 2.5, 0.4, 0.9, 0.3, 1)")
A("end")
for i in range(4):
    P(f"CampLog_{i}", 42 + jitter(1), 1.0, 138 + jitter(1), 2.2, 0.5, 0.5, (100, 66, 40), "Wood", 0, True, "Cylinder", 0, 0, jitter(0.5))
for i in range(6):
    P(f"CampRing_{i}", 42 + math.cos(i * 1.05) * 2.6, 0.85, 138 + math.sin(i * 1.05) * 2.6, 1.1, 0.9, 1.1, (110, 108, 112), "Rock", 0, True, "Ball")
# Lighthouse islet
for i in range(5):
    rock(f"IsletRock_{i}", 228, 40, 0.4 + rng.uniform(0, 1.2), (rng.uniform(4, 7), rng.uniform(2, 3), rng.uniform(4, 7)))
A("do")
A("local t1 = part(ws, 'LhTower1', 232, 2.0, 42, 9, 8, 9, {240, 238, 230}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder)")
A("part(ws, 'LhTower2', 232, 5.5, 42, 7, 8, 7, {240, 238, 230}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder)")
A("part(ws, 'LhTower3', 232, 8.0, 42, 5, 4, 5, {200, 60, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder)")
A("local b = part(ws, 'LhLight', 232, 10.5, 42, 2.2, 2.2, 2.2, {255, 240, 160}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)")
A("light(b, {255, 230, 140}, 2, 70)")
A("end")
P("LhRoof", 232, 11.2, 42, 6, 1.6, 6, (90, 90, 95), "SmoothPlastic", 0, True, "Cylinder")
# Underwater life near Sunshall
for i in range(10):
    x, z = rng.uniform(-80, 80), rng.uniform(20, 90)
    col = rng.choice([(255, 120, 150), (255, 160, 90), (200, 110, 220), (255, 200, 120)])
    P(f"Coral_{i}", x, -2.8, z, 0.8, 1.4, 0.8, col, "SmoothPlastic", 0, False, "Cylinder")
    P(f"CoralHead_{i}", x, -2.0, z, 1.3, 1.3, 1.3, col, "Neon", 0, False, "Ball")
for i in range(16):
    x, z = rng.uniform(-90, 90), rng.uniform(15, 95)
    P(f"Kelp_{i}", x, -2.0, z, 0.3, 4.2, 0.3, (40, 130, 70), "SmoothPlastic", 0, False, "Cylinder", jitter(0.2), 0, jitter(0.2))
for i in range(8):
    rock(f"SeaRock_{i}", rng.uniform(-100, 100), rng.uniform(10, 95), -3.0, (rng.uniform(2, 4), rng.uniform(1.5, 3), rng.uniform(2, 4)))

# Route buoys
ZONE_COLORS = {
    "sunshall": (255, 214, 150), "whisper": (70, 220, 210), "drop": (40, 100, 200),
    "ember": (255, 100, 50), "frost": (200, 235, 255), "abyss": (120, 90, 200),
}
def zone_color_for(z):
    if z <= -4500: return ZONE_COLORS["abyss"]
    if z <= -3500: return ZONE_COLORS["frost"]
    if z <= -2500: return ZONE_COLORS["ember"]
    if z <= -1500: return ZONE_COLORS["drop"]
    if z <= -500: return ZONE_COLORS["whisper"]
    return ZONE_COLORS["sunshall"]
for i, z in enumerate(range(-100, -4900, -300)):
    buoy(0, z, zone_color_for(z), f"route{i}")

# ═══════════ ZONES ═══════════
ZONES = {
    "sunshall":      {"pos": (0, 0),      "size": (360, 360), "color": (255, 214, 150), "label": "Sunshall Cove"},
    "whisper":       {"pos": (0, -1000),  "size": (360, 360), "color": (70, 220, 210),  "label": "Whisper Shallows"},
    "drop":          {"pos": (0, -2000),  "size": (360, 360), "color": (40, 100, 200),  "label": "The Drop"},
    "ember":         {"pos": (0, -3000),  "size": (360, 360), "color": (255, 100, 50),  "label": "Ember Falls"},
    "frost":         {"pos": (0, -4000),  "size": (360, 360), "color": (200, 235, 255), "label": "Frostreach"},
    "abyss":         {"pos": (0, -5000),  "size": (360, 360), "color": (120, 90, 200),  "label": "Abyssal Trench"},
    "hidden_isles":  {"pos": (800, -3000), "size": (180, 180), "color": (240, 255, 240), "label": "Hidden Isle of Whispers"},
    "sunken_grotto": {"pos": (800, -2000), "size": (180, 180), "color": (120, 220, 200), "label": "The Sunken Grotto"},
}
for zid, z in ZONES.items():
    x, zz = z["pos"]; wx, wz = z["size"]; c = z["color"]
    P(f"ZoneDisc_{zid}", x, -0.35, zz, wx * 0.6, 0.3, wz * 0.6, c, "SmoothPlastic", 0.55, True, "Cylinder")
    P(f"ZoneRegion_{zid}", x, 0, zz, wx, 80, wz, (255, 255, 255), "SmoothPlastic", 1.0, False, "Block")
    A(f"do local b = part(ws, 'BuoyBall_{zid}', {fmt(x)}, 4.6, {fmt(zz)}, 2.4, 2.4, 2.4, {lua_color(c)}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)")
    A(f"light(b, {lua_color(c)}, 0.9, 24)")
    A(f"billboard(b, {lua_string(z['label'])}, {lua_color(c)}, 6)")
    A("end")

# ── Whisper Shallows
for i in range(60):
    x, z = rng.uniform(-160, 160), -1000 + rng.uniform(-160, 160)
    P(f"Seagrass_{i}", x, -2.0, z, 0.3, rng.uniform(2.5, 4.5), 0.3, (45, 140, 80), "SmoothPlastic", 0, False, "Cylinder", jitter(0.25), 0, jitter(0.25))
for i in range(6):
    x, z = rng.uniform(-150, 150), -1000 + rng.uniform(-150, 150)
    P(f"Shallow_{i}", x, 0.04, z, rng.uniform(18, 34), 0.2, rng.uniform(18, 34), (120, 230, 220), "Glass", 0.75, False, "Block")
rock_cluster(0, -1000, 10)
P("IsletBase", 60, -1.0, -1030, 26, 2, 20, (200, 180, 140), "SmoothPlastic", 0, True, "Block")
P("IsletSand1", 60, 0.48, -1030, 20, 0.15, 16, (232, 214, 160), "SmoothPlastic", 0, False, "Block")
P("IsletSand2", 60, 0.53, -1030, 14, 0.2, 12, (232, 214, 160), "SmoothPlastic", 0, False, "Block")
palm(60, -1030, "Isle")
for i in range(3):
    rock(f"IsletRock_{i}", 60, -1030, 0.6 + rng.uniform(0, 1.2), (2.5, 2, 2.5))
# Arch
P("ArchPillar1", -45, -1.0, -1000, 5, 14, 5, (120, 118, 124), "Rock", 0, True, "Block")
P("ArchPillar2", -15, -1.0, -1000, 5, 14, 5, (120, 118, 124), "Rock", 0, True, "Block")
P("ArchBeam", -30, 5.5, -1000, 36, 6, 6, (120, 118, 124), "Rock", 0, True, "Block")

# ── The Drop
for i in range(14):
    ang = i / 13 * math.pi
    cx = math.cos(ang) * 150
    cz = -2000 + math.sin(ang) * 40
    h = rng.uniform(16, 26)
    P(f"Cliff_{i}", cx, -3 + h / 2, cz, rng.uniform(16, 30), h, rng.uniform(10, 20), (70, 72, 80), "Rock", 0, True, "Block", jitter(0.1), jitter(0.2), jitter(0.1))
for i in range(8):
    P(f"FogWisp_{i}", rng.uniform(-160, 160), rng.uniform(2, 7), -2000 + rng.uniform(-140, 140), rng.uniform(20, 40), 2, rng.uniform(12, 26), (230, 240, 250), "SmoothPlastic", 0.72, False, "Block")
A("do")
A("part(ws, 'WreckHull', -90, -0.5, -2010, 20, 5, 8, {90, 62, 40}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0.45, 0.25, 0)")
A("part(ws, 'WreckDeck', -90, 1.2, -2010, 18, 1, 7, {120, 88, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0.45, 0.25, 0)")
A("part(ws, 'WreckMast', -95, 2.5, -2015, 1.4, 14, 1.4, {100, 70, 45}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0, 0, 0.2)")
A("part(ws, 'WreckBow', -81, -1.0, -2008, 6, 3, 5, {80, 55, 35}, Enum.Material.Wood, 0, true, Enum.PartType.Wedge, 0.3, 0, 0)")
A("end")
for i in range(6):
    P(f"WreckPlank_{i}", -90 + rng.uniform(-14, 14), -0.6, -2010 + rng.uniform(-8, 8), rng.uniform(3, 6), 0.4, rng.uniform(0.8, 1.6), (110, 78, 48), "Wood", 0, True, "Block", jitter(0.5), jitter(0.5), jitter(0.5))
P("WreckAnchor", -100, -1.0, -2004, 2.2, 3, 2.2, (90, 90, 95), "Metal", 0, True, "Cylinder")
P("WreckAnchorArm1", -100, 0.2, -2004, 1, 1, 4, (90, 90, 95), "Metal", 0, True, "Block")
P("WreckAnchorArm2", -100, 0.2, -2004, 4, 1, 1, (90, 90, 95), "Metal", 0, True, "Block")
P("DeepArchP1", 60, -1.0, -1990, 5, 16, 5, (80, 82, 90), "Rock", 0, True, "Block")
P("DeepArchP2", 90, -1.0, -1990, 5, 16, 5, (80, 82, 90), "Rock", 0, True, "Block")
P("DeepArchBeam", 75, 6.5, -1990, 36, 6, 6, (80, 82, 90), "Rock", 0, True, "Block")

# ── Ember Falls
for i in range(12):
    ang = i / 12 * 2 * math.pi
    P(f"VolcBase_{i}", math.cos(ang) * 46, -0.5, -3000 + math.sin(ang) * 46, 18, 6, 18, (60, 40, 40), "Rock", 0, True, "Block", 0, 0, ang)
for layer, (r, h, y) in enumerate([(34, 6, 1.5), (24, 6, 4.5), (15, 6, 7.5), (8, 6, 10.5)]):
    for i in range(6):
        ang = i / 6 * 2 * math.pi + layer * 0.3
        P(f"VolcLay{layer}_{i}", math.cos(ang) * r, y + h / 2, -3000 + math.sin(ang) * r, h * 1.6, h, h * 1.6, (50, 34, 34), "Rock", 0, True, "Block", 0, 0, ang)
P("CraterRim1", -6, 13.5, -3000, 8, 3, 8, (70, 45, 45), "Rock", 0, True, "Block")
P("CraterRim2", 6, 13.5, -3000, 8, 3, 8, (70, 45, 45), "Rock", 0, True, "Block")
P("LavaPool", 0, 14.2, -3000, 16, 1, 16, (255, 120, 30), "Neon", 0, False, "Cylinder")
A("do local b = part(ws, 'LavaGlow', 0, 14.6, -3000, 2, 2, 2, {255, 150, 40}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)")
A("light(b, {255, 120, 30}, 2.2, 80)")
A("fx(b, {255, 130, 40}, 6, 0.7, 1.4, 0.6, 1.8, 0.3, 0.8, 0.2, 1)")
A("end")
for i in range(6):
    P(f"LavaCrack_{i}", rng.uniform(-70, 70), 0.5, -3000 + rng.uniform(-70, 70), rng.uniform(3, 7), 0.2, rng.uniform(1, 2.5), (255, 110, 30), "Neon", 0, False, "Block", 0, rng.uniform(0, 3), 0)
P("FallCliff", 150, 4, -3010, 30, 20, 10, (90, 70, 70), "Rock", 0, True, "Block")
P("FallWater", 150, 2, -3010, 2.5, 18, 6, (170, 220, 240), "Glass", 0.45, False, "Block")
P("FallMist1", 150, -1, -3010, 12, 2, 8, (220, 235, 245), "SmoothPlastic", 0.6, False, "Block")
A("do local m = part(ws, 'FallMistFX', 150, -1.2, -3010, 1, 1, 1, {255, 255, 255}, Enum.Material.SmoothPlastic, 1, false, Enum.PartType.Ball)")
A("fx(m, {220, 235, 245}, 10, 0.8, 1.6, 1, 2.5, 1.5, 3, 0.35, 1)")
A("end")
rock_cluster(0, -3000, 8, -1.6, (90, 60, 55))

# ── Frostreach
for c in range(6):
    cx, cz = rng.uniform(-150, 150), -4000 + rng.uniform(-150, 150)
    for i in range(rng.randint(4, 6)):
        P(f"Iceberg{c}_{i}", cx + jitter(8), -1.5 + rng.uniform(0, 2.5), cz + jitter(8),
          rng.uniform(8, 18), rng.uniform(6, 12), rng.uniform(8, 18),
          (225, 240, 250), "Ice", 0.12, True, "Block", jitter(0.12), jitter(0.15), jitter(0.12))
for i in range(6):
    P(f"Snow_{i}", rng.uniform(-160, 160), 0.5, -4000 + rng.uniform(-160, 160), rng.uniform(16, 30), 0.15, rng.uniform(16, 30), (245, 250, 255), "SmoothPlastic", 0, False, "Block")
AURORA_COLORS = [(120, 255, 190), (140, 230, 255), (190, 140, 255)]
for i in range(8):
    col = AURORA_COLORS[i % 3]
    P(f"Aurora_{i}", rng.uniform(-180, 180), rng.uniform(52, 70), -4000 + rng.uniform(-160, 160),
      rng.uniform(40, 100), 1.2, 6, col, "Neon", 0.35, False, "Wedge", jitter(0.2), jitter(0.3), jitter(0.2))
for i in range(6):
    P(f"IceCrystal_{i}", rng.uniform(-150, 150), -1.5, -4000 + rng.uniform(-150, 150),
      rng.uniform(0.6, 1.4), rng.uniform(2, 4.5), 0.6, (170, 230, 255), "Neon", 0, False, "Wedge", 0, rng.uniform(0, 3), 0)

# ── Abyssal Trench
BIO_COLORS = [(90, 200, 255), (120, 255, 200), (200, 140, 255), (80, 160, 255)]
for i in range(40):
    col = rng.choice(BIO_COLORS)
    P(f"Bio_{i}", rng.uniform(-160, 160), rng.uniform(-2.6, -0.8), -5000 + rng.uniform(-160, 160),
      0.4, 0.4, 0.4, col, "Neon", 0, False, "Ball")
for i in range(6):
    P(f"AbyssPillar_{i}", rng.uniform(-150, 150), -3 + rng.uniform(0, 4), -5000 + rng.uniform(-150, 150),
      rng.uniform(4, 7), rng.uniform(10, 18), rng.uniform(4, 7), (50, 52, 62), "Rock", 0, True, "Cylinder")
sx, sz = -60, -5010
for i in range(9):
    P(f"Spine_{i}", sx - 14 + i * 3.5, -2.2 + math.sin(i * 0.5) * 0.5, sz, 1.6, 1.6, 1.6, (235, 235, 240), "SmoothPlastic", 0, False, "Ball")
for i in range(8):
    P(f"Rib_{i}", sx - 12 + i * 3.2, -1.8, sz + (4 if i % 2 == 0 else -4), 0.7, 0.7, 5, (225, 225, 232), "SmoothPlastic", 0, False, "Cylinder", 0.4 if i % 2 == 0 else -0.4, 0, 0)
P("Skull", sx + 18, -1.9, sz, 3.4, 2.6, 2.4, (235, 235, 240), "SmoothPlastic", 0, False, "Ball")
P("EyeL", sx + 18.6, -1.7, sz + 0.9, 0.7, 0.7, 0.7, (40, 40, 48), "SmoothPlastic", 0, False, "Ball")
P("EyeR", sx + 18.6, -1.7, sz - 0.9, 0.7, 0.7, 0.7, (40, 40, 48), "SmoothPlastic", 0, False, "Ball")
A("do")
A("local c = part(ws, 'ChestBase', 40, -2.4, -5020, 3, 2, 2, {200, 160, 60}, Enum.Material.Metal, 0, true, Enum.PartType.Block)")
A("part(ws, 'ChestLid', 40, -1.3, -5020, 3, 0.8, 2, {220, 180, 70}, Enum.Material.Metal, 0, true, Enum.PartType.Wedge, 0, 0, 0)")
A("local g = part(ws, 'ChestGlow', 40, -1.0, -5020, 1.2, 1.2, 1.2, {255, 220, 90}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)")
A("light(g, {255, 210, 80}, 1.5, 30)")
A("end")

# ── Hidden Isle of Whispers
P("IsleBase", 800, -1.0, -3000, 52, 2, 42, (200, 180, 140), "SmoothPlastic", 0, True, "Block")
P("IsleSand1", 800, 0.48, -3000, 40, 0.15, 32, (235, 218, 168), "SmoothPlastic", 0, False, "Block")
P("IsleSand2", 800, 0.53, -3000, 30, 0.2, 24, (235, 218, 168), "SmoothPlastic", 0, False, "Block")
for i in range(5):
    rock(f"IsleRock_{i}", 800, -3000, 0.6 + rng.uniform(0, 1.6), (2.5, 2, 2.5))
for i in range(3):
    palm(800 + jitter(10), -3000 + jitter(10), f"H{i}")
A("do")
A("local fr = part(ws, 'FloatRock', 830, 8, -2980, 8, 4, 8, {110, 108, 112}, Enum.Material.Rock, 0, true, Enum.PartType.Ball)")
A("part(ws, 'IsleFall', 830, 3, -2980, 1.6, 9, 3, {170, 220, 240}, Enum.Material.Glass, 0.45, false, Enum.PartType.Block)")
A("local m = part(ws, 'IsleMist', 830, -0.8, -2980, 1, 1, 1, {255, 255, 255}, Enum.Material.SmoothPlastic, 1, false, Enum.PartType.Ball)")
A("fx(m, {220, 235, 245}, 8, 0.8, 1.6, 1, 2.5, 1.5, 3, 0.35, 1)")
A("end")
A("do")
A("local c = part(ws, 'IsleChest', 800, -0.4, -2990, 3, 2, 2, {200, 160, 60}, Enum.Material.Metal, 0, true, Enum.PartType.Block)")
A("part(ws, 'IsleChestLid', 800, 0.7, -2990, 3, 0.8, 2, {220, 180, 70}, Enum.Material.Metal, 0, true, Enum.PartType.Wedge, 0, 0, 0)")
A("local g = part(ws, 'IsleChestGlow', 800, 0.9, -2990, 1.2, 1.2, 1.2, {255, 220, 90}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)")
A("light(g, {255, 210, 80}, 1.5, 30)")
A("end")
for i in range(3):
    P(f"IsleFog_{i}", 800 + jitter(20), rng.uniform(2, 6), -3000 + jitter(20), rng.uniform(18, 30), 2, rng.uniform(14, 22), (235, 245, 250), "SmoothPlastic", 0.7, False, "Block")

# ── Sunken Grotto
for i in range(12):
    ang = i / 12 * 2 * math.pi + 0.13
    P(f"GrottoWall_{i}", 800 + math.cos(ang) * 75, -1, -2000 + math.sin(ang) * 75,
      rng.uniform(10, 16), rng.uniform(8, 14), rng.uniform(10, 16), (95, 95, 105), "Rock", 0, True, "Block", 0, 0, ang)
for i in range(8):
    P(f"Stalactite_{i}", 800 + jitter(45), rng.uniform(4, 8), -2000 + jitter(45),
      rng.uniform(1, 2), rng.uniform(4, 7), rng.uniform(1, 2), (110, 108, 118), "Rock", 0, False, "Wedge", 0, 0, jitter(0.5))
for i in range(8):
    col = rng.choice([(120, 255, 170), (170, 130, 255)])
    P(f"Crystal_{i}", 800 + jitter(50), -2.6, -2000 + jitter(50),
      rng.uniform(0.7, 1.4), rng.uniform(2, 4.5), 0.7, col, "Neon", 0, False, "Wedge", 0, rng.uniform(0, 3), 0)
P("GrottoPool", 800, 0.02, -2000, 60, 0.3, 60, (30, 90, 130), "Glass", 0.6, False, "Block")
A("do")
A("local c = part(ws, 'GrottoChest', 800, -2.4, -1990, 3, 2, 2, {200, 160, 60}, Enum.Material.Metal, 0, true, Enum.PartType.Block)")
A("local g = part(ws, 'GrottoGlow', 800, -1.0, -1990, 1.2, 1.2, 1.2, {150, 255, 160}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)")
A("light(g, {120, 255, 170}, 1.5, 30)")
A("end")
rock_cluster(800, -2000, 5, -1.6, (100, 100, 110))

# ═══════════ Lighting ═══════════
A("")
A("-- Lighting")
A("local lighting = Instance.new('Lighting')")
A("lighting.Name = 'Lighting'")
A("lighting.Parent = dm")
A("lighting.ClockTime = 14")
A("lighting.FogColor = Color3.fromRGB(190, 215, 235)")
A("lighting.FogStart = 500")
A("lighting.FogEnd = 5200")
A("lighting.Ambient = Color3.fromRGB(115, 125, 135)")
A("lighting.OutdoorAmbient = Color3.fromRGB(135, 145, 155)")
A("lighting.Brightness = 1.2")

# ═══════════ Script tree ═══════════
A("")
A("-- ===== Script tree ===== --")
A("local containerCls = {")
A("    ReplicatedStorage = 'ReplicatedStorage',")
A("    ServerScriptService = 'ServerScriptService',")
A("    StarterPlayer = 'StarterPlayer',")
A("    StarterPlayerScripts = 'StarterPlayerScripts',")
A("    Shared = 'Folder',")
A("    Services = 'Folder',")
A("    Controllers = 'Folder',")
A("    Modules = 'Folder',")
A("    Data = 'Folder',")
A("}")
A("")
A("local function ensureChain(logical, cls)")
A("    local parts = {}")
A("    for p in logical:gmatch('[^/]+') do table.insert(parts, p) end")
A("    local cur = dm")
A("    for i, name in ipairs(parts) do")
A("        local child = cur:FindFirstChild(name)")
A("        if not child then")
A("            local childCls = containerCls[name] or (i == #parts and cls or 'Folder')")
A("            child = Instance.new(childCls)")
A("            child.Name = name")
A("            child.Parent = cur")
A("        end")
A("        cur = child")
A("    end")
A("    return cur")
A("end")
A("")
for logical in sorted(TREE):
    cls = TREE[logical]
    A(f"-- {logical}")
    A(f"local inst_{logical.replace('/', '_')} = ensureChain({lua_string(logical)}, '{cls}')")
    if cls in ("ModuleScript", "Script", "LocalScript"):
        A(f"inst_{logical.replace('/', '_')}.Source = {lua_string(source_for(logical))}")
    A("")

# ═══════════ Encode ═══════════
A("")
A("local bytes = rbxmk.encodeFormat('rbxl', dm)")
A("fs.write(%s, bytes, 'bin')" % lua_string(str(OUT_RBXL)))
A("print('WROTE ' .. %s .. ' (' .. #bytes .. ' bytes)')" % lua_string(str(OUT_RBXL)))

OUT_SCRIPT.write_text("\n".join(L), encoding="utf-8")
print(f"wrote {OUT_SCRIPT} ({len(L)} lines)")
