--// Toolkit v4 (Spawn Point + ESP Player + ESP Monster + Visual) - untuk place Studio milikmu sendiri
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- PENGATURAN
----------------------------------------------------------------
local S = {
	-- spawn
	AutoSpawn = true,
	ShowMarker = true,
	-- player esp
	EspPlayer = false,
	PName = true,
	PDist = true,
	PColor = 1,
	PLimitOn = false,
	PLimit = 500,
	-- monster esp
	EspMonster = false,
	MName = true,
	MDist = true,
	MColor = 2,
	MRealName = false,
	MLimitOn = false,
	MLimit = 500,
	MonsterFilter = "",
	-- visual
	NoFog = false,
	Fullbright = false,
	CustomFov = false,
	Fov = 90,
	-- umum
	Style = "Isi",
	Locked = false,
	UiScale = 1,
}

local COLORS = {
	{ "Hijau", Color3.fromRGB(60, 255, 90) },
	{ "Merah", Color3.fromRGB(255, 60, 60) },
	{ "Biru", Color3.fromRGB(70, 150, 255) },
	{ "Kuning", Color3.fromRGB(255, 220, 50) },
	{ "Ungu", Color3.fromRGB(180, 100, 255) },
	{ "Oranye", Color3.fromRGB(255, 150, 40) },
	{ "Putih", Color3.fromRGB(245, 245, 245) },
}

local KEYWORDS = { "monster", "enemy", "enemies", "mob", "zombie", "boss", "creature", "musuh", "npc" }

local WHITE = Color3.new(1, 1, 1)
local C = {
	bg = Color3.fromRGB(16, 16, 22),
	side = Color3.fromRGB(23, 23, 31),
	card = Color3.fromRGB(31, 31, 42),
	off = Color3.fromRGB(64, 64, 80),
	on = Color3.fromRGB(52, 200, 120),
	accent = Color3.fromRGB(99, 102, 241),
	accent2 = Color3.fromRGB(168, 85, 247),
	danger = Color3.fromRGB(225, 70, 80),
	text = Color3.fromRGB(240, 240, 250),
	sub = Color3.fromRGB(140, 140, 162),
}

----------------------------------------------------------------
-- HELPER UI
----------------------------------------------------------------
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local function corner(o, r)
	return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o)
end

