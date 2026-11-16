--// BilliardAim v2 (guide lines + GUI) - LocalScript -> StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local P = require(ReplicatedStorage:WaitForChild("BilliardPhysics"))
local shotRemote = ReplicatedStorage:WaitForChild("BilliardShot")
local doneRemote = ReplicatedStorage:WaitForChild("BilliardDone")

local tableModel = workspace:WaitForChild("Table")
local playArea = tableModel:WaitForChild("PlayArea")
local pocketsFolder = tableModel:FindFirstChild("Pockets")
local ballsFolder = workspace:WaitForChild("Balls")
local tbl = P.readTable(playArea, pocketsFolder)

----------------------------------------------------------------
-- CONFIG + SETTINGS
----------------------------------------------------------------
local CFG = {
	CueName = "CueBall",
	MinPower = 0.03,
	GuideHeight = 0.05, -- lines float this high above the cloth
	MaxSegments = 140,
	UpdateRate = 20,    -- prediction updates per second
}

local S = {
	-- guide
	GuideOn = true,
	ShowOthers = true,    -- paths of the balls that get hit
	ShowGhost = true,     -- ghost ball at the first contact
	UseBallColor = true,  -- line color = ball color
	PreviewTime = 5,      -- seconds of movement shown
	Thick = 1,            -- line thickness multiplier
	-- shot
	PowerMode = "Hold",   -- Hold (charge) / Fixed (tap = fixed power)
	ChargeTime = 1.6,     -- seconds to reach 100%
	IdlePower = 0.45,     -- preview power (Hold) / shot power (Fixed)
	ShootBtn = true,
	-- menu
	Locked = false,
	UiScale = 1,
}

local WHITE = Color3.new(1, 1, 1)
local C = {
	bg = Color3.fromRGB(20, 20, 26),
	card = Color3.fromRGB(34, 34, 44),
	stroke = Color3.fromRGB(60, 60, 80),
	off = Color3.fromRGB(70, 70, 84),
	on = Color3.fromRGB(60, 190, 100),
	accent = Color3.fromRGB(0, 140, 255),
	danger = Color3.fromRGB(200, 50, 50),
	text = Color3.fromRGB(235, 235, 245),
	sub = Color3.fromRGB(150, 150, 170),
}

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o) end
local function tween(o, props, t)
	TweenService:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), props):Play()
end

local lastSig = nil
local function changed() lastSig = nil end -- force the guide to redraw

----------------------------------------------------------------
-- GUIDE DRAWING (client only: only you see it)
----------------------------------------------------------------
local guideFolder = new("Folder", { Name = "BilliardGuides" }, workspace)
local pool, used = {}, 0

local function newSeg()
	used += 1
	local s = pool[used]
	if not s then
		s = new("Part", {
			Name = "GuideSeg", Anchored = true, CanCollide = false, CanQuery = false,
			CanTouch = false, CastShadow = false, Material = Enum.Material.Neon,
		}, guideFolder)
		pool[used] = s
	end
	return s
end

local ghost = new("Part", {
	Name = "GuideGhost", Shape = Enum.PartType.Ball, Anchored = true, CanCollide = false,
	CanQuery = false, CanTouch = false, CastShadow = false,
	Material = Enum.Material.Neon, Transparency = 1,
}, guideFolder)

local function hideFrom(i)
	for k = i, #pool do
		if pool[k].Transparency ~= 1 then pool[k].Transparency = 1 end
	end
end

local function clearGuide()
	used = 0
	hideFrom(1)
	ghost.Transparency = 1
end

local function lineColor(c)
	if not S.UseBallColor then return WHITE end
	local _, _, v = c:ToHSV()
	if v < 0.25 then return c:Lerp(WHITE, 0.55) end -- dark balls would be invisible
	return c
end

local function toWorld(x, z, lift)
	return tbl.cf * Vector3.new(x, tbl.topY + lift, z)
