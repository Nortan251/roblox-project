-- Tidebound place builder (GENERATED) — v2 rich playable map + 29 scripts
local dm = Instance.new('DataModel')
dm.Name = 'Tidebound'
local ws = Instance.new('Workspace')
ws.Name = 'Workspace'
ws.Parent = dm
local terrain = Instance.new('Terrain')
terrain.Parent = ws

local function part(parent, name, x, y, z, sx, sy, sz, color, mat, transp, collide, shape, rx, ry, rz)
    local p = Instance.new('Part')
    p.Name = name
    p.Anchored = true
    p.CanCollide = collide
    p.CanQuery = true
    p.CanTouch = false
    p.Size = Vector3.new(sx, sy, sz)
    p.CFrame = CFrame.new(x, y, z) * CFrame.Angles(rx or 0, ry or 0, rz or 0)
    p.Color = Color3.fromRGB(color[1], color[2], color[3])
    p.Material = mat
    p.Transparency = transp
    p.Shape = shape
    p.Parent = parent
    return p
end
local function light(parent, color, brightness, range)
    local l = Instance.new('PointLight')
    l.Color = Color3.fromRGB(color[1], color[2], color[3])
    l.Brightness = brightness
    l.Range = range
    l.Parent = parent
    return l
end
local function fx(parent, color, rate, life0, life1, speed0, speed1, size0, size1, transp0, transp1)
    local pe = Instance.new('ParticleEmitter')
    pe.Name = 'FX'
    pe.Rate = rate
    pe.Lifetime = NumberRange.new(life0, life1)
    pe.Speed = NumberRange.new(speed0, speed1)
    pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size0), NumberSequenceKeypoint.new(1, size1) })
    pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, transp0), NumberSequenceKeypoint.new(1, transp1) })
    pe.Color = ColorSequence.new(Color3.fromRGB(color[1], color[2], color[3]))
    pe.Parent = parent
    return pe
end
local function billboard(parent, text, color, offsetY)
    local bg = Instance.new('BillboardGui')
    bg.Name = 'Tag'
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 300, 0, 60)
    bg.StudsOffset = Vector3.new(0, offsetY, 0)
    bg.MaxDistance = 400
    bg.Parent = parent
    local lbl = Instance.new('TextLabel')
    lbl.Name = 'Label'
    lbl.Text = text
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(color[1], color[2], color[3])
    lbl.TextSize = 18
    lbl.Font = Enum.Font.GothamBold
    lbl.Size = UDim2.new(1, 0, 0, 60)
    lbl.TextStrokeTransparency = 0.5
    lbl.Parent = bg
end

