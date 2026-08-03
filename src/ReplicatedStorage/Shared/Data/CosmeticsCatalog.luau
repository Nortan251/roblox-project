--!strict
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
