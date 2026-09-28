--[[
    Omar Hub
    Credit: Made by Omar
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============ CONFIG ============
local Config = {
    ESP = {
        Enabled = true,
        ShowName = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowBox = true,
        TeamCheck = true,
        IncludeNPCs = true,
    },
    Aimbot = {
        Enabled = false,
        FOV = 150,
        TargetPart = "Head",       -- "Head" or "Torso"
        TeamCheck = true,
        IncludeNPCs = true,
        MaxDistance = 1000,
        HardLock = true,
        Smoothness = 5,
        UseHoldKey = false,
        HoldKey = Enum.KeyCode.E,
        LockCamera = true,         -- write Camera.CFrame
        LockCharacter = true,      -- rotate HumanoidRootPart too (kills counter-rotation)
    },
    ToggleKey = Enum.KeyCode.RightShift,
}

-- ============ STATE ============
local connections = {}
local function track(c) table.insert(connections, c); return c end

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmarHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 400)
Main.Position = UDim2.new(0.5, -140, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Main.BorderSizePixel = 0
Main.Active = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(140, 60, 220)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.15

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 34)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 15, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(0, 60, 0, 4)
DragHandle.Position = UDim2.new(0.5, -30, 0, 4)
DragHandle.BackgroundColor3 = Color3.fromRGB(150, 90, 230)
DragHandle.BorderSizePixel = 0
DragHandle.Parent = TitleBar
Instance.new("UICorner", DragHandle).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Omar Hub"
Title.TextColor3 = Color3.fromRGB(200, 130, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local BtnRow = Instance.new("Frame")
BtnRow.Size = UDim2.new(0, 54, 0, 24)
BtnRow.Position = UDim2.new(1, -60, 0.5, -12)
BtnRow.BackgroundTransparency = 1
BtnRow.Parent = TitleBar

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
ToggleBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 70)
ToggleBtn.Text = "–"
ToggleBtn.TextColor3 = Color3.fromRGB(220, 180, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 15
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = BtnRow
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(0, 30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(70, 20, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 150, 180)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = BtnRow
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Drag via title bar
do
    local dragging, dragStart, startPos = false, nil, nil
    track(TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end))
    track(TitleBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                      startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                      startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

-- Tabs
local TabsBar = Instance.new("Frame")
TabsBar.Size = UDim2.new(1, -20, 0, 30)
TabsBar.Position = UDim2.new(0, 10, 0, 40)
TabsBar.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
TabsBar.BorderSizePixel = 0
TabsBar.Parent = Main
Instance.new("UICorner", TabsBar).CornerRadius = UDim.new(0, 6)

local function makeTab(name, order, total)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1/total, -2, 1, -4)
    tab.Position = UDim2.new((order-1)/total, 1, 0, 2)
    tab.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    tab.Text = name
    tab.TextColor3 = Color3.fromRGB(220, 190, 255)
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 12
    tab.BorderSizePixel = 0
    tab.Parent = TabsBar
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 5)
    return tab
end
local EspTabBtn = makeTab("ESP", 1, 2)
local AimTabBtn = makeTab("Aimbot", 2, 2)

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -20, 1, -116)
Body.Position = UDim2.new(0, 10, 0, 76)
Body.BackgroundTransparency = 1
Body.Parent = Main

local EspPage = Instance.new("ScrollingFrame")
EspPage.Size = UDim2.new(1, 0, 1, 0)
EspPage.BackgroundTransparency = 1
EspPage.BorderSizePixel = 0
EspPage.ScrollBarThickness = 3
EspPage.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 220)
EspPage.CanvasSize = UDim2.new(0, 0, 0, 260)
EspPage.Parent = Body

local AimPage = Instance.new("ScrollingFrame")
AimPage.Size = UDim2.new(1, 0, 1, 0)
AimPage.BackgroundTransparency = 1
AimPage.BorderSizePixel = 0
AimPage.ScrollBarThickness = 3
AimPage.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 220)
AimPage.CanvasSize = UDim2.new(0, 0, 0, 360)
AimPage.Visible = false
AimPage.Parent = Body

