--// Toolkit v6.1 (Spawn + ESP Manusia/Monster/Item + Visual) - untuk place Studio milikmu sendiri
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
	-- esp master
	EspAll = false,
	-- manusia
	EspPlayer = false,
	PName = true,
	PDist = true,
	PTracer = false,
	PColor = 1,
	PLimitOn = false,
	PLimit = 500,
	-- monster
	EspMonster = false,
	MName = true,
	MDist = true,
	MTracer = false,
	MColor = 2,
	MRealName = false,
	MLimitOn = false,
	MLimit = 500,
	MonsterFilter = "",
	-- item
	EspItem = false,
	IName = true,
	IDist = true,
	ITracer = false,
	IColor = 4,
	IRealName = true,
	ILimitOn = false,
	ILimit = 300,
	ItemFilter = "",
	ItemMode = "auto", -- auto / small / learned
	ItemMerge = true,  -- gabung item berdekatan jadi satu ESP
	ItemMergeDist = 8, -- jarak gabung (stud)
	-- visual
	NoFog = false,
	Fullbright = false,
	CustomFov = false,
	Fov = 90,
	-- umum
	Style = "fill",
	Locked = false,
	UiScale = 1,
	Opacity = 0,
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
	bg = Color3.fromRGB(14, 14, 20),
	side = Color3.fromRGB(21, 21, 29),
	card = Color3.fromRGB(29, 29, 40),
	line = Color3.fromRGB(60, 60, 82),
	off = Color3.fromRGB(62, 62, 78),
	on = Color3.fromRGB(52, 211, 130),
	accent = Color3.fromRGB(99, 102, 241),
	accent2 = Color3.fromRGB(192, 80, 255),
	cyan = Color3.fromRGB(56, 189, 248),
	danger = Color3.fromRGB(239, 68, 90),
	text = Color3.fromRGB(240, 240, 252),
	sub = Color3.fromRGB(138, 138, 164),
}

----------------------------------------------------------------
-- HELPER
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
	TweenService:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
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
-- DETEKSI ITEM
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
-- ESP (manusia, monster, item)
----------------------------------------------------------------
local espObjs = {} -- [key] = {hl, bb, label, adornee, part, color, tracer}
local pCount, mCount, iCount, gCount = 0, 0, 0, 0
local chipP, chipM, chipI
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

