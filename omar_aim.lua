--// Aim Assist + ESP
--// For your own Roblox Studio experience

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Settings
local AimEnabled = false
local ESPEnabled = false
local AimFOV = 150
local AimSmoothness = 0.15

--// UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimESP_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 130)
Main.Position = UDim2.new(0, 20, 0.5, -65)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Aim + ESP"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.new(0.85, 0, 0, 35)
AimButton.Position = UDim2.new(0.075, 0, 0, 42)
AimButton.Text = "Aim Assist: OFF"
AimButton.TextColor3 = Color3.new(1, 1, 1)
AimButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimButton.Font = Enum.Font.Gotham
AimButton.TextSize = 14
AimButton.Parent = Main

local ESPButton = AimButton:Clone()
ESPButton.Position = UDim2.new(0.075, 0, 0, 85)
ESPButton.Text = "ESP: OFF"
ESPButton.Parent = Main

--// Toggle buttons
AimButton.MouseButton1Click:Connect(function()
    AimEnabled = not AimEnabled
    AimButton.Text = "Aim Assist: " .. (AimEnabled and "ON" or "OFF")
end)

ESPButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPButton.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
end)

--// Find closest player
local function GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = AimFOV

    local mousePosition = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            local character = player.Character
            if character then

                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local head = character:FindFirstChild("Head")

                if humanoid and head and humanoid.Health > 0 then

                    local screenPosition, visible =
                        Camera:WorldToViewportPoint(head.Position)

                    if visible then
                        local distance = (
                            Vector2.new(screenPosition.X, screenPosition.Y)
                            - mousePosition
                        ).Magnitude

                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

--// Aim Assist
RunService.RenderStepped:Connect(function()

    if AimEnabled then

        local target = GetClosestPlayer()

        if target and target.Character then

            local head = target.Character:FindFirstChild("Head")

            if head then
                local targetCFrame =
                    CFrame.new(Camera.CFrame.Position, head.Position)

                Camera.CFrame =
                    Camera.CFrame:Lerp(targetCFrame, AimSmoothness)
            end
        end
    end
end)

--// ESP
local ESPObjects = {}

local function CreateESP(player)

    if player == LocalPlayer then
        return
    end
local highlight = Instance.new("Highlight")
    highlight.Name = "ESP"
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Enabled = false
    highlight.Parent = workspace

    ESPObjects[player] = highlight
end

local function RemoveESP(player)

    if ESPObjects[player] then
        ESPObjects[player]:Destroy()
        ESPObjects[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()

    for player, highlight in pairs(ESPObjects) do

        if ESPEnabled and player.Character then
            highlight.Adornee = player.Character
            highlight.Enabled = true
        else
            highlight.Enabled = false
        end
    end
end)

--// Make UI draggable
local dragging = false
local dragStart
local startPosition

Main.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
