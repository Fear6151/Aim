--[[
    PURPLE AIM + ESP
    Roblox Studio Edition

    Crate by, Omar

    Place this LocalScript in:
    StarterPlayer > StarterPlayerScripts
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------

local Settings = {

    -- AIM
    AimEnabled = false,
    Smoothness = 75,
    FOV = 180,
    TargetPart = "Head",

    TeamCheck = true,
    HoldToAim = false,
    IgnoreDead = true,

    -- Add teams that should never be targeted.
    ExcludedTeams = {
        -- ["Lobby"] = true,
        -- ["Spectators"] = true,
    },

    -- ESP
    ESPEnabled = false,

    ESP = {
        Box = true,
        Name = true,
        Distance = true,
        Health = true,
    }
}

------------------------------------------------------------
-- COLORS
------------------------------------------------------------

local Colors = {
    Background = Color3.fromRGB(9, 7, 13),
    Panel = Color3.fromRGB(17, 13, 25),
    Button = Color3.fromRGB(25, 19, 36),

    Purple = Color3.fromRGB(145, 70, 255),
    PurpleDark = Color3.fromRGB(80, 35, 150),

    White = Color3.fromRGB(245, 245, 250),
    Gray = Color3.fromRGB(155, 150, 165),

    Red = Color3.fromRGB(215, 55, 65),
}

------------------------------------------------------------
-- STATE
------------------------------------------------------------

local CurrentTarget = nil
local RMBDown = false
local MenuOpen = true

local ESPObjects = {}

------------------------------------------------------------
-- SCREEN GUI
------------------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "PurpleAimESP"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------
-- FOV CIRCLE
------------------------------------------------------------

local FOVCircle = Instance.new("Frame")

FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)

FOVCircle.Size = UDim2.fromOffset(
    Settings.FOV * 2,
    Settings.FOV * 2
)

FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = Gui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Colors.Purple
FOVStroke.Thickness = 2
FOVStroke.Transparency = 0.15
FOVStroke.Parent = FOVCircle

------------------------------------------------------------
-- MAIN WINDOW
------------------------------------------------------------

local Main = Instance.new("Frame")

Main.Name = "Main"
Main.Size = UDim2.fromOffset(350, 470)
Main.Position = UDim2.fromOffset(25, 160)

Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0

Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.PurpleDark
MainStroke.Thickness = 1
MainStroke.Parent = Main

------------------------------------------------------------
-- TITLE BAR
------------------------------------------------------------

local TitleBar = Instance.new("Frame")

TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = Colors.Panel
TitleBar.BorderSizePixel = 0

TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")

Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(15, 0)
Title.Size = UDim2.new(1, -100, 1, 0)

Title.Text = "PURPLE  •  AIM + ESP"
Title.TextColor3 = Colors.White
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

Title.Parent = TitleBar

------------------------------------------------------------
-- CLOSE BUTTON
------------------------------------------------------------

local Close = Instance.new("TextButton")

Close.Size = UDim2.fromOffset(32, 30)
Close.Position = UDim2.new(1, -40, 0, 9)

Close.BackgroundColor3 = Colors.Red
Close.Text = "×"

Close.TextColor3 = Colors.White
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold

Close.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

------------------------------------------------------------
-- CONTENT
------------------------------------------------------------

local Content = Instance.new("Frame")

Content.Position = UDim2.fromOffset(12, 58)
Content.Size = UDim2.new(1, -24, 1, -70)

Content.BackgroundTransparency = 1
Content.Parent = Main

local Layout = Instance.new("UIListLayout")

Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

Layout.Parent = Content

------------------------------------------------------------
-- BUTTON CREATOR
------------------------------------------------------------

local function CreateButton(Text)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, 0, 0, 37)

    Button.BackgroundColor3 = Colors.Button
    Button.BorderSizePixel = 0

    Button.Text = Text
    Button.TextColor3 = Colors.White
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamMedium

    Button.AutoButtonColor = false

    Button.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")

    Stroke.Color = Colors.White
    Stroke.Thickness = 1
    Stroke.Transparency = 0.45

    Stroke.Parent = Button

    return Button, Stroke
end

------------------------------------------------------------
-- BUTTON ACTIVE STYLE
------------------------------------------------------------

