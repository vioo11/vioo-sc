--// Weapon Skin Preview v2 (client-side only) - for your own Studio place
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
	-- folders (visible to the client) holding your skins. Every Tool / Model / MeshPart = one skin.
	SkinFolders = {
		{ ReplicatedStorage, "WeaponSkins" },
		{ ReplicatedStorage, "Skins" },
		{ ReplicatedStorage, "Weapons" },
		{ ReplicatedStorage, "Shop" },
	},
	MaxDepth = 4,
	MaxPreviews = 60,
}

local RARITY_ORDER = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }
local RARITY = {
	Common = Color3.fromRGB(160, 160, 172),
	Uncommon = Color3.fromRGB(80, 200, 120),
	Rare = Color3.fromRGB(70, 150, 255),
	Epic = Color3.fromRGB(180, 100, 255),
	Legendary = Color3.fromRGB(255, 190, 40),
	Mythic = Color3.fromRGB(255, 70, 90),
}

-- Mode "All"  = the chosen skin follows ANY weapon you hold
-- Mode "Held" = the chosen skin is saved only for the weapon you hold right now
local S = { Mode = "All", Rarity = "All", Search = "", Previews = true }

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

local statusLabel
local function setStatus(t)
	if statusLabel then statusLabel.Text = t end
end

local function rarityOf(inst)
	local r = tostring(inst:GetAttribute("Rarity") or "Common")
	r = r:sub(1, 1):upper() .. r:sub(2):lower()
	return RARITY[r] and r or "Common"
end

local function rarityRank(r)
	return table.find(RARITY_ORDER, r) or 1
end

----------------------------------------------------------------
-- SKIN LIST (flat: one entry = one skin)
----------------------------------------------------------------
local entries = {}

local function buildEntries()
	table.clear(entries)
	local seen = {}

	local function scan(parent, depth)
		for _, c in ipairs(parent:GetChildren()) do
			if c:IsA("Tool") or c:IsA("Model") or c:IsA("BasePart") then
				local id = c:GetFullName()
				if not seen[id] then
					seen[id] = true
					entries[#entries + 1] = {
						id = id,
						name = tostring(c:GetAttribute("DisplayName") or c.Name),
						rarity = rarityOf(c),
						inst = c,
					}
				end
			elseif c:IsA("Folder") and depth < CFG.MaxDepth then
				scan(c, depth + 1)
			end
		end
	end

	for _, def in ipairs(CFG.SkinFolders) do
		local f = def[1]:FindFirstChild(def[2])
		if f then scan(f, 1) end
	end

	table.sort(entries, function(a, b)
		local ra, rb = rarityRank(a.rarity), rarityRank(b.rarity)
		if ra ~= rb then return ra > rb end
		return a.name < b.name
	end)
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
-- APPLY SKINS ON YOUR TOOLS (client only)
----------------------------------------------------------------
local skinFor = {}      -- [toolName] = entry   (Mode "Held")
local globalSkin = nil  -- entry used for every weapon (Mode "All")
local rotFor = {}       -- [toolName] = CFrame  (manual rotation fix)
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

	-- hide the base weapon's own look (undo restores it)
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

local refreshUI -- forward declaration
local uiQueued = false
local function queueUI()
	if uiQueued then return end
	uiQueued = true
	task.defer(function()
		uiQueued = false
		if refreshUI then refreshUI() end
	end)
end

local function refreshAllTools()
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
		refreshAllTools()
		setStatus("Equipped: " .. e.name .. " on any weapon you hold. (only you can see this)")
	else
		local h = heldTool()
		if not h then
			setStatus("Hold a weapon first, then equip.")
			return
		end
		skinFor[h.Name] = e
		if not applyTo(h, e) then
			skinFor[h.Name] = nil
			setStatus("Couldn't apply '" .. e.name .. "' (no parts inside?).")
			return
		end
		setStatus(h.Name .. " now looks like: " .. e.name .. " (only you can see this)")
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
	refreshAllTools()
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
		setStatus("Equip a skin first.")
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
-- TOOL WATCHING (tools picked up / respawned get the skin too)
----------------------------------------------------------------
local function onTool(tool)
	task.spawn(function()
		tool:WaitForChild("Handle", 3)
		local e = getEntry(tool)
		if e and tool.Parent then applyTo(tool, e) end
		queueUI()
	end)
end

local function hookCharacter(char)
	for _, c in ipairs(char:GetChildren()) do
		if c:IsA("Tool") then onTool(c) end
	end
	char.ChildAdded:Connect(function(c)
		if c:IsA("Tool") then onTool(c) end
		queueUI()
	end)
	char.ChildRemoved:Connect(function(c)
		if c:IsA("Tool") then queueUI() end
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
	queueUI()
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

local BASE_H = 482
local main = new("Frame", {
	Size = UDim2.fromOffset(332, BASE_H),
	Position = UDim2.fromOffset(70, 10),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	Visible = false,
}, gui)
corner(main, 12)
new("UIStroke", { Color = C.stroke, Thickness = 1 }, main)
local mainScale = new("UIScale", { Scale = 1 }, main)

local function applyScale()
	local vp = camera.ViewportSize
	mainScale.Scale = math.clamp((vp.Y - 20) / BASE_H, 0.55, 1)
end
applyScale()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)

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