local function outline(o, color, th, tr)
	return new("UIStroke", {
		Color = color, Thickness = th or 1, Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, o)
end

local function tween(o, props, t)
	TweenService:Create(o, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

----------------------------------------------------------------
-- SPAWN POINT
----------------------------------------------------------------
local saved = nil
local marker = nil

local function removeMarker()
	if marker then
		marker:Destroy()
		marker = nil
	end
end

local function placeMarker(cf)
	removeMarker()
	if not S.ShowMarker then return end
	marker = new("Part", {
		Name = "SpawnPointMarker",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.3, 5, 5),
		Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(60, 255, 90),
		Transparency = 0.4,
		CFrame = CFrame.new(cf.Position - Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, 0, math.rad(90)),
	}, workspace)
end

local function getRoot()
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(cf)
	local char, root = player.Character, getRoot()
	if not (char and root) then return false end
	char:PivotTo(cf)
	root.AssemblyLinearVelocity = Vector3.zero
	return true
end

----------------------------------------------------------------
-- VISUAL: NO FOG, FULLBRIGHT, FOV
----------------------------------------------------------------
local fogOrig, atmoOrig = nil, {}
local lightOrig = nil
local fovOrig = nil

local function applyNoFog()
	if not fogOrig then
		fogOrig = { Start = Lighting.FogStart, End = Lighting.FogEnd }
	end
	if Lighting.FogEnd < 1e8 then
		Lighting.FogStart = 1e8
		Lighting.FogEnd = 1e9
	end
	for _, o in ipairs(Lighting:GetChildren()) do
		if o:IsA("Atmosphere") then
			if not atmoOrig[o] then atmoOrig[o] = { Density = o.Density, Haze = o.Haze } end
			if o.Density ~= 0 then o.Density = 0 end
			if o.Haze ~= 0 then o.Haze = 0 end
		end
	end
end

local function restoreFog()
	if fogOrig then
		Lighting.FogStart, Lighting.FogEnd = fogOrig.Start, fogOrig.End
		fogOrig = nil
	end
	for o, v in pairs(atmoOrig) do
		if o.Parent then o.Density, o.Haze = v.Density, v.Haze end
	end
	table.clear(atmoOrig)
end

local function applyFullbright()
	if not lightOrig then
		lightOrig = {
			Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
			Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
			GlobalShadows = Lighting.GlobalShadows,
		}
	end
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.Ambient = Color3.fromRGB(178, 178, 178)
	Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
	Lighting.GlobalShadows = false
end

local function restoreLight()
	if lightOrig then
		for k, v in pairs(lightOrig) do Lighting[k] = v end
		lightOrig = nil
	end
end

task.spawn(function()
	while true do
		if S.NoFog then applyNoFog() end
		if S.Fullbright then applyFullbright() end
		task.wait(0.5)
	end
end)

RunService.RenderStepped:Connect(function()
	if S.CustomFov then
		local cam = workspace.CurrentCamera
		if cam.FieldOfView ~= S.Fov then cam.FieldOfView = S.Fov end
	end
end)

local function setFovMode()
	local cam = workspace.CurrentCamera
	if S.CustomFov then
		fovOrig = fovOrig or cam.FieldOfView
	elseif fovOrig then
		cam.FieldOfView = fovOrig
		fovOrig = nil
	end
end

----------------------------------------------------------------
-- DETEKSI MONSTER
----------------------------------------------------------------
local monsters = {}
local mAdded, mRemoving = nil, nil
local scanId = 0

local function hasKeyword(s)
	s = string.lower(s)
	for _, k in ipairs(KEYWORDS) do
		if s:find(k, 1, true) then return true end
	end
	return false
end

local function isMonsterModel(m)
	if m == player.Character or Players:GetPlayerFromCharacter(m) then return false end

	local a = m.Parent
	while a and a ~= workspace do
		if monsters[a] then return false end
		a = a.Parent
	end

	if S.MonsterFilter ~= "" then
		return string.lower(m.Name):find(S.MonsterFilter, 1, true) ~= nil
	end
	if m:FindFirstChildOfClass("Humanoid") or m:FindFirstChildOfClass("AnimationController") then
		return true
	end
	if hasKeyword(m.Name) then return true end
	local par = m.Parent
	return par ~= nil and par ~= workspace and hasKeyword(par.Name)
end

local function tryAdd(inst)
	local m
	if inst:IsA("Model") then
		m = inst
	elseif inst:IsA("Humanoid") or inst:IsA("AnimationController") then
		m = inst.Parent
		if not (m and m:IsA("Model")) then return end
	else
		return
	end
	if not monsters[m] and isMonsterModel(m) then monsters[m] = true end
end

local function stopMonsterTrack()
	scanId += 1
	if mAdded then mAdded:Disconnect() mAdded = nil end
	if mRemoving then mRemoving:Disconnect() mRemoving = nil end
	table.clear(monsters)
end

local function startMonsterTrack()
	stopMonsterTrack()
	local id = scanId
	mAdded = workspace.DescendantAdded:Connect(tryAdd)
	mRemoving = workspace.DescendantRemoving:Connect(function(i)
		if monsters[i] then monsters[i] = nil end
	end)
	task.spawn(function()
		local n = 0
		for _, d in ipairs(workspace:GetDescendants()) do
			if id ~= scanId then return end
			tryAdd(d)
			n += 1
			if n % 400 == 0 then task.wait() end
		end
	end)
end

----------------------------------------------------------------
-- ESP
----------------------------------------------------------------
local espObjs = {}
local monsterCount = 0
local monsterInfo

local function removeEsp(char)
	local o = espObjs[char]
	if o then
		o.hl:Destroy()
		o.bb:Destroy()
		espObjs[char] = nil
	end
end

local function clearEsp()
	for char in pairs(espObjs) do removeEsp(char) end
end

local function makeEsp(char, part)
	local hl = new("Highlight", {
		Name = "TKESP",
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		FillTransparency = 0.6,
		OutlineTransparency = 0,
		Adornee = char,
	}, char)

	local bb = new("BillboardGui", {
		Name = "TKTag",
		Size = UDim2.fromOffset(160, 18),
		StudsOffset = Vector3.new(0, 3, 0),
		AlwaysOnTop = true,
		Adornee = part,
	}, part)

	local label = new("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextStrokeTransparency = 0.3,
	}, bb)

	return { hl = hl, bb = bb, label = label }