local function SetButtonState(
    Button,
    Stroke,
    Active
)

    if Active then

        Button.BackgroundColor3 =
            Colors.Purple

        Stroke.Color =
            Colors.White

        Stroke.Transparency = 0

    else

        Button.BackgroundColor3 =
            Colors.Button

        Stroke.Color =
            Colors.White

        Stroke.Transparency = 0.45
    end
end

------------------------------------------------------------
-- AIMBOT
------------------------------------------------------------

local AimButton, AimStroke =
    CreateButton("AIMBOT  •  OFF")

AimButton.MouseButton1Click:Connect(
    function()

        Settings.AimEnabled =
            not Settings.AimEnabled

        if not Settings.AimEnabled then
            CurrentTarget = nil
        end

        AimButton.Text =
            "AIMBOT  •  " ..
            (
                Settings.AimEnabled
                and "ON"
                or "OFF"
            )

        SetButtonState(
            AimButton,
            AimStroke,
            Settings.AimEnabled
        )
    end
)

------------------------------------------------------------
-- SMOOTHNESS
------------------------------------------------------------

local SmoothButton =
    CreateButton("Smoothness  •  75%")

SmoothButton.MouseButton1Click:Connect(
    function()

        Settings.Smoothness += 10

        if Settings.Smoothness > 100 then
            Settings.Smoothness = 0
        end

        SmoothButton.Text =
            "Smoothness  •  " ..
            Settings.Smoothness .. "%"
    end
)

------------------------------------------------------------
-- FOV SIZE
------------------------------------------------------------

local FOVButton =
    CreateButton("Aim FOV  •  180")

FOVButton.MouseButton1Click:Connect(
    function()

        Settings.FOV += 30

        if Settings.FOV > 500 then
            Settings.FOV = 60
        end

        FOVButton.Text =
            "Aim FOV  •  " ..
            Settings.FOV

        FOVCircle.Size =
            UDim2.fromOffset(
                Settings.FOV * 2,
                Settings.FOV * 2
            )
    end
)

------------------------------------------------------------
-- FOV CIRCLE
------------------------------------------------------------

local FOVToggle, FOVToggleStroke =
    CreateButton("FOV Circle  •  OFF")

FOVToggle.MouseButton1Click:Connect(
    function()

        FOVCircle.Visible =
            not FOVCircle.Visible

        FOVToggle.Text =
            "FOV Circle  •  " ..
            (
                FOVCircle.Visible
                and "ON"
                or "OFF"
            )

        SetButtonState(
            FOVToggle,
            FOVToggleStroke,
            FOVCircle.Visible
        )
    end
)

------------------------------------------------------------
-- TARGET PART
------------------------------------------------------------

local TargetButton =
    CreateButton("Target Part  •  HEAD")

TargetButton.MouseButton1Click:Connect(
    function()

        if Settings.TargetPart == "Head" then

            Settings.TargetPart =
                "HumanoidRootPart"

        else

            Settings.TargetPart =
                "Head"
        end

        TargetButton.Text =
            "Target Part  •  " ..
            string.upper(
                Settings.TargetPart
            )

        CurrentTarget = nil
    end
)

------------------------------------------------------------
-- TEAM CHECK
------------------------------------------------------------

local TeamButton, TeamStroke =
    CreateButton("Team Check  •  ON")

TeamButton.MouseButton1Click:Connect(
    function()

        Settings.TeamCheck =
            not Settings.TeamCheck

        TeamButton.Text =
            "Team Check  •  " ..
            (
                Settings.TeamCheck
                and "ON"
                or "OFF"
            )

        SetButtonState(
            TeamButton,
            TeamStroke,
            Settings.TeamCheck
        )

        CurrentTarget = nil
    end
)

------------------------------------------------------------
-- HOLD RMB
------------------------------------------------------------

local HoldButton, HoldStroke =
    CreateButton("Hold RMB  •  OFF")

HoldButton.MouseButton1Click:Connect(
    function()

        Settings.HoldToAim =
            not Settings.HoldToAim

        HoldButton.Text =
            "Hold RMB  •  " ..
            (
                Settings.HoldToAim
                and "ON"
                or "OFF"
            )

        SetButtonState(
            HoldButton,
            HoldStroke,
            Settings.HoldToAim
        )

        CurrentTarget = nil
    end
)

