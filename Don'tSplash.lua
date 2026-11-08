--// Toolkit v7.1 - for your own Studio place
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local LOGO_IMAGE = "rbxassetid://112323672996641"

----------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------
local S = {
	-- spawn
	AutoSpawn = true,
	ShowMarker = true,
	SideOn = false,
	-- player
	WalkOn = false,
	WalkSpeed = 32,
	CustomFov = false,
	Fov = 90,
	ZoomOn = false,
	Zoom = 200,
	-- esp master
	EspAll = false,
	-- esp player
	EspPlayer = false,
	PName = true,
	PDist = true,
	PTracer = false,
	PColor = 1,
	PLimitOn = false,
	PLimit = 500,
	-- esp monster
	EspMonster = false,
	MName = true,
	MDist = true,
	MTracer = false,
	MColor = 2,
	MRealName = false,
	MLimitOn = false,
	MLimit = 500,
	MonsterFilter = "",
	-- esp item
	EspItem = false,
	IName = true,
	IDist = true,
	ITracer = false,
	IColor = 4,
	IRealName = false, -- default: label says "Item"
	ILimitOn = false,
	ILimit = 300,
	ItemFilter = "",
	ItemMode = "auto", -- auto / small / learned
	ItemMerge = true,
	ItemMergeDist = 8,
	-- visual
	NoFog = false,
	Fullbright = false,
	TimeOn = false,
	Clock = 14,
	BrightOn = false,
	Bright = 2,
	NoShadow = false,
	NoEffects = false,
	ClearSky = false,
	-- general
	Style = "fill",
	Locked = false,
	UiScale = 1,
	Opacity = 0,
}

local COLORS = {
	{ "Green", Color3.fromRGB(60, 255, 90) },
	{ "Red", Color3.fromRGB(255, 60, 60) },
	{ "Blue", Color3.fromRGB(70, 150, 255) },
	{ "Yellow", Color3.fromRGB(255, 220, 50) },
	{ "Purple", Color3.fromRGB(180, 100, 255) },
	{ "Orange", Color3.fromRGB(255, 150, 40) },
	{ "White", Color3.fromRGB(245, 245, 245) },
}

local MONSTER_WORDS = { "monster", "enemy", "enemies", "mob", "zombie", "boss", "creature", "musuh", "npc" }
local ITEM_WORDS = {
	"item", "pickup", "loot", "coin", "key", "ammo", "medkit", "potion", "collect",
	"weapon", "gem", "chest", "orb", "ball", "bola", "sphere",
}
local PICK_WORDS = { "pick", "take", "ambil", "collect", "grab", "loot", "get", "equip" }
local MAX_ITEMS = 300
local MAX_LINES = 80
local PROXY_NAME = "TKClusterProxy"

