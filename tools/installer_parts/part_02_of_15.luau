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

-- ReplicatedStorage/Shared/Data/FishCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/FishCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/FishCatalog')
end

-- ReplicatedStorage/Shared/Data/RodCatalog
local inst = ensure('ReplicatedStorage/Shared/Data/RodCatalog', 'ModuleScript')
if inst and inst.Source ~= [==[--!strict
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
]==] then
	inst.Source = [==[--!strict
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
]==]
	print('[Installer] Wrote ReplicatedStorage/Shared/Data/RodCatalog')
end

print("[Installer] Part 2/15 complete - next: 3")