------------------------------------------------------------
-- ESP MAIN TOGGLE
------------------------------------------------------------

local ESPButton, ESPStroke =
    CreateButton("ESP  •  OFF")

ESPButton.MouseButton1Click:Connect(
    function()

        Settings.ESPEnabled =
            not Settings.ESPEnabled

        ESPButton.Text =
            "ESP  •  " ..
            (
                Settings.ESPEnabled
                and "ON"
                or "OFF"
            )

        SetButtonState(
            ESPButton,
            ESPStroke,
            Settings.ESPEnabled
        )
    end
)

------------------------------------------------------------
-- ESP BOX
------------------------------------------------------------

local BoxButton, BoxStroke =
    CreateButton("ESP Box  •  ON")

BoxButton.MouseButton1Click:Connect(
    function()

        Settings.ESP.Box =
            not Settings.ESP.Box

        BoxButton.Text =
            "ESP Box  •  " ..
            (
                Settings.ESP.Box
                and "ON"
                or "OFF"
            )

        SetButtonState(
            BoxButton,
            BoxStroke,
            Settings.ESP.Box
        )
    end
)

------------------------------------------------------------
-- ESP NAME + DISTANCE
------------------------------------------------------------

local NameButton, NameStroke =
    CreateButton(
        "ESP Name + Distance  •  ON"
    )

NameButton.MouseButton1Click:Connect(
    function()

        local NewState =
            not Settings.ESP.Name

        Settings.ESP.Name =
            NewState

        Settings.ESP.Distance =
            NewState

        NameButton.Text =
            "ESP Name + Distance  •  " ..
            (
                NewState
                and "ON"
                or "OFF"
            )

        SetButtonState(
            NameButton,
            NameStroke,
            NewState
        )
    end
)

------------------------------------------------------------
-- ESP HEALTH
------------------------------------------------------------

local HealthButton, HealthStroke =
    CreateButton("ESP Health  •  ON")

HealthButton.MouseButton1Click:Connect(
    function()

        Settings.ESP.Health =
            not Settings.ESP.Health

        HealthButton.Text =
            "ESP Health  •  " ..
            (
                Settings.ESP.Health
                and "ON"
                or "OFF"
            )

        SetButtonState(
            HealthButton,
            HealthStroke,
            Settings.ESP.Health
        )
    end
)

------------------------------------------------------------
-- CREDIT
------------------------------------------------------------

local Credit = Instance.new("TextLabel")

Credit.Size =
    UDim2.new(1, 0, 0, 25)

Credit.BackgroundTransparency = 1

Credit.Text = "Crate by, Omar"

Credit.TextColor3 =
    Colors.Gray

Credit.TextSize = 11
Credit.Font = Enum.Font.GothamMedium

Credit.Parent = Content

------------------------------------------------------------
-- TARGET VALIDATION
------------------------------------------------------------

local function IsValidTarget(Player)

    if Player == LocalPlayer then
        return false
    end

    --------------------------------------------------------
    -- TEAM CHECK
    --------------------------------------------------------

    if Settings.TeamCheck then

        if Player.Team == LocalPlayer.Team then
            return false
        end
    end

    --------------------------------------------------------
    -- EXCLUDED TEAMS
    --------------------------------------------------------

    if Player.Team then

        if Settings.ExcludedTeams[
            Player.Team.Name
        ] then

            return false
        end
    end

    --------------------------------------------------------
    -- CHARACTER
    --------------------------------------------------------

    local Character =
        Player.Character

    if not Character then
        return false
    end

    --------------------------------------------------------
    -- HUMANOID
    --------------------------------------------------------

    local Humanoid =
        Character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not Humanoid then
        return false
    end

    if Settings.IgnoreDead
        and Humanoid.Health <= 0 then

        return false
    end

    --------------------------------------------------------
    -- TARGET PART
    --------------------------------------------------------

    if not Character:FindFirstChild(
        Settings.TargetPart
    ) then

        return false
    end

    return true
end

------------------------------------------------------------
-- FIND CLOSEST TARGET
------------------------------------------------------------

