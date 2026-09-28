--[[
    Omar Hub v31
    Credit: Made by Omar
    For use ONLY in your own Roblox game.
--]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

local function log(m) pcall(function() print("[OmarHub] " .. m) end) end
log("=== Starting v31 ===")

-- ============ CONFIG ============
local Config = {
    ESP = {
        Enabled = true, ShowName = true, ShowDistance = true,
        ShowHealth = true, ShowBox = true, TeamCheck = false,
    },
    Aimbot = {
        Enabled = false, FOV = 150, TargetPart = "Head", TeamCheck = false,
        MaxDist = 1000, Smoothness = 100, LockMode = "Hold Mouse", WallCheck = false,
    },
    SilentAim = {
        Enabled = false, FOV = 220, TargetPart = "Head", TeamCheck = false,
        HitChance = 100,
    },
    ToggleKey = Enum.KeyCode.RightShift,
}

local connections = {}
local function track(c)
    if c then table.insert(connections, c) end
    return c
end
local function safeConnect(signal, fn)
    local ok, conn = pcall(function() return signal:Connect(fn) end)
    if ok and conn then
        table.insert(connections, conn)
        return conn
    end
    log("Failed to connect a signal")
    return nil
end
local mouseHeld = false

-- ============ UI ============
local ScreenGui
pcall(function()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OmarHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)
log("ScreenGui created")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 380)
Main.Position = UDim2.new(0.5, -130, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Main.BorderSizePixel = 0
Main.Active = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(140, 60, 220)
Stroke.Thickness = 1.5

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 34)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 15, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Omar Hub"
Title.TextColor3 = Color3.fromRGB(200, 130, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
ToggleBtn.Position = UDim2.new(1, -60, 0, 5)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 70)
ToggleBtn.Text = "–"
ToggleBtn.TextColor3 = Color3.fromRGB(220, 180, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 15
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = TitleBar
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(70, 20, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 150, 180)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Drag main panel
do
    local dragging, dragStart, startPos = false, nil, nil
    safeConnect(TitleBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, Main.Position
        end
    end)
    local function move(input)
        if not dragging then return end
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                  startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
    safeConnect(TitleBar.InputChanged, function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then move(i) end
    end)
    safeConnect(UserInputService.InputChanged, function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then move(i) end
    end)
    safeConnect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
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
local AimTabBtn    = makeTab("Aimbot", 1, 3)
local SilentTabBtn = makeTab("Silent", 2, 3)
local EspTabBtn    = makeTab("ESP",    3, 3)

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -20, 1, -116)
Body.Position = UDim2.new(0, 10, 0, 76)
Body.BackgroundTransparency = 1
Body.Parent = Main

local AimPage = Instance.new("ScrollingFrame")
AimPage.Size = UDim2.new(1, 0, 1, 0)
AimPage.BackgroundTransparency = 1
AimPage.BorderSizePixel = 0
AimPage.ScrollBarThickness = 3
AimPage.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 220)
AimPage.CanvasSize = UDim2.new(0, 0, 0, 340)
AimPage.Parent = Body

local SilentPage = Instance.new("ScrollingFrame")
SilentPage.Size = UDim2.new(1, 0, 1, 0)
SilentPage.BackgroundTransparency = 1
SilentPage.BorderSizePixel = 0
SilentPage.ScrollBarThickness = 3
SilentPage.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 220)
SilentPage.CanvasSize = UDim2.new(0, 0, 0, 340)
SilentPage.Visible = false
SilentPage.Parent = Body

local EspPage = Instance.new("ScrollingFrame")
EspPage.Size = UDim2.new(1, 0, 1, 0)
EspPage.BackgroundTransparency = 1
EspPage.BorderSizePixel = 0
EspPage.ScrollBarThickness = 3
EspPage.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 220)
EspPage.CanvasSize = UDim2.new(0, 0, 0, 240)
EspPage.Visible = false
EspPage.Parent = Body

local function setActiveTab(which)
    local map = { aim = AimPage, silent = SilentPage, esp = EspPage }
    local btns = { aim = AimTabBtn, silent = SilentTabBtn, esp = EspTabBtn }
    for k, page in pairs(map) do
        page.Visible = (k == which)
        btns[k].BackgroundColor3 = (k == which)
            and Color3.fromRGB(90, 40, 140)
            or  Color3.fromRGB(40, 20, 60)
    end
