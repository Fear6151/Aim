--[[
    Omar Hub
    Credit: Made by Omar
    
--]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

-- ============ CONFIG ============
local Config = {
    ESP = {
        Enabled      = true,
        ShowName     = true,
        ShowDistance = true,
        ShowHealth   = true,
        ShowBox      = true,
        TeamCheck    = true,
        MaxBoxPixels = 1200,
    },
    Aimbot = {
        Enabled    = false,
        FOV        = 150,
        TargetPart = "Head",
        TeamCheck  = true,
        MaxDist    = 1000,
        Smoothness = 100,
        LockMode   = "Hold Mouse",
    },
    ToggleKey = Enum.KeyCode.RightShift,
}

local connections = {}
local function track(c) table.insert(connections, c); return c end

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmarHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.5, -150, 0.5, -200)
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

local function makeDraggable(button, onTap)
    local dragging  = false
    local moved     = false
    local dragStart = nil
    local startPos  = nil
    local function clampToViewport(pos)
        local vp = Camera.ViewportSize
        local size = button.AbsoluteSize
        local w = size.X > 0 and size.X or button.Size.X.Offset
        local h = size.Y > 0 and size.Y or button.Size.Y.Offset
        return UDim2.new(0, math.clamp(pos.X.Offset, 0, vp.X - w),
                         0, math.clamp(pos.Y.Offset, 0, vp.Y - h))
    end
    track(button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, dragStart, startPos = true, false, input.Position, button.Position
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then moved = true end
            button.Position = clampToViewport(UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y))
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if not moved and onTap then onTap() end
            dragging, moved = false, false
        end
    end))
end

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
FloatPill.Active = true
FloatPill.ZIndex = 500
FloatPill.Visible = false
FloatPill.Parent = ScreenGui
Instance.new("UICorner", FloatPill).CornerRadius = UDim.new(0, 6)
local PillStroke = Instance.new("UIStroke", FloatPill)
PillStroke.Color = Color3.fromRGB(150, 70, 220)
PillStroke.Thickness = 1.5

local AimPill = Instance.new("TextButton")
AimPill.Size = UDim2.new(0, 72, 0, 28)
AimPill.Position = UDim2.new(0, 14, 1, -46)
AimPill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AimPill.Text = "AIM: OFF"
AimPill.TextColor3 = Color3.fromRGB(200, 90, 120)
AimPill.Font = Enum.Font.GothamBold
AimPill.TextSize = 12
AimPill.BorderSizePixel = 0
AimPill.AutoButtonColor = false
AimPill.Active = true
AimPill.ZIndex = 500
AimPill.Visible = false
AimPill.Parent = ScreenGui
Instance.new("UICorner", AimPill).CornerRadius = UDim.new(0, 6)
local AimStroke = Instance.new("UIStroke", AimPill)
AimStroke.Color = Color3.fromRGB(200, 60, 100)
AimStroke.Thickness = 1.5

local function refreshAimPill()
    if Config.Aimbot.Enabled then
        AimPill.Text = "AIM: ON"
        AimPill.TextColor3 = Color3.fromRGB(120, 255, 160)
        AimStroke.Color = Color3.fromRGB(80, 220, 130)
    else
        AimPill.Text = "AIM: OFF"
        AimPill.TextColor3 = Color3.fromRGB(200, 90, 120)
        AimStroke.Color = Color3.fromRGB(200, 60, 100)
    end
end
refreshAimPill()

makeDraggable(FloatPill, function()
    Main.Visible = true
    FloatPill.Visible = false
    AimPill.Visible = false
end)

makeDraggable(AimPill, function()
    Config.Aimbot.Enabled = not Config.Aimbot.Enabled
    refreshAimPill()
end)

