-- Tidebound deep simulation tests (appended to harness by build_smoke_harness.py)
-- Simulates quests/streaks/achievements and 90k+ RNG picks against real services.

local DataService = envBase.__tdRequire("Services.DataService")
local QuestService = envBase.__tdRequire("Services.QuestService")
local FishingService = envBase.__tdRequire("Services.FishingService")
local Fish = envBase.__tdRequire("Shared.Data.FishCatalog")
local Config = envBase.__tdRequire("Shared.Config")

local simFails = 0
local function simCheck(cond, label)
	if cond then
		print("[PASS] " .. label)
	else
		simFails += 1
		print("[FAIL] " .. label)
	end
end

-- ── Quests / streaks / achievements ──────────────────────────────────────

local fakePlayer = { UserId = 424242, Name = "SimTester" }
local profile = DataService:NewData()

local simCtx = {
	Services = {
		DataService = { GetData = function() return profile end, MarkDirty = function() end },
		EconomyService = {
			AddCoins = function(_, _p, amt) profile.coins += amt return profile.coins end,
			AddPearls = function(_, _p, amt) profile.pearls += amt return profile.pearls end,
			SpendCoins = function(_, _p, amt) if profile.coins >= amt then profile.coins -= amt return true end return false end,
			AddXP = function(_, _p, amt) profile.xp += amt return { newLevel = profile.level, leveledUp = false, coinsGranted = 0 } end,
			Sync = function() end,
		},
		SecurityService = { Flag = function() end },
		InventoryService = { GetGlobalCompletion = function() return 0 end },
		LeaderboardService = { SubmitCatch = function() end },
		EventService = { GetTimeOfDay = function() return "day" end, IsStorm = function() return false end },
	},
	MessageHandlers = {},
}
QuestService:Init(simCtx)
QuestService:EnsureRollovers(fakePlayer)
simCheck(#profile.dailyQuests == 3, "3 daily quests rolled")
simCheck(#profile.weeklyQuests == 3, "3 weekly quests rolled")
simCheck(profile.streak == 1, "streak started at 1")
simCheck(profile.coins >= 50, "day-1 streak reward granted (coins=" .. profile.coins .. ")")

profile.dailyQuests[1] = { templateId = "d_catch_total", params = {}, progress = 0, done = false, claimed = false }
for _ = 1, 12 do
	profile.stats.totalCatch += 1
	QuestService:OnFishCaught(fakePlayer, Fish.Get("sunsail_minnow"), false, false, false)
end
simCheck(profile.dailyQuests[1].done == true, "catch-total daily completed after 12 fish")
simCheck(profile.achievements.first_catch == true, "first_catch achievement granted")
simCheck(profile.titles["Shiny Hunter"] == nil, "no shiny title before shiny catch")

profile.stats.totalCatch += 1
profile.stats.shinyFish += 1
QuestService:OnFishCaught(fakePlayer, Fish.Get("gilded_bass"), false, false, true)
simCheck(profile.achievements.first_shiny == true, "first_shiny achievement granted")

QuestService:ClaimDaily(fakePlayer, 1)
simCheck(profile.coins >= 50 + 150, "daily quest reward claimed (coins=" .. profile.coins .. ")")

profile.streakLastDay = os.date("!%Y-%m-%d", os.time() - 86400)
QuestService:EnsureRollovers(fakePlayer)
simCheck(profile.streak == 2, "streak advanced to 2")

-- ── Fishing RNG distribution ─────────────────────────────────────────────

local function newSimCtx(isStorm)
	local d = DataService:NewData()
	d.equippedRod = "leviathan"
	d.rods.leviathan = true
	return {
		data = d,
		ctx = {
			Services = {
				DataService = { GetData = function() return d end, MarkDirty = function() end },
				EventService = { GetTimeOfDay = function() return "day" end, IsStorm = function() return isStorm end },
				SecurityService = { Flag = function() end },
			},
			MessageHandlers = {},
		},
	}
end

local function runPicks(zoneId, count, deepFish, storm)
	local sim = newSimCtx(storm)
	FishingService:Init(sim.ctx)
	sim.data.stats.deepFish = deepFish
	local counts = {}
	local oldOne = 0
	for _ = 1, count do
		local roll = FishingService:PickFish(zoneId, sim.data)
		counts[roll.fishId] = (counts[roll.fishId] or 0) + 1
		if roll.fishId == "old_one" then oldOne += 1 end
	end
	return counts, oldOne
end

local abyssCounts, abyssOld = runPicks("abyss", 20000, 0, false)
local mythic = (abyssCounts["leviathan_abyss"] or 0) / 20000
simCheck(mythic > 0.001 and mythic < 0.01, "abyss mythic rate sane (" .. string.format("%.4f", mythic) .. ")")
simCheck(abyssOld == 0, "Old One locked before 50 deep fish")

local _, oldOneAfter = runPicks("abyss", 10000, 50, false)
local oldRate = oldOneAfter / 10000
simCheck(oldRate > 0.005 and oldRate < 0.05, "Old One trigger rate ~2% (" .. string.format("%.4f", oldRate) .. ")")

local stormCounts, _ = runPicks("abyss", 5000, 50, true)
simCheck((stormCounts["stormcaller_eel"] or 0) > 0, "storm fish appear during storm")
simCheck((stormCounts["storm_sprat"] or 0) > 0, "universal storm fish appear")

local simB = newSimCtx(false)
FishingService:Init(simB.ctx)
simB.data.flags.equippedBait = "squid"
local eelCount = 0
for _ = 1, 10000 do
	local roll = FishingService:PickFish("drop", simB.data)
	if roll.fishId == "trench_eel" or roll.fishId == "abyssal_squid" then eelCount += 1 end
end
local baseSim = newSimCtx(false)
FishingService:Init(baseSim.ctx)
local eelCountBase = 0
for _ = 1, 10000 do
	local roll = FishingService:PickFish("drop", baseSim.data)
	if roll.fishId == "trench_eel" or roll.fishId == "abyssal_squid" then eelCountBase += 1 end
end
simCheck(eelCount > eelCountBase * 1.3, "squid bait boosts squid-family odds (" .. eelCount .. " vs " .. eelCountBase .. ")")

local baseSim2 = newSimCtx(false)
FishingService:Init(baseSim2.ctx)
baseSim2.data.equippedRod = "bamboo"
local simLuck = newSimCtx(false)
FishingService:Init(simLuck.ctx)
simLuck.data.equippedRod = "leviathan"
simLuck.data.flags.ownedPasses.lucky_charm = true
simLuck.data.flags.equippedBait = "golden"
simLuck.data.baits.golden = 100
simLuck.ctx.Services.EventService.GetTimeOfDay = function() return "night" end
local luckEpic = 0
for _ = 1, 10000 do
	local roll = FishingService:PickFish("abyss", simLuck.data)
	local def = Fish.Get(roll.fishId)
	if def and (Config.RARITY_INDEX[def.rarity] or 1) >= 4 then luckEpic += 1 end
end
local baseEpic = 0
for _ = 1, 10000 do
	local roll = FishingService:PickFish("abyss", baseSim2.data)
	local def = Fish.Get(roll.fishId)
	if def and (Config.RARITY_INDEX[def.rarity] or 1) >= 4 then baseEpic += 1 end
end
simCheck(luckEpic > baseEpic * 1.3, "luck visibly boosts epic+ (" .. luckEpic .. " vs " .. baseEpic .. ")")
simCheck(luckEpic < baseEpic * 2.5, "luck boost bounded under 2.5x (" .. luckEpic .. " vs " .. baseEpic .. ")")

-- ═══════════ DEEP SIMULATION: cosmetics, titles, contest ═══════════
local ShopService = envBase.__tdRequire("Services.ShopService")
local LeaderboardService = envBase.__tdRequire("Services.LeaderboardService")
local CosmeticsCat = envBase.__tdRequire("Shared.Data.CosmeticsCatalog")

local cProfile = DataService:NewData()
cProfile.pearls = 500

local cCtx = {
    Services = {
        DataService = { GetData = function() return cProfile end, MarkDirty = function() end },
        EconomyService = {
            SpendPearls = function(_, _p, amt)
                if cProfile.pearls >= amt then
                    cProfile.pearls -= amt
                    return true
                end
                return false
            end,
            SpendCoins = function(_, _p, amt)
                if cProfile.coins >= amt then cProfile.coins -= amt return true end
                return false
            end,
        },
        InventoryService = { SendInventory = function() end },
        FishingService = { UpdateRodColor = function() end },
        SecurityService = { Flag = function() end },
    },
    MessageHandlers = {},
}
ShopService:Init(cCtx)

local before = cProfile.pearls
ShopService:BuyCosmetic(fakePlayer, "bobber_coral")
simCheck(cProfile.pearls == before - 40, "cosmetic purchase deducts pearls (" .. cProfile.pearls .. ")")
simCheck(cProfile.flags.cosmeticsOwned["bobber_coral"] == true, "cosmetic marked owned")
simCheck(cProfile.cosmetics.bobber == "bobber_coral", "purchased cosmetic equipped immediately")

ShopService:BuyCosmetic(fakePlayer, "rodskin_royal")
simCheck(cProfile.cosmetics.rodSkin == "rodskin_royal", "rod skin equipped on purchase")
ShopService:EquipCosmetic(fakePlayer, "aura_ember")
simCheck(cProfile.cosmetics.aura == nil, "cannot equip unowned (guard)")

-- buying again does not double-charge
local before2 = cProfile.pearls
ShopService:BuyCosmetic(fakePlayer, "bobber_coral")
simCheck(cProfile.pearls == before2, "duplicate cosmetic buy is free (already owned)")

-- title equip
cProfile.titles["Night Owl"] = true
ShopService:EquipTitle(fakePlayer, "Night Owl")
simCheck(cProfile.equippedTitle == "Night Owl", "title equipped")
ShopService:EquipTitle(fakePlayer, "Fake Title")
simCheck(cProfile.equippedTitle == "Night Owl", "cannot equip unowned title")

-- contest top does not crash with empty store
local lbCtx = {
    Services = {
        DataService = { GetData = function() return cProfile end },
        EconomyService = { AddPearls = function() end },
        QuestService = { CheckAchievements = function() end },
        InventoryService = { GetGlobalCompletion = function() return 0 end },
    },
    MessageHandlers = {},
}
LeaderboardService:Init(lbCtx)
local lbErr = nil
local okLb = xpcall(function()
    LeaderboardService:SendContestTop(fakePlayer)
end, function(e) lbErr = tostring(e) end)
simCheck(okLb, "contest top send (empty store) does not crash" .. (lbErr and (" -- err: " .. lbErr) or ""))

print("")
if simFails == 0 then
	print("ALL SIMULATION TESTS PASSED")
else
	print(simFails .. " SIMULATION FAILURES")
	error(simFails .. " simulation failures")
end