local WHITE = Color3.new(1, 1, 1)
local C = {
	bg = Color3.fromRGB(20, 20, 25),
	card = Color3.fromRGB(30, 30, 38),
	stroke = Color3.fromRGB(60, 60, 80),
	off = Color3.fromRGB(40, 40, 48),
	offLine = Color3.fromRGB(65, 65, 75),
	knobOff = Color3.fromRGB(125, 125, 135),
	onBg = Color3.fromRGB(190, 30, 42),
	onLine = Color3.fromRGB(255, 65, 75),
	accent = Color3.fromRGB(0, 140, 255),
	green = Color3.fromRGB(46, 160, 90),
	danger = Color3.fromRGB(200, 50, 50),
	text = Color3.fromRGB(220, 220, 220),
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

local function outline(o, color, th, tr)
	return new("UIStroke", {
		Color = color, Thickness = th or 1, Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, o)
end

local function tween(o, props, t, style, dir)
	TweenService:Create(o, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad,
		dir or Enum.EasingDirection.Out), props):Play()
end

local function matchAny(s, words)
	for _, w in ipairs(words) do
		if s:find(w, 1, true) then return true end
	end
	return false
end

local function trim(s) return string.lower(s:match("^%s*(.-)%s*$")) end

----------------------------------------------------------------
-- SPAWN POINT
----------------------------------------------------------------
local saved = nil
local marker = nil
local spawnStatus -- assigned when the GUI is built

local function say(t)
	if spawnStatus then spawnStatus.Text = t end
end

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

local function getHum()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function teleportTo(cf)
	local char, root = player.Character, getRoot()
	if not (char and root) then return false end
	char:PivotTo(cf)
	root.AssemblyLinearVelocity = Vector3.zero
	return true
end

local function doSave()
	local r, hum = getRoot(), getHum()
	if not (r and hum and hum.Health > 0) then
		say("Can't save: character missing or dead.")
		return
	end
	saved = r.CFrame
	placeMarker(saved)
	local p = saved.Position
	say(string.format("Saved at (%d, %d, %d).", math.floor(p.X), math.floor(p.Y), math.floor(p.Z)))
end

local function doTeleport()
	if not saved then
		say("No spawn point saved.")
		return
	end
	if teleportTo(saved + Vector3.new(0, 3, 0)) then say("Teleported to spawn point.") end
end

local function doDelete()
	saved = nil
	removeMarker()
	say("Spawn point deleted. Respawning at the default spawn.")
end

----------------------------------------------------------------
-- PLAYER: WALKSPEED, FOV, ZOOM
----------------------------------------------------------------
local walkOrig, walkHum = nil, nil

local function restoreWalk()
	local hum = getHum()
	if hum then hum.WalkSpeed = walkOrig or 16 end
	walkOrig = nil
end

RunService.Heartbeat:Connect(function()
	local hum = getHum()
	if hum ~= walkHum then
		walkHum = hum
		walkOrig = nil
	end
	if S.WalkOn and hum then
		if not walkOrig then walkOrig = hum.WalkSpeed end
		if hum.WalkSpeed ~= S.WalkSpeed then hum.WalkSpeed = S.WalkSpeed end
	end
end)

local fovOrig = nil
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

local zoomOrig = nil
local function setZoom()
	if S.ZoomOn then
		zoomOrig = zoomOrig or player.CameraMaxZoomDistance
		player.CameraMaxZoomDistance = S.Zoom
	elseif zoomOrig then
		player.CameraMaxZoomDistance = zoomOrig
		zoomOrig = nil
	end
end

----------------------------------------------------------------
-- VISUAL (lighting, fog, screen effects)
----------------------------------------------------------------
local lightBase = nil
local atmoBase, effBase = {}, {}
local EFFECT_CLASSES = {
	"BlurEffect", "BloomEffect", "SunRaysEffect", "DepthOfFieldEffect", "ColorCorrectionEffect",
}

local function isEffect(o)
	for _, c in ipairs(EFFECT_CLASSES) do
		if o:IsA(c) then return true end
	end
	return false
end

local function anyLight()
	return S.NoFog or S.Fullbright or S.TimeOn or S.BrightOn
		or S.NoShadow or S.NoEffects or S.ClearSky
end

local function snapshotLight()
	lightBase = {
		Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
		Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
		GlobalShadows = Lighting.GlobalShadows,
		FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd,
	}
end

local function restoreLight()
	if lightBase then
		for k, v in pairs(lightBase) do Lighting[k] = v end
		lightBase = nil
	end
	for a, v in pairs(atmoBase) do
		if a.Parent then
			a.Density, a.Haze, a.Color, a.Decay, a.Glare = v.Density, v.Haze, v.Color, v.Decay, v.Glare
		end
	end
	table.clear(atmoBase)
	for e, v in pairs(effBase) do
		if e.Parent then e.Enabled = v end
	end
	table.clear(effBase)
end

local function applyLight()
	if not lightBase then snapshotLight() end

	if S.Fullbright then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		Lighting.GlobalShadows = false
	end
	if S.TimeOn then Lighting.ClockTime = S.Clock end
	if S.BrightOn then Lighting.Brightness = S.Bright end
	if S.NoShadow then Lighting.GlobalShadows = false end
	if S.NoFog then
		Lighting.FogStart = 1e8
		Lighting.FogEnd = 1e9
	end

	if S.NoFog or S.ClearSky then
		for _, o in ipairs(Lighting:GetChildren()) do
			if o:IsA("Atmosphere") then
				if not atmoBase[o] then
					atmoBase[o] = {
						Density = o.Density, Haze = o.Haze,
						Color = o.Color, Decay = o.Decay, Glare = o.Glare,
					}
				end
				if S.NoFog then
					o.Density = 0
					o.Haze = 0
				end
				if S.ClearSky then
					o.Color = Color3.fromRGB(199, 215, 255)
					o.Decay = Color3.fromRGB(255, 255, 255)
					o.Glare = 0
				end
			end
		end
	end

	if S.NoEffects then
		local function scan(parent)
			for _, o in ipairs(parent:GetChildren()) do
				if isEffect(o) then
					if effBase[o] == nil then effBase[o] = o.Enabled end
					if o.Enabled then o.Enabled = false end
				end
			end
		end
		scan(Lighting)
		scan(workspace.CurrentCamera)
	end
end

local function onLightChange()
	restoreLight()
	if anyLight() then applyLight() end
end

task.spawn(function()
	while true do
		if anyLight() then applyLight() end
		task.wait(0.5)
	end
end)

----------------------------------------------------------------
-- MONSTER DETECTION
----------------------------------------------------------------
local monsters = {}
local mAdded, mRemoving = nil, nil
local mScanId = 0

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
	if matchAny(string.lower(m.Name), MONSTER_WORDS) then return true end
	local par = m.Parent
	return par ~= nil and par ~= workspace and matchAny(string.lower(par.Name), MONSTER_WORDS)
end

local function tryAddMonster(inst)
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
	mScanId += 1
	if mAdded then mAdded:Disconnect() mAdded = nil end
	if mRemoving then mRemoving:Disconnect() mRemoving = nil end
	table.clear(monsters)
end

local function startMonsterTrack()
	stopMonsterTrack()
	local id = mScanId
	mAdded = workspace.DescendantAdded:Connect(tryAddMonster)
	mRemoving = workspace.DescendantRemoving:Connect(function(i)
		if monsters[i] then monsters[i] = nil end
	end)
	task.spawn(function()
		local n = 0
		for _, d in ipairs(workspace:GetDescendants()) do
			if id ~= mScanId then return end
			tryAddMonster(d)
			n += 1
			if n % 400 == 0 then task.wait() end
		end
	end)
end

----------------------------------------------------------------
-- ITEM DETECTION
----------------------------------------------------------------
local items = {} -- [key] = {adornee, part, name}
local itemN = 0
local iAdded, iRemoving = nil, nil
local iScanId = 0
local learned = {}
local learnedCount = 0

local function sigOf(p)
	local shape = p:IsA("Part") and p.Shape.Name or p.ClassName
	local s = p.Size
	return string.format("%s|%s|%d|%d|%d", string.lower(p.Name), shape,
		math.floor(s.X + 0.5), math.floor(s.Y + 0.5), math.floor(s.Z + 0.5))
end

local function itemPart(inst)
	if inst:IsA("BasePart") then return inst end
	if inst:IsA("Tool") then
		return inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart", true)
	end
	if inst:IsA("Model") then
		return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
	end
end

local function insideLiving(inst)
	local a = inst.Parent
	while a and a ~= workspace do
		if a:IsA("Model") and (monsters[a] or a:FindFirstChildOfClass("Humanoid")) then
			return true
		end
		a = a.Parent
	end
	return false
end

local function insideTracked(inst)
	local a = inst.Parent
	while a and a ~= workspace do
		if items[a] or a:IsA("Tool") then return true end
		a = a.Parent
	end
	return false
end

local function tryAddItem(inst)
	if itemN >= MAX_ITEMS then return end
	if inst:IsA("Terrain") or inst.Name == "SpawnPointMarker" or inst.Name == PROXY_NAME then return end

	local filter = S.ItemFilter
	local key, adornee, name

	if inst:IsA("Tool") then
		if filter ~= "" and not string.lower(inst.Name):find(filter, 1, true) then return end
		key, adornee, name = inst, inst, inst.Name

	elseif inst:IsA("ProximityPrompt") then
		if filter ~= "" then return end
		local txt = string.lower(inst.ActionText .. " " .. inst.ObjectText)
		if not matchAny(txt, PICK_WORDS) then return end
		local owner = inst.Parent
		if owner and owner:IsA("Attachment") then owner = owner.Parent end
		if not (owner and owner:IsA("BasePart")) then return end
		local mdl = owner:FindFirstAncestorOfClass("Model")
		if mdl and mdl:GetExtentsSize().Magnitude < 30 then
			key, adornee = mdl, mdl
		else
			key, adornee = owner, owner
		end
		name = (inst.ObjectText ~= "" and inst.ObjectText) or key.Name

	elseif inst:IsA("BasePart") or inst:IsA("Model") then
		local isPart = inst:IsA("BasePart")
		local nm = string.lower(inst.Name)
		local size = isPart and inst.Size.Magnitude or inst:GetExtentsSize().Magnitude
		if size > 40 then return end
		if not isPart and inst:FindFirstChildOfClass("Humanoid") then return end

		local ok = false
		if isPart and learned[sigOf(inst)] then
			ok = true
		elseif isPart and inst.Transparency >= 0.95 then
			ok = false
		elseif filter ~= "" then
			ok = nm:find(filter, 1, true) ~= nil
		elseif S.ItemMode == "auto" then
			ok = matchAny(nm, ITEM_WORDS)
				or (isPart and inst:IsA("Part") and inst.Shape == Enum.PartType.Ball and size <= 20)
		elseif S.ItemMode == "small" then
			ok = size <= 8
		end
		if not ok then return end
		key, adornee, name = inst, inst, inst.Name
	else
		return
	end

	if not key or items[key] then return end
	if insideLiving(key) or insideTracked(key) then return end
	local part = itemPart(adornee)
	if not part then return end

	items[key] = { adornee = adornee, part = part, name = name }
	itemN += 1
end

local function stopItemTrack()
	iScanId += 1
	if iAdded then iAdded:Disconnect() iAdded = nil end
	if iRemoving then iRemoving:Disconnect() iRemoving = nil end
	table.clear(items)
	itemN = 0
end

local function startItemTrack()
	stopItemTrack()
	local id = iScanId
	iAdded = workspace.DescendantAdded:Connect(tryAddItem)
	iRemoving = workspace.DescendantRemoving:Connect(function(i)
		if items[i] then
			items[i] = nil
			itemN -= 1
		end
	end)
	task.spawn(function()
		local n = 0
		for _, d in ipairs(workspace:GetDescendants()) do
			if id ~= iScanId then return end
			tryAddItem(d)
			n += 1
			if n % 400 == 0 then task.wait() end
		end
	end)
end

local function nearestParts(maxSize, maxDist)
	local root = getRoot()
	local origin = root and root.Position or workspace.CurrentCamera.CFrame.Position
	local list, n = {}, 0
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("BasePart") and not d:IsA("Terrain")
			and d.Name ~= "SpawnPointMarker" and d.Name ~= PROXY_NAME
			and d.Size.Magnitude <= maxSize
			and not (player.Character and d:IsDescendantOf(player.Character))
			and not insideLiving(d) then
			local dist = (d.Position - origin).Magnitude
			if dist <= maxDist then list[#list + 1] = { p = d, dist = dist } end
		end
		n += 1
		if n % 800 == 0 then task.wait() end
	end
	table.sort(list, function(a, b) return a.dist < b.dist end)
	return list
end

local function describe(p)
	local shape = p:IsA("Part") and p.Shape.Name or p.ClassName
	return string.format("%s · %s · %.1f×%.1f×%.1f", p.Name, shape, p.Size.X, p.Size.Y, p.Size.Z)
end

----------------------------------------------------------------
-- ESP (player, monster, item)
----------------------------------------------------------------
local espObjs = {} -- [key] = {hl, bb, label, adornee, part, color, tracer}
local mCount, iCount, gCount = 0, 0, 0
local monsterInfo, itemInfo

local function removeEsp(key)
	local o = espObjs[key]
	if o then
		o.hl:Destroy()
		o.bb:Destroy()
		espObjs[key] = nil
	end
end

local function clearEsp()
	for key in pairs(espObjs) do removeEsp(key) end
end

local function makeEsp(adornee, part, offset)
	local hl = new("Highlight", {
		Name = "TKESP",
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		FillTransparency = 0.6,
		OutlineTransparency = 0,
		Adornee = adornee,
	}, adornee)

	local bb = new("BillboardGui", {
		Name = "TKTag",
		Size = UDim2.fromOffset(180, 18),
		StudsOffset = Vector3.new(0, offset, 0),
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

	return { hl = hl, bb = bb, label = label, adornee = adornee, part = part }
end

local function pickPart(char)
	return char:FindFirstChild("Head")
		or char:FindFirstChild("HumanoidRootPart")
		or char.PrimaryPart
		or char:FindFirstChildWhichIsA("BasePart", true)
end

local seen = {}

local function updateOne(key, adornee, part, text, cfg, root, camPos)
	if not part or not part.Parent then return false end
	local hum = key:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health <= 0 then return false end

	local origin = root and root.Position or camPos
	local dist = (part.Position - origin).Magnitude
	if cfg.limitOn and dist > cfg.limit then return false end

	seen[key] = true

	local o = espObjs[key]
	if o and (o.adornee ~= adornee or o.part ~= part
		or o.hl.Parent ~= adornee or o.bb.Parent ~= part) then
		removeEsp(key)
		o = nil
	end
	if not o then
		o = makeEsp(adornee, part, cfg.offset)
		espObjs[key] = o
	end

	if o.color ~= cfg.color then
		o.color = cfg.color
		o.hl.FillColor = cfg.color
		o.hl.OutlineColor = cfg.color
		o.label.TextColor3 = cfg.color
	end
	o.tracer = cfg.tracer

	local fillT = (S.Style == "fill") and 0.6 or 1
	if o.hl.FillTransparency ~= fillT then o.hl.FillTransparency = fillT end

	o.bb.Enabled = cfg.showName or cfg.showDist

	local t = cfg.showName and text or ""
	if cfg.showDist then
		t = (t ~= "" and (t .. " ") or "") .. "[" .. math.floor(dist) .. "m]"
	end
	if o.label.Text ~= t then o.label.Text = t end
	return true
end

-- merged ESP for nearby items (one box + one label, name only)
local clusterPool = {}

local function getCluster(i)
	local v = clusterPool[i]
	if v then return v end
	local part = new("Part", {
		Name = PROXY_NAME,
		Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
		CastShadow = false, Transparency = 1,
		Size = Vector3.new(1, 1, 1),
	}, workspace)
	local box = new("SelectionBox", { LineThickness = 0.04, SurfaceTransparency = 1 }, part)
	local fill = new("BoxHandleAdornment", {
		AlwaysOnTop = true, ZIndex = 1, Transparency = 0.75, Size = Vector3.new(1, 1, 1),
	}, part)
	local bb = new("BillboardGui", {
		Size = UDim2.fromOffset(180, 18),
		AlwaysOnTop = true,
		Adornee = part,
		Enabled = false,
	}, part)
	local label = new("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextStrokeTransparency = 0.3,
	}, bb)
	v = { part = part, box = box, fill = fill, bb = bb, label = label, active = false }
	clusterPool[i] = v
	return v
end

local function hidePool(from)
	for i = from, #clusterPool do
		local v = clusterPool[i]
		if v and v.active then
			v.active = false
			v.box.Adornee = nil
			v.fill.Adornee = nil
			v.bb.Enabled = false
		end
	end
end

local function updateCluster(g, idx, cfg, root, camPos)
	local minV, maxV
	local sameName, firstName = true, g[1].info.name
	for _, e in ipairs(g) do
		local p = e.info.part
		local half = math.max(p.Size.X, p.Size.Y, p.Size.Z) / 2
		local lo = p.Position - Vector3.one * half
		local hi = p.Position + Vector3.one * half
		minV = minV and minV:Min(lo) or lo
		maxV = maxV and maxV:Max(hi) or hi
		if e.info.name ~= firstName then sameName = false end
	end

	local center = (minV + maxV) / 2
	local size = (maxV - minV) + Vector3.one * 0.6
	local origin = root and root.Position or camPos
	local dist = (center - origin).Magnitude
	if cfg.limitOn and dist > cfg.limit then return false end

	local v = getCluster(idx)
	v.active = true
	v.part.Size = size
	v.part.CFrame = CFrame.new(center)

	v.box.Adornee = v.part
	v.box.Color3 = cfg.color
	v.fill.Adornee = v.part
	v.fill.Size = size
	v.fill.Color3 = cfg.color
	v.fill.Visible = (S.Style == "fill")

	v.color = cfg.color
	v.tracer = cfg.tracer
	v.label.TextColor3 = cfg.color
	v.bb.StudsOffset = Vector3.new(0, size.Y / 2 + 1.5, 0)
	v.bb.Enabled = cfg.showName or cfg.showDist

	local base = (S.IRealName and sameName) and firstName or "Item"
	local t = cfg.showName and base or ""
	if cfg.showDist then
		t = (t ~= "" and (t .. " ") or "") .. "[" .. math.floor(dist) .. "m]"
	end
	if v.label.Text ~= t then v.label.Text = t end
	return true
end

local function clusterItems(list, radius)
	local r2 = radius * radius
	local used, clusters = {}, {}
	for i = 1, #list do
		if not used[i] then
			used[i] = true
			local g = { list[i] }
			local sp = list[i].pos
			for j = i + 1, #list do
				if not used[j] then
					local d = list[j].pos - sp
					if d:Dot(d) <= r2 then
						used[j] = true
						g[#g + 1] = list[j]
					end
				end
			end
			clusters[#clusters + 1] = g
		end
	end
	return clusters
end

local cfgP = { offset = 3 }
local cfgM = { offset = 3 }
local cfgI = { offset = 2 }

local espTimer, infoTimer = 0, 0
RunService.Heartbeat:Connect(function(dt)
	espTimer += dt
	if espTimer < 0.2 then return end
	espTimer = 0

	if not (S.EspPlayer or S.EspMonster or S.EspItem) then
		if next(espObjs) then clearEsp() end
		hidePool(1)
		mCount, iCount, gCount = 0, 0, 0
		return
	end

	local root = getRoot()
	local camPos = workspace.CurrentCamera.CFrame.Position
	table.clear(seen)
	mCount, iCount, gCount = 0, 0, 0

	if S.EspPlayer then
		cfgP.color = COLORS[S.PColor][2]
		cfgP.showName, cfgP.showDist = S.PName, S.PDist
		cfgP.limitOn, cfgP.limit, cfgP.tracer = S.PLimitOn, S.PLimit, S.PTracer
		for _, plr in ipairs(Players:GetPlayers()) do
			local char = plr.Character
			if plr ~= player and char then
				updateOne(char, char, pickPart(char), plr.Name, cfgP, root, camPos)
			end
		end
	end

	if S.EspMonster then
		cfgM.color = COLORS[S.MColor][2]
		cfgM.showName, cfgM.showDist = S.MName, S.MDist
		cfgM.limitOn, cfgM.limit, cfgM.tracer = S.MLimitOn, S.MLimit, S.MTracer
		for model in pairs(monsters) do
			if not model.Parent then
				monsters[model] = nil
			elseif updateOne(model, model, pickPart(model),
				S.MRealName and model.Name or "Monster", cfgM, root, camPos) then
				mCount += 1
			end
		end
	end

	if S.EspItem then
		cfgI.color = COLORS[S.IColor][2]
		cfgI.showName, cfgI.showDist = S.IName, S.IDist
		cfgI.limitOn, cfgI.limit, cfgI.tracer = S.ILimitOn, S.ILimit, S.ITracer

		local list = {}
		for key, info in pairs(items) do
			if not key:IsDescendantOf(workspace) then
				items[key] = nil
				itemN -= 1
			elseif info.part.Parent and not insideLiving(key) then
				list[#list + 1] = { key = key, info = info, pos = info.part.Position }
			end
		end

		local groups
		if S.ItemMerge then
			groups = clusterItems(list, S.ItemMergeDist)
		else
			groups = {}
			for _, e in ipairs(list) do groups[#groups + 1] = { e } end
		end

		local poolUsed = 0
		for _, g in ipairs(groups) do
			if #g == 1 then
				local e = g[1]
				if updateOne(e.key, e.info.adornee, e.info.part,
					S.IRealName and e.info.name or "Item", cfgI, root, camPos) then
					iCount += 1
					gCount += 1
				end
			elseif updateCluster(g, poolUsed + 1, cfgI, root, camPos) then
				poolUsed += 1
				iCount += #g
				gCount += 1
			end
		end
		hidePool(poolUsed + 1)
	else
		hidePool(1)
	end

	for key in pairs(espObjs) do
		if not seen[key] then removeEsp(key) end
	end

	infoTimer += 0.2
	if infoTimer >= 1 then
		infoTimer = 0
		if monsterInfo then
			local t = S.EspMonster and ("Monsters detected: " .. mCount) or "ESP Monster is off."
			if monsterInfo.Text ~= t then monsterInfo.Text = t end
		end
		if itemInfo then
			local t = S.EspItem
				and ("Items: " .. iCount .. " · shown: " .. gCount .. " · learned: " .. learnedCount)
				or "ESP Item is off."
			if itemInfo.Text ~= t then itemInfo.Text = t end
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if plr.Character then removeEsp(plr.Character) end
end)

----------------------------------------------------------------
-- GUI: BASE
----------------------------------------------------------------
local gui = new("ScreenGui", {
	Name = "ToolkitUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, player:WaitForChild("PlayerGui"))

-- Tracers
local tracerHolder = new("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Active = false,
	ZIndex = 0,
}, gui)
local lines = {}

RunService.RenderStepped:Connect(function()
	local used = 0
	if S.PTracer or S.MTracer or S.ITracer then
		local cam = workspace.CurrentCamera
		local vp = cam.ViewportSize
		local from = Vector2.new(vp.X / 2, vp.Y)

		local function draw(part, color)
			if used >= MAX_LINES or not (part and part.Parent) then return end
			local v, on = cam:WorldToViewportPoint(part.Position)
			if not on then return end
			used += 1
			local l = lines[used]
			if not l then
				l = new("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BorderSizePixel = 0,
				}, tracerHolder)
				lines[used] = l
			end
			local to = Vector2.new(v.X, v.Y)
			local d = to - from
			l.Size = UDim2.fromOffset(d.Magnitude, 1.5)
			l.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
			l.Rotation = math.deg(math.atan2(d.Y, d.X))
			l.BackgroundColor3 = color or WHITE
			l.Visible = true
		end

		for _, o in pairs(espObjs) do
			if o.tracer then draw(o.part, o.color) end
		end
		for _, v in ipairs(clusterPool) do
			if v.active and v.tracer then draw(v.part, v.color) end
		end
	end
	for i = used + 1, #lines do
		if lines[i].Visible then lines[i].Visible = false end
	end
end)

-- drag helper: handle can be tapped (onTap) or dragged; isLocked() blocks dragging
local function makeDraggable(handle, target, isLocked, onTap)
	local dragging, dragStart, startPos, moved = false, nil, nil, false
	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		dragging, moved = true, false
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
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			if d.Magnitude > 8 then moved = true end
			if moved and not isLocked() then
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end
	end)
end

----------------------------------------------------------------
-- GUI: LOGO + MAIN MENU
----------------------------------------------------------------
local BASE_W, BASE_H = 310, 260

-- Round logo (uses your image)
local logo = new("ImageButton", {
	Name = "Logo",
	Size = UDim2.fromOffset(55, 55),
	Position = UDim2.new(0, 20, 0.5, -27),
	BackgroundColor3 = Color3.fromRGB(25, 25, 35),
	Image = LOGO_IMAGE,
	ScaleType = Enum.ScaleType.Fit,
	AutoButtonColor = false,
	Active = true,
}, gui)
corner(logo, 28)
outline(logo, C.accent, 2, 0)

local main = new("Frame", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -(BASE_W / 2) - 14, 0.5, 0),
	Size = UDim2.fromOffset(BASE_W, BASE_H),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
}, gui)
corner(main, 12)
local mainStroke = outline(main, C.stroke, 1, 0)
local mainScale = new("UIScale", { Scale = 1 }, main)

local function fitScale()
	local vp = workspace.CurrentCamera.ViewportSize
	local fit = math.clamp(math.min((vp.Y - 40) / BASE_H, (vp.X - 40) / BASE_W), 0.5, 1)
	return fit * S.UiScale
end

local menuOpen = true
mainScale.Scale = fitScale()

local function applyScale()
	if menuOpen then mainScale.Scale = fitScale() end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)

local function toggleMenu()
	menuOpen = not menuOpen
	if menuOpen then
		main.Visible = true
		mainScale.Scale = fitScale() * 0.82
		main.BackgroundTransparency = 1
		tween(mainScale, { Scale = fitScale() }, 0.3, Enum.EasingStyle.Back)
		tween(main, { BackgroundTransparency = S.Opacity }, 0.2)
	else
		tween(mainScale, { Scale = fitScale() * 0.82 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local fade = TweenService:Create(main,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ BackgroundTransparency = 1 })
		fade:Play()
		fade.Completed:Connect(function()
			if not menuOpen then
				main.Visible = false
				main.BackgroundTransparency = S.Opacity
			end
		end)
	end
end

makeDraggable(logo, logo, function() return false end, toggleMenu)

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightControl then toggleMenu() end
end)

-- Header
local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 34),
	BackgroundTransparency = 1,
	Active = true,
}, main)