local function GetClosestTarget()

    local MousePosition =
        UserInputService:GetMouseLocation()

    local Closest = nil
    local ClosestDistance =
        Settings.FOV

    for _, Player in ipairs(
        Players:GetPlayers()
    ) do

        if IsValidTarget(Player) then

            local Character =
                Player.Character

            local Part =
                Character:FindFirstChild(
                    Settings.TargetPart
                )

            if Part then

                local ScreenPosition, Visible =
                    Camera:WorldToViewportPoint(
                        Part.Position
                    )

                if Visible
                    and ScreenPosition.Z > 0 then

                    local Distance =
                        (
                            Vector2.new(
                                ScreenPosition.X,
                                ScreenPosition.Y
                            )
                            - MousePosition
                        ).Magnitude

                    if Distance <
                        ClosestDistance then

                        ClosestDistance =
                            Distance

                        Closest = Player
                    end
                end
            end
        end
    end

    return Closest
end

------------------------------------------------------------
-- AIM
------------------------------------------------------------

local function AimAt(Player)

    if not Player then
        return
    end

    if not IsValidTarget(Player) then
        return
    end

    local Character =
        Player.Character

    local Part =
        Character:FindFirstChild(
            Settings.TargetPart
        )

    if not Part then
        return
    end

    local Desired =
        CFrame.lookAt(
            Camera.CFrame.Position,
            Part.Position
        )

    local Strength =
        Settings.Smoothness / 100

    -- Higher smoothness = stronger tracking.
    -- 100% remains interpolated rather than
    -- directly snapping the camera.

    local Alpha =
        0.025 +
        ((Strength ^ 2) * 0.93)

    Camera.CFrame =
        Camera.CFrame:Lerp(
            Desired,
            math.clamp(
                Alpha,
                0,
                0.98
            )
        )
end

------------------------------------------------------------
-- ESP CREATION
------------------------------------------------------------

local function CreateESP(Player)

    if Player == LocalPlayer then
        return
    end

    if ESPObjects[Player] then
        return
    end

    local Billboard =
        Instance.new("BillboardGui")

    Billboard.Name = "PlayerESP"

    Billboard.Size =
        UDim2.fromOffset(170, 75)

    Billboard.StudsOffset =
        Vector3.new(0, 2.8, 0)

    Billboard.AlwaysOnTop = true
    Billboard.Enabled = false

    Billboard.Parent = Gui

    --------------------------------------------------------
    -- NAME
    --------------------------------------------------------

    local Name =
        Instance.new("TextLabel")

    Name.Name = "Name"

    Name.Size =
        UDim2.new(1, 0, 0, 20)

    Name.BackgroundTransparency = 1

    Name.TextColor3 =
        Colors.White

    Name.TextStrokeTransparency = 0.2

    Name.TextSize = 14
    Name.Font = Enum.Font.GothamBold

    Name.Parent = Billboard

    --------------------------------------------------------
    -- DISTANCE
    --------------------------------------------------------

    local Distance =
        Instance.new("TextLabel")

    Distance.Name = "Distance"

    Distance.Position =
        UDim2.fromOffset(0, 20)

    Distance.Size =
        UDim2.new(1, 0, 0, 18)

    Distance.BackgroundTransparency = 1

    Distance.TextColor3 =
        Colors.Gray

    Distance.TextStrokeTransparency = 0.35

    Distance.TextSize = 11
    Distance.Font = Enum.Font.GothamMedium

    Distance.Parent = Billboard

    --------------------------------------------------------
    -- HEALTH BACKGROUND
    --------------------------------------------------------

    local HealthBackground =
        Instance.new("Frame")

    HealthBackground.Name =
        "HealthBackground"

    HealthBackground.Position =
        UDim2.fromOffset(25, 43)

    HealthBackground.Size =
        UDim2.new(1, -50, 0, 6)

    HealthBackground.BackgroundColor3 =
        Color3.fromRGB(35, 35, 40)

    HealthBackground.BorderSizePixel = 0

    HealthBackground.Parent = Billboard

    local HealthCorner =
        Instance.new("UICorner")

    HealthCorner.CornerRadius =
        UDim.new(1, 0)

    HealthCorner.Parent =
        HealthBackground

    --------------------------------------------------------
    -- HEALTH FILL
    --------------------------------------------------------

    local HealthFill =
        Instance.new("Frame")

    HealthFill.Name =
        "HealthFill"

    HealthFill.Size =
        UDim2.fromScale(1, 1)

    HealthFill.BackgroundColor3 =
        Colors.Purple

    HealthFill.BorderSizePixel = 0

    HealthFill.Parent =
        HealthBackground

    local HealthFillCorner =
        Instance.new("UICorner")

    HealthFillCorner.CornerRadius =
        UDim.new(1, 0)

    HealthFillCorner.Parent =
        HealthFill

    --------------------------------------------------------
    -- BOX
    --------------------------------------------------------

    local Box =
        Instance.new("Frame")

    Box.Name = "Box"

    Box.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Box.Position =
        UDim2.fromScale(0.5, 0.5)

    Box.Size =
        UDim2.fromOffset(70, 100)

    Box.BackgroundTransparency = 1

    Box.Parent = Billboard

    local BoxStroke =
        Instance.new("UIStroke")

    BoxStroke.Color =
        Colors.Purple

    BoxStroke.Thickness = 1.5

    BoxStroke.Parent = Box

    --------------------------------------------------------
    -- SAVE
    --------------------------------------------------------

    ESPObjects[Player] = {

        Gui = Billboard,

        Name = Name,
        Distance = Distance,

        HealthBackground =
            HealthBackground,

        HealthFill =
            HealthFill,

        Box = Box,
    }
