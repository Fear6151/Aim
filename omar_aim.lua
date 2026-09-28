--[[
    Omar Hub v3
    Credit: Made by Omar
    For use ONLY in your own Roblox game.
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
    },
    Aimbot = {
        Enabled = false,
        FOV = 150,
        TargetPart = "Head",     -- "Head" or "Torso"
        TeamCheck = true,
        MaxDistance = 1000,
        HardLock = true,
        Smoothness = 5,
        UseHoldKey = false,      -- if true, only locks while HoldKey is down
        HoldKey = Enum.KeyCode.E,
    }
}

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
Main.Active = true
Main.Draggable = true
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

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Omar Hub"
Title.TextColor3 = Color3.fromRGB(200, 130, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 150, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

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

local EspPage = Instance.new("ScrollingFrame")
EspPage.Size = UDim2.new(1, -20, 1, -96)
EspPage.Position = UDim2.new(0, 10, 0, 76)
EspPage.BackgroundTransparency = 1
EspPage.BorderSizePixel = 0
EspPage.ScrollBarThickness = 3
EspPage.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 220)
EspPage.CanvasSize = UDim2.new(0, 0, 0, 260)
EspPage.Parent = Main

local AimPage = Instance.new("ScrollingFrame")
AimPage.Size = UDim2.new(1, -20, 1, -96)
AimPage.Position = UDim2.new(0, 10, 0, 76)
AimPage.BackgroundTransparency = 1
AimPage.BorderSizePixel = 0
AimPage.ScrollBarThickness = 3
AimPage.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 220)
AimPage.CanvasSize = UDim2.new(0, 0, 0, 320)
AimPage.Visible = false
AimPage.Parent = Main

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
EspTabBtn.MouseButton1Click:Connect(function() setActiveTab("esp") end)
AimTabBtn.MouseButton1Click:Connect(function() setActiveTab("aim") end)

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
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Pill.BackgroundColor3 = state and Color3.fromRGB(150, 70, 220) or Color3.fromRGB(60, 40, 80)
        Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        callback(state)
    end)
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
        b.MouseButton1Click:Connect(function()
            for _, other in ipairs(Container:GetChildren()) do
                if other:IsA("TextButton") then
                    other.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
                end
            end
            b.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
            callback(opt)
        end)
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
    Bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + (max - min) * rel)
            Lbl.Text = text .. ": " .. val
            callback(val)
        end
    end)
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
EspPage.CanvasSize = UDim2.new(0, 0, 0, ey + 6)

-- ============ AIMBOT PAGE ============
local ay = 4
makeToggle(AimPage, "Aimbot Enabled", ay, Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end); ay = ay + 36
makeSwitch(AimPage, "Target:", ay, {"Head", "Torso"}, Config.Aimbot.TargetPart, function(v) Config.Aimbot.TargetPart = v end); ay = ay + 36
makeToggle(AimPage, "Hard Lock", ay, Config.Aimbot.HardLock, function(v) Config.Aimbot.HardLock = v end); ay = ay + 36
makeToggle(AimPage, "Team Check", ay, Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end); ay = ay + 36
makeToggle(AimPage, "Use Hold Key [E]", ay, Config.Aimbot.UseHoldKey, function(v) Config.Aimbot.UseHoldKey = v end); ay = ay + 36
makeSlider(AimPage, "FOV", ay, 30, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end); ay = ay + 48
makeSlider(AimPage, "Smoothness", ay, 2, 20, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end); ay = ay + 48
AimPage.CanvasSize = UDim2.new(0, 0, 0, ay + 6)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 1, -22)
Credit.BackgroundTransparency = 1
Credit.Text = "Made by Omar"
Credit.TextColor3 = Color3.fromRGB(180, 100, 240)
Credit.Font = Enum.Font.GothamBold
Credit.TextSize = 12
Credit.Parent = Main

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    FovCircle.Visible = Main.Visible and Config.Aimbot.Enabled
end)

-- ============ FOV CIRCLE ============
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
-- FIXED: only treat as teammate if BOTH have a valid, non-nil Team and they match
local function isTeammate(player)
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