new("TextLabel", {
	Size = UDim2.new(1, -50, 1, 0),
	Position = UDim2.fromOffset(14, 0),
	BackgroundTransparency = 1,
	Text = "TOOLKIT",
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
closeBtn.MouseButton1Click:Connect(toggleMenu)

makeDraggable(header, main, function() return S.Locked end, nil)

-- Tab bar
local tabBar = new("Frame", {
	Size = UDim2.new(1, -16, 0, 36),
	Position = UDim2.fromOffset(8, 36),
	BackgroundTransparency = 1,
}, main)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local content = new("Frame", {
	Size = UDim2.new(1, -16, 1, -82),
	Position = UDim2.fromOffset(8, 76),
	BackgroundTransparency = 1,
}, main)

local pages, tabs = {}, {}
local tabOrder = 0

local function setTab(name)
	for n, p in pairs(pages) do
		local sel = (n == name)
		p.Visible = sel
		tween(tabs[n].btn, { BackgroundColor3 = sel and C.accent or C.card }, 0.15)
		tabs[n].name.TextColor3 = sel and WHITE or C.sub
	end
end

local function newPage(name, icon)
	tabOrder += 1
	local btn = new("TextButton", {
		Size = UDim2.new(1 / 5, -4, 1, 0),
		BackgroundColor3 = C.card,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = tabOrder,
	}, tabBar)
	corner(btn, 8)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.fromOffset(0, 2),
		BackgroundTransparency = 1,
		Text = icon,
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextColor3 = WHITE,
	}, btn)
	local nameL = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.fromOffset(0, 22),
		BackgroundTransparency = 1,
		Text = name,
		TextSize = 8,
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
	new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	new("UIPadding", {
		PaddingRight = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 2),
	}, page)

	pages[name] = page
	tabs[name] = { btn = btn, name = nameL }
	btn.MouseButton1Click:Connect(function() setTab(name) end)
	return page
