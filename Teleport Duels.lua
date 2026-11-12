--// AimAssist Mobile v6.5 (Duel, kamera TPP normal) - untuk place Studio milikmu sendiri
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

----------------------------------------------------------------
-- PENGATURAN
----------------------------------------------------------------
local S = {
	-- aim
	Enabled = false,
	AutoAim = false,
	AimMode = "Camera",         -- Camera / Character / Both
	Fov = 150,
	Smooth = 3,
	WallCheck = true,           -- langsung ON
	TargetLock = true,
	IgnoreTeams = true,         -- duel: abaikan Team, semua pemain lain = musuh
	PartMode = "Head",          -- Head / Body / Random
	PriorityOn = false,
	PriorityMode = "Crosshair", -- Crosshair / Jarak / Darah
	PredictOn = false,
	Predict = 0.10,             -- detik
	SideOn = true,              -- panel side toggle (Aim & Auto Aim)
	-- esp
	Esp = false,
	EspName = true,
	-- umum
	MaxDistOn = false,
	MaxDist = 300,
	Npc = false,
	BtnSize = 80,
	BtnSide = "Kanan",
}

local GREEN = Color3.fromRGB(60, 255, 90)
local RED = Color3.fromRGB(255, 60, 60)
local WHITE = Color3.new(1, 1, 1)

local SEARCH_INTERVAL = 0.05
local WALL_INTERVAL = 0.1
local ESP_INTERVAL = 0.2

-- status untuk auto-matikan saat mati dan nyalakan lagi saat respawn
local resumeAim = false
local refreshers = {}

----------------------------------------------------------------
-- TEMAN / MUSUH
----------------------------------------------------------------
local manual = {} -- [UserId] = true teman / false musuh / nil auto

local function isFriend(plr)
	local o = manual[plr.UserId]
	if o ~= nil then return o end
	if S.IgnoreTeams then return false end
	if player.Neutral or plr.Neutral then return false end
	if player.Team ~= nil and plr.Team == player.Team then return true end
	return plr.TeamColor == player.TeamColor
end

local function isEnemy(plr)
	if plr == player then return false end
	-- kalau server mengisi lawan duel, hanya dia yang jadi musuh
	local id = player:GetAttribute("DuelOpponent")
	if id and manual[plr.UserId] == nil then
		return plr.UserId == id
	end
	return not isFriend(plr)
end

----------------------------------------------------------------
-- FUNGSI BANTU
----------------------------------------------------------------
local function isAlive(char)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return hum ~= nil and hum.Health > 0
end

local function partFor(char, mode)
	if mode == "Body" then
		return char:FindFirstChild("HumanoidRootPart")
			or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	end
	return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function scorePart(char)
	return partFor(char, S.PartMode == "Body" and "Body" or "Head")
end

-- raycast yang melewati part transparan / tanpa collision
local function isVisible(part)
	local ignore = { player.Character }
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore
	local origin = camera.CFrame.Position
	for _ = 1, 6 do
		local hit = workspace:Raycast(origin, part.Position - origin, params)
		if not hit then return true end
		local inst = hit.Instance
		if inst:IsDescendantOf(part.Parent) then return true end
		if inst.CanCollide and inst.Transparency < 0.9 then return false end
		table.insert(ignore, inst)
		params.FilterDescendantsInstances = ignore
		origin = hit.Position
	end
	return true
end

local function screenDist(part)
	local pos, onScreen = camera:WorldToViewportPoint(part.Position)
	if not onScreen then return nil end
	return (Vector2.new(pos.X, pos.Y) - camera.ViewportSize / 2).Magnitude
end

local function worldDist(pos)
	local c = player.Character
	local r = c and c:FindFirstChild("HumanoidRootPart")
	return (pos - (r and r.Position or camera.CFrame.Position)).Magnitude
end

local function inRange(pos)
	return not S.MaxDistOn or worldDist(pos) <= S.MaxDist
end

----------------------------------------------------------------
-- ENTITY (pemain + NPC)
----------------------------------------------------------------
local npcs = {} -- [Model] = true

local function tryAddNpc(inst)
	if inst:IsA("Humanoid") and inst.Parent and inst.Parent:IsA("Model") then
		npcs[inst.Parent] = true
	end