end
setActiveTab("aim")
safeConnect(AimTabBtn.MouseButton1Click, function() setActiveTab("aim") end)
safeConnect(SilentTabBtn.MouseButton1Click, function() setActiveTab("silent") end)
safeConnect(EspTabBtn.MouseButton1Click, function() setActiveTab("esp") end)

-- ============ WIDGETS ============
local function makeToggle(parent, text, yPos, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 32)
    Btn.Position = UDim2.new(0, 3, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
    Btn.Text = ""; Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -60, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(230, 200, 255)
    Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Btn

    local Pill = Instance.new("Frame")
    Pill.Size = UDim2.new(0, 40, 0, 20)
    Pill.Position = UDim2.new(1, -50, 0.5, -10)
    Pill.BackgroundColor3 = default and Color3.fromRGB(150, 70, 220) or Color3.fromRGB(60, 40, 80)
    Pill.BorderSizePixel = 0; Pill.Parent = Btn
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0; Knob.Parent = Pill
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = default
    safeConnect(Btn.MouseButton1Click, function()
        state = not state
        Pill.BackgroundColor3 = state and Color3.fromRGB(150, 70, 220) or Color3.fromRGB(60, 40, 80)
        Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        pcall(callback, state)
    end)
    return Btn
end

local function makeSwitch(parent, text, yPos, options, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 32)
    Frame.Position = UDim2.new(0, 3, 0, yPos)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
    Frame.BorderSizePixel = 0; Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0, 90, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(230, 200, 255)
    Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 120, 0, 22)
    Container.Position = UDim2.new(1, -128, 0.5, -11)
    Container.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
    Container.BorderSizePixel = 0; Container.Parent = Frame
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 5)

    for i, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1/#options, -2, 1, -4)
        b.Position = UDim2.new((i-1)/#options, 1, 0, 2)
        b.BackgroundColor3 = (opt == default) and Color3.fromRGB(150, 70, 220) or Color3.fromRGB(50, 30, 70)
        b.Text = opt; b.TextColor3 = Color3.fromRGB(240, 220, 255)
        b.Font = Enum.Font.GothamBold; b.TextSize = 11
        b.BorderSizePixel = 0; b.Parent = Container
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        safeConnect(b.MouseButton1Click, function()
            for _, other in ipairs(Container:GetChildren()) do
                if other:IsA("TextButton") then
                    other.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
                end
            end
            b.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
            pcall(callback, opt)
        end)
    end
    return Frame
end

local function makeSlider(parent, text, yPos, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 44)
    Frame.Position = UDim2.new(0, 3, 0, yPos)
    Frame.BackgroundTransparency = 1; Frame.Parent = parent

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 18)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text .. ": " .. default
    Lbl.TextColor3 = Color3.fromRGB(230, 200, 255)
    Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 14)
    Bar.Position = UDim2.new(0, 0, 0, 22)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
    Bar.BorderSizePixel = 0; Bar.Parent = Frame
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 7)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
    Fill.BorderSizePixel = 0; Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 7)

    local dragging = false
    safeConnect(Bar.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    safeConnect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    safeConnect(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + (max - min) * rel)
            Lbl.Text = text .. ": " .. val
            pcall(callback, val)
        end
    end)
    return Frame
end

-- Pages
local ay = 4
makeToggle(AimPage, "Aimbot Enabled", ay, Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end); ay = ay + 36
makeSwitch(AimPage, "Target:", ay, {"Head", "Torso"}, Config.Aimbot.TargetPart, function(v) Config.Aimbot.TargetPart = v end); ay = ay + 36
makeSwitch(AimPage, "Lock Mode:", ay, {"Hold Mouse", "Always"}, Config.Aimbot.LockMode, function(v) Config.Aimbot.LockMode = v end); ay = ay + 36
makeToggle(AimPage, "Team Check", ay, Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end); ay = ay + 36
makeToggle(AimPage, "Wall Check", ay, Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end); ay = ay + 36
makeSlider(AimPage, "Aimbot FOV", ay, 30, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end); ay = ay + 48
makeSlider(AimPage, "Smoothness", ay, 1, 100, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end); ay = ay + 48
AimPage.CanvasSize = UDim2.new(0, 0, 0, ay + 6)