end

local pageSpawn = newPage("SPAWN", "📍")
local pageEsp = newPage("ESP", "👁")
local pagePlayer = newPage("PLAYER", "🏃")
local pageVisual = newPage("VISUAL", "🌤")
local pageSet = newPage("SETTINGS", "⚙")

----------------------------------------------------------------
-- GUI: COMPONENTS
----------------------------------------------------------------
local order = 0
local function nextOrder()
	order += 1
	return order
end

local setters = {}

local function section(parent, text)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = string.upper(text),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.sub,
		LayoutOrder = nextOrder(),
	}, parent)
end

local function row(parent, height)
	local r = new("TextButton", {
		Size = UDim2.new(1, 0, 0, height or 34),
		BackgroundColor3 = C.card,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = nextOrder(),
	}, parent)
	corner(r, 8)
	return r
end

local function rowLabel(r, text, rightPad, y, h)
	return new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -(rightPad or 64), 0, h or 34),
		Position = UDim2.fromOffset(10, y or 0),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = text,
	}, r)
end

local OFF_POS = UDim2.new(0, 3, 0.5, -9)
local ON_POS = UDim2.new(1, -21, 0.5, -9)

-- X / ● switch (red when ON)
local function toggle(parent, label, key, onChange)
	local r = row(parent)
	rowLabel(r, label, 64)
	local sw = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(46, 24),
		BackgroundColor3 = C.off,
	}, r)
	corner(sw, 12)
	local sst = outline(sw, C.offLine, 1.5, 0)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = OFF_POS,
		BackgroundColor3 = C.knobOff,
	}, sw)
	corner(knob, 9)
	local icon = new("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "X",
		TextColor3 = Color3.fromRGB(230, 230, 230),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
	}, knob)

	local function refresh(instant)
		local on = S[key]
		icon.Text = on and "●" or "X"
		local bg = on and C.onBg or C.off
		local ln = on and C.onLine or C.offLine
		local kp = on and ON_POS or OFF_POS
		local kc = on and WHITE or C.knobOff
		if instant then
			sw.BackgroundColor3, sst.Color = bg, ln
			knob.Position, knob.BackgroundColor3 = kp, kc
		else
			tween(sw, { BackgroundColor3 = bg }, 0.22)
			tween(sst, { Color = ln }, 0.22)
			tween(knob, { Position = kp, BackgroundColor3 = kc }, 0.26, Enum.EasingStyle.Quint)
		end
	end

	setters[key] = function(v)
		S[key] = v
		refresh(false)
		if onChange then onChange() end
	end
	r.MouseButton1Click:Connect(function() setters[key](not S[key]) end)
	refresh(true)
