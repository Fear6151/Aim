
--========================================================
-- OMAR ASSIST V3
-- Created by: Omar
-- Roblox Studio - Own Game
--
-- Features:
-- Real camera aimlock
-- Sticky target selection
-- Head / Torso targeting
-- Smoothness 1-100
-- Player and NPC ESP
-- Team exclusion
-- Mobile-friendly draggable UI
-- Hide / reopen UI
--========================================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================
-- SETTINGS
--========================================================

local AIM_ENABLED = false
local ESP_ENABLED = false
local TEAM_CHECK = true

local SMOOTHNESS = 15
local TARGET_PART = "Head"

local currentTarget = nil
local candidates = {}
local highlights = {}

local running = true
local uiVisible = true

local scanElapsed = 0
local espElapsed = 0

local SCAN_INTERVAL = 0.5
local ESP_INTERVAL = 0.2

--========================================================
-- COLORS
--========================================================

local BLACK = Color3.fromRGB(15, 15, 20)
local PANEL = Color3.fromRGB(26, 26, 35)
local PURPLE = Color3.fromRGB(165, 95, 255)
local WHITE = Color3.fromRGB(245, 245, 250)
local GRAY = Color3.fromRGB(155, 155, 170)

--========================================================
-- CHARACTER HELPERS
--========================================================

local function getHumanoid(model)
    if not model or not model:IsA("Model") then
        return nil
    end

    return model:FindFirstChildOfClass("Humanoid")
end

local function getTargetPart(model)
    if not model then
        return nil
    end

    if TARGET_PART == "Head" then
        return model:FindFirstChild("Head")
    end

    return model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("HumanoidRootPart")
end

local function getPlayerFromCharacter(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then
            return player
        end
    end

    return nil
end

local function isEnemy(model)
    if not model or not model.Parent then
        return false
    end

    local humanoid = getHumanoid(model)

    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    if not getTargetPart(model) then
        return false
    end

    local player = getPlayerFromCharacter(model)

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
-- TARGET SCANNER
--========================================================

local function refreshCandidates()
    local found = {}
    local seen = {}

    -- Player characters
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character

        if character and isEnemy(character) then
            table.insert(found, character)
            seen[character] = true
        end
    end

    -- NPCs / bots
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("Model")
            and not seen[object]
            and getHumanoid(object)
            and not getPlayerFromCharacter(object)
            and isEnemy(object) then

            table.insert(found, object)
            seen[object] = true
        end
    end

    candidates = found
end

--========================================================
-- GUI ROOT
--========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmarAssistV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.Parent = PlayerGui

-- MAIN WINDOW
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(290, 390)
Main.Position = UDim2.new(0.5, -145, 0.5, -195)
Main.BackgroundColor3 = BLACK
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = PURPLE
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 62)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 28)
Title.Position = UDim2.fromOffset(14, 8)
Title.BackgroundTransparency = 1
Title.Text = "OMAR ASSIST"
Title.TextColor3 = WHITE
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -100, 0, 16)
Subtitle.Position = UDim2.fromOffset(15, 35)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "AIM  /  ESP  /  SETTINGS"
Subtitle.TextColor3 = PURPLE
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

--========================================================
-- HIDE / REOPEN
--========================================================

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.fromOffset(32, 32)
HideButton.Position = UDim2.new(1, -44, 0, 15)
HideButton.BackgroundColor3 = PANEL
HideButton.Text = "—"
HideButton.TextColor3 = WHITE
HideButton.TextSize = 20
HideButton.Font = Enum.Font.GothamBold
HideButton.Parent = Header

Instance.new("UICorner", HideButton).CornerRadius = UDim.new(0, 8)

local hideStroke = Instance.new("UIStroke")
hideStroke.Color = WHITE
hideStroke.Thickness = 1
hideStroke.Parent = HideButton

local ReopenButton = Instance.new("TextButton")
ReopenButton.Name = "OmarReopen"
ReopenButton.Size = UDim2.fromOffset(115, 38)
ReopenButton.Position = UDim2.new(0, 15, 0.5, -19)
ReopenButton.BackgroundColor3 = BLACK
ReopenButton.Text = "OMAR  +"
ReopenButton.TextColor3 = WHITE
ReopenButton.Font = Enum.Font.GothamBold
ReopenButton.TextSize = 14
ReopenButton.Visible = false
ReopenButton.Parent = ScreenGui

Instance.new("UICorner", ReopenButton).CornerRadius = UDim.new(0, 9)

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = PURPLE
reopenStroke.Thickness = 1.5
reopenStroke.Parent = ReopenButton