end

------------------------------------------------------------
-- REMOVE ESP
------------------------------------------------------------

local function RemoveESP(Player)

    local Data =
        ESPObjects[Player]

    if Data then

        Data.Gui:Destroy()

        ESPObjects[Player] = nil
    end
end

------------------------------------------------------------
-- CREATE ESP FOR EXISTING PLAYERS
------------------------------------------------------------

for _, Player in ipairs(
    Players:GetPlayers()
) do

    CreateESP(Player)
end

Players.PlayerAdded:Connect(
    CreateESP
)

Players.PlayerRemoving:Connect(
    RemoveESP
)

------------------------------------------------------------
-- UPDATE ESP
------------------------------------------------------------

local function UpdateESP(
    Player,
    Data
)

    --------------------------------------------------------
    -- MASTER ESP TOGGLE
    --------------------------------------------------------

    if not Settings.ESPEnabled then

        Data.Gui.Enabled = false
        return
    end

    --------------------------------------------------------
    -- CHARACTER
    --------------------------------------------------------

    local Character =
        Player.Character

    if not Character then

        Data.Gui.Enabled = false
        return
    end

    local Head =
        Character:FindFirstChild(
            "Head"
        )

    local Root =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    local Humanoid =
        Character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not Head
        or not Root
        or not Humanoid then

        Data.Gui.Enabled = false
        return
    end

    if Settings.IgnoreDead
        and Humanoid.Health <= 0 then

        Data.Gui.Enabled = false
        return
    end

    --------------------------------------------------------
    -- ENABLE
    --------------------------------------------------------

    Data.Gui.Adornee =
        Head

    Data.Gui.Enabled = true

    --------------------------------------------------------
    -- NAME
    --------------------------------------------------------

    Data.Name.Visible =
        Settings.ESP.Name

    Data.Name.Text =
        Player.DisplayName ..
        "  [" ..
        Player.Name ..
        "]"

    --------------------------------------------------------
    -- DISTANCE
    --------------------------------------------------------

    Data.Distance.Visible =
        Settings.ESP.Distance

    local MyCharacter =
        LocalPlayer.Character

    local MyRoot =
        MyCharacter and
        MyCharacter:FindFirstChild(
            "HumanoidRootPart"
        )

    if MyRoot then

        local Distance =
            (
                Root.Position -
                MyRoot.Position
            ).Magnitude

        Data.Distance.Text =
            math.floor(
                Distance
            ) .. " studs"
    end

    --------------------------------------------------------
    -- HEALTH
    --------------------------------------------------------

    Data.HealthBackground.Visible =
        Settings.ESP.Health

    local HealthPercent =
        math.clamp(
            Humanoid.Health /
            Humanoid.MaxHealth,
            0,
            1
        )

    Data.HealthFill.Size =
        UDim2.fromScale(
            HealthPercent,
            1
        )

    --------------------------------------------------------
    -- BOX
    --------------------------------------------------------

    Data.Box.Visible =
        Settings.ESP.Box
end

------------------------------------------------------------
-- MOUSE INPUT
------------------------------------------------------------