do
    local dragging, dragStart, startPos = false, nil, nil
    track(TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, Main.Position
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
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

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
local AimTabBtn = makeTab("Aimbot", 1, 2)
local EspTabBtn = makeTab("ESP", 2, 2)

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
AimPage.CanvasSize = UDim2.new(0, 0, 0, 300)
AimPage.Parent = Body

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
setActiveTab("aim")
track(AimTabBtn.MouseButton1Click:Connect(function() setActiveTab("aim") end))
track(EspTabBtn.MouseButton1Click:Connect(function() setActiveTab("esp") end))

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
    Container.Size = UDim2.new(0, 140, 0, 22)
    Container.Position = UDim2.new(1, -148, 0.5, -11)
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

-- ============ AIMBOT PAGE ============
local ay = 4
makeToggle(AimPage, "Aimbot Enabled", ay, Config.Aimbot.Enabled, function(v)
    Config.Aimbot.Enabled = v
    refreshAimPill()
end); ay = ay + 36
makeSwitch(AimPage, "Target:", ay, {"Head", "Torso"}, Config.Aimbot.TargetPart, function(v) Config.Aimbot.TargetPart = v end); ay = ay + 36
makeSwitch(AimPage, "Lock Mode:", ay, {"Hold Mouse", "Always"}, Config.Aimbot.LockMode, function(v) Config.Aimbot.LockMode = v end); ay = ay + 36
makeToggle(AimPage, "Team Check", ay, Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end); ay = ay + 36
makeSlider(AimPage, "FOV", ay, 30, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end); ay = ay + 48
makeSlider(AimPage, "Smoothness (1 soft - 100 hard)", ay, 1, 100, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end); ay = ay + 48
AimPage.CanvasSize = UDim2.new(0, 0, 0, ay + 6)

-- ============ ESP PAGE ============
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
Credit.Font = Enum.Font.GothamBold
Credit.TextSize = 12
Credit.Parent = Main

-- ============ FOV RING ============
local FovRing = Instance.new("Frame")
FovRing.AnchorPoint = Vector2.new(0.5, 0.5)
FovRing.BackgroundTransparency = 1
FovRing.BorderSizePixel = 0
FovRing.ZIndex = 1
FovRing.Parent = ScreenGui
Instance.new("UICorner", FovRing).CornerRadius = UDim.new(1, 0)

local FovStrokeOuter = Instance.new("UIStroke", FovRing)
FovStrokeOuter.Color = Color3.fromRGB(190, 110, 255)
FovStrokeOuter.Thickness = 2.5
FovStrokeOuter.Transparency = 0.1

local FovGlow = Instance.new("Frame")
FovGlow.AnchorPoint = Vector2.new(0.5, 0.5)
FovGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
FovGlow.BackgroundTransparency = 1
FovGlow.BorderSizePixel = 0
FovGlow.ZIndex = 0
FovGlow.Parent = ScreenGui
Instance.new("UICorner", FovGlow).CornerRadius = UDim.new(1, 0)
local FovStrokeInner = Instance.new("UIStroke", FovGlow)
FovStrokeInner.Color = Color3.fromRGB(255, 180, 255)
FovStrokeInner.Thickness = 1
FovStrokeInner.Transparency = 0.6

local CenterDot = Instance.new("Frame")
CenterDot.Size = UDim2.new(0, 6, 0, 6)
CenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
CenterDot.Position = UDim2.new(0.5, 0, 0.5, 0)
CenterDot.BackgroundColor3 = Color3.fromRGB(220, 140, 255)
CenterDot.BorderSizePixel = 0
CenterDot.ZIndex = 2
CenterDot.Parent = ScreenGui
Instance.new("UICorner", CenterDot).CornerRadius = UDim.new(1, 0)
local CenterStroke = Instance.new("UIStroke", CenterDot)
CenterStroke.Color = Color3.fromRGB(90, 40, 140)
CenterStroke.Thickness = 1

local TargetDot = Drawing.new("Circle")
TargetDot.Thickness = 2
TargetDot.Color = Color3.fromRGB(255, 80, 255)
TargetDot.Filled = false
TargetDot.Radius = 10
TargetDot.Transparency = 1
TargetDot.Visible = false

local TargetDotInner = Drawing.new("Circle")
TargetDotInner.Thickness = 1
TargetDotInner.Color = Color3.fromRGB(255, 200, 255)
TargetDotInner.Filled = false
TargetDotInner.Radius = 4
TargetDotInner.Transparency = 1
TargetDotInner.Visible = false

-- ============ HELPERS ============
local function isTeammate(player)
    if player == LocalPlayer then return false end
    local a, b = player.Team, LocalPlayer.Team
    if a == nil or b == nil then return false end
    return a == b
end

local function isAliveHumanoid(hum) return hum and hum.Health > 0 end

local function hasValidRig(model)
    if not model or not model.Parent then return false end
    local head = model:FindFirstChild("Head")
    local hrp  = model:FindFirstChild("HumanoidRootPart")
    return head and head:IsA("BasePart") and hrp and hrp:IsA("BasePart")
end

local function getTargetPart(char)
    if not hasValidRig(char) then return nil end
    if Config.Aimbot.TargetPart == "Head" then
        local h = char:FindFirstChild("Head")
        if h and h:IsA("BasePart") then return h end
        return nil
    end
    local upper = char:FindFirstChild("UpperTorso"); if upper and upper:IsA("BasePart") then return upper end
    local torso = char:FindFirstChild("Torso");      if torso and torso:IsA("BasePart") then return torso end
    local lower = char:FindFirstChild("LowerTorso"); if lower and lower:IsA("BasePart") then return lower end
    local hrp   = char:FindFirstChild("HumanoidRootPart"); if hrp and hrp:IsA("BasePart") then return hrp end
    return nil
end

-- Wall check: returns true if I can see the target from my head
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

local function getPlayerTargets()
    local out = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not char.Parent then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not isAliveHumanoid(hum) then continue end
        if Config.Aimbot.TeamCheck and isTeammate(player) then continue end
        if not hasValidRig(char) then continue end
        out[#out + 1] = {
            character = char, humanoid = hum, player = player,
            name = (player.DisplayName ~= "" and player.DisplayName) or player.Name,
            isNpc = false,
        }
    end
    return out
end

local npcCache, npcCacheTime = {}, 0
local function refreshNpcCache()
    local now = tick()
    if now - npcCacheTime < 0.5 then return end
    npcCacheTime = now
    local out = {}
    local localChar = LocalPlayer.Character
    for _, hum in ipairs(Workspace:GetDescendants()) do
        if not hum:IsA("Humanoid") then continue end
        if hum.Health <= 0 then continue end
        local model = hum.Parent
        if not model or not model:IsA("Model") then continue end
        if model == localChar then continue end
        if Players:GetPlayerFromCharacter(model) then continue end
        if not hasValidRig(model) then continue end
        local head = model:FindFirstChild("Head")
        local hrp  = model:FindFirstChild("HumanoidRootPart")
        if (head.Position - hrp.Position).Magnitude > 8 then continue end
        out[#out + 1] = model
    end
    npcCache = out
end
local function getNpcTargets()
    refreshNpcCache()
    local out = {}
    for _, model in ipairs(npcCache) do
        if not model.Parent then continue end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not isAliveHumanoid(hum) then continue end
        if not hasValidRig(model) then continue end
        out[#out + 1] = {
            character = model, humanoid = hum, player = nil,
            name = model.Name, isNpc = true,
        }
    end
    return out
end

-- ============ ESP ============
local espObjects = {}

local function createESP(character)
    if espObjects[character] then return end
    local d = {
        Box = Drawing.new("Square"),
        TL = Drawing.new("Line"), TR = Drawing.new("Line"),
        BL = Drawing.new("Line"), BR = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HP = Drawing.new("Square"),
        HPBg = Drawing.new("Square"),
        HPOutline = Drawing.new("Square"),
    }
    d.Box.Thickness = 1
    d.Box.Color = Color3.fromRGB(160, 80, 255)
    d.Box.Filled = false
    d.Box.Transparency = 1
    d.Box.Visible = false
    for _, line in ipairs({d.TL, d.TR, d.BL, d.BR}) do
        line.Thickness = 2
        line.Color = Color3.fromRGB(200, 130, 255)
        line.Transparency = 1
        line.Visible = false
    end
    d.HPBg.Filled = true
    d.HPBg.Color = Color3.fromRGB(0, 0, 0)
    d.HPBg.Transparency = 0.5
    d.HPBg.Visible = false
    d.HPOutline.Filled = false
    d.HPOutline.Color = Color3.fromRGB(20, 10, 30)
    d.HPOutline.Thickness = 1
    d.HPOutline.Transparency = 1
    d.HPOutline.Visible = false
    d.HP.Filled = true
    d.HP.Color = Color3.fromRGB(0, 255, 0)
    d.HP.Transparency = 1
    d.HP.Visible = false
    for _, t in ipairs({d.Name, d.Distance}) do
        t.Size = 14; t.Center = true; t.Outline = true
        t.OutlineColor = Color3.fromRGB(0, 0, 0)
        t.Color = Color3.fromRGB(255, 255, 255)
        t.Font = 2; t.Visible = false
    end
    d.Name.Color = Color3.fromRGB(220, 180, 255)
    d.Distance.Color = Color3.fromRGB(200, 140, 255)
    espObjects[character] = d
end

local function removeESP(character)
    local d = espObjects[character]
    if not d then return end
    for _, obj in pairs(d) do pcall(function() obj:Remove() end) end
    espObjects[character] = nil
end

local function setAllVisible(d, vis)
    for _, obj in pairs(d) do obj.Visible = vis end
end

track(Workspace.DescendantRemoving:Connect(function(obj)
    if espObjects[obj] then removeESP(obj) end
end))
track(Players.PlayerRemoving:Connect(function(player)
    if player.Character then removeESP(player.Character) end
end))

local function drawESP(t)
    local char = t.character
    if not espObjects[char] then createESP(char) end
    local d = espObjects[char]
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not (hrp and head) then setAllVisible(d, false); return end

    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local rootPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
    if not onScreen or headPos.Z < 0 then setAllVisible(d, false); return end

    local height = math.abs(rootPos.Y - headPos.Y)
    local width = height * 0.6
    if height > Config.ESP.MaxBoxPixels or width > Config.ESP.MaxBoxPixels then
        setAllVisible(d, false); return
    end
    if not (height > 0 and width > 0) then
        setAllVisible(d, false); return
    end

    local topLeft     = Vector2.new(headPos.X - width / 2, headPos.Y)
    local bottomRight = Vector2.new(headPos.X + width / 2, rootPos.Y)
    local boxSize     = bottomRight - topLeft

    if Config.ESP.ShowBox then
        d.Box.Visible = true
        d.Box.Size = boxSize
        d.Box.Position = topLeft
        local armLen = math.min(boxSize.X, boxSize.Y) * 0.25
        local br = topLeft + boxSize
        d.TL.Visible = true; d.TL.From = Vector2.new(topLeft.X, topLeft.Y + armLen); d.TL.To = Vector2.new(topLeft.X, topLeft.Y)
        d.TR.Visible = true; d.TR.From = Vector2.new(br.X - armLen, topLeft.Y);      d.TR.To = Vector2.new(br.X, topLeft.Y)
        d.BL.Visible = true; d.BL.From = Vector2.new(topLeft.X, br.Y - armLen);      d.BL.To = Vector2.new(topLeft.X, br.Y)
        d.BR.Visible = true; d.BR.From = Vector2.new(br.X - armLen, br.Y);           d.BR.To = Vector2.new(br.X, br.Y)
    else
        d.Box.Visible = false
        d.TL.Visible = false; d.TR.Visible = false; d.BL.Visible = false; d.BR.Visible = false
    end

    if Config.ESP.ShowName then
        d.Name.Visible = true
        d.Name.Text = t.name
        d.Name.Position = Vector2.new(headPos.X, topLeft.Y - 16)
    else d.Name.Visible = false end

    if Config.ESP.ShowDistance then
        d.Distance.Visible = true
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        d.Distance.Text = string.format("[%d studs]", math.floor(dist))
        d.Distance.Position = Vector2.new(headPos.X, bottomRight.Y + 2)
    else d.Distance.Visible = false end

    if Config.ESP.ShowHealth then
        local hpPct = math.clamp(t.humanoid.Health / t.humanoid.MaxHealth, 0, 1)
        local barH = boxSize.Y
        local barX = bottomRight.X + 4
        d.HPBg.Visible = true; d.HPBg.Size = Vector2.new(4, barH); d.HPBg.Position = Vector2.new(barX, topLeft.Y)
        d.HPOutline.Visible = true; d.HPOutline.Size = Vector2.new(4, barH); d.HPOutline.Position = Vector2.new(barX, topLeft.Y)
        d.HP.Visible = true; d.HP.Size = Vector2.new(4, barH * hpPct); d.HP.Position = Vector2.new(barX, topLeft.Y + barH * (1 - hpPct))
        d.HP.Color = Color3.fromRGB(math.floor(255 * (1 - hpPct)), math.floor(255 * hpPct), 0)
    else
        d.HP.Visible = false; d.HPBg.Visible = false; d.HPOutline.Visible = false
    end
end

-- ============ MOUSE STATE ============
local mouseHeld = false
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
-- findBestTarget now ALWAYS skips anything behind a wall (no toggle)
local function findBestTarget()
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local origin = Camera.CFrame.Position
    local bestPlayer, bestPlayerDist = nil, math.huge
    local bestNpc,    bestNpcDist    = nil, math.huge

    -- Players first
    for _, t in ipairs(getPlayerTargets()) do
        local part = getTargetPart(t.character)
        if part then
            local dist = (origin - part.Position).Magnitude
            if dist <= Config.Aimbot.MaxDist then
                -- ALWAYS check walls, no toggle
                if hasLineOfSight(part) then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if sd <= Config.Aimbot.FOV and sd < bestPlayerDist then
                            bestPlayerDist = sd
                            bestPlayer = part
                        end
                    end
                end
            end
        end
    end
    if bestPlayer then return bestPlayer end

    -- NPCs only if no visible player
    for _, t in ipairs(getNpcTargets()) do
        local part = getTargetPart(t.character)
        if part then
            local dist = (origin - part.Position).Magnitude
            if dist <= Config.Aimbot.MaxDist then
                if hasLineOfSight(part) then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if sd <= Config.Aimbot.FOV and sd < bestNpcDist then
                            bestNpcDist = sd
                            bestNpc = part
                        end
                    end
                end
            end
        end
    end
    return bestNpc
end

local AIMBOT_BIND_NAME = "OmarHubAimbot"
local bound = false
local currentTarget = nil

local function targetIsValid(part)
    if not part or not part.Parent then return false end
    if not part:IsDescendantOf(Workspace) then return false end
    local char = part.Parent
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hum and hum.Health > 0) then return false end
    -- Also drop the target if it walks behind a wall
    if not hasLineOfSight(part) then return false end
    return true
end

local function aimStep()
    if Config.Aimbot.Enabled then
        local radius = Config.Aimbot.FOV
        FovRing.Size = UDim2.new(0, radius * 2, 0, radius * 2)
        FovRing.Position = UDim2.new(0.5, 0, 0.5, 0)
        FovRing.Visible = true
        FovGlow.Size = UDim2.new(0, radius * 2 + 6, 0, radius * 2 + 6)
        FovGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        FovGlow.Visible = true
        CenterDot.Visible = true
    else
        FovRing.Visible = false
        FovGlow.Visible = false
        CenterDot.Visible = false
        TargetDot.Visible = false
        TargetDotInner.Visible = false
        return
    end

    local gated = (Config.Aimbot.LockMode == "Hold Mouse") and not mouseHeld

    -- Invalid or walled-off target → drop
    if not targetIsValid(currentTarget) then
        currentTarget = nil
    end

    -- Out of FOV → drop
    if currentTarget then
        local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        if not on or (Vector2.new(sp.X, sp.Y) - center).Magnitude > Config.Aimbot.FOV * 1.2 then
            currentTarget = nil
        end
    end

    if not currentTarget then
        currentTarget = findBestTarget()
    end

    if currentTarget then
        local sp, on = Camera:WorldToViewportPoint(currentTarget.Position)
        if on and sp.Z > 0 then
            TargetDot.Visible = true
            TargetDot.Position = Vector2.new(sp.X, sp.Y)
            TargetDotInner.Visible = true
            TargetDotInner.Position = Vector2.new(sp.X, sp.Y)
        else
            TargetDot.Visible = false
            TargetDotInner.Visible = false
        end
    else
        TargetDot.Visible = false
        TargetDotInner.Visible = false
    end

    if gated or not currentTarget then return end

    local aimPos = currentTarget.Position
    local alpha = math.clamp(Config.Aimbot.Smoothness / 100, 0.01, 1)

    local curCF = Camera.CFrame
    local desiredCF = CFrame.new(curCF.Position, aimPos)
    Camera.CFrame = curCF:Lerp(desiredCF, alpha)

    if alpha >= 0.4 then
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            hum.AutoRotate = false
            local flat = Vector3.new(aimPos.X, hrp.Position.Y, aimPos.Z)
            local curHRP = hrp.CFrame
            local desiredHRP = CFrame.new(curHRP.Position, flat)
            hrp.CFrame = curHRP:Lerp(desiredHRP, alpha)
        end
    end
end

local function refreshBinding()
    if Config.Aimbot.Enabled then
        if not bound then
            RunService:BindToRenderStep(AIMBOT_BIND_NAME, Enum.RenderPriority.Camera.Value + 1, aimStep)
            bound = true
        end
    else
        currentTarget = nil
        TargetDot.Visible = false
        TargetDotInner.Visible = false
        FovRing.Visible = false
        FovGlow.Visible = false
        CenterDot.Visible = false
        if bound then
            pcall(function() RunService:UnbindFromRenderStep(AIMBOT_BIND_NAME) end)
            bound = false
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

local oldEnabled = Config.Aimbot.Enabled
track(RunService.Heartbeat:Connect(function()
    if Config.Aimbot.Enabled ~= oldEnabled then
        oldEnabled = Config.Aimbot.Enabled
        refreshBinding()
        refreshAimPill()
    end
end))

track(RunService.Stepped:Connect(function()
    if Config.Aimbot.Enabled then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and not hum.AutoRotate then hum.AutoRotate = true end
end))

track(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    if not Config.Aimbot.Enabled then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end))