end

local function drawPath(path, color, th, baseT)
	if #path < 2 then return end
	local total = 0
	for i = 2, #path do
		total += math.sqrt((path[i][1] - path[i - 1][1]) ^ 2 + (path[i][2] - path[i - 1][2]) ^ 2)
	end
	if total < 0.05 then return end

	local acc = 0
	for i = 2, #path do
		local a, b = path[i - 1], path[i]
		local len = math.sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
		if len > 0.01 and used < CFG.MaxSegments then
			local A = toWorld(a[1], a[2], CFG.GuideHeight)
			local B = toWorld(b[1], b[2], CFG.GuideHeight)
			local s = newSeg()
			s.Color = color
			s.Size = Vector3.new(th, th, len)
			s.CFrame = CFrame.lookAt((A + B) / 2, B)
			s.Transparency = math.clamp(baseT + 0.55 * ((acc + len / 2) / total), 0, 0.95)
		end
		acc += len
	end
end

local function recompute(dx, dz, pw)
	if not S.GuideOn then
		clearGuide()
		return
	end

	local state = P.readBalls(ballsFolder, tbl)
	local cue = state.byId[CFG.CueName]
	if not cue or not cue.active then
		clearGuide()
		return
	end

	local vx, vz = P.shotVelocity(dx, dz, pw)
	local res = P.simulate(state, tbl, CFG.CueName, vx, vz, S.PreviewTime)
	if not res then
		clearGuide()
		return
	end

	used = 0
	-- the stronger the shot, the thicker and more solid the lines
	local th = (0.04 + 0.08 * pw) * S.Thick
	local baseT = 0.1 + (1 - pw) * 0.4

	drawPath(res.paths[cue.id], lineColor(cue.color), th, baseT)
	if S.ShowOthers then
		for _, b in ipairs(state.balls) do
			if b.id ~= cue.id then
				drawPath(res.paths[b.id], lineColor(b.color), th * 0.8, baseT)
			end
		end
	end
	hideFrom(used + 1)

	local e = res.firstHit
	if S.ShowGhost and e then
		local x, z
		if e.a == cue.id then x, z = e.ax, e.az else x, z = e.cx, e.cz end
		ghost.Size = Vector3.new(cue.r * 2, cue.r * 2, cue.r * 2)
		ghost.Color = lineColor(cue.color)
		ghost.Transparency = 0.6
		ghost.CFrame = CFrame.new(toWorld(x, z, cue.r))
	else
		ghost.Transparency = 1
	end
end

----------------------------------------------------------------
-- AIM + SHOT STATE
----------------------------------------------------------------
local power, charging, localBusy = 0, false, false

local function canAim()
	if localBusy or workspace:GetAttribute("BilliardBusy") then return false end
	local turn = workspace:GetAttribute("BilliardTurn")
	if turn ~= nil and turn ~= player.UserId then return false end
	local cue = ballsFolder:FindFirstChild(CFG.CueName)
	return cue ~= nil and cue:GetAttribute("Pocketed") ~= true
end

-- first-person look direction projected onto the table plane
local function aimDir()
	local look = workspace.CurrentCamera.CFrame.LookVector
	local l = tbl.cf:VectorToObjectSpace(look)
	local m = math.sqrt(l.X * l.X + l.Z * l.Z)
	if m < 0.05 then return nil end
	return l.X / m, l.Z / m
end

local function round4(v) return math.floor(v * 10000 + 0.5) / 10000 end

workspace:GetAttributeChangedSignal("BilliardBusy"):Connect(function()
	lastSig = nil
	if not workspace:GetAttribute("BilliardBusy") then localBusy = false end
end)
doneRemote.OnClientEvent:Connect(function()
	lastSig = nil
	localBusy = false
end)