end
for _, d in ipairs(workspace:GetDescendants()) do tryAddNpc(d) end
workspace.DescendantAdded:Connect(tryAddNpc)
workspace.DescendantRemoving:Connect(function(i)
	if i:IsA("Humanoid") and i.Parent then npcs[i.Parent] = nil end
end)

local function getEntities()
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			list[#list + 1] = { char = plr.Character, plr = plr, name = plr.Name }
		end
	end
	if S.Npc then
		for model in pairs(npcs) do
			if not model.Parent then
				npcs[model] = nil
			elseif model ~= player.Character and not Players:GetPlayerFromCharacter(model) then
				list[#list + 1] = { char = model, plr = nil, name = model.Name }
			end
		end
	end
	return list
end

local function entityEnemy(e)
	if e.plr then return isEnemy(e.plr) end
	return true -- NPC dianggap musuh
end

local function getBestTarget()
	local best, bestScore = nil, math.huge
	for _, e in ipairs(getEntities()) do
		if entityEnemy(e) and isAlive(e.char) then
			local part = scorePart(e.char)
			if part then
				local d = screenDist(part)
				if d and d <= S.Fov and inRange(part.Position) then
					local score = d
					if S.PriorityOn then
						if S.PriorityMode == "Jarak" then
							score = worldDist(part.Position)
						elseif S.PriorityMode == "Darah" then
							score = e.char:FindFirstChildOfClass("Humanoid").Health
						end
					end
					if score < bestScore and (not S.WallCheck or isVisible(part)) then
						best, bestScore = e, score
					end
				end
			end
		end
	end
	return best
end

----------------------------------------------------------------
-- ESP (nama & jarak saja)
----------------------------------------------------------------
local espObjs = {}

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
	local hl = Instance.new("Highlight")
	hl.Name = "AimAssistESP"
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = 0.6
	hl.OutlineTransparency = 0
	hl.Adornee = char
	hl.Parent = char

	local bb = Instance.new("BillboardGui")
	bb.Name = "AimAssistTag"
	bb.Size = UDim2.fromOffset(150, 18)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = part
	bb.Parent = part

	local nameL = Instance.new("TextLabel")
	nameL.Size = UDim2.fromScale(1, 1)
	nameL.BackgroundTransparency = 1
	nameL.Font = Enum.Font.GothamBold
	nameL.TextSize = 12
	nameL.TextStrokeTransparency = 0.3
	nameL.Parent = bb

	return { hl = hl, bb = bb, nameL = nameL }
end

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local C = {
	bg = Color3.fromRGB(20, 20, 26),
	card = Color3.fromRGB(34, 34, 44),
	off = Color3.fromRGB(70, 70, 84),
	on = Color3.fromRGB(60, 190, 100),
	accent = Color3.fromRGB(88, 101, 242),
	text = Color3.fromRGB(235, 235, 245),
	sub = Color3.fromRGB(150, 150, 170),
}

local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = o
end

local gui = Instance.new("ScreenGui")
gui.Name = "AimAssistUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- Lingkaran FOV (tetap di tengah layar)
local circle = Instance.new("Frame")
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.fromScale(0.5, 0.5)
circle.BackgroundTransparency = 1
circle.Active = false
circle.Visible = false
circle.Parent = gui
corner(circle, 9999)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = WHITE
stroke.Parent = circle

local function updateCircle()
	circle.Size = UDim2.fromOffset(S.Fov * 2, S.Fov * 2)
end

----------------------------------------------------------------
-- DRAG (bisa digeser dengan jari / mouse, tidak keluar layar)
----------------------------------------------------------------
-- handle = bagian yang ditahan, target = frame yang ikut bergerak,
-- onTap dipanggil kalau cuma diketuk (tidak digeser)
local function makeDraggable(handle, target, onTap)
	local dragging, dragInput, dragStart, startPos, moved = false, nil, nil, nil, false

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		dragging, moved = true, false
		dragInput = input
		dragStart = input.Position
		startPos = target.Position
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
			if moved then
				local vp = camera.ViewportSize
				local size = target.AbsoluteSize
				local x = math.clamp(startPos.X.Offset + d.X, 0, math.max(vp.X - size.X, 0))
				local y = math.clamp(startPos.Y.Offset + d.Y, 0, math.max(vp.Y - size.Y, 0))
				target.Position = UDim2.fromOffset(x, y)
			end
		end
	end)
end

-- Jendela utama
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(290, 320)
main.Position = UDim2.fromOffset(10, 40)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Parent = gui
corner(main, 12)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundTransparency = 1
header.Active = true
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "⋮⋮  Aim Assist  v6.5"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = C.text
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(190, 60, 60)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.TextColor3 = WHITE
closeBtn.Parent = header
corner(closeBtn, 6)

makeDraggable(header, main, nil)

-- Tombol buka kembali (bisa digeser, ketuk untuk membuka)
local reopen = Instance.new("TextButton")
reopen.Size = UDim2.fromOffset(40, 40)
reopen.Position = UDim2.fromOffset(10, 40)
reopen.BackgroundColor3 = C.bg
reopen.Text = "≡"
reopen.Font = Enum.Font.GothamBold
reopen.TextSize = 22
reopen.TextColor3 = WHITE
reopen.AutoButtonColor = false
reopen.Visible = false
reopen.Parent = gui
corner(reopen, 10)

local function setUIVisible(v)
	main.Visible = v
	reopen.Visible = not v
end
closeBtn.MouseButton1Click:Connect(function() setUIVisible(false) end)
makeDraggable(reopen, reopen, function() setUIVisible(true) end)

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 30)
tabBar.Position = UDim2.fromOffset(8, 38)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabBar

