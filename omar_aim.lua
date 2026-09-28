--[[
    Omar's Aimbot + ESP
    Credit: Made by Omar.
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
        Smoothness = 1, -- 1 = instant lock, higher = smoother
        TargetPart = "Head", -- "Head" or "Torso"
        TeamCheck = true,
        MaxDistance = 1000,
        VisibleOnly = false,
    }
}

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmarHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 380)
Main.Position = UDim2.new(0.5, -130, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(140, 60, 220)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.2

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 15, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Omar Hub"
Title.TextColor3 = Color3.fromRGB(200, 130, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 150, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -44)
Content.Position = UDim2.new(0, 8, 0, 38)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function makeToggle(text, yPos, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.Position = UDim2.new(0, 0, 0, yPos)
    Btn.BackgroundColor3 = default and Color3.fromRGB(90, 40, 140) or Color3.fromRGB(35, 20, 50)
    Btn.Text = ""
    Btn.BorderSizePixel = 0
    Btn.Parent = Content
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -10, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(230, 200, 255)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Btn

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(90, 40, 140) or Color3.fromRGB(35, 20, 50)
        callback(state)
    end)
    return Btn
end

local function makeSlider(text, yPos, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 42)
    Frame.Position = UDim2.new(0, 0, 0, yPos)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Content

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
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 6)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 6)

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
end

-- ESP Toggles
makeToggle("ESP Enabled", 0, Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
makeToggle("Show Name", 34, Config.ESP.ShowName, function(v) Config.ESP.ShowName = v end)
makeToggle("Show Distance", 68, Config.ESP.ShowDistance, function(v) Config.ESP.ShowDistance = v end)
makeToggle("Show Health", 102, Config.ESP.ShowHealth, function(v) Config.ESP.ShowHealth = v end)
makeToggle("Show Box", 136, Config.ESP.ShowBox, function(v) Config.ESP.ShowBox = v end)
makeToggle("ESP Team Check", 170, Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)

-- Aimbot Toggles
makeToggle("Aimbot Enabled", 210, Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
makeToggle("Target: Head", 244, true, function(v)
    Config.Aimbot.TargetPart = v and "Head" or "Torso"
end)
makeToggle("Aimbot Team Check", 278, Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)

makeSlider("FOV", 312, 30, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)

-- Credit
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
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- ============ FOV CIRCLE ============
local FovCircle = Instance.new("Frame")
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundTransparency = 1
FovCircle.BorderSizePixel = 0
FovCircle.Parent = ScreenGui

local FovCorner = Instance.new("UICorner", FovCircle)
FovCorner.CornerRadius = UDim.new(1, 0)

local FovStroke = Instance.new("UIStroke", FovCircle)
FovStroke.Color = Color3.fromRGB(180, 100, 255)
FovStroke.Thickness = 1.5
FovStroke.Transparency = 0.3

-- ============ ESP DRAWINGS ============
local espObjects = {}

local function createESP(player)
    if espObjects[player] then return end
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarBg = Drawing.new("Square"),
    }
    drawings.Box.Thickness = 1
    drawings.Box.Color = Color3.fromRGB(160, 80, 255)
    drawings.Box.Filled = false
    drawings.Box.Transparency = 1
    drawings.Box.Visible = false

    drawings.HealthBarBg.Filled = true
    drawings.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
    drawings.HealthBarBg.Transparency = 0.6
    drawings.HealthBarBg.Visible = false

    drawings.HealthBar.Filled = true
    drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    drawings.HealthBar.Transparency = 1
    drawings.HealthBar.Visible = false

    for _, d in pairs({drawings.Name, drawings.Distance}) do
        d.Size = 14
        d.Center = true
        d.Outline = true
        d.OutlineColor = Color3.fromRGB(0, 0, 0)
        d.Color = Color3.fromRGB(255, 255, 255)
        d.Font = 2
        d.Visible = false
    end
    drawings.Name.Color = Color3.fromRGB(220, 180, 255)
    drawings.Distance.Color = Color3.fromRGB(200, 140, 255)

    espObjects[player] = drawings
end

local function removeESP(player)
    local d = espObjects[player]
    if not d then return end
    for _, obj in pairs(d) do
        pcall(function() obj:Remove() end)
    end
    espObjects[player] = nil
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then createESP(p) end
end)
Players.PlayerRemoving:Connect(removeESP)

