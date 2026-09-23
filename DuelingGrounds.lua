if getgenv().CombatCore then pcall(function() getgenv().CombatCore:Unload() end) end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlayerCharacter = Remotes:WaitForChild("PlayerCharacter")
local ResolveImpact = PlayerCharacter:WaitForChild("Request"):WaitForChild("ResolveImpact")
local RequestHitboxOnImpact = PlayerCharacter.Request:WaitForChild("RequestHitboxOnImpact")

local Core = {
    Alive = true,
    Targeting = true,
    AutoParry = true,
    HitboxReach = true,
    ReachRange = 9,
    CurrentTarget = nil,
    Connections = {}
}
getgenv().CombatCore = Core

local GameManager, TargetLockController, MatchController
local function refreshControllers()
    if GameManager and TargetLockController and MatchController then return true end
    if not GameManager then
        local ok, manager = pcall(require, ReplicatedStorage:WaitForChild("GameManager"))
        if ok then GameManager = manager end
    end
    if GameManager then
        pcall(function()
            TargetLockController = GameManager:GetController("TargetLockController")
            MatchController = GameManager:GetController("MatchController")
        end)
    end
    return TargetLockController ~= nil
end

local function getRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
end

local function isEnemy(model, player)
    if MatchController and type(MatchController.IsCharacterEnemyOfLocalPlayer) == "function" then
        local ok, enemy = pcall(function() return MatchController:IsCharacterEnemyOfLocalPlayer(model) end)
        if ok then return enemy == true end
    end
    if player and LocalPlayer.Team and player.Team then return player.Team ~= LocalPlayer.Team end
    return player ~= LocalPlayer
end

local function getClosestEnemy()
    local localRoot = getRoot()
    if not localRoot then return nil end
    
    local closest, minDist = nil, math.huge
    for _, model in CollectionService:GetTagged("CustomCharacter") do
        if model:IsDescendantOf(workspace) and model:GetAttribute("IsDead") ~= true then
            local userId = model:GetAttribute("UserId")
            local player = userId and Players:GetPlayerByUserId(userId)
            if userId ~= LocalPlayer.UserId and isEnemy(model, player) then
                local part = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                local hum = model:FindFirstChildOfClass("Humanoid")
                if part and hum and hum.Health > 0 then
                    local dist = (part.Position - localRoot.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = { Part = part, Distance = dist }
                    end
                end
            end
        end
    end
    return closest
end

local resolutionHookTarget, resolutionHookOriginal, resolutionHookInstalled
local function installImpactHook()
    if resolutionHookInstalled or not Core.AutoParry or type(hookfunction) ~= "function" or type(newcclosure) ~= "function" then return end
    
    local ok, handler = pcall(function() return GameManager:GetController("CharacterController"):GetLocalCharacterHandler() end)
    local manager = ok and handler and handler.ActionManager
    if not manager or type(manager._computeImpactResolution) ~= "function" then return end

    resolutionHookTarget = manager._computeImpactResolution
    local okHook, original = pcall(hookfunction, resolutionHookTarget, newcclosure(function(self, impactData)
        if not Core.Alive or not Core.AutoParry then return resolutionHookOriginal(self, impactData) end
        
        local characterHandler = self.CharacterHandler
        local pParry, pBlock = characterHandler.IsParrying, characterHandler.IsBlocking
        characterHandler.IsParrying = true
        characterHandler.IsBlocking = true
        
        local results = table.pack(resolutionHookOriginal(self, impactData))
        characterHandler.IsParrying = pParry
        characterHandler.IsBlocking = pBlock
        return table.unpack(results, 1, results.n)
    end))

    if okHook then
        resolutionHookOriginal = original
        resolutionHookInstalled = true
    end
end

if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" and type(newcclosure) == "function" then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        if Core.Alive and Core.AutoParry and self == ResolveImpact and method == "FireServer" then
            local args = { ... }
            if args[2] ~= "Parry" and args[2] ~= "Dodge" then
                args[2] = "Parry"
            end
            return oldNamecall(self, table.unpack(args))
        end
        
        if Core.Alive and Core.HitboxReach and self == RequestHitboxOnImpact and method == "FireServer" then
            local args = { ... }
            local target = Core.CurrentTarget
            local localRoot = getRoot()
            if localRoot and target and target.Part and target.Part:IsDescendantOf(workspace) and typeof(args[1]) == "CFrame" then
                local offset = target.Part.Position - localRoot.Position
                local distance = offset.Magnitude
                if distance > 0.05 and distance <= Core.ReachRange then
                    local reportedOrigin = target.Part.Position - (offset.Unit * 2.75)
                    args[1] = CFrame.lookAt(reportedOrigin, target.Part.Position)
                    return oldNamecall(self, table.unpack(args))
                end
            end
        end
        
        return oldNamecall(self, ...)
    end))