local heldLabel = new("TextLabel", {
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

-- rarity chips
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
	Size = UDim2.new(1, -16, 0, 150),
	Position = UDim2.fromOffset(8, 112),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = C.accent,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
new("UIGridLayout", {
	CellSize = UDim2.new(1 / 3, -5, 0, 84),
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

-- preview panel (like the in-game inventory: big preview + name + EQUIP)
local panel = new("Frame", {
	Size = UDim2.new(1, -16, 0, 86),
	Position = UDim2.fromOffset(8, 266),
	BackgroundColor3 = C.card,
}, main)
corner(panel, 10)
local panelStroke = new("UIStroke", { Color = C.stroke, Thickness = 1.5 }, panel)

local panelVp = new("ViewportFrame", {
	Size = UDim2.fromOffset(112, 74),
	Position = UDim2.fromOffset(6, 6),
	BackgroundColor3 = C.view,
	BorderSizePixel = 0,
}, panel)
corner(panelVp, 8)

local panelName = new("TextLabel", {
	Size = UDim2.new(1, -132, 0, 22),
	Position = UDim2.fromOffset(126, 6),
	BackgroundTransparency = 1,
	Text = "Pick a skin",
	Font = Enum.Font.GothamBlack,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = WHITE,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, panel)
local panelRarity = new("TextLabel", {
	Size = UDim2.new(1, -132, 0, 14),
	Position = UDim2.fromOffset(126, 28),
	BackgroundTransparency = 1,
	Text = "",
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.sub,
}, panel)
local equipBtn = new("TextButton", {
	Size = UDim2.new(1, -132, 0, 32),
	Position = UDim2.fromOffset(126, 46),
	BackgroundColor3 = C.off,
	Text = "EQUIP",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = WHITE,
	AutoButtonColor = false,
}, panel)
corner(equipBtn, 8)

local picked = nil
local panelShown = nil

local function fillViewport(vp, entry)
	for _, ch in ipairs(vp:GetChildren()) do ch:Destroy() end
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

local cards = {} -- [id] = {stroke, tag, rc}

local function refreshHighlights()
	local sel = selectedEntry()
	for id, c in pairs(cards) do
		local equipped = sel ~= nil and sel.id == id
		local isPicked = picked ~= nil and picked.id == id
		c.stroke.Color = equipped and C.green or (isPicked and WHITE or c.rc)
		c.stroke.Thickness = (equipped or isPicked) and 2.5 or 1.2
		c.stroke.Transparency = (equipped or isPicked) and 0 or 0.35
		c.tag.Text = equipped and "● EQUIPPED" or c.rarityText
		c.tag.TextColor3 = equipped and C.green or c.rc
	end
end

local function updatePanel()
	if not picked then
		if panelShown then
			for _, ch in ipairs(panelVp:GetChildren()) do ch:Destroy() end
			panelShown = nil
		end
		panelName.Text = "Pick a skin"
		panelRarity.Text = ""
		panelStroke.Color = C.stroke
		equipBtn.Text = "EQUIP"
		equipBtn.BackgroundColor3 = C.off
		return
	end

	if panelShown ~= picked.id then
		panelShown = picked.id
		pcall(fillViewport, panelVp, picked)
	end
	local rc = RARITY[picked.rarity]
	panelName.Text = picked.name
	panelRarity.Text = picked.rarity:upper()
	panelRarity.TextColor3 = rc
	panelStroke.Color = rc

	local sel = selectedEntry()
	local on = sel ~= nil and sel.id == picked.id
	equipBtn.Text = on and "UNEQUIP" or "EQUIP"
	equipBtn.BackgroundColor3 = on and C.danger or C.green
end

local function updateHeld()
	local h = heldTool()
	heldLabel.Text = "Holding: " .. (h and h.Name or "nothing")
		.. "   |   " .. (S.Mode == "All" and "Skin follows ANY weapon" or "Skin for THIS weapon only")
	heldLabel.TextColor3 = h and C.green or C.sub
end

refreshUI = function()
	updateHeld()
	refreshHighlights()
	updatePanel()
end

local function render()
	for _, c in ipairs(grid:GetChildren()) do
		if c:IsA("GuiButton") then c:Destroy() end
	end
	table.clear(cards)

	local q = S.Search
	local shown, previews = 0, 0

	for _, e in ipairs(entries) do
		local rarOk = (S.Rarity == "All") or (S.Rarity == e.rarity)
		local nameOk = (q == "") or (e.name:lower():find(q, 1, true) ~= nil)
		if rarOk and nameOk then
			shown += 1
			local rc = RARITY[e.rarity]

			local card = new("TextButton", {
				BackgroundColor3 = C.card,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = shown,
			}, grid)
			corner(card, 8)
			local st = new("UIStroke", { Color = rc, Thickness = 1.2, Transparency = 0.35 }, card)

			local vp = new("ViewportFrame", {
				Size = UDim2.new(1, -8, 0, 50),
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
				Position = UDim2.fromOffset(4, 55),
				BackgroundTransparency = 1,
				Text = e.name,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = C.text,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, card)
			local tag = new("TextLabel", {
				Size = UDim2.new(1, -8, 0, 12),
				Position = UDim2.fromOffset(4, 69),
				BackgroundTransparency = 1,
				Text = e.rarity:upper(),
				Font = Enum.Font.GothamBold,
				TextSize = 9,
				TextColor3 = rc,
			}, card)

			cards[e.id] = { stroke = st, tag = tag, rc = rc, rarityText = e.rarity:upper() }

			card.MouseButton1Click:Connect(function()
				picked = e
				refreshUI()
			end)
		end
	end

	emptyLabel.Visible = (shown == 0)
	if shown == 0 then
		emptyLabel.Text = (#entries == 0)
			and "No skins found.\nPut skin models (Tool / Model / MeshPart) in\nReplicatedStorage > WeaponSkins."
			or "No skins match your search."
	end
	refreshUI()
end

-- rarity chips
local chipBtns = {}
local function refreshChips()
	for name, b in pairs(chipBtns) do
		local sel = (name == S.Rarity)
		b.BackgroundColor3 = sel and C.accent or C.card
		b.TextColor3 = sel and WHITE or (RARITY[name] or C.sub)
	end
end

local function buildChips()
	for _, c in ipairs(chipRow:GetChildren()) do
		if c:IsA("GuiButton") then c:Destroy() end
	end
	table.clear(chipBtns)

	local has = {}
	for _, e in ipairs(entries) do has[e.rarity] = true end
	local list = { "All" }
	for _, r in ipairs(RARITY_ORDER) do
		if has[r] then list[#list + 1] = r end
	end
	if not table.find(list, S.Rarity) then S.Rarity = "All" end

	for i, name in ipairs(list) do
		local b = new("TextButton", {
			Size = UDim2.fromOffset(math.max(48, #name * 8 + 16), 24),
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
			S.Rarity = name
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

-- EQUIP / UNEQUIP
equipBtn.MouseButton1Click:Connect(function()
	if not picked then
		setStatus("Tap a skin first.")
		return
	end
	local sel = selectedEntry()
	if sel ~= nil and sel.id == picked.id then
		removeSkin()
	else
		chooseSkin(picked)
	end
	refreshUI()
end)

-- small button helper
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

local function row(y, h)
	local f = new("Frame", {
		Size = UDim2.new(1, -16, 0, h),
		Position = UDim2.fromOffset(8, y),
		BackgroundTransparency = 1,
	}, main)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, f)
	return f
end

-- rotation row
local rotRow = row(358, 24)
smallBtn(rotRow, "↻ X", C.off, 1, function() rotateHeld("X") end, 0.2)
smallBtn(rotRow, "↻ Y", C.off, 2, function() rotateHeld("Y") end, 0.2)
smallBtn(rotRow, "↻ Z", C.off, 3, function() rotateHeld("Z") end, 0.2)
smallBtn(rotRow, "Reset rotation", C.off, 4, resetRotation, 0.4)

-- mode row
local modeRow = row(386, 26)
local modeAll, modeHeld, prevBtn
local function refreshOpts()
	modeAll.BackgroundColor3 = (S.Mode == "All") and C.accent or C.off
	modeHeld.BackgroundColor3 = (S.Mode == "Held") and C.accent or C.off
	prevBtn.Text = "Previews: " .. (S.Previews and "ON" or "OFF")
	prevBtn.BackgroundColor3 = S.Previews and C.green or C.off
end
modeAll = smallBtn(modeRow, "Any weapon", C.off, 1, function()
	S.Mode = "All"
	refreshOpts()
	refreshUI()
end, 0.34)
modeHeld = smallBtn(modeRow, "This weapon only", C.off, 2, function()
	S.Mode = "Held"
	refreshOpts()
	refreshUI()
end, 0.33)
prevBtn = smallBtn(modeRow, "", C.off, 3, function()
	S.Previews = not S.Previews
	refreshOpts()
	render()
end, 0.33)

-- action row
local actRow = row(416, 28)
smallBtn(actRow, "Remove skin", C.danger, 1, function()
	removeSkin()
	refreshUI()
end, 0.34)
smallBtn(actRow, "Reset all", C.danger, 2, function()
	resetAll()
	refreshUI()
end, 0.33)
smallBtn(actRow, "⟳ Refresh", C.accent, 3, function()
	buildEntries()
	buildChips()
	render()
	setStatus("List refreshed: " .. #entries .. " skins.")
end, 0.33)

statusLabel = new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 32),
	Position = UDim2.fromOffset(8, 448),
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

-- skin folders can replicate a moment late: rescan once
task.delay(1.5, function()
	buildEntries()
	buildChips()
	render()
end)
