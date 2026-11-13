--// Weapon Skin Preview (client-side only) - for your own Studio place
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local CFG = {
	-- folders (visible to the client) that hold your weapon skin models
	SkinFolders = {
		{ ReplicatedStorage, "WeaponSkins" },
		{ ReplicatedStorage, "Skins" },
		{ ReplicatedStorage, "Weapons" },
		{ ReplicatedStorage, "Shop" },
		{ ReplicatedStorage, "Cosmetics" },
	},
	MaxDepth = 3,
	MaxPreviews = 60,
}

local RARITY = {
	Common = Color3.fromRGB(160, 160, 172),
	Uncommon = Color3.fromRGB(80, 200, 120),
	Rare = Color3.fromRGB(70, 150, 255),
	Epic = Color3.fromRGB(180, 100, 255),
	Legendary = Color3.fromRGB(255, 190, 40),
	Mythic = Color3.fromRGB(255, 70, 90),
}

local S = { Mode = "Held", Cat = "All", Search = "", Previews = true }

local WHITE = Color3.new(1, 1, 1)
local C = {
	bg = Color3.fromRGB(20, 20, 25),
	card = Color3.fromRGB(32, 32, 40),
	view = Color3.fromRGB(24, 24, 32),
	stroke = Color3.fromRGB(60, 60, 80),
	accent = Color3.fromRGB(0, 140, 255),
	green = Color3.fromRGB(46, 160, 90),
	danger = Color3.fromRGB(200, 50, 50),
	off = Color3.fromRGB(45, 45, 55),
	text = Color3.fromRGB(225, 225, 235),
	sub = Color3.fromRGB(140, 140, 160),
}

----------------------------------------------------------------
-- HELPERS
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

local statusLabel, heldLabel
local function setStatus(t)
	if statusLabel then statusLabel.Text = t end
end

local function rarityOf(inst)
	local r = tostring(inst:GetAttribute("Rarity") or "Common")
	r = r:sub(1, 1):upper() .. r:sub(2):lower()
	return RARITY[r] and r or "Common"
end

----------------------------------------------------------------
-- SKIN LIST
----------------------------------------------------------------
local entries, cats = {}, {}