local function getTargetPart(char)
    if Config.Aimbot.TargetPart == "Head" then
        return char:FindFirstChild("Head")
    else
        return char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("Torso")
            or char:FindFirstChild("LowerTorso")
            or char:FindFirstChild("HumanoidRootPart")
    end
end

-- ============ ESP DRAWINGS ============
local espObjects = {}

local function createESP(player)
    if espObjects[player] then return end
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

    espObjects[player] = d
end

local function removeESP(player)
    local d = espObjects[player]
    if not d then return end
    for _, obj in pairs(d) do
        pcall(function() obj:Remove() end)
    end
    espObjects[player] = nil
end

local function setAllVisible(d, vis)
    for _, obj in pairs(d) do obj.Visible = vis end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

-- ============ ESP RENDER ============
RunService.RenderStepped:Connect(function()
    if Config.Aimbot.Enabled then
        FovCircle.Visible = Main.Visible
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
        FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    else
        FovCircle.Visible = false
    end

    for player, d in pairs(espObjects) do
        local char = player.Character
        local visible = Config.ESP.Enabled
            and player ~= LocalPlayer
            and char ~= nil
            and isAlive(player)
            and not (Config.ESP.TeamCheck and isTeammate(player))

        if not visible then
            setAllVisible(d, false)
            continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
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

        -- Corner brackets box
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

            -- connect corners with full square outline
            d.BoxTL.From = Vector2.new(topLeft.X, topLeft.Y + armLen)
            d.BoxTL.To   = Vector2.new(topLeft.X, topLeft.Y)
        else
            d.Box.Visible = false
            d.BoxTL.Visible = false
            d.BoxTR.Visible = false
            d.BoxBL.Visible = false
            d.BoxBR.Visible = false
        end

        if Config.ESP.ShowName then
            d.Name.Visible = true
            d.Name.Text = player.DisplayName ~= "" and player.DisplayName or player.Name
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
end)

-- ============ AIMBOT ============
-- Uses Camera.ViewportSize (actual pixels) so FOV circle lines up with pixel FOV check
local function getClosestTarget()
    local closest, closestDist = nil, math.huge
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local origin = Camera.CFrame.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.Aimbot.TeamCheck and isTeammate(player) then continue end
        if not isAlive(player) then continue end

        local char = player.Character
        local part = getTargetPart(char)
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

-- Lock the character so shooting / weapon modules can't rotate the camera away
local function lockCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = false
    end
end

local function unlockCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = true
    end
end

-- BindToRenderStep with priority AFTER camera (Camera priority = 200).
-- We use 201 so our CFrame write happens after Roblox's default camera update.
local AIMBOT_BIND_NAME = "OmarHubAimbot"
local bound = false

local function aimStep()
    if not Config.Aimbot.Enabled then return end
    if Config.Aimbot.UseHoldKey and not UserInputService:IsKeyDown(Config.Aimbot.HoldKey) then
        return
    end

    local target = getClosestTarget()
    if not target then return end

    local currentCF = Camera.CFrame
    local desiredCF = CFrame.new(currentCF.Position, target.Position)

    if Config.Aimbot.HardLock then
        Camera.CFrame = desiredCF
        -- lock again in case some other system re-enabled autorotate
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.AutoRotate then hum.AutoRotate = false end
        end
    else
        Camera.CFrame = currentCF:Lerp(desiredCF, 1 / Config.Aimbot.Smoothness)
    end
end

local function refreshBinding()
    if Config.Aimbot.Enabled then
        if not bound then
            RunService:BindToRenderStep(AIMBOT_BIND_NAME, Enum.RenderPriority.Camera.Value + 1, aimStep)
            bound = true
        end
        lockCharacter()
    else
        if bound then
            pcall(function() RunService:UnbindFromRenderStep(AIMBOT_BIND_NAME) end)
            bound = false
        end
        unlockCharacter()
    end
end

-- react when Enabled toggle flips
local oldEnabled = Config.Aimbot.Enabled
RunService.Heartbeat:Connect(function()
    if Config.Aimbot.Enabled ~= oldEnabled then
        oldEnabled = Config.Aimbot.Enabled
        refreshBinding()
    end
end)
refreshBinding()

-- When player respawns, re-lock character
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    if Config.Aimbot.Enabled then lockCharacter() end
end)