end

table.insert(Core.Connections, RunService.Heartbeat:Connect(function()
    if not Core.Alive then return end
    refreshControllers()
    installImpactHook()
    
    if Core.Targeting then
        local target = getClosestEnemy()
        Core.CurrentTarget = target
        if TargetLockController then
            pcall(function() TargetLockController:SetTarget(target and target.Part or nil) end)
        end
    end
end))

function Core:Unload()
    self.Alive = false
    for _, conn in ipairs(self.Connections) do pcall(function() conn:Disconnect() end) end
    if TargetLockController then pcall(function() TargetLockController:SetTarget(nil) end) end
    getgenv().CombatCore = nil
end

--// Dueling Grounds GUI
--// Animated Menu + Smooth X/● Toggle

local Core = getgenv().CombatCore
if not Core then return end

-- Default OFF
Core.AutoParry = false
Core.Targeting = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Hapus GUI lama
if getgenv().CombatCoreGUI then
	pcall(function()
		getgenv().CombatCoreGUI:Destroy()
	end)
end

-- ======================
-- SCREEN GUI
-- ======================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatCoreGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

getgenv().CombatCoreGUI = ScreenGui

-- ======================
-- LOGO
-- ======================

local LogoBtn = Instance.new("ImageButton")
LogoBtn.Name = "Logo"
LogoBtn.Size = UDim2.new(0, 55, 0, 55)
LogoBtn.Position = UDim2.new(0, 20, 0.5, -27)
LogoBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
LogoBtn.Image = "rbxassetid://112323672996641"
LogoBtn.ScaleType = Enum.ScaleType.Fit
LogoBtn.Active = true
LogoBtn.Parent = ScreenGui

Instance.new("UICorner", LogoBtn).CornerRadius = UDim.new(1, 0)

local LogoStroke = Instance.new("UIStroke", LogoBtn)
LogoStroke.Color = Color3.fromRGB(0, 140, 255)
LogoStroke.Thickness = 2

-- ======================
-- DRAG LOGO
-- ======================

local draggingLogo = false
local dragStartLogo
local startPosLogo

local function isInsideLogo(inputPos)
	local pos = LogoBtn.AbsolutePosition
	local size = LogoBtn.AbsoluteSize

	return inputPos.X >= pos.X
		and inputPos.X <= pos.X + size.X
		and inputPos.Y >= pos.Y
		and inputPos.Y <= pos.Y + size.Y
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		if isInsideLogo(input.Position) then
			draggingLogo = true
			dragStartLogo = input.Position
			startPosLogo = LogoBtn.Position
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		draggingLogo = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingLogo
		and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then

		local delta = input.Position - dragStartLogo

		LogoBtn.Position = UDim2.new(
			startPosLogo.X.Scale,
			startPosLogo.X.Offset + delta.X,
			startPosLogo.Y.Scale,
			startPosLogo.Y.Offset + delta.Y
		)
	end
end)

-- ======================
-- MAIN MENU
-- ======================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 280, 0, 220)
Main.Position = UDim2.new(0.5, -140, 0.5, -110)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BackgroundTransparency = 0
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Thickness = 1

local MainScale = Instance.new("UIScale")
MainScale.Scale = 0.82
MainScale.Parent = Main

-- ======================
-- TITLE
-- ======================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Dueling Grounds"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main

-- ======================
-- CLOSE
-- ======================

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Main

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ======================
-- SMOOTH TOGGLE
-- ======================