local function setActiveTab(which)
    if which == "esp" then
        EspPage.Visible = true; AimPage.Visible = false
        EspTabBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 140)
        AimTabBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    else
        EspPage.Visible = false; AimPage.Visible = true
        EspTabBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
        AimTabBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 140)
    end
end
setActiveTab("esp")
track(EspTabBtn.MouseButton1Click:Connect(function() setActiveTab("esp") end))
track(AimTabBtn.MouseButton1Click:Connect(function() setActiveTab("aim") end))

-- ============ WIDGETS ============
local function makeToggle(parent, text, yPos, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 32)
    Btn.Position = UDim2.new(0, 3, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
    Btn.Text = ""
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -60, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(230, 200, 255)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Btn

    local Pill = Instance.new("Frame")
    Pill.Size = UDim2.new(0, 40, 0, 20)
    Pill.Position = UDim2.new(1, -50, 0.5, -10)
    Pill.BackgroundColor3 = default and Color3.fromRGB(150, 70, 220) or Color3.fromRGB(60, 40, 80)
    Pill.BorderSizePixel = 0
    Pill.Parent = Btn
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Pill
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = default
    track(Btn.MouseButton1Click:Connect(function()
        state = not state
        Pill.BackgroundColor3 = state and Color3.fromRGB(150, 70, 220) or Color3.fromRGB(60, 40, 80)
        Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        callback(state)
    end))
    return Btn
end

local function makeSwitch(parent, text, yPos, options, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 32)
    Frame.Position = UDim2.new(0, 3, 0, yPos)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0, 90, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(230, 200, 255)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 120, 0, 22)
    Container.Position = UDim2.new(1, -128, 0.5, -11)
    Container.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
    Container.BorderSizePixel = 0
    Container.Parent = Frame
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 5)

    for i, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1/#options, -2, 1, -4)
        b.Position = UDim2.new((i-1)/#options, 1, 0, 2)
        b.BackgroundColor3 = (opt == default) and Color3.fromRGB(150, 70, 220) or Color3.fromRGB(50, 30, 70)
        b.Text = opt
        b.TextColor3 = Color3.fromRGB(240, 220, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.BorderSizePixel = 0
        b.Parent = Container
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        track(b.MouseButton1Click:Connect(function()
            for _, other in ipairs(Container:GetChildren()) do
                if other:IsA("TextButton") then
                    other.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
                end
            end
            b.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
            callback(opt)
        end))
    end
    return Frame
end

local function makeSlider(parent, text, yPos, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 44)
    Frame.Position = UDim2.new(0, 3, 0, yPos)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 18)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text .. ": " .. default
    Lbl.TextColor3 = Color3.fromRGB(230, 200, 255)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 14)
    Bar.Position = UDim2.new(0, 0, 0, 22)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
    Bar.BorderSizePixel = 0
    Bar.Parent = Frame
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 7)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 7)

    local dragging = false
    track(Bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end))
    track(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    track(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + (max - min) * rel)
            Lbl.Text = text .. ": " .. val
            callback(val)
        end
    end))
    return Frame
end

-- ============ ESP PAGE ============
local ey = 4
makeToggle(EspPage, "ESP Enabled", ey, Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end); ey = ey + 36
makeToggle(EspPage, "Show Name", ey, Config.ESP.ShowName, function(v) Config.ESP.ShowName = v end); ey = ey + 36
makeToggle(EspPage, "Show Distance", ey, Config.ESP.ShowDistance, function(v) Config.ESP.ShowDistance = v end); ey = ey + 36
makeToggle(EspPage, "Show Health", ey, Config.ESP.ShowHealth, function(v) Config.ESP.ShowHealth = v end); ey = ey + 36
makeToggle(EspPage, "Show Box", ey, Config.ESP.ShowBox, function(v) Config.ESP.ShowBox = v end); ey = ey + 36
makeToggle(EspPage, "Team Check", ey, Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end); ey = ey + 36
makeToggle(EspPage, "Include NPCs / Bots", ey, Config.ESP.IncludeNPCs, function(v) Config.ESP.IncludeNPCs = v end); ey = ey + 36
EspPage.CanvasSize = UDim2.new(0, 0, 0, ey + 6)

