--!strict
--[[
	Tidebound — Theme (client)
	Single source of UI colors/fonts so every panel looks consistent.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = {
	Bg = Color3.fromRGB(10, 22, 36),
	BgPanel = Color3.fromRGB(20, 38, 58),
	BgPanelLight = Color3.fromRGB(30, 52, 76),
	Accent = Color3.fromRGB(64, 210, 210),
	Accent2 = Color3.fromRGB(255, 190, 60),
	Text = Color3.fromRGB(235, 245, 255),
	TextDim = Color3.fromRGB(150, 170, 190),
	Danger = Color3.fromRGB(255, 96, 96),
	Success = Color3.fromRGB(96, 220, 130),
	Storm = Color3.fromRGB(150, 180, 255),
	Night = Color3.fromRGB(120, 100, 220),
	Gold = Color3.fromRGB(255, 210, 90),
	Rarity = {
		common = Color3.fromRGB(178, 188, 198),
		uncommon = Color3.fromRGB(110, 212, 122),
		rare = Color3.fromRGB(92, 162, 255),
		epic = Color3.fromRGB(192, 112, 255),
		legendary = Color3.fromRGB(255, 200, 64),
		mythic = Color3.fromRGB(255, 92, 130),
	},
	RarityName = {
		common = "Common",
		uncommon = "Uncommon",
		rare = "Rare",
		epic = "Epic",
		legendary = "Legendary",
		mythic = "Mythic",
	},
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
	FontTitle = Enum.Font.GothamBlack,
}

return Theme