end

local function pickPart(char)
	return char:FindFirstChild("Head")
		or char:FindFirstChild("HumanoidRootPart")
		or char.PrimaryPart
		or char:FindFirstChildWhichIsA("BasePart", true)
end

local seen = {}

local function updateOne(char, name, color, showName, showDist, limitOn, limit, root, camPos)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health <= 0 then return end
	local part = pickPart(char)
	if not part then return end

	local origin = root and root.Position or camPos
	local dist = (part.Position - origin).Magnitude
	if limitOn and dist > limit then return end

	seen[char] = true

	local o = espObjs[char]
	if o and (o.hl.Parent ~= char or o.bb.Parent ~= part) then
		removeEsp(char)
		o = nil
	end
	if not o then
		o = makeEsp(char, part)
		espObjs[char] = o
	end

	if o.color ~= color then
		o.color = color
		o.hl.FillColor = color
		o.hl.OutlineColor = color
		o.label.TextColor3 = color
	end

	local fillT = (S.Style == "Isi") and 0.6 or 1
	if o.hl.FillTransparency ~= fillT then o.hl.FillTransparency = fillT end

	o.bb.Enabled = showName or showDist

	local text = showName and name or ""
	if showDist then
		text = (text ~= "" and (text .. " ") or "") .. "[" .. math.floor(dist) .. "m]"
	end
	if o.label.Text ~= text then o.label.Text = text end
end

local espTimer, infoTimer = 0, 0
RunService.Heartbeat:Connect(function(dt)
	espTimer += dt
	if espTimer < 0.2 then return end
	espTimer = 0

	if not (S.EspPlayer or S.EspMonster) then
		if next(espObjs) then clearEsp() end
		return
	end

	local root = getRoot()
	local camPos = workspace.CurrentCamera.CFrame.Position
	table.clear(seen)

	if S.EspPlayer then
		local col = COLORS[S.PColor][2]
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				updateOne(plr.Character, plr.Name, col, S.PName, S.PDist,
					S.PLimitOn, S.PLimit, root, camPos)
			end
		end
	end

	if S.EspMonster then
		local col = COLORS[S.MColor][2]
		local n = 0
		for model in pairs(monsters) do
			if not model.Parent then
				monsters[model] = nil
			else
				n += 1
				updateOne(model, S.MRealName and model.Name or "Monster", col,
					S.MName, S.MDist, S.MLimitOn, S.MLimit, root, camPos)
			end
		end
		monsterCount = n
	end

	for char in pairs(espObjs) do
		if not seen[char] then removeEsp(char) end
	end

	infoTimer += 0.2
	if infoTimer >= 1 and monsterInfo then
		infoTimer = 0
		local t = S.EspMonster and ("Monster terdeteksi: " .. monsterCount) or "ESP Monster belum aktif."
		if monsterInfo.Text ~= t then monsterInfo.Text = t end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if plr.Character then removeEsp(plr.Character) end
end)

