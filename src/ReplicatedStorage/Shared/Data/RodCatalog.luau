--!strict
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