local pages, tabBtns = {}, {}

local function setTab(name)
	for n, p in pairs(pages) do
		p.Visible = (n == name)
		tabBtns[n].BackgroundColor3 = (n == name) and C.accent or C.card
		tabBtns[n].TextColor3 = (n == name) and WHITE or C.sub
	end
end

local function newPage(name)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1 / 3, -4, 1, 0)
	b.Text = name
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.BackgroundColor3 = C.card
	b.TextColor3 = C.sub
	b.AutoButtonColor = false
	b.Parent = tabBar
	corner(b, 8)
	tabBtns[name] = b

	local p = Instance.new("ScrollingFrame")
	p.Size = UDim2.new(1, 0, 1, -74)
	p.Position = UDim2.fromOffset(0, 72)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ScrollBarThickness = 3
	p.CanvasSize = UDim2.new()
	p.AutomaticCanvasSize = Enum.AutomaticSize.Y
	p.Visible = false
	p.Parent = main
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 6)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = p
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.Parent = p
	pages[name] = p

	b.MouseButton1Click:Connect(function() setTab(name) end)
	return p
end

local pageAim = newPage("AIM")
local pageEsp = newPage("ESP")
local pageSet = newPage("PENGATURAN")

-- Pembuat komponen
local order = 0
local function nextOrder()
	order += 1
	return order
end

local aimBtn
local sideRefresh = function() end

local function applyAimBtn()
	if not aimBtn then return end
	aimBtn.Size = UDim2.fromOffset(S.BtnSize, S.BtnSize)
	if S.BtnSide == "Kiri" then
		aimBtn.Position = UDim2.new(0, 30, 0.5, -S.BtnSize / 2)
	else
		aimBtn.Position = UDim2.new(1, -(S.BtnSize + 30), 0.5, -S.BtnSize / 2)
	end
end

local function refreshHud()
	if aimBtn then aimBtn.Visible = S.Enabled and not S.AutoAim end
	circle.Visible = S.Enabled
	sideRefresh()
end

local function section(page, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 18)
	l.BackgroundTransparency = 1
	l.Text = string.upper(text)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 11
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = C.sub
	l.LayoutOrder = nextOrder()
	l.Parent = page
end

local function newRow(page, labelText, labelWidthOffset)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 36)
	b.BackgroundColor3 = C.card
	b.AutoButtonColor = false
	b.Text = ""
	b.LayoutOrder = nextOrder()
	b.Parent = page
	corner(b, 8)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, labelWidthOffset or -70, 1, 0)
	l.Position = UDim2.fromOffset(10, 0)
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 13
	l.TextColor3 = C.text
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Text = labelText
	l.Parent = b
	return b
end