local sy = 4
makeToggle(SilentPage, "Silent Aim Enabled", sy, Config.SilentAim.Enabled, function(v) Config.SilentAim.Enabled = v end); sy = sy + 36
makeSwitch(SilentPage, "Target:", sy, {"Head", "Torso"}, Config.SilentAim.TargetPart, function(v) Config.SilentAim.TargetPart = v end); sy = sy + 36
makeToggle(SilentPage, "Team Check", sy, Config.SilentAim.TeamCheck, function(v) Config.SilentAim.TeamCheck = v end); sy = sy + 36
makeSlider(SilentPage, "Silent FOV", sy, 30, 500, Config.SilentAim.FOV, function(v) Config.SilentAim.FOV = v end); sy = sy + 48
makeSlider(SilentPage, "Hit Chance %", sy, 0, 100, Config.SilentAim.HitChance, function(v) Config.SilentAim.HitChance = v end); sy = sy + 48
SilentPage.CanvasSize = UDim2.new(0, 0, 0, sy + 6)

local ey = 4
makeToggle(EspPage, "ESP Enabled", ey, Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end); ey = ey + 36
makeToggle(EspPage, "Show Name", ey, Config.ESP.ShowName, function(v) Config.ESP.ShowName = v end); ey = ey + 36
makeToggle(EspPage, "Show Distance", ey, Config.ESP.ShowDistance, function(v) Config.ESP.ShowDistance = v end); ey = ey + 36
makeToggle(EspPage, "Show Health", ey, Config.ESP.ShowHealth, function(v) Config.ESP.ShowHealth = v end); ey = ey + 36
makeToggle(EspPage, "Show Box", ey, Config.ESP.ShowBox, function(v) Config.ESP.ShowBox = v end); ey = ey + 36
makeToggle(EspPage, "Team Check", ey, Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end); ey = ey + 36
EspPage.CanvasSize = UDim2.new(0, 0, 0, ey + 6)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 18)
Credit.Position = UDim2.new(0, 0, 1, -20)
Credit.BackgroundTransparency = 1
Credit.Text = "Made by Omar"
Credit.TextColor3 = Color3.fromRGB(180, 100, 240)
Credit.Font = Enum.Font.GothamBold; Credit.TextSize = 12
Credit.Parent = Main
log("UI built")

-- ============ FOV RINGS ============
local FovRing = Instance.new("Frame")
FovRing.AnchorPoint = Vector2.new(0.5, 0.5)
FovRing.BackgroundTransparency = 1
FovRing.BorderSizePixel = 0
FovRing.ZIndex = 3
FovRing.Visible = false
FovRing.Parent = ScreenGui
Instance.new("UICorner", FovRing).CornerRadius = UDim.new(1, 0)
local FovStroke = Instance.new("UIStroke", FovRing)
FovStroke.Color = Color3.fromRGB(190, 110, 255)
FovStroke.Thickness = 2.5

local SilentRing = Instance.new("Frame")
SilentRing.AnchorPoint = Vector2.new(0.5, 0.5)
SilentRing.BackgroundTransparency = 1
SilentRing.BorderSizePixel = 0
SilentRing.ZIndex = 3
SilentRing.Visible = false
SilentRing.Parent = ScreenGui
Instance.new("UICorner", SilentRing).CornerRadius = UDim.new(1, 0)
local SilentStroke = Instance.new("UIStroke", SilentRing)
SilentStroke.Color = Color3.fromRGB(120, 220, 255)
SilentStroke.Thickness = 2
log("Rings built")

-- ============ OMAR PILL ============
local FloatPill = Instance.new("TextButton")
FloatPill.Size = UDim2.new(0, 72, 0, 28)
FloatPill.Position = UDim2.new(0, 14, 1, -80)
FloatPill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FloatPill.Text = "OMAR"
FloatPill.TextColor3 = Color3.fromRGB(180, 100, 240)
FloatPill.Font = Enum.Font.GothamBold
FloatPill.TextSize = 12
FloatPill.BorderSizePixel = 0
FloatPill.AutoButtonColor = false
FloatPill.ZIndex = 500
FloatPill.Visible = false
FloatPill.Parent = ScreenGui
Instance.new("UICorner", FloatPill).CornerRadius = UDim.new(0, 6)
local PillStroke = Instance.new("UIStroke", FloatPill)
PillStroke.Color = Color3.fromRGB(150, 70, 220)
PillStroke.Thickness = 1.5