----------------------------------------------------------------
-- GUI: WINDOW
----------------------------------------------------------------
local gui = new("ScreenGui", {
	Name = "ToolkitUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, player:WaitForChild("PlayerGui"))

local main = new("Frame", {
	Size = UDim2.fromOffset(360, 330),
	Position = UDim2.new(1, -372, 0.5, -165),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
}, gui)
corner(main, 16)
local mainStroke = outline(main, C.accent, 1.5, 0.35)
local uiScale = new("UIScale", { Scale = S.UiScale }, main)

-- Header
local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundTransparency = 1,
	Active = true,
}, main)

new("TextLabel", {
	Size = UDim2.new(0, 120, 0, 20),
	Position = UDim2.fromOffset(16, 5),
	BackgroundTransparency = 1,
	Text = "TOOLKIT",
	Font = Enum.Font.GothamBlack,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.text,
}, header)

local pageTitle = new("TextLabel", {
	Size = UDim2.new(1, -120, 0, 14),
	Position = UDim2.fromOffset(16, 23),
	BackgroundTransparency = 1,
	Text = "",
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.sub,
}, header)

local function headerBtn(text, xOff, color)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, xOff, 0, 6),
		BackgroundColor3 = color,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = WHITE,
		AutoButtonColor = true,
	}, header)
	corner(b, 8)
	return b
end

local lockBtn = headerBtn("🔓", -72, C.card)
local closeBtn = headerBtn("✕", -38, C.danger)

local line = new("Frame", {
	Size = UDim2.new(1, -24, 0, 2),
	Position = UDim2.fromOffset(12, 41),
	BackgroundColor3 = WHITE,
	BorderSizePixel = 0,
}, main)
corner(line, 1)
new("UIGradient", {
	Color = ColorSequence.new(C.accent, C.accent2),
}, line)

-- Tombol buka kembali
local reopen = new("TextButton", {
	Size = UDim2.fromOffset(42, 42),
	Position = UDim2.new(1, -54, 0.5, -21),
	BackgroundColor3 = C.bg,
	Text = "≡",
	Font = Enum.Font.GothamBold,
	TextSize = 24,
	TextColor3 = WHITE,
	Visible = false,
}, gui)
corner(reopen, 12)
outline(reopen, C.accent, 1.5, 0.2)

local function setOpen(v)
	main.Visible = v
	reopen.Visible = not v
end
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)
reopen.MouseButton1Click:Connect(function() setOpen(true) end)

-- Geser lewat header (nonaktif saat terkunci)
do
	local dragging, dragStart, startPos = false, nil, nil
	header.InputBegan:Connect(function(input)
		if S.Locked then return end
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and not S.Locked and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- Sidebar
local sidebar = new("Frame", {
	Size = UDim2.fromOffset(60, 274),
	Position = UDim2.fromOffset(8, 48),
	BackgroundColor3 = C.side,
}, main)
corner(sidebar, 12)
new("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, sidebar)
new("UIPadding", { PaddingTop = UDim.new(0, 5) }, sidebar)

local content = new("Frame", {
	Size = UDim2.new(1, -78, 0, 274),
	Position = UDim2.fromOffset(74, 48),
	BackgroundTransparency = 1,
}, main)

local pages, tabs = {}, {}
local tabOrder = 0

local function setTab(name)
	for n, p in pairs(pages) do
		local sel = (n == name)
		p.page.Visible = sel
		tween(tabs[n].btn, { BackgroundColor3 = sel and C.accent or C.side })
		tabs[n].name.TextColor3 = sel and WHITE or C.sub
		if sel then pageTitle.Text = p.title end
	end
end

local function newPage(name, icon, title)
	tabOrder += 1
	local btn = new("TextButton", {
		Size = UDim2.new(1, -8, 0, 50),
		BackgroundColor3 = C.side,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = tabOrder,
	}, sidebar)
	corner(btn, 10)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 5),
		BackgroundTransparency = 1,
		Text = icon,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextColor3 = WHITE,
	}, btn)
	local nameL = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.fromOffset(0, 31),
		BackgroundTransparency = 1,
		Text = name,
		TextSize = 9,
		Font = Enum.Font.GothamBold,
		TextColor3 = C.sub,
	}, btn)

	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, content)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	new("UIPadding", {
		PaddingRight = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 2),
	}, page)

	pages[name] = { page = page, title = title }
	tabs[name] = { btn = btn, name = nameL }
	btn.MouseButton1Click:Connect(function() setTab(name) end)
	return page