local function CreateToggle(name, default, callback, yPos)

	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -30, 0, 36)
	Frame.Position = UDim2.new(0, 15, 0, yPos)
	Frame.BackgroundTransparency = 1
	Frame.Parent = Main

	-- Label
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.65, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	-- Switch
	local Switch = Instance.new("TextButton")
	Switch.Size = UDim2.new(0, 52, 0, 28)
	Switch.Position = UDim2.new(1, -52, 0.5, -14)
	Switch.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	Switch.Text = ""
	Switch.AutoButtonColor = false
	Switch.Parent = Frame

	local SwitchCorner = Instance.new("UICorner")
	SwitchCorner.CornerRadius = UDim.new(1, 0)
	SwitchCorner.Parent = Switch

	local SwitchStroke = Instance.new("UIStroke")
	SwitchStroke.Color = Color3.fromRGB(65, 65, 75)
	SwitchStroke.Thickness = 1.5
	SwitchStroke.Parent = Switch

	-- Knob
	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.new(0, 22, 0, 22)
	Knob.Position = UDim2.new(0, 3, 0.5, -11)
	Knob.BackgroundColor3 = Color3.fromRGB(125, 125, 135)
	Knob.Parent = Switch

	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

	-- Icon
	local Icon = Instance.new("TextLabel")
	Icon.Size = UDim2.new(1, 0, 1, 0)
	Icon.BackgroundTransparency = 1
	Icon.Text = "X"
	Icon.TextColor3 = Color3.fromRGB(230, 230, 230)
	Icon.Font = Enum.Font.GothamBold
	Icon.TextSize = 12
	Icon.Parent = Knob

	local state = default

	-- posisi knob
	local OFF_POS = UDim2.new(0, 3, 0.5, -11)
	local ON_POS = UDim2.new(1, -25, 0.5, -11)

	local function update(animated)

		if state then

			-- merah menyala
			TweenService:Create(
				Switch,
				TweenInfo.new(
					0.22,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),
				{
					BackgroundColor3 = Color3.fromRGB(190, 30, 42)
				}
			):Play()

			TweenService:Create(
				SwitchStroke,
				TweenInfo.new(0.22),
				{
					Color = Color3.fromRGB(255, 65, 75),
					Thickness = 2
				}
			):Play()

			TweenService:Create(
				Knob,
				TweenInfo.new(
					0.28,
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.Out
				),
				{
					Position = ON_POS,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				}
			):Play()

			Icon.Text = "●"

		else

			TweenService:Create(
				Switch,
				TweenInfo.new(
					0.22,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),
				{
					BackgroundColor3 = Color3.fromRGB(40, 40, 48)
				}
			):Play()

			TweenService:Create(
				SwitchStroke,
				TweenInfo.new(0.22),
				{
					Color = Color3.fromRGB(65, 65, 75),
					Thickness = 1.5
				}
			):Play()

			TweenService:Create(
				Knob,
				TweenInfo.new(
					0.28,
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.Out
				),
				{
					Position = OFF_POS,
					BackgroundColor3 = Color3.fromRGB(125, 125, 135)
				}
			):Play()

			Icon.Text = "X"

		end
	end

	update(false)

	Switch.MouseButton1Click:Connect(function()

		state = not state

		-- animasi tekan
		TweenService:Create(
			Knob,
			TweenInfo.new(
				0.08,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size = UDim2.new(0, 19, 0, 19)
			}
		):Play()

		task.delay(0.08, function()

			TweenService:Create(
				Knob,
				TweenInfo.new(
					0.12,
					Enum.EasingStyle.Back,
					Enum.EasingDirection.Out
				),
				{
					Size = UDim2.new(0, 22, 0, 22)
				}
			):Play()

		end)

		update(true)

		callback(state)
	end)
end

-- ======================
-- SIDE TOGGLE
-- ======================

local SideFrame = Instance.new("Frame")
SideFrame.Name = "SideToggle"
SideFrame.Size = UDim2.new(0, 155, 0, 42)
SideFrame.Position = UDim2.new(1, -170, 0.4, 0)
SideFrame.BackgroundTransparency = 1
SideFrame.Visible = false
SideFrame.Parent = ScreenGui

local AutoParryBtn = Instance.new("TextButton")
AutoParryBtn.Size = UDim2.new(0, 115, 0, 36)
AutoParryBtn.Position = UDim2.new(0, 0, 0, 3)
AutoParryBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
AutoParryBtn.Text = "Auto Parry"
AutoParryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoParryBtn.Font = Enum.Font.GothamBold
AutoParryBtn.TextSize = 14
AutoParryBtn.AutoButtonColor = false
AutoParryBtn.Parent = SideFrame

Instance.new("UICorner", AutoParryBtn).CornerRadius = UDim.new(1, 0)

AutoParryBtn.MouseButton1Click:Connect(function()

	Core.AutoParry = not Core.AutoParry

	TweenService:Create(
		AutoParryBtn,
		TweenInfo.new(0.18),
		{
			BackgroundColor3 =
				Core.AutoParry
				and Color3.fromRGB(46, 160, 90)
				or Color3.fromRGB(70, 70, 80)
		}
	):Play()

end)

-- ======================
-- ARROW
-- ======================