----------------------------------------------------------------
-- GUI: ROOT + DRAG
----------------------------------------------------------------
local gui = new("ScreenGui", {
	Name = "BilliardUI", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, player:WaitForChild("PlayerGui"))

local function makeDraggable(handle, target, isLocked, onTap)
	local dragging, dragInput, dragStart, startPos, moved = false, nil, nil, nil, false
	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		dragging, moved = true, false
		dragInput, dragStart, startPos = input, input.Position, target.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if onTap and not moved then onTap() end
			end
		end)
	end)
	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			if d.Magnitude > 6 then moved = true end
			if moved and not (isLocked and isLocked()) then
				local vp = workspace.CurrentCamera.ViewportSize
				local size = target.AbsoluteSize
				target.Position = UDim2.fromOffset(
					math.clamp(startPos.X.Offset + d.X, 0, math.max(vp.X - size.X, 0)),
					math.clamp(startPos.Y.Offset + d.Y, 0, math.max(vp.Y - size.Y, 0)))
			end
		end
	end)
end

local BASE_W, BASE_H = 300, 330

local main = new("Frame", {
	Size = UDim2.fromOffset(BASE_W, BASE_H),
	Position = UDim2.fromOffset(70, 30),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, gui)
corner(main, 12)
new("UIStroke", { Color = C.stroke, Thickness = 1 }, main)

local root = new("Frame", { Size = UDim2.fromOffset(BASE_W, BASE_H), BackgroundTransparency = 1 }, main)
local uiScale = new("UIScale", { Scale = 1 }, root)

local function applyScale()
	local vp = workspace.CurrentCamera.ViewportSize
	local sc = math.clamp((vp.Y - 30) / BASE_H, 0.55, 1) * S.UiScale
	uiScale.Scale = sc
	main.Size = UDim2.fromOffset(BASE_W * sc, BASE_H * sc)
end
applyScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)

-- logo: tap to open/close, drag to move
local logo = new("TextButton", {
	Size = UDim2.fromOffset(46, 46),
	Position = UDim2.fromOffset(14, 120),
	BackgroundColor3 = Color3.fromRGB(25, 25, 35),
	Text = "🎱", TextSize = 24, Font = Enum.Font.GothamBold, TextColor3 = WHITE,
	AutoButtonColor = false,
}, gui)
corner(logo, 23)
new("UIStroke", { Color = C.accent, Thickness = 2 }, logo)

local function setOpen(v) main.Visible = v end
makeDraggable(logo, logo, nil, function() setOpen(not main.Visible) end)

-- header
local header = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Active = true }, root)
new("TextLabel", {
	Size = UDim2.new(1, -50, 1, 0), Position = UDim2.fromOffset(14, 0),
	BackgroundTransparency = 1, Text = "⋮⋮  BILLIARD AIM", Font = Enum.Font.GothamBold,
	TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = WHITE,
}, header)
local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, -32, 0, 4),
	BackgroundColor3 = C.danger, Text = "X", Font = Enum.Font.GothamBold,
	TextSize = 13, TextColor3 = WHITE, AutoButtonColor = false,
}, header)
corner(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)
makeDraggable(header, main, function() return S.Locked end, nil)

-- tabs
local tabBar = new("Frame", {
	Size = UDim2.new(1, -16, 0, 30), Position = UDim2.fromOffset(8, 36), BackgroundTransparency = 1,
}, root)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local pages, tabBtns, tabN = {}, {}, 0

local function setTab(name)
	for n, p in pairs(pages) do
		p.Visible = (n == name)
		tabBtns[n].BackgroundColor3 = (n == name) and C.accent or C.card
		tabBtns[n].TextColor3 = (n == name) and WHITE or C.sub
	end
end