do
    local dragging, moved, dragStart, startPos = false, false, nil, nil
    local function clamp(pos)
        local vp = Camera.ViewportSize
        local size = FloatPill.AbsoluteSize
        local w = size.X > 0 and size.X or FloatPill.Size.X.Offset
        local h = size.Y > 0 and size.Y or FloatPill.Size.Y.Offset
        return UDim2.new(0, math.clamp(pos.X.Offset, 0, vp.X - w),
                         0, math.clamp(pos.Y.Offset, 0, vp.Y - h))
    end
    safeConnect(FloatPill.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, dragStart, startPos = true, false, input.Position, FloatPill.Position
        end
    end)
    safeConnect(UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then moved = true end
            FloatPill.Position = clamp(UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                                 startPos.Y.Scale, startPos.Y.Offset + d.Y))
        end
    end)
    safeConnect(UserInputService.InputEnded, function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if not moved then
                Main.Visible = true
                FloatPill.Visible = false
            end
            dragging, moved = false, false
        end
    end)
end
log("Pill built")

-- ============ HELPERS ============
local function isTeammate(player, teamCheckOn)
    if not teamCheckOn then return false end
    if player == LocalPlayer then return false end
    local a, b = player.Team, LocalPlayer.Team
    if a == nil or b == nil then return false end
    return a == b
end

local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function pickPart(char, partName)
    if not char then return nil end
    if partName == "Head" then
        local h = char:FindFirstChild("Head")
        if h and h:IsA("BasePart") then return h end
        return nil
    end
    return char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("LowerTorso")
        or char:FindFirstChild("HumanoidRootPart")
end

local function hasLineOfSight(targetPart)
    if not targetPart then return false end
    local myChar = LocalPlayer.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not myHead then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { myChar, targetPart.Parent }
    params.IgnoreWater = true
    local hit = Workspace:Raycast(myHead.Position, targetPart.Position - myHead.Position, params)
    return hit == nil
end

local function getCharTargets(teamCheckOn)
    local out = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if isTeammate(p, teamCheckOn) then continue end
        if not isAlive(p) then continue end
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            out[#out + 1] = char
        end
    end
    return out
end
log("Helpers ready")

-- ============ ESP (Highlight + Billboard) ============
local espObjects = {}

local function createNativeESP(character)
    if espObjects[character] then return end
    local ok, err = pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "OmarHL"
        hl.FillColor = Color3.fromRGB(120, 50, 200)
        hl.FillTransparency = 0.7
        hl.OutlineColor = Color3.fromRGB(200, 130, 255)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = character
        hl.Parent = ScreenGui

        local bb = Instance.new("BillboardGui")
        bb.Name = "OmarBB"
        bb.Size = UDim2.new(0, 200, 0, 44)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        bb.Parent = ScreenGui

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, 0, 0, 20)
        nameLbl.BackgroundTransparency = 1
        nameLbl.TextColor3 = Color3.fromRGB(230, 200, 255)
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.TextStrokeTransparency = 0
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 14
        nameLbl.Text = ""
        nameLbl.Parent = bb

        local distLbl = Instance.new("TextLabel")
        distLbl.Size = UDim2.new(1, 0, 0, 16)
        distLbl.Position = UDim2.new(0, 0, 0, 20)
        distLbl.BackgroundTransparency = 1
        distLbl.TextColor3 = Color3.fromRGB(200, 140, 255)
        distLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLbl.TextStrokeTransparency = 0
        distLbl.Font = Enum.Font.Gotham
        distLbl.TextSize = 12
        distLbl.Text = ""
        distLbl.Parent = bb

        local hpBB = Instance.new("BillboardGui")
        hpBB.Size = UDim2.new(0, 40, 0, 4)
        hpBB.StudsOffset = Vector3.new(0, 2.5, 0)
        hpBB.AlwaysOnTop = true
        hpBB.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        hpBB.Parent = ScreenGui

        local hpBg = Instance.new("Frame")
        hpBg.Size = UDim2.new(1, 2, 1, 2)
        hpBg.Position = UDim2.new(0, -1, 0, -1)
        hpBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = hpBB
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)

        local hpFill = Instance.new("Frame")
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hpFill.BorderSizePixel = 0
        hpFill.Parent = hpBg
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)

        espObjects[character] = {
            hl = hl, bb = bb, hpBB = hpBB,
            nameLbl = nameLbl, distLbl = distLbl,
            hpFill = hpFill, hpBg = hpBg,
        }
    end)
    if not ok then log("createESP error: " .. tostring(err)) end
end

local function removeNativeESP(character)
    local d = espObjects[character]
    if not d then return end
    for _, obj in pairs(d) do
        pcall(function() obj:Destroy() end)
    end
    espObjects[character] = nil
end