local ArrowBtn = Instance.new("TextButton")
ArrowBtn.Size = UDim2.new(0, 32, 0, 32)
ArrowBtn.Position = UDim2.new(0, 120, 0, 5)
ArrowBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ArrowBtn.Text = "◀"
ArrowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ArrowBtn.Font = Enum.Font.GothamBold
ArrowBtn.TextSize = 14
ArrowBtn.AutoButtonColor = false
ArrowBtn.Parent = SideFrame

Instance.new("UICorner", ArrowBtn).CornerRadius = UDim.new(0, 8)

local isExpanded = true

ArrowBtn.MouseButton1Click:Connect(function()

	isExpanded = not isExpanded

	AutoParryBtn.Visible = isExpanded
	ArrowBtn.Text = isExpanded and "◀" or "▶"

	SideFrame.Size =
		isExpanded
		and UDim2.new(0, 155, 0, 42)
		or UDim2.new(0, 40, 0, 42)

end)

-- ======================
-- LOCK
-- ======================

local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0, 28, 0, 28)
LockBtn.Position = UDim2.new(0, 120, 0, 42)
LockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
LockBtn.Text = "🔓"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 14
LockBtn.Parent = SideFrame

Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 8)

local locked = false

LockBtn.MouseButton1Click:Connect(function()

	locked = not locked
	LockBtn.Text = locked and "🔒" or "🔓"

end)

-- ======================
-- DRAG SIDE
-- ======================

local draggingSide = false
local dragStartSide
local startPosSide

local function isNearArrow(inputPos)

	local arrowPos = ArrowBtn.AbsolutePosition
	local arrowSize = ArrowBtn.AbsoluteSize
	local center = arrowPos + arrowSize / 2

	local distance =
		(Vector2.new(inputPos.X, inputPos.Y)
		- Vector2.new(center.X, center.Y)).Magnitude

	return distance <= 48
end

UserInputService.InputBegan:Connect(function(input)

	if locked then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		if isNearArrow(input.Position) then

			draggingSide = true
			dragStartSide = input.Position
			startPosSide = SideFrame.Position

		end
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		draggingSide = false

	end
end)

UserInputService.InputChanged:Connect(function(input)

	if draggingSide
		and not locked
		and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then

		local delta = input.Position - dragStartSide

		SideFrame.Position = UDim2.new(
			startPosSide.X.Scale,
			startPosSide.X.Offset,
			startPosSide.Y.Scale,
			startPosSide.Y.Offset + delta.Y
		)

	end
end)

-- ======================
-- TOGGLES
-- ======================

CreateToggle("Auto Parry", false, function(val)

	Core.AutoParry = val

	AutoParryBtn.BackgroundColor3 =
		val
		and Color3.fromRGB(46, 160, 90)
		or Color3.fromRGB(70, 70, 80)

end, 55)

CreateToggle("Show Side Toggle", false, function(val)

	SideFrame.Visible = val

end, 100)

CreateToggle("Targeting", false, function(val)

	Core.Targeting = val

end, 145)

-- ======================
-- MENU ANIMATION
-- ======================

local menuOpen = false

local function ToggleMenu()

	menuOpen = not menuOpen

	if menuOpen then

		Main.Visible = true
		MainScale.Scale = 0.82
		Main.BackgroundTransparency = 1

		TweenService:Create(
			MainScale,
			TweenInfo.new(
				0.3,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),
			{
				Scale = 1
			}
		):Play()

		TweenService:Create(
			Main,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				BackgroundTransparency = 0
			}
		):Play()

	else

		TweenService:Create(
			MainScale,
			TweenInfo.new(
				0.18,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),
			{
				Scale = 0.82
			}
		):Play()

		local fade = TweenService:Create(
			Main,
			TweenInfo.new(
				0.15,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),
			{
				BackgroundTransparency = 1
			}
		)

		fade:Play()

		fade.Completed:Connect(function()

			if not menuOpen then
				Main.Visible = false
				Main.BackgroundTransparency = 0
				MainScale.Scale = 1
			end

		end)

	end
end

-- ======================
-- OPEN / CLOSE
-- ======================

LogoBtn.MouseButton1Click:Connect(ToggleMenu)

CloseBtn.MouseButton1Click:Connect(ToggleMenu)

UserInputService.InputBegan:Connect(function(input, gp)

	if gp then return end

	if input.KeyCode == Enum.KeyCode.RightControl then
		ToggleMenu()
	end

end)

print("Dueling Grounds GUI Loaded | Smooth Animated Toggle")
