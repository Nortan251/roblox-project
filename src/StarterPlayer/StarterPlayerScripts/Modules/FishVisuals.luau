--!strict
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
