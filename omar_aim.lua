
--==================================================
-- OMAR AIM ASSIST + ESP
-- Created by: Omar
-- For your own Roblox Studio game
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local AIM_ENABLED = false
local ESP_ENABLED = false
local TEAM_CHECK = true

local SMOOTHNESS = 10
local TARGET_PART = "Head"

local currentTarget = nil
local highlights = {}

local running = true
local connections = {}

--==================================================
-- COLORS
--==================================================

local BLACK = Color3.fromRGB(17, 17, 22)
local PANEL = Color3.fromRGB(27, 27, 35)
local PURPLE = Color3.fromRGB(165, 95, 255)
local WHITE = Color3.fromRGB(245, 245, 250)
local GRAY = Color3.fromRGB(155, 155, 170)

--==================================================
-- CONNECTION MANAGEMENT
--==================================================

local function track(connection)
    table.insert(connections, connection)
    return connection
end

--==================================================
-- PLAYER VALIDATION
--==================================================

local function isEnemy(player)
    if player == LocalPlayer then
        return false
    end

    if not TEAM_CHECK then
        return true
    end

    if LocalPlayer.Team ~= nil
        and player.Team == LocalPlayer.Team then
        return false
    end

    return true
end

local function getTargetPart(player)
    local character = player.Character

    if not character then
        return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        return nil
    end

    if TARGET_PART == "Head" then
        return character:FindFirstChild("Head")
    end

    return character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("HumanoidRootPart")
end

local function isValidTarget(player)
    if not player or not player.Parent then
        return false
    end

    if not isEnemy(player) then
        return false
    end

    return getTargetPart(player) ~= nil
end

--==================================================
-- GUI CREATION
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmarAimAssist"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(300, 365)
Main.Position = UDim2.new(0.5, -150, 0.5, -182)
Main.BackgroundColor3 = BLACK
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = PURPLE
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

--==================================================
-- DRAGGABLE HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -65, 0, 30)
HeaderTitle.Position = UDim2.fromOffset(15, 9)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "OMAR ASSIST"
HeaderTitle.TextColor3 = WHITE
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 18
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local HeaderSubtitle = Instance.new("TextLabel")
HeaderSubtitle.Size = UDim2.new(1, -65, 0, 17)
HeaderSubtitle.Position = UDim2.fromOffset(16, 36)
HeaderSubtitle.BackgroundTransparency = 1
HeaderSubtitle.Text = "AIM  /  VISUALS"
HeaderSubtitle.TextColor3 = PURPLE
HeaderSubtitle.Font = Enum.Font.GothamMedium
HeaderSubtitle.TextSize = 10
HeaderSubtitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderSubtitle.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(32, 32)
CloseButton.Position = UDim2.new(1, -44, 0, 16)
CloseButton.BackgroundColor3 = PANEL
CloseButton.Text = "×"
CloseButton.TextColor3 = WHITE
CloseButton.TextSize = 23
CloseButton.Font = Enum.Font.Gotham
CloseButton.AutoButtonColor = true
CloseButton.Parent = Header

Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = WHITE
CloseStroke.Thickness = 1
CloseStroke.Parent = CloseButton

--==================================================
-- DRAG SUPPORT: MOUSE + TOUCH
--==================================================

local dragging = false
local dragStart
local startPosition
local dragInput

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- UI HELPERS
--==================================================

local function createButton(name, position, size)
    local button = Instance.new("TextButton")

    button.Name = name
    button.Size = size
    button.Position = position

    button.BackgroundColor3 = PANEL
    button.BorderSizePixel = 0

    button.TextColor3 = WHITE
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13

    button.AutoButtonColor = false
    button.Parent = Main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = WHITE
    stroke.Thickness = 1
    stroke.Transparency = 0.12
    stroke.Parent = button

    return button
end

local function updateButton(button, enabled)
    if enabled then
        button.BackgroundColor3 = Color3.fromRGB(65, 39, 95)
    else
        button.BackgroundColor3 = PANEL
    end
end

--==================================================
-- AIM BUTTON
--==================================================

local AimButton = createButton(
    "AimButton",
    UDim2.fromOffset(15, 82),
    UDim2.new(1, -30, 0, 42)
)

local function refreshAimButton()
    AimButton.Text = AIM_ENABLED and "AIM ASSIST     [ ON ]"
        or "AIM ASSIST     [ OFF ]"

    updateButton(AimButton, AIM_ENABLED)
end

AimButton.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED

    if not AIM_ENABLED then
        currentTarget = nil
    end

    refreshAimButton()
end)

refreshAimButton()

--==================================================
-- ESP BUTTON
--==================================================

local ESPButton = createButton(
    "ESPButton",
    UDim2.fromOffset(15, 132),
    UDim2.new(1, -30, 0, 42)
)

local function refreshESPButton()
    ESPButton.Text = ESP_ENABLED and "ENEMY ESP     [ ON ]"
        or "ENEMY ESP     [ OFF ]"

    updateButton(ESPButton, ESP_ENABLED)
end

ESPButton.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    refreshESPButton()
end)

refreshESPButton()

--==================================================
-- TEAM CHECK BUTTON
--==================================================

local TeamButton = createButton(
    "TeamButton",
    UDim2.fromOffset(15, 182),
    UDim2.new(1, -30, 0, 42)
)

local function refreshTeamButton()
    TeamButton.Text = TEAM_CHECK and "TEAM CHECK     [ ON ]"
        or "TEAM CHECK     [ OFF ]"

    updateButton(TeamButton, TEAM_CHECK)
end

TeamButton.MouseButton1Click:Connect(function()
    TEAM_CHECK = not TEAM_CHECK
    currentTarget = nil
    refreshTeamButton()
end)

