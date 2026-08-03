--!strict
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
