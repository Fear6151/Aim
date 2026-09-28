--[[
    Omar Hub v28 — Diagnostic + Fallback ESP
    Credit: Made by Omar
--]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

local function log(msg) print("[OmarHub] " .. msg) end
log("Script starting...")

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
local function track(c) table.insert(connections, c); return c end
local mouseHeld = false

-- Detect Drawing availability
local drawingOK = false
pcall(function()
    if Drawing and Drawing.new then
        local test = Drawing.new("Circle")
        test:Remove()
        drawingOK = true
    end
end)
log("Drawing available: " .. tostring(drawingOK))

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmarHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
log("ScreenGui created")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 360)
Main.Position = UDim2.new(0.5, -130, 0.5, -180)
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

-- OMAR pill
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

log("Base UI created")

-- ============ WIRE UP BUTTONS FIRST (before any features) ============
local function setUIVisible(vis)
    Main.Visible = vis
    FloatPill.Visible = not vis
end

track(ToggleBtn.MouseButton1Click:Connect(function()
    log("Hide clicked")
    setUIVisible(false)
end))

track(CloseBtn.MouseButton1Click:Connect(function()
    log("Close clicked")
    -- We'll define full shutdown later, this just hides for now
    ScreenGui.Enabled = false
    task.wait(0.1)
    ScreenGui.Enabled = true
    -- Full shutdown attaches at the bottom
end))

track(FloatPill.MouseButton1Click:Connect(function()
    log("OMAR clicked")
    setUIVisible(true)
end))

track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then
        setUIVisible(not Main.Visible)
    end
end))

log("Base buttons wired")

-- Drag main panel
do
    local dragging, dragStart, startPos = false, nil, nil
    track(TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, Main.Position
            log("Drag start")
        end
    end))
    local function move(input)
        if not dragging then return end
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                  startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
    track(TitleBar.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then move(i) end
    end))
    track(UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then move(i) end
    end))
    track(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            if dragging then log("Drag end") end
            dragging = false
        end
    end))
end

-- Drag the OMAR pill
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
    track(FloatPill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, dragStart, startPos = true, false, input.Position, FloatPill.Position
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then moved = true end
            FloatPill.Position = clamp(UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                                 startPos.Y.Scale, startPos.Y.Offset + d.Y))
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if not moved then
                log("OMAR tap open")
                setUIVisible(true)
            end
            dragging, moved = false, false
        end
    end))
end

log("Drags wired")

-- ============ TABS ============
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
track(AimTabBtn.MouseButton1Click:Connect(function() setActiveTab("aim") end))
track(SilentTabBtn.MouseButton1Click:Connect(function() setActiveTab("silent") end))
track(EspTabBtn.MouseButton1Click:Connect(function() setActiveTab("esp") end))

log("Tabs wired")

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
    track(Bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end))
    track(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
    track(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + (max - min) * rel)
            Lbl.Text = text .. ": " .. val
            callback(val)
        end
    end))
    return Frame
end

-- Aimbot page
local ay = 4
makeToggle(AimPage, "Aimbot Enabled", ay, Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end); ay = ay + 36
makeSwitch(AimPage, "Target:", ay, {"Head", "Torso"}, Config.Aimbot.TargetPart, function(v) Config.Aimbot.TargetPart = v end); ay = ay + 36
makeSwitch(AimPage, "Lock Mode:", ay, {"Hold Mouse", "Always"}, Config.Aimbot.LockMode, function(v) Config.Aimbot.LockMode = v end); ay = ay + 36
makeToggle(AimPage, "Team Check", ay, Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end); ay = ay + 36
makeSlider(AimPage, "Aimbot FOV", ay, 30, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end); ay = ay + 48
makeSlider(AimPage, "Smoothness", ay, 1, 100, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end); ay = ay + 48
AimPage.CanvasSize = UDim2.new(0, 0, 0, ay + 6)

-- Silent page
local sy = 4
makeToggle(SilentPage, "Silent Aim Enabled", sy, Config.SilentAim.Enabled, function(v) Config.SilentAim.Enabled = v end); sy = sy + 36
makeSwitch(SilentPage, "Target:", sy, {"Head", "Torso"}, Config.SilentAim.TargetPart, function(v) Config.SilentAim.TargetPart = v end); sy = sy + 36
makeToggle(SilentPage, "Team Check", sy, Config.SilentAim.TeamCheck, function(v) Config.SilentAim.TeamCheck = v end); sy = sy + 36
makeSlider(SilentPage, "Silent FOV", sy, 30, 500, Config.SilentAim.FOV, function(v) Config.SilentAim.FOV = v end); sy = sy + 48
makeSlider(SilentPage, "Hit Chance %", sy, 0, 100, Config.SilentAim.HitChance, function(v) Config.SilentAim.HitChance = v end); sy = sy + 48
SilentPage.CanvasSize = UDim2.new(0, 0, 0, sy + 6)

-- ESP page
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

log("Widgets built")

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