-- ============ AIMBOT PAGE ============
local ay = 4
makeToggle(AimPage, "Aimbot Enabled", ay, Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end); ay = ay + 36
makeSwitch(AimPage, "Target:", ay, {"Head", "Torso"}, Config.Aimbot.TargetPart, function(v) Config.Aimbot.TargetPart = v end); ay = ay + 36
makeToggle(AimPage, "Hard Lock", ay, Config.Aimbot.HardLock, function(v) Config.Aimbot.HardLock = v end); ay = ay + 36
makeToggle(AimPage, "Lock Camera", ay, Config.Aimbot.LockCamera, function(v) Config.Aimbot.LockCamera = v end); ay = ay + 36
makeToggle(AimPage, "Lock Character", ay, Config.Aimbot.LockCharacter, function(v) Config.Aimbot.LockCharacter = v end); ay = ay + 36
makeToggle(AimPage, "Team Check", ay, Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end); ay = ay + 36
makeToggle(AimPage, "Include NPCs / Bots", ay, Config.Aimbot.IncludeNPCs, function(v) Config.Aimbot.IncludeNPCs = v end); ay = ay + 36
makeToggle(AimPage, "Use Hold Key [E]", ay, Config.Aimbot.UseHoldKey, function(v) Config.Aimbot.UseHoldKey = v end); ay = ay + 36
makeSlider(AimPage, "FOV", ay, 30, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end); ay = ay + 48
makeSlider(AimPage, "Smoothness", ay, 2, 20, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end); ay = ay + 48
AimPage.CanvasSize = UDim2.new(0, 0, 0, ay + 6)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 18)
Credit.Position = UDim2.new(0, 0, 1, -20)
Credit.BackgroundTransparency = 1
Credit.Text = "Made by Omar"
Credit.TextColor3 = Color3.fromRGB(180, 100, 240)
Credit.Font = Enum.Font.GothamBold
Credit.TextSize = 12
Credit.Parent = Main

-- FOV circle
local FovCircle = Instance.new("Frame")
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundTransparency = 1
FovCircle.BorderSizePixel = 0
FovCircle.ZIndex = 0
FovCircle.Parent = ScreenGui
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)

local FovStroke = Instance.new("UIStroke", FovCircle)
FovStroke.Color = Color3.fromRGB(180, 100, 255)
FovStroke.Thickness = 1.5
FovStroke.Transparency = 0.3

-- ============ HELPERS ============
-- Strict teammate check: only true if BOTH sides have a non-nil team that matches
local function isTeammate(player)
    if player == LocalPlayer then return false end
    local a, b = player.Team, LocalPlayer.Team
    if a == nil or b == nil then return false end
    return a == b
end

local function isAliveHumanoid(hum)
    return hum and hum.Health > 0
end

-- Strict target part picker: NO fallback to HRP when Head/Torso requested
local function getTargetPartFromCharacter(char)
    if not char then return nil end
    if Config.Aimbot.TargetPart == "Head" then
        local h = char:FindFirstChild("Head")
        if h and h:IsA("BasePart") then return h end
        return nil
    end
    -- Torso: prefer UpperTorso (R15), then Torso (R6), then LowerTorso, then HRP
    local upper = char:FindFirstChild("UpperTorso")
    if upper and upper:IsA("BasePart") then return upper end
    local torso = char:FindFirstChild("Torso")
    if torso and torso:IsA("BasePart") then return torso end
    local lower = char:FindFirstChild("LowerTorso")
    if lower and lower:IsA("BasePart") then return lower end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then return hrp end
    return nil
end