part(ws, 'SeaFloor', 0, -3.5, -2500, 12000, 5, 12000, {110, 140, 170}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'WaterVisual', 0, -0.2, -2500, 12000, 0.4, 12000, {40, 130, 210}, Enum.Material.Glass, 0.72, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DockPlanks', 0, 0.0, 58, 44, 1.2, 24, {150, 110, 70}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DockArm', 0, 0.0, 84, 30, 1.1, 10, {140, 100, 65}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DockPillar_-18_50', -18, -1.1, 50, 3, 3.4, 3, {120, 90, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DockPillar_18_50', 18, -1.1, 50, 3, 3.4, 3, {120, 90, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DockPillar_-18_66', -18, -1.1, 66, 3, 3.4, 3, {120, 90, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DockPillar_18_66', 18, -1.1, 66, 3, 3.4, 3, {120, 90, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DockPillar_-12_80', -12, -1.1, 80, 3, 3.4, 3, {120, 90, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DockPillar_12_80', 12, -1.1, 80, 3, 3.4, 3, {120, 90, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_-19_47', -19, 0.55, 47, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_-19_52', -19, 0.55, 52, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_-19_57', -19, 0.55, 57, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_-19_62', -19, 0.55, 62, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_-19_67', -19, 0.55, 67, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailLong_-19', -19, 1.4, 58, 0.5, 0.5, 23, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_19_47', 19, 0.55, 47, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_19_52', 19, 0.55, 52, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_19_57', 19, 0.55, 57, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_19_62', 19, 0.55, 62, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailPost_19_67', 19, 0.55, 67, 0.5, 2.6, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailLong_19', 19, 1.4, 58, 0.5, 0.5, 23, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailEnd1', 0, 1.4, 46.6, 39, 0.5, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'RailEnd2', 0, 1.4, 69.4, 39, 0.5, 0.5, {110, 80, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
do local p = part(ws, 'Lantern_-20_47', -20, 1.6, 47, 0.6, 4, 0.6, {60, 55, 50}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder)
local b = part(ws, 'LanternBall_-20_47', -20, 3.8, 47, 1.1, 1.1, 1.1, {255, 180, 80}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)
light(b, {255, 170, 70}, 1, 28)
end
do local p = part(ws, 'Lantern_20_69', 20, 1.6, 69, 0.6, 4, 0.6, {60, 55, 50}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder)
local b = part(ws, 'LanternBall_20_69', 20, 3.8, 69, 1.1, 1.1, 1.1, {255, 180, 80}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)
light(b, {255, 170, 70}, 1, 28)
end
part(ws, 'Crate_8_62', 8, 0.5, 62, 2, 2, 2, {140, 100, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Crate_11_63', 11, 0.5, 63, 2, 2, 2, {140, 100, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Crate_9_65', 9, 0.5, 65, 2, 2, 2, {140, 100, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Crate_14_60', 14, 0.5, 60, 2, 2, 2, {140, 100, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Crate_16_63', 16, 0.5, 63, 2, 2, 2, {140, 100, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Barrel_-12_63', -12, 0.4, 63, 1.4, 2.4, 1.4, {120, 90, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'Barrel_-9_65', -9, 0.4, 65, 1.4, 2.4, 1.4, {120, 90, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'Barrel_-14_67', -14, 0.4, 67, 1.4, 2.4, 1.4, {120, 90, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'RopeCoil_-16_60', -16, 0.5, 60, 1.6, 0.35, 1.6, {200, 170, 90}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'RopeCoil_-17_62', -17, 0.5, 62, 1.6, 0.35, 1.6, {200, 170, 90}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'SignPost', -14, 1.7, 45, 0.6, 5, 0.6, {100, 70, 40}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
do local b = part(ws, 'SignBoard', -14, 2.8, 45, 6, 2.4, 0.4, {90, 60, 35}, Enum.Material.Wood, 0, true, Enum.PartType.Block)
billboard(b, 'SUNSHALL COVE', {255, 214, 150}, 4)
end
part(ws, 'StallTable', 12, 0.0, 84, 10, 1, 6, {160, 120, 70}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'StallPost1', 9, 0.45, 81, 1, 2.6, 1, {140, 100, 60}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'StallPost2', 15, 0.45, 87, 1, 2.6, 1, {140, 100, 60}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'StallRoof', 12, 2.0, 84, 14, 0.5, 14, {200, 60, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'StallSign', 12, 1.5, 84, 12, 0.3, 12, {255, 210, 90}, Enum.Material.Neon, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'MarketCrate1', 16, 0.5, 82, 2, 2, 2, {140, 100, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'MarketCrate2', 17, 0.5, 85, 2, 2, 2, {130, 95, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'HangingFish0', 12, 1.4, 81, 0.6, 1.2, 0.3, {90, 190, 220}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0, 0.2)
part(ws, 'HangingFish1', 13, 1.4, 83, 0.6, 1.2, 0.3, {90, 190, 220}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0, 0.2)
part(ws, 'HangingFish2', 11, 1.4, 85, 0.6, 1.2, 0.3, {90, 190, 220}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0, 0.2)
do local b = part(ws, 'MarketBoard', 12, 2.8, 91, 8, 2, 0.4, {90, 60, 35}, Enum.Material.Wood, 0, true, Enum.PartType.Block)
billboard(b, 'MARKET', {255, 210, 90}, 3.5)
end
part(ws, 'OldSaltBody', -20, 0.05, 70, 2.4, 3, 1.4, {70, 90, 130}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'OldSaltHead', -20, 1.75, 70, 1.3, 1.3, 1.3, {255, 220, 190}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'OldSaltHat', -20, 2.4, 70, 1.6, 0.5, 1.6, {60, 60, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'OldSaltBeard', -20, 1.55, 69.4, 0.9, 0.9, 0.5, {230, 230, 230}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'OldSaltRod', -18.4, 1.2, 70.8, 0.35, 5.5, 0.35, {150, 110, 70}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0, 0, 0.6)
part(ws, 'OldSaltBucket', -21.6, 0.4, 71.6, 1.2, 1.4, 1.2, {150, 150, 155}, Enum.Material.Metal, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
do
local h = part(ws, 'RowboatHull', 24, 0.9, 56, 8, 1.1, 3, {130, 90, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Wedge, 0, 0, 0)
part(ws, 'RowboatSeat1', 24, 1.45, 56, 0.5, 0.4, 2.6, {120, 85, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block)
part(ws, 'RowboatSeat2', 24, 1.45, 57.5, 0.5, 0.4, 2.6, {120, 85, 50}, Enum.Material.Wood, 0, true, Enum.PartType.Block)
part(ws, 'RowboatOar1', 26.2, 1.2, 55.2, 3.4, 0.25, 0.25, {160, 130, 90}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0, 0, 0.5)
part(ws, 'RowboatOar2', 26.2, 1.2, 56.8, 3.4, 0.25, 0.25, {160, 130, 90}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0, 0, -0.5)
end
do
local sp = Instance.new('SpawnLocation')
sp.Name = 'SpawnLocation'
sp.Anchored = true
sp.CanCollide = true
sp.Size = Vector3.new(10, 0.6, 10)
sp.CFrame = CFrame.new(0, 0.2, 66) * CFrame.Angles(0, math.pi, 0)
sp.Color = Color3.fromRGB(90, 220, 170)
sp.Material = Enum.Material.SmoothPlastic
sp.Neutral = true
sp.Duration = 5
sp.Parent = ws
end
part(ws, 'SandShelf', 25, -0.05, 140, 150, 1.4, 100, {205, 190, 150}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Sand_0', -16.9, 0.75, 140.72, 17.12, 0.12, 20.6, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Sand_1', -18.71, 0.75, 115.87, 18.01, 0.12, 17.57, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Sand_2', 56.17, 0.75, 144.76, 19.31, 0.12, 19.68, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Sand_3', 52.61, 0.75, 148.2, 14.4, 0.12, 18.14, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Sand_4', -17.82, 0.75, 168.69, 16.5, 0.12, 20.15, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Sand_5', 45.37, 0.75, 156.47, 14.1, 0.12, 14.52, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Sand_6', 77.79, 0.75, 178.71, 20.05, 0.12, 22.0, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Sand_7', 26.49, 0.75, 102.79, 15.4, 0.12, 17.57, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Sand_8', 2.13, 0.75, 136.71, 20.76, 0.12, 19.04, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_0', 0.62, 0.45, 80.0, 2.42, 0.1, 3.11, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_1', -1.09, 0.45, 81.6, 2.82, 0.1, 2.8, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_2', 0.69, 0.45, 83.2, 2.9, 0.1, 2.52, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_3', 0.05, 0.45, 84.8, 3.15, 0.1, 3.0, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_4', -0.07, 0.45, 86.4, 3.32, 0.1, 2.66, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_5', -0.64, 0.45, 88.0, 3.33, 0.1, 2.88, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_6', 0.14, 0.45, 89.6, 2.43, 0.1, 2.62, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_7', -2.97, 0.45, 91.2, 2.45, 0.1, 3.1, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_8', 3.09, 0.45, 92.8, 2.5, 0.1, 3.02, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_9', -0.24, 0.45, 94.4, 2.88, 0.1, 2.63, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_10', 3.09, 0.45, 96.0, 3.03, 0.1, 2.86, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Path_11', -0.24, 0.45, 97.6, 3.33, 0.1, 3.39, {168, 160, 140}, Enum.Material.Slate, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'PalmTrunk_P0', 30.58, 3.4, 143.63, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.05, 0, 0.0)
part(ws, 'PalmLeaf_P0_0', 32.04, 5.5, 147.09, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P0_1', 29.96, 5.5, 146.03, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P0_2', 26.06, 5.5, 143.5, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P0_3', 28.41, 5.5, 143.82, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P0_4', 30.15, 5.5, 142.46, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P0', 29.1, 4.7, 147.61, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P0', 28.52, 4.7, 144.4, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P1', 27.97, 3.4, 166.44, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.07, 0, 0.05)
part(ws, 'PalmLeaf_P1_0', 27.63, 5.5, 168.59, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P1_1', 24.51, 5.5, 169.71, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P1_2', 25.72, 5.5, 167.7, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P1_3', 23.76, 5.5, 167.34, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P1_4', 29.77, 5.5, 165.69, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P1', 25.6, 4.7, 163.78, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P1', 25.13, 4.7, 165.78, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P2', -15.87, 3.4, 159.5, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, -0.08, 0, -0.08)
part(ws, 'PalmLeaf_P2_0', -12.25, 5.5, 162.4, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P2_1', -17.04, 5.5, 164.04, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P2_2', -18.96, 5.5, 162.04, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P2_3', -15.91, 5.5, 160.99, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P2_4', -13.49, 5.5, 158.15, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P2', -17.81, 4.7, 158.98, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P2', -14.44, 4.7, 161.12, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P3', 71.32, 3.4, 137.17, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, -0.04, 0, 0.01)
part(ws, 'PalmLeaf_P3_0', 75.34, 5.5, 141.62, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P3_1', 70.82, 5.5, 139.34, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P3_2', 68.89, 5.5, 143.48, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P3_3', 69.61, 5.5, 140.3, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P3_4', 69.67, 5.5, 136.37, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P3', 71.44, 4.7, 139.78, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P3', 68.57, 4.7, 136.14, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P4', -17.08, 3.4, 170.1, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, -0.02, 0, 0.04)
part(ws, 'PalmLeaf_P4_0', -14.63, 5.5, 171.08, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P4_1', -14.62, 5.5, 172.32, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P4_2', -17.54, 5.5, 170.26, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P4_3', -13.78, 5.5, 169.9, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P4_4', -11.72, 5.5, 166.48, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P4', -14.67, 4.7, 170.92, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P4', -14.97, 4.7, 171.31, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P5', 42.24, 3.4, 103.73, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.07, 0, -0.07)
part(ws, 'PalmLeaf_P5_0', 45.72, 5.5, 107.59, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P5_1', 43.36, 5.5, 109.56, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P5_2', 38.87, 5.5, 108.34, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P5_3', 43.03, 5.5, 101.79, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P5_4', 43.87, 5.5, 104.81, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P5', 42.55, 4.7, 108.6, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P5', 41.21, 4.7, 107.33, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P6', 13.48, 3.4, 131.5, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, -0.03, 0, -0.02)
part(ws, 'PalmLeaf_P6_0', 15.18, 5.5, 134.01, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P6_1', 16.47, 5.5, 136.0, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P6_2', 11.69, 5.5, 134.5, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P6_3', 11.8, 5.5, 130.2, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P6_4', 16.61, 5.5, 133.35, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P6', 15.49, 4.7, 136.42, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P6', 12.79, 4.7, 136.45, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P7', 62.31, 3.4, 153.35, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.06, 0, 0.03)
part(ws, 'PalmLeaf_P7_0', 68.23, 5.5, 150.77, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P7_1', 61.6, 5.5, 154.5, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P7_2', 61.18, 5.5, 153.4, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P7_3', 58.43, 5.5, 151.4, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P7_4', 64.03, 5.5, 149.6, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P7', 60.75, 4.7, 150.72, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P7', 61.87, 4.7, 151.69, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P8', -12.13, 3.4, 119.12, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.03, 0, 0.04)
part(ws, 'PalmLeaf_P8_0', -10.92, 5.5, 119.21, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P8_1', -13.28, 5.5, 123.61, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P8_2', -18.31, 5.5, 124.64, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P8_3', -18.2, 5.5, 118.44, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P8_4', -15.45, 5.5, 116.01, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P8', -15.78, 4.7, 123.79, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P8', -12.79, 4.7, 120.28, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P9', -26.32, 3.4, 105.45, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.03, 0, 0.01)
part(ws, 'PalmLeaf_P9_0', -18.24, 5.5, 106.82, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P9_1', -20.98, 5.5, 110.83, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P9_2', -24.64, 5.5, 109.92, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P9_3', -23.0, 5.5, 105.06, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P9_4', -24.33, 5.5, 105.03, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P9', -20.98, 4.7, 110.29, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P9', -21.94, 4.7, 109.58, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P10', 42.47, 3.4, 176.58, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, -0.02, 0, 0.04)
part(ws, 'PalmLeaf_P10_0', 45.36, 5.5, 171.04, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P10_1', 45.11, 5.5, 175.11, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P10_2', 43.78, 5.5, 177.21, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P10_3', 38.79, 5.5, 173.96, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P10_4', 42.89, 5.5, 173.85, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P10', 42.99, 4.7, 173.25, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P10', 43.91, 4.7, 174.93, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_P11', -16.03, 3.4, 147.27, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, -0.02, 0, 0.02)
part(ws, 'PalmLeaf_P11_0', -10.21, 5.5, 146.69, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_P11_1', -12.48, 5.5, 151.13, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_P11_2', -16.55, 5.5, 149.47, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_P11_3', -16.3, 5.5, 146.29, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_P11_4', -15.15, 5.5, 147.31, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_P11', -13.17, 4.7, 152.43, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_P11', -12.24, 4.7, 148.6, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'BeachRock_0', -7.59, 0.85, 108.25, 2.97, 2.7, 2.92, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.03, 0.14, 0.02)
part(ws, 'BeachRock_1', 43.8, 1.93, 186.84, 2.93, 3.08, 4.64, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.15, 0.19, -0.01)
part(ws, 'BeachRock_2', 88.03, 2.7, 160.36, 5.25, 3.77, 3.4, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.08, 0.13, -0.05)
part(ws, 'BeachRock_3', -13.55, 2.2, 125.94, 3.92, 2.69, 4.76, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.04, -0.14, 0.12)
part(ws, 'BeachRock_4', 81.89, 2.64, 171.24, 4.46, 3.49, 4.24, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.07, -0.14, 0.07)
part(ws, 'BeachRock_5', 91.67, 1.28, 93.32, 4.97, 2.96, 4.0, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.14, 0.01, 0.04)
part(ws, 'BeachRock_6', -21.29, 0.99, 142.23, 4.56, 2.33, 2.92, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.09, -0.14, -0.06)
part(ws, 'BeachRock_7', 30.78, 2.94, 126.93, 2.66, 3.37, 2.03, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.02, 0.12, 0.12)
part(ws, 'BeachRock_8', 85.93, 1.18, 191.24, 3.81, 1.95, 3.89, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.0, 0.15, 0.04)
part(ws, 'BeachRock_9', -41.23, 1.61, 130.65, 2.76, 1.89, 4.14, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.0, 0.15, 0.07)
part(ws, 'BeachRock_10', 9.63, 2.22, 153.78, 3.22, 3.77, 2.42, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.06, -0.02, 0.03)
part(ws, 'BeachRock_11', -30.36, 0.99, 167.65, 3.73, 2.28, 4.64, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.0, -0.07, 0.12)
part(ws, 'BeachRock_12', 54.86, 1.69, 175.4, 2.62, 3.52, 2.77, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.09, -0.04, 0.09)
part(ws, 'BeachRock_13', 10.95, 2.43, 106.41, 4.3, 1.82, 2.94, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.1, -0.02, -0.11)
do
local f = part(ws, 'Fire', 42, 1.5, 138, 1.6, 2.4, 1.6, {255, 140, 40}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)
light(f, {255, 150, 60}, 1.2, 22)
fx(f, {190, 190, 195}, 8, 0.8, 1.6, 1, 2.5, 0.4, 0.9, 0.3, 1)
end
part(ws, 'CampLog_0', 42.25, 1.0, 137.47, 2.2, 0.5, 0.5, {100, 66, 40}, Enum.Material.Wood, 0, true, Enum.PartType.Cylinder, 0, 0, 0.47)
part(ws, 'CampLog_1', 42.12, 1.0, 137.25, 2.2, 0.5, 0.5, {100, 66, 40}, Enum.Material.Wood, 0, true, Enum.PartType.Cylinder, 0, 0, -0.21)
part(ws, 'CampLog_2', 41.92, 1.0, 137.8, 2.2, 0.5, 0.5, {100, 66, 40}, Enum.Material.Wood, 0, true, Enum.PartType.Cylinder, 0, 0, -0.48)
part(ws, 'CampLog_3', 42.43, 1.0, 138.35, 2.2, 0.5, 0.5, {100, 66, 40}, Enum.Material.Wood, 0, true, Enum.PartType.Cylinder, 0, 0, -0.16)
part(ws, 'CampRing_0', 44.6, 0.85, 138.0, 1.1, 0.9, 1.1, {110, 108, 112}, Enum.Material.Rock, 0, true, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'CampRing_1', 43.29, 0.85, 140.26, 1.1, 0.9, 1.1, {110, 108, 112}, Enum.Material.Rock, 0, true, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'CampRing_2', 40.69, 0.85, 140.24, 1.1, 0.9, 1.1, {110, 108, 112}, Enum.Material.Rock, 0, true, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'CampRing_3', 39.4, 0.85, 137.98, 1.1, 0.9, 1.1, {110, 108, 112}, Enum.Material.Rock, 0, true, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'CampRing_4', 40.73, 0.85, 135.73, 1.1, 0.9, 1.1, {110, 108, 112}, Enum.Material.Rock, 0, true, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'CampRing_5', 43.33, 0.85, 135.77, 1.1, 0.9, 1.1, {110, 108, 112}, Enum.Material.Rock, 0, true, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'IsletRock_0', 229.81, 1.22, 40.67, 6.77, 2.91, 6.54, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.01, -0.12, -0.04)
part(ws, 'IsletRock_1', 228.24, 0.8, 39.01, 6.77, 2.72, 4.03, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.05, 0.06, -0.03)
part(ws, 'IsletRock_2', 226.15, 1.33, 38.88, 5.43, 2.89, 5.02, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.11, 0.14, -0.07)
part(ws, 'IsletRock_3', 228.52, 0.42, 38.32, 4.63, 2.46, 4.83, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.06, 0.02, -0.15)
part(ws, 'IsletRock_4', 228.42, 0.51, 38.68, 4.99, 2.22, 5.39, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.06, 0.03, 0.06)
do
local t1 = part(ws, 'LhTower1', 232, 2.0, 42, 9, 8, 9, {240, 238, 230}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder)
part(ws, 'LhTower2', 232, 5.5, 42, 7, 8, 7, {240, 238, 230}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder)
part(ws, 'LhTower3', 232, 8.0, 42, 5, 4, 5, {200, 60, 60}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder)
local b = part(ws, 'LhLight', 232, 10.5, 42, 2.2, 2.2, 2.2, {255, 240, 160}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)
light(b, {255, 230, 140}, 1.5, 40)
end
part(ws, 'LhRoof', 232, 11.2, 42, 6, 1.6, 6, {90, 90, 95}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'Coral_0', 28.98, -2.8, 59.14, 0.8, 1.4, 0.8, {255, 120, 150}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_0', 28.98, -2.0, 59.14, 1.3, 1.3, 1.3, {255, 120, 150}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Coral_1', -75.47, -2.8, 85.73, 0.8, 1.4, 0.8, {255, 120, 150}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_1', -75.47, -2.0, 85.73, 1.3, 1.3, 1.3, {255, 120, 150}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Coral_2', -50.36, -2.8, 71.4, 0.8, 1.4, 0.8, {255, 160, 90}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_2', -50.36, -2.0, 71.4, 1.3, 1.3, 1.3, {255, 160, 90}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Coral_3', 78.14, -2.8, 83.73, 0.8, 1.4, 0.8, {200, 110, 220}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_3', 78.14, -2.0, 83.73, 1.3, 1.3, 1.3, {200, 110, 220}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Coral_4', -25.03, -2.8, 42.25, 0.8, 1.4, 0.8, {255, 200, 120}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_4', -25.03, -2.0, 42.25, 1.3, 1.3, 1.3, {255, 200, 120}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Coral_5', -39.14, -2.8, 81.83, 0.8, 1.4, 0.8, {200, 110, 220}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_5', -39.14, -2.0, 81.83, 1.3, 1.3, 1.3, {200, 110, 220}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Coral_6', -74.13, -2.8, 54.3, 0.8, 1.4, 0.8, {255, 120, 150}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_6', -74.13, -2.0, 54.3, 1.3, 1.3, 1.3, {255, 120, 150}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Coral_7', -3.09, -2.8, 45.63, 0.8, 1.4, 0.8, {255, 200, 120}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_7', -3.09, -2.0, 45.63, 1.3, 1.3, 1.3, {255, 200, 120}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Coral_8', -48.2, -2.8, 39.15, 0.8, 1.4, 0.8, {255, 200, 120}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_8', -48.2, -2.0, 39.15, 1.3, 1.3, 1.3, {255, 200, 120}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Coral_9', -31.35, -2.8, 60.72, 0.8, 1.4, 0.8, {255, 200, 120}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'CoralHead_9', -31.35, -2.0, 60.72, 1.3, 1.3, 1.3, {255, 200, 120}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Kelp_0', 65.33, -2.0, 73.07, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.06, 0, 0.0)
part(ws, 'Kelp_1', 5.81, -2.0, 83.64, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.19, 0, 0.05)
part(ws, 'Kelp_2', 63.55, -2.0, 92.96, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.04, 0, -0.0)
part(ws, 'Kelp_3', 28.9, -2.0, 43.81, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.17, 0, 0.02)
part(ws, 'Kelp_4', 53.63, -2.0, 75.75, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.19, 0, 0.18)
part(ws, 'Kelp_5', 5.04, -2.0, 84.46, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.05, 0, 0.17)
part(ws, 'Kelp_6', 86.32, -2.0, 17.31, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.1, 0, -0.03)
part(ws, 'Kelp_7', 63.99, -2.0, 25.12, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.12, 0, 0.14)
part(ws, 'Kelp_8', 49.64, -2.0, 72.31, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.15, 0, 0.07)
part(ws, 'Kelp_9', 64.23, -2.0, 44.1, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.06, 0, 0.01)
part(ws, 'Kelp_10', 40.71, -2.0, 30.12, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.04, 0, 0.08)
part(ws, 'Kelp_11', -62.44, -2.0, 26.52, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.12, 0, 0.12)
part(ws, 'Kelp_12', 13.13, -2.0, 79.15, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.15, 0, -0.09)
part(ws, 'Kelp_13', -36.12, -2.0, 80.57, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.14, 0, 0.19)
part(ws, 'Kelp_14', 34.73, -2.0, 25.24, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.13, 0, 0.08)
part(ws, 'Kelp_15', 45.24, -2.0, 69.39, 0.3, 4.2, 0.3, {40, 130, 70}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.03, 0, 0.05)
part(ws, 'SeaRock_0', 80.84, -3.0, 92.1, 2.6, 2.27, 3.78, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.03, 0.16, -0.11)
part(ws, 'SeaRock_1', 2.44, -3.0, 51.29, 2.12, 2.03, 3.69, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.05, -0.19, 0.0)
part(ws, 'SeaRock_2', 72.78, -3.0, 18.3, 3.33, 1.8, 3.68, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.0, -0.05, 0.01)
part(ws, 'SeaRock_3', 73.31, -3.0, 72.25, 2.92, 2.04, 2.42, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.13, 0.02, -0.01)
part(ws, 'SeaRock_4', 76.46, -3.0, 28.69, 2.39, 2.63, 2.71, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.12, -0.12, -0.02)
part(ws, 'SeaRock_5', 81.48, -3.0, 92.63, 2.86, 2.32, 2.29, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.07, 0.1, -0.03)
part(ws, 'SeaRock_6', -6.26, -3.0, 47.69, 2.55, 2.03, 3.97, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.08, -0.06, -0.04)
part(ws, 'SeaRock_7', 28.48, -3.0, 12.42, 3.4, 2.34, 3.51, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.01, 0.02, 0.09)
part(ws, 'BuoyPole_route0', 0, 0.5, -100, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route0', 0, 4.6, -100, 2.4, 2.4, 2.4, {255, 214, 150}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route1', 0, 0.5, -400, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route1', 0, 4.6, -400, 2.4, 2.4, 2.4, {255, 214, 150}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route2', 0, 0.5, -700, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route2', 0, 4.6, -700, 2.4, 2.4, 2.4, {70, 220, 210}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route3', 0, 0.5, -1000, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route3', 0, 4.6, -1000, 2.4, 2.4, 2.4, {70, 220, 210}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route4', 0, 0.5, -1300, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route4', 0, 4.6, -1300, 2.4, 2.4, 2.4, {70, 220, 210}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route5', 0, 0.5, -1600, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route5', 0, 4.6, -1600, 2.4, 2.4, 2.4, {40, 100, 200}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route6', 0, 0.5, -1900, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route6', 0, 4.6, -1900, 2.4, 2.4, 2.4, {40, 100, 200}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route7', 0, 0.5, -2200, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route7', 0, 4.6, -2200, 2.4, 2.4, 2.4, {40, 100, 200}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route8', 0, 0.5, -2500, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route8', 0, 4.6, -2500, 2.4, 2.4, 2.4, {255, 100, 50}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route9', 0, 0.5, -2800, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route9', 0, 4.6, -2800, 2.4, 2.4, 2.4, {255, 100, 50}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route10', 0, 0.5, -3100, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route10', 0, 4.6, -3100, 2.4, 2.4, 2.4, {255, 100, 50}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route11', 0, 0.5, -3400, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route11', 0, 4.6, -3400, 2.4, 2.4, 2.4, {255, 100, 50}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route12', 0, 0.5, -3700, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route12', 0, 4.6, -3700, 2.4, 2.4, 2.4, {200, 235, 255}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route13', 0, 0.5, -4000, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route13', 0, 4.6, -4000, 2.4, 2.4, 2.4, {200, 235, 255}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route14', 0, 0.5, -4300, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route14', 0, 4.6, -4300, 2.4, 2.4, 2.4, {200, 235, 255}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'BuoyPole_route15', 0, 0.5, -4600, 0.6, 8, 0.6, {90, 90, 100}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'BuoyBall_route15', 0, 4.6, -4600, 2.4, 2.4, 2.4, {120, 90, 200}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
part(ws, 'ZoneDisc_sunshall', 0, -0.35, 0, 216.0, 0.3, 216.0, {255, 214, 150}, Enum.Material.SmoothPlastic, 0.55, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'ZoneRegion_sunshall', 0, 0, 0, 360, 80, 360, {255, 255, 255}, Enum.Material.SmoothPlastic, 1.0, false, Enum.PartType.Block, 0, 0, 0)
do local b = part(ws, 'BuoyBall_sunshall', 0, 4.6, 0, 2.4, 2.4, 2.4, {255, 214, 150}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
billboard(b, [===[Sunshall Cove]===], {255, 214, 150}, 6)
end
part(ws, 'ZoneDisc_whisper', 0, -0.35, -1000, 216.0, 0.3, 216.0, {70, 220, 210}, Enum.Material.SmoothPlastic, 0.55, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'ZoneRegion_whisper', 0, 0, -1000, 360, 80, 360, {255, 255, 255}, Enum.Material.SmoothPlastic, 1.0, false, Enum.PartType.Block, 0, 0, 0)
do local b = part(ws, 'BuoyBall_whisper', 0, 4.6, -1000, 2.4, 2.4, 2.4, {70, 220, 210}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
billboard(b, [===[Whisper Shallows]===], {70, 220, 210}, 6)
end
part(ws, 'ZoneDisc_drop', 0, -0.35, -2000, 216.0, 0.3, 216.0, {40, 100, 200}, Enum.Material.SmoothPlastic, 0.55, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'ZoneRegion_drop', 0, 0, -2000, 360, 80, 360, {255, 255, 255}, Enum.Material.SmoothPlastic, 1.0, false, Enum.PartType.Block, 0, 0, 0)
do local b = part(ws, 'BuoyBall_drop', 0, 4.6, -2000, 2.4, 2.4, 2.4, {40, 100, 200}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
billboard(b, [===[The Drop]===], {40, 100, 200}, 6)
end
part(ws, 'ZoneDisc_ember', 0, -0.35, -3000, 216.0, 0.3, 216.0, {255, 100, 50}, Enum.Material.SmoothPlastic, 0.55, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'ZoneRegion_ember', 0, 0, -3000, 360, 80, 360, {255, 255, 255}, Enum.Material.SmoothPlastic, 1.0, false, Enum.PartType.Block, 0, 0, 0)
do local b = part(ws, 'BuoyBall_ember', 0, 4.6, -3000, 2.4, 2.4, 2.4, {255, 100, 50}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
billboard(b, [===[Ember Falls]===], {255, 100, 50}, 6)
end
part(ws, 'ZoneDisc_frost', 0, -0.35, -4000, 216.0, 0.3, 216.0, {200, 235, 255}, Enum.Material.SmoothPlastic, 0.55, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'ZoneRegion_frost', 0, 0, -4000, 360, 80, 360, {255, 255, 255}, Enum.Material.SmoothPlastic, 1.0, false, Enum.PartType.Block, 0, 0, 0)
do local b = part(ws, 'BuoyBall_frost', 0, 4.6, -4000, 2.4, 2.4, 2.4, {200, 235, 255}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
billboard(b, [===[Frostreach]===], {200, 235, 255}, 6)
end
part(ws, 'ZoneDisc_abyss', 0, -0.35, -5000, 216.0, 0.3, 216.0, {120, 90, 200}, Enum.Material.SmoothPlastic, 0.55, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'ZoneRegion_abyss', 0, 0, -5000, 360, 80, 360, {255, 255, 255}, Enum.Material.SmoothPlastic, 1.0, false, Enum.PartType.Block, 0, 0, 0)
do local b = part(ws, 'BuoyBall_abyss', 0, 4.6, -5000, 2.4, 2.4, 2.4, {120, 90, 200}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
billboard(b, [===[Abyssal Trench]===], {120, 90, 200}, 6)
end
part(ws, 'ZoneDisc_hidden_isles', 800, -0.35, -3000, 108.0, 0.3, 108.0, {240, 255, 240}, Enum.Material.SmoothPlastic, 0.55, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'ZoneRegion_hidden_isles', 800, 0, -3000, 180, 80, 180, {255, 255, 255}, Enum.Material.SmoothPlastic, 1.0, false, Enum.PartType.Block, 0, 0, 0)
do local b = part(ws, 'BuoyBall_hidden_isles', 800, 4.6, -3000, 2.4, 2.4, 2.4, {240, 255, 240}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
billboard(b, [===[Hidden Isle of Whispers]===], {240, 255, 240}, 6)
end
part(ws, 'ZoneDisc_sunken_grotto', 800, -0.35, -2000, 108.0, 0.3, 108.0, {120, 220, 200}, Enum.Material.SmoothPlastic, 0.55, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'ZoneRegion_sunken_grotto', 800, 0, -2000, 180, 80, 180, {255, 255, 255}, Enum.Material.SmoothPlastic, 1.0, false, Enum.PartType.Block, 0, 0, 0)
do local b = part(ws, 'BuoyBall_sunken_grotto', 800, 4.6, -2000, 2.4, 2.4, 2.4, {120, 220, 200}, Enum.Material.Neon, 0, true, Enum.PartType.Ball)
billboard(b, [===[The Sunken Grotto]===], {120, 220, 200}, 6)
end
part(ws, 'Seagrass_0', 102.71, -2.0, -857.15, 0.3, 4.13, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.1, 0, -0.21)
part(ws, 'Seagrass_1', -146.6, -2.0, -991.16, 0.3, 3.4, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.2, 0, 0.15)
part(ws, 'Seagrass_2', 96.06, -2.0, -852.98, 0.3, 3.73, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.02, 0, -0.17)
part(ws, 'Seagrass_3', -58.11, -2.0, -1151.49, 0.3, 3.28, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.17, 0, 0.18)
part(ws, 'Seagrass_4', -154.16, -2.0, -1145.22, 0.3, 4.44, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.13, 0, 0.01)
part(ws, 'Seagrass_5', 74.38, -2.0, -885.92, 0.3, 3.17, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.17, 0, 0.23)
part(ws, 'Seagrass_6', -82.56, -2.0, -930.57, 0.3, 3.44, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.13, 0, -0.13)
part(ws, 'Seagrass_7', 115.58, -2.0, -1059.96, 0.3, 2.58, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.13, 0, -0.16)
part(ws, 'Seagrass_8', -99.65, -2.0, -1123.61, 0.3, 3.45, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.06, 0, 0.01)
part(ws, 'Seagrass_9', -0.33, -2.0, -1090.06, 0.3, 3.96, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.01, 0, 0.14)
part(ws, 'Seagrass_10', -65.7, -2.0, -884.61, 0.3, 3.13, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.13, 0, 0.18)
part(ws, 'Seagrass_11', 25.71, -2.0, -1046.89, 0.3, 4.24, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.17, 0, 0.02)
part(ws, 'Seagrass_12', 20.08, -2.0, -902.13, 0.3, 3.67, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.03, 0, -0.02)
part(ws, 'Seagrass_13', 98.48, -2.0, -903.44, 0.3, 4.11, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.04, 0, 0.24)
part(ws, 'Seagrass_14', -81.82, -2.0, -1143.64, 0.3, 4.0, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.17, 0, -0.12)
part(ws, 'Seagrass_15', -40.24, -2.0, -1078.29, 0.3, 4.37, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.23, 0, 0.1)
part(ws, 'Seagrass_16', 41.88, -2.0, -931.96, 0.3, 2.73, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.03, 0, 0.08)
part(ws, 'Seagrass_17', -46.19, -2.0, -877.54, 0.3, 4.42, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.02, 0, 0.22)
part(ws, 'Seagrass_18', 41.75, -2.0, -1148.91, 0.3, 4.36, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.18, 0, -0.15)
part(ws, 'Seagrass_19', 48.39, -2.0, -1005.93, 0.3, 3.08, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.17, 0, -0.22)
part(ws, 'Seagrass_20', -94.53, -2.0, -1068.19, 0.3, 3.79, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.01, 0, -0.12)
part(ws, 'Seagrass_21', 123.4, -2.0, -927.13, 0.3, 2.84, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.07, 0, 0.04)
part(ws, 'Seagrass_22', -83.84, -2.0, -897.53, 0.3, 3.58, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.14, 0, -0.05)
part(ws, 'Seagrass_23', -132.01, -2.0, -1149.94, 0.3, 3.33, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.03, 0, -0.03)
part(ws, 'Seagrass_24', 39.21, -2.0, -1105.1, 0.3, 2.83, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.15, 0, 0.13)
part(ws, 'Seagrass_25', -32.05, -2.0, -845.26, 0.3, 3.81, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.02, 0, -0.24)
part(ws, 'Seagrass_26', -136.22, -2.0, -919.08, 0.3, 4.46, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.03, 0, 0.01)
part(ws, 'Seagrass_27', -82.17, -2.0, -898.22, 0.3, 4.24, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.18, 0, 0.15)
part(ws, 'Seagrass_28', -103.77, -2.0, -983.96, 0.3, 2.78, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.16, 0, -0.21)
part(ws, 'Seagrass_29', 63.35, -2.0, -958.63, 0.3, 3.84, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.08, 0, 0.22)
part(ws, 'Seagrass_30', -133.37, -2.0, -941.87, 0.3, 2.54, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.12, 0, -0.19)
part(ws, 'Seagrass_31', 120.85, -2.0, -858.12, 0.3, 3.69, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.04, 0, 0.25)
part(ws, 'Seagrass_32', -102.52, -2.0, -921.11, 0.3, 2.52, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.24, 0, 0.21)
part(ws, 'Seagrass_33', -103.83, -2.0, -1013.38, 0.3, 2.69, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.08, 0, 0.13)
part(ws, 'Seagrass_34', -109.08, -2.0, -854.56, 0.3, 4.37, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.01, 0, -0.22)
part(ws, 'Seagrass_35', -158.73, -2.0, -991.21, 0.3, 2.8, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.22, 0, -0.24)
part(ws, 'Seagrass_36', 34.73, -2.0, -856.51, 0.3, 3.26, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.06, 0, -0.03)
part(ws, 'Seagrass_37', -121.12, -2.0, -1087.22, 0.3, 3.15, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.15, 0, 0.17)
part(ws, 'Seagrass_38', 145.04, -2.0, -1019.59, 0.3, 3.39, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.22, 0, -0.1)
part(ws, 'Seagrass_39', -17.3, -2.0, -960.94, 0.3, 3.44, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.18, 0, 0.16)
part(ws, 'Seagrass_40', -127.47, -2.0, -984.67, 0.3, 2.91, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.24, 0, -0.1)
part(ws, 'Seagrass_41', 153.19, -2.0, -841.55, 0.3, 2.95, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.1, 0, -0.09)
part(ws, 'Seagrass_42', 96.03, -2.0, -1086.45, 0.3, 2.76, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.08, 0, 0.02)
part(ws, 'Seagrass_43', -93.55, -2.0, -984.29, 0.3, 4.32, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.02, 0, -0.06)
part(ws, 'Seagrass_44', -75.63, -2.0, -883.0, 0.3, 3.4, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.16, 0, -0.1)
part(ws, 'Seagrass_45', 75.18, -2.0, -896.07, 0.3, 3.1, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.17, 0, 0.09)
part(ws, 'Seagrass_46', -119.99, -2.0, -844.24, 0.3, 3.77, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.09, 0, 0.06)
part(ws, 'Seagrass_47', 76.13, -2.0, -904.12, 0.3, 3.53, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.03, 0, 0.17)
part(ws, 'Seagrass_48', -87.73, -2.0, -938.83, 0.3, 4.26, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.19, 0, 0.22)
part(ws, 'Seagrass_49', 3.48, -2.0, -903.66, 0.3, 4.16, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.06, 0, -0.07)
part(ws, 'Seagrass_50', 156.8, -2.0, -919.6, 0.3, 3.55, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.24, 0, 0.01)
part(ws, 'Seagrass_51', -36.03, -2.0, -874.47, 0.3, 3.23, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.22, 0, -0.13)
part(ws, 'Seagrass_52', 27.07, -2.0, -1046.01, 0.3, 3.99, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.19, 0, -0.2)
part(ws, 'Seagrass_53', -91.1, -2.0, -1003.03, 0.3, 3.29, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.25, 0, -0.17)
part(ws, 'Seagrass_54', 4.18, -2.0, -1040.32, 0.3, 3.59, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.24, 0, -0.19)
part(ws, 'Seagrass_55', -32.79, -2.0, -1013.64, 0.3, 3.19, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.01, 0, 0.19)
part(ws, 'Seagrass_56', -128.49, -2.0, -1084.8, 0.3, 3.12, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.25, 0, 0.2)
part(ws, 'Seagrass_57', 83.76, -2.0, -949.16, 0.3, 3.42, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.04, 0, 0.07)
part(ws, 'Seagrass_58', 104.55, -2.0, -1098.98, 0.3, 4.1, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.18, 0, -0.08)
part(ws, 'Seagrass_59', -102.04, -2.0, -1132.29, 0.3, 2.97, 0.3, {45, 140, 80}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.03, 0, 0.23)
part(ws, 'Shallow_0', 124.75, 0.04, -874.55, 26.81, 0.2, 33.71, {120, 230, 220}, Enum.Material.Glass, 0.75, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Shallow_1', 76.08, 0.04, -1110.72, 18.33, 0.2, 25.42, {120, 230, 220}, Enum.Material.Glass, 0.75, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Shallow_2', 112.92, 0.04, -1131.19, 25.97, 0.2, 25.18, {120, 230, 220}, Enum.Material.Glass, 0.75, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Shallow_3', -44.54, 0.04, -1120.44, 18.75, 0.2, 20.9, {120, 230, 220}, Enum.Material.Glass, 0.75, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Shallow_4', 42.09, 0.04, -1073.28, 26.72, 0.2, 21.97, {120, 230, 220}, Enum.Material.Glass, 0.75, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Shallow_5', -117.31, 0.04, -864.64, 18.18, 0.2, 20.27, {120, 230, 220}, Enum.Material.Glass, 0.75, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Rock_0_-1000_0', 5.13, 0.53, -1007.86, 3.3, 2.31, 2.68, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.11, -0.17, 0.08)
part(ws, 'Rock_0_-1000_1', -7.45, 0.04, -1002.23, 3.74, 2.7, 4.47, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.07, 0.02, -0.07)
part(ws, 'Rock_0_-1000_2', -0.91, 0.76, -1004.12, 2.78, 4.12, 4.32, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.09, -0.08, -0.07)
part(ws, 'Rock_0_-1000_3', -11.56, -1.79, -994.75, 2.59, 3.78, 4.09, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.11, -0.07, 0.04)
part(ws, 'Rock_0_-1000_4', 4.62, 0.23, -996.71, 4.93, 4.61, 4.98, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.05, -0.05, -0.15)
part(ws, 'Rock_0_-1000_5', -6.42, 0.58, -994.37, 4.35, 2.03, 3.24, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.06, 0.02, 0.01)
part(ws, 'Rock_0_-1000_6', -15.22, -0.5, -992.55, 3.15, 4.74, 4.86, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.13, -0.11, -0.14)
part(ws, 'Rock_0_-1000_7', -3.72, 0.06, -989.96, 3.37, 4.03, 3.61, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.11, 0.15, -0.08)
part(ws, 'Rock_0_-1000_8', 7.11, -1.49, -1015.71, 4.38, 5.0, 4.62, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.02, 0.13, 0.07)
part(ws, 'Rock_0_-1000_9', 6.97, -0.57, -990.21, 3.11, 4.03, 4.38, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.06, -0.09, 0.13)
part(ws, 'IsletBase', 60, -1.0, -1030, 26, 2, 20, {200, 180, 140}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'IsletSand1', 60, 0.48, -1030, 20, 0.15, 16, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'IsletSand2', 60, 0.53, -1030, 14, 0.2, 12, {232, 214, 160}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'PalmTrunk_Isle', 60.22, 3.4, -1029.36, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.03, 0, -0.07)
part(ws, 'PalmLeaf_Isle_0', 65.39, 5.5, -1030.52, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_Isle_1', 60.66, 5.5, -1026.71, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_Isle_2', 55.77, 5.5, -1031.48, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_Isle_3', 59.58, 5.5, -1033.98, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_Isle_4', 58.61, 5.5, -1034.31, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_Isle', 62.38, 4.7, -1029.93, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_Isle', 61.13, 4.7, -1032.07, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'IsletRock_0', 61.21, 0.79, -1030.82, 2.5, 2, 2.5, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.12, -0.12, -0.03)
part(ws, 'IsletRock_1', 61.87, 1.03, -1028.57, 2.5, 2, 2.5, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.15, 0.03, -0.12)
part(ws, 'IsletRock_2', 58.78, 1.26, -1030.98, 2.5, 2, 2.5, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.06, 0.02, 0.1)
part(ws, 'ArchPillar1', -45, -1.0, -1000, 5, 14, 5, {120, 118, 124}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'ArchPillar2', -15, -1.0, -1000, 5, 14, 5, {120, 118, 124}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'ArchBeam', -30, 5.5, -1000, 36, 6, 6, {120, 118, 124}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Cliff_0', 150.0, 5.37, -2000.0, 19.15, 16.73, 15.58, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.06, 0.15, -0.07)
part(ws, 'Cliff_1', 145.64, 5.97, -1990.43, 19.53, 17.94, 11.2, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.05, 0.06, -0.03)
part(ws, 'Cliff_2', 132.82, 5.94, -1981.41, 18.49, 17.88, 13.6, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.09, 0.06, -0.07)
part(ws, 'Cliff_3', 112.28, 9.96, -1973.48, 27.18, 25.93, 17.98, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.09, 0.02, 0.07)
part(ws, 'Cliff_4', 85.21, 6.13, -1967.08, 19.86, 18.26, 16.35, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.09, -0.08, -0.05)
part(ws, 'Cliff_5', 53.19, 6.96, -1962.6, 27.06, 19.93, 19.72, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.08, -0.08, -0.05)
part(ws, 'Cliff_6', 18.08, 8.39, -1960.29, 21.8, 22.78, 14.79, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.04, -0.15, 0.09)
part(ws, 'Cliff_7', -18.08, 9.55, -1960.29, 16.66, 25.1, 10.68, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.05, -0.16, -0.06)
part(ws, 'Cliff_8', -53.19, 6.01, -1962.6, 23.56, 18.03, 10.3, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.04, -0.19, 0.07)
part(ws, 'Cliff_9', -85.21, 5.47, -1967.08, 22.98, 16.94, 15.21, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.02, -0.07, 0.05)
part(ws, 'Cliff_10', -112.28, 6.09, -1973.48, 21.01, 18.19, 16.76, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.04, 0.17, -0.0)
part(ws, 'Cliff_11', -132.82, 7.14, -1981.41, 24.75, 20.29, 13.42, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.03, 0.02, -0.05)
part(ws, 'Cliff_12', -145.64, 8.17, -1990.43, 20.82, 22.34, 14.03, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.07, -0.17, 0.03)
part(ws, 'Cliff_13', -150.0, 8.79, -2000.0, 16.29, 23.58, 14.66, {70, 72, 80}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.04, 0.06, -0.09)
part(ws, 'FogWisp_0', -113.37, 5.3, -2027.04, 34.28, 2, 21.04, {230, 240, 250}, Enum.Material.SmoothPlastic, 0.72, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'FogWisp_1', -46.1, 2.61, -2107.01, 28.45, 2, 21.03, {230, 240, 250}, Enum.Material.SmoothPlastic, 0.72, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'FogWisp_2', -70.96, 3.07, -1872.58, 20.18, 2, 12.54, {230, 240, 250}, Enum.Material.SmoothPlastic, 0.72, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'FogWisp_3', 150.66, 4.37, -2091.65, 38.04, 2, 25.24, {230, 240, 250}, Enum.Material.SmoothPlastic, 0.72, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'FogWisp_4', -117.67, 2.99, -1971.4, 23.59, 2, 22.51, {230, 240, 250}, Enum.Material.SmoothPlastic, 0.72, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'FogWisp_5', -68.43, 6.11, -1984.26, 24.02, 2, 17.55, {230, 240, 250}, Enum.Material.SmoothPlastic, 0.72, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'FogWisp_6', 111.79, 6.37, -1969.78, 34.77, 2, 20.02, {230, 240, 250}, Enum.Material.SmoothPlastic, 0.72, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'FogWisp_7', 65.52, 4.45, -1923.77, 39.57, 2, 15.34, {230, 240, 250}, Enum.Material.SmoothPlastic, 0.72, false, Enum.PartType.Block, 0, 0, 0)
do
part(ws, 'WreckHull', -90, -0.5, -2010, 20, 5, 8, {90, 62, 40}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0.45, 0.25, 0)
part(ws, 'WreckDeck', -90, 1.2, -2010, 18, 1, 7, {120, 88, 55}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0.45, 0.25, 0)
part(ws, 'WreckMast', -95, 2.5, -2015, 1.4, 14, 1.4, {100, 70, 45}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0, 0, 0.2)
part(ws, 'WreckBow', -81, -1.0, -2008, 6, 3, 5, {80, 55, 35}, Enum.Material.Wood, 0, true, Enum.PartType.Wedge, 0.3, 0, 0)
end
part(ws, 'WreckPlank_0', -79.16, -0.6, -2006.15, 5.35, 0.4, 1.24, {110, 78, 48}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0.36, 0.24, -0.31)
part(ws, 'WreckPlank_1', -91.12, -0.6, -2014.47, 5.32, 0.4, 1.54, {110, 78, 48}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0.12, -0.03, -0.05)
part(ws, 'WreckPlank_2', -77.53, -0.6, -2004.33, 5.16, 0.4, 1.46, {110, 78, 48}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0.19, 0.13, -0.22)
part(ws, 'WreckPlank_3', -79.1, -0.6, -2010.57, 5.09, 0.4, 0.85, {110, 78, 48}, Enum.Material.Wood, 0, true, Enum.PartType.Block, -0.11, 0.03, -0.07)
part(ws, 'WreckPlank_4', -95.2, -0.6, -2016.54, 5.1, 0.4, 1.02, {110, 78, 48}, Enum.Material.Wood, 0, true, Enum.PartType.Block, 0.21, 0.02, -0.37)
part(ws, 'WreckPlank_5', -77.44, -0.6, -2005.04, 5.74, 0.4, 1.56, {110, 78, 48}, Enum.Material.Wood, 0, true, Enum.PartType.Block, -0.23, 0.17, -0.49)
part(ws, 'WreckAnchor', -100, -1.0, -2004, 2.2, 3, 2.2, {90, 90, 95}, Enum.Material.Metal, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'WreckAnchorArm1', -100, 0.2, -2004, 1, 1, 4, {90, 90, 95}, Enum.Material.Metal, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'WreckAnchorArm2', -100, 0.2, -2004, 4, 1, 1, {90, 90, 95}, Enum.Material.Metal, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DeepArchP1', 60, -1.0, -1990, 5, 16, 5, {80, 82, 90}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DeepArchP2', 90, -1.0, -1990, 5, 16, 5, {80, 82, 90}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'DeepArchBeam', 75, 6.5, -1990, 36, 6, 6, {80, 82, 90}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'VolcBase_0', 46.0, -0.5, -3000.0, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0.0)
part(ws, 'VolcBase_1', 39.84, -0.5, -2977.0, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0.52)
part(ws, 'VolcBase_2', 23.0, -0.5, -2960.16, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 1.05)
part(ws, 'VolcBase_3', 0.0, -0.5, -2954.0, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 1.57)
part(ws, 'VolcBase_4', -23.0, -0.5, -2960.16, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 2.09)
part(ws, 'VolcBase_5', -39.84, -0.5, -2977.0, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 2.62)
part(ws, 'VolcBase_6', -46.0, -0.5, -3000.0, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 3.14)
part(ws, 'VolcBase_7', -39.84, -0.5, -3023.0, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 3.67)
part(ws, 'VolcBase_8', -23.0, -0.5, -3039.84, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 4.19)
part(ws, 'VolcBase_9', -0.0, -0.5, -3046.0, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 4.71)
part(ws, 'VolcBase_10', 23.0, -0.5, -3039.84, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 5.24)
part(ws, 'VolcBase_11', 39.84, -0.5, -3023.0, 18, 6, 18, {60, 40, 40}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 5.76)
part(ws, 'VolcLay0_0', 34.0, 4.5, -3000.0, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0.0)
part(ws, 'VolcLay0_1', 17.0, 4.5, -2970.56, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 1.05)
part(ws, 'VolcLay0_2', -17.0, 4.5, -2970.56, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 2.09)
part(ws, 'VolcLay0_3', -34.0, 4.5, -3000.0, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 3.14)
part(ws, 'VolcLay0_4', -17.0, 4.5, -3029.44, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 4.19)
part(ws, 'VolcLay0_5', 17.0, 4.5, -3029.44, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 5.24)
part(ws, 'VolcLay1_0', 22.93, 7.5, -2992.91, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0.3)
part(ws, 'VolcLay1_1', 5.32, 7.5, -2976.6, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 1.35)
part(ws, 'VolcLay1_2', -17.61, 7.5, -2983.69, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 2.39)
part(ws, 'VolcLay1_3', -22.93, 7.5, -3007.09, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 3.44)
part(ws, 'VolcLay1_4', -5.32, 7.5, -3023.4, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 4.49)
part(ws, 'VolcLay1_5', 17.61, 7.5, -3016.31, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 5.54)
part(ws, 'VolcLay2_0', 12.38, 10.5, -2991.53, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0.6)
part(ws, 'VolcLay2_1', -1.14, 10.5, -2985.04, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 1.65)
part(ws, 'VolcLay2_2', -13.52, 10.5, -2993.51, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 2.69)
part(ws, 'VolcLay2_3', -12.38, 10.5, -3008.47, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 3.74)
part(ws, 'VolcLay2_4', 1.14, 10.5, -3014.96, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 4.79)
part(ws, 'VolcLay2_5', 13.52, 10.5, -3006.49, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 5.84)
part(ws, 'VolcLay3_0', 4.97, 13.5, -2993.73, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0.9)
part(ws, 'VolcLay3_1', -2.94, 13.5, -2992.56, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 1.95)
part(ws, 'VolcLay3_2', -7.91, 13.5, -2998.83, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 2.99)
part(ws, 'VolcLay3_3', -4.97, 13.5, -3006.27, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 4.04)
part(ws, 'VolcLay3_4', 2.94, 13.5, -3007.44, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 5.09)
part(ws, 'VolcLay3_5', 7.91, 13.5, -3001.17, 9.6, 6, 9.6, {50, 34, 34}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 6.14)
part(ws, 'CraterRim1', -6, 13.5, -3000, 8, 3, 8, {70, 45, 45}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'CraterRim2', 6, 13.5, -3000, 8, 3, 8, {70, 45, 45}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'LavaPool', 0, 14.2, -3000, 16, 1, 16, {255, 120, 30}, Enum.Material.Neon, 0, false, Enum.PartType.Cylinder, 0, 0, 0)
do local b = part(ws, 'LavaGlow', 0, 14.6, -3000, 2, 2, 2, {255, 150, 40}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)
light(b, {255, 120, 30}, 2.2, 80)
fx(b, {255, 130, 40}, 6, 0.7, 1.4, 0.6, 1.8, 0.3, 0.8, 0.2, 1)
end
part(ws, 'LavaCrack_0', -30.34, 0.5, -3046.17, 6.72, 0.2, 2.16, {255, 110, 30}, Enum.Material.Neon, 0, false, Enum.PartType.Block, 0, 0.84, 0)
part(ws, 'LavaCrack_1', 67.75, 0.5, -2964.91, 6.98, 0.2, 1.11, {255, 110, 30}, Enum.Material.Neon, 0, false, Enum.PartType.Block, 0, 1.65, 0)
part(ws, 'LavaCrack_2', -32.78, 0.5, -3032.7, 3.03, 0.2, 1.59, {255, 110, 30}, Enum.Material.Neon, 0, false, Enum.PartType.Block, 0, 0.28, 0)
part(ws, 'LavaCrack_3', -18.16, 0.5, -2964.27, 5.76, 0.2, 2.11, {255, 110, 30}, Enum.Material.Neon, 0, false, Enum.PartType.Block, 0, 0.0, 0)
part(ws, 'LavaCrack_4', -62.34, 0.5, -3067.77, 5.86, 0.2, 1.94, {255, 110, 30}, Enum.Material.Neon, 0, false, Enum.PartType.Block, 0, 1.9, 0)
part(ws, 'LavaCrack_5', -67.39, 0.5, -3001.46, 6.08, 0.2, 1.89, {255, 110, 30}, Enum.Material.Neon, 0, false, Enum.PartType.Block, 0, 0.32, 0)
part(ws, 'FallCliff', 150, 4, -3010, 30, 20, 10, {90, 70, 70}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'FallWater', 150, 2, -3010, 2.5, 18, 6, {170, 220, 240}, Enum.Material.Glass, 0.45, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'FallMist1', 150, -1, -3010, 12, 2, 8, {220, 235, 245}, Enum.Material.SmoothPlastic, 0.6, false, Enum.PartType.Block, 0, 0, 0)
do local m = part(ws, 'FallMistFX', 150, -1.2, -3010, 1, 1, 1, {255, 255, 255}, Enum.Material.SmoothPlastic, 1, false, Enum.PartType.Ball)
fx(m, {220, 235, 245}, 10, 0.8, 1.6, 1, 2.5, 1.5, 3, 0.35, 1)
end
part(ws, 'Rock_0_-3000_0', 8.06, 0.81, -3011.51, 2.47, 2.6, 2.66, {90, 60, 55}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.14, 0.01, 0.0)
part(ws, 'Rock_0_-3000_1', -3.33, 0.71, -3000.65, 4.69, 4.9, 3.2, {90, 60, 55}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.03, -0.06, -0.13)
part(ws, 'Rock_0_-3000_2', -11.23, -0.88, -3006.35, 2.12, 4.55, 2.02, {90, 60, 55}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.06, -0.04, 0.08)
part(ws, 'Rock_0_-3000_3', 13.83, -0.12, -2989.8, 3.01, 3.05, 4.44, {90, 60, 55}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.12, -0.14, -0.02)
part(ws, 'Rock_0_-3000_4', 1.82, -1.15, -3011.86, 3.81, 4.44, 3.42, {90, 60, 55}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.03, -0.13, 0.06)
part(ws, 'Rock_0_-3000_5', -12.33, -0.07, -2998.46, 4.2, 4.69, 2.59, {90, 60, 55}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.0, 0.14, 0.0)
part(ws, 'Rock_0_-3000_6', -13.64, -1.24, -2998.97, 4.44, 4.58, 3.78, {90, 60, 55}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.0, -0.19, -0.03)
part(ws, 'Rock_0_-3000_7', 9.28, 0.03, -3006.63, 2.94, 3.27, 4.9, {90, 60, 55}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.03, -0.03, 0.1)
part(ws, 'Iceberg0_0', -104.72, -1.01, -3878.16, 8.91, 7.6, 12.55, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.12, 0.06, 0.04)
part(ws, 'Iceberg0_1', -111.45, -0.84, -3873.91, 15.49, 8.44, 16.08, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.0, -0.1, -0.11)
part(ws, 'Iceberg0_2', -103.48, 0.03, -3871.25, 8.15, 10.38, 15.15, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.09, 0.07, -0.08)
part(ws, 'Iceberg0_3', -111.55, 0.37, -3884.77, 9.63, 7.34, 12.67, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.11, 0.09, 0.04)
part(ws, 'Iceberg0_4', -104.53, 0.25, -3886.24, 8.6, 11.99, 9.2, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.12, 0.03, 0.01)
part(ws, 'Iceberg1_0', -147.3, -0.16, -4108.23, 10.33, 10.5, 9.43, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.09, -0.03, -0.03)
part(ws, 'Iceberg1_1', -142.79, 0.32, -4118.24, 14.45, 9.16, 16.24, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.09, -0.01, 0.05)
part(ws, 'Iceberg1_2', -144.42, -1.17, -4110.34, 13.88, 9.77, 9.75, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.07, 0.14, -0.02)
part(ws, 'Iceberg1_3', -147.41, -1.45, -4119.31, 13.44, 11.98, 14.9, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.03, 0.12, -0.07)
part(ws, 'Iceberg2_0', -77.63, 0.65, -4010.24, 10.01, 11.66, 11.62, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.11, 0.06, 0.07)
part(ws, 'Iceberg2_1', -84.59, 0.69, -3999.28, 17.66, 10.35, 17.18, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.06, -0.13, 0.03)
part(ws, 'Iceberg2_2', -88.86, 0.77, -4006.46, 10.35, 8.2, 12.18, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.01, -0.14, 0.09)
part(ws, 'Iceberg2_3', -81.08, 0.95, -4010.53, 9.05, 7.52, 9.08, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.1, -0.09, 0.03)
part(ws, 'Iceberg2_4', -91.16, -1.06, -4010.76, 9.09, 11.05, 8.02, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.11, -0.11, -0.05)
part(ws, 'Iceberg3_0', 124.16, 0.52, -3961.88, 10.89, 9.4, 16.61, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.09, -0.09, 0.0)
part(ws, 'Iceberg3_1', 122.82, -1.34, -3974.02, 16.0, 10.39, 17.04, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.09, -0.1, -0.07)
part(ws, 'Iceberg3_2', 123.98, -0.19, -3967.01, 11.78, 8.93, 17.0, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.07, -0.01, -0.03)
part(ws, 'Iceberg3_3', 115.65, -1.47, -3972.77, 9.71, 11.06, 13.2, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.04, 0.05, -0.06)
part(ws, 'Iceberg3_4', 123.13, -0.42, -3964.3, 8.7, 10.23, 14.14, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.1, 0.04, -0.0)
part(ws, 'Iceberg4_0', -75.05, -0.81, -3952.27, 15.48, 6.53, 14.13, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.03, -0.13, -0.03)
part(ws, 'Iceberg4_1', -81.13, -0.06, -3962.37, 12.53, 9.43, 8.48, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.02, 0.06, -0.07)
part(ws, 'Iceberg4_2', -73.32, 0.82, -3954.65, 14.02, 8.33, 16.44, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.01, -0.15, 0.06)
part(ws, 'Iceberg4_3', -71.86, -0.8, -3963.62, 16.29, 7.83, 16.16, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.09, -0.01, -0.11)
part(ws, 'Iceberg4_4', -74.79, -0.89, -3954.53, 9.27, 8.53, 17.9, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.1, -0.01, -0.03)
part(ws, 'Iceberg5_0', 26.35, -0.74, -4042.52, 13.62, 7.05, 14.61, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.09, 0.02, -0.08)
part(ws, 'Iceberg5_1', 22.7, -0.05, -4034.93, 12.42, 9.44, 10.48, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.1, 0.07, -0.0)
part(ws, 'Iceberg5_2', 21.6, -1.44, -4034.35, 13.99, 9.0, 14.69, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, -0.11, 0.08, 0.07)
part(ws, 'Iceberg5_3', 22.48, -1.47, -4035.56, 17.42, 9.77, 16.03, {225, 240, 250}, Enum.Material.Ice, 0.12, true, Enum.PartType.Block, 0.11, -0.11, 0.03)
part(ws, 'Snow_0', -76.43, 0.5, -4100.38, 22.98, 0.15, 18.01, {245, 250, 255}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Snow_1', 64.63, 0.5, -3925.03, 27.35, 0.15, 19.87, {245, 250, 255}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Snow_2', -74.74, 0.5, -4139.94, 22.54, 0.15, 22.15, {245, 250, 255}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Snow_3', -24.0, 0.5, -3902.9, 19.8, 0.15, 18.32, {245, 250, 255}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Snow_4', -93.54, 0.5, -4021.8, 22.64, 0.15, 22.15, {245, 250, 255}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Snow_5', 30.77, 0.5, -4132.9, 17.28, 0.15, 21.21, {245, 250, 255}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'Aurora_0', 163.66, 67.46, -3916.92, 57.39, 1.2, 6, {120, 255, 190}, Enum.Material.Neon, 0.35, false, Enum.PartType.Wedge, -0.02, 0.17, 0.19)
part(ws, 'Aurora_1', -38.11, 54.4, -4047.7, 50.34, 1.2, 6, {140, 230, 255}, Enum.Material.Neon, 0.35, false, Enum.PartType.Wedge, 0.01, 0.05, -0.19)
part(ws, 'Aurora_2', -104.39, 55.03, -4119.28, 65.93, 1.2, 6, {190, 140, 255}, Enum.Material.Neon, 0.35, false, Enum.PartType.Wedge, -0.04, -0.05, 0.04)
part(ws, 'Aurora_3', 171.78, 54.99, -3892.71, 53.2, 1.2, 6, {120, 255, 190}, Enum.Material.Neon, 0.35, false, Enum.PartType.Wedge, -0.12, 0.16, -0.13)
part(ws, 'Aurora_4', 23.54, 65.38, -4003.57, 62.29, 1.2, 6, {140, 230, 255}, Enum.Material.Neon, 0.35, false, Enum.PartType.Wedge, -0.19, 0.28, -0.15)
part(ws, 'Aurora_5', 89.7, 63.16, -4112.18, 50.86, 1.2, 6, {190, 140, 255}, Enum.Material.Neon, 0.35, false, Enum.PartType.Wedge, -0.0, -0.2, -0.05)
part(ws, 'Aurora_6', -64.37, 62.24, -4099.39, 45.85, 1.2, 6, {120, 255, 190}, Enum.Material.Neon, 0.35, false, Enum.PartType.Wedge, 0.08, -0.17, -0.07)
part(ws, 'Aurora_7', -25.24, 66.34, -3933.47, 93.65, 1.2, 6, {140, 230, 255}, Enum.Material.Neon, 0.35, false, Enum.PartType.Wedge, -0.1, -0.3, 0.14)
part(ws, 'IceCrystal_0', -126.71, -1.5, -4037.56, 1.36, 2.72, 0.6, {170, 230, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0.1, 0)
part(ws, 'IceCrystal_1', 121.28, -1.5, -4020.96, 0.89, 3.58, 0.6, {170, 230, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0.85, 0)
part(ws, 'IceCrystal_2', 71.8, -1.5, -3874.74, 0.62, 3.58, 0.6, {170, 230, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 2.14, 0)
part(ws, 'IceCrystal_3', -52.96, -1.5, -3878.49, 1.03, 4.43, 0.6, {170, 230, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0.33, 0)
part(ws, 'IceCrystal_4', 90.69, -1.5, -4130.81, 1.23, 3.07, 0.6, {170, 230, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0.77, 0)
part(ws, 'IceCrystal_5', 54.78, -1.5, -3983.73, 1.27, 4.24, 0.6, {170, 230, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 1.53, 0)
part(ws, 'Bio_0', 34.91, -1.11, -4910.93, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_1', -139.37, -0.82, -5137.48, 0.4, 0.4, 0.4, {80, 160, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_2', 24.17, -0.87, -4893.85, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_3', 140.41, -2.04, -5139.33, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_4', 157.68, -0.91, -5048.48, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_5', 37.84, -1.46, -4917.63, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_6', 53.94, -1.97, -4977.1, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_7', 113.16, -1.5, -4892.2, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_8', 16.03, -1.69, -4895.82, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_9', -69.3, -1.51, -5080.12, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_10', 92.79, -2.28, -5004.59, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_11', -91.04, -1.91, -4978.79, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_12', 21.19, -1.06, -5129.25, 0.4, 0.4, 0.4, {80, 160, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_13', 126.05, -2.08, -5074.03, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_14', -75.03, -1.31, -5156.3, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_15', 155.0, -1.7, -4925.54, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_16', -43.08, -1.07, -4867.4, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_17', 81.64, -2.27, -5072.87, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_18', -135.72, -1.66, -4847.86, 0.4, 0.4, 0.4, {80, 160, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_19', -76.26, -1.44, -5032.34, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_20', -41.21, -1.17, -5152.65, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_21', -109.55, -1.43, -4953.55, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_22', 46.89, -1.42, -5081.23, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_23', 35.86, -0.96, -4864.71, 0.4, 0.4, 0.4, {80, 160, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_24', 61.86, -1.71, -5012.73, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_25', -36.52, -1.39, -4909.64, 0.4, 0.4, 0.4, {80, 160, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_26', 48.97, -2.47, -5156.45, 0.4, 0.4, 0.4, {80, 160, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_27', -135.98, -1.82, -5138.39, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_28', 48.4, -1.43, -5145.32, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_29', 36.66, -2.03, -4858.02, 0.4, 0.4, 0.4, {80, 160, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_30', 152.01, -2.26, -4973.32, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_31', 144.4, -1.29, -4843.9, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_32', 3.57, -1.29, -4863.93, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_33', -37.67, -1.64, -4865.95, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_34', 147.63, -2.1, -5035.88, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_35', -135.14, -1.04, -4842.09, 0.4, 0.4, 0.4, {200, 140, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_36', -100.64, -1.1, -4984.67, 0.4, 0.4, 0.4, {90, 200, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_37', 54.11, -2.0, -4983.03, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_38', 55.87, -1.0, -5010.93, 0.4, 0.4, 0.4, {120, 255, 200}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Bio_39', 11.08, -1.1, -5038.79, 0.4, 0.4, 0.4, {80, 160, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'AbyssPillar_0', 3.92, -0.95, -4978.53, 5.76, 13.22, 6.0, {50, 52, 62}, Enum.Material.Rock, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'AbyssPillar_1', -3.01, -1.17, -4889.35, 5.94, 12.53, 5.02, {50, 52, 62}, Enum.Material.Rock, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'AbyssPillar_2', -21.33, -0.01, -5042.17, 6.29, 15.13, 4.57, {50, 52, 62}, Enum.Material.Rock, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'AbyssPillar_3', 103.45, 0.56, -4939.74, 6.73, 15.91, 5.92, {50, 52, 62}, Enum.Material.Rock, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'AbyssPillar_4', -3.51, -0.84, -4932.94, 5.51, 11.5, 5.18, {50, 52, 62}, Enum.Material.Rock, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'AbyssPillar_5', -93.82, 0.11, -4886.23, 5.37, 13.91, 4.78, {50, 52, 62}, Enum.Material.Rock, 0, true, Enum.PartType.Cylinder, 0, 0, 0)
part(ws, 'Spine_0', -74.0, -2.2, -5010, 1.6, 1.6, 1.6, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Spine_1', -70.5, -1.96, -5010, 1.6, 1.6, 1.6, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Spine_2', -67.0, -1.78, -5010, 1.6, 1.6, 1.6, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Spine_3', -63.5, -1.7, -5010, 1.6, 1.6, 1.6, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Spine_4', -60.0, -1.75, -5010, 1.6, 1.6, 1.6, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Spine_5', -56.5, -1.9, -5010, 1.6, 1.6, 1.6, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Spine_6', -53.0, -2.13, -5010, 1.6, 1.6, 1.6, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Spine_7', -49.5, -2.38, -5010, 1.6, 1.6, 1.6, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Spine_8', -46.0, -2.58, -5010, 1.6, 1.6, 1.6, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'Rib_0', -72.0, -1.8, -5006, 0.7, 0.7, 5, {225, 225, 232}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.4, 0, 0)
part(ws, 'Rib_1', -68.8, -1.8, -5014, 0.7, 0.7, 5, {225, 225, 232}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.4, 0, 0)
part(ws, 'Rib_2', -65.6, -1.8, -5006, 0.7, 0.7, 5, {225, 225, 232}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.4, 0, 0)
part(ws, 'Rib_3', -62.4, -1.8, -5014, 0.7, 0.7, 5, {225, 225, 232}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.4, 0, 0)
part(ws, 'Rib_4', -59.2, -1.8, -5006, 0.7, 0.7, 5, {225, 225, 232}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.4, 0, 0)
part(ws, 'Rib_5', -56.0, -1.8, -5014, 0.7, 0.7, 5, {225, 225, 232}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.4, 0, 0)
part(ws, 'Rib_6', -52.8, -1.8, -5006, 0.7, 0.7, 5, {225, 225, 232}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, 0.4, 0, 0)
part(ws, 'Rib_7', -49.6, -1.8, -5014, 0.7, 0.7, 5, {225, 225, 232}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Cylinder, -0.4, 0, 0)
part(ws, 'Skull', -42, -1.9, -5010, 3.4, 2.6, 2.4, {235, 235, 240}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'EyeL', -41.4, -1.7, -5009.1, 0.7, 0.7, 0.7, {40, 40, 48}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'EyeR', -41.4, -1.7, -5010.9, 0.7, 0.7, 0.7, {40, 40, 48}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
do
local c = part(ws, 'ChestBase', 40, -2.4, -5020, 3, 2, 2, {200, 160, 60}, Enum.Material.Metal, 0, true, Enum.PartType.Block)
part(ws, 'ChestLid', 40, -1.3, -5020, 3, 0.8, 2, {220, 180, 70}, Enum.Material.Metal, 0, true, Enum.PartType.Wedge, 0, 0, 0)
local g = part(ws, 'ChestGlow', 40, -1.0, -5020, 1.2, 1.2, 1.2, {255, 220, 90}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)
light(g, {255, 210, 80}, 1.5, 30)
end
part(ws, 'IsleBase', 800, -1.0, -3000, 52, 2, 42, {200, 180, 140}, Enum.Material.SmoothPlastic, 0, true, Enum.PartType.Block, 0, 0, 0)
part(ws, 'IsleSand1', 800, 0.48, -3000, 40, 0.15, 32, {235, 218, 168}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'IsleSand2', 800, 0.53, -3000, 30, 0.2, 24, {235, 218, 168}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'IsleRock_0', 798.8, 2.04, -2999.47, 2.5, 2, 2.5, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.14, -0.12, -0.15)
part(ws, 'IsleRock_1', 799.77, 1.51, -2998.67, 2.5, 2, 2.5, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.04, -0.12, -0.05)
part(ws, 'IsleRock_2', 799.25, 1.15, -3001.83, 2.5, 2, 2.5, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.09, -0.01, 0.14)
part(ws, 'IsleRock_3', 800.78, 1.88, -3000.59, 2.5, 2, 2.5, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.03, -0.19, 0.14)
part(ws, 'IsleRock_4', 800.33, 1.98, -2999.7, 2.5, 2, 2.5, {110, 110, 118}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.13, -0.11, 0.07)
part(ws, 'PalmTrunk_H0', 798.15, 3.4, -3007.3, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.07, 0, -0.03)
part(ws, 'PalmLeaf_H0_0', 800.96, 5.5, -3005.8, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_H0_1', 799.68, 5.5, -3002.55, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_H0_2', 796.21, 5.5, -3005.22, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_H0_3', 798.52, 5.5, -3008.65, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_H0_4', 799.59, 5.5, -3010.22, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_H0', 801.85, 4.7, -3005.17, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_H0', 803.94, 4.7, -3007.59, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_H1', 793.97, 3.4, -3003.1, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.08, 0, -0.04)
part(ws, 'PalmLeaf_H1_0', 796.55, 5.5, -2997.73, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_H1_1', 798.54, 5.5, -2997.87, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_H1_2', 796.48, 5.5, -2999.26, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_H1_3', 792.41, 5.5, -3000.83, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_H1_4', 795.6, 5.5, -3000.87, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_H1', 797.5, 4.7, -3001.58, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_H1', 798.48, 4.7, -3000.52, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmTrunk_H2', 796.28, 3.4, -3003.73, 0.7, 6, 0.7, {122, 82, 44}, Enum.Material.Wood, 0, false, Enum.PartType.Cylinder, 0.06, 0, -0.05)
part(ws, 'PalmLeaf_H2_0', 798.65, 5.5, -3007.74, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 1.57)
part(ws, 'PalmLeaf_H2_1', 797.38, 5.5, -3005.04, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, 0.31)
part(ws, 'PalmLeaf_H2_2', 793.76, 5.5, -3003.28, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -0.95)
part(ws, 'PalmLeaf_H2_3', 798.63, 5.5, -3009.85, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -2.21)
part(ws, 'PalmLeaf_H2_4', 799.21, 5.5, -3008.18, 3.2, 0.35, 0.9, {58, 138, 60}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Wedge, 0.5, 0, -3.47)
part(ws, 'PalmNut1_H2', 799.09, 4.7, -3003.45, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
part(ws, 'PalmNut2_H2', 800.5, 4.7, -3008.15, 0.4, 0.4, 0.4, {90, 62, 30}, Enum.Material.SmoothPlastic, 0, false, Enum.PartType.Ball, 0, 0, 0)
do
local fr = part(ws, 'FloatRock', 830, 8, -2980, 8, 4, 8, {110, 108, 112}, Enum.Material.Rock, 0, true, Enum.PartType.Ball)
part(ws, 'IsleFall', 830, 3, -2980, 1.6, 9, 3, {170, 220, 240}, Enum.Material.Glass, 0.45, false, Enum.PartType.Block)
local m = part(ws, 'IsleMist', 830, -0.8, -2980, 1, 1, 1, {255, 255, 255}, Enum.Material.SmoothPlastic, 1, false, Enum.PartType.Ball)
fx(m, {220, 235, 245}, 8, 0.8, 1.6, 1, 2.5, 1.5, 3, 0.35, 1)
end
do
local c = part(ws, 'IsleChest', 800, -0.4, -2990, 3, 2, 2, {200, 160, 60}, Enum.Material.Metal, 0, true, Enum.PartType.Block)
part(ws, 'IsleChestLid', 800, 0.7, -2990, 3, 0.8, 2, {220, 180, 70}, Enum.Material.Metal, 0, true, Enum.PartType.Wedge, 0, 0, 0)
local g = part(ws, 'IsleChestGlow', 800, 0.9, -2990, 1.2, 1.2, 1.2, {255, 220, 90}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)
light(g, {255, 210, 80}, 1.5, 30)
end
part(ws, 'IsleFog_0', 810.14, 3.17, -2988.74, 21.92, 2, 18.29, {235, 245, 250}, Enum.Material.SmoothPlastic, 0.7, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'IsleFog_1', 795.79, 5.4, -3001.15, 29.73, 2, 16.91, {235, 245, 250}, Enum.Material.SmoothPlastic, 0.7, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'IsleFog_2', 818.06, 2.1, -2991.17, 21.58, 2, 15.14, {235, 245, 250}, Enum.Material.SmoothPlastic, 0.7, false, Enum.PartType.Block, 0, 0, 0)
part(ws, 'GrottoWall_0', 874.37, -1, -1990.28, 12.21, 8.42, 14.93, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0.13)
part(ws, 'GrottoWall_1', 859.54, -1, -1954.4, 14.09, 13.31, 12.33, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 0.65)
part(ws, 'GrottoWall_2', 828.76, -1, -1930.73, 12.36, 12.92, 15.9, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 1.18)
part(ws, 'GrottoWall_3', 790.28, -1, -1925.63, 12.04, 9.41, 15.39, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 1.7)
part(ws, 'GrottoWall_4', 754.4, -1, -1940.46, 14.48, 13.52, 11.06, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 2.22)
part(ws, 'GrottoWall_5', 730.73, -1, -1971.24, 14.86, 8.29, 14.27, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 2.75)
part(ws, 'GrottoWall_6', 725.63, -1, -2009.72, 10.88, 13.05, 12.39, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 3.27)
part(ws, 'GrottoWall_7', 740.46, -1, -2045.6, 14.45, 9.83, 10.12, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 3.8)
part(ws, 'GrottoWall_8', 771.24, -1, -2069.27, 12.07, 13.83, 13.78, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 4.32)
part(ws, 'GrottoWall_9', 809.72, -1, -2074.37, 11.33, 8.11, 15.07, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 4.84)
part(ws, 'GrottoWall_10', 845.6, -1, -2059.54, 10.22, 8.41, 14.94, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 5.37)
part(ws, 'GrottoWall_11', 869.27, -1, -2028.76, 11.96, 10.19, 11.97, {95, 95, 105}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0, 0, 5.89)
part(ws, 'Stalactite_0', 823.93, 6.81, -2026.5, 1.27, 5.61, 1.94, {110, 108, 118}, Enum.Material.Rock, 0, false, Enum.PartType.Wedge, 0, 0, -0.45)
part(ws, 'Stalactite_1', 822.95, 4.6, -1980.4, 1.26, 6.41, 1.52, {110, 108, 118}, Enum.Material.Rock, 0, false, Enum.PartType.Wedge, 0, 0, 0.02)
part(ws, 'Stalactite_2', 774.79, 6.01, -2020.92, 1.0, 6.98, 1.85, {110, 108, 118}, Enum.Material.Rock, 0, false, Enum.PartType.Wedge, 0, 0, 0.09)
part(ws, 'Stalactite_3', 825.47, 6.77, -2034.71, 1.62, 4.43, 1.44, {110, 108, 118}, Enum.Material.Rock, 0, false, Enum.PartType.Wedge, 0, 0, -0.17)
part(ws, 'Stalactite_4', 833.62, 5.25, -1969.83, 1.79, 4.85, 1.27, {110, 108, 118}, Enum.Material.Rock, 0, false, Enum.PartType.Wedge, 0, 0, 0.16)
part(ws, 'Stalactite_5', 762.18, 7.84, -1994.18, 1.9, 6.41, 1.87, {110, 108, 118}, Enum.Material.Rock, 0, false, Enum.PartType.Wedge, 0, 0, 0.12)
part(ws, 'Stalactite_6', 772.12, 6.43, -2030.07, 1.9, 6.84, 1.09, {110, 108, 118}, Enum.Material.Rock, 0, false, Enum.PartType.Wedge, 0, 0, -0.45)
part(ws, 'Stalactite_7', 821.71, 6.84, -2036.79, 1.19, 5.67, 1.21, {110, 108, 118}, Enum.Material.Rock, 0, false, Enum.PartType.Wedge, 0, 0, 0.15)
part(ws, 'Crystal_0', 786.43, -2.6, -1963.91, 0.99, 2.02, 0.7, {170, 130, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 1.48, 0)
part(ws, 'Crystal_1', 755.24, -2.6, -1976.6, 0.78, 3.71, 0.7, {170, 130, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 1.94, 0)
part(ws, 'Crystal_2', 827.49, -2.6, -1963.9, 1.03, 2.29, 0.7, {120, 255, 170}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 1.02, 0)
part(ws, 'Crystal_3', 829.73, -2.6, -2002.69, 1.18, 3.14, 0.7, {120, 255, 170}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 2.18, 0)
part(ws, 'Crystal_4', 769.22, -2.6, -1999.93, 1.1, 3.34, 0.7, {170, 130, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 2.88, 0)
part(ws, 'Crystal_5', 796.71, -2.6, -2036.83, 0.89, 2.69, 0.7, {170, 130, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0.48, 0)
part(ws, 'Crystal_6', 847.3, -2.6, -2007.88, 1.09, 2.03, 0.7, {170, 130, 255}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0.62, 0)
part(ws, 'Crystal_7', 779.0, -2.6, -1980.79, 1.04, 3.01, 0.7, {120, 255, 170}, Enum.Material.Neon, 0, false, Enum.PartType.Wedge, 0, 0.83, 0)
part(ws, 'GrottoPool', 800, 0.02, -2000, 60, 0.3, 60, {30, 90, 130}, Enum.Material.Glass, 0.6, false, Enum.PartType.Block, 0, 0, 0)
do
local c = part(ws, 'GrottoChest', 800, -2.4, -1990, 3, 2, 2, {200, 160, 60}, Enum.Material.Metal, 0, true, Enum.PartType.Block)
local g = part(ws, 'GrottoGlow', 800, -1.0, -1990, 1.2, 1.2, 1.2, {150, 255, 160}, Enum.Material.Neon, 0, false, Enum.PartType.Ball)
light(g, {120, 255, 170}, 1.5, 30)
end
part(ws, 'Rock_800_-2000_0', 805.34, 1.25, -2010.04, 2.31, 2.96, 4.68, {100, 100, 110}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.0, -0.02, 0.09)
part(ws, 'Rock_800_-2000_1', 803.5, 1.27, -1988.49, 2.06, 3.69, 4.75, {100, 100, 110}, Enum.Material.Rock, 0, true, Enum.PartType.Block, 0.07, 0.02, 0.02)
part(ws, 'Rock_800_-2000_2', 790.12, -1.13, -2008.57, 3.79, 2.09, 4.83, {100, 100, 110}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.08, -0.17, -0.05)
part(ws, 'Rock_800_-2000_3', 786.8, -0.43, -1985.35, 2.36, 3.79, 4.64, {100, 100, 110}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.07, -0.02, -0.01)
part(ws, 'Rock_800_-2000_4', 800.18, -0.09, -2000.3, 4.0, 4.77, 3.4, {100, 100, 110}, Enum.Material.Rock, 0, true, Enum.PartType.Block, -0.13, 0.16, 0.11)

-- Lighting
local lighting = Instance.new('Lighting')
lighting.Name = 'Lighting'
lighting.Parent = dm
lighting.ClockTime = 14
lighting.FogColor = Color3.fromRGB(190, 215, 235)
lighting.FogStart = 500
lighting.FogEnd = 5200
lighting.Ambient = Color3.fromRGB(115, 125, 135)
lighting.OutdoorAmbient = Color3.fromRGB(135, 145, 155)
lighting.Brightness = 1.2

-- ===== Script tree ===== --
local containerCls = {
    ReplicatedStorage = 'ReplicatedStorage',
    ServerScriptService = 'ServerScriptService',
    StarterPlayer = 'StarterPlayer',
    StarterPlayerScripts = 'StarterPlayerScripts',
    Shared = 'Folder',
    Services = 'Folder',
    Controllers = 'Folder',
    Modules = 'Folder',
    Data = 'Folder',
}

local function ensureChain(logical, cls)
    local parts = {}
    for p in logical:gmatch('[^/]+') do table.insert(parts, p) end
    local cur = dm
    for i, name in ipairs(parts) do
        local child = cur:FindFirstChild(name)
        if not child then
            local childCls = containerCls[name] or (i == #parts and cls or 'Folder')
            child = Instance.new(childCls)
            child.Name = name
            child.Parent = cur
        end
        cur = child
    end
    return cur
end

-- ReplicatedStorage/Shared
local inst_ReplicatedStorage_Shared = ensureChain([===[ReplicatedStorage/Shared]===], 'Folder')

-- ReplicatedStorage/Shared/Config
local inst_ReplicatedStorage_Shared_Config = ensureChain([===[ReplicatedStorage/Shared/Config]===], 'ModuleScript')
inst_ReplicatedStorage_Shared_Config.Source = [===[--!strict
--[[
	Tidebound — Config
	ALL tunable game constants live here. Rebalance by editing this file only.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Config = {}

-- ── Save system ──────────────────────────────────────────────────────────
Config.SAVE_VERSION = 1
Config.SAVE_KEY_PREFIX = "TD_Save_v"
Config.AUTOSAVE_INTERVAL = 90 -- seconds

-- ── Leveling ─────────────────────────────────────────────────────────────
Config.XP_BASE = 100 -- xp needed from level N to N+1 = XP_BASE * N^XP_EXPONENT
Config.XP_EXPONENT = 1.6
Config.MAX_LEVEL = 50
Config.LEVEL_UP_COINS = 50 + 10 -- flat bonus on level up (scaled by level in code)

-- ── Rarity / luck ────────────────────────────────────────────────────────
Config.RARITIES = { "common", "uncommon", "rare", "epic", "legendary", "mythic" }
Config.RARITY_INDEX = { common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5, mythic = 6 }
Config.RARITY_WEIGHTS = { common = 500, uncommon = 280, rare = 140, epic = 60, legendary = 17, mythic = 3 }
Config.LUCK_CAP = 2.5 -- max combined luck multiplier on epic+ (anti-P2W cap)
Config.SHINY_CHANCE = 0.02 -- 2% shiny variant on any catch
Config.SHINY_VALUE_MULT = 3
Config.BAIT_FAMILY_MULT = 2.0 -- preferred bait doubles family weight
Config.GOLDEN_LURE_LUCK = 0.20
Config.GOLDEN_LURE_WEIGHT_MULT = 1.15
Config.NIGHT_LUCK = 0.05 -- +5% luck mood at night

-- ── Fishing timing ───────────────────────────────────────────────────────
Config.CAST_COOLDOWN = 1.2
Config.WAIT_MIN = 4.0 -- seconds before bite (base)
Config.WAIT_MAX = 9.0
Config.WAIT_FLOOR = 2.5 -- rod lure speed can't reduce below this
Config.REEL_TICK = 0.1 -- server simulation step
Config.REEL_STATE_SEND = 0.16 -- client state push interval
Config.PROGRESS_MAX = 100
Config.TENSION_MAX = 100
Config.TENSION_RISE_BASE = 34 -- tension/s at strength 1, common fish
Config.TENSION_RISE_PER_RARITY = 0.22 -- extra rise per rarity step
Config.TENSION_DECAY = 46 -- tension/s while released
Config.PROGRESS_RATE_BASE = 8 -- progress/s at strength 0
Config.PROGRESS_RATE_PER_STRENGTH = 1 -- +progress/s per strength point
Config.REEL_POSITION_RADIUS = 60 -- player must stay near own bobber
Config.WATER_Y = 0 -- bobber floats at this height

-- ── Economy caps ─────────────────────────────────────────────────────────
Config.COIN_CAP = 9999999
Config.PEARL_CAP = 99999
Config.INVENTORY_START = 40
Config.INVENTORY_CAP = 200
Config.INVENTORY_UPGRADES = {
	{ slots = 10, cost = 2000 },
	{ slots = 10, cost = 8000 },
	{ slots = 10, cost = 25000 },
}
Config.PEARL_DROP_CHANCE = 0.005 -- 0.5% per epic+ catch
Config.PEARL_DROP_MIN_RARITY = "epic"

-- ── Quests / streaks ─────────────────────────────────────────────────────
Config.DAILY_QUESTS = 3
Config.WEEKLY_QUESTS = 3
Config.STREAK_REWARDS = {
	{ coins = 50 },
	{ coins = 100 },
	{ coins = 200, worm = 5 },
	{ coins = 350 },
	{ coins = 500 },
	{ coins = 750, shrimp = 3 },
	{ coins = 1000, pearls = 25, golden = 1 },
}

-- ── Day / night & storms ─────────────────────────────────────────────────
Config.DAY_LENGTH = 1200 -- 20 min
Config.NIGHT_LENGTH = 360 -- 6 min
Config.STORM_MIN_DELAY = 1500 -- 25 min
Config.STORM_MAX_DELAY = 2700 -- 45 min
Config.STORM_DURATION = 480 -- 8 min
Config.STORM_WARNING = 60 -- seconds of warning
Config.STORM_XP_MULT = 1.5
Config.STORM_PEARL_CHANCE = 0.05 -- storm fish drop pearls 5%

-- ── Baits (coin shop) ────────────────────────────────────────────────────
Config.BAITS = {
	worm = { name = "Worm", cost = 50, count = 10 },
	shrimp = { name = "Shrimp", cost = 120, count = 10 },
	squid = { name = "Squid", cost = 300, count = 10 },
	golden = { name = "Golden Lure", cost = 500, count = 3 },
}

-- ── Rate limits (messages per 10s window per player) ─────────────────────
Config.RATE_LIMITS = {
	Cast = 6,
	ReelHold = 100,
	AutoReel = 5,
	SellFish = 25,
	SellAll = 6,
	SetAutoSell = 4,
	BuyRod = 6,
	BuyBait = 10,
	BuyUpgrade = 6,
	BuyCosmetic = 10,
	EquipRod = 8,
	EquipBait = 8,
	EquipCosmetic = 10,
	ClaimDaily = 6,
	ClaimWeekly = 6,
	RerollQuest = 3,
	FastTravel = 8,
	Purchase = 6,
	BuyCosmetic = 10,
	EquipCosmetic = 10,
	EquipTitle = 8,
	GetContestTop = 10,
}

-- ── Golden spots (limited-time shimmer locations) ─────────────────────────
Config.GOLDEN_SPOT_INTERVAL_MIN = 300 -- 5 min
Config.GOLDEN_SPOT_INTERVAL_MAX = 600 -- 10 min
Config.GOLDEN_SPOT_DURATION = 90 -- seconds a spot stays
Config.GOLDEN_SPOT_RADIUS = 30 -- studs around the shimmer
Config.GOLDEN_SPOT_LUCK = 0.20 -- +20% luck while casting there
Config.GOLDEN_SPOT_VALUE_MULT = 1.1 -- +10% sell value

-- ── Monetization (fill IDs from Creator Dashboard, Phase 7) ──────────────
Config.GAMEPASS_IDS = {
	double_catch = 0, -- 349 R$ : 2x coins
	bigger_tackle_box = 0, -- 149 R$ : +50 inventory
	lucky_charm = 0, -- 199 R$ : +15% luck
	vip_angler = 0, -- 449 R$ : +10% XP, VIP dock, skin, tag
	golden_lure_pass = 0, -- 249 R$ : permanent Golden Lure
	starter_pack = 0, -- 99 R$ : 500c + 5 golden lures + bobber
}
Config.PRODUCT_IDS = {
	pearls_100 = 0, -- 99 R$
	pearls_450 = 0, -- 399 R$
	pearls_1000 = 0, -- 799 R$
	auto_reel_tokens = 0, -- 149 R$ : x100
	xp_boost_2h = 0, -- 49 R$
}
Config.PEARL_PACKS = {
	{ id = "pearls_100", pearls = 100 },
	{ id = "pearls_450", pearls = 450 },
	{ id = "pearls_1000", pearls = 1000 },
}
Config.AUTO_REEL_TOKEN_PACK = 100
Config.XP_BOOST_DURATION = 7200
Config.XP_BOOST_MULT = 1.5
Config.DOUBLE_COINS_MULT = 2.0
Config.LUCKY_CHARM_LUCK = 0.15
Config.VIP_XP_MULT = 1.1
Config.STARTER_PACK = { coins = 500, golden = 5 }

-- ── Weekly contest ───────────────────────────────────────────────────────
Config.CONTEST_REWARDS = { 50, 40, 30, 25, 20, 15, 12, 10, 8, 5 } -- pearls, top 10
Config.CONTEST_MULTIPLIER_BASE = 1.0 -- score = weightKg * (base + rarityIndex)

-- ── Client UI / input ────────────────────────────────────────────────────
Config.CAST_POWER_TIME = 1.2 -- seconds to charge cast power 0→1
Config.QUICK_CAST_POWER = 0.55 -- power used when tapping without holding
Config.MAX_FEED_MESSAGES = 5 -- feed entries kept on screen
Config.CATCH_CARD_MS = 3500 -- catch card auto-dismiss (epic+)

-- ── Audio (fill IDs after uploading assets/audio/*.wav in Studio) ───────
-- 0 = sound disabled (graceful silence until the ID is set)
Config.AUDIO_IDS = {
	ui_click = 0,
	ui_error = 0,
	cast_splash = 0,
	bite = 0,
	reel_tick = 0,
	catch_common = 0,
	catch_rare = 0,
	catch_mythic = 0,
	levelup = 0,
	coins = 0,
	streak = 0,
	storm = 0,
	achievement = 0,
	buy = 0,
}

return Config
]===]

-- ReplicatedStorage/Shared/Data
local inst_ReplicatedStorage_Shared_Data = ensureChain([===[ReplicatedStorage/Shared/Data]===], 'Folder')

-- ReplicatedStorage/Shared/Data/CosmeticsCatalog
local inst_ReplicatedStorage_Shared_Data_CosmeticsCatalog = ensureChain([===[ReplicatedStorage/Shared/Data/CosmeticsCatalog]===], 'ModuleScript')
inst_ReplicatedStorage_Shared_Data_CosmeticsCatalog.Source = [===[--!strict
--[[
	Tidebound — CosmeticsCatalog
	Every purchasable cosmetic (pearl shop). Types: bobber, trail, aura, rodSkin, nameColor.
	Cosmetics are 100% visual — never affect gameplay values.
	Phase 7 | AI-assisted | 2026-08-03
]]

local Types = require(script.Parent.Parent.Types)

export type CosmeticDef = {
	id: string,
	name: string,
	kind: "bobber" | "trail" | "aura" | "rodSkin" | "nameColor",
	price: number, -- pearls (0 = default, free)
	color: Color3,
	desc: string,
}

local COSMETICS: { [string]: CosmeticDef } = {}

local function c(
	id: string,
	name: string,
	kind: "bobber" | "trail" | "aura" | "rodSkin" | "nameColor",
	price: number,
	color: Color3,
	desc: string
): CosmeticDef
	local def: CosmeticDef = { id = id, name = name, kind = kind, price = price, color = color, desc = desc }
	COSMETICS[id] = def
	return def
end

-- Bobbers (visual on the bobber)
c("bobber_classic", "Classic Bobber", "bobber", 0, Color3.fromRGB(255, 220, 80), "The old faithful. Gold never goes out of style.")
c("bobber_coral", "Coral Bobber", "bobber", 40, Color3.fromRGB(255, 120, 160), "Carved from living reef. A favorite of the shallows.")
c("bobber_aurora", "Aurora Bobber", "bobber", 90, Color3.fromRGB(120, 255, 190), "Catches the northern lights. Even at noon.")
c("bobber_void", "Void Bobber", "bobber", 150, Color3.fromRGB(150, 90, 255), "Fishing in the dark just got darker.")

-- Trails (particles behind the bobber)
c("trail_bubbles", "Bubble Trail", "trail", 60, Color3.fromRGB(200, 235, 255), "A stream of bubbles marks your cast.")
c("trail_stars", "Starlight Trail", "trail", 110, Color3.fromRGB(255, 240, 160), "A sprinkle of stardust follows your line.")

-- Auras (particle glow on catch)
c("aura_ember", "Ember Aura", "aura", 130, Color3.fromRGB(255, 140, 50), "Your catches arrive wreathed in embers.")
c("aura_ghost", "Ghostlight Aura", "aura", 130, Color3.fromRGB(160, 200, 255), "A cold, pale light that follows the fish home.")

-- Rod skins (color of the rod handle you hold)
c("rodskin_oak", "Oak Grip", "rodSkin", 50, Color3.fromRGB(150, 105, 60), "Classic wood. Warm, familiar, dependable.")
c("rodskin_obsidian", "Obsidian Grip", "rodSkin", 80, Color3.fromRGB(45, 45, 55), "Black as the trench it was forged in.")
c("rodskin_royal", "Royal Grip", "rodSkin", 150, Color3.fromRGB(200, 170, 60), "Gold trim for the angler who knows it.")

-- Name colors (profile + title displays)
c("name_aqua", "Aqua Name", "nameColor", 25, Color3.fromRGB(90, 220, 255), "A splash of color for your name.")
c("name_rose", "Rose Name", "nameColor", 25, Color3.fromRGB(255, 130, 160), "Soft and unmistakable.")
c("name_gold", "Gold Name", "nameColor", 60, Color3.fromRGB(255, 200, 60), "For those who always land the big one.")

local CosmeticsCatalog = {}

function CosmeticsCatalog.Get(id: string): CosmeticDef?
	return COSMETICS[id]
end

function CosmeticsCatalog.GetAll(): { [string]: CosmeticDef }
	return COSMETICS
end

function CosmeticsCatalog.GetByKind(kind: string): { CosmeticDef }
	local out: { CosmeticDef } = {}
	for _, def in pairs(COSMETICS) do
		if def.kind == kind then
			table.insert(out, def)
		end
	end
	table.sort(out, function(a, b)
		return a.price < b.price
	end)
	return out
end

function CosmeticsCatalog.DefaultFor(kind: string): string?
	if kind == "bobber" then
		return "bobber_classic"
	end
	return nil
end

return CosmeticsCatalog
]===]

-- ReplicatedStorage/Shared/Data/FishCatalog
local inst_ReplicatedStorage_Shared_Data_FishCatalog = ensureChain([===[ReplicatedStorage/Shared/Data/FishCatalog]===], 'ModuleScript')
inst_ReplicatedStorage_Shared_Data_FishCatalog.Source = [===[--!strict
--[[
	Tidebound — FishCatalog
	All fish definitions. Content DB — add species here for new updates.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Types = require(script.Parent.Parent.Types)

local FISH: { [string]: Types.FishDef } = {}

local function fish(
	id: string,
	name: string,
	rarity: Types.Rarity,
	baseValue: number,
	minWeight: number,
	maxWeight: number,
	xp: number,
	zone: string,
	family: string,
	desc: string,
	color: Color3,
	accent: Color3,
	bodyScale: number,
	opts: { time: "any" | "night", bait: string?, stormOnly: boolean? }?
): Types.FishDef
	local def: Types.FishDef = {
		id = id,
		name = name,
		rarity = rarity,
		baseValue = baseValue,
		minWeight = minWeight,
		maxWeight = maxWeight,
		xp = xp,
		zone = zone,
		time = opts and opts.time or "any",
		bait = opts and opts.bait,
		family = family,
		desc = desc,
		color = color,
		accent = accent,
		bodyScale = bodyScale,
		stormOnly = opts and opts.stormOnly,
	}
	FISH[id] = def
	return def
end

-- ═══════════ SUNSHALL COVE (starter) ═══════════
fish("sunsail_minnow", "Sunsail Minnow", "common", 4, 0.2, 0.8, 8, "sunshall", "shoal",
	"A cheerful little fish that follows boats. Perfect first catch.", Color3.fromRGB(210, 200, 120), Color3.fromRGB(255, 240, 160), 0.7)
fish("reef_perch", "Reef Perch", "common", 5, 0.5, 1.5, 9, "sunshall", "reef",
	"Stubborn but plentiful. Hides among the pier posts.", Color3.fromRGB(190, 120, 80), Color3.fromRGB(120, 80, 60), 0.9)
fish("cove_carp", "Cove Carp", "uncommon", 10, 1.0, 3.0, 20, "sunshall", "carp",
	"Lazy bottom feeder. Loves worms.", Color3.fromRGB(140, 160, 130), Color3.fromRGB(90, 110, 85), 1.1, { bait = "worm" })
fish("striped_grunt", "Striped Grunt", "uncommon", 9, 0.8, 2.2, 18, "sunshall", "reef",
	"Makes a grunting sound when annoyed. Locals find it hilarious.", Color3.fromRGB(150, 160, 170), Color3.fromRGB(60, 70, 80), 1.0)
fish("golden_anchovy", "Golden Anchovy", "rare", 25, 0.1, 0.4, 50, "sunshall", "shoal",
	"A tiny flash of gold. Worth far more than its size suggests.", Color3.fromRGB(255, 205, 60), Color3.fromRGB(255, 250, 200), 0.5)
fish("moon_koi", "Moon Koi", "rare", 40, 1.5, 4.0, 65, "sunshall", "koi",
	"Only swims in moonlight. Its scales glow like the moon's reflection.", Color3.fromRGB(190, 200, 255), Color3.fromRGB(120, 140, 255), 1.3, { time = "night" })
fish("sunsong_sturgeon", "Sunsong Sturgeon", "epic", 90, 5.0, 12.0, 140, "sunshall", "sturgeon",
	"An ancient fish said to hum along with the sunrise.", Color3.fromRGB(110, 140, 170), Color3.fromRGB(200, 220, 235), 2.2, { bait = "shrimp" })
fish("gilded_bass", "Gilded Bass", "legendary", 220, 8.0, 20.0, 320, "sunshall", "bass",
	"Legend says whoever catches it is blessed with good luck for a week.", Color3.fromRGB(255, 190, 40), Color3.fromRGB(255, 240, 150), 1.8)

-- ═══════════ WHISPER SHALLOWS ═══════════
fish("shimmerfin", "Whisper Shimmerfin", "common", 7, 0.4, 1.2, 12, "whisper", "shoal",
	"Its scales shimmer like the shallow water it calls home.", Color3.fromRGB(120, 200, 210), Color3.fromRGB(200, 255, 250), 0.8)
fish("drift_mackerel", "Drift Mackerel", "common", 8, 1.0, 3.0, 14, "whisper", "shoal",
	"Travels in huge schools. Where you see one, you see hundreds.", Color3.fromRGB(80, 130, 190), Color3.fromRGB(40, 70, 110), 1.2)
fish("seagrass_snapper", "Seagrass Snapper", "uncommon", 13, 2.0, 6.0, 24, "whisper", "reef",
	"Patient ambush hunter of the seagrass beds.", Color3.fromRGB(230, 120, 90), Color3.fromRGB(160, 70, 50), 1.3)
fish("silver_carp", "Silver Carp", "uncommon", 12, 2.0, 5.0, 22, "whisper", "carp",
	"Leaps out of the water when startled. Bring worms.", Color3.fromRGB(190, 200, 210), Color3.fromRGB(120, 130, 140), 1.2, { bait = "worm" })
fish("whisper_lanternfish", "Whisper Lanternfish", "rare", 45, 0.3, 0.9, 70, "whisper", "glow",
	"A living firefly of the shallows. Only visible after dark.", Color3.fromRGB(120, 255, 200), Color3.fromRGB(255, 255, 220), 0.6, { time = "night" })
fish("moonlit_koi", "Moonlit Koi", "rare", 55, 2.0, 6.0, 80, "whisper", "koi",
	"A paler cousin of the Moon Koi, with a violet sheen.", Color3.fromRGB(180, 170, 255), Color3.fromRGB(90, 80, 200), 1.4, { time = "night" })
fish("kelp_serpent", "Kelp Serpent", "epic", 95, 10.0, 25.0, 150, "whisper", "serpent",
	"A long, sinewy hunter that mimics kelp. Do not touch the fins.", Color3.fromRGB(60, 140, 90), Color3.fromRGB(30, 80, 50), 3.0, { bait = "squid" })
fish("tide_hunter", "Tide Hunter", "legendary", 240, 15.0, 40.0, 340, "whisper", "hunter",
	"Follows the tide in from the deep. Fast, angry, unforgettable.", Color3.fromRGB(70, 100, 140), Color3.fromRGB(20, 30, 50), 2.6)

-- ═══════════ THE DROP ═══════════
fish("deep_darter", "Deep Darter", "common", 12, 1.0, 4.0, 18, "drop", "shoal",
	"The first sign you've left the shallows behind.", Color3.fromRGB(60, 90, 140), Color3.fromRGB(30, 50, 80), 1.1)
fish("cliff_cod", "Cliff Cod", "uncommon", 18, 3.0, 8.0, 30, "drop", "cod",
	"Bulky, dependable, slightly grumpy.", Color3.fromRGB(110, 120, 110), Color3.fromRGB(70, 80, 70), 1.6, { bait = "worm" })
fish("drop_anglerfish", "Drop Anglerfish", "rare", 55, 3.0, 9.0, 85, "drop", "angler",
	"Carries its own lantern. The light is a lie.", Color3.fromRGB(50, 50, 70), Color3.fromRGB(120, 255, 220), 1.4, { bait = "squid" })
fish("abyssal_squid", "Abyssal Squid", "rare", 60, 2.0, 7.0, 90, "drop", "squid",
	"Ghost-pale tentacles that dance in the dark water.", Color3.fromRGB(220, 220, 240), Color3.fromRGB(255, 150, 200), 1.5, { time = "night", bait = "squid" })
fish("trench_eel", "Trench Eel", "epic", 110, 8.0, 20.0, 170, "drop", "eel",
	"Slips through crevices no fish should fit through.", Color3.fromRGB(40, 80, 90), Color3.fromRGB(120, 200, 200), 2.4, { bait = "squid" })
fish("fog_wraith", "Fog Wraith", "legendary", 260, 20.0, 50.0, 360, "drop", "wraith",
	"Some say it is not a fish at all, but the fog that got lost.", Color3.fromRGB(200, 210, 225), Color3.fromRGB(255, 255, 255), 2.8, { time = "night" })

-- ═══════════ EMBER FALLS ═══════════
fish("ember_trout", "Ember Trout", "common", 16, 1.0, 5.0, 22, "ember", "trout",
	"Thrives in water warmed by volcanic vents.", Color3.fromRGB(230, 120, 50), Color3.fromRGB(255, 180, 80), 1.0)
fish("ash_gar", "Ash Gar", "uncommon", 24, 3.0, 9.0, 35, "ember", "gar",
	"A needle-nosed predator of the ash-strewn shore.", Color3.fromRGB(90, 90, 100), Color3.fromRGB(50, 50, 55), 1.8, { bait = "worm" })
fish("magma_eel", "Magma Eel", "rare", 70, 4.0, 12.0, 100, "ember", "eel",
	"Glows like cooling lava. Handle with respect.", Color3.fromRGB(255, 90, 30), Color3.fromRGB(255, 200, 60), 2.0, { bait = "squid" })
fish("cinder_salmon", "Cinder Salmon", "rare", 80, 5.0, 14.0, 110, "ember", "salmon",
	"Swims UP the waterfalls. No one knows how.", Color3.fromRGB(240, 140, 90), Color3.fromRGB(255, 220, 180), 1.5, { bait = "shrimp" })
fish("ember_pike", "Ember Pike", "epic", 140, 10.0, 25.0, 200, "ember", "pike",
	"A furnace of muscle and teeth.", Color3.fromRGB(180, 70, 30), Color3.fromRGB(255, 140, 60), 2.2)
fish("magma_whale", "Magma Whale", "legendary", 300, 60.0, 140.0, 400, "ember", "whale",
	"The gentle giant of the caldera. Its song melts ice from miles away.", Color3.fromRGB(120, 60, 40), Color3.fromRGB(255, 120, 50), 4.5)
fish("ember_leviathan", "Ember Leviathan", "legendary", 320, 40.0, 90.0, 420, "ember", "leviathan",
	"Legends say the volcano itself once had a heartbeat.", Color3.fromRGB(90, 40, 30), Color3.fromRGB(255, 90, 20), 3.8)
fish("storm_krakenling", "Storm Krakenling", "mythic", 1200, 50.0, 120.0, 1000, "ember", "storm",
	"Born in the lightning. Only appears when the sky tears open.", Color3.fromRGB(60, 90, 180), Color3.fromRGB(200, 220, 255), 3.5, { stormOnly = true })

-- ═══════════ FROSTREACH ═══════════
fish("frostling_pike", "Frostling Pike", "common", 22, 2.0, 7.0, 28, "frost", "pike",
	"Cold-blooded in every sense. Aggressive year-round.", Color3.fromRGB(140, 190, 210), Color3.fromRGB(80, 120, 140), 1.6)
fish("iceback_herring", "Iceback Herring", "common", 30, 1.0, 4.0, 40, "frost", "shoal",
	"Its back freezes into a natural armor plate.", Color3.fromRGB(170, 200, 230), Color3.fromRGB(230, 245, 255), 0.9)
fish("snowcap_char", "Snowcap Char", "rare", 95, 4.0, 12.0, 130, "frost", "char",
	"Wears a white 'cap' that looks knitted by glaciers.", Color3.fromRGB(220, 80, 60), Color3.fromRGB(255, 255, 255), 1.3, { bait = "worm" })
fish("aurora_koi", "Aurora Koi", "rare", 110, 3.0, 10.0, 140, "frost", "koi",
	"Drinks the northern lights. Swim under the aurora to see it shine.", Color3.fromRGB(120, 255, 160), Color3.fromRGB(255, 120, 240), 1.4, { time = "night" })
fish("glacier_eel", "Glacier Eel", "epic", 180, 15.0, 35.0, 240, "frost", "eel",
	"Sleeps for years inside the ice. Wakes hungry.", Color3.fromRGB(90, 140, 180), Color3.fromRGB(200, 230, 255), 2.6, { bait = "squid" })
fish("frost_whale", "Frost Whale", "legendary", 380, 80.0, 180.0, 480, "frost", "whale",
	"An iceberg with a heartbeat. The sea freezes where it dives.", Color3.fromRGB(160, 190, 220), Color3.fromRGB(235, 245, 255), 4.8)
fish("frost_leviathan", "Frostbound Leviathan", "legendary", 400, 60.0, 150.0, 500, "frost", "leviathan",
	"Scars on its hide match the cracks in the ancient ice sheets.", Color3.fromRGB(120, 150, 190), Color3.fromRGB(255, 255, 255), 4.2)
fish("aurora_serpent", "Aurora Serpent", "mythic", 1500, 40.0, 100.0, 1200, "frost", "serpent",
	"A ribbon of living light. Seeing one is a once-in-a-lifetime gift.", Color3.fromRGB(100, 255, 200), Color3.fromRGB(255, 140, 255), 3.6, { time = "night" })

-- ═══════════ ABYSSAL TRENCH ═══════════
fish("trench_fangtooth", "Trench Fangtooth", "common", 30, 1.0, 5.0, 35, "abyss", "fang",
	"All teeth and no patience.", Color3.fromRGB(70, 70, 90), Color3.fromRGB(200, 60, 60), 1.2)
fish("void_lanternfish", "Void Lanternfish", "uncommon", 40, 0.5, 2.0, 50, "abyss", "glow",
	"A constellation swimming in the dark.", Color3.fromRGB(80, 120, 255), Color3.fromRGB(200, 220, 255), 0.8)
fish("abyssal_angler", "Abyssal Angler", "rare", 120, 6.0, 16.0, 160, "abyss", "angler",
	"The deep's most successful liar.", Color3.fromRGB(60, 60, 80), Color3.fromRGB(80, 255, 200), 1.8, { bait = "squid" })
fish("gloom_serpent", "Gloom Serpent", "epic", 220, 20.0, 45.0, 280, "abyss", "serpent",
	"Feeds on the silence of the trench.", Color3.fromRGB(50, 60, 90), Color3.fromRGB(140, 160, 220), 3.2, { bait = "squid" })
fish("abyssal_hunter", "Abyssal Hunter", "legendary", 480, 50.0, 130.0, 600, "abyss", "hunter",
	"Nothing in the trench is faster. Nothing is safer either.", Color3.fromRGB(40, 50, 70), Color3.fromRGB(120, 60, 200), 3.4)
fish("trench_devil", "Trench Devil", "legendary", 520, 60.0, 150.0, 620, "abyss", "devil",
	"When the trench goes silent, it is hunting.", Color3.fromRGB(140, 40, 60), Color3.fromRGB(255, 80, 60), 3.6, { time = "night" })
fish("leviathan_abyss", "Abyssal Leviathan", "mythic", 2200, 150.0, 400.0, 2000, "abyss", "leviathan",
	"The reason sailors check under the boat at night.", Color3.fromRGB(50, 70, 110), Color3.fromRGB(100, 200, 255), 5.0)
fish("stormcaller_eel", "Stormcaller Eel", "mythic", 2000, 80.0, 200.0, 1800, "abyss", "storm",
	"Some storms aren't weather. They're this.", Color3.fromRGB(40, 60, 140), Color3.fromRGB(220, 230, 255), 4.0, { stormOnly = true })
fish("old_one", "The Old One", "mythic", 2500, 200.0, 500.0, 2500, "abyss", "old",
	"Older than the islands. Older than the ocean. It remembers your name.",
	Color3.fromRGB(30, 90, 70), Color3.fromRGB(160, 255, 200), 5.5)

-- ═══════════ HIDDEN ISLES & GROTTO (secrets) ═══════════
fish("mistfin", "Mistfin", "rare", 90, 1.0, 4.0, 130, "hidden_isles", "mist",
	"A fish that looks like fog over water. Found only at the hidden isle.", Color3.fromRGB(210, 220, 230), Color3.fromRGB(255, 255, 255), 1.0)
fish("isle_song", "Isle Song", "legendary", 350, 15.0, 35.0, 450, "hidden_isles", "mist",
	"Its scales hum a melody the wind keeps forgetting.", Color3.fromRGB(150, 200, 255), Color3.fromRGB(255, 240, 200), 2.4)
fish("grotto_glowfin", "Grotto Glowfin", "rare", 100, 1.0, 3.0, 140, "sunken_grotto", "glow",
	"The grotto's only light source. Catch it and the cave goes dark.", Color3.fromRGB(120, 255, 255), Color3.fromRGB(255, 255, 160), 0.9)
fish("sunken_king", "Sunken King", "legendary", 450, 30.0, 70.0, 550, "sunken_grotto", "king",
	"Once the ruler of a drowned court. Now it guards what sank with it.", Color3.fromRGB(180, 160, 90), Color3.fromRGB(120, 90, 40), 3.0)

-- ═══════════ UNIVERSAL STORM FISH (any zone during a storm) ═══════════
fish("storm_sprat", "Storm Sprat", "uncommon", 20, 0.3, 1.0, 30, "storm_any", "storm",
	"Rides the storm waves for fun. Reckless little thing.", Color3.fromRGB(150, 160, 190), Color3.fromRGB(230, 240, 255), 0.7, { stormOnly = true })
fish("gale_herring", "Gale Herring", "rare", 85, 2.0, 6.0, 120, "storm_any", "storm",
	"Swims faster than the wind. Almost.", Color3.fromRGB(120, 140, 200), Color3.fromRGB(200, 220, 255), 1.2, { stormOnly = true })

-- ═══════════ Catalog API ═══════════

local FishCatalog = {}

function FishCatalog.Get(id: string): Types.FishDef?
	return FISH[id]
end

function FishCatalog.GetAll(): { [string]: Types.FishDef }
	return FISH
end

-- All fish catchable in a zone under current conditions.
-- `storm` adds storm fish; `night` adds night-only fish.
function FishCatalog.GetZoneFish(zoneId: string, night: boolean, storm: boolean): { Types.FishDef }
	local out: { Types.FishDef } = {}
	for _, def  in pairs(FISH) do
		local inZone = def.zone == zoneId
		local isUniversalStorm = def.zone == "storm_any"
		local isStormFish = def.stormOnly == true
		if inZone or (storm and isUniversalStorm) then
			if isStormFish and not storm then
				continue
			end
			if def.time == "night" and not night then
				continue
			end
			table.insert(out, def)
		end
	end
	return out
end

function FishCatalog.CountInZone(zoneId: string): number
	local n = 0
	for _, def  in pairs(FISH) do
		if def.zone == zoneId then
			n += 1
		end
	end
	return n
end

return FishCatalog
]===]

-- ReplicatedStorage/Shared/Data/QuestCatalog
local inst_ReplicatedStorage_Shared_Data_QuestCatalog = ensureChain([===[ReplicatedStorage/Shared/Data/QuestCatalog]===], 'ModuleScript')
inst_ReplicatedStorage_Shared_Data_QuestCatalog.Source = [===[--!strict
--[[
	Tidebound — QuestCatalog
	Daily/weekly quest templates + achievements. Data-driven; add more in updates.
	Phase 2 | AI-assisted | 2026-08-02
]]

local QuestCatalog = {}

-- type: catchTotal | catchZone | catchNight | catchRarity | catchFamily | catchStorm | sellCoins | catchShiny
-- param: { zone = "drop" } or { family = "eel" } — resolved at roll time
local DAILY_POOL: { { id: string, desc: string, type: string, target: number, rewards: { coins: number?, pearls: number?, bait: string? }, param: string? } } = {
	{ id = "d_catch_total", desc = "Catch {n} fish", type = "catchTotal", target = 10, rewards = { coins = 150 } },
	{ id = "d_catch_zone", desc = "Catch {n} fish in {zone}", type = "catchZone", target = 8, rewards = { coins = 200 }, param = "zone" },
	{ id = "d_catch_night", desc = "Catch {n} fish at night", type = "catchNight", target = 5, rewards = { coins = 250 } },
	{ id = "d_catch_rare", desc = "Catch a Rare or better fish", type = "catchRarity", target = 1, rewards = { coins = 300, pearls = 1 } },
	{ id = "d_sell_coins", desc = "Earn {n} coins from selling", type = "sellCoins", target = 400, rewards = { coins = 200 } },
	{ id = "d_catch_family", desc = "Catch {n} {family} fish", type = "catchFamily", target = 6, rewards = { coins = 220, bait = "worm" }, param = "family" },
	{ id = "d_catch_storm", desc = "Catch {n} fish during a storm", type = "catchStorm", target = 3, rewards = { coins = 350, pearls = 2 } },
	{ id = "d_catch_shiny", desc = "Catch a Shiny fish", type = "catchShiny", target = 1, rewards = { coins = 500, pearls = 5 } },
}

local WEEKLY_POOL: { { id: string, desc: string, type: string, target: number, rewards: { pearls: number }, param: string? } } = {
	{ id = "w_catch_100", desc = "Catch 100 fish", type = "catchTotal", target = 100, rewards = { pearls = 25 } },
	{ id = "w_catch_epic", desc = "Catch 5 Epic or better fish", type = "catchRarity", target = 5, rewards = { pearls = 30 } },
	{ id = "w_sell_5000", desc = "Earn 5,000 coins from selling", type = "sellCoins", target = 5000, rewards = { pearls = 20 } },
	{ id = "w_shiny_hunt", desc = "Catch 3 Shiny fish", type = "catchShiny", target = 3, rewards = { pearls = 40 } },
	{ id = "w_zone_master", desc = "Complete 50% of any zone bestiary", type = "zoneProgress", target = 50, rewards = { pearls = 25 } },
}

-- Achievements: id, name, desc, rewards, condition(profile-ish stats)
-- Conditions are evaluated by QuestService hooks using server-side stats only.
local ACHIEVEMENTS: { { id: string, name: string, desc: string, rewards: { pearls: number?, title: string? } } } = {
	{ id = "first_catch", name = "First Cast", desc = "Catch your first fish", rewards = { pearls = 5 } },
	{ id = "first_shiny", name = "Shiny Hunter", desc = "Catch your first Shiny fish", rewards = { pearls = 10, title = "Shiny Hunter" } },
	{ id = "fish_100", name = "Getting the Hang", desc = "Catch 100 fish", rewards = { pearls = 10 } },
	{ id = "fish_1000", name = "Master Angler", desc = "Catch 1,000 fish", rewards = { pearls = 25, title = "Master Angler" } },
	{ id = "coins_10k", name = "Coin Collector", desc = "Earn 10,000 coins total", rewards = { pearls = 10 } },
	{ id = "coins_100k", name = "Dock Tycoon", desc = "Earn 100,000 coins total", rewards = { pearls = 25, title = "Dock Tycoon" } },
	{ id = "night_owl", name = "Night Owl", desc = "Catch 20 fish at night", rewards = { pearls = 10, title = "Night Owl" } },
	{ id = "storm_chaser", name = "Storm Chaser", desc = "Catch 10 fish during storms", rewards = { pearls = 15, title = "Storm Chaser" } },
	{ id = "deep_diver", name = "Deep Diver", desc = "Catch 50 deep-water fish", rewards = { pearls = 15 } },
	{ id = "old_one_witness", name = "The Old One's Witness", desc = "Catch The Old One", rewards = { pearls = 50, title = "Old One's Witness" } },
	{ id = "secret_finder", name = "Isle Finder", desc = "Find the Hidden Isle of Whispers", rewards = { pearls = 20, title = "Isle Finder" } },
	{ id = "grotto_finder", name = "Grotto Diver", desc = "Find the Sunken Grotto", rewards = { pearls = 20, title = "Grotto Diver" } },
	{ id = "level_10", name = "Level 10", desc = "Reach level 10", rewards = { pearls = 10 } },
	{ id = "level_25", name = "Level 25", desc = "Reach level 25", rewards = { pearls = 20 } },
	{ id = "level_50", name = "Level 50", desc = "Reach the max level", rewards = { pearls = 40, title = "Tidebound Legend" } },
	{ id = "rod_collector", name = "Rod Collector", desc = "Own every rod", rewards = { pearls = 30, title = "Rod Collector" } },
	{ id = "zone_master", name = "Zone Master", desc = "Complete any zone bestiary 100%", rewards = { pearls = 25, title = "Zone Master" } },
	{ id = "all_zones", name = "Bestiary Master", desc = "Complete every zone bestiary 100%", rewards = { pearls = 100, title = "Bestiary Master" } },
	{ id = "contest_winner", name = "Weekly Champion", desc = "Win the weekly catch contest", rewards = { pearls = 50, title = "Weekly Champion" } },
	{ id = "pearl_earner", name = "Pearl Diver", desc = "Earn 100 pearls", rewards = { title = "Pearl Diver" } },
	{ id = "shiny_10", name = "Shiny Collector", desc = "Catch 10 Shiny fish", rewards = { pearls = 30, title = "Shiny Collector" } },
}

QuestCatalog.DAILY_POOL = DAILY_POOL
QuestCatalog.WEEKLY_POOL = WEEKLY_POOL
QuestCatalog.ACHIEVEMENTS = ACHIEVEMENTS

function QuestCatalog.GetDailyTemplate(id: string)
	for _, t  in pairs(DAILY_POOL) do
		if t.id == id then
			return t
		end
	end
	return nil
end

function QuestCatalog.GetWeeklyTemplate(id: string)
	for _, t  in pairs(WEEKLY_POOL) do
		if t.id == id then
			return t
		end
	end
	return nil
end

-- Random template from a pool, excluding ones already rolled this cycle
function QuestCatalog.RollTemplates(pool: { any }, exclude: { [string]: boolean }): { any }
	local available: { any } = {}
	for _, t  in pairs(pool) do
		if not exclude[t.id] then
			table.insert(available, t)
		end
	end
	-- Shuffle (Fisher-Yates)
	for i = #available, 2, -1 do
		local j = math.random(1, i)
		available[i], available[j] = available[j], available[i]
	end
	return available
end

-- Build a human-readable description from a template + params
function QuestCatalog.FormatDesc(template: any, params: { [string]: string }): string
	local desc = template.desc
	desc = string.gsub(desc, "{n}", tostring(template.target))
	if params and params.zone then
		desc = string.gsub(desc, "{zone}", params.zone)
	end
	if params and params.family then
		desc = string.gsub(desc, "{family}", params.family)
	end
	return desc
end

return QuestCatalog
]===]

-- ReplicatedStorage/Shared/Data/RodCatalog
local inst_ReplicatedStorage_Shared_Data_RodCatalog = ensureChain([===[ReplicatedStorage/Shared/Data/RodCatalog]===], 'ModuleScript')
inst_ReplicatedStorage_Shared_Data_RodCatalog.Source = [===[--!strict
--[[
	Tidebound — RodCatalog
	The core upgrade ladder. Each rod: luck, strength, lure speed.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Types = require(script.Parent.Parent.Types)

local RODS: { [string]: Types.RodDef } = {}

local function rod(
	id: string,
	name: string,
	cost: number,
	luck: number,
	strength: number,
	lure: number,
	unlockLevel: number,
	desc: string,
	color: Color3
): Types.RodDef
	local def: Types.RodDef = {
		id = id,
		name = name,
		cost = cost,
		luck = luck,
		strength = strength,
		lure = lure,
		unlockLevel = unlockLevel,
		desc = desc,
		color = color,
	}
	RODS[id] = def
	return def
end

rod("bamboo", "Bamboo Rod", 0, 0.00, 2, 0, 1, "The Old Salt's gift. Simple, honest, reliable.", Color3.fromRGB(180, 150, 90))
rod("river_oak", "River Oak Rod", 150, 0.03, 3, 1, 2, "Carved from driftwood. A touch more reach.", Color3.fromRGB(140, 100, 60))
rod("coral_reed", "Coral Reed Rod", 450, 0.07, 4, 2, 6, "Grows back every season, stronger each time.", Color3.fromRGB(255, 140, 160))
rod("storm_runner", "Storm Runner Rod", 1400, 0.12, 5, 3, 12, "Forged from a ship's mast that survived a hurricane.", Color3.fromRGB(90, 120, 200))
rod("ember_spine", "Ember Spine Rod", 4000, 0.18, 6, 4, 20, "Tempered in volcanic springs. Warm to the touch.", Color3.fromRGB(255, 90, 40))
rod("frostbound", "Frostbound Rod", 11000, 0.25, 7, 5, 28, "Cut from the heart of a glacier. Never thaws.", Color3.fromRGB(170, 210, 255))
rod("abyss_caller", "Abyss Caller Rod", 28000, 0.35, 8, 6, 36, "Whispers to the deep. The deep whispers back.", Color3.fromRGB(110, 70, 200))
rod("leviathan", "Leviathan Rod", 70000, 0.50, 10, 7, 45, "Woven from the sinew of a leviathan. It remembers how to fight.", Color3.fromRGB(40, 140, 120))

local RodCatalog = {}

function RodCatalog.Get(id: string): Types.RodDef?
	return RODS[id]
end

function RodCatalog.GetAll(): { [string]: Types.RodDef }
	return RODS
end

-- Rods sorted by cost (for shop display)
function RodCatalog.GetSorted(): { Types.RodDef }
	local out: { Types.RodDef } = {}
	for _, def  in pairs(RODS) do
		table.insert(out, def)
	end
	table.sort(out, function(a, b)
		return a.cost < b.cost
	end)
	return out
end

return RodCatalog
]===]

-- ReplicatedStorage/Shared/Data/ZoneCatalog
local inst_ReplicatedStorage_Shared_Data_ZoneCatalog = ensureChain([===[ReplicatedStorage/Shared/Data/ZoneCatalog]===], 'ModuleScript')
inst_ReplicatedStorage_Shared_Data_ZoneCatalog.Source = [===[--!strict
--[[
	Tidebound — ZoneCatalog
	Zone definitions + the name of the region Part the builder places in Studio.
	Region parts: anchored, transparent, CanCollide=false, named "ZoneRegion_<id>".
	Phase 2 | AI-assisted | 2026-08-02
]]

local Types = require(script.Parent.Parent.Types)

local ZONES: { [string]: Types.ZoneDef } = {
	sunshall = {
		id = "sunshall",
		name = "Sunshall Cove",
		unlockLevel = 1,
		desc = "Golden beach, calm water, and the smell of salt and story.",
		fishIds = { "sunsail_minnow", "reef_perch", "cove_carp", "striped_grunt", "golden_anchovy", "moon_koi", "sunsong_sturgeon", "gilded_bass" },
		nightFishIds = { "moon_koi" },
	},
	whisper = {
		id = "whisper",
		name = "Whisper Shallows",
		unlockLevel = 3,
		desc = "Turquoise water and kelp that hums with hidden life.",
		fishIds = { "shimmerfin", "drift_mackerel", "seagrass_snapper", "silver_carp", "whisper_lanternfish", "moonlit_koi", "kelp_serpent", "tide_hunter" },
		nightFishIds = { "whisper_lanternfish", "moonlit_koi" },
	},
	drop = {
		id = "drop",
		name = "The Drop",
		unlockLevel = 8,
		desc = "The shelf ends here. So does the light.",
		fishIds = { "deep_darter", "cliff_cod", "drop_anglerfish", "abyssal_squid", "trench_eel", "fog_wraith" },
		nightFishIds = { "abyssal_squid", "fog_wraith" },
	},
	ember = {
		id = "ember",
		name = "Ember Falls",
		unlockLevel = 15,
		desc = "Volcanic waters under a red sky. The fish here glow like coals.",
		fishIds = { "ember_trout", "ash_gar", "magma_eel", "cinder_salmon", "ember_pike", "magma_whale", "ember_leviathan", "storm_krakenling" },
		stormFishIds = { "storm_krakenling" },
	},
	frost = {
		id = "frost",
		name = "Frostreach",
		unlockLevel = 24,
		desc = "Icebergs and aurora. The cold here has teeth.",
		fishIds = { "frostling_pike", "iceback_herring", "snowcap_char", "aurora_koi", "glacier_eel", "frost_whale", "frost_leviathan", "aurora_serpent" },
		nightFishIds = { "aurora_koi", "aurora_serpent" },
	},
	abyss = {
		id = "abyss",
		name = "Abyssal Trench",
		unlockLevel = 35,
		desc = "Near-black water, bioluminescent ghosts, and the oldest things in the sea.",
		fishIds = { "trench_fangtooth", "void_lanternfish", "abyssal_angler", "gloom_serpent", "abyssal_hunter", "trench_devil", "leviathan_abyss", "stormcaller_eel", "old_one" },
		nightFishIds = { "trench_devil" },
		stormFishIds = { "stormcaller_eel" },
	},
	hidden_isles = {
		id = "hidden_isles",
		name = "Hidden Isle of Whispers",
		unlockLevel = 1,
		desc = "Behind the waterfall at Ember Falls. Nobody believes you when you find it.",
		fishIds = { "mistfin", "isle_song" },
	},
	sunken_grotto = {
		id = "sunken_grotto",
		name = "The Sunken Grotto",
		unlockLevel = 1,
		desc = "Inside a sea cave at The Drop. The water here remembers a drowned court.",
		fishIds = { "grotto_glowfin", "sunken_king" },
	},
}

-- Families that count toward "deep" knowledge (unlocks The Old One)
local DEEP_FAMILIES = {
	eel = true,
	serpent = true,
	squid = true,
	angler = true,
	abyss = true,
	fang = true,
	devil = true,
	wraith = true,
	glow = true,
	old = true,
}

local ZoneCatalog = {}

function ZoneCatalog.Get(id: string): Types.ZoneDef?
	return ZONES[id]
end

function ZoneCatalog.GetAll(): { [string]: Types.ZoneDef }
	return ZONES
end

function ZoneCatalog.IsDeepFamily(family: string): boolean
	return DEEP_FAMILIES[family] == true
end

-- Region part name for a zone (builder places these in Studio)
function ZoneCatalog.RegionPartName(zoneId: string): string
	return "ZoneRegion_" .. zoneId
end

return ZoneCatalog
]===]

-- ReplicatedStorage/Shared/Remotes
local inst_ReplicatedStorage_Shared_Remotes = ensureChain([===[ReplicatedStorage/Shared/Remotes]===], 'ModuleScript')
inst_ReplicatedStorage_Shared_Remotes.Source = [===[--!strict
--[[
	Tidebound — Remotes
	Single RemoteEvent per direction with a typed message envelope.
	Security: ALL messages funnel through one router and are validated server-side.
	Phase 2 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ensure the remotes folder exists (idempotent on both client and server)
local folder = ReplicatedStorage:FindFirstChild("TideboundRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "TideboundRemotes"
	folder.Parent = ReplicatedStorage
end

local c2s = folder:FindFirstChild("ClientToServer")
if not c2s then
	c2s = Instance.new("RemoteEvent")
	c2s.Name = "ClientToServer"
	c2s.Parent = folder
end

local s2c = folder:FindFirstChild("ServerToClient")
if not s2c then
	s2c = Instance.new("RemoteEvent")
	s2c.Name = "ServerToClient"
	s2c.Parent = folder
end

local Remotes = {
	ClientToServer = c2s :: RemoteEvent,
	ServerToClient = s2c :: RemoteEvent,
}

-- Client -> Server
function Remotes:SendToServer(message)
	self.ClientToServer:FireServer(message)
end

-- Server -> one client
function Remotes:SendToClient(player: Player, message)
	self.ServerToClient:FireClient(player, message)
end

-- Server -> all clients
function Remotes:SendToAll(message)
	self.ServerToClient:FireAllClients(message)
end

-- Server: subscribe to client messages. Handler(player, message).
function Remotes:OnServerMessage(handler: (Player, any) -> ())
	return self.ClientToServer.OnServerEvent:Connect(function(player, message)
		handler(player, message)
	end)
end

-- Client: subscribe to server messages. Handler(message).
function Remotes:OnClientMessage(handler: (any) -> ())
	return self.ServerToClient.OnClientEvent:Connect(function(message)
		handler(message)
	end)
end

return Remotes
]===]

-- ReplicatedStorage/Shared/Types
local inst_ReplicatedStorage_Shared_Types = ensureChain([===[ReplicatedStorage/Shared/Types]===], 'ModuleScript')
inst_ReplicatedStorage_Shared_Types.Source = [===[--!strict
--[[
	Tidebound — Shared Types
	Single source of type truth for both server and client.
	Phase 2 | AI-assisted | 2026-08-02
]]

export type Rarity = "common" | "uncommon" | "rare" | "epic" | "legendary" | "mythic"

export type FishDef = {
	id: string,
	name: string,
	rarity: Rarity,
	baseValue: number, -- coins at 1 kg
	minWeight: number, -- kg
	maxWeight: number, -- kg
	xp: number,
	zone: string,
	time: "any" | "night",
	family: string,
	bait: string?, -- preferred bait id (worm/shrimp/squid/golden)
	desc: string,
	color: Color3,
	accent: Color3,
	bodyScale: number, -- display length multiplier
	stormOnly: boolean?,
}

export type RodDef = {
	id: string,
	name: string,
	cost: number,
	luck: number, -- 0..1 additive
	strength: number, -- 2..10
	lure: number, -- seconds removed from bite wait
	unlockLevel: number,
	desc: string,
	color: Color3,
}

export type ZoneDef = {
	id: string,
	name: string,
	unlockLevel: number,
	desc: string,
	fishIds: { string },
	nightFishIds: { string }?,
	stormFishIds: { string }?,
}

export type InventoryFish = {
	uid: number,
	fishId: string,
	weight: number, -- kg (1 decimal)
	shiny: boolean,
	caughtAt: number, -- os.time()
}

export type BestiaryEntry = {
	caught: number,
	shiny: boolean,
	maxWeight: number,
}

export type QuestProgress = {
	templateId: string,
	params: { [string]: string }, -- e.g. { zone = "drop" }
	progress: number,
	done: boolean,
	claimed: boolean,
}

export type Stats = {
	totalCatch: number,
	totalCoinsEarned: number,
	totalPearlsEarned: number,
	nightFish: number,
	stormFish: number,
	shinyFish: number,
	deepFish: number,
	epicPlus: number,
	zoneCounts: { [string]: number },
	familyCounts: { [string]: number },
	bestCatch: { weight: number, fishId: string, rarity: Rarity, weekKey: string },
}

export type ProfileData = {
	v: number,
	coins: number,
	pearls: number,
	xp: number,
	level: number,
	streak: number,
	streakLastDay: string, -- YYYY-MM-DD (UTC)
	rods: { [string]: boolean },
	equippedRod: string,
	baits: { [string]: number },
	inventory: { InventoryFish },
	nextUid: number,
	bestiary: { [string]: BestiaryEntry },
	dailyQuests: { QuestProgress },
	weeklyQuests: { QuestProgress },
	questDay: string, -- YYYY-MM-DD
	questWeek: string, -- YYYY-Www
	achievements: { [string]: boolean },
	titles: { [string]: boolean },
	equippedTitle: string?,
	stats: Stats,
	cosmetics: { bobber: string, trail: string?, aura: string?, rodSkin: string?, nameColor: string? },
	flags: {
		tutorialDone: boolean,
		autoSell: string?, -- max rarity auto-sold, or nil
		equippedBait: string?, -- worm/shrimp/squid/golden, nil = none
		ownedPasses: { [string]: boolean },
		tokens: number, -- auto-reel tokens
		xpBoostUntil: number, -- os.time()
		chestsClaimed: { [string]: boolean },
		prestige: number,
		rerollsUsed: number, -- daily quest rerolls
		zoneRewards: { [string]: boolean }, -- 100% bestiary rewards claimed
		receipts: { [string]: boolean }, -- purchase idempotency
		contestWins: number,
		starterClaimed: boolean,
		invUpgradeTier: number, -- 0..3 inventory upgrades bought
		cosmeticsOwned: { [string]: boolean },
	},
}

export type C2SMessage = { type: string, payload: any }
export type S2CMessage = { type: string, payload: any }

-- Public snapshot sent to the client on join (never the raw profile)
export type PublicProfile = {
	coins: number,
	pearls: number,
	xp: number,
	level: number,
	equippedRod: string,
	rods: { [string]: boolean },
	baits: { [string]: number },
	inventory: { InventoryFish },
	bestiary: { [string]: BestiaryEntry },
	dailyQuests: { QuestProgress },
	weeklyQuests: { QuestProgress },
	achievements: { [string]: boolean },
	titles: { [string]: boolean },
	equippedTitle: string?,
	stats: Stats,
	cosmetics: any,
	flags: any,
}

return {}
]===]

-- ReplicatedStorage/Shared/Util
local inst_ReplicatedStorage_Shared_Util = ensureChain([===[ReplicatedStorage/Shared/Util]===], 'ModuleScript')
inst_ReplicatedStorage_Shared_Util.Source = [===[--!strict
--[[
	Tidebound — Util
	Pure, dependency-free helpers shared by server and client.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Util = {}

-- Clamp a number to [min, max]
function Util.clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

-- Round to N decimals
function Util.round(value: number, decimals: number): number
	local mult = 10 ^ decimals
	return math.floor(value * mult + 0.5) / mult
end

-- Format big numbers: 1234 -> "1.2K", 2500000 -> "2.5M"
function Util.formatNumber(value: number): string
	if value >= 1000000 then
		return string.format("%.1fM", value / 1000000)
	elseif value >= 1000 then
		return string.format("%.1fK", value / 1000)
	end
	return tostring(math.floor(value))
end

-- Weighted random pick from { key = weight }. Returns key or nil if empty.
function Util.weightedPick(weights: { [string]: number }): string?
	local total = 0
	for _, w  in pairs(weights) do
		total += w
	end
	if total <= 0 then
		return nil
	end
	local roll = math.random() * total
	for key, w  in pairs(weights) do
		roll -= w
		if roll <= 0 then
			return key
		end
	end
	-- Fallback: last key (floating point safety)
	local last: string? = nil
	for key, _  in pairs(weights) do
		last = key
	end
	return last
end

-- True with probability p (0..1)
function Util.rollChance(p: number): boolean
	return math.random() < p
end

-- UTC date key "YYYY-MM-DD"
function Util.todayKey(): string
	return os.date("!%Y-%m-%d", os.time())
end

-- UTC week key "YYYY-Www" (matches the same week everywhere on the server)
function Util.weekKey(): string
	return os.date("!%Y-W%W", os.time())
end

-- Yesterday's UTC date key (for streak logic)
function Util.yesterdayKey(): string
	return os.date("!%Y-%m-%d", os.time() - 86400)
end

-- Safe number guard: nil/NaN/Infinity -> fallback
function Util.safeNumber(value: any, fallback: number): number
	if typeof(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge then
		return value
	end
	return fallback
end

-- Shallow copy of a table (catalogs are immutable; copies are for display)
function Util.shallowCopy<T>(t: { [string]: T }): { [string]: T }
	local out: { [string]: T } = {}
	for k, v  in pairs(t) do
		out[k] = v
	end
	return out
end

-- List of keys in a table
function Util.keys(t: { [any]: any }): { any }
	local out = {}
	for k, _  in pairs(t) do
		table.insert(out, k)
	end
	return out
end

-- Weight roll for a fish: skewed toward the low end (min + rand^1.7 * range)
function Util.rollWeight(min: number, max: number): number
	local t = math.random() ^ 1.7
	return Util.round(min + t * (max - min), 1)
end

-- XP needed to advance FROM `level` TO `level + 1`
function Util.xpForLevel(level: number, xpBase: number, exponent: number): number
	return math.floor(xpBase * (level ^ exponent))
end

return Util
]===]

-- ServerScriptService/Bootstrap
local inst_ServerScriptService_Bootstrap = ensureChain([===[ServerScriptService/Bootstrap]===], 'Script')
inst_ServerScriptService_Bootstrap.Source = [===[--!strict
--[[
	Tidebound — Bootstrap (server)
	Service lifecycle manager + message router.
	1. Require all services. 2. Init all. 3. Start all. 4. Route client messages.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
]===]

-- ServerScriptService/Services
local inst_ServerScriptService_Services = ensureChain([===[ServerScriptService/Services]===], 'Folder')

-- ServerScriptService/Services/AmbienceService
local inst_ServerScriptService_Services_AmbienceService = ensureChain([===[ServerScriptService/Services/AmbienceService]===], 'Script')
inst_ServerScriptService_Services_AmbienceService.Source = [===[--!strict
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
]===]

-- ServerScriptService/Services/DataService
local inst_ServerScriptService_Services_DataService = ensureChain([===[ServerScriptService/Services/DataService]===], 'Script')
inst_ServerScriptService_Services_DataService.Source = [===[--!strict
--[[
	Tidebound — DataService
	Player profile lifecycle: load on join, autosave, save on leave/shutdown.
	Single owner of the DataStore. All other services read/write through profiles.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)

local DataService = {}
DataService.Name = "DataService"

local playersAlive = true -- set false on shutdown; autosave loops check it

local store = DataStoreService:GetDataStore("TideboundSaves")
local profiles: { [number]: { player: Player, data: Types.ProfileData, dirty: boolean } } = {}
local profileReadyCallbacks: { ((Player, Types.ProfileData) -> ()) } = {}

-- ── Default profile for new players ──────────────────────────────────────

function DataService:NewData(): Types.ProfileData
	local data: Types.ProfileData = {
		v = Config.SAVE_VERSION,
		coins = 0,
		pearls = 0,
		xp = 0,
		level = 1,
		streak = 0,
		streakLastDay = "",
		rods = { bamboo = true },
		equippedRod = "bamboo",
		baits = { worm = 3 },
		inventory = {},
		nextUid = 1,
		bestiary = {},
		dailyQuests = {},
		weeklyQuests = {},
		questDay = "",
		questWeek = "",
		achievements = {},
		titles = {},
		equippedTitle = nil,
		stats = {
			totalCatch = 0,
			totalCoinsEarned = 0,
			totalPearlsEarned = 0,
			nightFish = 0,
			stormFish = 0,
			shinyFish = 0,
			deepFish = 0,
			epicPlus = 0,
			zoneCounts = {},
			familyCounts = {},
			bestCatch = { weight = 0, fishId = "", rarity = "common", weekKey = "" },
		},
		cosmetics = { bobber = "classic" },
		flags = {
			tutorialDone = false,
			autoSell = nil,
			equippedBait = nil,
			ownedPasses = {},
			tokens = 0,
			xpBoostUntil = 0,
			chestsClaimed = {},
			prestige = 0,
			rerollsUsed = 0,
			zoneRewards = {},
			receipts = {},
			contestWins = 0,
			starterClaimed = false,
			invUpgradeTier = 0,
			cosmeticsOwned = {},
		},
	}
	return data
end

-- Merge a decoded save into a fresh default (schema evolution + corruption defense)
function DataService:Sanitize(raw: any): Types.ProfileData
	local data = self:NewData()
	if typeof(raw) ~= "table" then
		return data
	end
	-- Top-level scalars
	data.coins = Util.safeNumber(raw.coins, 0)
	data.pearls = Util.safeNumber(raw.pearls, 0)
	data.xp = Util.safeNumber(raw.xp, 0)
	data.level = math.clamp(Util.safeNumber(raw.level, 1), 1, Config.MAX_LEVEL)
	data.streak = math.clamp(Util.safeNumber(raw.streak, 0), 0, 7)
	if typeof(raw.streakLastDay) == "string" then
		data.streakLastDay = raw.streakLastDay
	end
	if typeof(raw.equippedRod) == "string" and RodCatalog.Get(raw.equippedRod) then
		data.equippedRod = raw.equippedRod
	end
	if typeof(raw.rods) == "table" then
		for id, owned  in pairs(raw.rods) do
			if owned and RodCatalog.Get(id) then
				data.rods[id] = true
			end
		end
	end
	if typeof(raw.baits) == "table" then
		for id, count  in pairs(raw.baits) do
			if Config.BAITS[id] and Util.safeNumber(count, 0) > 0 then
				data.baits[id] = math.floor(Util.safeNumber(count, 0))
			end
		end
	end
	if typeof(raw.inventory) == "table" then
		for _, item  in pairs(raw.inventory) do
			if typeof(item) ~= "table" or #data.inventory >= Config.INVENTORY_CAP then
				continue
			end
			local uid = Util.safeNumber(item.uid, 0)
			local fishId = typeof(item.fishId) == "string" and item.fishId or ""
			local weight = Util.safeNumber(item.weight, 0)
			if uid > 0 and fishId ~= "" and weight > 0 then
				table.insert(data.inventory, {
					uid = uid,
					fishId = fishId,
					weight = weight,
					shiny = item.shiny == true,
					caughtAt = Util.safeNumber(item.caughtAt, os.time()),
				})
				data.nextUid = math.max(data.nextUid, uid + 1)
			end
		end
	end
	if typeof(raw.bestiary) == "table" then
		for fishId, entry  in pairs(raw.bestiary) do
			if typeof(entry) == "table" then
				data.bestiary[fishId] = {
					caught = math.floor(Util.safeNumber(entry.caught, 0)),
					shiny = entry.shiny == true,
					maxWeight = Util.safeNumber(entry.maxWeight, 0),
				}
			end
		end
	end
	if typeof(raw.quests) == "table" then
		data.dailyQuests = raw.quests.daily or {}
		data.weeklyQuests = raw.quests.weekly or {}
	end
	if typeof(raw.questDay) == "string" then
		data.questDay = raw.questDay
	end
	if typeof(raw.questWeek) == "string" then
		data.questWeek = raw.questWeek
	end
	if typeof(raw.achievements) == "table" then
		for id, done  in pairs(raw.achievements) do
			if done then
				data.achievements[id] = true
			end
		end
	end
	if typeof(raw.titles) == "table" then
		for id, owned  in pairs(raw.titles) do
			if owned then
				data.titles[id] = true
			end
		end
	end
	if typeof(raw.equippedTitle) == "string" then
		data.equippedTitle = raw.equippedTitle
	end
	if typeof(raw.stats) == "table" then
		local s = raw.stats
		data.stats.totalCatch = math.floor(Util.safeNumber(s.totalCatch, 0))
		data.stats.totalCoinsEarned = math.floor(Util.safeNumber(s.totalCoinsEarned, 0))
		data.stats.totalPearlsEarned = math.floor(Util.safeNumber(s.totalPearlsEarned, 0))
		data.stats.nightFish = math.floor(Util.safeNumber(s.nightFish, 0))
		data.stats.stormFish = math.floor(Util.safeNumber(s.stormFish, 0))
		data.stats.shinyFish = math.floor(Util.safeNumber(s.shinyFish, 0))
		data.stats.deepFish = math.floor(Util.safeNumber(s.deepFish, 0))
		data.stats.epicPlus = math.floor(Util.safeNumber(s.epicPlus, 0))
		if typeof(s.zoneCounts) == "table" then
			for k, v  in pairs(s.zoneCounts) do
				data.stats.zoneCounts[k] = math.floor(Util.safeNumber(v, 0))
			end
		end
		if typeof(s.familyCounts) == "table" then
			for k, v  in pairs(s.familyCounts) do
				data.stats.familyCounts[k] = math.floor(Util.safeNumber(v, 0))
			end
		end
		if typeof(s.bestCatch) == "table" then
			data.stats.bestCatch = {
				weight = Util.safeNumber(s.bestCatch.weight, 0),
				fishId = typeof(s.bestCatch.fishId) == "string" and s.bestCatch.fishId or "",
				rarity = "common",
				weekKey = typeof(s.bestCatch.weekKey) == "string" and s.bestCatch.weekKey or "",
			}
		end
	end
	if typeof(raw.cosmetics) == "table" then
		data.cosmetics = raw.cosmetics
	end
	if typeof(raw.flags) == "table" then
		local f = raw.flags
		data.flags.tutorialDone = f.tutorialDone == true
		if typeof(f.autoSell) == "string" then
			data.flags.autoSell = f.autoSell
		end
		if typeof(f.equippedBait) == "string" and Config.BAITS[f.equippedBait] then
			data.flags.equippedBait = f.equippedBait
		end
		if typeof(f.ownedPasses) == "table" then
			for k, v  in pairs(f.ownedPasses) do
				if v then
					data.flags.ownedPasses[k] = true
				end
			end
		end
		data.flags.tokens = math.floor(Util.safeNumber(f.tokens, 0))
		data.flags.xpBoostUntil = math.floor(Util.safeNumber(f.xpBoostUntil, 0))
		if typeof(f.chestsClaimed) == "table" then
			for k, v  in pairs(f.chestsClaimed) do
				if v then
					data.flags.chestsClaimed[k] = true
				end
			end
		end
		data.flags.prestige = math.floor(Util.safeNumber(f.prestige, 0))
		data.flags.rerollsUsed = math.floor(Util.safeNumber(f.rerollsUsed, 0))
		if typeof(f.zoneRewards) == "table" then
			for k, v  in pairs(f.zoneRewards) do
				if v then
					data.flags.zoneRewards[k] = true
				end
			end
		end
		if typeof(f.receipts) == "table" then
			for k, v  in pairs(f.receipts) do
				if v then
					data.flags.receipts[k] = true
				end
			end
		end
		data.flags.contestWins = math.floor(Util.safeNumber(f.contestWins, 0))
		data.flags.starterClaimed = f.starterClaimed == true
		data.flags.invUpgradeTier = math.clamp(math.floor(Util.safeNumber(f.invUpgradeTier, 0)), 0, 3)
		if typeof(f.cosmeticsOwned) == "table" then
			for k, v in pairs(f.cosmeticsOwned) do
				if v then
					data.flags.cosmeticsOwned[k] = true
				end
			end
		end
	end
	return data
end

-- ── Load / save ──────────────────────────────────────────────────────────

function DataService:LoadProfile(player: Player): Types.ProfileData
	local key = Config.SAVE_KEY_PREFIX .. Config.SAVE_VERSION .. "_" .. player.UserId
	local ok, result = pcall(function()
		return store:GetAsync(key)
	end)
	if ok and result ~= nil then
		local decodeOk, decoded = pcall(function()
			return HttpService:JSONDecode(result)
		end)
		if decodeOk then
			return self:Sanitize(decoded)
		end
		warn("[DataService] Corrupt save for " .. player.Name .. ", using defaults")
	end
	return self:NewData()
end

function DataService:SaveProfile(player: Player): boolean
	local profile = profiles[player.UserId]
	if not profile then
		return false
	end
	local key = Config.SAVE_KEY_PREFIX .. Config.SAVE_VERSION .. "_" .. player.UserId
	local encodeOk, encoded = pcall(function()
		return HttpService:JSONEncode(profile.data)
	end)
	if not encodeOk then
		warn("[DataService] Encode failed for " .. player.Name)
		return false
	end
	local attempts = { 0, 1, 5, 15 }
	for i, delay  in pairs(attempts) do
		if i > 1 then
			task.wait(delay)
		end
		local ok, err = pcall(function()
			store:SetAsync(key, encoded)
		end)
		if ok then
			profile.dirty = false
			return true
		end
		warn("[DataService] Save retry " .. i .. " failed for " .. player.Name .. ": " .. tostring(err))
	end
	return false
end

-- ── Public API ───────────────────────────────────────────────────────────

function DataService:GetProfile(player: Player)
	return profiles[player.UserId]
end

function DataService:GetData(player: Player): Types.ProfileData?
	local profile = profiles[player.UserId]
	if profile then
		return profile.data
	end
	return nil
end

function DataService:MarkDirty(player: Player)
	local profile = profiles[player.UserId]
	if profile then
		profile.dirty = true
	end
end

function DataService:OnProfileReady(callback: (Player, Types.ProfileData) -> ())
	table.insert(profileReadyCallbacks, callback)
end

function DataService:SaveAll()
	for _, profile  in pairs(profiles) do
		self:SaveProfile(profile.player)
	end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function DataService:Init(ctx)
	self.ctx = ctx
end

function DataService:Start()
	local loadedPlayers: { [number]: boolean } = {}

	local function onPlayerAdded(player: Player)
		if loadedPlayers[player.UserId] then
			return
		end
		loadedPlayers[player.UserId] = true
		local data = self:LoadProfile(player)
		profiles[player.UserId] = { player = player, data = data, dirty = false }
		for _, cb  in pairs(profileReadyCallbacks) do
			task.spawn(cb, player, data)
		end
		-- Autosave loop
		task.spawn(function()
			while playersAlive do
				task.wait(Config.AUTOSAVE_INTERVAL)
				local profile = profiles[player.UserId]
				if profile and profile.dirty then
					self:SaveProfile(player)
				end
			end
		end)
	end

	local function onPlayerRemoving(player: Player)
		-- Persist before the player is destroyed.
		local profile = profiles[player.UserId]
		if profile then
			self:SaveProfile(player)
		end
		profiles[player.UserId] = nil
		loadedPlayers[player.UserId] = nil
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	-- Load players already present at boot AFTER other services have
	-- registered their profile-ready callbacks (they Start after us).
	task.spawn(function()
		task.wait(1)
		for _, player  in pairs(Players:GetPlayers()) do
			onPlayerAdded(player)
		end
	end)
end

function DataService:Stop()
	playersAlive = false
	self:SaveAll()
	task.wait(1)
end

return DataService
]===]

-- ServerScriptService/Services/EconomyService
local inst_ServerScriptService_Services_EconomyService = ensureChain([===[ServerScriptService/Services/EconomyService]===], 'Script')
inst_ServerScriptService_Services_EconomyService.Source = [===[--!strict
--[[
	Tidebound — EconomyService
	The ONLY place currencies change. All grants/spends are validated here.
	Guards: caps, non-negativity, integer enforcement, anomaly logging.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local EconomyService = {}
EconomyService.Name = "EconomyService"

local function validAmount(amount: any): boolean
	return typeof(amount) == "number" and amount == amount and amount > 0 and amount < 1e9
end

-- ── Coins ────────────────────────────────────────────────────────────────

function EconomyService:AddCoins(player: Player, amount: number, reason: string): number
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return 0
	end
	data.coins = math.min(Config.COIN_CAP, math.floor(data.coins + amount))
	data.stats.totalCoinsEarned = math.min(Config.COIN_CAP * 2, data.stats.totalCoinsEarned + math.floor(amount))
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	if amount > 10000 then
		warn("[Economy] Large coin grant " .. player.Name .. " +" .. amount .. " (" .. reason .. ")")
	end
	return data.coins
end

function EconomyService:SpendCoins(player: Player, amount: number, reason: string): boolean
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return false
	end
	if data.coins < amount then
		self.ctx.Services.SecurityService:Flag(player, "spend with insufficient coins (" .. reason .. ")")
		return false
	end
	data.coins = math.floor(data.coins - amount)
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return true
end

-- ── Pearls ───────────────────────────────────────────────────────────────

function EconomyService:AddPearls(player: Player, amount: number, reason: string): number
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return 0
	end
	data.pearls = math.min(Config.PEARL_CAP, math.floor(data.pearls + amount))
	data.stats.totalPearlsEarned = math.min(Config.PEARL_CAP * 2, data.stats.totalPearlsEarned + math.floor(amount))
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return data.pearls
end

function EconomyService:SpendPearls(player: Player, amount: number, reason: string): boolean
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return false
	end
	if data.pearls < amount then
		self.ctx.Services.SecurityService:Flag(player, "spend with insufficient pearls (" .. reason .. ")")
		return false
	end
	data.pearls = math.floor(data.pearls - amount)
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return true
end

-- ── XP & levels ──────────────────────────────────────────────────────────

function EconomyService:AddXP(player: Player, amount: number, reason: string): { newLevel: number, leveledUp: boolean, coinsGranted: number }
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or not validAmount(amount) then
		return { newLevel = data and data.level or 1, leveledUp = false, coinsGranted = 0 }
	end
	local xpGained = math.floor(amount)
	data.xp = data.xp + xpGained
	local leveledUp = false
	local coinsGranted = 0
	while data.level < Config.MAX_LEVEL do
		local needed = Util.xpForLevel(data.level, Config.XP_BASE, Config.XP_EXPONENT)
		if data.xp < needed then
			break
		end
		data.xp -= needed
		data.level += 1
		leveledUp = true
		coinsGranted += Config.LEVEL_UP_COINS
	end
	if leveledUp then
		data.coins = math.min(Config.COIN_CAP, data.coins + coinsGranted)
		Remotes:SendToClient(player, { type = "LevelUp", payload = { level = data.level, coinsGranted = coinsGranted } })
		local questService = self.ctx.Services.QuestService
		if questService then
			questService:OnLevelUp(player, data.level)
		end
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:Sync(player)
	return { newLevel = data.level, leveledUp = leveledUp, coinsGranted = coinsGranted }
end

-- ── State sync ───────────────────────────────────────────────────────────

-- Push the public subset of the profile to the client (change-based, throttled by caller)
function EconomyService:Sync(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	Remotes:SendToClient(player, {
		type = "StateSync",
		payload = {
			coins = data.coins,
			pearls = data.pearls,
			xp = data.xp,
			level = data.level,
			equippedRod = data.equippedRod,
			rods = data.rods,
			baits = data.baits,
			equippedBait = data.flags.equippedBait,
			tokens = data.flags.tokens,
			xpBoostUntil = data.flags.xpBoostUntil,
			invUpgradeTier = data.flags.invUpgradeTier,
		},
	})
end

function EconomyService:Init(ctx)
	self.ctx = ctx
end

function EconomyService:Start()
end

function EconomyService:Stop()
end

return EconomyService
]===]

-- ServerScriptService/Services/EventService
local inst_ServerScriptService_Services_EventService = ensureChain([===[ServerScriptService/Services/EventService]===], 'Script')
inst_ServerScriptService_Services_EventService.Source = [===[--!strict
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
]===]

-- ServerScriptService/Services/FishingService
local inst_ServerScriptService_Services_FishingService = ensureChain([===[ServerScriptService/Services/FishingService]===], 'Script')
inst_ServerScriptService_Services_FishingService.Source = [===[--!strict
--[[
	Tidebound — FishingService
	The heart of the game. Server-authoritative cast → bite → reel → catch.
	- Server owns ALL RNG (fish pick, shiny roll, weight, timing).
	- Client only sends intents: Cast, ReelHold, AutoReel.
	- Reel minigame is simulated on the server at Config.REEL_TICK granularity.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)
local CosmeticsCatalog = require(ReplicatedStorage.Shared.Data.CosmeticsCatalog)

local FishingService = {}
FishingService.Name = "FishingService"

-- ── State ────────────────────────────────────────────────────────────────

type CastState = {
	player: Player,
	bobber: Part,
	zoneId: string,
	phase: "waiting" | "reeling",
	waitUntil: number,
	fishId: string,
	fishName: string,
	rarity: Types.Rarity,
	shiny: boolean,
	weight: number,
	progress: number,
	tension: number,
	holding: boolean,
	progressRate: number,
	tensionRate: number,
	lastSend: number,
	golden: boolean,
}

local casts: { [number]: CastState } = {}
local lastCastTime: { [number]: number } = {}
local zoneRegions: { [string]: BasePart? } = {}
local warnedRegions = false

-- ── Zone helpers ─────────────────────────────────────────────────────────

function FishingService:RefreshRegions()
	zoneRegions = {}
	for zoneId  in pairs(ZoneCatalog.GetAll()) do
		zoneRegions[zoneId] = Workspace:FindFirstChild(ZoneCatalog.RegionPartName(zoneId)) :: BasePart?
	end
	warnedRegions = false
end

function FishingService:GetZoneAt(position: Vector3): string?
	for zoneId, region  in pairs(zoneRegions) do
		if region then
			local localPos = region.CFrame:PointToObjectSpace(position)
			local size = region.Size
			if math.abs(localPos.X) <= size.X / 2 and math.abs(localPos.Y) <= size.Y / 2 and math.abs(localPos.Z) <= size.Z / 2 then
				return zoneId
			end
		end
	end
	return nil
end

-- ── Fish picking (server-only RNG) ───────────────────────────────────────

function FishingService:PickFish(zoneId: string, data: Types.ProfileData, extraLuck: number?): { fishId: string, shiny: boolean, weight: number }
	local eventService = self.ctx.Services.EventService
	local isNight = eventService and eventService:GetTimeOfDay() == "night" or false
	local isStorm = eventService and eventService:IsStorm() or false
	extraLuck = extraLuck or 0

	local candidates = FishCatalog.GetZoneFish(zoneId, isNight, isStorm)
	if #candidates == 0 then
		return { fishId = "sunsail_minnow", shiny = false, weight = 0.5 } -- safety fallback
	end

	-- Luck stack (capped)
	local rod = RodCatalog.Get(data.equippedRod)
	local totalLuck = (rod and rod.luck or 0) + extraLuck
	if data.flags.ownedPasses.lucky_charm then
		totalLuck += Config.LUCKY_CHARM_LUCK
	end
	if isNight then
		totalLuck += Config.NIGHT_LUCK
	end
	local bait = data.flags.equippedBait
	local isGolden = bait == "golden"
	if isGolden then
		totalLuck += Config.GOLDEN_LURE_LUCK
	end

	-- Weights per fish
	local weights: { [string]: number } = {}
	for _, def  in pairs(candidates) do
		local base = Config.RARITY_WEIGHTS[def.rarity] or 1
		local w = base
		local idx = Config.RARITY_INDEX[def.rarity] or 1
		if idx >= 4 and totalLuck > 0 then
			w = base * Util.clamp(1 + totalLuck, 1, Config.LUCK_CAP)
		end
		-- Bait preference: double the family's weight
		if bait and def.bait == bait then
			w *= Config.BAIT_FAMILY_MULT
		end
		if isGolden then
			w *= Config.GOLDEN_LURE_WEIGHT_MULT
		end
		weights[def.id] = w
	end

	-- The Old One is NEVER in the normal loot table — it only appears via its
	-- secret trigger (50 deep-water fish caught, then a 2% roll). This keeps it
	-- a discovered secret rather than an ordinary mythic.
	weights["old_one"] = nil
	local pickedId = Util.weightedPick(weights)
	if zoneId == "abyss" and data.stats.deepFish >= 50 and Util.rollChance(0.02) then
		pickedId = "old_one"
	end
	local def = FishCatalog.Get(pickedId or "sunsail_minnow")
	if not def then
		def = FishCatalog.Get("sunsail_minnow") :: Types.FishDef
	end

	-- Weight roll (skewed small); golden lure adds heft
	local weight = Util.rollWeight(def.minWeight, def.maxWeight)
	if isGolden then
		weight = Util.round(weight * Config.GOLDEN_LURE_WEIGHT_MULT, 1)
	end

	local shiny = Util.rollChance(Config.SHINY_CHANCE)
	return { fishId = def.id, shiny = shiny, weight = weight }
end

-- ── Cast (intent from client) ────────────────────────────────────────────

function FishingService:HandleCast(player: Player, payload: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local uid = player.UserId

	-- State + cooldown
	if casts[uid] then
		return
	end
	local now = os.clock()
	if (lastCastTime[uid] or 0) + Config.CAST_COOLDOWN > now then
		return
	end

	-- Payload validation
	local dir = payload and payload.dir
	local power = payload and payload.power
	if typeof(dir) ~= "Vector3" then
		self.ctx.Services.SecurityService:Flag(player, "cast: bad dir")
		return
	end
	if dir.Magnitude < 0.4 or dir.Magnitude > 2.0 then
		self.ctx.Services.SecurityService:Flag(player, "cast: bad magnitude")
		return
	end
	power = Util.clamp(Util.safeNumber(power, 0.5), 0, 1)

	-- Position validation (must be inside a fishing region)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end
	local zoneId = self:GetZoneAt(root.Position)
	if not zoneId then
		return
	end

	-- Rod check
	local rod = RodCatalog.Get(data.equippedRod)
	if not rod or not data.rods[data.equippedRod] then
		return
	end

	-- Consume bait (equipped bait, 1 per cast; Golden Lure Pass makes golden free)
	local equippedBait = data.flags.equippedBait
	if equippedBait then
		local count = data.baits[equippedBait] or 0
		if count <= 0 and not (equippedBait == "golden" and data.flags.ownedPasses.golden_lure_pass) then
			data.flags.equippedBait = nil
		elseif count > 0 then
			data.baits[equippedBait] = count - 1
			if data.baits[equippedBait] == 0 and not (equippedBait == "golden" and data.flags.ownedPasses.golden_lure_pass) then
				data.flags.equippedBait = nil
			end
			self.ctx.Services.DataService:MarkDirty(player)
		end
	end

	-- Bobber (with cosmetic colors + trail)
	local bobber = Instance.new("Part")
	bobber.Name = "Bobber_" .. player.Name
	bobber.Size = Vector3.new(0.8, 0.8, 0.8)
	bobber.Shape = Enum.PartType.Ball
	bobber.Material = Enum.Material.Neon
	local bobberColor = Color3.fromRGB(255, 220, 80)
	local bobberDef = data.cosmetics.bobber and CosmeticsCatalog.Get(data.cosmetics.bobber)
	if bobberDef then
		bobberColor = bobberDef.color
	end
	bobber.Color = bobberColor
	bobber.Anchored = true
	bobber.CanCollide = false
	bobber.CanQuery = false
	bobber.CanTouch = false
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = bobber
	local trailDef = data.cosmetics.trail and CosmeticsCatalog.Get(data.cosmetics.trail)
	if trailDef then
		local pe = Instance.new("ParticleEmitter")
		pe.Name = "TrailFX"
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Rate = 30
		pe.Lifetime = NumberRange.new(0.4, 0.9)
		pe.Speed = NumberRange.new(0.5, 2)
		pe.Size = NumberSequence.new(0.08, 0.28)
		pe.Transparency = NumberSequence.new(0.3, 1)
		pe.Color = ColorSequence.new(trailDef.color)
		pe.Parent = bobber
	end
	local castDist = 12 + 18 * power
	local targetPos = root.Position + dir.Unit * castDist
	bobber.CFrame = CFrame.new(targetPos.X, Config.WATER_Y + 0.6, targetPos.Z)
	bobber.Parent = Workspace

	-- State
	local waitTime = Util.clamp(
		math.random() * (Config.WAIT_MAX - Config.WAIT_MIN) + Config.WAIT_MIN - rod.lure,
		Config.WAIT_FLOOR,
		Config.WAIT_MAX
	)
	casts[uid] = {
		player = player,
		bobber = bobber,
		zoneId = zoneId,
		phase = "waiting",
		waitUntil = now + waitTime,
		fishId = "",
		fishName = "",
		rarity = "common",
		shiny = false,
		weight = 0,
		progress = 0,
		tension = 0,
		holding = false,
		progressRate = 0,
		tensionRate = 0,
		lastSend = 0,
		golden = false,
	}
	lastCastTime[uid] = now

	-- Simulation loop
	task.spawn(function()
		self:RunCast(uid)
	end)
end

-- ── Cast simulation ──────────────────────────────────────────────────────

function FishingService:RunCast(uid: number)
	local state = casts[uid]
	if not state then
		return
	end
	local data = self.ctx.Services.DataService:GetData(state.player)
	local lastTick = os.clock()
	while casts[uid] do
		task.wait(Config.REEL_TICK)
		local now = os.clock()
		local dt = now - lastTick
		lastTick = now
		state = casts[uid]
		if not state then
			return
		end
		data = data or self.ctx.Services.DataService:GetData(state.player)
		if not data then
			self:Cleanup(uid, false)
			return
		end

		if state.phase == "waiting" then
			if now >= state.waitUntil then
				self:StartBite(uid)
			end
		elseif state.phase == "reeling" then
			-- Anti-exploit: player must stay near their own bobber
			local character = state.player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not root then
				self:Cleanup(uid, false)
				return
			end
			if (root.Position - state.bobber.Position).Magnitude > Config.REEL_POSITION_RADIUS then
				self:Cleanup(uid, false)
				return
			end

			-- Simulate
			if state.holding then
				state.progress += state.progressRate * dt
				state.tension += state.tensionRate * dt
			else
				state.tension = math.max(0, state.tension - Config.TENSION_DECAY * dt)
			end

			if state.tension >= Config.TENSION_MAX then
				-- Line snapped
				Remotes:SendToClient(state.player, { type = "CatchResult", payload = { snapped = true } })
				self:Cleanup(uid, true)
				return
			end
			if state.progress >= Config.PROGRESS_MAX then
				self:ResolveCatch(uid)
				return
			end

			-- Push reel state (throttled)
			if now - state.lastSend >= Config.REEL_STATE_SEND then
				state.lastSend = now
				Remotes:SendToClient(state.player, {
					type = "ReelState",
					payload = {
						progress = state.progress,
						tension = state.tension,
						fishName = state.fishName,
						rarity = state.rarity,
					},
				})
			end
		end
	end
end

function FishingService:StartBite(uid: number)
	local state = casts[uid]
	if not state then
		return
	end
	local data = self.ctx.Services.DataService:GetData(state.player)
	if not data then
		return
	end
	local eventSvc = self.ctx.Services.EventService
	state.golden = eventSvc ~= nil and eventSvc:IsGoldenAt(state.bobber.Position) == true or false
	local roll = self:PickFish(state.zoneId, data, state.golden and Config.GOLDEN_SPOT_LUCK or 0)
	local def = FishCatalog.Get(roll.fishId)
	if not def then
		self:Cleanup(uid, false)
		return
	end
	local rod = RodCatalog.Get(data.equippedRod) :: Types.RodDef

	state.phase = "reeling"
	state.fishId = def.id
	state.fishName = def.name
	state.rarity = def.rarity
	state.shiny = roll.shiny
	state.weight = roll.weight
	local idx = Config.RARITY_INDEX[def.rarity] or 1
	state.tensionRate = Config.TENSION_RISE_BASE * (1 + Config.TENSION_RISE_PER_RARITY * (idx - 1)) / rod.strength
	state.progressRate = Config.PROGRESS_RATE_BASE + Config.PROGRESS_RATE_PER_STRENGTH * rod.strength

	-- Old One teaser
	if def.id == "old_one" then
		Remotes:SendToClient(state.player, { type = "EventBanner", payload = { kind = "oldOne", text = "Something ancient takes the line..." } })
	end

	-- Bite!
	Remotes:SendToClient(state.player, {
		type = "Bite",
		payload = {
			strength = rod.strength,
			rarity = def.rarity,
			fishName = def.name,
		},
	})
end

-- ── Catch resolution ─────────────────────────────────────────────────────

function FishingService:ResolveCatch(uid: number)
	local state = casts[uid]
	if not state then
		return
	end
	local data = self.ctx.Services.DataService:GetData(state.player)
	if not data then
		self:Cleanup(uid, false)
		return
	end
	local def = FishCatalog.Get(state.fishId)
	if not def then
		self:Cleanup(uid, false)
		return
	end

	local eventService = self.ctx.Services.EventService
	local isNight = eventService and eventService:GetTimeOfDay() == "night" or false
	local isStorm = eventService and eventService:IsStorm() or false

	local outcome = self.ctx.Services.InventoryService:AddCatch(
		state.player,
		def,
		state.weight,
		state.shiny,
		isNight,
		isStorm,
		state.golden
	)

	-- Catch aura (cosmetic)
	local auraDef = data.cosmetics.aura and CosmeticsCatalog.Get(data.cosmetics.aura)
	if auraDef then
		local fx = Instance.new("Part")
		fx.Name = "CatchAura"
		fx.Anchored = true
		fx.CanCollide = false
		fx.CanQuery = false
		fx.Size = Vector3.new(0.5, 0.5, 0.5)
		fx.Transparency = 1
		fx.CFrame = state.bobber.CFrame
		fx.Parent = Workspace
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Rate = 40
		pe.Lifetime = NumberRange.new(0.5, 1.1)
		pe.Speed = NumberRange.new(2, 5)
		pe.Size = NumberSequence.new(0.3, 0.9)
		pe.Transparency = NumberSequence.new(0.2, 1)
		pe.Color = ColorSequence.new(auraDef.color)
		pe.Parent = fx
		task.delay(1.4, function()
			if fx and fx.Parent then
				fx:Destroy()
			end
		end)
	end

	-- Result to the catcher
	Remotes:SendToClient(state.player, {
		type = "CatchResult",
		payload = {
			snapped = false,
			fishId = def.id,
			name = def.name,
			rarity = def.rarity,
			weight = state.weight,
			shiny = state.shiny,
			value = outcome and outcome.value or 0,
			coins = outcome and outcome.coins or 0,
			xp = outcome and outcome.xp or 0,
			pearls = outcome and outcome.pearls or 0,
			autoSold = outcome and outcome.autoSold or false,
			overflowSold = outcome and outcome.overflowSold or false,
			zonePct = outcome and outcome.zonePct or 0,
			golden = state.golden,
		},
	})

	-- Feed + announcements (virality layer)
	local idx = Config.RARITY_INDEX[def.rarity] or 1
	if state.shiny or idx >= 6 then
		Remotes:SendToAll({
			type = "FeedMessage",
			payload = {
				kind = "announce",
				text = state.player.Name .. " caught " .. (state.shiny and "a SHINY " or "a MYTHIC ") .. def.name .. " — " .. state.weight .. "kg!",
			},
		})
	elseif idx >= 4 then
		Remotes:SendToAll({
			type = "FeedMessage",
			payload = {
				kind = "chat",
				text = state.player.Name .. " caught a " .. def.name .. " (" .. state.weight .. "kg)",
			},
		})
	end

	self:Cleanup(uid, true)
end

-- ── Reel input (client intents) ──────────────────────────────────────────

function FishingService:HandleReelHold(player: Player, payload: any)
	local state = casts[player.UserId]
	if not state or state.phase ~= "reeling" then
		return
	end
	state.holding = payload and payload.held == true
end

function FishingService:HandleAutoReel(player: Player)
	local state = casts[player.UserId]
	local data = self.ctx.Services.DataService:GetData(player)
	if not state or state.phase ~= "reeling" or not data then
		return
	end
	if data.flags.tokens <= 0 then
		return
	end
	data.flags.tokens -= 1
	self.ctx.Services.DataService:MarkDirty(player)
	self:ResolveCatch(player.UserId)
end

-- ── Rod tool (visible fishing rod) ───────────────────────────────────────

function FishingService:UpdateRodColor(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	local character = player.Character
	if not data or not character then
		return
	end
	local tool = character:FindFirstChild("FishingRod")
	local handle = tool and tool:FindFirstChild("Handle") :: BasePart?
	if not handle then
		return
	end
	local rod = RodCatalog.Get(data.equippedRod)
	local color = rod and rod.color or Color3.fromRGB(150, 110, 70)
	local skin = data.cosmetics.rodSkin and CosmeticsCatalog.Get(data.cosmetics.rodSkin)
	if skin then
		color = skin.color
	end
	handle.Color = color
end

function FishingService:EnsureRodTool(player: Player)
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not humanoid then
		return
	end
	local existing = character:FindFirstChild("FishingRod")
	if existing then
		self:UpdateRodColor(player)
		return
	end
	local tool = Instance.new("Tool")
	tool.Name = "FishingRod"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.45, 6.5, 0.45)
	handle.Material = Enum.Material.Wood
	handle.Color = Color3.fromRGB(150, 110, 70)
	handle.Shape = Enum.PartType.Cylinder
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	tool.Parent = character
	task.wait(0.1)
	pcall(function()
		humanoid:EquipTool(tool)
	end)
	self:UpdateRodColor(player)
end

-- ── Cleanup ──────────────────────────────────────────────────────────────

function FishingService:Cleanup(uid: number, destroyBobber: boolean)
	local state = casts[uid]
	if not state then
		return
	end
	if destroyBobber and state.bobber then
		state.bobber:Destroy()
	end
	casts[uid] = nil
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function FishingService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.Cast = function(player, payload)
		self:HandleCast(player, payload)
	end
	ctx.MessageHandlers.ReelHold = function(player, payload)
		self:HandleReelHold(player, payload)
	end
	ctx.MessageHandlers.AutoReel = function(player, _payload)
		self:HandleAutoReel(player)
	end
end

function FishingService:Start()
	self:RefreshRegions()
	-- Keep region cache fresh if the builder edits live
	Workspace.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") and string.sub(desc.Name, 1, 11) == "ZoneRegion_" then
			self:RefreshRegions()
		end
	end)
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(_character)
			self:EnsureRodTool(player)
		end)
	end)
	for _, player in Players:GetPlayers() do
		if player.Character then
			task.spawn(function()
				task.wait(0.5)
				self:EnsureRodTool(player)
			end)
		end
	end
	Players.PlayerRemoving:Connect(function(player)
		self:Cleanup(player.UserId, true)
	end)
	if not warnedRegions then
		local count = 0
		for _, region  in pairs(zoneRegions) do
			if region then
				count += 1
			end
		end
		if count < 6 then
			warn("[Fishing] Only " .. count .. " zone regions found. Place ZoneRegion_<zone> parts in Workspace (see src/README.md).")
		end
	end
end

function FishingService:Stop()
	for uid, state  in pairs(casts) do
		self:Cleanup(uid, true)
	end
end

return FishingService
]===]

-- ServerScriptService/Services/InventoryService
local inst_ServerScriptService_Services_InventoryService = ensureChain([===[ServerScriptService/Services/InventoryService]===], 'Script')
inst_ServerScriptService_Services_InventoryService.Source = [===[--!strict
--[[
	Tidebound — InventoryService
	Fish inventory, bestiary, sell logic, and catch resolution.
	Owns: add/sell fish, bestiary entries, zone completion, catch stats.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)

local InventoryService = {}
InventoryService.Name = "InventoryService"

local RARITY_INDEX = Config.RARITY_INDEX

-- ── Bestiary helpers ─────────────────────────────────────────────────────

function InventoryService:GetZoneCompletion(data: Types.ProfileData, zoneId: string): number
	local zone = ZoneCatalog.Get(zoneId)
	if not zone then
		return 0
	end
	local total = #zone.fishIds
	if total == 0 then
		return 0
	end
	local caught = 0
	for _, fishId  in pairs(zone.fishIds) do
		local entry = data.bestiary[fishId]
		if entry and entry.caught > 0 then
			caught += 1
		end
	end
	return math.floor(caught / total * 100)
end

function InventoryService:GetGlobalCompletion(data: Types.ProfileData): number
	local total = 0
	local caught = 0
	for _, def  in pairs(FishCatalog.GetAll()) do
		if def.zone == "storm_any" then
			continue -- universal storm fish don't count toward bestiary %
		end
		total += 1
		local entry = data.bestiary[def.id]
		if entry and entry.caught > 0 then
			caught += 1
		end
	end
	if total == 0 then
		return 0
	end
	return math.floor(caught / total * 100)
end

-- ── Catch resolution (called by FishingService) ──────────────────────────

export type CatchOutcome = {
	uid: number,
	value: number,
	coins: number,
	xp: number,
	pearls: number,
	autoSold: boolean,
	overflowSold: boolean,
	bestiaryNew: boolean,
	zonePct: number,
	shiny: boolean,
}

function InventoryService:AddCatch(
	player: Player,
	fishDef: Types.FishDef,
	weight: number,
	shiny: boolean,
	isNight: boolean,
	isStorm: boolean,
	golden: boolean?
): CatchOutcome?
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return nil
	end
	local ctx = self.ctx

	-- Bestiary
	local entry = data.bestiary[fishDef.id]
	local bestiaryNew = entry == nil or entry.caught == 0
	if not entry then
		entry = { caught = 0, shiny = false, maxWeight = 0 }
		data.bestiary[fishDef.id] = entry
	end
	entry.caught += 1
	if shiny then
		entry.shiny = true
	end
	if weight > entry.maxWeight then
		entry.maxWeight = weight
	end

	-- Stats
	local stats = data.stats
	stats.totalCatch += 1
	stats.zoneCounts[fishDef.zone] = (stats.zoneCounts[fishDef.zone] or 0) + 1
	stats.familyCounts[fishDef.family] = (stats.familyCounts[fishDef.family] or 0) + 1
	if isNight then
		stats.nightFish += 1
	end
	if isStorm then
		stats.stormFish += 1
	end
	if shiny then
		stats.shinyFish += 1
	end
	if (RARITY_INDEX[fishDef.rarity] or 1) >= 4 then
		stats.epicPlus += 1
	end
	if ZoneCatalog.IsDeepFamily(fishDef.family) then
		stats.deepFish += 1
	end

	-- Value / coins / xp
	local value = Util.round(fishDef.baseValue * weight, 0)
	if shiny then
		value = math.floor(value * Config.SHINY_VALUE_MULT)
	end
	if golden then
		value = math.floor(value * Config.GOLDEN_SPOT_VALUE_MULT)
	end
	local coins = value
	if data.flags.ownedPasses.double_catch then
		coins = math.floor(coins * Config.DOUBLE_COINS_MULT)
	end
	local xp = fishDef.xp
	if isStorm then
		xp = math.floor(xp * Config.STORM_XP_MULT)
	end
	if data.flags.ownedPasses.vip_angler then
		xp = math.floor(xp * Config.VIP_XP_MULT)
	end
	if os.time() < data.flags.xpBoostUntil then
		xp = math.floor(xp * Config.XP_BOOST_MULT)
	end

	-- Auto-sell / inventory
	local autoSold = false
	local overflowSold = false
	local uid = 0
	local autoSellRarity = data.flags.autoSell
	if autoSellRarity and (RARITY_INDEX[fishDef.rarity] or 1) <= (RARITY_INDEX[autoSellRarity] or 1) then
		autoSold = true
	else
		if #data.inventory >= Config.INVENTORY_CAP then
			-- Overflow: sell the oldest common/uncommon to make room
			local soldValue = 0
			for i, item  in pairs(data.inventory) do
				local def = FishCatalog.Get(item.fishId)
				if def and (RARITY_INDEX[def.rarity] or 1) <= 2 then
					soldValue = math.floor(def.baseValue * item.weight)
					if item.shiny then
						soldValue *= Config.SHINY_VALUE_MULT
					end
					table.remove(data.inventory, i)
					stats.totalCoinsEarned += soldValue
					break
				end
			end
			if soldValue > 0 then
				overflowSold = true
				coins += soldValue
			else
				autoSold = true -- inventory full of rares; this catch sells itself
			end
		end
		if not autoSold then
			uid = data.nextUid
			data.nextUid += 1
			table.insert(data.inventory, {
				uid = uid,
				fishId = fishDef.id,
				weight = weight,
				shiny = shiny,
				caughtAt = os.time(),
			})
		end
	end

	-- Economy
	local economy = ctx.Services.EconomyService
	economy:AddCoins(player, coins, "catch:" .. fishDef.id)
	economy:AddXP(player, xp, "catch:" .. fishDef.id)

	-- Pearl drops (rare, capped by design)
	local pearls = 0
	if (RARITY_INDEX[fishDef.rarity] or 1) >= (RARITY_INDEX[Config.PEARL_DROP_MIN_RARITY] or 4) and Util.rollChance(Config.PEARL_DROP_CHANCE) then
		pearls += 1
		economy:AddPearls(player, 1, "drop")
	end
	if isStorm and Util.rollChance(Config.STORM_PEARL_CHANCE) then
		pearls += 1
		economy:AddPearls(player, 1, "storm")
	end

	-- Zone completion rewards
	local zonePct = self:GetZoneCompletion(data, fishDef.zone)
	if zonePct >= 100 and not data.flags.zoneRewards[fishDef.zone] then
		data.flags.zoneRewards[fishDef.zone] = true
		economy:AddPearls(player, 10, "zone_complete:" .. fishDef.zone)
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "zoneComplete", text = "Bestiary complete in " .. fishDef.zone .. "! +10 pearls" },
		})
	end

	-- Quest / achievement hooks
	local questService = ctx.Services.QuestService
	if questService then
		questService:OnFishCaught(player, fishDef, isNight, isStorm, shiny)
	end

	-- Weekly contest submission
	local leaderboardService = ctx.Services.LeaderboardService
	if leaderboardService and not autoSold then
		leaderboardService:SubmitCatch(player, weight, fishDef.id, fishDef.rarity)
	end

	ctx.Services.DataService:MarkDirty(player)
	Remotes:SendToClient(player, { type = "BestiaryUpdate", payload = { fishId = fishDef.id, shiny = shiny, zonePct = zonePct, bestiaryNew = bestiaryNew } })

	return {
		uid = uid,
		value = value,
		coins = coins,
		xp = xp,
		pearls = pearls,
		autoSold = autoSold,
		overflowSold = overflowSold,
		bestiaryNew = bestiaryNew,
		zonePct = zonePct,
		shiny = shiny,
	}
end

-- ── Selling ──────────────────────────────────────────────────────────────

function InventoryService:SellFish(player: Player, ids: { number }): (boolean, string?)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return false, "no profile"
	end
	if typeof(ids) ~= "table" or #ids == 0 or #ids > 50 then
		return false, "bad ids"
	end
	local seen: { [number]: boolean } = {}
	local total = 0
	local sold = 0
	for _, uid  in pairs(ids) do
		if typeof(uid) ~= "number" or seen[uid] then
			continue
		end
		seen[uid] = true
		for i, item  in pairs(data.inventory) do
			if item.uid == uid then
				local def = FishCatalog.Get(item.fishId)
				if def then
					local v = math.floor(def.baseValue * item.weight)
					if item.shiny then
						v *= Config.SHINY_VALUE_MULT
					end
					total += v
				end
				table.remove(data.inventory, i)
				sold += 1
				break
			end
		end
	end
	if sold == 0 then
		return false, "no valid fish"
	end
	local economy = self.ctx.Services.EconomyService
	economy:AddCoins(player, total, "sell")
	local questService = self.ctx.Services.QuestService
	if questService then
		questService:OnSell(player, total)
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendInventory(player)
	return true
end

function InventoryService:SellAll(player: Player, maxRarity: string): (boolean, string?)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return false, "no profile"
	end
	local maxIdx = RARITY_INDEX[maxRarity] or 2
	local total = 0
	local kept: { Types.InventoryFish } = {}
	for _, item  in pairs(data.inventory) do
		local def = FishCatalog.Get(item.fishId)
		local idx = def and (RARITY_INDEX[def.rarity] or 1) or 1
		if idx <= maxIdx and not item.shiny then
			if def then
				local v = math.floor(def.baseValue * item.weight)
				total += v
			end
		else
			table.insert(kept, item)
		end
	end
	if total <= 0 then
		return false, "nothing to sell"
	end
	data.inventory = kept
	local economy = self.ctx.Services.EconomyService
	economy:AddCoins(player, total, "sell_all")
	local questService = self.ctx.Services.QuestService
	if questService then
		questService:OnSell(player, total)
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendInventory(player)
	return true
end

function InventoryService:SetAutoSell(player: Player, maxRarity: string?)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if maxRarity == nil then
		data.flags.autoSell = nil
	elseif RARITY_INDEX[maxRarity] then
		data.flags.autoSell = maxRarity
	else
		return
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendInventory(player)
end

-- Push inventory + bestiary snapshot to a client
function InventoryService:SendInventory(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local upgradeSlots = 0
	for i = 1, data.flags.invUpgradeTier do
		local tier = Config.INVENTORY_UPGRADES[i]
		if tier then
			upgradeSlots += tier.slots
		end
	end
	local passSlots = data.flags.ownedPasses.bigger_tackle_box and 50 or 0
	Remotes:SendToClient(player, {
		type = "InventorySync",
		payload = {
			inventory = data.inventory,
			bestiary = data.bestiary,
			globalPct = self:GetGlobalCompletion(data),
			autoSell = data.flags.autoSell,
			invSlots = Config.INVENTORY_START + upgradeSlots + passSlots,
			achievements = data.achievements,
			titles = data.titles,
			equippedTitle = data.equippedTitle,
			cosmetics = data.cosmetics,
			cosmeticsOwned = data.flags.cosmeticsOwned,
			stats = {
				totalCatch = data.stats.totalCatch,
				totalCoinsEarned = data.stats.totalCoinsEarned,
				totalPearlsEarned = data.stats.totalPearlsEarned,
				shinyFish = data.stats.shinyFish,
				stormFish = data.stats.stormFish,
				nightFish = data.stats.nightFish,
				deepFish = data.stats.deepFish,
				bestCatch = data.stats.bestCatch,
			},
		},
	})
end

function InventoryService:Init(ctx)
	self.ctx = ctx
end

function InventoryService:Start()
end

function InventoryService:Stop()
end

return InventoryService
]===]

-- ServerScriptService/Services/LeaderboardService
local inst_ServerScriptService_Services_LeaderboardService = ensureChain([===[ServerScriptService/Services/LeaderboardService]===], 'Script')
inst_ServerScriptService_Services_LeaderboardService.Source = [===[--!strict
--[[
	Tidebound — LeaderboardService
	leaderstats (Level / Coins / Bestiary) + weekly catch contest.
	Contest: auto-tracked best catch per week, top 10 rewarded at rollover.
	Phase 3 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local LeaderboardService = {}
LeaderboardService.Name = "LeaderboardService"

local contestStore = DataStoreService:GetOrderedDataStore("TD_Contest")
local lastFinalizedWeek = ""
local statsValues: { [number]: { level: number, coins: number, bestiary: number } } = {}

-- ── leaderstats ──────────────────────────────────────────────────────────

function LeaderboardService:SetupLeaderstats(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	local function ensure(name: string, value: number)
		local v = leaderstats:FindFirstChild(name)
		if not v then
			v = Instance.new("IntValue")
			v.Name = name
			v.Parent = leaderstats
		end
		v.Value = value
	end
	ensure("Level", 1)
	ensure("Coins", 0)
	ensure("Bestiary", 0)
	statsValues[player.UserId] = { level = 1, coins = 0, bestiary = 0 }
end

function LeaderboardService:UpdateLeaderstats(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local stats = statsValues[player.UserId]
	if not stats then
		return
	end
	if stats.level ~= data.level then
		stats.level = data.level
	end
	if stats.coins ~= data.coins then
		stats.coins = data.coins
	end
	local pct = self.ctx.Services.InventoryService:GetGlobalCompletion(data)
	if stats.bestiary ~= pct then
		stats.bestiary = pct
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local lv = leaderstats:FindFirstChild("Level")
		local cv = leaderstats:FindFirstChild("Coins")
		local bv = leaderstats:FindFirstChild("Bestiary")
		if lv then
			lv.Value = stats.level
		end
		if cv then
			cv.Value = stats.coins
		end
		if bv then
			bv.Value = stats.bestiary
		end
	end
end

-- ── Weekly contest ───────────────────────────────────────────────────────

function LeaderboardService:SubmitCatch(player: Player, weight: number, fishId: string, rarity: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local week = Util.weekKey()
	local idx = Config.RARITY_INDEX[rarity] or 1
	local score = math.floor(weight * (Config.CONTEST_MULTIPLIER_BASE + idx))
	local best = data.stats.bestCatch
	if best.weekKey ~= week or score > (best.weight * (Config.CONTEST_MULTIPLIER_BASE + (Config.RARITY_INDEX[best.rarity] or 1))) then
		data.stats.bestCatch = {
			weight = weight,
			fishId = fishId,
			rarity = rarity,
			weekKey = week,
		}
		self.ctx.Services.DataService:MarkDirty(player)
		local ok, err = pcall(function()
			contestStore:SetAsync(tostring(player.UserId), score)
		end)
		if not ok then
			warn("[Leaderboard] contest SetAsync failed: " .. tostring(err))
		end
	end
end

function LeaderboardService:FinalizeWeek(week: string)
	local ok, pages = pcall(function()
		return contestStore:GetSortedAsync(false, 100)
	end)
	if not ok then
		warn("[Leaderboard] contest read failed")
		return
	end
	local results = {}
	local ok2, err2 = pcall(function()
		results = pages:GetCurrentPage()
	end)
	if not ok2 then
		warn("[Leaderboard] contest page failed: " .. tostring(err2))
		return
	end
	local winners: { string } = {}
	for i, entry in ipairs(results) do
		if i > 10 then
			break
		end
		local userId = tonumber(entry.key)
		local player = userId and Players:GetPlayerByUserId(userId)
		if player then
			local pearls = Config.CONTEST_REWARDS[i]
			if pearls then
				self.ctx.Services.EconomyService:AddPearls(player, pearls, "contest")
			end
			table.insert(winners, player.Name)
			if i == 1 then
				local data = self.ctx.Services.DataService:GetData(player)
				if data then
					data.flags.contestWins += 1
					data.titles["Weekly Champion"] = true
					if not data.equippedTitle then
						data.equippedTitle = "Weekly Champion"
					end
					self.ctx.Services.DataService:MarkDirty(player)
					self.ctx.Services.QuestService:CheckAchievements(player)
				end
			end
		end
	end
	if #winners > 0 then
		Remotes:SendToAll({
			type = "FeedMessage",
			payload = { kind = "announce", text = "🏆 Weekly catch contest winners: " .. table.concat(winners, ", ") .. "! See you next week." },
		})
	end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function LeaderboardService:SendContestTop(player: Player)
	local ok, pages = pcall(function()
		return contestStore:GetSortedAsync(false, 10)
	end)
	if not ok then
		return
	end
	local results = {}
	local ok2, err2 = pcall(function()
		results = pages:GetCurrentPage()
	end)
	if not ok2 then
		warn("[Leaderboard] contest page failed: " .. tostring(err2))
		return
	end
	local entries: { { name: string, score: number } } = {}
	for i, entry in ipairs(results) do
		if i > 10 then
			break
		end
		local userId = tonumber(entry.key)
		local name = "Player " .. tostring(entry.key)
		if userId then
			local okN, nm = pcall(function()
				return Players:GetNameByUserIdAsync(userId)
			end)
			if okN and typeof(nm) == "string" then
				name = nm
			end
		end
		table.insert(entries, { name = name, score = entry.value })
	end
	Remotes:SendToClient(player, {
		type = "ContestTop",
		payload = { week = Util.weekKey(), entries = entries },
	})
end

function LeaderboardService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.GetContestTop = function(player, _payload)
		self:SendContestTop(player)
	end
end

function LeaderboardService:Start()
	self.ctx.Services.DataService:OnProfileReady(function(player, _data)
		self:SetupLeaderstats(player)
	end)

	lastFinalizedWeek = Util.weekKey()

	-- Periodic updates + week rollover check
	task.spawn(function()
		while true do
			task.wait(5)
			for _, player  in pairs(Players:GetPlayers()) do
				self:UpdateLeaderstats(player)
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(60)
			local week = Util.weekKey()
			if week ~= lastFinalizedWeek then
				self:FinalizeWeek(lastFinalizedWeek)
				lastFinalizedWeek = week
			end
		end
	end)
end

function LeaderboardService:Stop()
end

return LeaderboardService
]===]

-- ServerScriptService/Services/QuestService
local inst_ServerScriptService_Services_QuestService = ensureChain([===[ServerScriptService/Services/QuestService]===], 'Script')
inst_ServerScriptService_Services_QuestService.Source = [===[--!strict
--[[
	Tidebound — QuestService
	Daily/weekly quests, login streak, achievements. All server-side.
	Phase 3 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local QuestCatalog = require(ReplicatedStorage.Shared.Data.QuestCatalog)

local QuestService = {}
QuestService.Name = "QuestService"

-- Families available for "catch family" quests
local FAMILIES = {
	"shoal", "reef", "carp", "koi", "sturgeon", "bass", "serpent", "glow",
	"hunter", "cod", "squid", "angler", "eel", "wraith", "trout", "gar",
	"salmon", "pike", "whale", "leviathan", "storm", "char", "fang", "devil", "mist",
}
local MAIN_ZONES = { "sunshall", "whisper", "drop", "ember", "frost", "abyss" }

-- ── Quest rollover ───────────────────────────────────────────────────────

function QuestService:RollDaily(data: Types.ProfileData)
	local exclude: { [string]: boolean } = {}
	for _, q  in pairs(data.dailyQuests) do
		exclude[q.templateId] = true
	end
	local pool = QuestCatalog.RollTemplates(QuestCatalog.DAILY_POOL, exclude)
	data.dailyQuests = {}
	for i = 1, Config.DAILY_QUESTS do
		local t = pool[i]
		if not t then
			break
		end
		local params: { [string]: string } = {}
		if t.param == "zone" then
			params.zone = MAIN_ZONES[math.random(1, #MAIN_ZONES)]
		elseif t.param == "family" then
			params.family = FAMILIES[math.random(1, #FAMILIES)]
		end
		table.insert(data.dailyQuests, {
			templateId = t.id,
			params = params,
			progress = 0,
			done = false,
			claimed = false,
		})
	end
end

function QuestService:RollWeekly(data: Types.ProfileData)
	local exclude: { [string]: boolean } = {}
	for _, q  in pairs(data.weeklyQuests) do
		exclude[q.templateId] = true
	end
	local pool = QuestCatalog.RollTemplates(QuestCatalog.WEEKLY_POOL, exclude)
	data.weeklyQuests = {}
	for i = 1, Config.WEEKLY_QUESTS do
		local t = pool[i]
		if not t then
			break
		end
		table.insert(data.weeklyQuests, {
			templateId = t.id,
			params = {},
			progress = 0,
			done = false,
			claimed = false,
		})
	end
end

-- Called on join and before any quest-touching action
function QuestService:EnsureRollovers(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local changed = false

	local today = Util.todayKey()
	if data.questDay ~= today then
		self:RollDaily(data)
		data.questDay = today
		data.flags.rerollsUsed = 0
		changed = true
	end
	local week = Util.weekKey()
	if data.questWeek ~= week then
		self:RollWeekly(data)
		data.questWeek = week
		changed = true
	end

	-- Login streak (day-based; cycle resets at 7)
	if data.streakLastDay ~= today then
		if data.streakLastDay == Util.yesterdayKey() then
			data.streak = if data.streak >= 7 then 1 else data.streak + 1
		else
			data.streak = 1
		end
		local reward = Config.STREAK_REWARDS[data.streak] or { coins = 50 }
		if reward.coins then
			self.ctx.Services.EconomyService:AddCoins(player, reward.coins, "streak")
		end
		if reward.pearls then
			self.ctx.Services.EconomyService:AddPearls(player, reward.pearls, "streak")
		end
		for _, baitId in ipairs({ "worm", "shrimp", "squid", "golden" }) do
			local n = reward[baitId]
			if n then
				data.baits[baitId] = (data.baits[baitId] or 0) + n
			end
		end
		data.streakLastDay = today
		changed = true
		Remotes:SendToClient(player, {
			type = "StreakUpdate",
			payload = { streak = data.streak, reward = reward },
		})
	end

	if changed then
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendQuestUpdate(player)
	end
end

-- ── Quest progress hooks ─────────────────────────────────────────────────

function QuestService:OnFishCaught(player: Player, def: Types.FishDef, isNight: boolean, isStorm: boolean, shiny: boolean)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local idx = Config.RARITY_INDEX[def.rarity] or 1
	local function advance(list: { Types.QuestProgress }, pool: any)
		for _, q  in pairs(list) do
			if q.claimed or q.done then
				continue
			end
			local t = pool(q.templateId)
			if not t then
				continue
			end
			local matched = false
			if t.type == "catchTotal" then
				matched = true
			elseif t.type == "catchZone" then
				matched = q.params.zone == def.zone
			elseif t.type == "catchNight" then
				matched = isNight
			elseif t.type == "catchRarity" then
				matched = idx >= 4
			elseif t.type == "catchStorm" then
				matched = isStorm
			elseif t.type == "catchFamily" then
				matched = q.params.family == def.family
			elseif t.type == "catchShiny" then
				matched = shiny
			end
			if matched then
				q.progress += 1
				if q.progress >= t.target then
					q.done = true
				end
			end
		end
	end
	advance(data.dailyQuests, QuestCatalog.GetDailyTemplate)
	advance(data.weeklyQuests, QuestCatalog.GetWeeklyTemplate)
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
	self:CheckAchievements(player)
end

function QuestService:OnSell(player: Player, coins: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local function advance(list: { Types.QuestProgress }, pool: any)
		for _, q  in pairs(list) do
			if q.claimed or q.done then
				continue
			end
			local t = pool(q.templateId)
			if t and t.type == "sellCoins" then
				q.progress += coins
				if q.progress >= t.target then
					q.done = true
				end
			end
		end
	end
	advance(data.dailyQuests, QuestCatalog.GetDailyTemplate)
	advance(data.weeklyQuests, QuestCatalog.GetWeeklyTemplate)
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

function QuestService:OnLevelUp(player: Player, _level: number)
	self:CheckAchievements(player)
end

function QuestService:OnZoneComplete(player: Player, _zoneId: string)
	self:CheckAchievements(player)
end

-- ── Claims & reroll ──────────────────────────────────────────────────────

function QuestService:ClaimDaily(player: Player, slot: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local q = data.dailyQuests[slot]
	if not q or not q.done or q.claimed then
		return
	end
	local t = QuestCatalog.GetDailyTemplate(q.templateId)
	if not t then
		return
	end
	self:GrantRewards(player, t.rewards)
	q.claimed = true
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

function QuestService:ClaimWeekly(player: Player, slot: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local q = data.weeklyQuests[slot]
	if not q or not q.done or q.claimed then
		return
	end
	local t = QuestCatalog.GetWeeklyTemplate(q.templateId)
	if not t then
		return
	end
	self:GrantRewards(player, t.rewards)
	q.claimed = true
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

function QuestService:GrantRewards(player: Player, rewards: { coins: number?, pearls: number?, bait: string? })
	if rewards.coins then
		self.ctx.Services.EconomyService:AddCoins(player, rewards.coins, "quest")
	end
	if rewards.pearls then
		self.ctx.Services.EconomyService:AddPearls(player, rewards.pearls, "quest")
	end
	if rewards.bait then
		local data = self.ctx.Services.DataService:GetData(player)
		if data then
			data.baits[rewards.bait] = (data.baits[rewards.bait] or 0) + 5
		end
	end
end

function QuestService:RerollQuest(player: Player, slot: number)
	self:EnsureRollovers(player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if data.flags.rerollsUsed >= 1 then
		return
	end
	local current = data.dailyQuests[slot]
	if not current then
		return
	end
	local exclude: { [string]: boolean } = {}
	for _, q  in pairs(data.dailyQuests) do
		exclude[q.templateId] = true
	end
	local pool = QuestCatalog.RollTemplates(QuestCatalog.DAILY_POOL, exclude)
	local t = pool[1]
	if not t then
		return
	end
	local params: { [string]: string } = {}
	if t.param == "zone" then
		params.zone = MAIN_ZONES[math.random(1, #MAIN_ZONES)]
	elseif t.param == "family" then
		params.family = FAMILIES[math.random(1, #FAMILIES)]
	end
	data.dailyQuests[slot] = {
		templateId = t.id,
		params = params,
		progress = 0,
		done = false,
		claimed = false,
	}
	data.flags.rerollsUsed = 1
	self.ctx.Services.DataService:MarkDirty(player)
	self:SendQuestUpdate(player)
end

-- ── Achievements ─────────────────────────────────────────────────────────

local CONDITIONS: { [string]: (Types.ProfileData) -> boolean } = {
	first_catch = function(d)
		return d.stats.totalCatch >= 1
	end,
	first_shiny = function(d)
		return d.stats.shinyFish >= 1
	end,
	fish_100 = function(d)
		return d.stats.totalCatch >= 100
	end,
	fish_1000 = function(d)
		return d.stats.totalCatch >= 1000
	end,
	coins_10k = function(d)
		return d.stats.totalCoinsEarned >= 10000
	end,
	coins_100k = function(d)
		return d.stats.totalCoinsEarned >= 100000
	end,
	night_owl = function(d)
		return d.stats.nightFish >= 20
	end,
	storm_chaser = function(d)
		return d.stats.stormFish >= 10
	end,
	deep_diver = function(d)
		return d.stats.deepFish >= 50
	end,
	old_one_witness = function(d)
		local e = d.bestiary.old_one
		return e ~= nil and e.caught > 0
	end,
	secret_finder = function(d)
		local e = d.bestiary.mistfin
		return e ~= nil and e.caught > 0
	end,
	grotto_finder = function(d)
		local e = d.bestiary.grotto_glowfin
		return e ~= nil and e.caught > 0
	end,
	level_10 = function(d)
		return d.level >= 10
	end,
	level_25 = function(d)
		return d.level >= 25
	end,
	level_50 = function(d)
		return d.level >= Config.MAX_LEVEL
	end,
	rod_collector = function(d)
		for _, def in pairs(require(ReplicatedStorage.Shared.Data.RodCatalog).GetAll()) do
			if not d.rods[def.id] then
				return false
			end
		end
		return true
	end,
	zone_master = function(d)
		for _, _  in pairs(d.flags.zoneRewards) do
			return true
		end
		return false
	end,
	all_zones = function(d)
		for _, zoneId  in pairs(MAIN_ZONES) do
			if not d.flags.zoneRewards[zoneId] then
				return false
			end
		end
		return true
	end,
	contest_winner = function(d)
		return d.flags.contestWins >= 1
	end,
	pearl_earner = function(d)
		return d.stats.totalPearlsEarned >= 100
	end,
	shiny_10 = function(d)
		return d.stats.shinyFish >= 10
	end,
}

function QuestService:CheckAchievements(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local changed = false
	for _, def  in pairs(QuestCatalog.ACHIEVEMENTS) do
		if data.achievements[def.id] then
			continue
		end
		local cond = CONDITIONS[def.id]
		if cond and cond(data) then
			data.achievements[def.id] = true
			if def.rewards.pearls then
				self.ctx.Services.EconomyService:AddPearls(player, def.rewards.pearls, "achievement:" .. def.id)
			end
			if def.rewards.title then
				data.titles[def.rewards.title] = true
				if not data.equippedTitle then
					data.equippedTitle = def.rewards.title
				end
			end
			Remotes:SendToClient(player, {
				type = "AchievementUnlock",
				payload = { id = def.id, name = def.name, desc = def.desc },
			})
			changed = true
		end
	end
	if changed then
		self.ctx.Services.DataService:MarkDirty(player)
	end
end

-- ── Sync ─────────────────────────────────────────────────────────────────

function QuestService:SendQuestUpdate(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	Remotes:SendToClient(player, {
		type = "QuestUpdate",
		payload = {
			daily = data.dailyQuests,
			weekly = data.weeklyQuests,
			streak = data.streak,
		},
	})
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function QuestService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.ClaimDaily = function(player, payload)
		self:ClaimDaily(player, Util.safeNumber(payload and payload.slot, 1))
	end
	ctx.MessageHandlers.ClaimWeekly = function(player, payload)
		self:ClaimWeekly(player, Util.safeNumber(payload and payload.slot, 1))
	end
	ctx.MessageHandlers.RerollQuest = function(player, payload)
		self:RerollQuest(player, Util.safeNumber(payload and payload.slot, 1))
	end
end

function QuestService:Start()
	self.ctx.Services.DataService:OnProfileReady(function(player, _data)
		self:EnsureRollovers(player)
		self:CheckAchievements(player)
	end)
end

function QuestService:Stop()
end

return QuestService
]===]

-- ServerScriptService/Services/SecurityService
local inst_ServerScriptService_Services_SecurityService = ensureChain([===[ServerScriptService/Services/SecurityService]===], 'Script')
inst_ServerScriptService_Services_SecurityService.Source = [===[--!strict
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
]===]

-- ServerScriptService/Services/ShopService
local inst_ServerScriptService_Services_ShopService = ensureChain([===[ServerScriptService/Services/ShopService]===], 'Script')
inst_ServerScriptService_Services_ShopService.Source = [===[--!strict
--[[
	Tidebound — ShopService
	Monetization: gamepasses, developer products, coin/pearl purchases.
	- ProcessReceipt with idempotency (receipt cache per player)
	- Pass ownership checked on join (UserOwnsGamePassAsync)
	- All purchases funnel through EconomyService (single choke point)
	Phase 3/7 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Util = require(ReplicatedStorage.Shared.Util)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local CosmeticsCatalog = require(ReplicatedStorage.Shared.Data.CosmeticsCatalog)

local ShopService = {}
ShopService.Name = "ShopService"

-- Receipts that arrived before the profile was loaded: applied on load
local pendingReceipts: { [number]: { any } } = {}

-- ── Pass / product grants ────────────────────────────────────────────────

function ShopService:GrantGamepass(player: Player, passKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	data.flags.ownedPasses[passKey] = true
	if passKey == "starter_pack" and not data.flags.starterClaimed then
		data.flags.starterClaimed = true
		self.ctx.Services.EconomyService:AddCoins(player, Config.STARTER_PACK.coins, "starter_pack")
		data.baits.golden = (data.baits.golden or 0) + Config.STARTER_PACK.golden
	end
	self.ctx.Services.DataService:MarkDirty(player)
	Remotes:SendToClient(player, { type = "PassGranted", payload = { passId = passKey } })
	warn("[Shop] Gamepass granted: " .. player.Name .. " | " .. passKey)
end

function ShopService:GrantProduct(player: Player, productKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local economy = self.ctx.Services.EconomyService
	for _, pack  in pairs(Config.PEARL_PACKS) do
		if pack.id == productKey then
			economy:AddPearls(player, pack.pearls, "purchase:" .. productKey)
			Remotes:SendToClient(player, { type = "ProductGranted", payload = { productId = productKey } })
			return
		end
	end
	if productKey == "auto_reel_tokens" then
		data.flags.tokens = math.min(9999, data.flags.tokens + Config.AUTO_REEL_TOKEN_PACK)
		self.ctx.Services.DataService:MarkDirty(player)
		Remotes:SendToClient(player, { type = "ProductGranted", payload = { productId = productKey } })
	elseif productKey == "xp_boost_2h" then
		data.flags.xpBoostUntil = math.max(data.flags.xpBoostUntil, os.time() + Config.XP_BOOST_DURATION)
		self.ctx.Services.DataService:MarkDirty(player)
		Remotes:SendToClient(player, { type = "ProductGranted", payload = { productId = productKey } })
	end
end

function ShopService:HandleReceipt(receiptInfo: any): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	local profile = player and self.ctx.Services.DataService:GetProfile(player)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if not profile then
		-- Profile not loaded yet: queue and apply on load
		local queue = pendingReceipts[receiptInfo.PlayerId] or {}
		table.insert(queue, receiptInfo)
		pendingReceipts[receiptInfo.PlayerId] = queue
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local data = profile.data

	-- Idempotency: never grant the same purchase twice
	local receiptKey = tostring(receiptInfo.PurchaseId)
	if data.flags.receipts[receiptKey] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	data.flags.receipts[receiptKey] = true
	self.ctx.Services.DataService:MarkDirty(player)

	if receiptInfo.PurchaseType == Enum.PurchaseType.GamePass then
		local passKey: string? = nil
		for key, id  in pairs(Config.GAMEPASS_IDS) do
			if id == receiptInfo.PurchaseId then
				passKey = key
				break
			end
		end
		if passKey then
			self:GrantGamepass(player, passKey)
		end
	elseif receiptInfo.PurchaseType == Enum.PurchaseType.Product then
		local productKey: string? = nil
		for key, id  in pairs(Config.PRODUCT_IDS) do
			if id == receiptInfo.PurchaseId then
				productKey = key
				break
			end
		end
		if productKey then
			self:GrantProduct(player, productKey)
		end
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Check pass ownership at join (covers out-of-game purchases)
function ShopService:CheckPassOwnership(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	task.spawn(function()
		for key, passId  in pairs(Config.GAMEPASS_IDS) do
			if passId <= 0 then
				continue
			end
			local ok, owned = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
			end)
			if ok and owned and not data.flags.ownedPasses[key] then
				self:GrantGamepass(player, key)
			end
		end
	end)
end

-- ── Coin / pearl purchases (message-driven) ──────────────────────────────

function ShopService:BuyRod(player: Player, rodId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(rodId) ~= "string" then
		return
	end
	local def = RodCatalog.Get(rodId)
	if not def then
		self.ctx.Services.SecurityService:Flag(player, "buy unknown rod")
		return
	end
	if data.rods[rodId] then
		return
	end
	if data.level < def.unlockLevel then
		return
	end
	if not self.ctx.Services.EconomyService:SpendCoins(player, def.cost, "rod:" .. rodId) then
		return
	end
	data.rods[rodId] = true
	data.equippedRod = rodId
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.EconomyService:Sync(player)
	local fishing = self.ctx.Services.FishingService
	if fishing and fishing.UpdateRodColor then
		fishing:UpdateRodColor(player)
	end
end

function ShopService:EquipRod(player: Player, rodId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(rodId) ~= "string" then
		return
	end
	if data.rods[rodId] and RodCatalog.Get(rodId) then
		data.equippedRod = rodId
		self.ctx.Services.DataService:MarkDirty(player)
		self.ctx.Services.EconomyService:Sync(player)
	end
end

function ShopService:BuyBait(player: Player, baitId: any, count: any)
	local data = self.ctx.Services.DataService:GetData(player)
	local baitDef = typeof(baitId) == "string" and Config.BAITS[baitId]
	if not data or not baitDef then
		return
	end
	count = math.clamp(math.floor(Util.safeNumber(count, 1)), 1, 10)
	local cost = baitDef.cost * count
	if not self.ctx.Services.EconomyService:SpendCoins(player, cost, "bait:" .. baitId) then
		return
	end
	data.baits[baitId] = (data.baits[baitId] or 0) + count
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.EconomyService:Sync(player)
end

function ShopService:EquipBait(player: Player, baitId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if baitId == nil then
		data.flags.equippedBait = nil
	elseif typeof(baitId) == "string" and Config.BAITS[baitId] then
		local count = data.baits[baitId] or 0
		if count <= 0 and not (baitId == "golden" and data.flags.ownedPasses.golden_lure_pass) then
			return
		end
		data.flags.equippedBait = baitId
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.EconomyService:Sync(player)
end

function ShopService:BuyUpgrade(player: Player, tier: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(tier) ~= "number" then
		return
	end
	tier = math.floor(tier)
	if tier < 1 or tier > #Config.INVENTORY_UPGRADES then
		return
	end
	if data.flags.invUpgradeTier + 1 ~= tier then
		return -- must buy in order
	end
	local def = Config.INVENTORY_UPGRADES[tier]
	if not self.ctx.Services.EconomyService:SpendCoins(player, def.cost, "storage:" .. tier) then
		return
	end
	data.flags.invUpgradeTier = tier
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.InventoryService:SendInventory(player)
end

-- ── Cosmetics & titles ───────────────────────────────────────────────────

function ShopService:BuyCosmetic(player: Player, cosmeticId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(cosmeticId) ~= "string" then
		return
	end
	local def = CosmeticsCatalog.Get(cosmeticId)
	if not def or def.price <= 0 then
		return
	end
	if data.flags.cosmeticsOwned[cosmeticId] then
		return -- already owned
	end
	if not self.ctx.Services.EconomyService:SpendPearls(player, def.price, "cosmetic:" .. cosmeticId) then
		return
	end
	data.flags.cosmeticsOwned[cosmeticId] = true
	-- Buying a cosmetic equips it immediately (satisfying + clear)
	data.cosmetics[def.kind] = def.id
	if def.kind == "rodSkin" then
		local fishing = self.ctx.Services.FishingService
		if fishing and fishing.UpdateRodColor then
			fishing:UpdateRodColor(player)
		end
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.InventoryService:SendInventory(player)
end

function ShopService:EquipCosmetic(player: Player, cosmeticId: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(cosmeticId) ~= "string" then
		return
	end
	local def = CosmeticsCatalog.Get(cosmeticId)
	if not def then
		return
	end
	if not data.flags.cosmeticsOwned[cosmeticId] and def.price > 0 then
		return -- must own it first
	end
	data.cosmetics[def.kind] = def.id
	if def.kind == "rodSkin" then
		local fishing = self.ctx.Services.FishingService
		if fishing and fishing.UpdateRodColor then
			fishing:UpdateRodColor(player)
		end
	end
	self.ctx.Services.DataService:MarkDirty(player)
	self.ctx.Services.InventoryService:SendInventory(player)
end

function ShopService:EquipTitle(player: Player, title: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data or typeof(title) ~= "string" then
		return
	end
	if data.titles[title] then
		data.equippedTitle = title
		self.ctx.Services.DataService:MarkDirty(player)
		self.ctx.Services.InventoryService:SendInventory(player)
	end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function ShopService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.BuyRod = function(player, payload)
		self:BuyRod(player, payload and payload.rodId)
	end
	ctx.MessageHandlers.EquipRod = function(player, payload)
		self:EquipRod(player, payload and payload.rodId)
	end
	ctx.MessageHandlers.BuyBait = function(player, payload)
		self:BuyBait(player, payload and payload.baitId, payload and payload.count)
	end
	ctx.MessageHandlers.EquipBait = function(player, payload)
		self:EquipBait(player, payload and payload.baitId)
	end
	ctx.MessageHandlers.BuyUpgrade = function(player, payload)
		self:BuyUpgrade(player, payload and payload.tier)
	end
	ctx.MessageHandlers.BuyCosmetic = function(player, payload)
		self:BuyCosmetic(player, payload and payload.cosmeticId)
	end
	ctx.MessageHandlers.EquipCosmetic = function(player, payload)
		self:EquipCosmetic(player, payload and payload.cosmeticId)
	end
	ctx.MessageHandlers.EquipTitle = function(player, payload)
		self:EquipTitle(player, payload and payload.title)
	end
end

function ShopService:Start()
	MarketplaceService.ProcessReceipt:Connect(function(receiptInfo)
		return self:HandleReceipt(receiptInfo)
	end)

	self.ctx.Services.DataService:OnProfileReady(function(player, _data)
		-- Apply receipts that arrived before the profile loaded
		local queue = pendingReceipts[player.UserId]
		if queue then
			pendingReceipts[player.UserId] = nil
			for _, receiptInfo  in pairs(queue) do
				self:HandleReceipt(receiptInfo)
			end
		end
		self:CheckPassOwnership(player)
	end)
end

function ShopService:Stop()
end

return ShopService
]===]

-- ServerScriptService/Services/TravelService
local inst_ServerScriptService_Services_TravelService = ensureChain([===[ServerScriptService/Services/TravelService]===], 'Script')
inst_ServerScriptService_Services_TravelService.Source = [===[--!strict
--[[
	Tidebound — TravelService
	Fast travel between zones. Server-authoritative teleport:
	validates zone + unlock level + cooldown, cancels in-flight casts,
	moves the character, announces arrival. Prevents the "swim 1000 studs" grind.
	Phase 5 | AI-assisted | 2026-08-03
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local TravelService = {}
TravelService.Name = "TravelService"

local TRAVEL_COOLDOWN = 3 -- seconds between travels
local lastTravel: { [number]: number } = {}

function TravelService:HandleFastTravel(player: Player, payload: any)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local zoneId = payload and payload.zone
	if typeof(zoneId) ~= "string" then
		self.ctx.Services.SecurityService:Flag(player, "travel: bad zone")
		return
	end
	local zone = ZoneCatalog.Get(zoneId)
	if not zone then
		return
	end

	-- Unlock check
	if data.level < zone.unlockLevel then
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "travelDenied", text = "Reach level " .. zone.unlockLevel .. " to unlock " .. zone.name .. "!" },
		})
		return
	end

	-- Cooldown
	local now = os.clock()
	if (lastTravel[player.UserId] or 0) + TRAVEL_COOLDOWN > now then
		return
	end
	lastTravel[player.UserId] = now

	-- Character check
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not root or not humanoid then
		return
	end

	-- Cancel any in-flight cast (bobber cleanup is FishingService's job)
	local fishing = self.ctx.Services.FishingService
	if fishing then
		fishing:Cleanup(player.UserId, true)
	end

	-- Destination: zone region center (fallback to a sane spot)
	local dest = Vector3.new(0, 3, -5000)
	local region = Workspace:FindFirstChild("ZoneRegion_" .. zoneId) :: BasePart?
	if region then
		local pos = region:GetPivot().Position
		dest = Vector3.new(pos.X, 3, pos.Z)
	end

	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	root.CFrame = CFrame.new(dest)
	task.wait(0.15)
	root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

	Remotes:SendToClient(player, {
		type = "EventBanner",
		payload = { kind = "zoneEnter", text = "Welcome to " .. zone.name .. "!" },
	})
end

function TravelService:Init(ctx)
	self.ctx = ctx
	ctx.MessageHandlers.FastTravel = function(player, payload)
		self:HandleFastTravel(player, payload)
	end
end

function TravelService:Start()
end

function TravelService:Stop()
end

return TravelService
]===]

-- StarterPlayer/StarterPlayerScripts/Bootstrap
local inst_StarterPlayer_StarterPlayerScripts_Bootstrap = ensureChain([===[StarterPlayer/StarterPlayerScripts/Bootstrap]===], 'LocalScript')
inst_StarterPlayer_StarterPlayerScripts_Bootstrap.Source = [===[--!strict
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
]===]

-- StarterPlayer/StarterPlayerScripts/Controllers
local inst_StarterPlayer_StarterPlayerScripts_Controllers = ensureChain([===[StarterPlayer/StarterPlayerScripts/Controllers]===], 'Folder')

-- StarterPlayer/StarterPlayerScripts/Controllers/AudioController
local inst_StarterPlayer_StarterPlayerScripts_Controllers_AudioController = ensureChain([===[StarterPlayer/StarterPlayerScripts/Controllers/AudioController]===], 'ModuleScript')
inst_StarterPlayer_StarterPlayerScripts_Controllers_AudioController.Source = [===[--!strict
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
]===]

-- StarterPlayer/StarterPlayerScripts/Controllers/CastController
local inst_StarterPlayer_StarterPlayerScripts_Controllers_CastController = ensureChain([===[StarterPlayer/StarterPlayerScripts/Controllers/CastController]===], 'ModuleScript')
inst_StarterPlayer_StarterPlayerScripts_Controllers_CastController.Source = [===[--!strict
--[[
	Tidebound — CastController (client, ModuleScript)
	Casting + reeling input. Server-authoritative: we only send intents.
	- Hold Q / mouse / CAST button to charge power, release to cast.
	- While reeling: hold to reel (progress rises, tension rises), release to rest.
	- Auto-reel button consumes premium tokens (never required).
	Phase 4 | AI-assisted | 2026-08-02
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local CastController = {}
CastController.Name = "CastController"

local player = Players.LocalPlayer
local gui: ScreenGui
local castButton: TextButton
local reelFrame: Frame
local powerBarFill: Frame
local progressFill: Frame
local tensionFill: Frame
local reelHint: TextLabel
local autoReelButton: TextButton

local charging = false
local chargeStart = 0
local isReeling = false
local lastHold = false
local lastHoldSent = false
local inputConnections: { RBXScriptConnection } = {}

local function canAct(): boolean
	return not ClientState:Get().uiOpen
end

-- ── UI ───────────────────────────────────────────────────────────────────

function CastController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "CastGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 5,
		Parent = player.PlayerGui,
	})

	-- Power bar (above cast button)
	local powerBar = UiKit.Frame(gui, UDim2.fromScale(0.28, 0.05), UDim2.fromScale(1, 0.5), Theme.BgPanel, 8)
	powerBar.Position = UDim2.fromScale(0.5, 0.62)
	powerBar.AnchorPoint = Vector2.new(0.5, 0.5)
	powerBar.BackgroundTransparency = 0.6
	powerBar.Visible = false
	powerBarFill = UiKit.Frame(powerBar, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	powerBarFill.AnchorPoint = Vector2.new(0, 0)

	-- Cast button (mobile-first; also clickable on desktop)
	castButton = UiKit.New("TextButton", {
		Name = "CastButton",
		Text = "🎣\nCAST",
		Size = UDim2.fromScale(0.2, 0.14),
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = 18,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = gui,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = castButton })
	local castPad = UiKit.New("UIPadding", { PaddingBottom = UDim.new(0, 18), PaddingRight = UDim.new(0, 18), Parent = castButton })

	-- Reel frame (hidden until a bite)
	reelFrame = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.22), UDim2.fromScale(0.5, 0.78), Theme.BgPanel, 12)
	reelFrame.AnchorPoint = Vector2.new(0.5, 1)
	reelFrame.Visible = false

	reelHint = UiKit.Label(reelFrame, "HOLD to reel — release to rest!", UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), Theme.Text)
	UiKit.Label(reelFrame, "PROGRESS", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.22), Theme.TextDim, nil, 12)
	local progressBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.4), Theme.BgPanelLight, 6)
	progressFill = UiKit.Frame(progressBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Success, 6)
	UiKit.Label(reelFrame, "TENSION", UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.25, 0.55), Theme.TextDim, nil, 12)
	local tensionBg = UiKit.Frame(reelFrame, UDim2.fromScale(0.5, 0.12), UDim2.fromScale(0.25, 0.73), Theme.BgPanelLight, 6)
	tensionFill = UiKit.Frame(tensionBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Danger, 6)

	autoReelButton = UiKit.Button(reelFrame, "⚡ AUTO-REEL", function()
		ClientState:Send("AutoReel")
	end, { size = UDim2.fromScale(0.16, 0.24), pos = UDim2.fromScale(0.84, 0.6), color = Theme.Accent2, textSize = 12 })
end

-- ── Input ────────────────────────────────────────────────────────────────

local function isCastInput(input: InputObject): boolean
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		return true
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		return true
	end
	return false
end

local function beginCharge()
	if not canAct() or isReeling then
		return
	end
	charging = true
	chargeStart = os.clock()
	powerBar.Visible = true
	powerBar.Parent.Visible = true
	powerBarFill.Size = UDim2.fromScale(0, 1)
end

local function endCharge()
	if not charging then
		return
	end
	charging = false
	powerBar.Visible = false
	local heldFor = os.clock() - chargeStart
	local power = Util.clamp(heldFor / Config.CAST_POWER_TIME, 0, 1)
	if heldFor < 0.1 then
		power = Config.QUICK_CAST_POWER -- tap = quick cast
	end
	-- Direction: camera look, flattened to the water plane
	local camera = Workspace.CurrentCamera
	local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude < 0.1 then
		look = Vector3.new(0, 0, -1)
	end
	ClientState:Send("Cast", { dir = look.Unit, power = power })
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("cast_splash")
	end)
end

local function onHoldChange(held: boolean)
	lastHold = held
	if isReeling and lastHoldSent ~= held then
		lastHoldSent = held
		ClientState:Send("ReelHold", { held = held })
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function CastController:HandleBite(_payload: any)
	isReeling = true
	lastHoldSent = nil
	reelFrame.Visible = true
	castButton.Visible = false
	progressFill.Size = UDim2.fromScale(0, 1)
	tensionFill.Size = UDim2.fromScale(0, 1)
	pcall(function()
		require(script.Parent.Parent.Controllers.AudioController):Play("bite")
	end)
end

function CastController:HandleReelState(payload: any)
	if not isReeling then
		return
	end
	local p = Util.clamp(payload.progress or 0, 0, 100) / 100
	local t = Util.clamp(payload.tension or 0, 0, 100) / 100
	progressFill.Size = UDim2.fromScale(p, 1)
	tensionFill.Size = UDim2.fromScale(t, 1)
	if payload.fishName and payload.fishName ~= "" then
		local rarity = payload.rarity or "common"
		reelHint.Text = payload.fishName .. " — " .. (Theme.RarityName[rarity] or rarity)
		reelHint.TextColor3 = Theme.Rarity[rarity] or Theme.Text
	end
end

function CastController:HandleCatchResult(_payload: any)
	isReeling = false
	lastHoldSent = nil
	reelFrame.Visible = false
	castButton.Visible = true
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function CastController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("Bite", function(payload)
		self:HandleBite(payload)
	end)
	ctx.RegisterHandler("ReelState", function(payload)
		self:HandleReelState(payload)
	end)
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
end

function CastController:Start()
	self:BuildUI()

	table.insert(inputConnections, UserInputService.InputBegan:Connect(function(input)
		if isCastInput(input) then
			beginCharge()
		end
		if isCastInput(input) then
			onHoldChange(true)
		end
	end))
	table.insert(inputConnections, UserInputService.InputEnded:Connect(function(input)
		if isCastInput(input) then
			endCharge()
			onHoldChange(false)
		end
	end))

	castButton.MouseButton1Down:Connect(function()
		beginCharge()
	end)
	castButton.MouseButton1Up:Connect(function()
		endCharge()
	end)

	-- Power bar animation
	RunService.RenderStepped:Connect(function(_dt)
		if charging then
			local power = Util.clamp((os.clock() - chargeStart) / Config.CAST_POWER_TIME, 0, 1)
			powerBarFill.Size = UDim2.fromScale(power, 1)
		end
	end)
end

function CastController:Stop()
	for _, conn in inputConnections do
		conn:Disconnect()
	end
	if gui then
		gui:Destroy()
	end
end

return CastController
]===]

-- StarterPlayer/StarterPlayerScripts/Controllers/MenuUIController
local inst_StarterPlayer_StarterPlayerScripts_Controllers_MenuUIController = ensureChain([===[StarterPlayer/StarterPlayerScripts/Controllers/MenuUIController]===], 'ModuleScript')
inst_StarterPlayer_StarterPlayerScripts_Controllers_MenuUIController.Source = [===[--!strict
--[[
	Tidebound — MenuUIController (client, ModuleScript)
	Full-screen panels: Shop (rods/baits/upgrades), Pearls (cosmetics),
	Store (Robux gamepasses + dev products), Bestiary, Bag (filters/sort),
	Quests, Achievements, Contest, Travel, Profile (titles + stats).
	All prices/stats come from shared catalogs — nothing hardcoded here.
	Phase 7 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)
local RodCatalog = require(ReplicatedStorage.Shared.Data.RodCatalog)
local ZoneCatalog = require(ReplicatedStorage.Shared.Data.ZoneCatalog)
local QuestCatalog = require(ReplicatedStorage.Shared.Data.QuestCatalog)
local CosmeticsCatalog = require(ReplicatedStorage.Shared.Data.CosmeticsCatalog)

local MenuUIController = {}
MenuUIController.Name = "MenuUIController"

local player = Players.LocalPlayer
local gui: ScreenGui
local openPanel: string? = nil
local panelFrame: Frame?
local zoneFilter = "sunshall"
local currentDetail: string? = nil
local shopTab = "rods"
local bagFilter = "all"
local bagSort = "new"
local contestRequested = false

local ZONE_ORDER = { "sunshall", "whisper", "drop", "ember", "frost", "abyss", "hidden_isles", "sunken_grotto" }
local AUTO_SELL_OPTIONS = { "off", "common", "uncommon", "rare" }
local BAG_FILTERS = { "all", "common", "uncommon", "rare", "epic", "legendary", "shiny" }

-- ── Core panel scaffolding ───────────────────────────────────────────────

local function makePanel(title: string): Frame
	if panelFrame then
		panelFrame:Destroy()
	end
	local panel = UiKit.Frame(gui, UDim2.fromScale(0.8, 0.86), UDim2.fromScale(0.5, 0.5), Theme.Bg, 18)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panelFrame = panel
	UiKit.Label(panel, title, UDim2.fromScale(0.5, 0.06), UDim2.fromScale(0.25, 0.01), Theme.Text, Theme.FontTitle, 24)
	UiKit.Button(panel, "✕", function()
		MenuUIController:Close()
	end, { size = UDim2.fromScale(0.05, 0.05), pos = UDim2.fromScale(0.94, 0.01), color = Theme.Danger, textSize = 16 })
	return panel
end

function MenuUIController:Open(name: string)
	openPanel = name
	ClientState:Get().uiOpen = true
	if name == "contest" then
		contestRequested = false
	end
	self:Refresh()
end

function MenuUIController:Close()
	openPanel = nil
	ClientState:Get().uiOpen = false
	if panelFrame then
		panelFrame:Destroy()
		panelFrame = nil
	end
end

function MenuUIController:Toggle(name: string)
	if openPanel == name then
		self:Close()
	else
		self:Open(name)
	end
end

-- ══════════════════════ SHOP ══════════════════════

local function shopRodsTab(panel: Frame)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.12), 6)
	local s = ClientState:Get()
	for _, rod in ipairs(RodCatalog.GetSorted()) do
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.9, 0.13), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, rod.name, UDim2.fromScale(0.3, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 17)
		UiKit.Label(row, "Luck +" .. math.floor(rod.luck * 100) .. "%  •  Str " .. rod.strength .. "  •  Lure -" .. rod.lure .. "s",
			UDim2.fromScale(0.44, 0.5), UDim2.fromScale(0.32, 0.05), Theme.TextDim, nil, 13)
		local owned = s.rods[rod.id] == true
		local equipped = s.equippedRod == rod.id
		local affordable = s.coins >= rod.cost
		local levelOk = s.level >= rod.unlockLevel
		local statusText = if equipped then "EQUIPPED"
			elseif owned then "Equip"
			else "Buy • " .. Util.formatNumber(rod.cost) .. " 🪙"
		if not owned and not affordable then
			statusText = statusText .. "\n(need " .. Util.formatNumber(rod.cost - s.coins) .. " more)"
		end
		if not owned and not levelOk then
			statusText = statusText .. "\n(Lv " .. rod.unlockLevel .. " req)"
		end
		local btn = UiKit.Button(row, statusText, function()
			if owned then
				ClientState:Send("EquipRod", { rodId = rod.id })
				MenuUIController:Refresh()
			elseif levelOk then
				ClientState:Send("BuyRod", { rodId = rod.id })
				MenuUIController:Refresh()
			end
		end, { size = UDim2.fromScale(0.22, 0.72), pos = UDim2.fromScale(0.76, 0.14), color = if equipped then Theme.Accent2 elseif owned then Theme.Success elseif affordable then Theme.Accent else Theme.BgPanelLight, textSize = 12 })
	end
end

local function shopBaitsTab(panel: Frame)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.12), 6)
	local s = ClientState:Get()
	for id, def in pairs(Config.BAITS) do
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, def.name, UDim2.fromScale(0.25, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 16)
		UiKit.Label(row, "Price: " .. def.cost .. " 🪙 / " .. def.count .. "x   •   Owned: " .. (s.baits[id] or 0),
			UDim2.fromScale(0.45, 0.5), UDim2.fromScale(0.28, 0.05), Theme.TextDim, nil, 13)
		local equipped = s.equippedBait == id
		UiKit.Button(row, "Equip", function()
			ClientState:Send("EquipBait", { baitId = id })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.1, 0.6), pos = UDim2.fromScale(0.72, 0.2), color = if equipped then Theme.Accent2 else Theme.Success, textSize = 12 })
		UiKit.Button(row, "+" .. def.count, function()
			ClientState:Send("BuyBait", { baitId = id, count = def.count })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.09, 0.6), pos = UDim2.fromScale(0.83, 0.2), color = Theme.Accent, textSize = 12 })
	end
	UiKit.Label(panel, "💡 Equipped bait is consumed per cast. Golden Lure: +luck & +weight!",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.93), Theme.TextDim, nil, 12)
end

local function shopUpgradesTab(panel: Frame)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.12), 6)
	local s = ClientState:Get()
	for i, def in ipairs(Config.INVENTORY_UPGRADES) do
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, "Tackle Box +" .. def.slots .. " slots", UDim2.fromScale(0.4, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 16)
		local tierOwned = s.invUpgradeTier >= i
		local canBuy = s.invUpgradeTier + 1 == i
		local btnText = if tierOwned then "OWNED" else (if canBuy then "Upgrade • " .. Util.formatNumber(def.cost) .. " 🪙" else "🔒")
		UiKit.Button(row, btnText, function()
			ClientState:Send("BuyUpgrade", { tier = i })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.22, 0.6), pos = UDim2.fromScale(0.76, 0.2), color = if canBuy then Theme.Accent else Theme.BgPanelLight, textSize = 12 })
	end
	UiKit.Label(panel, "The Bigger Tackle Box gamepass adds +50 slots instantly (Store tab).",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.93), Theme.TextDim, nil, 12)
end

local function shopPanel()
	local panel = makePanel("🎣 SHOP")
	local tabs = { { "rods", "Rods" }, { "baits", "Baits" }, { "upgrades", "Upgrades" } }
	for i, tab in ipairs(tabs) do
		UiKit.Button(panel, tab[2], function()
			shopTab = tab[1]
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.18, 0.05), pos = UDim2.fromScale(0.04 + 0.19 * (i - 1), 0.06), color = if shopTab == tab[1] then Theme.Accent else Theme.BgPanelLight, textSize = 14 })
	end
	if shopTab == "rods" then
		shopRodsTab(panel)
	elseif shopTab == "baits" then
		shopBaitsTab(panel)
	else
		shopUpgradesTab(panel)
	end
end

-- ══════════════════════ PEARLS (cosmetics) ══════════════════════

local KIND_ORDER = { "bobber", "trail", "aura", "rodSkin", "nameColor" }
local KIND_LABELS = {
	bobber = "Bobbers", trail = "Trails", aura = "Auras", rodSkin = "Rod Grips", nameColor = "Name Colors",
}

local function pearlsPanel()
	local panel = makePanel("🐚 PEARL SHOP")
	local s = ClientState:Get()
	UiKit.Label(panel, "Your pearls: " .. Util.formatNumber(s.pearls) .. " 🐚", UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.06), Theme.Accent, Theme.FontBold, 16)

	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.74), UDim2.fromScale(0.03, 0.13), 6)
	local yOffset = 0
	for _, kind in ipairs(KIND_ORDER) do
		UiKit.Label(scroll, "— " .. KIND_LABELS[kind] .. " —", UDim2.fromScale(0.9, 0.04), UDim2.fromScale(0.02, 0), Theme.TextDim, Theme.FontBold, 13)
		for _, def in ipairs(CosmeticsCatalog.GetByKind(kind)) do
			local owned = s.cosmeticsOwned[def.id] == true
			local equipped = s.cosmetics[def.kind] == def.id
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.92, 0.11), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			-- color swatch
			local swatch = UiKit.Frame(row, UDim2.fromScale(0.04, 0.5), UDim2.fromScale(0.02, 0.25), def.color, 4)
			swatch.BorderSizePixel = 0
			UiKit.Label(row, def.name, UDim2.fromScale(0.3, 0.5), UDim2.fromScale(0.08, 0.05), Theme.Text, Theme.FontBold, 15)
			UiKit.Label(row, def.desc, UDim2.fromScale(0.5, 0.4), UDim2.fromScale(0.08, 0.5), Theme.TextDim, nil, 11)
			local btnText = if equipped then "EQUIPPED" else (if owned then "Equip" else def.price .. " 🐚")
			UiKit.Button(row, btnText, function()
				if owned then
					ClientState:Send("EquipCosmetic", { cosmeticId = def.id })
				else
					ClientState:Send("BuyCosmetic", { cosmeticId = def.id })
				end
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.16, 0.6), pos = UDim2.fromScale(0.8, 0.2), color = if equipped then Theme.Accent2 elseif owned then Theme.Success else Theme.Accent, textSize = 12 })
		end
	end
	UiKit.Label(panel, "Cosmetics are visual only — they never affect your catch rates.",
		UDim2.fromScale(0.9, 0.04), UDim2.fromScale(0.05, 0.9), Theme.TextDim, nil, 12)
end

-- ══════════════════════ STORE (Robux) ══════════════════════

local function storePanel()
	local panel = makePanel("🛒 STORE")
	local s = ClientState:Get()
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.8), UDim2.fromScale(0.03, 0.08), 6)

	local passNames = {
		double_catch = "Double Catch — 2x coins from selling fish",
		bigger_tackle_box = "Bigger Tackle Box — +50 inventory slots",
		lucky_charm = "Lucky Charm — +15% luck (capped, fair)",
		vip_angler = "VIP Angler — +10% XP, exclusive rod skin, gold name",
		golden_lure_pass = "Golden Lure Pass — permanent best bait",
		starter_pack = "Starter Pack — 500 coins + 5 Golden Lures + bobber",
	}
	local productNames = {
		pearls_100 = "100 Pearls",
		pearls_450 = "450 Pearls",
		pearls_1000 = "1000 Pearls",
		auto_reel_tokens = "Auto-Reel Tokens (x100)",
		xp_boost_2h = "XP Boost (2 hours)",
	}

	local shown = 0
	for key, id in pairs(Config.GAMEPASS_IDS) do
		if id > 0 then
			shown += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.92, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, passNames[key] or key, UDim2.fromScale(0.72, 0.6), UDim2.fromScale(0.03, 0.1), Theme.Text, Theme.FontBold, 14)
			local owned = s.cosmeticsOwned["pass_" .. key] == true
			UiKit.Button(row, "Get", function()
				pcall(function()
					MarketplaceService:PromptGamePassPurchase(player, id)
				end)
			end, { size = UDim2.fromScale(0.14, 0.6), pos = UDim2.fromScale(0.8, 0.2), color = Theme.Accent2, textSize = 13 })
		end
	end
	for key, id in pairs(Config.PRODUCT_IDS) do
		if id > 0 then
			shown += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.92, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, productNames[key] or key, UDim2.fromScale(0.72, 0.6), UDim2.fromScale(0.03, 0.1), Theme.Text, Theme.FontBold, 14)
			UiKit.Button(row, "Get", function()
				pcall(function()
					MarketplaceService:PromptProductPurchase(player, id)
				end)
			end, { size = UDim2.fromScale(0.14, 0.6), pos = UDim2.fromScale(0.8, 0.2), color = Theme.Accent, textSize = 13 })
		end
	end
	if shown == 0 then
		UiKit.Label(scroll, "The store is being stocked — the pearl shop is already open! 🐚",
			UDim2.fromScale(0.9, 0.08), UDim2.fromScale(0.03, 0.05), Theme.TextDim, nil, 14)
	end
	UiKit.Label(panel, "All purchases are one-time, cosmetic or time-saving. Nothing is pay-to-win.",
		UDim2.fromScale(0.9, 0.04), UDim2.fromScale(0.05, 0.9), Theme.TextDim, nil, 12)
end

-- ══════════════════════ BESTIARY ══════════════════════

local function zoneCompletion(zoneId: string): number
	local s = ClientState:Get()
	local zone = ZoneCatalog.Get(zoneId)
	if not zone then
		return 0
	end
	local total = #zone.fishIds
	local caught = 0
	for _, fishId in ipairs(zone.fishIds) do
		local entry = s.bestiary[fishId]
		if entry and entry.caught > 0 then
			caught += 1
		end
	end
	if total == 0 then
		return 0
	end
	return math.floor(caught / total * 100)
end

local function bestiaryGrid(panel: Frame, zoneId: string)
	UiKit.Label(panel, "Zone completion: " .. zoneCompletion(zoneId) .. "%", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.04, 0.1), Theme.Accent, Theme.FontBold, 15)
	UiKit.Label(panel, "💡 Shiny variants exist for every fish. Complete zones for pearl rewards!",
		UDim2.fromScale(0.8, 0.05), UDim2.fromScale(0.04, 0.15), Theme.TextDim, nil, 12)
	local zone = ZoneCatalog.Get(zoneId)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.72), UDim2.fromScale(0.03, 0.22), 8)
	UiKit.New("UIGridLayout", {
		CellSize = UDim2.fromScale(0.23, 0.28),
		CellPadding = UDim2.fromScale(0.015, 0.02),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroll,
	})
	local s = ClientState:Get()
	for _, fishId in ipairs(zone.fishIds) do
		local def = FishCatalog.Get(fishId)
		local entry = s.bestiary[fishId]
		local caught = entry and entry.caught or 0
		local tile = UiKit.Frame(scroll, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.BgPanel, 10)
		if caught == 0 then
			tile.BackgroundColor3 = Theme.BgPanelLight
			tile.BackgroundTransparency = 0.6
		end
		UiKit.Frame(tile, UDim2.fromScale(1, 0.04), UDim2.fromScale(0, 0), Theme.Rarity[def.rarity], 0)
		UiKit.Label(tile, if caught > 0 then def.name else "???", UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0.25), if caught > 0 then Theme.Text else Theme.TextDim, Theme.FontBold, 13)
		UiKit.Label(tile, "caught: " .. caught .. (entry and entry.shiny and " ✨" or ""), UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.55), Theme.TextDim, nil, 11)
		local btn = UiKit.Button(tile, "View", function()
			currentDetail = fishId
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.6, 0.2), pos = UDim2.fromScale(0.2, 0.76), color = Theme.BgPanelLight, textSize = 11 })
		if caught == 0 then
			btn.BackgroundTransparency = 0.7
		end
	end
end

local function bestiaryDetail(panel: Frame, fishId: string)
	local def = FishCatalog.Get(fishId)
	local s = ClientState:Get()
	local entry = s.bestiary[fishId]
	local caught = entry and entry.caught or 0
	local shinyCaught = entry and entry.shiny or false
	UiKit.Button(panel, "← Back", function()
		currentDetail = nil
		MenuUIController:Refresh()
	end, { size = UDim2.fromScale(0.1, 0.05), pos = UDim2.fromScale(0.02, 0.06), color = Theme.BgPanelLight, textSize = 14 })
	local vp = UiKit.New("ViewportFrame", {
		Name = "DetailViewport",
		Size = UDim2.fromScale(0.4, 0.42),
		Position = UDim2.fromScale(0.05, 0.14),
		BackgroundColor3 = Theme.Bg,
		Parent = panel,
	})
	local ok, model = pcall(FishVisuals.Build, fishId, shinyCaught)
	if ok and model then
		model.Parent = vp
		vp.CurrentCamera = Instance.new("Camera")
		vp.CurrentCamera.CFrame = FishVisuals.FrameCamera(model, 4)
	end
	local zoneName = ZoneCatalog.Get(def.zone)
	UiKit.Label(panel, def.name .. (shinyCaught and " ✨" or ""), UDim2.fromScale(0.5, 0.07), UDim2.fromScale(0.48, 0.14), Theme.Rarity[def.rarity], Theme.FontTitle, 22)
	UiKit.Label(panel, (Theme.RarityName[def.rarity] or ""):upper() .. " • " .. (zoneName and zoneName.name or def.zone),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.21), Theme.TextDim, Theme.FontBold, 13)
	UiKit.Label(panel, "⚖ " .. def.minWeight .. "–" .. def.maxWeight .. " kg   •   💰 " .. def.baseValue .. " 🪙/kg   •   ✨ " .. def.xp .. " XP",
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.27), Theme.Text, nil, 13)
	UiKit.Label(panel, "🎯 Bait: " .. (def.bait and (Config.BAITS[def.bait] and Config.BAITS[def.bait].name or def.bait) or "any"),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.33), Theme.TextDim, nil, 13)
	UiKit.Label(panel, "🌙 Night-only: " .. (def.time == "night" and "yes" or "no") .. (def.stormOnly and "   ⛈ Storm-only: yes" or ""),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.39), Theme.TextDim, nil, 13)
	UiKit.Label(panel, "📖 " .. def.desc, UDim2.fromScale(0.9, 0.16), UDim2.fromScale(0.48, 0.45), Theme.Text, nil, 14)
	UiKit.Label(panel, "Best: " .. (entry and entry.maxWeight or 0) .. " kg   •   Caught: " .. caught .. (shinyCaught and " (incl. SHINY)" or ""),
		UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.48, 0.62), Theme.Gold, Theme.FontBold, 14)
end

local function bestiaryPanel()
	local panel = makePanel("📖 BESTIARY")
	for i, zoneId in ipairs(ZONE_ORDER) do
		local zone = ZoneCatalog.Get(zoneId)
		UiKit.Button(panel, zone.name, function()
			zoneFilter = zoneId
			currentDetail = nil
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.16, 0.05), pos = UDim2.fromScale(0.02 + 0.1 * (i - 1), 0.06), color = if zoneFilter == zoneId then Theme.Accent else Theme.BgPanelLight, textSize = 11 })
	end
	if currentDetail then
		bestiaryDetail(panel, currentDetail)
	else
		bestiaryGrid(panel, zoneFilter)
	end
end

-- ══════════════════════ BAG ══════════════════════

local function matchesFilter(item: any, def: any): boolean
	if bagFilter == "all" then
		return true
	end
	if bagFilter == "shiny" then
		return item.shiny == true
	end
	return def.rarity == bagFilter
end

local function inventoryPanel()
	local panel = makePanel("🎒 BAG")
	local s = ClientState:Get()
	UiKit.Label(panel, "Capacity: " .. #s.inventory .. " / " .. s.invSlots, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.08), Theme.Text, Theme.FontBold, 14)
	local capBg = UiKit.Frame(panel, UDim2.fromScale(0.4, 0.03), UDim2.fromScale(0.04, 0.14), Theme.BgPanelLight, 6)
	UiKit.Frame(capBg, UDim2.fromScale(Util.clamp(#s.inventory / math.max(1, s.invSlots), 0, 1), 1), UDim2.fromScale(0, 0), Theme.Accent, 6)

	-- Filters
	for i, f in ipairs(BAG_FILTERS) do
		UiKit.Button(panel, f:upper(), function()
			bagFilter = f
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.08, 0.04), pos = UDim2.fromScale(0.04 + 0.085 * (i - 1), 0.18), color = if bagFilter == f then Theme.Accent2 else Theme.BgPanelLight, textSize = 10 })
	end
	-- Sort
	UiKit.Button(panel, if bagSort == "new" then "Newest" else "Biggest", function()
		bagSort = if bagSort == "new" then "big" else "new"
		MenuUIController:Refresh()
	end, { size = UDim2.fromScale(0.1, 0.04), pos = UDim2.fromScale(0.72, 0.18), color = Theme.BgPanelLight, textSize = 10 })

	-- Auto-sell
	UiKit.Label(panel, "Auto-sell (≤ rarity):", UDim2.fromScale(0.18, 0.04), UDim2.fromScale(0.04, 0.24), Theme.TextDim, nil, 12)
	for i, opt in ipairs(AUTO_SELL_OPTIONS) do
		UiKit.Button(panel, opt:upper(), function()
			ClientState:Send("SetAutoSell", { maxRarity = opt == "off" and nil or opt })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.09, 0.04), pos = UDim2.fromScale(0.22 + 0.095 * (i - 1), 0.24), color = if (s.autoSell or "off") == opt then Theme.Accent2 else Theme.BgPanelLight, textSize = 10 })
	end

	-- Bulk sell
	local bulk = { { "common", "Sell Commons" }, { "uncommon", "Sell Uncommons" }, { "rare", "Sell Rares" }, { "all", "Sell All (keeps ✨)" } }
	for i, b in ipairs(bulk) do
		UiKit.Button(panel, b[2], function()
			ClientState:Send("SellAll", { maxRarity = if b[1] == "all" then "epic" else b[1] })
			MenuUIController:Refresh()
		end, { size = UDim2.fromScale(0.19, 0.045), pos = UDim2.fromScale(0.04 + 0.2 * (i - 1), 0.29), color = Theme.Accent, textSize = 12 })
	end

	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.58), UDim2.fromScale(0.04, 0.36), 6)
	local items = s.inventory
	table.sort(items, function(a, b)
		if bagSort == "big" then
			return a.weight > b.weight
		end
		return a.caughtAt > b.caughtAt
	end)
	local shown = 0
	for _, item in ipairs(items) do
		local def = FishCatalog.Get(item.fishId)
		if def and matchesFilter(item, def) then
			shown += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.95, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Frame(row, UDim2.fromScale(0.02, 0.7), UDim2.fromScale(0.01, 0.15), Theme.Rarity[def.rarity], 2)
			UiKit.Label(row, (item.shiny and "✨ " or "") .. def.name, UDim2.fromScale(0.3, 1), UDim2.fromScale(0.05, 0), Theme.Text, Theme.FontBold, 13)
			UiKit.Label(row, item.weight .. " kg  •  ~" .. Util.formatNumber(math.floor(def.baseValue * item.weight * (item.shiny and Config.SHINY_VALUE_MULT or 1))) .. " 🪙",
				UDim2.fromScale(0.4, 0.6), UDim2.fromScale(0.38, 0.05), Theme.TextDim, nil, 12)
			UiKit.Button(row, "Sell", function()
				ClientState:Send("SellFish", { ids = { item.uid } })
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.12, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = Theme.Danger, textSize = 12 })
		end
	end
	if shown == 0 then
		UiKit.Label(scroll, "No fish match this filter. Go catch some! 🎣", UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0), Theme.TextDim, nil, 14)
	end
end

-- ══════════════════════ QUESTS ══════════════════════

local function questRow(parent: Instance, q: any, template: any, desc: string, claimFn: () -> ())
	local row = UiKit.Frame(parent, UDim2.fromScale(0.95, 0.11), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
	UiKit.Label(row, desc, UDim2.fromScale(0.72, 0.5), UDim2.fromScale(0.02, 0.05), Theme.Text, Theme.FontBold, 14)
	local progress = template and math.min(q.progress / template.target, 1) or 0
	local barBg = UiKit.Frame(row, UDim2.fromScale(0.72, 0.16), UDim2.fromScale(0.02, 0.55), Theme.BgPanelLight, 4)
	UiKit.Frame(barBg, UDim2.fromScale(progress, 1), UDim2.fromScale(0, 0), Theme.Accent, 4)
	UiKit.Label(row, Util.formatNumber(q.progress) .. "/" .. (template and Util.formatNumber(template.target) or "?"), UDim2.fromScale(0.2, 0.3), UDim2.fromScale(0.54, 0.6), Theme.TextDim, nil, 11)
	local btn = UiKit.Button(row, if q.claimed then "✓" else (if q.done then "Claim" else "…"), claimFn,
		{ size = UDim2.fromScale(0.14, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = if q.claimed then Theme.BgPanelLight elseif q.done then Theme.Success else Theme.BgPanelLight, textSize = 12 })
	if q.claimed then
		btn.TextColor3 = Theme.TextDim
	end
	return row
end

local function questsPanel()
	local panel = makePanel("📜 QUESTS")
	local s = ClientState:Get()
	UiKit.Label(panel, "🔥 Login streak: Day " .. s.streak, UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.04, 0.07), Theme.Accent2, Theme.FontBold, 16)
	for i = 1, 7 do
		local reward = Config.STREAK_REWARDS[i]
		local day = UiKit.Frame(panel, UDim2.fromScale(0.06, 0.09), UDim2.fromScale(0.04 + 0.07 * (i - 1), 0.13), if i == s.streak then Theme.Accent2 elseif i < s.streak then Theme.Success else Theme.BgPanelLight, 30)
		if i < s.streak then
			day.BackgroundTransparency = 0.4
		end
		UiKit.Label(day, "D" .. i, UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0.05), Theme.Text, Theme.FontBold, 12)
		local rewardText = ""
		if reward.coins then
			rewardText = reward.coins .. "🪙"
		end
		if reward.pearls then
			rewardText = rewardText .. (rewardText ~= "" and " " or "") .. reward.pearls .. "🐚"
		end
		UiKit.Label(day, rewardText, UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0.5), Theme.TextDim, nil, 9)
	end
	UiKit.Label(panel, "DAILY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.23), Theme.Accent, Theme.FontTitle, 14)
	local dailyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.28), 4)
	for i, q in ipairs(s.dailyQuests) do
		local template = QuestCatalog.GetDailyTemplate(q.templateId)
		local desc = q.templateId
		if template then
			desc = template.desc
			desc = string.gsub(desc, "{n}", tostring(template.target))
			if q.params and q.params.zone then
				local zn = ZoneCatalog.Get(q.params.zone)
				desc = string.gsub(desc, "{zone}", (zn and zn.name or q.params.zone))
			end
			if q.params and q.params.family then
				desc = string.gsub(desc, "{family}", q.params.family)
			end
		end
		questRow(dailyScroll, q, template, desc, function()
			ClientState:Send("ClaimDaily", { slot = i })
			MenuUIController:Refresh()
		end)
	end
	UiKit.Button(panel, "↻ Reroll one daily (1/day)", function()
		ClientState:Send("RerollQuest", { slot = 1 })
		MenuUIController:Refresh()
	end, { size = UDim2.fromScale(0.3, 0.045), pos = UDim2.fromScale(0.62, 0.23), color = Theme.BgPanelLight, textSize = 12 })
	UiKit.Label(panel, "WEEKLY", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.04, 0.59), Theme.Gold, Theme.FontTitle, 14)
	local weeklyScroll = UiKit.Scroll(panel, UDim2.fromScale(0.92, 0.3), UDim2.fromScale(0.04, 0.64), 4)
	for i, q in ipairs(s.weeklyQuests) do
		local template = QuestCatalog.GetWeeklyTemplate(q.templateId)
		local desc = q.templateId
		if template then
			desc = string.gsub(template.desc, "{n}", tostring(template.target))
		end
		questRow(weeklyScroll, q, template, desc, function()
			ClientState:Send("ClaimWeekly", { slot = i })
			MenuUIController:Refresh()
		end)
	end
end

-- ══════════════════════ ACHIEVEMENTS ══════════════════════

local function achievementsPanel()
	local panel = makePanel("🏅 ACHIEVEMENTS")
	local s = ClientState:Get()
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.82), UDim2.fromScale(0.03, 0.08), 6)
	local unlockedCount = 0
	for _, def in pairs(QuestCatalog.ACHIEVEMENTS) do
		local done = s.achievements[def.id] == true
		if done then
			unlockedCount += 1
		end
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.94, 0.1), UDim2.fromScale(0, 0), if done then Theme.BgPanel else Theme.BgPanelLight, 8)
		if not done then
			row.BackgroundTransparency = 0.5
		end
		UiKit.Label(row, (done and "🏅 " or "🔒 ") .. def.name, UDim2.fromScale(0.4, 0.6), UDim2.fromScale(0.03, 0.05), if done then Theme.Gold else Theme.TextDim, Theme.FontBold, 14)
		UiKit.Label(row, def.desc, UDim2.fromScale(0.45, 0.5), UDim2.fromScale(0.03, 0.5), Theme.TextDim, nil, 11)
		local rewardText = ""
		if def.rewards.pearls then
			rewardText = rewardText .. def.rewards.pearls .. " 🐚"
		end
		if def.rewards.title then
			rewardText = rewardText .. (rewardText ~= "" and " + " or "") .. "Title: " .. def.rewards.title
		end
		UiKit.Label(row, rewardText, UDim2.fromScale(0.28, 0.5), UDim2.fromScale(0.7, 0.5), Theme.Accent, nil, 11)
	end
	UiKit.Label(panel, "Unlocked: " .. unlockedCount .. " / " .. #QuestCatalog.ACHIEVEMENTS,
		UDim2.fromScale(0.4, 0.05), UDim2.fromScale(0.03, 0.02), Theme.Text, Theme.FontBold, 14)
end

-- ══════════════════════ CONTEST ══════════════════════

local function contestPanel()
	local panel = makePanel("🏆 WEEKLY CONTEST")
	local s = ClientState:Get()
	if not contestRequested then
		contestRequested = true
		ClientState:Send("GetContestTop")
	end
	UiKit.Label(panel, "Biggest catch of the week wins! Week: " .. (s.contestTop and s.contestTop.week or "…"),
		UDim2.fromScale(0.6, 0.05), UDim2.fromScale(0.04, 0.06), Theme.Accent2, Theme.FontBold, 14)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.68), UDim2.fromScale(0.03, 0.13), 6)
	local entries = s.contestTop and s.contestTop.entries or nil
	if entries and #entries > 0 then
		for i, e in ipairs(entries) do
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.94, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, (i == 1 and "🥇 " or i == 2 and "🥈 " or i == 3 and "🥉 " or "   ") .. "#" .. i .. "  " .. e.name,
				UDim2.fromScale(0.6, 1), UDim2.fromScale(0.03, 0), if i <= 3 then Theme.Gold else Theme.Text, Theme.FontBold, 15)
			UiKit.Label(row, Util.formatNumber(e.score) .. " pts", UDim2.fromScale(0.25, 1), UDim2.fromScale(0.72, 0), Theme.Accent, Theme.FontBold, 14)
		end
	else
		UiKit.Label(scroll, "No catches yet this week — be the first! 🎣", UDim2.fromScale(0.9, 0.1), UDim2.fromScale(0.05, 0.05), Theme.TextDim, nil, 14)
	end
	UiKit.Button(panel, "↻ Refresh", function()
		contestRequested = true
		ClientState:Send("GetContestTop")
		task.delay(0.5, function()
			MenuUIController:Refresh()
		end)
	end, { size = UDim2.fromScale(0.16, 0.05), pos = UDim2.fromScale(0.42, 0.84), color = Theme.Accent, textSize = 13 })
	UiKit.Label(panel, "Top 10 win pearls every Monday. Score = weight × rarity bonus.",
		UDim2.fromScale(0.8, 0.05), UDim2.fromScale(0.1, 0.9), Theme.TextDim, nil, 12)
end

-- ══════════════════════ TRAVEL ══════════════════════

local function travelPanel()
	local panel = makePanel("🗺 TRAVEL")
	local s = ClientState:Get()
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.94, 0.76), UDim2.fromScale(0.03, 0.1), 6)
	for _, zoneId in ipairs(ZONE_ORDER) do
		local zone = ZoneCatalog.Get(zoneId)
		local unlocked = s.level >= zone.unlockLevel
		local row = UiKit.Frame(scroll, UDim2.fromScale(0.95, 0.12), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
		UiKit.Label(row, zone.name, UDim2.fromScale(0.5, 1), UDim2.fromScale(0.02, 0), Theme.Text, Theme.FontBold, 16)
		UiKit.Label(row, if unlocked then "Level " .. zone.unlockLevel .. " • Ready" else "Requires level " .. zone.unlockLevel,
			UDim2.fromScale(0.3, 0.6), UDim2.fromScale(0.5, 0.05), if unlocked then Theme.Success else Theme.TextDim, nil, 13)
		UiKit.Button(row, "Go! ⚡", function()
			ClientState:Send("FastTravel", { zone = zoneId })
			MenuUIController:Close()
		end, { size = UDim2.fromScale(0.16, 0.6), pos = UDim2.fromScale(0.82, 0.2), color = if unlocked then Theme.Accent else Theme.BgPanelLight, textSize = 13 })
	end
	UiKit.Label(panel, "Fast travel is free — unlock zones by leveling up!",
		UDim2.fromScale(0.9, 0.05), UDim2.fromScale(0.05, 0.88), Theme.TextDim, nil, 13)
end

-- ══════════════════════ PROFILE ══════════════════════

local function profilePanel()
	local panel = makePanel("👤 PROFILE")
	local s = ClientState:Get()
	UiKit.Label(panel, player.Name .. (s.equippedTitle and (" — " .. s.equippedTitle) or ""),
		UDim2.fromScale(0.6, 0.06), UDim2.fromScale(0.2, 0.04), Theme.Text, Theme.FontTitle, 22)

	-- Stats
	local st = s.stats or {}
	local statsText = string.format(
		"Fish caught: %s   •   Coins earned: %s   •   Pearls earned: %s\nShinies: %s   •   Storm fish: %s   •   Night fish: %s   •   Deep fish: %s",
		Util.formatNumber(st.totalCatch or 0),
		Util.formatNumber(st.totalCoinsEarned or 0),
		Util.formatNumber(st.totalPearlsEarned or 0),
		Util.formatNumber(st.shinyFish or 0),
		Util.formatNumber(st.stormFish or 0),
		Util.formatNumber(st.nightFish or 0),
		Util.formatNumber(st.deepFish or 0)
	)
	UiKit.Label(panel, statsText, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0.05, 0.12), Theme.Text, nil, 13)
	local bc = st.bestCatch
	if bc and bc.fishId ~= "" then
		local bdef = FishCatalog.Get(bc.fishId)
		UiKit.Label(panel, "🏆 Best catch: " .. (bdef and bdef.name or bc.fishId) .. " — " .. bc.weight .. " kg",
			UDim2.fromScale(0.6, 0.05), UDim2.fromScale(0.05, 0.24), Theme.Gold, Theme.FontBold, 14)
	end

	-- Titles
	UiKit.Label(panel, "TITLES", UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.05, 0.3), Theme.Accent, Theme.FontTitle, 14)
	local scroll = UiKit.Scroll(panel, UDim2.fromScale(0.9, 0.5), UDim2.fromScale(0.05, 0.35), 6)
	local titleCount = 0
	for title, owned in pairs(s.titles) do
		if owned then
			titleCount += 1
			local row = UiKit.Frame(scroll, UDim2.fromScale(0.94, 0.09), UDim2.fromScale(0, 0), Theme.BgPanel, 8)
			UiKit.Label(row, title, UDim2.fromScale(0.6, 1), UDim2.fromScale(0.03, 0), Theme.Text, Theme.FontBold, 14)
			local equipped = s.equippedTitle == title
			UiKit.Button(row, if equipped then "EQUIPPED" else "Equip", function()
				ClientState:Send("EquipTitle", { title = title })
				MenuUIController:Refresh()
			end, { size = UDim2.fromScale(0.18, 0.6), pos = UDim2.fromScale(0.78, 0.2), color = if equipped then Theme.Accent2 else Theme.Success, textSize = 12 })
		end
	end
	if titleCount == 0 then
		UiKit.Label(scroll, "No titles yet. Complete achievements to earn them!", UDim2.fromScale(0.9, 0.1), UDim2.fromScale(0.05, 0.05), Theme.TextDim, nil, 13)
	end
end

-- ══════════════════════ Refresh & lifecycle ══════════════════════

function MenuUIController:Refresh()
	if not openPanel then
		return
	end
	makePanel("")
	if openPanel == "shop" then
		shopPanel()
	elseif openPanel == "pearls" then
		pearlsPanel()
	elseif openPanel == "store" then
		storePanel()
	elseif openPanel == "bestiary" then
		bestiaryPanel()
	elseif openPanel == "inventory" then
		inventoryPanel()
	elseif openPanel == "quests" then
		questsPanel()
	elseif openPanel == "achievements" then
		achievementsPanel()
	elseif openPanel == "contest" then
		contestPanel()
	elseif openPanel == "travel" then
		travelPanel()
	elseif openPanel == "profile" then
		profilePanel()
	end
end

function MenuUIController:Init(ctx)
	self.ctx = ctx
end

function MenuUIController:Start()
	gui = UiKit.New("ScreenGui", {
		Name = "MenuGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 2,
		Parent = player.PlayerGui,
	})
end

function MenuUIController:Stop()
	if gui then
		gui:Destroy()
	end
end

return MenuUIController
]===]

-- StarterPlayer/StarterPlayerScripts/Controllers/UIController
local inst_StarterPlayer_StarterPlayerScripts_Controllers_UIController = ensureChain([===[StarterPlayer/StarterPlayerScripts/Controllers/UIController]===], 'ModuleScript')
inst_StarterPlayer_StarterPlayerScripts_Controllers_UIController.Source = [===[--!strict
--[[
	Tidebound — UIController (client, ModuleScript)
	HUD + gameplay overlays: coins/pearls/XP bar, event banners, catch card
	(screenshot engine), feed, level-up, streak, achievement toasts.
	Panels (shop/bestiary/inventory/quests) live in MenuUIController.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)
local FishVisuals = require(script.Parent.Parent.Modules.FishVisuals)
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local UIController = {}
UIController.Name = "UIController"

local player = Players.LocalPlayer
local gui: ScreenGui

local coinLabel: TextLabel
local pearlLabel: TextLabel
local streakLabel: TextLabel
local xpFill: Frame
local xpText: TextLabel
local bannerFrame: Frame
local bannerText: TextLabel
local hintLabel: TextLabel
local hintDismissed = false
local feedFrame: Frame
local stormChip: TextLabel
local cardContainer: Frame

-- ── UI build ─────────────────────────────────────────────────────────────

function UIController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "HudGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1,
		Parent = player.PlayerGui,
	})

	-- Top-left: currencies
	coinLabel = UiKit.Label(gui, "🪙 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.01), Theme.Gold, Theme.FontBold, 17)
	coinLabel.TextXAlignment = Enum.TextXAlignment.Left
	pearlLabel = UiKit.Label(gui, "🐚 0", UDim2.fromScale(0.16, 0.045), UDim2.fromScale(0.01, 0.06), Theme.Accent, Theme.FontBold, 17)
	pearlLabel.TextXAlignment = Enum.TextXAlignment.Left
	streakLabel = UiKit.Label(gui, "🔥 0", UDim2.fromScale(0.16, 0.04), UDim2.fromScale(0.01, 0.11), Theme.Accent2, Theme.FontBold, 15)
	streakLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Top-right: panel buttons
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	local function panelButton(name: string, label: string, order: number)
		local rowIdx = math.ceil(order / 5)
		local colIdx = (order - 1) % 5
		local btn = UiKit.Button(gui, label, function()
			menu:Toggle(name)
		end, { size = UDim2.fromScale(0.1, 0.04), pos = UDim2.fromScale(1 - 0.105 * (colIdx + 1), 0.01 + 0.045 * (rowIdx - 1)), color = Theme.BgPanelLight, textSize = 11 })
		btn.AnchorPoint = Vector2.new(1, 0)
		btn.TextColor3 = Theme.Text
		return btn
	end
	panelButton("travel", "🗺 Map", 1)
	panelButton("quests", "📜 Quests", 2)
	panelButton("shop", "🎣 Shop", 3)
	panelButton("bestiary", "📖 Bestiary", 4)
	panelButton("inventory", "🎒 Bag", 5)
	panelButton("store", "🛒 Store", 6)
	panelButton("pearls", "🐚 Pearls", 7)
	panelButton("achievements", "🏅 Medals", 8)
	panelButton("contest", "🏆 Contest", 9)
	panelButton("profile", "👤 Profile", 10)

	-- XP bar (bottom center) — the "always visible progress" FTUE element
	local xpBg = UiKit.Frame(gui, UDim2.fromScale(0.5, 0.035), UDim2.fromScale(0.5, 1), Theme.BgPanel, 8)
	xpBg.AnchorPoint = Vector2.new(0.5, 1)
	xpBg.BackgroundTransparency = 0.5
	xpFill = UiKit.Frame(xpBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Accent, 8)
	xpText = UiKit.Label(xpBg, "Lv 1", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 13)

	-- Storm countdown chip
	stormChip = UiKit.Label(gui, "", UDim2.fromScale(0.22, 0.04), UDim2.fromScale(0.5, 0.06), Theme.Storm, Theme.FontBold, 14)
	stormChip.AnchorPoint = Vector2.new(0.5, 0)

	-- First-catch hint (dismisses on the player's first catch)
	hintLabel = UiKit.Label(gui, "🎣 Hold Q (or tap CAST) to charge — release to cast!", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.5, 0.9), Theme.Gold, Theme.FontBold, 15)
	hintLabel.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Banner (top-center, animated)
	bannerFrame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.07), UDim2.fromScale(0.5, 0.12), Theme.BgPanel, 10)
	bannerFrame.AnchorPoint = Vector2.new(0.5, 0)
	bannerFrame.Visible = false
	bannerText = UiKit.Label(bannerFrame, "", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Theme.Text, Theme.FontBold, 18)

	-- Feed (bottom-left)
	feedFrame = UiKit.New("Frame", {
		Name = "Feed",
		Size = UDim2.fromScale(0.34, 0.5),
		Position = UDim2.fromScale(0.01, 0.5),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	UiKit.New("UIListLayout", { Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Parent = feedFrame })

	-- Catch card container (center overlay)
	cardContainer = UiKit.New("Frame", {
		Name = "CatchCardContainer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	})
end

-- ── HUD refresh (reads ClientState) ──────────────────────────────────────

function UIController:RefreshHud()
	local s = ClientState:Get()
	coinLabel.Text = "🪙 " .. Util.formatNumber(s.coins)
	pearlLabel.Text = "🐚 " .. Util.formatNumber(s.pearls)
	if s.streak > 1 then
		streakLabel.Text = "🔥 " .. s.streak .. " day streak"
		streakLabel.Visible = true
	else
		streakLabel.Visible = false
	end
	local needed = Util.xpForLevel(s.level, Config.XP_BASE, Config.XP_EXPONENT)
	xpFill.Size = UDim2.fromScale(Util.clamp(s.xp / needed, 0, 1), 1)
	xpText.Text = "Lv " .. s.level .. "  " .. Util.formatNumber(s.xp) .. "/" .. Util.formatNumber(needed)
end

-- ── Banner / feed / toasts ───────────────────────────────────────────────

local bannerTween: Tween? = nil

function UIController:ShowBanner(text: string, color: Color3, duration: number)
	bannerText.Text = text
	bannerFrame.BackgroundColor3 = color
	bannerFrame.Visible = true
	bannerFrame.Size = UDim2.fromScale(0.6, 0.07)
	bannerFrame.Position = UDim2.fromScale(0.5, -0.1)
	local tween = TweenService:Create(bannerFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.12),
	})
	tween:Play()
	task.delay(duration or 4, function()
		if bannerFrame and bannerFrame.Visible then
			local out = TweenService:Create(bannerFrame, TweenInfo.new(0.3), { Position = UDim2.fromScale(0.5, -0.1) })
			out:Play()
			task.delay(0.3, function()
				if bannerFrame then
					bannerFrame.Visible = false
				end
			end)
		end
	end)
end

function UIController:AddFeed(text: string, color: Color3?)
	local entry = UiKit.Frame(feedFrame, UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0), Theme.BgPanel, 6)
	entry.BackgroundTransparency = 0.35
	local label = UiKit.Label(entry, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), color or Theme.Text, nil, 13)
	label.TextXAlignment = Enum.TextXAlignment.Left
	UiKit.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = entry })
	-- Cap feed length
	local children = feedFrame:GetChildren()
	for i = 1, #children - Config.MAX_FEED_MESSAGES do
		if children[i]:IsA("Frame") then
			children[i]:Destroy()
		end
	end
	-- Fade out
	task.delay(8, function()
		if entry and entry.Parent then
			entry:Destroy()
		end
	end)
end

function UIController:Toast(text: string, color: Color3?)
	local t = UiKit.Frame(gui, UDim2.fromScale(0.42, 0.055), UDim2.fromScale(0.5, 0.22), color or Theme.Accent, 10)
	t.AnchorPoint = Vector2.new(0.5, 0)
	t.BackgroundTransparency = 0.25
	UiKit.Label(t, text, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.new(1, 1, 1), Theme.FontBold, 15)
	task.delay(3, function()
		if t and t.Parent then
			t:Destroy()
		end
	end)
end

-- ── Catch card (screenshot engine) ───────────────────────────────────────

function UIController:ShowCatchCard(payload: any)
	local fishId = payload.fishId
	local def = FishCatalog.Get(fishId)
	if not def then
		return
	end
	local shiny = payload.shiny == true
	local rarity = payload.rarity or "common"
	local color = Theme.Rarity[rarity] or Theme.Text

	cardContainer.Visible = true
	for _, child in pairs(cardContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local backdrop = UiKit.Frame(cardContainer, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(5, 10, 18), 0)
	backdrop.BackgroundTransparency = 0.35

	local card = UiKit.Frame(backdrop, UDim2.fromScale(0.34, 0.5), UDim2.fromScale(0.5, 0.5), Theme.BgPanel, 16)
	card.AnchorPoint = Vector2.new(0.5, 0.5)

	local rarityTag = UiKit.Label(card, (shiny and "✨ SHINY " or "") .. (Theme.RarityName[rarity] or rarity):upper(), UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.03), color, Theme.FontTitle, 16)

	-- Fish visual in a viewport
	local vp = UiKit.New("ViewportFrame", {
		Name = "FishViewport",
		Size = UDim2.fromScale(1, 0.5),
		Position = UDim2.fromScale(0, 0.12),
		BackgroundColor3 = Theme.Bg,
		Parent = card,
	})
	local ok, model = pcall(FishVisuals.Build, fishId, shiny)
	if ok and model then
		model.Parent = vp
		vp.CurrentCamera = Instance.new("Camera")
		vp.CurrentCamera.CFrame = FishVisuals.FrameCamera(model, 4.5)
	end

	UiKit.Label(card, payload.name or def.name, UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0.6), Theme.Text, Theme.FontTitle, 22)
	UiKit.Label(card, "⚖ " .. payload.weight .. " kg", UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0.7), Theme.Text, Theme.FontBold, 15)
	UiKit.Label(card, "+" .. Util.formatNumber(payload.coins or 0) .. " 🪙   +" .. (payload.xp or 0) .. " XP   +" .. (payload.pearls or 0) .. " 🐚",
		UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0.78), Theme.Gold, Theme.FontBold, 14)
	UiKit.Button(card, "Nice! ✨", function()
		cardContainer.Visible = false
	end, { size = UDim2.fromScale(0.4, 0.09), pos = UDim2.fromScale(0.3, 0.88), color = Theme.Accent, textSize = 14 })

	-- Auto-dismiss for rares; mythics/shiny stay until dismissed (screenshot time)
	if rarity ~= "mythic" and not shiny then
		task.delay(Config.CATCH_CARD_MS / 1000, function()
			if cardContainer.Visible then
				cardContainer.Visible = false
			end
		end)
	end
end

-- ── Server messages ──────────────────────────────────────────────────────

function UIController:HandleCatchResult(payload: any)
	if not hintDismissed and hintLabel then
		hintDismissed = true
		hintLabel.Visible = false
	end
	if payload.snapped then
		self:Toast("The line snapped! Reel when tension is low.", Theme.Danger)
		return
	end
	local idx = Config.RARITY_INDEX[payload.rarity or "common"] or 1
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	audio:PlayCatch(payload.rarity or "common", payload.shiny == true)
	if payload.golden then
		self:Toast("✨ Golden catch! +10% value", Theme.Gold)
	end
	if payload.autoSold then
		self:AddFeed("(auto-sold) " .. payload.name .. " — +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.TextDim)
	elseif payload.overflowSold then
		self:AddFeed("(bag full — sold oldest) " .. payload.name, Theme.TextDim)
	end
	if idx >= 4 or payload.shiny then
		self:ShowCatchCard(payload)
	else
		self:Toast(payload.name .. " — " .. payload.weight .. "kg  +" .. Util.formatNumber(payload.coins) .. " 🪙", Theme.Rarity[payload.rarity] or Theme.Text)
	end
end

function UIController:HandleEventBanner(payload: any)
	local kind = payload.kind
	local text = payload.text or ""
	local audio = require(script.Parent.Parent.Controllers.AudioController)
	if kind == "storm" then
		self:ShowBanner("⛈ " .. text, Theme.Storm, 5)
		audio:Play("storm")
	elseif kind == "stormWarning" then
		self:ShowBanner("🌩 " .. text, Theme.Storm, 4)
	elseif kind == "night" then
		self:ShowBanner("🌙 " .. text, Theme.Night, 4)
	elseif kind == "day" then
		self:ShowBanner("🌅 " .. text, Theme.Gold, 3)
	elseif kind == "stormEnd" then
		self:ShowBanner("☀ " .. text, Theme.Text, 3)
	elseif kind == "zoneComplete" then
		self:ShowBanner("🏆 " .. text, Theme.Success, 4)
	elseif kind == "zoneEnter" then
		self:ShowBanner("🌊 " .. text, Theme.Accent, 3)
	elseif kind == "travelDenied" then
		self:Toast(text, Theme.Danger)
	elseif kind == "oldOne" then
		self:ShowBanner("🐋 " .. text, Theme.Success, 5)
		audio:Play("catch_mythic")
	else
		self:ShowBanner(text, Theme.Accent, 4)
	end
end

function UIController:HandleLevelUp(payload: any)
	self:ShowBanner("⬆ LEVEL UP! You reached level " .. payload.level .. " (+" .. payload.coinsGranted .. " 🪙)", Theme.Accent2, 3.5)
	require(script.Parent.Parent.Controllers.AudioController):Play("levelup")
end

function UIController:HandleStreakUpdate(payload: any)
	local day = payload.streak or 1
	if day == 1 then
		return -- day-1 streak is just "welcome back", no popup
	end
	self:Toast("🔥 Day " .. day .. " streak! Rewards claimed.", Theme.Accent2)
	require(script.Parent.Parent.Controllers.AudioController):Play("streak")
end

function UIController:HandleAchievementUnlock(payload: any)
	self:ShowBanner("🏅 Achievement: " .. payload.name, Theme.Gold, 4)
	require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
end

function UIController:HandleFeedMessage(payload: any)
	self:AddFeed(payload.text or "", payload.kind == "announce" and Theme.Accent2 or Theme.TextDim)
end

function UIController:HandleBestiaryUpdate(payload: any)
	if payload.bestiaryNew then
		local def = FishCatalog.Get(payload.fishId)
		self:Toast("📖 New bestiary entry: " .. (def and def.name or "?") .. (payload.shiny and " (SHINY!)" or ""), Theme.Accent)
		require(script.Parent.Parent.Controllers.AudioController):Play("achievement")
	end
end

function UIController:HandleGoldenSpot(payload: any)
	if payload.active then
		self:ShowBanner("✨ Golden shimmer: " .. payload.zoneId .. "!", Theme.Gold, 4)
	end
end

function UIController:HandleWorldState(payload: any)
	-- Storm countdown chip updates
	if payload.stormIn and payload.stormIn > 0 and payload.stormIn <= 90 and not payload.isStorm then
		stormChip.Text = "🌩 storm in " .. math.ceil(payload.stormIn) .. "s"
		stormChip.Visible = true
	else
		stormChip.Visible = false
	end
end

function UIController:HandlePassGranted(_payload: any)
	self:Toast("✅ Purchase complete — thank you for supporting Tidebound!", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

function UIController:HandleProductGranted(_payload: any)
	self:Toast("✅ Delivered! Check your bag.", Theme.Success)
	require(script.Parent.Parent.Controllers.AudioController):Play("buy")
end

-- ── Lifecycle ────────────────────────────────────────────────────────────

function UIController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("CatchResult", function(payload)
		self:HandleCatchResult(payload)
	end)
	ctx.RegisterHandler("EventBanner", function(payload)
		self:HandleEventBanner(payload)
	end)
	ctx.RegisterHandler("LevelUp", function(payload)
		self:HandleLevelUp(payload)
	end)
	ctx.RegisterHandler("StreakUpdate", function(payload)
		self:HandleStreakUpdate(payload)
	end)
	ctx.RegisterHandler("AchievementUnlock", function(payload)
		self:HandleAchievementUnlock(payload)
	end)
	ctx.RegisterHandler("FeedMessage", function(payload)
		self:HandleFeedMessage(payload)
	end)
	ctx.RegisterHandler("BestiaryUpdate", function(payload)
		self:HandleBestiaryUpdate(payload)
	end)
	ctx.RegisterHandler("WorldState", function(payload)
		self:HandleWorldState(payload)
	end)
	ctx.RegisterHandler("GoldenSpot", function(payload)
		self:HandleGoldenSpot(payload)
	end)
	ctx.RegisterHandler("PassGranted", function(payload)
		self:HandlePassGranted(payload)
	end)
	ctx.RegisterHandler("ProductGranted", function(payload)
		self:HandleProductGranted(payload)
	end)
end

function UIController:Start()
	self:BuildUI()
	self:RefreshHud()
	ClientState:Subscribe(function(msgType, _payload)
		if msgType == "StateSync" or msgType == "QuestUpdate" or msgType == "InventorySync" then
			self:RefreshHud()
		end
	end)
end

function UIController:Stop()
	if gui then
		gui:Destroy()
	end
end

return UIController
]===]

-- StarterPlayer/StarterPlayerScripts/Modules
local inst_StarterPlayer_StarterPlayerScripts_Modules = ensureChain([===[StarterPlayer/StarterPlayerScripts/Modules]===], 'Folder')

-- StarterPlayer/StarterPlayerScripts/Modules/ClientState
local inst_StarterPlayer_StarterPlayerScripts_Modules_ClientState = ensureChain([===[StarterPlayer/StarterPlayerScripts/Modules/ClientState]===], 'ModuleScript')
inst_StarterPlayer_StarterPlayerScripts_Modules_ClientState.Source = [===[--!strict
--[[
	Tidebound — ClientState (client)
	The client's cache of server state + the ONLY place UI reads numbers from.
	Server messages are applied here and listeners are notified (UI re-renders).
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local ClientState = {}

local state = {
	coins = 0,
	pearls = 0,
	xp = 0,
	level = 1,
	equippedRod = "bamboo",
	rods = {},
	baits = {},
	equippedBait = nil,
	tokens = 0,
	xpBoostUntil = 0,
	invUpgradeTier = 0,
	inventory = {},
	bestiary = {},
	globalPct = 0,
	autoSell = nil,
	invSlots = 40,
	dailyQuests = {},
	weeklyQuests = {},
	streak = 0,
	timeOfDay = "day",
	isStorm = false,
	stormIn = 0,
	achievements = {},
	titles = {},
	equippedTitle = nil,
	cosmetics = {},
	cosmeticsOwned = {},
	stats = {},
	contestTop = nil,
	goldenSpot = nil,
	uiOpen = false, -- true while a menu panel is open (blocks casting)
}

local listeners: { (string, any) -> () } = {}

function ClientState:Get()
	return state
end

function ClientState:Subscribe(cb: (string, any) -> ())
	table.insert(listeners, cb)
end

function ClientState:Notify(msgType: string, payload: any)
	for _, cb in pairs(listeners) do
		pcall(cb, msgType, payload)
	end
end

-- Client -> server (single choke point; types validated server-side)
function ClientState:Send(msgType: string, payload: any?)
	Remotes:SendToServer({ type = msgType, payload = payload })
end

-- Apply a server message to the cache. Returns true if anything changed.
function ClientState:Apply(msgType: string, payload: any): boolean
	if typeof(payload) ~= "table" then
		return false
	end
	if msgType == "StateSync" then
		state.coins = payload.coins or state.coins
		state.pearls = payload.pearls or state.pearls
		state.xp = payload.xp or state.xp
		state.level = payload.level or state.level
		state.equippedRod = payload.equippedRod or state.equippedRod
		if typeof(payload.rods) == "table" then
			state.rods = payload.rods
		end
		if typeof(payload.baits) == "table" then
			state.baits = payload.baits
		end
		state.equippedBait = payload.equippedBait
		state.tokens = payload.tokens or 0
		state.xpBoostUntil = payload.xpBoostUntil or 0
		state.invUpgradeTier = payload.invUpgradeTier or 0
	elseif msgType == "InventorySync" then
		if typeof(payload.inventory) == "table" then
			state.inventory = payload.inventory
		end
		if typeof(payload.bestiary) == "table" then
			state.bestiary = payload.bestiary
		end
		state.globalPct = payload.globalPct or 0
		state.autoSell = payload.autoSell
		state.invSlots = payload.invSlots or state.invSlots
		if typeof(payload.achievements) == "table" then
			state.achievements = payload.achievements
		end
		if typeof(payload.titles) == "table" then
			state.titles = payload.titles
		end
		state.equippedTitle = payload.equippedTitle
		if typeof(payload.cosmetics) == "table" then
			state.cosmetics = payload.cosmetics
		end
		if typeof(payload.cosmeticsOwned) == "table" then
			state.cosmeticsOwned = payload.cosmeticsOwned
		end
		if typeof(payload.stats) == "table" then
			state.stats = payload.stats
		end
	elseif msgType == "QuestUpdate" then
		if typeof(payload.daily) == "table" then
			state.dailyQuests = payload.daily
		end
		if typeof(payload.weekly) == "table" then
			state.weeklyQuests = payload.weekly
		end
		state.streak = payload.streak or 0
	elseif msgType == "WorldState" then
		state.timeOfDay = payload.timeOfDay or state.timeOfDay
		state.isStorm = payload.isStorm == true
		state.stormIn = payload.stormIn or 0
	elseif msgType == "GoldenSpot" then
		state.goldenSpot = payload
	elseif msgType == "ContestTop" then
		state.contestTop = payload
	else
		return false
	end
	self:Notify(msgType, payload)
	return true
end

return ClientState
]===]

-- StarterPlayer/StarterPlayerScripts/Modules/FishVisuals
local inst_StarterPlayer_StarterPlayerScripts_Modules_FishVisuals = ensureChain([===[StarterPlayer/StarterPlayerScripts/Modules/FishVisuals]===], 'ModuleScript')
inst_StarterPlayer_StarterPlayerScripts_Modules_FishVisuals.Source = [===[--!strict
--[[
	Tidebound — FishVisuals (client)
	Builds a low-poly procedural fish model from a FishDef — no external models.
	Used by the catch card (ViewportFrame) and bestiary details.
	Phase 4 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishCatalog = require(ReplicatedStorage.Shared.Data.FishCatalog)

local FishVisuals = {}

local function part(className: string, name: string, parent: Instance?, color: Color3?, size: Vector3?)
	local p = Instance.new(className)
	p.Name = name
	p.Parent = parent
	if color then
		p.Color = color
	end
	if size then
		p.Size = size
	end
	return p
end

-- Build a fish model. Returns the Model (unparented; caller parents it).
function FishVisuals.Build(fishId: string, shiny: boolean): Model
	local def = FishCatalog.Get(fishId)
	local model = Instance.new("Model")
	model.Name = "Fish_" .. fishId

	local color = def and def.color or Color3.fromRGB(120, 160, 200)
	local accent = def and def.accent or Color3.fromRGB(255, 255, 255)
	local scale = def and def.bodyScale or 1

	if shiny then
		color = Color3.fromRGB(
			math.min(255, color.R * 255 * 1.35 + 60),
			math.min(255, color.G * 255 * 1.35 + 60),
			math.min(255, color.B * 255 * 1.35 + 60)
		)
	end

	local length = 1.2 + scale * 0.8

	-- Body (slightly tapered via two wedges + core)
	local body = part("Part", "Body", model, color, Vector3.new(length, 0.5 + scale * 0.18, 0.35 + scale * 0.12))
	body.Shape = Enum.PartType.Block

	-- Belly (lighter)
	local belly = part("Part", "Belly", model, color:Lerp(Color3.new(1, 1, 1), 0.55), Vector3.new(length * 0.8, 0.18, 0.3 + scale * 0.1))

	-- Tail (accent wedge)
	local tail = part("WedgePart", "Tail", model, accent, Vector3.new(length * 0.32, 0.4 + scale * 0.14, 0.06))
	tail.Material = Enum.Material.SmoothPlastic

	-- Dorsal fin
	local fin = part("WedgePart", "DorsalFin", model, accent, Vector3.new(length * 0.25, 0.3, 0.05))

	-- Eyes
	local eyeL = part("Part", "EyeL", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeL.Shape = Enum.PartType.Ball
	local eyeR = part("Part", "EyeR", model, Color3.new(0.05, 0.05, 0.08), Vector3.new(0.09, 0.09, 0.09))
	eyeR.Shape = Enum.PartType.Ball

	-- Shiny sparkle trail
	if shiny then
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Name = "ShinySparkle"
		sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparkle.Rate = 24
		sparkle.Lifetime = NumberRange.new(0.6, 1.2)
		sparkle.Speed = NumberRange.new(0.5, 2)
		sparkle.Size = NumberRange.new(0.06, 0.18)
		sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 240, 160), Color3.fromRGB(255, 255, 255))
		sparkle.Transparency = NumberSequence.new(0.2, 1)
		sparkle.Parent = body
	end

	-- Layout: fish points +X (nose forward)
	body.CFrame = CFrame.new(0, 0, 0)
	belly.CFrame = CFrame.new(0, -0.28, 0)
	tail.CFrame = CFrame.new(-length * 0.62, 0.05, 0) * CFrame.Angles(0, math.pi / 2, 0)
	fin.CFrame = CFrame.new(0, 0.34, 0) * CFrame.Angles(-math.pi / 2.4, 0, 0)
	eyeL.CFrame = CFrame.new(length * 0.48, 0.08, 0.14)
	eyeR.CFrame = CFrame.new(length * 0.48, 0.08, -0.14)

	model.PrimaryPart = body
	return model
end

-- Center a model in a viewport: returns the camera CFrame to frame it.
function FishVisuals.FrameCamera(model: Model, distance: number): CFrame
	local pivot = model:GetPivot()
	local size = model:GetExtentsSize()
	local d = distance or (size.Magnitude + 2.5)
	return CFrame.new(pivot.Position + Vector3.new(0, 0.4, d), pivot.Position)
end

return FishVisuals
]===]

-- StarterPlayer/StarterPlayerScripts/Modules/Theme
local inst_StarterPlayer_StarterPlayerScripts_Modules_Theme = ensureChain([===[StarterPlayer/StarterPlayerScripts/Modules/Theme]===], 'ModuleScript')
inst_StarterPlayer_StarterPlayerScripts_Modules_Theme.Source = [===[--!strict
--[[
	Tidebound — Theme (client)
	Single source of UI colors/fonts so every panel looks consistent.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = {
	Bg = Color3.fromRGB(10, 22, 36),
	BgPanel = Color3.fromRGB(20, 38, 58),
	BgPanelLight = Color3.fromRGB(30, 52, 76),
	Accent = Color3.fromRGB(64, 210, 210),
	Accent2 = Color3.fromRGB(255, 190, 60),
	Text = Color3.fromRGB(235, 245, 255),
	TextDim = Color3.fromRGB(150, 170, 190),
	Danger = Color3.fromRGB(255, 96, 96),
	Success = Color3.fromRGB(96, 220, 130),
	Storm = Color3.fromRGB(150, 180, 255),
	Night = Color3.fromRGB(120, 100, 220),
	Gold = Color3.fromRGB(255, 210, 90),
	Rarity = {
		common = Color3.fromRGB(178, 188, 198),
		uncommon = Color3.fromRGB(110, 212, 122),
		rare = Color3.fromRGB(92, 162, 255),
		epic = Color3.fromRGB(192, 112, 255),
		legendary = Color3.fromRGB(255, 200, 64),
		mythic = Color3.fromRGB(255, 92, 130),
	},
	RarityName = {
		common = "Common",
		uncommon = "Uncommon",
		rare = "Rare",
		epic = "Epic",
		legendary = "Legendary",
		mythic = "Mythic",
	},
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
	FontTitle = Enum.Font.GothamBlack,
}

return Theme
]===]

-- StarterPlayer/StarterPlayerScripts/Modules/UiKit
local inst_StarterPlayer_StarterPlayerScripts_Modules_UiKit = ensureChain([===[StarterPlayer/StarterPlayerScripts/Modules/UiKit]===], 'ModuleScript')
inst_StarterPlayer_StarterPlayerScripts_Modules_UiKit.Source = [===[--!strict
--[[
	Tidebound — UiKit (client)
	One toolkit for building UI: frames, labels, buttons, scrolling lists.
	Every controller uses this — no duplicated UI code anywhere.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = require(script.Parent.Theme)

local UiKit = {}

-- Generic instance builder with property table
function UiKit.New(className: string, props: { [string]: any }?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

-- Frame with optional corner radius + automatic UIListLayout
function UiKit.Frame(parent: Instance, size: UDim2, pos: UDim2, color: Color3?, radius: number?): Frame
	local f = UiKit.New("Frame", {
		Name = "Frame",
		Size = size,
		Position = pos,
		BackgroundColor3 = color or Theme.BgPanel,
		BorderSizePixel = 0,
		Parent = parent,
	})
	if radius and radius > 0 then
		UiKit.New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = f })
	end
	return f
end

-- Label
function UiKit.Label(parent: Instance, text: string, size: UDim2, pos: UDim2, color: Color3?, font: Enum.Font?, textSize: number?): TextLabel
	return UiKit.New("TextLabel", {
		Name = "Label",
		Text = text,
		Size = size,
		Position = pos,
		BackgroundTransparency = 1,
		TextColor3 = color or Theme.Text,
		Font = font or Theme.Font,
		TextSize = textSize or 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	})
end

-- Button with hover feedback + click sound
function UiKit.Button(parent: Instance, text: string, onClick: () -> (), opts: { size: UDim2?, pos: UDim2?, color: Color3?, textSize: number? }?): TextButton
	local btn = UiKit.New("TextButton", {
		Name = "Button",
		Text = text,
		Size = opts and opts.size or UDim2.fromScale(0.5, 0.5),
		Position = opts and opts.pos or UDim2.fromScale(0, 0),
		BackgroundColor3 = opts and opts.color or Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = opts and opts.textSize or 16,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = parent,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	btn.MouseButton1Click:Connect(function()
		pcall(function()
			require(script.Parent.Parent.Controllers.AudioController):Play("ui_click")
		end)
		onClick()
	end)
	-- Hover feedback (guarded for stub environments)
	pcall(function()
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = (opts and opts.color or Theme.Accent):Lerp(Color3.new(1, 1, 1), 0.18)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = opts and opts.color or Theme.Accent
		end)
	end)
	return btn
end

-- Scrolling frame with list layout + padding
function UiKit.Scroll(parent: Instance, size: UDim2, pos: UDim2, padding: number?, bg: Color3?): ScrollingFrame
	local sf = UiKit.New("ScrollingFrame", {
		Name = "Scroll",
		Size = size,
		Position = pos,
		BackgroundColor3 = bg or Theme.BgPanelLight,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 6,
		Parent = parent,
	})
	UiKit.New("UIListLayout", {
		Padding = UDim.new(0, padding or 8),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sf,
	})
	UiKit.New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = sf })
	return sf
end

-- Row separator
function UiKit.Separator(parent: Instance, width: UDim2): Frame
	return UiKit.Frame(parent, width, UDim2.fromScale(0.5, 0), Theme.BgPanelLight, 0)
end

return UiKit
]===]


local bytes = rbxmk.encodeFormat('rbxl', dm)
fs.write([===[/home/user/tidebound/tools/tidebound_full.rbxl]===], bytes, 'bin')
print('WROTE ' .. [===[/home/user/tidebound/tools/tidebound_full.rbxl]===] .. ' (' .. #bytes .. ' bytes)')