----------------------------------------------------------------
-- ESP GABUNGAN UNTUK ITEM BERDEKATAN (satu kotak + satu label)
----------------------------------------------------------------
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
	local box = new("SelectionBox", {
		LineThickness = 0.04,
		SurfaceTransparency = 1,
	}, part)
	local fill = new("BoxHandleAdornment", {
		AlwaysOnTop = true, ZIndex = 1, Transparency = 0.75,
		Size = Vector3.new(1, 1, 1),
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
	local t = cfg.showName and (base .. " ×" .. #g) or ("×" .. #g)
	if cfg.showDist then t = t .. " [" .. math.floor(dist) .. "m]" end
	if v.label.Text ~= t then v.label.Text = t end
	return true
end

-- kelompokkan item: anggota harus dekat dengan item pertama (seed)
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
		pCount, mCount, iCount, gCount = 0, 0, 0, 0
		return
	end

	local root = getRoot()
	local camPos = workspace.CurrentCamera.CFrame.Position
	table.clear(seen)
	pCount, mCount, iCount, gCount = 0, 0, 0, 0

	if S.EspPlayer then
		cfgP.color = COLORS[S.PColor][2]
		cfgP.showName, cfgP.showDist = S.PName, S.PDist
		cfgP.limitOn, cfgP.limit, cfgP.tracer = S.PLimitOn, S.PLimit, S.PTracer
		for _, plr in ipairs(Players:GetPlayers()) do
			local char = plr.Character
			if plr ~= player and char then
				if updateOne(char, char, pickPart(char), plr.Name, cfgP, root, camPos) then
					pCount += 1
				end
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
			else
				if updateCluster(g, poolUsed + 1, cfgI, root, camPos) then
					poolUsed += 1
					iCount += #g
					gCount += 1
				end
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
		if chipP then
			chipP.Text = "👤  " .. pCount
			chipM.Text = "👹  " .. mCount
			chipI.Text = "🎒  " .. iCount
		end
		if monsterInfo then
			local t = S.EspMonster and ("Monster terdeteksi: " .. mCount) or "ESP Monster belum aktif."
			if monsterInfo.Text ~= t then monsterInfo.Text = t end
		end
		if itemInfo then
			local t = S.EspItem
				and ("Item: " .. iCount .. "  ·  ESP tampil: " .. gCount .. "  ·  dipelajari: " .. learnedCount)
				or "ESP Item belum aktif."
			if itemInfo.Text ~= t then itemInfo.Text = t end
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if plr.Character then removeEsp(plr.Character) end
end)

----------------------------------------------------------------
-- GUI: DASAR
----------------------------------------------------------------
local gui = new("ScreenGui", {
	Name = "ToolkitUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, player:WaitForChild("PlayerGui"))

-- Tracer (garis dari bawah layar ke target)
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

----------------------------------------------------------------
-- GUI: JENDELA
----------------------------------------------------------------
local BASE_W, BASE_H = 400, 340

local main = new("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -12, 0.5, 0),
	Size = UDim2.fromOffset(BASE_W, BASE_H),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, gui)
corner(main, 18)
new("UIGradient", {
	Color = ColorSequence.new(Color3.fromRGB(26, 24, 40), Color3.fromRGB(12, 12, 18)),
	Rotation = 90,
}, main)

local mainStroke = outline(main, WHITE, 2, 0)
local glow = new("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.accent),
		ColorSequenceKeypoint.new(0.35, C.accent2),
		ColorSequenceKeypoint.new(0.7, C.cyan),
		ColorSequenceKeypoint.new(1, C.accent),
	}),
}, mainStroke)

local rootUi = new("Frame", {
	Size = UDim2.fromOffset(BASE_W, BASE_H),
	BackgroundTransparency = 1,
}, main)
local uiScale = new("UIScale", { Scale = 1 }, rootUi)

local function applyScale()
	local vp = workspace.CurrentCamera.ViewportSize
	local fit = math.clamp(math.min((vp.Y - 30) / BASE_H, (vp.X - 20) / BASE_W), 0.5, 1)
	local sc = fit * S.UiScale
	uiScale.Scale = sc
	main.Size = UDim2.fromOffset(BASE_W * sc, BASE_H * sc)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
applyScale()

RunService.Heartbeat:Connect(function(dt)
	if main.Visible then glow.Rotation = (glow.Rotation + dt * 45) % 360 end
end)

-- Header
local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 46),
	BackgroundTransparency = 1,
	Active = true,
}, rootUi)

local logo = new("TextLabel", {
	Size = UDim2.fromOffset(30, 30),
	Position = UDim2.fromOffset(12, 8),
	BackgroundColor3 = WHITE,
	Text = "👁",
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	TextColor3 = WHITE,
}, header)
corner(logo, 10)
new("UIGradient", { Color = ColorSequence.new(C.accent, C.accent2), Rotation = 45 }, logo)

local titleL = new("TextLabel", {
	Size = UDim2.fromOffset(150, 20),
	Position = UDim2.fromOffset(50, 6),
	BackgroundTransparency = 1,
	Text = "TOOLKIT",
	Font = Enum.Font.GothamBlack,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = WHITE,
}, header)
new("UIGradient", { Color = ColorSequence.new(WHITE, Color3.fromRGB(190, 190, 255)) }, titleL)

local pageTitle = new("TextLabel", {
	Size = UDim2.new(1, -170, 0, 14),
	Position = UDim2.fromOffset(50, 26),
	BackgroundTransparency = 1,
	Text = "",
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.sub,
}, header)

local function headerBtn(text, xOff, color)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, xOff, 0, 8),
		BackgroundColor3 = color,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = WHITE,
	}, header)
	corner(b, 10)
	return b
end

local lockBtn = headerBtn("🔓", -78, C.card)
local minBtn = headerBtn("—", -42, C.danger)

local divider = new("Frame", {
	Size = UDim2.new(1, -24, 0, 2),
	Position = UDim2.fromOffset(12, 46),
	BackgroundColor3 = WHITE,
	BorderSizePixel = 0,
}, rootUi)
corner(divider, 1)
new("UIGradient", { Color = ColorSequence.new(C.accent, C.accent2, C.cyan) }, divider)