refreshTeamButton()

--==================================================
-- TARGET PART SELECTOR
--==================================================

local TargetButton = createButton(
    "TargetButton",
    UDim2.fromOffset(15, 232),
    UDim2.new(1, -30, 0, 42)
)

local function refreshTargetButton()
    TargetButton.Text = "TARGET PART     [ " .. TARGET_PART:upper() .. " ]"
end

TargetButton.MouseButton1Click:Connect(function()
    if TARGET_PART == "Head" then
        TARGET_PART = "Torso"
    else
        TARGET_PART = "Head"
    end

    currentTarget = nil
    refreshTargetButton()
end)

refreshTargetButton()

--==================================================
-- SMOOTHNESS SLIDER
--==================================================

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, -30, 0, 22)
SliderLabel.Position = UDim2.fromOffset(15, 283)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = WHITE
SliderLabel.Font = Enum.Font.GothamMedium
SliderLabel.TextSize = 13
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = Main

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, -30, 0, 7)
SliderTrack.Position = UDim2.fromOffset(15, 312)
SliderTrack.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = Main

Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = PURPLE
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderButton = Instance.new("TextButton")
SliderButton.Size = UDim2.new(1, 0, 0, 30)
SliderButton.Position = UDim2.new(0, 0, 0.5, -15)
SliderButton.BackgroundTransparency = 1
SliderButton.Text = ""
SliderButton.Parent = SliderTrack

local SliderDot = Instance.new("Frame")
SliderDot.Size = UDim2.fromOffset(15, 15)
SliderDot.AnchorPoint = Vector2.new(0.5, 0.5)
SliderDot.Position = UDim2.new(0, 0, 0.5, 0)
SliderDot.BackgroundColor3 = WHITE
SliderDot.BorderSizePixel = 0
SliderDot.Parent = SliderTrack

Instance.new("UICorner", SliderDot).CornerRadius = UDim.new(1, 0)

local function updateSlider(value)
    SMOOTHNESS = math.clamp(math.floor(value + 0.5), 1, 30)

    local alpha = (SMOOTHNESS - 1) / 29

    SliderFill.Size = UDim2.new(alpha, 0, 1, 0)
    SliderDot.Position = UDim2.new(alpha, 0, 0.5, 0)

    SliderLabel.Text = "SMOOTHNESS                         " .. SMOOTHNESS
end

local sliderDragging = false

local function setSliderFromInput(input)
    local relativeX = input.Position.X - SliderTrack.AbsolutePosition.X
    local alpha = math.clamp(relativeX / SliderTrack.AbsoluteSize.X, 0, 1)

    updateSlider(1 + alpha * 29)
end

SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        sliderDragging = true
        setSliderFromInput(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            setSliderFromInput(input)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        sliderDragging = false
    end
end)

updateSlider(SMOOTHNESS)

--==================================================
-- ESP
--==================================================

local function removeHighlight(player)
    local highlight = highlights[player]

    if highlight then
        highlight:Destroy()
        highlights[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if ESP_ENABLED and isEnemy(player) then
            local character = player.Character

            if character then
                local highlight = highlights[player]

                if not highlight or highlight.Parent ~= character then
                    removeHighlight(player)

                    highlight = Instance.new("Highlight")
                    highlight.Name = "OmarESP"
                    highlight.Adornee = character
                    highlight.FillColor = PURPLE
                    highlight.OutlineColor = WHITE
                    highlight.FillTransparency = 0.78
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
                    highlight.Parent = character

                    highlights[player] = highlight
                end
            else
                removeHighlight(player)
            end
        else
            removeHighlight(player)
        end
    end
end

--==================================================
-- TARGET ACQUISITION
--==================================================

local function getClosestTarget()
    local camera = workspace.CurrentCamera

    if not camera then
        return nil
    end

    local viewport = camera.ViewportSize
    local screenCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)

    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local part = getTargetPart(player)

            if part then
                local screenPosition, visible =
                    camera:WorldToViewportPoint(part.Position)

                if visible and screenPosition.Z > 0 then
                    local distance = (
                        Vector2.new(screenPosition.X, screenPosition.Y)
                        - screenCenter
                    ).Magnitude

                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

--==================================================
-- AIM TRACKING
--==================================================

local function updateAim()
    if not AIM_ENABLED then
        currentTarget = nil
        return
    end

    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    -- Keep the current target while valid.
    if not isValidTarget(currentTarget) then
        currentTarget = getClosestTarget()
    end

    if not currentTarget then
        return
    end

    local part = getTargetPart(currentTarget)

    if not part then
        currentTarget = nil
        return
    end

    local cameraPosition = camera.CFrame.Position

    local desiredCFrame = CFrame.lookAt(
        cameraPosition,
        part.Position
    )

    -- Higher smoothness value means slower camera movement.
    local alpha = math.clamp(1 / SMOOTHNESS, 0.01, 1)

    camera.CFrame = camera.CFrame:Lerp(desiredCFrame, alpha)
end

--==================================================
-- MAIN UPDATE
--==================================================

track(RunService.RenderStepped:Connect(function()
    if not running then
        return
    end

    updateESP()
    updateAim()
end))

--==================================================
-- CLEANUP
--==================================================

local function cleanup()
    if not running then
        return
    end

    running = false
    AIM_ENABLED = false
    ESP_ENABLED = false
    currentTarget = nil

    for _, connection in ipairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end

    for player in pairs(highlights) do
        removeHighlight(player)
    end

    ScreenGui:Destroy()
end

CloseButton.MouseButton1Click:Connect(cleanup)

print("Omar Aim Assist loaded successfully.")