local function pill(parent, w)
	local p = Instance.new("TextLabel")
	p.AnchorPoint = Vector2.new(1, 0.5)
	p.Position = UDim2.new(1, -8, 0.5, 0)
	p.Size = UDim2.fromOffset(w, 22)
	p.Font = Enum.Font.GothamBold
	p.TextSize = 11
	p.TextColor3 = WHITE
	p.BackgroundColor3 = C.off
	p.Parent = parent
	corner(p, 11)
	return p
end

local function toggle(page, label, key, onChange)
	local b = newRow(page, label)
	local p = pill(b, 48)
	local function refresh()
		p.Text = S[key] and "ON" or "OFF"
		p.BackgroundColor3 = S[key] and C.on or C.off
	end
	refreshers[key] = refresh
	b.MouseButton1Click:Connect(function()
		S[key] = not S[key]
		refresh()
		refreshHud()
		if onChange then onChange() end
	end)
	refresh()
end

local function cycle(page, label, key, options, onChange)
	local b = newRow(page, label, -110)
	local p = pill(b, 88)
	p.BackgroundColor3 = C.accent
	local function refresh()
		for _, o in ipairs(options) do
			if o[1] == S[key] then p.Text = o[2] end
		end
	end
	b.MouseButton1Click:Connect(function()
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

local function stepper(page, label, key, step, min, max, onChange)
	local b = newRow(page, label, -150)
	local function small(txt, xOff)
		local s = Instance.new("TextButton")
		s.AnchorPoint = Vector2.new(1, 0.5)
		s.Position = UDim2.new(1, xOff, 0.5, 0)
		s.Size = UDim2.fromOffset(28, 24)
		s.BackgroundColor3 = C.off
		s.Text = txt
		s.Font = Enum.Font.GothamBold
		s.TextSize = 14
		s.TextColor3 = WHITE
		s.Parent = b
		corner(s, 6)
		return s
	end
	local plus = small("+", -8)
	local minus = small("-", -88)
	local val = Instance.new("TextLabel")
	val.AnchorPoint = Vector2.new(1, 0.5)
	val.Position = UDim2.new(1, -38, 0.5, 0)
	val.Size = UDim2.fromOffset(46, 24)
	val.BackgroundTransparency = 1
	val.Font = Enum.Font.GothamBold
	val.TextSize = 12
	val.TextColor3 = C.text
	val.Parent = b
	local function refresh() val.Text = tostring(S[key]) end
	local function change(d)
		S[key] = math.clamp(math.round((S[key] + d) * 100) / 100, min, max)
		refresh()
		if onChange then onChange() end
	end
	minus.MouseButton1Click:Connect(function() change(-step) end)
	plus.MouseButton1Click:Connect(function() change(step) end)
	refresh()
end

----------------------------------------------------------------
-- SIDE TOGGLE (panel kecil: Aim & Auto Aim, bisa digeser)
----------------------------------------------------------------
local function setFlag(key, v)
	S[key] = v
	if key == "Enabled" then resumeAim = false end
	-- Auto Aim hanya bekerja kalau Aim menyala, jadi ikut dinyalakan
	if key == "AutoAim" and v and not S.Enabled then
		S.Enabled = true
		if refreshers.Enabled then refreshers.Enabled() end
	end
	if refreshers[key] then refreshers[key]() end
	refreshHud()
end

local side = Instance.new("Frame")
side.Name = "SideToggle"
side.Size = UDim2.fromOffset(116, 0)
side.AutomaticSize = Enum.AutomaticSize.Y
side.Position = UDim2.fromOffset(14, 150)
side.BackgroundColor3 = C.bg
side.BorderSizePixel = 0
side.Visible = S.SideOn
side.Parent = gui
corner(side, 10)
do
	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(60, 60, 80)
	st.Thickness = 1
	st.Parent = side
	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 4)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Parent = side
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 5)
	pad.PaddingBottom = UDim.new(0, 5)
	pad.PaddingLeft = UDim.new(0, 5)
	pad.PaddingRight = UDim.new(0, 5)
	pad.Parent = side
end