-- Orb (tombol melayang saat menu ditutup)
local orb = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -14, 0.5, 0),
	Size = UDim2.fromOffset(50, 50),
	BackgroundColor3 = WHITE,
	Text = "👁",
	TextSize = 24,
	Font = Enum.Font.GothamBold,
	TextColor3 = WHITE,
	Visible = false,
	AutoButtonColor = false,
}, gui)
corner(orb, 25)
new("UIGradient", { Color = ColorSequence.new(C.accent, C.accent2), Rotation = 45 }, orb)
outline(orb, WHITE, 2, 0.5)

local function setOpen(v)
	main.Visible = v
	orb.Visible = not v
end
minBtn.MouseButton1Click:Connect(function() setOpen(false) end)

local function makeDraggable(handle, target, respectLock, onTap)
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
			if moved and not (respectLock and S.Locked) then
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end
	end)
end
makeDraggable(header, main, true, nil)
makeDraggable(orb, orb, false, function() setOpen(true) end)

-- Sidebar
local sidebar = new("Frame", {
	Size = UDim2.fromOffset(62, 280),
	Position = UDim2.fromOffset(8, 54),
	BackgroundColor3 = C.side,
}, rootUi)
corner(sidebar, 14)
outline(sidebar, C.line, 1, 0.7)

local indicator = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.new(1, -8, 0, 50),
	Position = UDim2.new(0.5, 0, 0, 5),
	BackgroundColor3 = WHITE,
	ZIndex = 1,
}, sidebar)
corner(indicator, 11)
new("UIGradient", { Color = ColorSequence.new(C.accent, C.accent2), Rotation = 60 }, indicator)

local tabHolder = new("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ZIndex = 2,
}, sidebar)
new("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, tabHolder)
new("UIPadding", { PaddingTop = UDim.new(0, 5) }, tabHolder)

local content = new("Frame", {
	Size = UDim2.fromOffset(BASE_W - 86, 280),
	Position = UDim2.fromOffset(78, 54),
	BackgroundTransparency = 1,
}, rootUi)

local pages, tabs = {}, {}
local tabOrder = 0

local function setTab(name)
	for n, p in pairs(pages) do
		local sel = (n == name)
		p.page.Visible = sel
		tabs[n].name.TextColor3 = sel and WHITE or C.sub
		if sel then
			pageTitle.Text = p.title
			tween(indicator, { Position = UDim2.new(0.5, 0, 0, 5 + (tabs[n].idx - 1) * 54) }, 0.22)
		end
	end
end

local function newPage(name, icon, title)
	tabOrder += 1
	local btn = new("TextButton", {
		Size = UDim2.new(1, -8, 0, 50),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = tabOrder,
	}, tabHolder)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 5),
		BackgroundTransparency = 1,
		Text = icon,
		TextSize = 19,
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
		PaddingBottom = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 2),
	}, page)

	pages[name] = { page = page, title = title }
	tabs[name] = { name = nameL, idx = tabOrder }
	btn.MouseButton1Click:Connect(function() setTab(name) end)
	return page
end

local pageSpawn = newPage("SPAWN", "📍", "Titik spawn")
local pageEsp = newPage("ESP", "👁", "ESP · Manusia, Monster, Item")
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
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
	}, f)
	corner(bar, 2)
	new("UIGradient", { Color = ColorSequence.new(C.accent, C.accent2), Rotation = 90 }, bar)
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
		Size = UDim2.new(1, 0, 0, height or 42),
		BackgroundColor3 = C.card,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = nextOrder(),
	}, page)
	corner(r, 12)
	outline(r, C.line, 1, 0.65)
	return r
end

local function rowLabel(r, text, rightPad, y, h)
	return new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -(rightPad or 64), 0, h or 42),
		Position = UDim2.fromOffset(12, y or 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = text,
	}, r)
end

local function group(page, title, color)
	local hdr = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = C.card,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = nextOrder(),
	}, page)
	corner(hdr, 12)
	outline(hdr, color, 1.2, 0.45)
	local bar = new("Frame", {
		Size = UDim2.fromOffset(4, 20),
		Position = UDim2.new(0, 9, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, hdr)
	corner(bar, 2)
	new("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.fromOffset(22, 0),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = color,
	}, hdr)
	local arrow = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1,
		Text = "▼",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = C.sub,
	}, hdr)

	local body = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
	}, page)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, body)

	hdr.MouseButton1Click:Connect(function()
		body.Visible = not body.Visible
		arrow.Text = body.Visible and "▼" or "▶"
	end)
	return body
end

