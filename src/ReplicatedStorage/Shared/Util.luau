--!strict
--[[
	Tidebound — Util
	Pure, dependency-free helpers shared by server and client.
	Phase 2 | AI-assisted | 2026-08-02
]]

local Util = {}

-- Clamp a number to [min, max]
function Util.clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

-- Round to N decimals
function Util.round(value: number, decimals: number): number
	local mult = 10 ^ decimals
	return math.floor(value * mult + 0.5) / mult
end

-- Format big numbers: 1234 -> "1.2K", 2500000 -> "2.5M"
function Util.formatNumber(value: number): string
	if value >= 1000000 then
		return string.format("%.1fM", value / 1000000)
	elseif value >= 1000 then
		return string.format("%.1fK", value / 1000)
	end
	return tostring(math.floor(value))
end

-- Weighted random pick from { key = weight }. Returns key or nil if empty.
function Util.weightedPick(weights: { [string]: number }): string?
	local total = 0
	for _, w  in pairs(weights) do
		total += w
	end
	if total <= 0 then
		return nil
	end
	local roll = math.random() * total
	for key, w  in pairs(weights) do
		roll -= w
		if roll <= 0 then
			return key
		end
	end
	-- Fallback: last key (floating point safety)
	local last: string? = nil
	for key, _  in pairs(weights) do
		last = key
	end
	return last
end

-- True with probability p (0..1)
function Util.rollChance(p: number): boolean
	return math.random() < p
end

-- UTC date key "YYYY-MM-DD"
function Util.todayKey(): string
	return os.date("!%Y-%m-%d", os.time())
end

-- UTC week key "YYYY-Www" (matches the same week everywhere on the server)
function Util.weekKey(): string
	return os.date("!%Y-W%W", os.time())
end

-- Yesterday's UTC date key (for streak logic)
function Util.yesterdayKey(): string
	return os.date("!%Y-%m-%d", os.time() - 86400)
end

-- Safe number guard: nil/NaN/Infinity -> fallback
function Util.safeNumber(value: any, fallback: number): number
	if typeof(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge then
		return value
	end
	return fallback
end

-- Shallow copy of a table (catalogs are immutable; copies are for display)
function Util.shallowCopy<T>(t: { [string]: T }): { [string]: T }
	local out: { [string]: T } = {}
	for k, v  in pairs(t) do
		out[k] = v
	end
	return out
end

-- List of keys in a table
function Util.keys(t: { [any]: any }): { any }
	local out = {}
	for k, _  in pairs(t) do
		table.insert(out, k)
	end
	return out
end

-- Weight roll for a fish: skewed toward the low end (min + rand^1.7 * range)
function Util.rollWeight(min: number, max: number): number
	local t = math.random() ^ 1.7
	return Util.round(min + t * (max - min), 1)
end

-- XP needed to advance FROM `level` TO `level + 1`
function Util.xpForLevel(level: number, xpBase: number, exponent: number): number
	return math.floor(xpBase * (level ^ exponent))
end

return Util