local sideHead = Instance.new("TextButton")
sideHead.Size = UDim2.new(1, 0, 0, 24)
sideHead.BackgroundColor3 = C.card
sideHead.Text = "⋮⋮ AIM ▲"
sideHead.Font = Enum.Font.GothamBold
sideHead.TextSize = 11
sideHead.TextColor3 = WHITE
sideHead.AutoButtonColor = false
sideHead.LayoutOrder = 1
sideHead.Parent = side
corner(sideHead, 6)

local sideBody = Instance.new("Frame")
sideBody.Size = UDim2.new(1, 0, 0, 0)
sideBody.AutomaticSize = Enum.AutomaticSize.Y
sideBody.BackgroundTransparency = 1
sideBody.LayoutOrder = 2
sideBody.Parent = side
do
	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 4)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Parent = sideBody
end

local sideBtns = {}
local function sideToggle(label, key, ord)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 30)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = WHITE
	b.AutoButtonColor = false
	b.LayoutOrder = ord
	b.Parent = sideBody
	corner(b, 7)
	b.MouseButton1Click:Connect(function() setFlag(key, not S[key]) end)
	sideBtns[key] = { btn = b, label = label }
end
sideToggle("Aim", "Enabled", 1)
sideToggle("Auto Aim", "AutoAim", 2)

sideRefresh = function()
	for key, d in pairs(sideBtns) do
		d.btn.Text = d.label .. ": " .. (S[key] and "ON" or "OFF")
		d.btn.BackgroundColor3 = S[key] and C.on or C.off
	end
end

local sideOpen = true
makeDraggable(sideHead, side, function()
	sideOpen = not sideOpen
	sideBody.Visible = sideOpen
	sideHead.Text = sideOpen and "⋮⋮ AIM ▲" or "⋮⋮ AIM ▼"
end)

---------------- TAB AIM ----------------
section(pageAim, "Utama")
toggle(pageAim, "Aim", "Enabled", function()
	resumeAim = false -- kalau dimatikan/dinyalakan manual, batalkan auto-nyala
end)
toggle(pageAim, "Auto Aim", "AutoAim")
toggle(pageAim, "Side toggle (Aim & Auto Aim)", "SideOn", function()
	side.Visible = S.SideOn
end)
cycle(pageAim, "Mode bidik", "AimMode", {
	{ "Camera", "Kamera" }, { "Character", "Karakter" }, { "Both", "Keduanya" },
})
stepper(pageAim, "FOV", "Fov", 10, 20, 500, updateCircle)
stepper(pageAim, "Smooth", "Smooth", 1, 1, 30)
section(pageAim, "Target")
toggle(pageAim, "Wall Check", "WallCheck")
toggle(pageAim, "Target Lock", "TargetLock")
toggle(pageAim, "Ignore teams (duel)", "IgnoreTeams")
cycle(pageAim, "Bagian target", "PartMode", {
	{ "Head", "Kepala" }, { "Body", "Badan" }, { "Random", "Acak" },
})
toggle(pageAim, "Prioritas target", "PriorityOn")
cycle(pageAim, "Mode prioritas", "PriorityMode", {
	{ "Crosshair", "Crosshair" }, { "Jarak", "Terdekat" }, { "Darah", "Darah rendah" },
})
section(pageAim, "Prediksi")
toggle(pageAim, "Prediksi gerakan", "PredictOn")
stepper(pageAim, "Kekuatan (dtk)", "Predict", 0.05, 0.05, 0.5)

---------------- TAB ESP ----------------
section(pageEsp, "ESP (hijau = teman, merah = musuh)")
toggle(pageEsp, "ESP", "Esp", function()
	if not S.Esp then clearEsp() end
end)
toggle(pageEsp, "Nama & jarak", "EspName")

---------------- TAB PENGATURAN ----------------
section(pageSet, "Jarak")
toggle(pageSet, "Batas jarak", "MaxDistOn")
stepper(pageSet, "Jarak maks", "MaxDist", 50, 50, 1000)
section(pageSet, "Umum")
toggle(pageSet, "Mode NPC", "Npc")
section(pageSet, "Tombol AIM")
stepper(pageSet, "Ukuran", "BtnSize", 10, 50, 140, applyAimBtn)
cycle(pageSet, "Posisi", "BtnSide", { { "Kanan", "Kanan" }, { "Kiri", "Kiri" } }, applyAimBtn)
section(pageSet, "Player (ketuk: AUTO / TEMAN / MUSUH)")