local function newPage(name)
	tabN += 1
	local b = new("TextButton", {
		Size = UDim2.new(1 / 3, -4, 1, 0), BackgroundColor3 = C.card, Text = name,
		Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.sub,
		AutoButtonColor = false, LayoutOrder = tabN,
	}, tabBar)
	corner(b, 8)
	tabBtns[name] = b

	local p = new("ScrollingFrame", {
		Size = UDim2.new(1, -16, 1, -76), Position = UDim2.fromOffset(8, 70),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
	}, root)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, p)
	new("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, p)
	pages[name] = p
	b.MouseButton1Click:Connect(function() setTab(name) end)
	return p
end

local pageShot = newPage("SHOT")
local pageGuide = newPage("GUIDE")
local pageSet = newPage("SETTINGS")

----------------------------------------------------------------
-- GUI: COMPONENTS
----------------------------------------------------------------
local order = 0
local function nextOrder() order += 1 return order end

local function section(page, text)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = string.upper(text),
		Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.sub, LayoutOrder = nextOrder(),
	}, page)
end

local function row(page, h)
	local r = new("TextButton", {
		Size = UDim2.new(1, 0, 0, h or 36), BackgroundColor3 = C.card,
		AutoButtonColor = false, Text = "", LayoutOrder = nextOrder(),
	}, page)
	corner(r, 8)
	return r
end

local function rowLabel(r, text, rightPad, y, h)
	return new("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -(rightPad or 64), 0, h or 36),
		Position = UDim2.fromOffset(10, y or 0), Font = Enum.Font.GothamMedium, TextSize = 12,
		TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Text = text,
	}, r)
end

local function toggle(page, label, key, onChange)
	local r = row(page)
	rowLabel(r, label, 64)
	local track = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(44, 22), BackgroundColor3 = C.off,
	}, r)
	corner(track, 11)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16), BackgroundColor3 = WHITE,
	}, track)
	corner(knob, 8)
	local function refresh()
		local on = S[key]
		tween(track, { BackgroundColor3 = on and C.on or C.off })
		tween(knob, { Position = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
	end
	r.MouseButton1Click:Connect(function()
		S[key] = not S[key]
		refresh()
		changed()
		if onChange then onChange() end
	end)
	refresh()
end

local function slider(page, label, key, min, max, step, onChange, fmt)
	local r = row(page, 46)
	rowLabel(r, label, 90, 2, 22)
	local val = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 2),
		Size = UDim2.fromOffset(80, 22), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
		TextSize = 11, TextColor3 = C.accent, TextXAlignment = Enum.TextXAlignment.Right,
	}, r)
	local track = new("Frame", {
		Size = UDim2.new(1, -28, 0, 5), Position = UDim2.new(0, 14, 0, 32),
		BackgroundColor3 = C.off, BorderSizePixel = 0,
	}, r)
	corner(track, 3)
	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.accent, BorderSizePixel = 0,
	}, track)
	corner(fill, 3)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(16, 16), BackgroundColor3 = WHITE, ZIndex = 2,
	}, track)
	corner(knob, 8)
	new("UIStroke", { Color = C.accent, Thickness = 2 }, knob)

	local function refresh()
		local t = (S[key] - min) / (max - min)
		fill.Size = UDim2.fromScale(t, 1)
		knob.Position = UDim2.new(t, 0, 0.5, 0)
		val.Text = fmt and fmt(S[key]) or tostring(S[key])
	end

	local hit = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, 18),
		BackgroundTransparency = 1, Text = "",
	}, r)

	local function setFromX(x)
		local t = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local v = math.floor((min + t * (max - min)) / step + 0.5) * step
		v = math.clamp(math.round(v * 100) / 100, min, max)
		if S[key] ~= v then
			S[key] = v
			refresh()
			changed()
			if onChange then onChange() end
		end
	end

	local dragging = false
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local sc = r:FindFirstAncestorOfClass("ScrollingFrame")
			if sc then sc.ScrollingEnabled = false end
			setFromX(input.Position.X)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if sc then sc.ScrollingEnabled = true end
				end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	refresh()
end