end

local pageSpawn = newPage("SPAWN", "📍", "Titik spawn")
local pagePlayer = newPage("PLAYER", "👤", "ESP Player")
local pageMonster = newPage("MONSTER", "👹", "ESP Monster")
local pageVisual = newPage("VISUAL", "🌤", "Tampilan dunia")
local pageSet = newPage("SETELAN", "⚙", "Pengaturan")

----------------------------------------------------------------
-- GUI: KOMPONEN
----------------------------------------------------------------
local order = 0
local function nextOrder()
	order += 1
	return order
end

local setters = {}

local function section(page, text)
	local f = new("Frame", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
	}, page)
	local bar = new("Frame", {
		Size = UDim2.fromOffset(3, 12),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
	}, f)
	corner(bar, 2)
	new("TextLabel", {
		Size = UDim2.new(1, -14, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = string.upper(text),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.sub,
	}, f)
end

local function row(page, height)
	local r = new("TextButton", {
		Size = UDim2.new(1, 0, 0, height or 40),
		BackgroundColor3 = C.card,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = nextOrder(),
	}, page)
	corner(r, 10)
	return r
end

local function rowLabel(r, text, rightPad)
	return new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -(rightPad or 64), 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = text,
	}, r)
end

local function toggle(page, label, key, onChange)
	local r = row(page)
	rowLabel(r, label, 64)
	local track = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(40, 22),
		BackgroundColor3 = C.off,
	}, r)
	corner(track, 11)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = WHITE,
	}, track)
	corner(knob, 8)

	local function refresh()
		local on = S[key]
		tween(track, { BackgroundColor3 = on and C.on or C.off })
		tween(knob, { Position = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
	end
	setters[key] = function(v)
		S[key] = v
		refresh()
		if onChange then onChange() end
	end
	r.MouseButton1Click:Connect(function() setters[key](not S[key]) end)
	refresh()
end

local function stepper(page, label, key, step, min, max, onChange, fmt)
	local r = row(page)
	rowLabel(r, label, 138)
	local function small(txt, xOff)
		local b = new("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, xOff, 0.5, 0),
			Size = UDim2.fromOffset(28, 26),
			BackgroundColor3 = C.off,
			Text = txt,
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextColor3 = WHITE,
		}, r)
		corner(b, 8)
		return b
	end
	local plus = small("+", -8)
	local minus = small("−", -86)
	local val = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -36, 0.5, 0),
		Size = UDim2.fromOffset(46, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.text,
	}, r)
	local function refresh() val.Text = fmt and fmt(S[key]) or tostring(S[key]) end
	local function change(d)
		S[key] = math.clamp(math.round((S[key] + d) * 100) / 100, min, max)
		refresh()
		if onChange then onChange() end
	end
	minus.MouseButton1Click:Connect(function() change(-step) end)
	plus.MouseButton1Click:Connect(function() change(step) end)
	refresh()
end

local function cycle(page, label, key, options, onChange)
	local r = row(page)
	rowLabel(r, label, 120)
	local pill = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(100, 24),
		BackgroundColor3 = C.accent,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = WHITE,
	}, r)
	corner(pill, 12)
	local function refresh()
		for _, o in ipairs(options) do
			if o[1] == S[key] then pill.Text = o[2] end
		end
	end
	r.MouseButton1Click:Connect(function()
		local idx = 1
		for i, o in ipairs(options) do
			if o[1] == S[key] then idx = i end
		end
		S[key] = options[(idx % #options) + 1][1]
		refresh()
		if onChange then onChange() end
	end)
	refresh()
end

local function colorCycle(page, label, key)
	local r = row(page)
	rowLabel(r, label, 120)
	local pill = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(100, 24),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(15, 15, 20),
	}, r)
	corner(pill, 12)
	local function refresh()
		pill.Text = COLORS[S[key]][1]
		pill.BackgroundColor3 = COLORS[S[key]][2]
	end
	r.MouseButton1Click:Connect(function()
		S[key] = (S[key] % #COLORS) + 1
		refresh()
	end)
	refresh()
end

local function actionButton(page, text, color, onClick)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = color,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = WHITE,
		LayoutOrder = nextOrder(),
	}, page)
	corner(b, 10)
	b.MouseButton1Click:Connect(onClick)
	return b