local rows = {} -- [Player] = TextButton

local function refreshRow(plr)
	local b = rows[plr]
	if not b then return end
	local friend = isFriend(plr)
	local mode = (manual[plr.UserId] == nil) and "AUTO" or "MANUAL"
	local text = plr.Name .. "  -  " .. (friend and "TEMAN" or "MUSUH") .. " (" .. mode .. ")"
	if b.Text ~= text then
		b.Text = text
		b.BackgroundColor3 = friend and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(130, 45, 45)
	end
end

local function addRow(plr)
	if plr == player or rows[plr] then return end
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 30)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 11
	b.TextColor3 = WHITE
	b.TextTruncate = Enum.TextTruncate.AtEnd
	b.LayoutOrder = nextOrder()
	b.Parent = pageSet
	corner(b, 8)
	rows[plr] = b
	b.MouseButton1Click:Connect(function()
		local o = manual[plr.UserId]
		if o == nil then manual[plr.UserId] = true
		elseif o == true then manual[plr.UserId] = false
		else manual[plr.UserId] = nil end
		refreshRow(plr)
	end)
	refreshRow(plr)
end

for _, plr in ipairs(Players:GetPlayers()) do addRow(plr) end
Players.PlayerAdded:Connect(addRow)

task.spawn(function()
	while true do
		if main.Visible and pageSet.Visible then
			for plr in pairs(rows) do refreshRow(plr) end
		end
		task.wait(1)
	end
end)

-- Tombol AIM (tahan)
aimBtn = Instance.new("TextButton")
aimBtn.BackgroundColor3 = Color3.fromRGB(190, 60, 60)
aimBtn.Text = "AIM"
aimBtn.Font = Enum.Font.GothamBold
aimBtn.TextSize = 18
aimBtn.TextColor3 = WHITE
aimBtn.Visible = false
aimBtn.Parent = gui
corner(aimBtn, 9999)

setTab("AIM")
updateCircle()
applyAimBtn()
refreshHud()

----------------------------------------------------------------
-- PENCARIAN TARGET (dibatasi interval) + warna FOV dinamis
----------------------------------------------------------------
local candidate = nil
local searchTimer = 0

RunService.Heartbeat:Connect(function(dt)
	searchTimer += dt
	if searchTimer < SEARCH_INTERVAL then return end
	searchTimer = 0
	camera = workspace.CurrentCamera

	if not S.Enabled then
		candidate = nil
		stroke.Color = WHITE
		return
	end
	candidate = getBestTarget()
	stroke.Color = candidate and RED or WHITE
end)

----------------------------------------------------------------
-- ESP LOOP
----------------------------------------------------------------
local espTimer = 0
RunService.Heartbeat:Connect(function(dt)
	espTimer += dt
	if espTimer < ESP_INTERVAL then return end
	espTimer = 0

	if not S.Esp then
		if next(espObjs) then clearEsp() end
		return
	end

	local seen = {}
	for _, e in ipairs(getEntities()) do
		local char = e.char
		local hum = char:FindFirstChildOfClass("Humanoid")
		local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")

		if hum and hum.Health > 0 and part and inRange(part.Position) then
			seen[char] = true
			local friend = e.plr ~= nil and isFriend(e.plr)
			local color = friend and GREEN or RED

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
				o.nameL.TextColor3 = color
			end

			o.bb.Enabled = S.EspName
			if S.EspName then
				local t = e.name .. " [" .. math.floor(worldDist(part.Position)) .. "m]"
				if o.nameL.Text ~= t then o.nameL.Text = t end
			end
		end
	end

	for char in pairs(espObjs) do
		if not seen[char] then removeEsp(char) end
	end
end)

----------------------------------------------------------------
-- LOGIKA AIM (kamera TPP bawaan map tetap dipakai)
----------------------------------------------------------------
local holding = false
local target = nil       -- entity {char, plr, name}
local lockMode = "Head"
local lastWall, wallOk = 0, true

local aimLook = nil      -- arah pandang hasil smoothing
local rotHum = nil       -- humanoid yang AutoRotate-nya kita matikan