refreshBinding()

-- ============ ESP RENDER ============
track(RunService.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then
        for _, d in pairs(espObjects) do setAllVisible(d, false) end
        return
    end
    local liveChars = {}
    for _, t in ipairs(getPlayerTargets()) do
        liveChars[t.character] = true
        drawESP(t)
    end
    for _, t in ipairs(getNpcTargets()) do
        liveChars[t.character] = true
        drawESP(t)
    end
    for char, d in pairs(espObjects) do
        if not liveChars[char] then setAllVisible(d, false) end
    end
end))

-- ============ TOGGLE / CLOSE ============
local function setUIVisible(vis)
    Main.Visible = vis
    FloatPill.Visible = not vis
    AimPill.Visible = not vis
end

track(ToggleBtn.MouseButton1Click:Connect(function() setUIVisible(false) end))
track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then
        setUIVisible(not Main.Visible)
    end
end))

local function shutdown()
    pcall(function() RunService:UnbindFromRenderStep(AIMBOT_BIND_NAME) end)
    bound = false
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
    for _, d in pairs(espObjects) do
        for _, obj in pairs(d) do pcall(function() obj:Remove() end) end
    end
    espObjects = {}
    pcall(function() TargetDot:Remove() end)
    pcall(function() TargetDotInner:Remove() end)
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    connections = {}
    pcall(function() ScreenGui:Destroy() end)
end

track(CloseBtn.MouseButton1Click:Connect(shutdown))
