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

-- ReplicatedStorage/Shared/Data/ZoneCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/ZoneCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/ZoneCatalog')
end

-- ReplicatedStorage/Shared/Data/QuestCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/QuestCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/QuestCatalog')
end

-- ReplicatedStorage/Shared/Data/CosmeticsCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/CosmeticsCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/CosmeticsCatalog')
end

-- ServerScriptService/Bootstrap
local inst = ensure('ServerScriptService/Bootstrap', 'Script')
if inst and inst.Source ~= [==[--!strict
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
	"WorldInteractionsService",
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
ctx.MessageHandlers.GuideDone = function(player: Player)
	local world = ctx.Services.WorldInteractionsService
	if world and world.OnGuideDone then
		world:OnGuideDone(player)
	end
end

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
	local world = ctx.Services.WorldInteractionsService
	if world and world.SendGuide then
		world:SendGuide(player)
	end
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
]==] then
	inst.Source = [==[--!strict
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
	"WorldInteractionsService",
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
ctx.MessageHandlers.GuideDone = function(player: Player)
	local world = ctx.Services.WorldInteractionsService
	if world and world.OnGuideDone then
		world:OnGuideDone(player)
	end
end

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
	local world = ctx.Services.WorldInteractionsService
	if world and world.SendGuide then
		world:SendGuide(player)
	end
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
]==]
	print('[Installer] Wrote ServerScriptService/Bootstrap')
end

print("[Installer] Part 3/15 complete - next: 4")