end

local function statusCard(page, text)
	local l = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.card,
		Text = text,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.text,
		LayoutOrder = nextOrder(),
	}, page)
	corner(l, 10)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 9),
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
	}, l)
	return l
end

local function infoLabel(page, text)
	local l = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.sub,
		LayoutOrder = nextOrder(),
	}, page)
	new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, l)
	return l
end

local function textInput(page, placeholder, onSubmit)
	local box = new("TextBox", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = C.card,
		TextColor3 = C.text,
		PlaceholderText = placeholder,
		PlaceholderColor3 = C.sub,
		Text = "",
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		LayoutOrder = nextOrder(),
	}, page)
	corner(box, 10)
	outline(box, C.accent, 1, 0.7)
	box.FocusLost:Connect(function() onSubmit(box.Text) end)
	return box
end

local function meters(v) return v .. "m" end
----------------------------------------------------------------
-- ISI: SPAWN
----------------------------------------------------------------
section(pageSpawn, "Status")
local spawnStatus = statusCard(pageSpawn, "Belum ada spawn point.")

section(pageSpawn, "Aksi")
actionButton(pageSpawn, "📍  Simpan Spawn Point", C.on, function()
	local char = player.Character
	local root = getRoot()
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not (root and hum and hum.Health > 0) then
		spawnStatus.Text = "Tidak bisa menyimpan: karakter tidak ada atau sudah mati."
		return
	end
	saved = root.CFrame
	placeMarker(saved)
	local p = saved.Position
	spawnStatus.Text = string.format("Tersimpan di (%d, %d, %d).", p.X, p.Y, p.Z)
end)

actionButton(pageSpawn, "🚀  Teleport ke Spawn Point", C.accent, function()
	if not saved then
		spawnStatus.Text = "Belum ada spawn point."
		return
	end
	if teleportTo(saved + Vector3.new(0, 3, 0)) then
		spawnStatus.Text = "Teleport ke spawn point."
	end
end)

actionButton(pageSpawn, "🗑  Hapus Spawn Point", C.danger, function()
	saved = nil
	removeMarker()
	spawnStatus.Text = "Spawn point dihapus. Respawn kembali ke titik bawaan."
end)

section(pageSpawn, "Opsi")
toggle(pageSpawn, "Spawn otomatis saat mati", "AutoSpawn")
toggle(pageSpawn, "Tampilkan penanda", "ShowMarker", function()
	if saved then placeMarker(saved) else removeMarker() end
end)

----------------------------------------------------------------
-- ISI: PLAYER
----------------------------------------------------------------
section(pagePlayer, "Utama")
toggle(pagePlayer, "ESP Player", "EspPlayer")
section(pagePlayer, "Tampilan")
toggle(pagePlayer, "Tampilkan nama", "PName")
toggle(pagePlayer, "Tampilkan jarak", "PDist")
colorCycle(pagePlayer, "Warna", "PColor")
section(pagePlayer, "Batas jarak")
toggle(pagePlayer, "Aktifkan batas", "PLimitOn")
stepper(pagePlayer, "Jarak maksimal", "PLimit", 50, 50, 2000, nil, meters)