local function toggle(page, label, key, onChange)
	local r = row(page)
	rowLabel(r, label, 70)
	local track = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(44, 24),
		BackgroundColor3 = C.off,
	}, r)
	corner(track, 12)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = WHITE,
	}, track)
	corner(knob, 9)

	local function refresh()
		local on = S[key]
		tween(track, { BackgroundColor3 = on and C.on or C.off })
		tween(knob, { Position = on and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
	end
	setters[key] = function(v)
		S[key] = v
		refresh()
		if onChange then onChange() end
	end
	r.MouseButton1Click:Connect(function() setters[key](not S[key]) end)
	refresh()
end

local function slider(page, label, key, min, max, step, onChange, fmt)
	local r = row(page, 56)
	rowLabel(r, label, 100, 2, 28)
	local val = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 2),
		Size = UDim2.fromOffset(80, 28),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.cyan,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, r)
	local track = new("Frame", {
		Size = UDim2.new(1, -28, 0, 6),
		Position = UDim2.new(0, 14, 0, 38),
		BackgroundColor3 = C.off,
		BorderSizePixel = 0,
	}, r)
	corner(track, 3)
	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
	}, track)
	corner(fill, 3)
	new("UIGradient", { Color = ColorSequence.new(C.accent, C.accent2) }, fill)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = WHITE,
		ZIndex = 2,
	}, track)
	corner(knob, 9)
	outline(knob, C.accent, 2, 0)

	local function refresh()
		local t = (S[key] - min) / (max - min)
		fill.Size = UDim2.fromScale(t, 1)
		knob.Position = UDim2.new(t, 0, 0.5, 0)
		val.Text = fmt and fmt(S[key]) or tostring(S[key])
	end

	local hit = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.fromOffset(0, 24),
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

local function segmented(page, label, key, options, onChange)
	local r = row(page, 70)
	rowLabel(r, label, 20, 2, 28)
	local holder = new("Frame", {
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.fromOffset(10, 32),
		BackgroundColor3 = C.bg,
	}, r)
	corner(holder, 10)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, holder)
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3),
	}, holder)

	local btns = {}
	local n = #options
	local function refresh()
		for i, o in ipairs(options) do
			local sel = (o[1] == S[key])
			btns[i].BackgroundColor3 = sel and C.accent or C.bg
			btns[i].TextColor3 = sel and WHITE or C.sub
		end
	end
	for i, o in ipairs(options) do
		local b = new("TextButton", {
			Size = UDim2.new(1 / n, -3, 0, 24),
			BackgroundColor3 = C.bg,
			Text = o[2],
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = C.sub,
			AutoButtonColor = false,
			LayoutOrder = i,
		}, holder)
		corner(b, 8)
		btns[i] = b
		b.MouseButton1Click:Connect(function()
			S[key] = o[1]
			refresh()
			if onChange then onChange() end
		end)
	end
	refresh()
end

local function swatches(page, label, key)
	local r = row(page, 68)
	rowLabel(r, label, 20, 2, 28)
	local holder = new("Frame", {
		Size = UDim2.new(1, -20, 0, 28),
		Position = UDim2.fromOffset(12, 32),
		BackgroundTransparency = 1,
	}, r)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 7),
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
			Size = UDim2.fromOffset(26, 26),
			BackgroundColor3 = c[2],
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = i,
		}, holder)
		corner(b, 13)
		strokes[i] = outline(b, WHITE, 2.5, 1)
		b.MouseButton1Click:Connect(function()
			S[key] = i
			refresh()
		end)
	end
	refresh()
end

local function actionButton(page, text, color, onClick)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = color,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = WHITE,
		LayoutOrder = nextOrder(),
	}, page)
	corner(b, 12)
	new("UIGradient", {
		Color = ColorSequence.new(WHITE, Color3.fromRGB(205, 205, 215)),
		Rotation = 90,
	}, b)
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
	corner(l, 12)
	outline(l, C.line, 1, 0.65)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
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
		Size = UDim2.new(1, 0, 0, 40),
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
	corner(box, 12)
	outline(box, C.accent, 1.2, 0.55)
	box.FocusLost:Connect(function() onSubmit(box.Text) end)
	return box
end

local function meters(v) return v .. "m" end
local function studs(v) return v .. " stud" end
local function percent(v) return math.floor(v * 100 + 0.5) .. "%" end

----------------------------------------------------------------
-- ISI: SPAWN
----------------------------------------------------------------
section(pageSpawn, "Status")
local spawnStatus = statusCard(pageSpawn, "Belum ada spawn point.")