end

local function slider(parent, label, key, min, max, step, onChange, fmt)
	local r = row(parent, 46)
	rowLabel(r, label, 90, 2, 22)
	local val = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 2),
		Size = UDim2.fromOffset(80, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = C.accent,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, r)
	local track = new("Frame", {
		Size = UDim2.new(1, -28, 0, 5),
		Position = UDim2.new(0, 14, 0, 32),
		BackgroundColor3 = C.off,
		BorderSizePixel = 0,
	}, r)
	corner(track, 3)
	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
	}, track)
	corner(fill, 3)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = WHITE,
		ZIndex = 2,
	}, track)
	corner(knob, 8)
	outline(knob, C.accent, 2, 0)

	local function refresh()
		local t = (S[key] - min) / (max - min)
		fill.Size = UDim2.fromScale(t, 1)
		knob.Position = UDim2.new(t, 0, 0.5, 0)
		val.Text = fmt and fmt(S[key]) or tostring(S[key])
	end

	local hit = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.fromOffset(0, 18),
		BackgroundTransparency = 1,
		Text = "",
	}, r)

	local function setFromX(x)
		local t = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local v = min + t * (max - min)
		v = math.floor(v / step + 0.5) * step
		v = math.clamp(math.round(v * 100) / 100, min, max)
		if S[key] ~= v then
			S[key] = v
			refresh()
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