local function segmented(page, label, key, options, onChange)
	local r = row(page, 58)
	rowLabel(r, label, 20, 2, 22)
	local holder = new("Frame", {
		Size = UDim2.new(1, -16, 0, 26), Position = UDim2.fromOffset(8, 26), BackgroundColor3 = C.bg,
	}, r)
	corner(holder, 8)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center,
	}, holder)
	new("UIPadding", { PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3) }, holder)

	local btns, n = {}, #options
	local function refresh()
		for i, o in ipairs(options) do
			local sel = (o[1] == S[key])
			btns[i].BackgroundColor3 = sel and C.accent or C.bg
			btns[i].TextColor3 = sel and WHITE or C.sub
		end
	end
	for i, o in ipairs(options) do
		local b = new("TextButton", {
			Size = UDim2.new(1 / n, -3, 0, 20), BackgroundColor3 = C.bg, Text = o[2],
			Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = C.sub,
			AutoButtonColor = false, LayoutOrder = i,
		}, holder)
		corner(b, 6)
		btns[i] = b
		b.MouseButton1Click:Connect(function()
			S[key] = o[1]
			refresh()
			changed()
			if onChange then onChange() end
		end)
	end
	refresh()
end

local function infoLabel(page, text)
	local l = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextSize = 10,
		TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.sub, LayoutOrder = nextOrder(),
	}, page)
	new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, l)
	return l
end

local function statusCard(page, text)
	local l = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.card, Text = text,
		Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.text, LayoutOrder = nextOrder(),
	}, page)
	corner(l, 8)
	return l
end

local function percent(v) return math.floor(v * 100 + 0.5) .. "%" end

----------------------------------------------------------------
-- GUI: CONTENT
----------------------------------------------------------------
-- SHOT
local statusL = statusCard(pageShot, "Ready")
section(pageShot, "Power")
segmented(pageShot, "Power mode", "PowerMode", {
	{ "Hold", "Hold to charge" }, { "Fixed", "Tap = fixed power" },
})
slider(pageShot, "Charge time (Hold)", "ChargeTime", 0.6, 3, 0.1, nil,
	function(v) return string.format("%.1fs", v) end)
slider(pageShot, "Preview / fixed power", "IdlePower", 0.1, 1, 0.05, nil, percent)
section(pageShot, "Controls")
toggle(pageShot, "Shoot button", "ShootBtn")
infoLabel(pageShot, "Hold mode: hold the shoot button (or left mouse) to charge, release to shoot. Fixed mode: just tap. Aim with your first-person camera.")

-- GUIDE
section(pageGuide, "Lines")
toggle(pageGuide, "Guide lines", "GuideOn")
toggle(pageGuide, "Paths of hit balls", "ShowOthers")
toggle(pageGuide, "Ghost ball (first contact)", "ShowGhost")
toggle(pageGuide, "Use ball colors", "UseBallColor")
section(pageGuide, "Style")
slider(pageGuide, "Preview time", "PreviewTime", 1, 10, 1, nil, function(v) return v .. "s" end)
slider(pageGuide, "Line thickness", "Thick", 0.5, 2.5, 0.1, nil,
	function(v) return string.format("x%.1f", v) end)
infoLabel(pageGuide, "Line color follows each ball's color. The stronger the shot, the thicker and more solid the lines.")

-- SETTINGS
section(pageSet, "Menu")
toggle(pageSet, "Lock menu position", "Locked")
slider(pageSet, "Menu size", "UiScale", 0.6, 1.3, 0.05, applyScale, percent)
infoLabel(pageSet, "Tap the 🎱 logo to open / close. The logo and the menu can both be dragged.")

setTab("SHOT")

----------------------------------------------------------------
-- HUD: POWER BAR + SHOOT BUTTON
----------------------------------------------------------------
local bar = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -28),
	Size = UDim2.fromOffset(240, 16), BackgroundColor3 = Color3.fromRGB(25, 25, 32),
	BorderSizePixel = 0,
}, gui)
corner(bar, 8)
local fill = new("Frame", {
	Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(80, 255, 120),
}, bar)
corner(fill, 8)