section(pageSpawn, "Aksi")
actionButton(pageSpawn, "📍  Simpan Spawn Point", C.on, function()
	local char = player.Character
	local r = getRoot()
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not (r and hum and hum.Health > 0) then
		spawnStatus.Text = "Tidak bisa menyimpan: karakter tidak ada atau sudah mati."
		return
	end
	saved = r.CFrame
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
-- ISI: ESP
----------------------------------------------------------------
local chipRow = new("Frame", {
	Size = UDim2.new(1, 0, 0, 34),
	BackgroundTransparency = 1,
	LayoutOrder = nextOrder(),
}, pageEsp)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, chipRow)

local function chip(icon, color, ord)
	local f = new("Frame", {
		Size = UDim2.new(1 / 3, -4, 1, 0),
		BackgroundColor3 = C.card,
		LayoutOrder = ord,
	}, chipRow)
	corner(f, 12)
	outline(f, color, 1.2, 0.45)
	return new("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = icon .. "  0",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = color,
	}, f)
end
chipP = chip("👤", COLORS[1][2], 1)
chipM = chip("👹", COLORS[2][2], 2)
chipI = chip("🎒", COLORS[4][2], 3)

toggle(pageEsp, "👁  ESP Semua (master)", "EspAll", function()
	for _, k in ipairs({ "EspPlayer", "EspMonster", "EspItem" }) do
		if setters[k] then setters[k](S.EspAll) end
	end
end)

-- 👤 MANUSIA
local gPlayer = group(pageEsp, "👤  MANUSIA", COLORS[1][2])
toggle(gPlayer, "ESP Manusia", "EspPlayer")
toggle(gPlayer, "Tampilkan nama", "PName")
toggle(gPlayer, "Tampilkan jarak", "PDist")
toggle(gPlayer, "Garis tracer", "PTracer")
swatches(gPlayer, "Warna", "PColor")
toggle(gPlayer, "Batas jarak", "PLimitOn")
slider(gPlayer, "Jarak maksimal", "PLimit", 50, 2000, 50, nil, meters)

-- 👹 MONSTER
local gMonster = group(pageEsp, "👹  MONSTER", COLORS[2][2])
toggle(gMonster, "ESP Monster", "EspMonster", function()
	if S.EspMonster then startMonsterTrack() else stopMonsterTrack() end
end)
monsterInfo = statusCard(gMonster, "ESP Monster belum aktif.")
toggle(gMonster, "Tampilkan nama", "MName")
toggle(gMonster, "Tampilkan jarak", "MDist")
toggle(gMonster, "Pakai nama asli model", "MRealName")
toggle(gMonster, "Garis tracer", "MTracer")
swatches(gMonster, "Warna", "MColor")
toggle(gMonster, "Batas jarak", "MLimitOn")
slider(gMonster, "Jarak maksimal", "MLimit", 50, 2000, 50, nil, meters)
textInput(gMonster, "Filter nama monster, contoh: zombie", function(text)
	S.MonsterFilter = trim(text)
	if S.EspMonster then startMonsterTrack() end
end)
infoLabel(gMonster, "Filter kosong = otomatis (punya Humanoid / AnimationController, atau nama berisi monster, enemy, mob, zombie, boss, npc).")

-- 🎒 ITEM
local gItem = group(pageEsp, "🎒  ITEM", COLORS[4][2])
local function restartItems()
	if S.EspItem then startItemTrack() end
end

toggle(gItem, "ESP Item", "EspItem", function()
	if S.EspItem then startItemTrack() else stopItemTrack() end
end)
itemInfo = statusCard(gItem, "ESP Item belum aktif.")
toggle(gItem, "Gabung item berdekatan", "ItemMerge")
slider(gItem, "Jarak gabung", "ItemMergeDist", 2, 30, 1, nil, studs)
toggle(gItem, "Tampilkan nama", "IName")
toggle(gItem, "Tampilkan jarak", "IDist")
toggle(gItem, "Pakai nama asli item", "IRealName")
toggle(gItem, "Garis tracer", "ITracer")
swatches(gItem, "Warna", "IColor")
toggle(gItem, "Batas jarak", "ILimitOn")
slider(gItem, "Jarak maksimal", "ILimit", 50, 2000, 50, nil, meters)
segmented(gItem, "Mode deteksi item", "ItemMode", {
	{ "auto", "Otomatis" },
	{ "small", "Semua kecil" },
	{ "learned", "Diajari" },
}, restartItems)
textInput(gItem, "Filter nama item, contoh: key", function(text)
	S.ItemFilter = trim(text)
	restartItems()
end)