local function segmented(parent, label, key, options, onChange)
	local r = row(parent, 56)
	rowLabel(r, label, 20, 2, 22)
	local holder = new("Frame", {
		Size = UDim2.new(1, -16, 0, 26),
		Position = UDim2.fromOffset(8, 25),
		BackgroundColor3 = C.bg,
	}, r)
	corner(holder, 8)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
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
			Size = UDim2.new(1 / n, -3, 0, 20),
			BackgroundColor3 = C.bg,
			Text = o[2],
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextColor3 = C.sub,
			AutoButtonColor = false,
			LayoutOrder = i,
		}, holder)
		corner(b, 6)
		btns[i] = b
		b.MouseButton1Click:Connect(function()
			S[key] = o[1]
			refresh()
			if onChange then onChange() end
		end)
	end
	refresh()
end

local function swatches(parent, label, key)
	local r = row(parent, 54)
	rowLabel(r, label, 20, 2, 22)
	local holder = new("Frame", {
		Size = UDim2.new(1, -20, 0, 24),
		Position = UDim2.fromOffset(10, 26),
		BackgroundTransparency = 1,
	}, r)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, holder)

	local strokes = {}
	local function refresh()
		for i, st in ipairs(strokes) do
			st.Transparency = (i == S[key]) and 0 or 1
		end
	end
	for i, c in ipairs(COLORS) do
		local b = new("TextButton", {
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = c[2],
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = i,
		}, holder)
		corner(b, 11)
		strokes[i] = outline(b, WHITE, 2, 1)
		b.MouseButton1Click:Connect(function()
			S[key] = i
			refresh()
		end)
	end
	refresh()
end

local function actionButton(parent, text, color, onClick)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = color,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = WHITE,
		AutoButtonColor = false,
		LayoutOrder = nextOrder(),
	}, parent)
	corner(b, 8)
	b.MouseButton1Click:Connect(onClick)
	return b
end

-- several buttons in one row
local function triRow(parent, defs)
	local f = new("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
	}, parent)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, f)
	for i, d in ipairs(defs) do
		local b = new("TextButton", {
			Size = UDim2.new(1 / #defs, -3, 1, 0),
			BackgroundColor3 = d[2],
			Text = d[1],
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = WHITE,
			AutoButtonColor = false,
			LayoutOrder = i,
		}, f)
		corner(b, 8)
		b.MouseButton1Click:Connect(d[3])
	end
end

local function statusCard(parent, text)
	local l = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.card,
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.text,
		LayoutOrder = nextOrder(),
	}, parent)
	corner(l, 8)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
	}, l)
	return l
end

local function infoLabel(parent, text)
	local l = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.sub,
		LayoutOrder = nextOrder(),
	}, parent)
	new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, l)
	return l
end

local function textInput(parent, placeholder, onSubmit)
	local box = new("TextBox", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = C.card,
		TextColor3 = C.text,
		PlaceholderText = placeholder,
		PlaceholderColor3 = C.sub,
		Text = "",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		LayoutOrder = nextOrder(),
	}, parent)
	corner(box, 8)
	outline(box, C.stroke, 1, 0)
	box.FocusLost:Connect(function() onSubmit(box.Text) end)
	return box
end

local function meters(v) return v .. "m" end
local function studs(v) return v .. " studs" end
local function percent(v) return math.floor(v * 100 + 0.5) .. "%" end

----------------------------------------------------------------
-- SIDE TOGGLE (small spawn panel)
----------------------------------------------------------------
local sideLocked = false

