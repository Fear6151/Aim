
--========================================================
-- OMAR ASSIST V4
-- Created by Omar
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- SETTINGS
local AIM_ENABLED = false
local ESP_ENABLED = false
local TEAM_CHECK = true
local SMOOTHNESS = 15
local TARGET_PART = "Head"

local currentTarget
local highlights = {}
local running = true

local PURPLE = Color3.fromRGB(165, 95, 255)
local WHITE = Color3.fromRGB(245, 245, 250)
local BLACK = Color3.fromRGB(16, 16, 22)
local PANEL = Color3.fromRGB(27, 27, 36)

--========================================================
-- TARGET VALIDATION
--========================================================

local function getPlayer(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then
            return player
        end
    end
end

local function getPart(model)
    if not model then return nil end

    if TARGET_PART == "Head" then
        return model:FindFirstChild("Head")
    end

    return model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("HumanoidRootPart")
end

local function validTarget(model)
    if not model or not model:IsA("Model") then
        return false
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    if not getPart(model) then
        return false
    end

    local player = getPlayer(model)

    if player then
        if player == LocalPlayer then
            return false
        end

        if TEAM_CHECK
            and LocalPlayer.Team ~= nil
            and player.Team == LocalPlayer.Team then
            return false
        end
    end

    return true
end

--========================================================
-- FIND TARGETS
--========================================================

local function getCandidates()
    local result = {}
    local seen = {}

    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character

        if character and validTarget(character) then
            table.insert(result, character)
            seen[character] = true
        end
    end

    -- NPCs and bots
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("Model")
            and not seen[object]
            and not getPlayer(object)
            and validTarget(object) then

            table.insert(result, object)
            seen[object] = true
        end
    end

    return result
end

--========================================================
-- AIMLOCK
--========================================================

local function findTarget()
    local camera = Workspace.CurrentCamera
    if not camera then return nil end

    local center = camera.ViewportSize / 2
    local nearest
    local nearestDistance = math.huge

    for _, model in ipairs(getCandidates()) do
        local part = getPart(model)

        if part then
            local screenPosition =
                camera:WorldToViewportPoint(part.Position)

            -- No FOV radius restriction.
            -- Select the closest target to screen center.
            if screenPosition.Z > 0 then
                local point = Vector2.new(
                    screenPosition.X,
                    screenPosition.Y
                )

                local distance = (point - center).Magnitude

                if distance < nearestDistance then
                    nearestDistance = distance
                    nearest = model
                end
            end
        end
    end

    return nearest
end

local function aimAtTarget()
    if not AIM_ENABLED then
        currentTarget = nil
        return
    end

    local camera = Workspace.CurrentCamera
    if not camera then return end

    -- Sticky target: do not switch while valid.
    if not validTarget(currentTarget) then
        currentTarget = findTarget()
    end

    if not currentTarget then return end

    local part = getPart(currentTarget)

    if not part then
        currentTarget = nil
        return
    end

    local origin = camera.CFrame.Position
    local destination = part.Position

    local desired = CFrame.lookAt(origin, destination)

    -- Smoothness 1 = instant.
    -- Smoothness 100 = gradual.
    local alpha = 1 - math.exp(-20 / SMOOTHNESS)

    camera.CFrame = camera.CFrame:Lerp(desired, alpha)
end

--========================================================
-- ESP
--========================================================

local function removeESP(model)
    local highlight = highlights[model]

    if highlight then
        highlight:Destroy()
        highlights[model] = nil
    end
end

local function updateESP()
    local active = {}

    if ESP_ENABLED then
        for _, model in ipairs(getCandidates()) do
            if validTarget(model) then
                active[model] = true

                local highlight = highlights[model]

                if not highlight or highlight.Parent ~= model then
                    removeESP(model)

                    highlight = Instance.new("Highlight")
                    highlight.Name = "OmarESP"
                    highlight.Adornee = model
                    highlight.FillColor = PURPLE
                    highlight.OutlineColor = WHITE
                    highlight.FillTransparency = 0.75
                    highlight.OutlineTransparency = 0

                    -- Visible through walls.
                    highlight.DepthMode =
                        Enum.HighlightDepthMode.AlwaysOnTop

                    highlight.Parent = model
                    highlights[model] = highlight
                end
            end
        end
    end

    for model in pairs(highlights) do
        if not active[model] then
            removeESP(model)
        end
    end
end

--========================================================
-- GUI
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "OmarAssistV4"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(285, 350)
main.Position = UDim2.new(0.5, -142, 0.5, -175)
main.BackgroundColor3 = BLACK
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local outline = Instance.new("UIStroke")
outline.Color = PURPLE
outline.Thickness = 1.5
outline.Parent = main

local function label(text, position, size, parent)
    local object = Instance.new("TextLabel")
    object.Size = size
    object.Position = position
    object.BackgroundTransparency = 1
    object.Text = text
    object.TextColor3 = WHITE
    object.Font = Enum.Font.GothamBold
    object.TextSize = 15
    object.Parent = parent
    return object
end

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundColor3 = PANEL
header.BorderSizePixel = 0
header.Parent = main

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

label(
    "OMAR ASSIST",
    UDim2.fromOffset(14, 5),
    UDim2.new(1, -70, 0, 28),
    header
)

local subtitle = label(
    "AIM  /  ESP  /  SETTINGS",
    UDim2.fromOffset(15, 31),
    UDim2.new(1, -70, 0, 15),
    header
)
subtitle.TextColor3 = PURPLE
subtitle.TextSize = 10

-- Dragging
local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Button builder
local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -28, 0, 39)
    button.Position = UDim2.fromOffset(14, y)
    button.BackgroundColor3 = PANEL
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = WHITE
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.AutoButtonColor = false
    button.Parent = main

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = WHITE
    stroke.Thickness = 1
    stroke.Parent = button

    return button
