--!strict
--[[
	Tidebound — WorldInteractionsService
	Makes the world ALIVE: proximity prompts + clickable interactables.
	- Old Salt (tutorial NPC): guided first-catch dialog → quest line
	- Market stall: opens the shop panel
	- Sign: opens the travel (map) panel
	- Crate: free daily pearl? no — free starter bait once
	- Old Salt dialog uses REAL guided steps (server-driven, no UI hacking)
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldInteractionsService = {}
WorldInteractionsService.Name = "WorldInteractionsService"

-- Old Salt guided tutorial steps (server-driven)
local GUIDE_STEPS = {
	{ prompt = "Grab the starter rod and cast it! Hold Q (or tap CAST) to charge, release to throw.", waitFor = "firstCast" },
	{ prompt = "When the bobber splashes — HOLD to reel it in! Release to rest the tension.", waitFor = "firstReel" },
	{ prompt = "Nice catch! Open your BAG (top-right) and Sell it, or keep it for the bestiary.", waitFor = "firstCatch" },
	{ prompt = "Open the SHOP (top-right) and grab the River Oak Rod — your first upgrade!", waitFor = "firstBuy" },
	{ prompt = "Check the QUESTS tab every day for rewards — and race the storms for rare fish!", waitFor = "done" },
}

function WorldInteractionsService:GetGuideStep(data: any): number
	local flags = data.flags
	if not flags.tutorialDone then
		if not flags.guideFirstCast then
			return 1
		elseif not flags.guideFirstReel then
			return 2
		elseif not flags.guideFirstCatch then
			return 3
		elseif not flags.guideFirstBuy then
			return 4
		else
			return 5
		end
	end
	return 0
end

function WorldInteractionsService:SendGuide(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if not data then
		return
	end
	local step = self:GetGuideStep(data)
	if step == 0 then
		Remotes:SendToClient(player, {
			type = "GuideUpdate",
			payload = { active = false, text = "" },
		})
		return
	end
	Remotes:SendToClient(player, {
		type = "GuideUpdate",
		payload = { active = true, text = GUIDE_STEPS[step].prompt, step = step },
	})
end

-- Called by other services when the player does the guided action
function WorldInteractionsService:OnCast(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCast then
		data.flags.guideFirstCast = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnReelStart(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstReel then
		data.flags.guideFirstReel = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstCatch(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstCatch then
		data.flags.guideFirstCatch = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnFirstBuy(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data and not data.flags.guideFirstBuy then
		data.flags.guideFirstBuy = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

function WorldInteractionsService:OnGuideDone(player: Player)
	local data = self.ctx.Services.DataService:GetData(player)
	if data then
		data.flags.tutorialDone = true
		self.ctx.Services.DataService:MarkDirty(player)
		self:SendGuide(player)
	end
end

-- World interactables (ProximityPrompts) — called by FishingService/Bootstrap after map build
local PROMPTS = {
	{
		partName = "OldSaltBody",
		promptName = "TalkToOldSalt",
		text = "Talk to Old Salt",
		action = "talk",
	},
	{
		partName = "StallTable",
		promptName = "OpenShop",
		text = "Open Shop",
		action = "shop",
	},
	{
		partName = "SignBoard",
		promptName = "OpenMap",
		text = "Open Map",
		action = "travel",
	},
}

function WorldInteractionsService:SetupPrompts()
	task.spawn(function()
		task.wait(2)
		for _, def in ipairs(PROMPTS) do
			local part = Workspace:FindFirstChild(def.partName) :: BasePart?
			if part then
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = def.promptName
				prompt.ActionText = def.text
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.ObjectText = def.partName
				prompt.Parent = part
				prompt.Triggered:Connect(function(player)
					self:OnPrompt(player, def.action)
				end)
			end
		end
	end)
end

function WorldInteractionsService:OnPrompt(player: Player, action: string)
	if action == "talk" then
		self:SendGuide(player)
	elseif action == "shop" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "shop" } })
	elseif action == "travel" then
		Remotes:SendToClient(player, { type = "OpenPanel", payload = { panel = "travel" } })
	end
end

function WorldInteractionsService:Init(ctx)
	self.ctx = ctx
end

function WorldInteractionsService:Start()
	self:SetupPrompts()
end

function WorldInteractionsService:Stop()
end

return WorldInteractionsService