local function buildEntries()
	table.clear(entries)
	table.clear(cats)
	local seenCat = {}

	local function scan(parent, cat, depth)
		for _, c in ipairs(parent:GetChildren()) do
			if c:IsA("Tool") or c:IsA("Model") or c:IsA("BasePart") then
				entries[#entries + 1] = {
					id = c:GetFullName(), name = c.Name, cat = cat,
					rarity = rarityOf(c), inst = c,
				}
				if not seenCat[cat] then
					seenCat[cat] = true
					cats[#cats + 1] = cat
				end
			elseif c:IsA("Folder") and depth < CFG.MaxDepth then
				scan(c, depth == 1 and c.Name or cat, depth + 1)
			end
		end
	end

	for _, def in ipairs(CFG.SkinFolders) do
		local f = def[1]:FindFirstChild(def[2])
		if f then scan(f, f.Name, 1) end
	end
	table.sort(cats)
end

----------------------------------------------------------------
-- BUILD A VISUAL COPY OF A SKIN
----------------------------------------------------------------
local function makeContainer(src)
	local clone = src:Clone()
	for _, d in ipairs(clone:GetDescendants()) do
		if d:IsA("LuaSourceContainer") or d:IsA("Humanoid") then d:Destroy() end
	end

	local container
	if clone:IsA("Model") then
		container = clone
	else
		container = Instance.new("Model")
		if clone:IsA("Tool") then
			for _, ch in ipairs(clone:GetChildren()) do ch.Parent = container end
			clone:Destroy()
		else
			clone.Parent = container
		end
	end
	container.Name = "TKSkin"

	if not container.PrimaryPart then
		local h = container:FindFirstChild("Handle")
		if h and h:IsA("BasePart") then
			container.PrimaryPart = h
		else
			container.PrimaryPart = container:FindFirstChildWhichIsA("BasePart", true)
		end
	end
	return container
end

----------------------------------------------------------------
-- APPLY SKINS TO TOOLS (client only)
----------------------------------------------------------------
local skinFor = {}      -- [toolName] = entry
local globalSkin = nil  -- entry used for every weapon
local rotFor = {}       -- [toolName] = CFrame
local applied = {}      -- [tool] = {entry, rot, container, undo}

local function getEntry(tool)
	return skinFor[tool.Name] or globalSkin
end

local function heldTool()
	local c = player.Character
	return c and c:FindFirstChildOfClass("Tool")
end

local function forEachTool(fn)
	local bp = player:FindFirstChildOfClass("Backpack")
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") then fn(t) end
		end
	end
	local h = heldTool()
	if h then fn(h) end
end

local function removeFrom(tool)
	local a = applied[tool]
	if not a then return end
	for i = #a.undo, 1, -1 do pcall(a.undo[i]) end
	if a.container then a.container:Destroy() end
	applied[tool] = nil
end

local function applyTo(tool, entry)
	local rot = rotFor[tool.Name] or CFrame.identity
	local a = applied[tool]
	if a and a.entry == entry and a.rot == rot and a.container and a.container.Parent == tool then
		return true
	end
	removeFrom(tool)

	local handle = tool:FindFirstChild("Handle")
	if not (handle and handle:IsA("BasePart")) then
		handle = tool:FindFirstChildWhichIsA("BasePart", true)
	end
	if not handle then return false end
	if not (entry.inst and entry.inst.Parent) then return false end

	local container = makeContainer(entry.inst)
	if not container:FindFirstChildWhichIsA("BasePart", true) then
		container:Destroy()
		return false
	end

	-- hide the original look (undo restores it)
	local undo = {}
	for _, d in ipairs(tool:GetDescendants()) do
		if d:IsA("BasePart") then
			local old = d.Transparency
			d.Transparency = 1
			undo[#undo + 1] = function() d.Transparency = old end
		end
	end

	container:PivotTo(handle.CFrame * rot)
	for _, d in ipairs(container:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = false
			d.Massless = true
			d.CanCollide = false
			d.CanTouch = false
			d.CanQuery = false
			local w = Instance.new("Weld")
			w.Part0 = handle
			w.Part1 = d
			w.C0 = handle.CFrame:ToObjectSpace(d.CFrame)
			w.C1 = CFrame.new()
			w.Parent = d
		end
	end
	container.Parent = tool

	applied[tool] = { entry = entry, rot = rot, container = container, undo = undo }
	return true
end

local render -- forward declaration
local renderQueued = false
local function queueRender()
	if renderQueued then return end
	renderQueued = true
	task.defer(function()
		renderQueued = false
		if render then render() end
	end)
end

local function refreshAll()
	forEachTool(function(tool)
		local e = getEntry(tool)
		if e then applyTo(tool, e) else removeFrom(tool) end
	end)
end

local function selectedEntry()
	local h = heldTool()
	if h then return getEntry(h) end
	return globalSkin
end

local function chooseSkin(e)
	if S.Mode == "All" then
		table.clear(skinFor)
		globalSkin = e
		refreshAll()
		setStatus("All weapons now use: " .. e.name .. "  (only you can see this)")
	else
		local h = heldTool()
		if not h then
			setStatus("Hold a weapon first, then pick a skin.")
			return
		end
		skinFor[h.Name] = e
		if not applyTo(h, e) then
			skinFor[h.Name] = nil
			setStatus("Couldn't apply '" .. e.name .. "' (no parts inside?).")
			return
		end
		setStatus(h.Name .. " now uses: " .. e.name .. "  (only you can see this)")
	end
end

local function removeSkin()
	if S.Mode == "All" then
		globalSkin = nil
		table.clear(skinFor)
	else
		local h = heldTool()
		if not h then
			setStatus("Hold a weapon first.")
			return
		end
		skinFor[h.Name] = nil
	end
	refreshAll()
	setStatus("Skin removed.")
end

local function resetAll()
	globalSkin = nil
	table.clear(skinFor)
	table.clear(rotFor)
	forEachTool(removeFrom)
	setStatus("Everything reset to the original look.")
end

local function rotateHeld(axis)
	local h = heldTool()
	if not h then
		setStatus("Hold a weapon first.")
		return
	end
	local e = getEntry(h)
	if not e then
		setStatus("Pick a skin for this weapon first.")
		return
	end
	local r = math.rad(90)
	local step = CFrame.Angles(axis == "X" and r or 0, axis == "Y" and r or 0, axis == "Z" and r or 0)
	rotFor[h.Name] = step * (rotFor[h.Name] or CFrame.identity)
	applyTo(h, e)
	setStatus("Rotated " .. axis .. " 90°.")
end

local function resetRotation()
	local h = heldTool()
	if h then
		rotFor[h.Name] = nil
		local e = getEntry(h)
		if e then applyTo(h, e) end
		setStatus("Rotation reset.")
	end
end

----------------------------------------------------------------
-- TOOL WATCHING (new tools after respawn get the skin too)
----------------------------------------------------------------
local function onTool(tool)
	task.spawn(function()
		tool:WaitForChild("Handle", 3)
		local e = getEntry(tool)
		if e and tool.Parent then applyTo(tool, e) end
		queueRender()
	end)
end

local function hookCharacter(char)
	for _, c in ipairs(char:GetChildren()) do
		if c:IsA("Tool") then onTool(c) end
	end
	char.ChildAdded:Connect(function(c)
		if c:IsA("Tool") then onTool(c) end
		queueRender()
	end)
	char.ChildRemoved:Connect(function(c)
		if c:IsA("Tool") then queueRender() end
	end)

	local bp = player:WaitForChild("Backpack", 5)
	if bp then
		for _, c in ipairs(bp:GetChildren()) do
			if c:IsA("Tool") then onTool(c) end
		end
		bp.ChildAdded:Connect(function(c)
			if c:IsA("Tool") then onTool(c) end
		end)
	end
end

player.CharacterAdded:Connect(function(char)
	table.clear(applied) -- old tools are gone
	hookCharacter(char)
	queueRender()
end)
if player.Character then task.spawn(hookCharacter, player.Character) end

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local gui = new("ScreenGui", {
	Name = "WeaponSkinUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, player:WaitForChild("PlayerGui"))

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

local main = new("Frame", {
	Size = UDim2.fromOffset(332, 426),
	Position = UDim2.fromOffset(70, 30),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	Visible = false,
}, gui)
corner(main, 12)
new("UIStroke", { Color = C.stroke, Thickness = 1 }, main)

local logo = new("TextButton", {
	Size = UDim2.fromOffset(46, 46),
	Position = UDim2.fromOffset(14, 120),
	BackgroundColor3 = Color3.fromRGB(25, 25, 35),
	Text = "⚔",
	TextSize = 22,
	Font = Enum.Font.GothamBold,
	TextColor3 = WHITE,
	AutoButtonColor = false,
}, gui)
corner(logo, 23)
new("UIStroke", { Color = C.accent, Thickness = 2 }, logo)

local function setOpen(v) main.Visible = v end
makeDraggable(logo, logo, function() setOpen(not main.Visible) end)

UIS.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.RightControl then setOpen(not main.Visible) end
end)

-- header
local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 34),
	BackgroundTransparency = 1,
	Active = true,
}, main)
new("TextLabel", {
	Size = UDim2.new(1, -50, 1, 0),
	Position = UDim2.fromOffset(14, 0),
	BackgroundTransparency = 1,
	Text = "⋮⋮  WEAPON SKINS",
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = WHITE,
}, header)
local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(26, 26),
	Position = UDim2.new(1, -32, 0, 4),
	BackgroundColor3 = C.danger,
	Text = "X",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = WHITE,
	AutoButtonColor = false,
}, header)
corner(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)
makeDraggable(header, main, nil)