local function isTeammate(player)
    if not Config.ESP.TeamCheck and not Config.Aimbot.TeamCheck then return false end
    return player.Team == LocalPlayer.Team and player.Team ~= nil
end

local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- ============ RENDER ESP ============
RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    if Config.Aimbot.Enabled then
        FovCircle.Visible = true
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
        FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    else
        FovCircle.Visible = false
    end

    for player, drawings in pairs(espObjects) do
        local char = player.Character
        local visible = Config.ESP.Enabled
            and char
            and isAlive(player)
            and not (Config.ESP.TeamCheck and isTeammate(player))
            and player ~= LocalPlayer

        if not visible then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not (hrp and head and hum) then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

        if not onScreen or headPos.Z < 0 then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local height = math.abs(rootPos.Y - headPos.Y)
        local width = height * 0.6
        local topLeft = Vector2.new(headPos.X - width / 2, headPos.Y)
        local bottomRight = Vector2.new(headPos.X + width / 2, rootPos.Y)

        -- Box
        if Config.ESP.ShowBox then
            drawings.Box.Visible = true
            drawings.Box.Size = bottomRight - topLeft
            drawings.Box.Position = topLeft
        else
            drawings.Box.Visible = false
        end

        -- Name
        if Config.ESP.ShowName then
            drawings.Name.Visible = true
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new(headPos.X, topLeft.Y - 16)
        else
            drawings.Name.Visible = false
        end

        -- Distance
        if Config.ESP.ShowDistance then
            drawings.Distance.Visible = true
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            drawings.Distance.Text = string.format("[%d studs]", math.floor(dist))
            drawings.Distance.Position = Vector2.new(headPos.X, bottomRight.Y + 2)
        else
            drawings.Distance.Visible = false
        end

        -- Health bar
        if Config.ESP.ShowHealth then
            local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barH = bottomRight.Y - topLeft.Y
            local barX = bottomRight.X + 4

            drawings.HealthBarBg.Visible = true
            drawings.HealthBarBg.Size = Vector2.new(3, barH)
            drawings.HealthBarBg.Position = Vector2.new(barX, topLeft.Y)

            drawings.HealthBar.Visible = true
            drawings.HealthBar.Size = Vector2.new(3, barH * hpPct)
            drawings.HealthBar.Position = Vector2.new(barX, topLeft.Y + barH * (1 - hpPct))
            drawings.HealthBar.Color = Color3.fromRGB(255 * (1 - hpPct), 255 * hpPct, 0)
        else
            drawings.HealthBar.Visible = false
            drawings.HealthBarBg.Visible = false
        end
    end
end)

-- ============ AIMBOT ============
local function getClosestTarget()
    local closest, closestDist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local origin = Camera.CFrame.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.Aimbot.TeamCheck and isTeammate(player) then continue end
        if not isAlive(player) then continue end

        local char = player.Character
        local part = char:FindFirstChild(Config.Aimbot.TargetPart)
            or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local distFromMe = (origin - part.Position).Magnitude
        if distFromMe > Config.Aimbot.MaxDistance then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen or screenPos.Z < 0 then continue end

        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
        local distFromCenter = (screenVec - viewportCenter).Magnitude

        if distFromCenter <= Config.Aimbot.FOV and distFromCenter < closestDist then
            closestDist = distFromCenter
            closest = part
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function(dt)
    if not Config.Aimbot.Enabled then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.E) then return end -- optional hold key

    local target = getClosestTarget()
    if not target then return end

    local targetPos = target.Position
    local currentCF = Camera.CFrame
    local desiredCF = CFrame.new(currentCF.Position, targetPos)

    if Config.Aimbot.Smoothness <= 1 then
        Camera.CFrame = desiredCF
    else
        Camera.CFrame = currentCF:Lerp(desiredCF, 1 / Config.Aimbot.Smoothness)
    end
end)