pcall(function()
    safeConnect(Workspace.DescendantRemoving, function(obj)
        if espObjects[obj] then removeNativeESP(obj) end
    end)
end)
pcall(function()
    safeConnect(Players.PlayerRemoving, function(p)
        if p.Character then removeNativeESP(p.Character) end
    end)
end)
log("ESP system ready")

-- ============ MOUSE STATE ============
safeConnect(UserInputService.InputBegan, function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.MouseButton2
    or input.UserInputType == Enum.UserInputType.Touch then
        mouseHeld = true
    end
end)
safeConnect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.MouseButton2
    or input.UserInputType == Enum.UserInputType.Touch then
        mouseHeld = false
    end
end)

-- ============ AIMBOT ============
local function findAimbotTarget()
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local origin = Camera.CFrame.Position
    local best, bestScore = nil, math.huge

    for _, char in ipairs(getCharTargets(Config.Aimbot.TeamCheck)) do
        local part = pickPart(char, Config.Aimbot.TargetPart)
        if part then
            if not Config.Aimbot.WallCheck or hasLineOfSight(part) then
                local worldDist = (origin - part.Position).Magnitude
                if worldDist <= Config.Aimbot.MaxDist then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if screenDist <= Config.Aimbot.FOV then
                            local score = screenDist + (worldDist / 50)
                            if score < bestScore then
                                bestScore = score
                                best = part
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function aimStep()
    if Config.Aimbot.Enabled then
        local r = Config.Aimbot.FOV
        FovRing.Size = UDim2.new(0, r * 2, 0, r * 2)
        FovRing.Position = UDim2.new(0.5, 0, 0.5, 0)
        FovRing.Visible = true
    else
        FovRing.Visible = false
    end

    if Config.Aimbot.Enabled then
        if Config.Aimbot.LockMode ~= "Hold Mouse" or mouseHeld then
            local target = findAimbotTarget()
            if target then
                local alpha = math.clamp(Config.Aimbot.Smoothness / 100, 0.01, 1)
                local curCF = Camera.CFrame
                local desiredCF = CFrame.new(curCF.Position, target.Position)
                Camera.CFrame = curCF:Lerp(desiredCF, alpha)
            end
        end
    end
end

pcall(function()
    RunService:BindToRenderStep("OmarHubAimbot", Enum.RenderPriority.Camera.Value + 1, aimStep)
    log("Aimbot bound")
end)

-- ============ SILENT AIM ============
local silentFiring = false
local silentTapUntil = 0
local function silentTrigger() silentTapUntil = tick() + 0.2 end

safeConnect(UserInputService.InputBegan, function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        silentFiring = true
        silentTrigger()
    end
end)
safeConnect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        silentFiring = false
    end
end)

local function isFiringNow() return silentFiring or tick() < silentTapUntil end

local function findSilentTarget()
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local origin = Camera.CFrame.Position
    local best, bestScore = nil, math.huge

    for _, char in ipairs(getCharTargets(Config.SilentAim.TeamCheck)) do
        local part = pickPart(char, Config.SilentAim.TargetPart)
        if part and hasLineOfSight(part) then
            local sp, on = Camera:WorldToViewportPoint(part.Position)
            if on and sp.Z > 0 then
                local worldDist = (origin - part.Position).Magnitude
                local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if screenDist <= Config.SilentAim.FOV then
                    local score = screenDist + (worldDist / 50)
                    if score < bestScore then
                        bestScore = score
                        best = part
                    end
                end
            end
        end
    end
    return best
end

local originalRaycast, originalRaycastAll
pcall(function()
    originalRaycast    = Workspace.Raycast
    originalRaycastAll = Workspace.RaycastAll

    Workspace.Raycast = function(self, origin, direction, params)
        if self == Workspace and Config.SilentAim.Enabled and isFiringNow() then
            local ok, result = pcall(function()
                if Config.SilentAim.HitChance <= 0 then return nil end
                if Config.SilentAim.HitChance < 100 and math.random(1, 100) > Config.SilentAim.HitChance then
                    return nil
                end
                if (origin - Camera.CFrame.Position).Magnitude > 30 then return nil end
                if direction.Magnitude > 0.001 and direction.Unit:Dot(Camera.CFrame.LookVector) < 0.1 then
                    return nil
                end
                local target = findSilentTarget()
                if not target then return nil end
                return target.Position - origin
            end)
            if ok and result then
                return originalRaycast(self, origin, result, params)
            end
        end
        return originalRaycast(self, origin, direction, params)
    end

    Workspace.RaycastAll = function(self, origin, direction, params)
        if self == Workspace and Config.SilentAim.Enabled and isFiringNow() then
            local ok, result = pcall(function()
                if Config.SilentAim.HitChance <= 0 then return nil end
                local target = findSilentTarget()
                if not target then return nil end
                return target.Position - origin
            end)
            if ok and result then
                return originalRaycastAll(self, origin, result, params)
            end
        end
        return originalRaycastAll(self, origin, direction, params)
    end
    log("Silent aim installed")
end)