end

local function setButton(button, text, enabled)
    button.Text = text
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(65, 40, 95)
        or PANEL
end

-- Aim
local aimButton = makeButton("AIMLOCK  [ OFF ]", 70)

aimButton.Activated:Connect(function()
    AIM_ENABLED = not AIM_ENABLED

    if not AIM_ENABLED then
        currentTarget = nil
    end

    setButton(
        aimButton,
        AIM_ENABLED and "AIMLOCK  [ ON ]" or "AIMLOCK  [ OFF ]",
        AIM_ENABLED
    )
end)

-- ESP
local espButton = makeButton("ESP  [ OFF ]", 117)

espButton.Activated:Connect(function()
    ESP_ENABLED = not ESP_ENABLED

    setButton(
        espButton,
        ESP_ENABLED and "ESP  [ ON ]" or "ESP  [ OFF ]",
        ESP_ENABLED
    )

    if not ESP_ENABLED then
        updateESP()
    end
end)

-- Team check
local teamButton = makeButton("TEAM CHECK  [ ON ]", 164)

teamButton.Activated:Connect(function()
    TEAM_CHECK = not TEAM_CHECK
    currentTarget = nil

    setButton(
        teamButton,
        TEAM_CHECK and "TEAM CHECK  [ ON ]" or "TEAM CHECK  [ OFF ]",
        TEAM_CHECK
    )
end)

-- Target part
local partButton = makeButton("TARGET: HEAD", 211)

partButton.Activated:Connect(function()
    TARGET_PART = TARGET_PART == "Head" and "Torso" or "Head"
    currentTarget = nil

    partButton.Text = "TARGET: " .. TARGET_PART:upper()
end)

-- Smoothness
local smoothLabel = label(
    "SMOOTHNESS: 15 / 100",
    UDim2.fromOffset(14, 265),
    UDim2.new(1, -28, 0, 22),
    main
)
smoothLabel.TextXAlignment = Enum.TextXAlignment.Left
smoothLabel.TextSize = 13

local slider = Instance.new("TextButton")
slider.Size = UDim2.new(1, -30, 0, 12)
slider.Position = UDim2.fromOffset(15, 300)
slider.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
slider.Text = ""
slider.Parent = main

Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0.1414, 0, 1, 0)
fill.BackgroundColor3 = PURPLE
fill.BorderSizePixel = 0
fill.Parent = slider

Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local sliderDragging = false

local function setSmoothness(input)
    local width = slider.AbsoluteSize.X
    if width <= 0 then return end

    local x = input.Position.X - slider.AbsolutePosition.X
    local alpha = math.clamp(x / width, 0, 1)

    SMOOTHNESS = math.clamp(
        math.floor(1 + alpha * 99 + 0.5),
        1,
        100
    )

    fill.Size = UDim2.new(alpha, 0, 1, 0)
    smoothLabel.Text = "SMOOTHNESS: " .. SMOOTHNESS .. " / 100"
end

slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        sliderDragging = true
        setSmoothness(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            setSmoothness(input)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

label(
    "CREATED BY OMAR",
    UDim2.new(0, 0, 1, -25),
    UDim2.new(1, 0, 0, 18),
    main
).TextColor3 = GRAY

-- Hide / reopen
local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.fromOffset(30, 30)
hideButton.Position = UDim2.new(1, -38, 0, 12)
hideButton.BackgroundColor3 = PANEL
hideButton.Text = "—"
hideButton.TextColor3 = WHITE
hideButton.TextSize = 18
hideButton.Parent = header

local reopen = Instance.new("TextButton")
reopen.Size = UDim2.fromOffset(110, 38)
reopen.Position = UDim2.new(0, 15, 0.5, -19)
reopen.BackgroundColor3 = BLACK
reopen.Text = "OMAR  +"
reopen.TextColor3 = WHITE
reopen.Font = Enum.Font.GothamBold
reopen.Visible = false
reopen.Parent = gui

Instance.new("UICorner", reopen).CornerRadius = UDim.new(0, 8)

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = PURPLE
reopenStroke.Parent = reopen

hideButton.Activated:Connect(function()
    main.Visible = false
    reopen.Visible = true
end)

reopen.Activated:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

--========================================================
-- MAIN LOOP
--========================================================

local scanClock = 0
local espClock = 0

local scanInterval = 0.4
local espInterval = 0.15

local function update()
    if not running then return end

    scanClock += 0.4
    espClock += 0.15

    if scanClock >= scanInterval then
        scanClock = 0
    end

    if espClock >= espInterval then
        espClock = 0
        updateESP()
    end
end

-- Keep camera aim after Roblox's normal camera update.
RunService:BindToRenderStep(
    "OmarAssistAim",
    Enum.RenderPriority.Camera.Value + 1,
    function()
        if running and AIM_ENABLED then
            aimAtTarget()
        end
    end
)

RunService.Heartbeat:Connect(function()
    if not running then return end

    update()
end)

-- Cleanup if the GUI is removed.
gui.Destroying:Connect(function()
    running = false
    RunService:UnbindFromRenderStep("OmarAssistAim")

    for model, highlight in pairs(highlights) do
        if highlight then
            highlight:Destroy()
        end
        highlights[model] = nil
    end
end)

print("Omar Assist V4 loaded successfully")
