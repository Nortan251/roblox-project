--!strict
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

	-- Guide: first cast
	local world = self.ctx.Services.WorldInteractionsService
	if world and world.OnCast then
		world:OnCast(player)
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
	local world = self.ctx.Services.WorldInteractionsService
	if world and world.OnReelStart then
		world:OnReelStart(state.player)
	end
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
	for _, player in ipairs(Players:GetPlayers()) do
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