heldLabel = new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 16),
	Position = UDim2.fromOffset(8, 34),
	BackgroundTransparency = 1,
	Text = "Holding: nothing",
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.sub,
}, main)

local search = new("TextBox", {
	Size = UDim2.new(1, -16, 0, 26),
	Position = UDim2.fromOffset(8, 54),
	BackgroundColor3 = C.card,
	TextColor3 = C.text,
	PlaceholderText = "Search skins...",
	PlaceholderColor3 = C.sub,
	Text = "",
	ClearTextOnFocus = false,
	Font = Enum.Font.Gotham,
	TextSize = 12,
}, main)
corner(search, 8)

-- category chips (scroll sideways)
local chipRow = new("ScrollingFrame", {
	Size = UDim2.new(1, -16, 0, 24),
	Position = UDim2.fromOffset(8, 84),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 0,
	ScrollingDirection = Enum.ScrollingDirection.X,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.X,
}, main)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, chipRow)

-- skin grid
local grid = new("ScrollingFrame", {
	Size = UDim2.new(1, -16, 0, 176),
	Position = UDim2.fromOffset(8, 112),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = C.accent,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
new("UIGridLayout", {
	CellSize = UDim2.new(1 / 3, -5, 0, 92),
	CellPadding = UDim2.fromOffset(6, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, grid)
new("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }, grid)

local emptyLabel = new("TextLabel", {
	Size = UDim2.new(1, -24, 0, 60),
	Position = UDim2.fromOffset(12, 140),
	BackgroundTransparency = 1,
	Text = "",
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextWrapped = true,
	TextColor3 = C.sub,
	Visible = false,
}, main)

local function fillViewport(vp, entry)
	local container = makeContainer(entry.inst)
	if not container:FindFirstChildWhichIsA("BasePart", true) then
		container:Destroy()
		return
	end
	container.Parent = vp
	local cf, size = container:GetBoundingBox()
	local cam = new("Camera", { FieldOfView = 40 }, vp)
	vp.CurrentCamera = cam
	local dist = (size.Magnitude / 2) / math.tan(math.rad(20)) * 1.05
	local center = cf.Position
	cam.CFrame = CFrame.lookAt(center + Vector3.new(1, 0.45, 1).Unit * dist, center)
end

render = function()
	for _, c in ipairs(grid:GetChildren()) do
		if c:IsA("GuiButton") then c:Destroy() end
	end

	local h = heldTool()
	heldLabel.Text = "Holding: " .. (h and h.Name or "nothing")
		.. "   |   Mode: " .. (S.Mode == "All" and "ALL weapons" or "HELD weapon")
	heldLabel.TextColor3 = h and C.green or C.sub

	local sel = selectedEntry()
	local q = S.Search
	local shown, previews = 0, 0

	for _, e in ipairs(entries) do
		local catOk = (S.Cat == "All") or (S.Cat == e.cat)
		local nameOk = (q == "") or (e.name:lower():find(q, 1, true) ~= nil)
		if catOk and nameOk then
			shown += 1
			local selected = sel ~= nil and sel.id == e.id
			local rc = RARITY[e.rarity]

			local card = new("TextButton", {
				BackgroundColor3 = C.card,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = shown,
			}, grid)
			corner(card, 8)
			new("UIStroke", {
				Color = selected and C.green or rc,
				Thickness = selected and 2.5 or 1.2,
				Transparency = selected and 0 or 0.35,
			}, card)

			local vp = new("ViewportFrame", {
				Size = UDim2.new(1, -8, 0, 56),
				Position = UDim2.fromOffset(4, 4),
				BackgroundColor3 = C.view,
				BorderSizePixel = 0,
			}, card)
			corner(vp, 6)
			if S.Previews and previews < CFG.MaxPreviews then
				previews += 1
				pcall(fillViewport, vp, e)
			end

			new("TextLabel", {
				Size = UDim2.new(1, -8, 0, 14),
				Position = UDim2.fromOffset(4, 62),
				BackgroundTransparency = 1,
				Text = e.name,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = C.text,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, card)
			new("TextLabel", {
				Size = UDim2.new(1, -8, 0, 12),
				Position = UDim2.fromOffset(4, 77),
				BackgroundTransparency = 1,
				Text = selected and "● EQUIPPED" or e.rarity:upper(),
				Font = Enum.Font.GothamBold,
				TextSize = 9,
				TextColor3 = selected and C.green or rc,
			}, card)

			card.MouseButton1Click:Connect(function()
				if selected and S.Mode == "Held" then
					removeSkin()
				else
					chooseSkin(e)
				end
				render()
			end)
		end
	end

	emptyLabel.Visible = (shown == 0)
	if shown == 0 then
		emptyLabel.Text = (#entries == 0)
			and "No skins found.\nPut skin models (Tool / Model / MeshPart) in\nReplicatedStorage > WeaponSkins."
			or "No skins match your search."
	end
end

-- chips
local chipBtns = {}
local function refreshChips()
	for name, b in pairs(chipBtns) do
		local sel = (name == S.Cat)
		b.BackgroundColor3 = sel and C.accent or C.card
		b.TextColor3 = sel and WHITE or C.sub
	end
end

local function buildChips()
	for _, c in ipairs(chipRow:GetChildren()) do
		if c:IsA("GuiButton") then c:Destroy() end
	end
	table.clear(chipBtns)
	local list = { "All" }
	for _, c in ipairs(cats) do list[#list + 1] = c end
	if not table.find(list, S.Cat) then S.Cat = "All" end

	for i, name in ipairs(list) do
		local b = new("TextButton", {
			Size = UDim2.fromOffset(math.max(52, #name * 8 + 18), 24),
			BackgroundColor3 = C.card,
			Text = name:upper(),
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextColor3 = C.sub,
			AutoButtonColor = false,
			LayoutOrder = i,
		}, chipRow)
		corner(b, 7)
		chipBtns[name] = b
		b.MouseButton1Click:Connect(function()
			S.Cat = name
			refreshChips()
			render()
		end)
	end
	refreshChips()
end

search:GetPropertyChangedSignal("Text"):Connect(function()
	S.Search = string.lower(search.Text)
	render()
end)

-- rotation row
local rotRow = new("Frame", {
	Size = UDim2.new(1, -16, 0, 26),
	Position = UDim2.fromOffset(8, 292),
	BackgroundTransparency = 1,
}, main)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, rotRow)

local function smallBtn(parent, text, color, ord, fn, widthScale)
	local b = new("TextButton", {
		Size = UDim2.new(widthScale, -3, 1, 0),
		BackgroundColor3 = color,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = WHITE,
		AutoButtonColor = false,
		LayoutOrder = ord,
	}, parent)
	corner(b, 7)
	b.MouseButton1Click:Connect(fn)
	return b
end
smallBtn(rotRow, "↻ X", C.off, 1, function() rotateHeld("X") end, 0.2)
smallBtn(rotRow, "↻ Y", C.off, 2, function() rotateHeld("Y") end, 0.2)
smallBtn(rotRow, "↻ Z", C.off, 3, function() rotateHeld("Z") end, 0.2)
smallBtn(rotRow, "Reset rotation", C.off, 4, resetRotation, 0.4)

-- mode + previews
local modeRow = new("Frame", {
	Size = UDim2.new(1, -16, 0, 26),
	Position = UDim2.fromOffset(8, 322),
	BackgroundTransparency = 1,
}, main)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, modeRow)

local modeHeld, modeAll, prevBtn
local function refreshOpts()
	modeHeld.BackgroundColor3 = (S.Mode == "Held") and C.accent or C.off
	modeAll.BackgroundColor3 = (S.Mode == "All") and C.accent or C.off
	prevBtn.Text = "Previews: " .. (S.Previews and "ON" or "OFF")
	prevBtn.BackgroundColor3 = S.Previews and C.green or C.off
end
modeHeld = smallBtn(modeRow, "Held weapon", C.off, 1, function()
	S.Mode = "Held"
	refreshOpts()
	render()
end, 0.34)
modeAll = smallBtn(modeRow, "All weapons", C.off, 2, function()
	S.Mode = "All"
	refreshOpts()
	render()
end, 0.33)
prevBtn = smallBtn(modeRow, "", C.off, 3, function()
	S.Previews = not S.Previews
	refreshOpts()
	render()
end, 0.33)

-- actions
local actRow = new("Frame", {
	Size = UDim2.new(1, -16, 0, 30),
	Position = UDim2.fromOffset(8, 354),
	BackgroundTransparency = 1,
}, main)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, actRow)
smallBtn(actRow, "Remove skin", C.danger, 1, function()
	removeSkin()
	render()
end, 0.34)
smallBtn(actRow, "Reset all", C.danger, 2, function()
	resetAll()
	render()
end, 0.33)
smallBtn(actRow, "⟳ Refresh", C.accent, 3, function()
	buildEntries()
	buildChips()
	render()
	setStatus("List refreshed: " .. #entries .. " skins.")
end, 0.33)

statusLabel = new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 30),
	Position = UDim2.fromOffset(8, 390),
	BackgroundTransparency = 1,
	Text = "Preview only: other players won't see your skin.",
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextWrapped = true,
	TextColor3 = C.sub,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, main)

----------------------------------------------------------------
-- START
----------------------------------------------------------------
refreshOpts()
buildEntries()
buildChips()
render()
setOpen(true)

-- shop folders can replicate a moment late: rescan once
task.delay(1.5, function()
	buildEntries()
	buildChips()
	render()
  end)