HideButton.Activated:Connect(function()
    uiVisible = false
    Main.Visible = false
    ReopenButton.Visible = true
end)

ReopenButton.Activated:Connect(function()
    uiVisible = true
    Main.Visible = true
    ReopenButton.Visible = false
end)

--========================================================
-- DRAGGING: MOUSE AND TOUCH
--========================================================

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

--========================================================
-- BUTTON HELPER
--========================================================

local function makeButton(name, y)
    local button = Instance.new("TextButton")

    button.Name = name
    button.Size = UDim2.new(1, -30, 0, 40)
    button.Position = UDim2.fromOffset(15, y)

    button.BackgroundColor3 = PANEL
    button.BorderSizePixel = 0

    button.TextColor3 = WHITE
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.AutoButtonColor = false
    button.Parent = Main

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = WHITE
    stroke.Thickness = 1
    stroke.Transparency = 0.12
    stroke.Parent = button

    return button
end

local function styleButton(button, enabled)
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(65, 40, 95)
        or PANEL
end

--========================================================
-- AIM TOGGLE
--========================================================

local AimButton = makeButton("AimButton", 77)

local function refreshAim()
    AimButton.Text = AIM_ENABLED
        and "AIMLOCK          [ ON ]"
        or "AIMLOCK          [ OFF ]"

    styleButton(AimButton, AIM_ENABLED)
end

AimButton.Activated:Connect(function()
    AIM_ENABLED = not AIM_ENABLED

    if not AIM_ENABLED then
        currentTarget = nil
    end

    refreshAim()
end)

refreshAim()

--========================================================
-- ESP TOGGLE
--========================================================

local ESPButton = makeButton("ESPButton", 125)

local function refreshESP()
    ESPButton.Text = ESP_ENABLED
        and "PLAYER + BOT ESP  [ ON ]"
        or "PLAYER + BOT ESP  [ OFF ]"

    styleButton(ESPButton, ESP_ENABLED)
end

ESPButton.Activated:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    refreshESP()
end)

refreshESP()

--========================================================
-- TEAM CHECK
--========================================================

local TeamButton = makeButton("TeamButton", 173)

local function refreshTeam()
    TeamButton.Text = TEAM_CHECK
        and "TEAM CHECK       [ ON ]"
        or "TEAM CHECK       [ OFF ]"

    styleButton(TeamButton, TEAM_CHECK)
end

TeamButton.Activated:Connect(function()
    TEAM_CHECK = not TEAM_CHECK
    currentTarget = nil
    refreshTeam()
end)

refreshTeam()

--========================================================
-- TARGET PART
--========================================================

local TargetButton = makeButton("TargetButton", 221)

local function refreshTarget()
    TargetButton.Text = "TARGET PART      [ " .. TARGET_PART:upper() .. " ]"
end

TargetButton.Activated:Connect(function()
    TARGET_PART = TARGET_PART == "Head" and "Torso" or "Head"
    currentTarget = nil
    refreshTarget()
end)

refreshTarget()

--========================================================
-- SMOOTHNESS SLIDER: 1-100
--========================================================

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, -30, 0, 22)
SliderLabel.Position = UDim2.fromOffset(15, 274)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = WHITE
SliderLabel.Font = Enum.Font.GothamMedium
SliderLabel.TextSize = 13
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = Main

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, -30, 0, 7)
SliderTrack.Position = UDim2.fromOffset(15, 307)
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

local SliderInput = Instance.new("TextButton")
SliderInput.Size = UDim2.new(1, 0, 0, 30)
SliderInput.Position = UDim2.new(0, 0, 0.5, -15)
SliderInput.BackgroundTransparency = 1
SliderInput.Text = ""
SliderInput.Parent = SliderTrack

local SliderDot = Instance.new("Frame")
SliderDot.Size = UDim2.fromOffset(15, 15)
SliderDot.AnchorPoint = Vector2.new(0.5, 0.5)
SliderDot.Position = UDim2.new(0, 0, 0.5, 0)
SliderDot.BackgroundColor3 = WHITE
SliderDot.BorderSizePixel = 0
SliderDot.Parent = SliderTrack

Instance.new("UICorner", SliderDot).CornerRadius = UDim.new(1, 0)

local sliderDragging = false

local function updateSlider(value)
    SMOOTHNESS = math.clamp(math.floor(value + 0.5), 1, 100)

    local alpha = (SMOOTHNESS - 1) / 99

    SliderFill.Size = UDim2.new(alpha, 0, 1, 0)
    SliderDot.Position = UDim2.new(alpha, 0, 0.5, 0)

    SliderLabel.Text = "SMOOTHNESS                         " .. SMOOTHNESS