-- ============ TARGET LIST ============
-- Returns a list of {name, character, humanoid, team, isNpc}
local function collectTargets()
    local list = {}

    -- Real players
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and isAliveHumanoid(hum) then
            list[#list + 1] = {
                name = player.DisplayName ~= "" and player.DisplayName or player.Name,
                character = char,
                humanoid = hum,
                team = player.Team,
                isNpc = false,
                player = player,
            }
        end
    end

    -- NPCs / bots: any model with a Humanoid that isn't a player's character
    if Config.ESP.IncludeNPCs or Config.Aimbot.IncludeNPCs then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and isAliveHumanoid(obj) then
                local model = obj.Parent
                if model and model:IsA("Model") then
                    -- skip if it belongs to a player
                    local plr = Players:GetPlayerFromCharacter(model)
                    if not plr then
                        local char = model
                        list[#list + 1] = {
                            name = model.Name,
                            character = char,
                            humanoid = obj,
                            team = nil,
                            isNpc = true,
                            player = nil,
                        }
                    end
                end
            end
        end
    end

    return list
end

-- ============ ESP DRAWINGS ============
-- Keyed by character Model (works for players AND NPCs)
local espObjects = {}

local function createESP(character)
    if espObjects[character] then return end
    local d = {
        Box = Drawing.new("Square"),
        BoxTL = Drawing.new("Line"),
        BoxTR = Drawing.new("Line"),
        BoxBL = Drawing.new("Line"),
        BoxBR = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarBg = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
    }
    d.Box.Thickness = 1
    d.Box.Color = Color3.fromRGB(160, 80, 255)
    d.Box.Filled = false
    d.Box.Transparency = 1
    d.Box.Visible = false

    for _, line in ipairs({d.BoxTL, d.BoxTR, d.BoxBL, d.BoxBR}) do
        line.Thickness = 2
        line.Color = Color3.fromRGB(200, 130, 255)
        line.Transparency = 1
        line.Visible = false
    end

    d.HealthBarBg.Filled = true
    d.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
    d.HealthBarBg.Transparency = 0.5
    d.HealthBarBg.Visible = false

    d.HealthBarOutline.Filled = false
    d.HealthBarOutline.Color = Color3.fromRGB(20, 10, 30)
    d.HealthBarOutline.Thickness = 1
    d.HealthBarOutline.Transparency = 1
    d.HealthBarOutline.Visible = false

    d.HealthBar.Filled = true
    d.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    d.HealthBar.Transparency = 1
    d.HealthBar.Visible = false

    for _, t in ipairs({d.Name, d.Distance}) do
        t.Size = 14
        t.Center = true
        t.Outline = true
        t.OutlineColor = Color3.fromRGB(0, 0, 0)
        t.Color = Color3.fromRGB(255, 255, 255)
        t.Font = 2
        t.Visible = false
    end
    d.Name.Color = Color3.fromRGB(220, 180, 255)
    d.Distance.Color = Color3.fromRGB(200, 140, 255)

    espObjects[character] = d
end

local function removeESP(character)
    local d = espObjects[character]
    if not d then return end
    for _, obj in pairs(d) do
        pcall(function() obj:Remove() end)
    end
    espObjects[character] = nil
end

local function setAllVisible(d, vis)
    for _, obj in pairs(d) do obj.Visible = vis end
end

-- Clean up ESP for a character when it's removed
track(Workspace.DescendantRemoving:Connect(function(obj)
    if espObjects[obj] then removeESP(obj) end
end))
track(Players.PlayerRemoving:Connect(function(player)
    if player.Character and espObjects[player.Character] then
        removeESP(player.Character)
    end
end))

