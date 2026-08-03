--!strict
--[[
	Tidebound — GuideController (client, ModuleScript)
	The guided tutorial popup (bottom-center, above the XP bar).
	Server-driven: WorldInteractionsService sends GuideUpdate messages.
	Also opens panels when the server says so (OpenPanel).
	Phase 5 | AI-assisted | 2026-08-03
]]

local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent.Modules.Theme)
local UiKit = require(script.Parent.Parent.Modules.UiKit)
local ClientState = require(script.Parent.Parent.Modules.ClientState)

local GuideController = {}
GuideController.Name = "GuideController"

local player = Players.LocalPlayer
local gui: ScreenGui
local frame: Frame
local label: TextLabel
local dismissBtn: TextButton

function GuideController:BuildUI()
	gui = UiKit.New("ScreenGui", {
		Name = "GuideGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 4,
		Parent = player.PlayerGui,
	})
	frame = UiKit.Frame(gui, UDim2.fromScale(0.6, 0.1), UDim2.fromScale(0.5, 0.76), Theme.BgPanel, 12)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundTransparency = 0.15
	frame.Visible = false
	label = UiKit.Label(frame, "", UDim2.fromScale(0.9, 0.6), UDim2.fromScale(0.05, 0.1), Theme.Text, Theme.FontBold, 15)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextWrapped = true
	dismissBtn = UiKit.Button(frame, "Got it!", function()
		ClientState:Send("GuideDone")
		frame.Visible = false
	end, { size = UDim2.fromScale(0.22, 0.28), pos = UDim2.fromScale(0.39, 0.66), color = Theme.Accent, textSize = 13 })
end

function GuideController:HandleGuideUpdate(payload: any)
	if payload.active and typeof(payload.text) == "string" then
		label.Text = payload.text
		frame.Visible = true
	else
		frame.Visible = false
	end
end

function GuideController:HandleOpenPanel(payload: any)
	local menu = require(script.Parent.Parent.Controllers.MenuUIController)
	if payload and typeof(payload.panel) == "string" then
		menu:Open(payload.panel)
	end
end

function GuideController:Init(ctx)
	self.ctx = ctx
	ctx.RegisterHandler("GuideUpdate", function(payload)
		self:HandleGuideUpdate(payload)
	end)
	ctx.RegisterHandler("OpenPanel", function(payload)
		self:HandleOpenPanel(payload)
	end)
end

function GuideController:Start()
	self:BuildUI()
end

function GuideController:Stop()
	if gui then
		gui:Destroy()
	end
end

return GuideController