-- ============ RENDER LOOPS ============
pcall(function()
    safeConnect(RunService.RenderStepped, function()
        -- FOV rings
        if Config.Aimbot.Enabled then
            local r = Config.Aimbot.FOV
            FovRing.Size = UDim2.new(0, r * 2, 0, r * 2)
            FovRing.Position = UDim2.new(0.5, 0, 0.5, 0)
            FovRing.Visible = true
        else
            FovRing.Visible = false
        end

        if Config.SilentAim.Enabled then
            local r = Config.SilentAim.FOV
            SilentRing.Size = UDim2.new(0, r * 2, 0, r * 2)
            SilentRing.Position = UDim2.new(0.5, 0, 0.5, 0)
            SilentRing.Visible = true
        else
            SilentRing.Visible = false
        end

        -- ESP
        if not Config.ESP.Enabled then
            for _, d in pairs(espObjects) do
                if d.hl then d.hl.Enabled = false end
                if d.bb then d.bb.Enabled = false end
                if d.hpBB then d.hpBB.Enabled = false end
            end
        else
            local live = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                if isTeammate(p, Config.ESP.TeamCheck) then continue end
                if not isAlive(p) then continue end
                local char = p.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if char and hum and hrp then
                    live[char] = true
                    if not espObjects[char] then createNativeESP(char) end
                    local d = espObjects[char]
                    if d then
                        d.hl.Enabled = Config.ESP.ShowBox
                        d.bb.Enabled = Config.ESP.ShowName or Config.ESP.ShowDistance
                        d.hpBB.Enabled = Config.ESP.ShowHealth

                        local name = (p.DisplayName ~= "" and p.DisplayName) or p.Name
                        d.nameLbl.Visible = Config.ESP.ShowName
                        if Config.ESP.ShowName then d.nameLbl.Text = name end

                        d.distLbl.Visible = Config.ESP.ShowDistance
                        if Config.ESP.ShowDistance then
                            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                            d.distLbl.Text = string.format("[%d studs]", dist)
                        end

                        if Config.ESP.ShowHealth then
                            local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            d.hpFill.Size = UDim2.new(hpPct, 0, 1, 0)
                            d.hpFill.BackgroundColor3 = Color3.fromRGB(
                                math.floor(255 * (1 - hpPct)),
                                math.floor(255 * hpPct),
                                0
                            )
                        end
                    end
                end
            end
            for char, d in pairs(espObjects) do
                if not live[char] then
                    if d.hl then d.hl.Enabled = false end
                    if d.bb then d.bb.Enabled = false end
                    if d.hpBB then d.hpBB.Enabled = false end
                end
            end
        end
    end)
    log("Render loop bound")
end)

-- Restore autorotate
pcall(function()
    safeConnect(RunService.Stepped, function()
        if Config.Aimbot.Enabled then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and not hum.AutoRotate then hum.AutoRotate = true end
    end)
end)

-- ============ TOGGLE / CLOSE ============
local function setUIVisible(vis)
    Main.Visible = vis
    FloatPill.Visible = not vis
end

safeConnect(ToggleBtn.MouseButton1Click, function()
    log("Hide clicked")
    setUIVisible(false)
end)

safeConnect(UserInputService.InputBegan, function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then
        setUIVisible(not Main.Visible)
    end
end)

local function shutdown()
    log("Shutting down")
    pcall(function() RunService:UnbindFromRenderStep("OmarHubAimbot") end)
    if originalRaycast then
        pcall(function() Workspace.Raycast = originalRaycast end)
    end
    if originalRaycastAll then
        pcall(function() Workspace.RaycastAll = originalRaycastAll end)
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
    for _, d in pairs(espObjects) do
        for _, obj in pairs(d) do pcall(function() obj:Destroy() end) end
    end
    espObjects = {}
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    connections = {}
    pcall(function() ScreenGui:Destroy() end)
end

safeConnect(CloseBtn.MouseButton1Click, shutdown)

log("=== Loaded successfully ===")