-- Silent dot
local SilentDot = nil
if drawingOK then
    pcall(function()
        SilentDot = Drawing.new("Circle")
        SilentDot.Thickness = 2
        SilentDot.Color = Color3.fromRGB(120, 220, 255)
        SilentDot.Filled = false
        SilentDot.Radius = 12
        SilentDot.Visible = false
    end)
end

log("Rings created")

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

-- ============ ESP (Drawing OR Highlight fallback) ============
local espDrawing = {}   -- character -> {objects}
local espHighlight = {} -- character -> {highlight, billboard}

local function createDrawingESP(character)
    if espDrawing[character] then return end
    local d = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HP = Drawing.new("Square"),
        HPBg = Drawing.new("Square"),
    }
    d.Box.Thickness = 1
    d.Box.Color = Color3.fromRGB(160, 80, 255)
    d.Box.Filled = false
    d.Box.Transparency = 1
    d.Box.Visible = false
    for _, t in ipairs({d.Name, d.Distance}) do
        t.Size = 14; t.Center = true; t.Outline = true
        t.OutlineColor = Color3.fromRGB(0, 0, 0)
        t.Color = Color3.fromRGB(230, 200, 255)
        t.Font = 2; t.Visible = false
    end
    d.HPBg.Filled = true
    d.HPBg.Color = Color3.fromRGB(0, 0, 0)
    d.HPBg.Transparency = 0.5
    d.HPBg.Visible = false
    d.HP.Filled = true
    d.HP.Color = Color3.fromRGB(0, 255, 0)
    d.HP.Transparency = 1
    d.HP.Visible = false
    espDrawing[character] = d
end

local function removeDrawingESP(character)
    local d = espDrawing[character]
    if not d then return end
    for _, obj in pairs(d) do pcall(function() obj:Remove() end) end
    espDrawing[character] = nil
end

local function setDrawingVisible(d, vis)
    for _, o in pairs(d) do o.Visible = vis end
end

local function createHighlightESP(character)
    if espHighlight[character] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "OmarESP"
    hl.FillColor = Color3.fromRGB(120, 50, 200)
    hl.FillTransparency = 0.6
    hl.OutlineColor = Color3.fromRGB(200, 130, 255)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = character
    hl.Parent = ScreenGui

    local bb = Instance.new("BillboardGui")
    bb.Name = "OmarESPName"
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    bb.Parent = ScreenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 200, 255)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Text = ""
    label.Parent = bb

    espHighlight[character] = { hl = hl, bb = bb, label = label }
end

local function removeHighlightESP(character)
    local d = espHighlight[character]
    if not d then return end
    pcall(function() d.hl:Destroy() end)
    pcall(function() d.bb:Destroy() end)
    espHighlight[character] = nil
end

track(Workspace.DescendantRemoving:Connect(function(obj)
    if espDrawing[obj] then removeDrawingESP(obj) end
    if espHighlight[obj] then removeHighlightESP(obj) end
end))
track(Players.PlayerRemoving:Connect(function(p)
    if p.Character then
        removeDrawingESP(p.Character)
        removeHighlightESP(p.Character)
    end
end))

local function drawDrawingESP(char, name, hum)
    if not espDrawing[char] then createDrawingESP(char) end
    local d = espDrawing[char]
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not (hrp and head) then setDrawingVisible(d, false); return end

    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local rootPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
    if not onScreen or headPos.Z < 0 then setDrawingVisible(d, false); return end

    local height = math.abs(rootPos.Y - headPos.Y)
    local width = height * 0.6
    if height <= 0 or width <= 0 or height > 1500 then
        setDrawingVisible(d, false); return
    end

    local topLeft     = Vector2.new(headPos.X - width / 2, headPos.Y)
    local bottomRight = Vector2.new(headPos.X + width / 2, rootPos.Y)
    local boxSize     = bottomRight - topLeft

    d.Box.Visible = Config.ESP.ShowBox
    if Config.ESP.ShowBox then
        d.Box.Size = boxSize
        d.Box.Position = topLeft
    end

    d.Name.Visible = Config.ESP.ShowName
    if Config.ESP.ShowName then
        d.Name.Text = name
        d.Name.Position = Vector2.new(headPos.X, topLeft.Y - 16)
    end

    d.Distance.Visible = Config.ESP.ShowDistance
    if Config.ESP.ShowDistance then
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        d.Distance.Text = string.format("[%d studs]", math.floor(dist))
        d.Distance.Position = Vector2.new(headPos.X, bottomRight.Y + 2)
    end

    if Config.ESP.ShowHealth and hum then
        local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local barH = boxSize.Y
        local barX = bottomRight.X + 4
        d.HPBg.Visible = true
        d.HPBg.Size = Vector2.new(4, barH)
        d.HPBg.Position = Vector2.new(barX, topLeft.Y)
        d.HP.Visible = true
        d.HP.Size = Vector2.new(4, barH * hpPct)
        d.HP.Position = Vector2.new(barX, topLeft.Y + barH * (1 - hpPct))
        d.HP.Color = Color3.fromRGB(math.floor(255 * (1 - hpPct)), math.floor(255 * hpPct), 0)
    else
        d.HP.Visible = false
        d.HPBg.Visible = false
    end