local side = new("Frame", {
	Name = "SideToggle",
	Size = UDim2.fromOffset(104, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	Position = UDim2.new(0, 14, 0.2, 0),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	Visible = false,
}, gui)
corner(side, 10)
outline(side, C.stroke, 1, 0)
new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, side)
new("UIPadding", {
	PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
	PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5),
}, side)

local sideHead = new("Frame", {
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundTransparency = 1,
	LayoutOrder = 1,
}, side)

local arrowBtn = new("TextButton", {
	Size = UDim2.new(1, -30, 1, 0),
	BackgroundColor3 = C.card,
	Text = "▲ SPAWN",
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextColor3 = WHITE,
	AutoButtonColor = false,
}, sideHead)
corner(arrowBtn, 6)

local sideLockBtn = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.fromOffset(26, 24),
	BackgroundColor3 = C.card,
	Text = "🔓",
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextColor3 = WHITE,
	AutoButtonColor = false,
}, sideHead)
corner(sideLockBtn, 6)

local sideBody = new("Frame", {
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	LayoutOrder = 2,
}, side)
new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, sideBody)

local function sideBtn(text, color, ord, fn)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = color,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = WHITE,
		AutoButtonColor = false,
		LayoutOrder = ord,
	}, sideBody)
	corner(b, 7)
	b.MouseButton1Click:Connect(fn)
end
sideBtn("📍 Save", C.green, 1, doSave)
sideBtn("🚀 TP", C.accent, 2, doTeleport)
sideBtn("🗑 Delete", C.danger, 3, doDelete)

local sideExpanded = true
makeDraggable(arrowBtn, side, function() return sideLocked end, function()
	sideExpanded = not sideExpanded
	sideBody.Visible = sideExpanded
	arrowBtn.Text = sideExpanded and "▲ SPAWN" or "▼ SPAWN"
end)

sideLockBtn.MouseButton1Click:Connect(function()
	sideLocked = not sideLocked
	sideLockBtn.Text = sideLocked and "🔒" or "🔓"
end)

----------------------------------------------------------------
-- CONTENT: SPAWN
----------------------------------------------------------------
spawnStatus = statusCard(pageSpawn, "No spawn point saved.")
toggle(pageSpawn, "Side Toggle (mini panel)", "SideOn", function()
	side.Visible = S.SideOn
end)
triRow(pageSpawn, {
	{ "📍 Save", C.green, doSave },
	{ "🚀 TP", C.accent, doTeleport },
	{ "🗑 Delete", C.danger, doDelete },
})
toggle(pageSpawn, "Respawn at saved point", "AutoSpawn")
toggle(pageSpawn, "Show marker", "ShowMarker", function()
	if saved then placeMarker(saved) else removeMarker() end
end)

----------------------------------------------------------------
-- CONTENT: ESP (category buttons on top)
----------------------------------------------------------------
local selRow = new("Frame", {
	Size = UDim2.new(1, 0, 0, 28),
	BackgroundTransparency = 1,
	LayoutOrder = nextOrder(),
}, pageEsp)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, selRow)

toggle(pageEsp, "ESP All (master)", "EspAll", function()
	for _, k in ipairs({ "EspPlayer", "EspMonster", "EspItem" }) do
		if setters[k] then setters[k](S.EspAll) end
	end
end)

local cats = {}
local function selectCat(name)
	for n, c in pairs(cats) do
		local sel = (n == name)
		c.body.Visible = sel
		c.btn.BackgroundColor3 = sel and c.color:Lerp(C.card, 0.7) or C.card
		c.stroke.Transparency = sel and 0 or 0.75
	end
end

local function newCat(name, text, color, ord)
	local btn = new("TextButton", {
		Size = UDim2.new(1 / 3, -3, 1, 0),
		BackgroundColor3 = C.card,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = color,
		AutoButtonColor = false,
		LayoutOrder = ord,
	}, selRow)
	corner(btn, 8)
	local st = outline(btn, color, 1.2, 0.75)
	local body = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
		Visible = false,
	}, pageEsp)
	new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, body)
	cats[name] = { btn = btn, body = body, color = color, stroke = st }
	btn.MouseButton1Click:Connect(function() selectCat(name) end)
	return body
end

-- PLAYER
local bPlayer = newCat("PLAYER", "👤 PLAYER", COLORS[1][2], 1)
toggle(bPlayer, "ESP Player", "EspPlayer")
toggle(bPlayer, "Show name", "PName")
toggle(bPlayer, "Show distance", "PDist")
toggle(bPlayer, "Tracer line", "PTracer")
swatches(bPlayer, "Color", "PColor")
toggle(bPlayer, "Distance limit", "PLimitOn")
slider(bPlayer, "Max distance", "PLimit", 50, 2000, 50, nil, meters)

-- MONSTER
local bMonster = newCat("MONSTER", "👹 MONSTER", COLORS[2][2], 2)
toggle(bMonster, "ESP Monster", "EspMonster", function()
	if S.EspMonster then startMonsterTrack() else stopMonsterTrack() end
end)
monsterInfo = statusCard(bMonster, "ESP Monster is off.")
toggle(bMonster, "Show name", "MName")
toggle(bMonster, "Show distance", "MDist")
toggle(bMonster, "Use real model name", "MRealName")
toggle(bMonster, "Tracer line", "MTracer")
swatches(bMonster, "Color", "MColor")
toggle(bMonster, "Distance limit", "MLimitOn")
slider(bMonster, "Max distance", "MLimit", 50, 2000, 50, nil, meters)
textInput(bMonster, "Name filter, e.g. zombie", function(text)
	S.MonsterFilter = trim(text)
	if S.EspMonster then startMonsterTrack() end
end)
infoLabel(bMonster, "Empty filter = automatic (has a Humanoid / AnimationController, or a name containing monster, enemy, mob, zombie, boss, npc).")

-- ITEM
local bItem = newCat("ITEM", "🎒 ITEM", COLORS[4][2], 3)
local function restartItems()
	if S.EspItem then startItemTrack() end