end

local function setSlider(input)
    local width = SliderTrack.AbsoluteSize.X

    if width <= 0 then
        return
    end

    local x = input.Position.X - SliderTrack.AbsolutePosition.X
    local alpha = math.clamp(x / width, 0, 1)

    updateSlider(1 + alpha * 99)
end

SliderInput.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        sliderDragging = true
        setSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            setSlider(input)
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

--========================================================
-- CREDIT
--========================================================

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 1, -27)
Credit.BackgroundTransparency = 1
Credit.Text = "CREATED BY OMAR"
Credit.TextColor3 = GRAY
Credit.Font = Enum.Font.GothamMedium
Credit.TextSize = 10
Credit.Parent = Main

--========================================================
-- ESP
--========================================================

local function removeHighlight(model)
    local highlight = highlights[model]

    if highlight then
        highlight:Destroy()
        highlights[model] = nil
    end
end

local function updateESP()
    local active = {}

    if ESP_ENABLED then
        for _, model in ipairs(candidates) do
            if isEnemy(model) then
                active[model] = true

                local highlight = highlights[model]

                if not highlight or highlight.Parent ~= model then
                    removeHighlight(model)

                    highlight = Instance.new("Highlight")
                    highlight.Name = "OmarESP"
                    highlight.Adornee = model
                    highlight.FillColor = PURPLE
                    highlight.OutlineColor = WHITE
                    highlight.FillTransparency = 0.78
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
                    highlight.Parent = model

                    highlights[model] = highlight
                end
            end
        end
    end

    for model in pairs(highlights) do
        if not active[model] then
            removeHighlight(model)
        end
    end
end

--========================================================
-- TARGET SELECTION
--========================================================

local function isValidTarget(model)
    return model ~= nil
        and model.Parent ~= nil
        and isEnemy(model)
end

local function getClosestTarget()
    local camera = Workspace.CurrentCamera

    if not camera then
        return nil
    end

    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    local closest = nil
    local closestDistance = math.huge

    for _, model in ipairs(candidates) do
        if isValidTarget(model) then
            local part = getTargetPart(model)

            if part then
                local screen, visible = camera:WorldToViewportPoint(part.Position)

                if visible and screen.Z > 0 then
                    local distance = (
                        Vector2.new(screen.X, screen.Y) - center
                    ).Magnitude

                    if distance < closestDistance then
                        closestDistance = distance
                        closest = model
                    end
                end
            end
        end
    end

    return closest
end

--========================================================
-- REAL CAMERA AIMLOCK
--========================================================

local function updateAim()
    if not AIM_ENABLED then
        currentTarget = nil
        return
    end

    local camera = Workspace.CurrentCamera

    if not camera then
        return
    end

    -- Sticky lock: retain target while valid.
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

    local origin = camera.CFrame.Position
    local destination = part.Position

    -- Actual camera rotation toward the target.
    local desired = CFrame.lookAt(origin, destination)

    -- Smoothness 1 = instant.
    -- Smoothness 100 = very gradual.
    local alpha = 1 - math.exp(-12 / SMOOTHNESS)

    camera.CFrame = camera.CFrame:Lerp(desired, alpha)
end

--========================================================
-- UPDATE LOOP
--========================================================

track(RunService.RenderStepped:Connect(function(dt)
    if not running then
        return
    end

    scanElapsed += dt
    espElapsed += dt

    if scanElapsed >= SCAN_INTERVAL then
        scanElapsed = 0
        refreshCandidates()
    end

    if espElapsed >= ESP_INTERVAL then
        espElapsed = 0
        updateESP()
    end
end))

-- Run after Roblox's default camera update.
RunService:BindToRenderStep(
    "OmarAssistCamera",
    Enum.RenderPriority.Camera.Value + 1,
    function()
        if running and AIM_ENABLED then
            updateAim()
        end
    end
)

--========================================================
-- CLEANUP
--========================================================

local function cleanup()
    if not running then
        return
    end

    running = false
    AIM_ENABLED = false
    ESP_ENABLED = false
    currentTarget = nil

    RunService:UnbindFromRenderStep("OmarAssistCamera")

    for _, connection in ipairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end

    for model in pairs(highlights) do
        removeHighlight(model)
    end

    ScreenGui:Destroy()
end

-- Optional cleanup if the GUI is removed externally.
ScreenGui.Destroying:Connect(function()
    if running then
        cleanup()
    end
end)

print("Omar Assist V3 loaded.")