end

log("ESP system ready")

-- ============ MOUSE STATE ============
track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.MouseButton2
    or input.UserInputType == Enum.UserInputType.Touch then
        mouseHeld = true
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.MouseButton2
    or input.UserInputType == Enum.UserInputType.Touch then
        mouseHeld = false
    end
end))

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

RunService:BindToRenderStep("OmarHubAimbot", Enum.RenderPriority.Camera.Value + 1, aimStep)
log("Aimbot bound")

-- ============ SILENT AIM ============
local silentFiring = false
local silentTapUntil = 0

local function silentTrigger()
    silentTapUntil = tick() + 0.2
end

track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        silentFiring = true
        silentTrigger()
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        silentFiring = false
    end
end))

local function isFiringNow()
    return silentFiring or tick() < silentTapUntil
end

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

pcall(function()
    local originalRaycast    = Workspace.Raycast
    local originalRaycastAll = Workspace.RaycastAll

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

    -- keep references for shutdown
    _G.__OmarRaycast = originalRaycast
    _G.__OmarRaycastAll = originalRaycastAll
    log("Silent aim hooks installed")
end)

-- Silent ring UI
track(RunService.RenderStepped:Connect(function()
    if Config.SilentAim.Enabled then
        local r = Config.SilentAim.FOV
        SilentRing.Size = UDim2.new(0, r * 2, 0, r * 2)
        SilentRing.Position = UDim2.new(0.5, 0, 0.5, 0)
        SilentRing.Visible = true

        if SilentDot then
            local st = findSilentTarget()
            if st then
                local sp, on = Camera:WorldToViewportPoint(st.Position)
                if on and sp.Z > 0 then
                    SilentDot.Visible = true
                    SilentDot.Position = Vector2.new(sp.X, sp.Y)
                else
                    SilentDot.Visible = false
                end
            else
                SilentDot.Visible = false
            end
        end
    else
        SilentRing.Visible = false
        if SilentDot then SilentDot.Visible = false end
    end
end))

-- ============ ESP RENDER ============
track(RunService.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then
        for _, d in pairs(espDrawing) do setDrawingVisible(d, false) end
        for _, d in pairs(espHighlight) do
            if d.hl then d.hl.Enabled = false end
            if d.bb then d.bb.Enabled = false end
        end
        return
    end

    local live = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if isTeammate(p, Config.ESP.TeamCheck) then continue end
        if not isAlive(p) then continue end
        local char = p.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and hum then
            local name = (p.DisplayName ~= "" and p.DisplayName) or p.Name
            live[char] = true

            if drawingOK then
                drawDrawingESP(char, name, hum)
            else
                -- Highlight fallback
                if not espHighlight[char] then createHighlightESP(char) end
                local h = espHighlight[char]
                if h then
                    h.hl.Enabled = true
                    h.bb.Enabled = true
                    local dist = math.floor((Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude)
                    local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    h.label.Text = string.format("%s\n[%d studs]  HP:%d%%", name, dist, math.floor(hpPct * 100))
                    h.label.TextColor3 = Color3.fromRGB(
                        math.floor(255 * (1 - hpPct)),
                        math.floor(255 * hpPct),
                        math.floor(100 * hpPct)
                    )
                end
            end
        end
    end

    for char, d in pairs(espDrawing) do
        if not live[char] then setDrawingVisible(d, false) end
    end
    for char, d in pairs(espHighlight) do
        if not live[char] then
            if d.hl then d.hl.Enabled = false end
            if d.bb then d.bb.Enabled = false end
        end
    end
end))

-- Restore autorotate
track(RunService.Stepped:Connect(function()
    if Config.Aimbot.Enabled then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and not hum.AutoRotate then hum.AutoRotate = true end
end))

-- ============ FULL SHUTDOWN (re-wire CloseBtn) ============
-- Disconnect the earlier "hide" close connection and set up real shutdown
-- (we just redefine by connecting another one and gating)
local shuttingDown = false
track(CloseBtn.MouseButton1Click:Connect(function()
    if shuttingDown then return end
    shuttingDown = true
    log("Shutting down")

    pcall(function() RunService:UnbindFromRenderStep("OmarHubAimbot") end)
    if _G.__OmarRaycast then
        pcall(function() Workspace.Raycast = _G.__OmarRaycast end)
    end
    if _G.__OmarRaycastAll then
        pcall(function() Workspace.RaycastAll = _G.__OmarRaycastAll end)
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end

    for _, d in pairs(espDrawing) do
        for _, obj in pairs(d) do pcall(function() obj:Remove() end) end
    end
    espDrawing = {}
    for _, d in pairs(espHighlight) do
        pcall(function() d.hl:Destroy() end)
        pcall(function() d.bb:Destroy() end)
    end
    espHighlight = {}
    if SilentDot then pcall(function() SilentDot:Remove() end) end

    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    connections = {}
    pcall(function() ScreenGui:Destroy() end)
end))

log("Script loaded successfully.")