local function releaseAim()
	aimLook = nil
	if rotHum then
		rotHum.AutoRotate = true
		rotHum = nil
	end
end

local function setTarget(e)
	target = e
	wallOk = true
	lastWall = os.clock()
	if S.PartMode == "Random" then
		lockMode = (math.random() < 0.5) and "Head" or "Body"
	else
		lockMode = S.PartMode
	end
end

local function targetValid(t, now)
	local char = t.char
	if not (char.Parent and isAlive(char)) then return false end
	if t.plr then
		if not isEnemy(t.plr) then return false end
	elseif not S.Npc then
		return false
	end
	local part = scorePart(char)
	if not part then return false end
	local d = screenDist(part)
	if not d or d > S.Fov * 1.5 then return false end
	if not inRange(part.Position) then return false end
	if S.WallCheck then
		if now - lastWall >= WALL_INTERVAL then
			lastWall = now
			wallOk = isVisible(part)
		end
		return wallOk
	end
	return true
end

aimBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		holding = true
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				holding = false
				target = nil
			end
		end)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if rows[plr] then
		rows[plr]:Destroy()
		rows[plr] = nil
	end
	if plr.Character then removeEsp(plr.Character) end
	manual[plr.UserId] = nil
	if target and target.plr == plr then target = nil end
end)

RunService:BindToRenderStep("AimAssist", Enum.RenderPriority.Camera.Value + 1, function(dt)
	camera = workspace.CurrentCamera

	if not S.Enabled or not (S.AutoAim or holding) then
		target = nil
		releaseAim()
		return
	end

	local now = os.clock()

	if target and not targetValid(target, now) then target = nil end

	if (not target or not S.TargetLock) and candidate then
		if not target or target.char ~= candidate.char then
			setTarget(candidate)
		end
	end

	local part = target and partFor(target.char, lockMode)
	if not part then
		releaseAim()
		return
	end

	local aimPos = part.Position
	if S.PredictOn then
		aimPos += part.AssemblyLinearVelocity * S.Predict
	end

	local useCam = S.AimMode ~= "Character"
	local useChar = S.AimMode ~= "Camera"

	-- Kamera: posisi tetap dari kamera TPP map, hanya arah pandang yang diarahkan
	if useCam then
		local camPos = camera.CFrame.Position
		local to = aimPos - camPos
		if to.Magnitude > 0.01 then
			if not aimLook then aimLook = camera.CFrame.LookVector end
			local alpha = 1 - (1 - 1 / S.Smooth) ^ (dt * 60)
			local look = aimLook:Lerp(to.Unit, alpha)
			if look.Magnitude > 0.001 then aimLook = look.Unit end
			camera.CFrame = CFrame.lookAt(camPos, camPos + aimLook)
		end
	else
		aimLook = nil
	end

	-- Karakter: badan menghadap lawan (kamera tidak disentuh)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if useChar and root and hum then
		if not rotHum then
			rotHum = hum
			hum.AutoRotate = false
		end
		local flat = Vector3.new(aimPos.X, root.Position.Y, aimPos.Z)
		if (flat - root.Position).Magnitude > 0.05 then
			root.CFrame = CFrame.lookAt(root.Position, flat)
		end
	elseif rotHum then
		rotHum.AutoRotate = true
		rotHum = nil
	end
end)

----------------------------------------------------------------
-- MATI -> AIM OFF, RESPAWN -> AIM NYALA LAGI
----------------------------------------------------------------
local function hookDeath(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	hum.Died:Connect(function()
		if S.Enabled then
			resumeAim = true -- ingat bahwa tadi aktif
		end
		S.Enabled = false
		holding = false
		target = nil
		releaseAim()
		stroke.Color = WHITE
		if refreshers.Enabled then refreshers.Enabled() end
		refreshHud()
	end)
end

player.CharacterAdded:Connect(function(char)
	hookDeath(char)
	if resumeAim then
		resumeAim = false
		task.wait(0.5) -- tunggu karakter dan kamera siap
		S.Enabled = true
		if refreshers.Enabled then refreshers.Enabled() end
		refreshHud()
	end
end)

if player.Character then task.spawn(hookDeath, player.Character) end

print("[AimAssist] v6.5 loaded")