local powerLabel = new("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -48),
	Size = UDim2.fromOffset(240, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
	TextSize = 13, TextColor3 = WHITE, TextStrokeTransparency = 0.5, Text = "POWER 0%",
}, gui)

local shootBtn = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -28, 0.5, 0),
	Size = UDim2.fromOffset(84, 84), BackgroundColor3 = Color3.fromRGB(200, 50, 50),
	Text = "SHOOT", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = WHITE,
	AutoButtonColor = false,
}, gui)
corner(shootBtn, 42)

local function updateBar()
	local p = charging and power or 0
	fill.Size = UDim2.fromScale(p, 1)
	fill.BackgroundColor3 = Color3.fromHSV((1 - p) * 0.33, 0.85, 1)
	powerLabel.Text = "POWER " .. math.floor(p * 100 + 0.5) .. "%"
end

local function startCharge()
	if charging or not canAim() then return end
	charging = true
	power = (S.PowerMode == "Fixed") and S.IdlePower or 0
end

local function endCharge()
	if not charging then return end
	charging = false
	local pw = round4(power)
	power = 0
	updateBar()
	if pw < CFG.MinPower or not canAim() then return end

	local dx, dz = aimDir()
	if not dx then return end

	-- same numbers the prediction used -> the server runs the identical shot
	shotRemote:FireServer(round4(dx), round4(dz), pw)
	localBusy = true
	clearGuide()
	task.delay(2, function()
		if localBusy and not workspace:GetAttribute("BilliardBusy") then localBusy = false end
	end)
end

shootBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		startCharge()
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then endCharge() end
		end)
	end
end)

-- PC: hold left mouse anywhere (GUI clicks are ignored automatically)
UIS.InputBegan:Connect(function(input, gp)
	if not gp and input.UserInputType == Enum.UserInputType.MouseButton1 then startCharge() end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then endCharge() end
end)

----------------------------------------------------------------
-- MAIN LOOP
----------------------------------------------------------------
local function statusText()
	if workspace:GetAttribute("BilliardBusy") or localBusy then return "Balls moving..." end
	local turn = workspace:GetAttribute("BilliardTurn")
	if turn ~= nil and turn ~= player.UserId then return "Not your turn" end
	local cue = ballsFolder:FindFirstChild(CFG.CueName)
	if not cue or cue:GetAttribute("Pocketed") == true then return "Cue ball unavailable" end
	if not aimDir() then return "Look toward the table" end
	return "Ready - aim and shoot"
end

local acc, statAcc = 0, 0
RunService.RenderStepped:Connect(function(dt)
	local ok = canAim()
	bar.Visible, powerLabel.Visible = ok, ok
	shootBtn.Visible = ok and S.ShootBtn

	if charging then
		if not ok then
			charging, power = false, 0
		elseif S.PowerMode == "Hold" then
			power = math.min(1, power + dt / S.ChargeTime)
		else
			power = S.IdlePower
		end
	end
	updateBar()

	statAcc += dt
	if statAcc > 0.2 then
		statAcc = 0
		local t = statusText()
		if statusL.Text ~= t then statusL.Text = t end
	end

	acc += dt
	if acc < 1 / CFG.UpdateRate then return end
	acc = 0

	if not ok then
		clearGuide()
		lastSig = nil
		return
	end

	local dx, dz = aimDir()
	if not dx then
		clearGuide()
		lastSig = nil
		return
	end

	dx, dz = round4(dx), round4(dz)
	local pw = charging and round4(math.max(power, CFG.MinPower)) or S.IdlePower
	local sig = dx .. "|" .. dz .. "|" .. pw
	if sig == lastSig then return end
	lastSig = sig
	recompute(dx, dz, pw)
end)

print("[BilliardAim] v2 loaded")
