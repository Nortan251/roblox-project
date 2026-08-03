--!strict
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