----------------------------------------------------------------
-- ISI: MONSTER
----------------------------------------------------------------
section(pageMonster, "Utama")
toggle(pageMonster, "ESP Monster", "EspMonster", function()
	if S.EspMonster then startMonsterTrack() else stopMonsterTrack() end
end)
monsterInfo = statusCard(pageMonster, "ESP Monster belum aktif.")

section(pageMonster, "Tampilan")
toggle(pageMonster, "Tampilkan nama", "MName")
toggle(pageMonster, "Tampilkan jarak", "MDist")
toggle(pageMonster, "Pakai nama asli model", "MRealName")
colorCycle(pageMonster, "Warna", "MColor")

section(pageMonster, "Batas jarak")
toggle(pageMonster, "Aktifkan batas", "MLimitOn")
stepper(pageMonster, "Jarak maksimal", "MLimit", 50, 50, 2000, nil, meters)

section(pageMonster, "Deteksi")
textInput(pageMonster, "Filter nama, contoh: zombie", function(text)
	S.MonsterFilter = string.lower(text:match("^%s*(.-)%s*$"))
	if S.EspMonster then startMonsterTrack() end
end)
infoLabel(pageMonster, "Kosong = otomatis (punya Humanoid / AnimationController, atau nama berisi monster, enemy, mob, zombie, boss, npc). Diisi = hanya model dengan nama itu.")

----------------------------------------------------------------
-- ISI: VISUAL
----------------------------------------------------------------
section(pageVisual, "Lingkungan")
toggle(pageVisual, "No Fog (hapus kabut)", "NoFog", function()
	if S.NoFog then applyNoFog() else restoreFog() end
end)
toggle(pageVisual, "Fullbright (terang)", "Fullbright", function()
	if S.Fullbright then applyFullbright() else restoreLight() end
end)
section(pageVisual, "Kamera")
toggle(pageVisual, "Atur FOV kamera", "CustomFov", setFovMode)
stepper(pageVisual, "Nilai FOV", "Fov", 5, 40, 120)
infoLabel(pageVisual, "Saat dimatikan, kabut, cahaya, dan FOV kembali seperti semula.")

----------------------------------------------------------------
-- ISI: SETELAN
----------------------------------------------------------------
local function refreshLock()
	lockBtn.Text = S.Locked and "🔒" or "🔓"
	tween(lockBtn, { BackgroundColor3 = S.Locked and C.on or C.card })
	mainStroke.Color = S.Locked and C.on or C.accent
end
lockBtn.MouseButton1Click:Connect(function() setters.Locked(not S.Locked) end)

section(pageSet, "Jendela")
toggle(pageSet, "Kunci posisi jendela", "Locked", refreshLock)
stepper(pageSet, "Ukuran menu", "UiScale", 0.1, 0.6, 1.4, function()
	uiScale.Scale = S.UiScale
end, function(v) return math.floor(v * 100 + 0.5) .. "%" end)

section(pageSet, "ESP")
cycle(pageSet, "Gaya sorotan", "Style", {
	{ "Isi", "Isi + Garis" },
	{ "Garis", "Garis saja" },
})

section(pageSet, "Darurat")
actionButton(pageSet, "⛔  Matikan semua fitur", C.danger, function()
	for _, k in ipairs({ "EspPlayer", "EspMonster", "NoFog", "Fullbright", "CustomFov" }) do
		if setters[k] then setters[k](false) end
	end
end)
infoLabel(pageSet, "Toolkit v4 · tombol ✕ menutup menu, tombol ≡ membukanya lagi.")

refreshLock()
setTab("SPAWN")

----------------------------------------------------------------
-- RESPAWN -> PINDAH KE SPAWN POINT
----------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
	if not (S.AutoSpawn and saved) then return end

	local root = char:WaitForChild("HumanoidRootPart", 10)
	if not root then return end

	local target = saved + Vector3.new(0, 3, 0)
	char:PivotTo(target)

	task.delay(0.15, function()
		if char.Parent and S.AutoSpawn and saved then
			char:PivotTo(target)
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end)

	spawnStatus.Text = "Respawn di spawn point tersimpan."
end)
