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

-- ServerScriptService/Services/EventService
local inst = ensure('ServerScriptService/Services/EventService', 'Script')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote ServerScriptService/Services/EventService')
end

-- ServerScriptService/Services/LeaderboardService
local inst = ensure('ServerScriptService/Services/LeaderboardService', 'Script')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote ServerScriptService/Services/LeaderboardService')
end

print("[Installer] Part 7/14 complete - next: 8")