end
toggle(bItem, "ESP Item", "EspItem", function()
	if S.EspItem then
		if setters.IRealName then setters.IRealName(false) end -- label shows "Item"
		startItemTrack()
	else
		stopItemTrack()
	end
end)
itemInfo = statusCard(bItem, "ESP Item is off.")
toggle(bItem, "Merge nearby items", "ItemMerge")
slider(bItem, "Merge distance", "ItemMergeDist", 2, 30, 1, nil, studs)
toggle(bItem, "Show name", "IName")
toggle(bItem, "Show distance", "IDist")
toggle(bItem, "Use real item name", "IRealName")
toggle(bItem, "Tracer line", "ITracer")
swatches(bItem, "Color", "IColor")
toggle(bItem, "Distance limit", "ILimitOn")
slider(bItem, "Max distance", "ILimit", 50, 2000, 50, nil, meters)
segmented(bItem, "Item detection mode", "ItemMode", {
	{ "auto", "Auto" },
	{ "small", "All small" },
	{ "learned", "Learned" },
}, restartItems)
textInput(bItem, "Name filter, e.g. key", function(text)
	S.ItemFilter = trim(text)
	restartItems()
end)

local diagCard = statusCard(bItem, "")
diagCard.Visible = false

actionButton(bItem, "➕ Teach nearest item", C.accent, function()
	task.spawn(function()
		local list = nearestParts(20, 60)
		local top = list[1]
		diagCard.Visible = true
		if not top then
			diagCard.Text = "No nearby object. Stand close to the item."
			return
		end
		local sig = sigOf(top.p)
		if not learned[sig] then
			learned[sig] = top.p.Name
			learnedCount += 1
		end
		restartItems()
		diagCard.Text = "Learned: " .. top.p.Name .. " (" .. math.floor(top.dist) .. "m)"
	end)
end)

actionButton(bItem, "🔍 Inspect nearby objects", Color3.fromRGB(40, 110, 150), function()
	task.spawn(function()
		diagCard.Visible = true
		diagCard.Text = "Scanning…"
		local list = nearestParts(60, 80)
		if #list == 0 then
			diagCard.Text = "No objects within 80 m."
			return
		end
		local out = {}
		for i = 1, math.min(6, #list) do
			out[#out + 1] = string.format("%d. %s · %dm", i, describe(list[i].p), math.floor(list[i].dist))
		end
		diagCard.Text = table.concat(out, "\n")
	end)
end)

actionButton(bItem, "🧹 Forget learned items", C.danger, function()
	table.clear(learned)
	learnedCount = 0
	restartItems()
end)
infoLabel(bItem, "Nearby items are merged into a single ESP with a name-only label. Item not detected? Stand next to it and press Teach.")

selectCat("PLAYER")

----------------------------------------------------------------
-- CONTENT: PLAYER (movement + camera)
----------------------------------------------------------------
section(pagePlayer, "Movement")
toggle(pagePlayer, "WalkSpeed", "WalkOn", function()
	if not S.WalkOn then restoreWalk() end
end)
slider(pagePlayer, "Speed", "WalkSpeed", 16, 150, 1, nil, function(v) return v .. " studs/s" end)
actionButton(pagePlayer, "↺ Reset to normal speed", C.card, function()
	setters.WalkOn(false)
	S.WalkSpeed = 32
end)
section(pagePlayer, "Camera")
toggle(pagePlayer, "Custom FOV", "CustomFov", setFovMode)
slider(pagePlayer, "FOV value", "Fov", 40, 120, 1)
toggle(pagePlayer, "Max zoom", "ZoomOn", setZoom)
slider(pagePlayer, "Zoom distance", "Zoom", 20, 500, 10, function()
	if S.ZoomOn then setZoom() end
end, function(v) return v .. " studs" end)
infoLabel(pagePlayer, "Roblox defaults: WalkSpeed 16, FOV 70. Turning a feature off restores the original value.")

----------------------------------------------------------------
-- CONTENT: VISUAL
----------------------------------------------------------------
section(pageVisual, "Environment")
toggle(pageVisual, "No Fog", "NoFog", onLightChange)
toggle(pageVisual, "Fullbright", "Fullbright", onLightChange)
toggle(pageVisual, "No shadows", "NoShadow", onLightChange)
toggle(pageVisual, "Clear sky", "ClearSky", onLightChange)
toggle(pageVisual, "Remove screen effects", "NoEffects", onLightChange)
section(pageVisual, "Time & light")
toggle(pageVisual, "Set time of day", "TimeOn", onLightChange)
slider(pageVisual, "Time", "Clock", 0, 24, 0.5, function()
	if S.TimeOn then applyLight() end
end, function(v) return string.format("%02d:%02d", math.floor(v) % 24, (v % 1) * 60) end)
toggle(pageVisual, "Set brightness", "BrightOn", onLightChange)
slider(pageVisual, "Brightness", "Bright", 0, 5, 0.1, function()
	if S.BrightOn then applyLight() end
end)
infoLabel(pageVisual, "Screen effects = blur, bloom, sun rays, depth of field, color correction. Clear sky depends on the map's Atmosphere.")

----------------------------------------------------------------
-- CONTENT: SETTINGS
----------------------------------------------------------------
local function refreshLock()
	mainStroke.Color = S.Locked and C.green or C.stroke
end

section(pageSet, "Menu")
toggle(pageSet, "Lock menu position", "Locked", refreshLock)
slider(pageSet, "Menu size", "UiScale", 0.6, 1.3, 0.05, applyScale, percent)
slider(pageSet, "Menu opacity", "Opacity", 0, 0.5, 0.05, function()
	main.BackgroundTransparency = S.Opacity
end, percent)
section(pageSet, "ESP")
segmented(pageSet, "Highlight style", "Style", {
	{ "fill", "Fill + Outline" },
	{ "line", "Outline only" },
})
section(pageSet, "Emergency")
actionButton(pageSet, "⛔ Disable all features", C.danger, function()
	for _, k in ipairs({
		"EspAll", "EspPlayer", "EspMonster", "EspItem",
		"PTracer", "MTracer", "ITracer",
		"WalkOn", "CustomFov", "ZoomOn",
		"NoFog", "Fullbright", "NoShadow", "ClearSky", "NoEffects", "TimeOn", "BrightOn",
	}) do
		if setters[k] then setters[k](false) end
	end
end)
infoLabel(pageSet, "Toolkit v7.1 · tap the logo or X to open/close the menu. The logo can be dragged anywhere.")

refreshLock()
setTab("SPAWN") -- first open: SPAWN tab

----------------------------------------------------------------
-- RESPAWN -> MOVE TO SAVED SPAWN POINT
----------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
	if not (S.AutoSpawn and saved) then return end

	local r = char:WaitForChild("HumanoidRootPart", 10)
	if not r then return end

	local target = saved + Vector3.new(0, 3, 0)
	char:PivotTo(target)

	task.delay(0.15, function()
		if char.Parent and S.AutoSpawn and saved then
			char:PivotTo(target)
			r.AssemblyLinearVelocity = Vector3.zero
		end
	end)

	say("Respawned at saved spawn point.")
end)