-- ============ ESP RENDER ============
track(RunService.RenderStepped:Connect(function()
    if Config.Aimbot.Enabled then
        FovCircle.Visible = Main.Visible
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
        FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    else
        FovCircle.Visible = false
    end

    if not Config.ESP.Enabled then
        for _, d in pairs(espObjects) do setAllVisible(d, false) end
        return
    end

    local targets = collectTargets()
    local liveChars = {}

    for _, t in ipairs(targets) do
        local char = t.character
        liveChars[char] = true

        -- Team check (only applies to real players with a non-nil team)
        if Config.ESP.TeamCheck and not t.isNpc then
            local a, b = t.team, LocalPlayer.Team
            if a ~= nil and b ~= nil and a == b then
                if espObjects[char] then setAllVisible(espObjects[char], false) end
                continue
            end
        end

        if not espObjects[char] then createESP(char) end
        local d = espObjects[char]
        local hum = t.humanoid
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        local head = char:FindFirstChild("Head")
        if not (hrp and head and hum) then
            setAllVisible(d, false)
            continue
        end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

        if not onScreen or headPos.Z < 0 then
            setAllVisible(d, false)
            continue
        end

        local height = math.abs(rootPos.Y - headPos.Y)
        local width = height * 0.6
        local topLeft = Vector2.new(headPos.X - width / 2, headPos.Y)
        local bottomRight = Vector2.new(headPos.X + width / 2, rootPos.Y)
        local boxSize = bottomRight - topLeft

        if Config.ESP.ShowBox then
            d.Box.Visible = true
            d.Box.Size = boxSize
            d.Box.Position = topLeft

            local armLen = math.min(boxSize.X, boxSize.Y) * 0.25
            local br = topLeft + boxSize
            d.BoxTL.Visible = true
            d.BoxTL.From = Vector2.new(topLeft.X, topLeft.Y + armLen)
            d.BoxTL.To   = Vector2.new(topLeft.X, topLeft.Y)
            d.BoxTR.Visible = true
            d.BoxTR.From = Vector2.new(br.X - armLen, topLeft.Y)
            d.BoxTR.To   = Vector2.new(br.X, topLeft.Y)
            d.BoxBL.Visible = true
            d.BoxBL.From = Vector2.new(topLeft.X, br.Y - armLen)
            d.BoxBL.To   = Vector2.new(topLeft.X, br.Y)
            d.BoxBR.Visible = true
            d.BoxBR.From = Vector2.new(br.X - armLen, br.Y)
            d.BoxBR.To   = Vector2.new(br.X, br.Y)
        else
            d.Box.Visible = false
            d.BoxTL.Visible = false
            d.BoxTR.Visible = false
            d.BoxBL.Visible = false
            d.BoxBR.Visible = false
        end

        if Config.ESP.ShowName then
            d.Name.Visible = true
            d.Name.Text = t.isNpc and ("[NPC] " .. t.name) or t.name
            d.Name.Position = Vector2.new(headPos.X, topLeft.Y - 16)
        else
            d.Name.Visible = false
        end

        if Config.ESP.ShowDistance then
            d.Distance.Visible = true
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            d.Distance.Text = string.format("[%d studs]", math.floor(dist))
            d.Distance.Position = Vector2.new(headPos.X, bottomRight.Y + 2)
        else
            d.Distance.Visible = false
        end

        if Config.ESP.ShowHealth then
            local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barH = boxSize.Y
            local barX = bottomRight.X + 4

            d.HealthBarBg.Visible = true
            d.HealthBarBg.Size = Vector2.new(4, barH)
            d.HealthBarBg.Position = Vector2.new(barX, topLeft.Y)

            d.HealthBarOutline.Visible = true
            d.HealthBarOutline.Size = Vector2.new(4, barH)
            d.HealthBarOutline.Position = Vector2.new(barX, topLeft.Y)

            d.HealthBar.Visible = true
            d.HealthBar.Size = Vector2.new(4, barH * hpPct)
            d.HealthBar.Position = Vector2.new(barX, topLeft.Y + barH * (1 - hpPct))
            d.HealthBar.Color = Color3.fromRGB(
                math.floor(255 * (1 - hpPct)),
                math.floor(255 * hpPct),
                0
            )
        else
            d.HealthBar.Visible = false
            d.HealthBarBg.Visible = false
            d.HealthBarOutline.Visible = false
        end
    end

    -- Hide ESP for chars no longer alive/present
    for char, d in pairs(espObjects) do
        if not liveChars[char] then setAllVisible(d, false) end
    end
end))

-- ============ AIMBOT ============
local function getClosestTarget()
    local closest, closestDist = nil, math.huge
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local origin = Camera.CFrame.Position

    for _, t in ipairs(collectTargets()) do
        -- Team check (real players only)
        if Config.Aimbot.TeamCheck and not t.isNpc then
            local a, b = t.team, LocalPlayer.Team
            if a ~= nil and b ~= nil and a == b then continue end
        end
        -- Skip NPCs when disabled
        if t.isNpc and not Config.Aimbot.IncludeNPCs then continue end

        local part = getTargetPartFromCharacter(t.character)
        if not part then continue end

        if (origin - part.Position).Magnitude > Config.Aimbot.MaxDistance then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen or screenPos.Z < 0 then continue end

        local d2 = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if d2 <= Config.Aimbot.FOV and d2 < closestDist then
            closestDist = d2
            closest = part
        end
    end
    return closest
