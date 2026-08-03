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

-- ServerScriptService/Services/WorldInteractionsService
local inst = ensure('ServerScriptService/Services/WorldInteractionsService', 'Script')
if inst and inst.Source ~= [==[--!strict
--[[
	Tidebound — WorldInteractionsService
	Makes the world ALIVE: proximity prompts + clickable interactables.
	- Old Salt (tutorial NPC): guided first-catch dialog → quest line
	- Market stall: opens the shop panel
	- Sign: opens the travel (map) panel
	- Crate: free daily pearl? no — free starter bait once
	- Old Salt dialog uses REAL guided steps (server-driven, no UI hacking)
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldInteractionsService = {}
WorldInteractionsService.Name = "WorldInteractionsService"

-- Old Salt guided tutorial steps (server-driven)
local GUIDE_STEPS = {
	{ prompt = "Grab the starter rod and cast it! Hold Q (or tap CAST) to charge, release to throw.", waitFor = "firstCast" },
	{ prompt = "When the bobber splashes — HOLD to reel it in! Release to rest the tension.", waitFor = "firstReel" },
	{ prompt = "Nice catch! Open your BAG (top-right) and Sell it, or keep it for the bestiary.", waitFor = "firstCatch" },
	{ prompt = "Open the SHOP (top-right) and grab the River Oak Rod — your first upgrade!", waitFor = "firstBuy" },
	{ prompt = "Check the QUESTS tab every day for rewards — and race the storms for rare fish!", waitFor = "done" },
}

function WorldInteractionsService:GetGuideStep(data: any): number
	local flags = data.flags
	if not flags.tutorialDone then
		if not flags.guideFirstCast then
			return 1
		elseif not flags.guideFirstReel then
			return 2
		elseif not flags.guideFirstCatch then
			return 3
		elseif not flags.guideFirstBuy then
			return 4
		else
			return 5
		end
	end
	return 0
end

function WorldInteractionsService:SendGuide(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local step = self:GetGuideStep(data)
	if step == 0 then
		Remotes:SendToClient(player, {
			type = "GuideUpdate",
			payload = { active = false, text = "" },
		})
		return
	end
	Remotes:SendToClient(player, {
		type = "GuideUpdate",
		payload = { active = true, text = GUIDE_STEPS[step].prompt, step = step },
	})
end

-- Called by other services when the player does the guided action
function WorldInteractionsService:OnCast(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCast then
		data.flags.guideFirstCast = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnReelStart(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstReel then
		data.flags.guideFirstReel = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstCatch(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCatch then
		data.flags.guideFirstCatch = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstBuy(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstBuy then
		data.flags.guideFirstBuy = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnGuideDone(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data then
		data.flags.tutorialDone = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

-- World interactables (ProximityPrompts) — called by FishingService/Bootstrap after map build
local PROMPTS = {
	{
		partName = "OldSaltBody",
		promptName = "TalkToOldSalt",
		text = "Talk to Old Salt",
		action = "talk",
	},
	{
		partName = "StallTable",
		promptName = "OpenShop",
		text = "Open Shop",
		action = "shop",
	},
	{
		partName = "SignBoard",
		promptName = "OpenMap",
		text = "Open Map",
		action = "travel",
	},
	{
		partName = "ChestBase",
		promptName = "OpenChest",
		text = "Open the Sunken Chest",
		action = "chest",
		chestKey = "abyss",
	},
	{
		partName = "IsleChest",
		promptName = "OpenIsleChest",
		text = "Open the Isle Chest",
		action = "chest",
		chestKey = "isle",
	},
	{
		partName = "GrottoChest",
		promptName = "OpenGrottoChest",
		text = "Open the Grotto Chest",
		action = "chest",
		chestKey = "grotto",
	},
}

function WorldInteractionsService:SetupPrompts()
	task.spawn(function()
		task.wait(2)
		for _, def in ipairs(PROMPTS) do
			local part = Workspace:FindFirstChild(def.partName) :: BasePart?
			if part then
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = def.promptName
				prompt.ActionText = def.text
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.ObjectText = def.partName
				prompt.Parent = part
				prompt.Triggered:Connect(function(player)
					self:OnPrompt(player, def.action, def.chestKey)
				end)
			end
		end
	end)
end

function WorldInteractionsService:OnPrompt(player: Player, action: string, chestKey: string?)
	if action == "talk" then
		self:SendGuide(player)
	elseif action == "shop" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "shop" } })
	elseif action == "travel" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "travel" } })
	elseif action == "chest" and chestKey then
		self:OpenChest(player, chestKey)
	end
end

-- Secret chests: one-time pearl reward per account (world collectibles)
function WorldInteractionsService:OpenChest(player: Player, chestKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if data.flags.chestsClaimed[chestKey] then
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "chestEmpty", text = "This chest is empty — you already claimed it!" },
		})
		return
	end
	data.flags.chestsClaimed[chestKey] = true
	local pearls = chestKey == "abyss" and 15 or 10
	self.ctx.Services.EconomyService:AddPearls(player, pearls, "chest:" .. chestKey)
	Remotes:SendToClient(player, {
		type = "EventBanner",
		payload = { kind = "chest", text = "💎 You found " .. pearls .. " pearls in the chest!" },
	})
end

function WorldInteractionsService:Init(ctx)
	self.ctx = ctx
end

function WorldInteractionsService:Start()
	self:SetupPrompts()
end

function WorldInteractionsService:Stop()
end

return WorldInteractionsService
]==] then
	inst.Source = [==[--!strict
--[[
	Tidebound — WorldInteractionsService
	Makes the world ALIVE: proximity prompts + clickable interactables.
	- Old Salt (tutorial NPC): guided first-catch dialog → quest line
	- Market stall: opens the shop panel
	- Sign: opens the travel (map) panel
	- Crate: free daily pearl? no — free starter bait once
	- Old Salt dialog uses REAL guided steps (server-driven, no UI hacking)
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldInteractionsService = {}
WorldInteractionsService.Name = "WorldInteractionsService"

-- Old Salt guided tutorial steps (server-driven)
local GUIDE_STEPS = {
	{ prompt = "Grab the starter rod and cast it! Hold Q (or tap CAST) to charge, release to throw.", waitFor = "firstCast" },
	{ prompt = "When the bobber splashes — HOLD to reel it in! Release to rest the tension.", waitFor = "firstReel" },
	{ prompt = "Nice catch! Open your BAG (top-right) and Sell it, or keep it for the bestiary.", waitFor = "firstCatch" },
	{ prompt = "Open the SHOP (top-right) and grab the River Oak Rod — your first upgrade!", waitFor = "firstBuy" },
	{ prompt = "Check the QUESTS tab every day for rewards — and race the storms for rare fish!", waitFor = "done" },
}

function WorldInteractionsService:GetGuideStep(data: any): number
	local flags = data.flags
	if not flags.tutorialDone then
		if not flags.guideFirstCast then
			return 1
		elseif not flags.guideFirstReel then
			return 2
		elseif not flags.guideFirstCatch then
			return 3
		elseif not flags.guideFirstBuy then
			return 4
		else
			return 5
		end
	end
	return 0
end

function WorldInteractionsService:SendGuide(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local step = self:GetGuideStep(data)
	if step == 0 then
		Remotes:SendToClient(player, {
			type = "GuideUpdate",
			payload = { active = false, text = "" },
		})
		return
	end
	Remotes:SendToClient(player, {
		type = "GuideUpdate",
		payload = { active = true, text = GUIDE_STEPS[step].prompt, step = step },
	})
end

-- Called by other services when the player does the guided action
function WorldInteractionsService:OnCast(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCast then
		data.flags.guideFirstCast = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnReelStart(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstReel then
		data.flags.guideFirstReel = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstCatch(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCatch then
		data.flags.guideFirstCatch = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstBuy(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstBuy then
		data.flags.guideFirstBuy = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnGuideDone(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data then
		data.flags.tutorialDone = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

-- World interactables (ProximityPrompts) — called by FishingService/Bootstrap after map build
local PROMPTS = {
	{
		partName = "OldSaltBody",
		promptName = "TalkToOldSalt",
		text = "Talk to Old Salt",
		action = "talk",
	},
	{
		partName = "StallTable",
		promptName = "OpenShop",
		text = "Open Shop",
		action = "shop",
	},
	{
		partName = "SignBoard",
		promptName = "OpenMap",
		text = "Open Map",
		action = "travel",
	},
	{
		partName = "ChestBase",
		promptName = "OpenChest",
		text = "Open the Sunken Chest",
		action = "chest",
		chestKey = "abyss",
	},
	{
		partName = "IsleChest",
		promptName = "OpenIsleChest",
		text = "Open the Isle Chest",
		action = "chest",
		chestKey = "isle",
	},
	{
		partName = "GrottoChest",
		promptName = "OpenGrottoChest",
		text = "Open the Grotto Chest",
		action = "chest",
		chestKey = "grotto",
	},
}

function WorldInteractionsService:SetupPrompts()
	task.spawn(function()
		task.wait(2)
		for _, def in ipairs(PROMPTS) do
			local part = Workspace:FindFirstChild(def.partName) :: BasePart?
			if part then
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = def.promptName
				prompt.ActionText = def.text
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.ObjectText = def.partName
				prompt.Parent = part
				prompt.Triggered:Connect(function(player)
					self:OnPrompt(player, def.action, def.chestKey)
				end)
			end
		end
	end)
end

function WorldInteractionsService:OnPrompt(player: Player, action: string, chestKey: string?)
	if action == "talk" then
		self:SendGuide(player)
	elseif action == "shop" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "shop" } })
	elseif action == "travel" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "travel" } })
	elseif action == "chest" and chestKey then
		self:OpenChest(player, chestKey)
	end
end

-- Secret chests: one-time pearl reward per account (world collectibles)
function WorldInteractionsService:OpenChest(player: Player, chestKey: string)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	if data.flags.chestsClaimed[chestKey] then
		Remotes:SendToClient(player, {
			type = "EventBanner",
			payload = { kind = "chestEmpty", text = "This chest is empty — you already claimed it!" },
		})
		return
	end
	data.flags.chestsClaimed[chestKey] = true
	local pearls = chestKey == "abyss" and 15 or 10
	self.ctx.Services.EconomyService:AddPearls(player, pearls, "chest:" .. chestKey)
	Remotes:SendToClient(player, {
		type = "EventBanner",
		payload = { kind = "chest", text = "💎 You found " .. pearls .. " pearls in the chest!" },
	})
end

function WorldInteractionsService:Init(ctx)
	self.ctx = ctx
end

function WorldInteractionsService:Start()
	self:SetupPrompts()
end

function WorldInteractionsService:Stop()
end

return WorldInteractionsService
]==]
	print('[Installer] Wrote ServerScriptService/Services/WorldInteractionsService')
end

-- ServerScriptService/Services/AutoTerrainService
local inst = ensure('ServerScriptService/Services/AutoTerrainService', 'Script')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote ServerScriptService/Services/AutoTerrainService')
end

-- StarterPlayer/StarterPlayerScripts/Bootstrap
local inst = ensure('StarterPlayer/StarterPlayerScripts/Bootstrap', 'LocalScript')
if inst and inst.Source ~= [==[--!strict
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
local CONTROLLERS = { "AudioController", "GuideController", "CastController", "UIController", "MenuUIController" }

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
]==] then
	inst.Source = [==[--!strict
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
local CONTROLLERS = { "AudioController", "GuideController", "CastController", "UIController", "MenuUIController" }

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
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Bootstrap')
end

-- StarterPlayer/StarterPlayerScripts/Controllers/AudioController
local inst = ensure('StarterPlayer/StarterPlayerScripts/Controllers/AudioController', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote StarterPlayer/StarterPlayerScripts/Controllers/AudioController')
end

print("[Installer] Part 12/16 complete - next: 13")
