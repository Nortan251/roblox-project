--!strict
--[[
	Tidebound — UiKit (client)
	One toolkit for building UI: frames, labels, buttons, scrolling lists.
	Every controller uses this — no duplicated UI code anywhere.
	Phase 4 | AI-assisted | 2026-08-02
]]

local Theme = require(script.Parent.Theme)

local UiKit = {}

-- Generic instance builder with property table
function UiKit.New(className: string, props: { [string]: any }?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

-- Frame with optional corner radius + automatic UIListLayout
function UiKit.Frame(parent: Instance, size: UDim2, pos: UDim2, color: Color3?, radius: number?): Frame
	local f = UiKit.New("Frame", {
		Name = "Frame",
		Size = size,
		Position = pos,
		BackgroundColor3 = color or Theme.BgPanel,
		BorderSizePixel = 0,
		Parent = parent,
	})
	if radius and radius > 0 then
		UiKit.New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = f })
	end
	return f
end

-- Label
function UiKit.Label(parent: Instance, text: string, size: UDim2, pos: UDim2, color: Color3?, font: Enum.Font?, textSize: number?): TextLabel
	return UiKit.New("TextLabel", {
		Name = "Label",
		Text = text,
		Size = size,
		Position = pos,
		BackgroundTransparency = 1,
		TextColor3 = color or Theme.Text,
		Font = font or Theme.Font,
		TextSize = textSize or 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	})
end

-- Button with hover feedback + click sound
function UiKit.Button(parent: Instance, text: string, onClick: () -> (), opts: { size: UDim2?, pos: UDim2?, color: Color3?, textSize: number? }?): TextButton
	local btn = UiKit.New("TextButton", {
		Name = "Button",
		Text = text,
		Size = opts and opts.size or UDim2.fromScale(0.5, 0.5),
		Position = opts and opts.pos or UDim2.fromScale(0, 0),
		BackgroundColor3 = opts and opts.color or Theme.Accent,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Theme.FontBold,
		TextSize = opts and opts.textSize or 16,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Parent = parent,
	})
	UiKit.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	btn.MouseButton1Click:Connect(function()
		pcall(function()
			require(script.Parent.Parent.Controllers.AudioController):Play("ui_click")
		end)
		onClick()
	end)
	-- Hover feedback (guarded for stub environments)
	pcall(function()
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = (opts and opts.color or Theme.Accent):Lerp(Color3.new(1, 1, 1), 0.18)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = opts and opts.color or Theme.Accent
		end)
	end)
	return btn
end

-- Scrolling frame with list layout + padding
function UiKit.Scroll(parent: Instance, size: UDim2, pos: UDim2, padding: number?, bg: Color3?): ScrollingFrame
	local sf = UiKit.New("ScrollingFrame", {
		Name = "Scroll",
		Size = size,
		Position = pos,
		BackgroundColor3 = bg or Theme.BgPanelLight,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 6,
		Parent = parent,
	})
	UiKit.New("UIListLayout", {
		Padding = UDim.new(0, padding or 8),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sf,
	})
	UiKit.New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = sf })
	return sf
end

-- Row separator
function UiKit.Separator(parent: Instance, width: UDim2): Frame
	return UiKit.Frame(parent, width, UDim2.fromScale(0.5, 0), Theme.BgPanelLight, 0)
end

return UiKit