end

local AIMBOT_BIND_NAME = "OmarHubAimbot"
local bound = false

-- Cache the current target so we don't flicker between parts mid-shot
local currentTarget = nil

local function aimStep()
    if not Config.Aimbot.Enabled then return end
    if Config.Aimbot.UseHoldKey and not UserInputService:IsKeyDown(Config.Aimbot.HoldKey) then
        currentTarget = nil
        return
    end

    -- Re-acquire only if we have no target or it's gone
    if not currentTarget
    or not currentTarget.Parent
    or not currentTarget:IsDescendantOf(Workspace) then
        currentTarget = getClosestTarget()
    end
    -- Verify still inside FOV each frame
    if currentTarget then
        local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        if not on or (Vector2.new(sp.X, sp.Y) - center).Magnitude > Config.Aimbot.FOV * 1.2 then
            currentTarget = getClosestTarget()
        end
    end

    local target = currentTarget or getClosestTarget()
    if not target then return end

    -- Aim at exact center of chosen part
    local aimPos = target.Position

    if Config.Aimbot.LockCamera then
        local currentCF = Camera.CFrame
        local desiredCF = CFrame.new(currentCF.Position, aimPos)
        if Config.Aimbot.HardLock then
            Camera.CFrame = desiredCF
        else
            Camera.CFrame = currentCF:Lerp(desiredCF, 1 / Config.Aimbot.Smoothness)
        end
    end

    if Config.Aimbot.LockCharacter then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            hum.AutoRotate = false
            -- Rotate HRP to face target (kills counter-rotation from weapons/tools)
            local look = Vector3.new(aimPos.X, hrp.Position.Y, aimPos.Z)
            hrp.CFrame = CFrame.new(hrp.Position, look)
        end
    end
end

local function refreshBinding()
    if Config.Aimbot.Enabled then
        if not bound then
            RunService:BindToRenderStep(AIMBOT_BIND_NAME, Enum.RenderPriority.Camera.Value + 1, aimStep)
            bound = true
        end
        -- kill autorotate at start
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and Config.Aimbot.LockCharacter then hum.AutoRotate = false end
    else
        currentTarget = nil
        if bound then
            pcall(function() RunService:UnbindFromRenderStep(AIMBOT_BIND_NAME) end)
            bound = false
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

-- Watch Enabled toggle
local oldEnabled = Config.Aimbot.Enabled
track(RunService.Heartbeat:Connect(function()
    if Config.Aimbot.Enabled ~= oldEnabled then
        oldEnabled = Config.Aimbot.Enabled
        refreshBinding()
    end
end))

track(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    if Config.Aimbot.Enabled and Config.Aimbot.LockCharacter then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = false end
    end
end))

refreshBinding()

-- ============ TOGGLE / CLOSE ============
local function setUIVisible(vis)
    Main.Visible = vis
    if not vis then FovCircle.Visible = false end
end

track(ToggleBtn.MouseButton1Click:Connect(function()
    setUIVisible(not Main.Visible)
end))

track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then
        setUIVisible(not Main.Visible)
    end
end))

-- CLOSE = full exit
local function shutdown()
    -- Unbind aimbot
    pcall(function() RunService:UnbindFromRenderStep(AIMBOT_BIND_NAME) end)
    bound = false

    -- Restore character
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end

    -- Remove drawings
    for char, d in pairs(espObjects) do
        for _, obj in pairs(d) do
            pcall(function() obj:Remove() end)
        end
    end
    espObjects = {}

    -- Disconnect everything
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}

    -- Destroy GUI
    pcall(function() ScreenGui:Destroy() end)
end

track(CloseBtn.MouseButton1Click:Connect(shutdown))