local diagCard = statusCard(gItem, "")
diagCard.Visible = false

actionButton(gItem, "➕  Ajari item terdekat", C.accent, function()
	task.spawn(function()
		local list = nearestParts(20, 60)
		local top = list[1]
		if not top then
			spawnStatus.Text = "Tidak ada objek dekat untuk diajari."
			diagCard.Visible = true
			diagCard.Text = "Tidak ada objek dekat. Berdirilah dekat item lalu coba lagi."
			return
		end
		local sig = sigOf(top.p)
		if not learned[sig] then
			learned[sig] = top.p.Name
			learnedCount += 1
		end
		restartItems()
		diagCard.Visible = true
		diagCard.Text = "Dipelajari: " .. top.p.Name .. " (" .. math.floor(top.dist) .. "m)"
	end)
end)

actionButton(gItem, "🔍  Cek objek di sekitar", C.cyan, function()
	task.spawn(function()
		diagCard.Visible = true
		diagCard.Text = "Memindai…"
		local list = nearestParts(60, 80)
		if #list == 0 then
			diagCard.Text = "Tidak ada objek dalam jarak 80 m."
			return
		end
		local out = {}
		for i = 1, math.min(6, #list) do
			out[#out + 1] = string.format("%d. %s · %dm", i, describe(list[i].p), math.floor(list[i].dist))
		end
		diagCard.Text = table.concat(out, "\n")
	end)
end)

actionButton(gItem, "🧹  Lupakan item yang diajari", C.danger, function()
	table.clear(learned)
	learnedCount = 0
	restartItems()
end)

infoLabel(gItem, "Item yang berdekatan (dalam Jarak gabung) ditampilkan sebagai satu ESP, contoh: Item ×3. Matikan 'Gabung item berdekatan' kalau mau satu ESP per item.")

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
slider(pageVisual, "Nilai FOV", "Fov", 40, 120, 1)
infoLabel(pageVisual, "Saat dimatikan, kabut, cahaya, dan FOV kembali seperti semula.")

----------------------------------------------------------------
-- ISI: SETELAN
----------------------------------------------------------------
local function refreshLock()
	lockBtn.Text = S.Locked and "🔒" or "🔓"
	tween(lockBtn, { BackgroundColor3 = S.Locked and C.on or C.card })
	glow.Color = S.Locked
		and ColorSequence.new(C.on, Color3.fromRGB(120, 255, 190), C.on)
		or ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.accent),
			ColorSequenceKeypoint.new(0.35, C.accent2),
			ColorSequenceKeypoint.new(0.7, C.cyan),
			ColorSequenceKeypoint.new(1, C.accent),
		})
end
lockBtn.MouseButton1Click:Connect(function() setters.Locked(not S.Locked) end)

section(pageSet, "Jendela")
toggle(pageSet, "Kunci posisi jendela", "Locked", refreshLock)
slider(pageSet, "Ukuran menu", "UiScale", 0.6, 1.3, 0.05, applyScale, percent)
slider(pageSet, "Transparansi menu", "Opacity", 0, 0.5, 0.05, function()
	main.BackgroundTransparency = S.Opacity
end, percent)

section(pageSet, "ESP")
segmented(pageSet, "Gaya sorotan", "Style", {
	{ "fill", "Isi + Garis" },
	{ "line", "Garis saja" },
})

section(pageSet, "Darurat")
actionButton(pageSet, "⛔  Matikan semua fitur", C.danger, function()
	for _, k in ipairs({
		"EspAll", "EspPlayer", "EspMonster", "EspItem",
		"PTracer", "MTracer", "ITracer", "NoFog", "Fullbright", "CustomFov",
	}) do
		if setters[k] then setters[k](false) end
	end
end)
infoLabel(pageSet, "Toolkit v6.1 · tombol — menyembunyikan menu jadi bola 👁 yang bisa digeser. Ketuk bola untuk membuka lagi.")

refreshLock()
setTab("ESP")

----------------------------------------------------------------
-- RESPAWN -> PINDAH KE SPAWN POINT
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

	spawnStatus.Text = "Respawn di spawn point tersimpan."
end)