UserInputService.InputBegan:Connect(
    function(Input, Processed)

        if Processed then
            return
        end

        if Input.UserInputType ==
            Enum.UserInputType.MouseButton2 then

            RMBDown = true
        end
    end
)

UserInputService.InputEnded:Connect(
    function(Input)

        if Input.UserInputType ==
            Enum.UserInputType.MouseButton2 then

            RMBDown = false
        end
    end
)

------------------------------------------------------------
-- DRAGGABLE WINDOW
------------------------------------------------------------

local Dragging = false
local DragStart
local StartPosition

TitleBar.InputBegan:Connect(
    function(Input)

        if Input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            Dragging = true

            DragStart =
                Input.Position

            StartPosition =
                Main.Position
        end
    end
)

UserInputService.InputChanged:Connect(
    function(Input)

        if Dragging
            and Input.UserInputType ==
                Enum.UserInputType.MouseMovement then

            local Delta =
                Input.Position -
                DragStart

            Main.Position =
                UDim2.new(

                    StartPosition.X.Scale,

                    StartPosition.X.Offset +
                        Delta.X,

                    StartPosition.Y.Scale,

                    StartPosition.Y.Offset +
                        Delta.Y
                )
        end
    end
)

UserInputService.InputEnded:Connect(
    function(Input)

        if Input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            Dragging = false
        end
    end
)

------------------------------------------------------------
-- OPEN BUTTON
------------------------------------------------------------

local Reopen =
    Instance.new("TextButton")

Reopen.Size =
    UDim2.fromOffset(75, 36)

Reopen.Position =
    UDim2.fromOffset(20, 20)

Reopen.BackgroundColor3 =
    Colors.Panel

Reopen.Text = "OPEN"

Reopen.TextColor3 =
    Colors.White

Reopen.TextSize = 12
Reopen.Font = Enum.Font.GothamBold

Reopen.Visible = false

Reopen.Parent = Gui

local ReopenCorner =
    Instance.new("UICorner")

ReopenCorner.CornerRadius =
    UDim.new(0, 8)

ReopenCorner.Parent =
    Reopen

local ReopenStroke =
    Instance.new("UIStroke")

ReopenStroke.Color =
    Colors.Purple

ReopenStroke.Thickness = 1

ReopenStroke.Parent =
    Reopen

------------------------------------------------------------
-- CLOSE / REOPEN
------------------------------------------------------------

Close.MouseButton1Click:Connect(
    function()

        Main.Visible = false
        Reopen.Visible = true
        MenuOpen = false
    end
)

Reopen.MouseButton1Click:Connect(
    function()

        Main.Visible = true
        Reopen.Visible = false
        MenuOpen = true
    end
)

------------------------------------------------------------
-- INSERT = HIDE / SHOW
------------------------------------------------------------

UserInputService.InputBegan:Connect(
    function(Input, Processed)

        if Processed then
            return
        end

        if Input.KeyCode ==
            Enum.KeyCode.Insert then

            MenuOpen =
                not MenuOpen

            Main.Visible =
                MenuOpen

            Reopen.Visible =
                not MenuOpen
        end
    end
)

------------------------------------------------------------
-- MAIN LOOP
------------------------------------------------------------

RunService.RenderStepped:Connect(
    function()

        ----------------------------------------------------
        -- AIM
        ----------------------------------------------------

        if Settings.AimEnabled then

            local ShouldAim = true

            if Settings.HoldToAim then

                ShouldAim =
                    RMBDown
            end

            if ShouldAim then

                -- Keep the current target while valid.
                -- This prevents unnecessary switching.

                if not CurrentTarget
                    or not IsValidTarget(
                        CurrentTarget
                    ) then

                    CurrentTarget =
                        GetClosestTarget()
                end

                if CurrentTarget then

                    AimAt(
                        CurrentTarget
                    )
                end

            else

                CurrentTarget = nil
            end

        else

            CurrentTarget = nil
        end

        ----------------------------------------------------
        -- ESP
        ----------------------------------------------------

        for Player, Data in pairs(
            ESPObjects
        ) do

            UpdateESP(
                Player,
                Data
            )
        end
    end
)

------------------------------------------------------------
-- DONE
------------------------------------------------------------

print(
    "Aim + ESP loaded | Crate by, Omar"
)
