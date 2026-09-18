--========================================
-- LUNAR SNAKE
-- PART 1/4
-- CORE UI / HOME / BACKGROUND / MINIMIZE
--========================================

--========================================
-- SERVICES
--========================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--========================================
-- PERSISTENT SESSION DATA
--========================================

getgenv().LunarSnakeData = getgenv().LunarSnakeData or {
    BestScore = 0,
    Score = 0,

    Snake = nil,
    Food = nil,

    Direction = "Right",
    DirectionQueue = {},

    Running = false,
    Paused = false
}

local Save = getgenv().LunarSnakeData

--========================================
-- CONFIG
--========================================

local CONFIG = {
    Width = 18,
    Height = 14,

    CellSize = 22,

    -- Comfortable snake speed
    GameSpeed = 0.20,

    Background = Color3.fromRGB(8, 7, 15),
    Panel = Color3.fromRGB(15, 13, 25),
    Panel2 = Color3.fromRGB(21, 18, 34),

    Purple = Color3.fromRGB(145, 85, 255),
    PurpleDark = Color3.fromRGB(78, 43, 140),

    Text = Color3.fromRGB(240, 236, 255),
    Muted = Color3.fromRGB(155, 148, 180),

    Snake = Color3.fromRGB(158, 91, 250),
    SnakeHead = Color3.fromRGB(204, 163, 255),

    Food = Color3.fromRGB(255, 92, 168)
}

--========================================
-- HELPERS
--========================================

local function New(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent

    return object
end

local function Corner(parent, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius or 10)
    }, parent)
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color or CONFIG.Purple,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, parent)
end

local function Tween(object, time, properties, style, direction)
    if not object or not object.Parent then
        return
    end

    local info = TweenInfo.new(
        time,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(
        object,
        info,
        properties
    )

    tween:Play()

    return tween
end

local function Label(
    parent,
    text,
    size,
    position,
    font,
    textSize
)
    return New("TextLabel", {
        BackgroundTransparency = 1,

        Text = text,

        Size = size,
        Position = position,

        Font = font or Enum.Font.Gotham,
        TextSize = textSize or 14,

        TextColor3 = CONFIG.Text,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        BorderSizePixel = 0
    }, parent)
end

--========================================
-- REMOVE PREVIOUS GUI
--========================================

local PreviousGui = CoreGui:FindFirstChild("LunarSnake")

if PreviousGui then
    PreviousGui:Destroy()
end

--========================================
-- SCREEN GUI
--========================================

local Gui = New("ScreenGui", {
    Name = "LunarSnake",

    ResetOnSpawn = false,
    IgnoreGuiInset = true,

    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, CoreGui)

--========================================
-- MAIN HOLDER
--========================================

local Holder = New("Frame", {
    Name = "Holder",

    Size = UDim2.fromOffset(570, 470),

    Position = UDim2.new(
        0.5,
        -285,
        0.5,
        -235
    ),

    BackgroundColor3 = CONFIG.Background,

    BorderSizePixel = 0,

    ClipsDescendants = true,

    Active = true,

    ZIndex = 10
}, Gui)

Corner(Holder, 18)
Stroke(
    Holder,
    CONFIG.PurpleDark,
    1,
    0.2
)

--========================================
-- BACKGROUND CLIP
--========================================

local BackgroundClip = New("Frame", {
    Name = "BackgroundClip",

    Size = UDim2.fromScale(1, 1),

    Position = UDim2.fromScale(0, 0),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ClipsDescendants = true,

    ZIndex = 11
}, Holder)

Corner(BackgroundClip, 18)

--========================================
-- BACKGROUND GLOW
--========================================

local Glow = New("Frame", {
    Name = "Glow",

    Size = UDim2.fromOffset(260, 260),

    Position = UDim2.new(
        0.5,
        -130,
        0.5,
        -130
    ),

    BackgroundColor3 = CONFIG.PurpleDark,

    BackgroundTransparency = 0.94,

    BorderSizePixel = 0,

    ZIndex = 11
}, BackgroundClip)

Corner(Glow, 130)

--========================================
-- ANIMATED BACKGROUND LINES
--========================================

local BackgroundLines = {}

for i = 1, 8 do

    local line = New("Frame", {
        Name = "BackgroundLine_" .. i,

        Size = UDim2.fromOffset(
            2,
            720
        ),

        Position = UDim2.new(
            -0.5 + i * 0.18,
            0,
            -0.55,
            0
        ),

        Rotation = 25,

        BackgroundColor3 = CONFIG.Purple,

        BackgroundTransparency = 0.955,

        BorderSizePixel = 0,

        ZIndex = 12
    }, BackgroundClip)

    table.insert(
        BackgroundLines,
        line
    )

    task.spawn(function()

        local baseX =
            -0.5 + i * 0.18

        while line.Parent do

            line.Position = UDim2.new(
                baseX,
                0,
                -0.55,
                0
            )

            local target =
                UDim2.new(
                    baseX + 0.45,
                    0,
                    -0.55,
                    0
                )

            local tween = Tween(
                line,
                5.5 + i * 0.25,
                {
                    Position = target
                },
                Enum.EasingStyle.Linear
            )

            if tween then
                tween.Completed:Wait()
            else
                break
            end
        end
    end)
end

--========================================
-- TOP BAR
--========================================

local TopBar = New("Frame", {
    Name = "TopBar",

    Size = UDim2.new(
        1,
        -28,
        0,
        64
    ),

    Position = UDim2.fromOffset(
        14,
        10
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ZIndex = 30
}, Holder)

--========================================
-- LOGO HOLDER
--========================================

local LogoHolder = New("Frame", {
    Name = "LogoHolder",

    Size = UDim2.fromOffset(
        42,
        42
    ),

    Position = UDim2.fromOffset(
        0,
        8
    ),

    BackgroundColor3 = CONFIG.Panel2,

    BorderSizePixel = 0,

    ZIndex = 31
}, TopBar)

Corner(LogoHolder, 12)

Stroke(
    LogoHolder,
    CONFIG.PurpleDark,
    1,
    0.35
)

--========================================
-- LUNAR LOGO
--========================================

local Moon = New("Frame", {
    Name = "Moon",

    Size = UDim2.fromOffset(
        24,
        24
    ),

    Position = UDim2.new(
        0.5,
        -12,
        0.5,
        -12
    ),

    BackgroundColor3 =
        Color3.fromRGB(
            191,
            157,
            255
        ),

    BorderSizePixel = 0,

    ZIndex = 32
}, LogoHolder)

Corner(Moon, 50)

local MoonCut = New("Frame", {
    Name = "MoonCut",

    Size = UDim2.fromOffset(
        22,
        22
    ),

    Position = UDim2.fromOffset(
        8,
        -3
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    BorderSizePixel = 0,

    ZIndex = 33
}, Moon)

Corner(MoonCut, 50)

--========================================
-- TITLE
--========================================

local Title = Label(
    TopBar,

    "LUNAR SNAKE",

    UDim2.fromOffset(
        260,
        28
    ),

    UDim2.fromOffset(
        54,
        7
    ),

    Enum.Font.GothamBold,

    18
)

Title.ZIndex = 31

local Subtitle = Label(
    TopBar,

    "CLASSIC SNAKE GAME",

    UDim2.fromOffset(
        260,
        20
    ),

    UDim2.fromOffset(
        54,
        32
    ),

    Enum.Font.Gotham,

    10
)

Subtitle.TextColor3 =
    CONFIG.Muted

Subtitle.ZIndex = 31

--========================================
-- MINIMIZE BUTTON
--========================================

local MinimizeButton = New("TextButton", {
    Name = "MinimizeButton",

    Size = UDim2.fromOffset(
        34,
        34
    ),

    Position = UDim2.new(
        1,
        -76,
        0,
        12
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    Text = "—",

    TextColor3 =
        CONFIG.Text,

    TextSize = 18,

    Font =
        Enum.Font.GothamBold,

    AutoButtonColor = false,

    BorderSizePixel = 0,

    ZIndex = 40
}, TopBar)

Corner(
    MinimizeButton,
    10
)

--========================================
-- CLOSE BUTTON
--========================================

local CloseButton = New("TextButton", {
    Name = "CloseButton",

    Size = UDim2.fromOffset(
        34,
        34
    ),

    Position = UDim2.new(
        1,
        -36,
        0,
        12
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    Text = "×",

    TextColor3 =
        CONFIG.Text,

    TextSize = 20,

    Font =
        Enum.Font.GothamBold,

    AutoButtonColor = false,

    BorderSizePixel = 0,

    ZIndex = 40
}, TopBar)

Corner(
    CloseButton,
    10
)

--========================================
-- CONTENT CLIP
--========================================

local Content = New("Frame", {
    Name = "Content",

    Size = UDim2.new(
        1,
        -28,
        1,
        -86
    ),

    Position = UDim2.fromOffset(
        14,
        76
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ClipsDescendants = true,

    ZIndex = 20
}, Holder)

Corner(Content, 12)

--========================================
-- HOME PAGE
--========================================

local Home = New("Frame", {
    Name = "Home",

    Size = UDim2.fromScale(
        1,
        1
    ),

    Position = UDim2.fromScale(
        0,
        0
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ZIndex = 21
}, Content)

--========================================
-- MAIN GAME CARD
--========================================

local GameCard = New("Frame", {
    Name = "GameCard",

    Size = UDim2.new(
        1,
        -20,
        0,
        215
    ),

    Position = UDim2.fromOffset(
        10,
        8
    ),

    BackgroundColor3 =
        CONFIG.Panel,

    BorderSizePixel = 0,

    ZIndex = 22
}, Home)

Corner(
    GameCard,
    16
)

Stroke(
    GameCard,
    CONFIG.PurpleDark,
    1,
    0.45
)

--========================================
-- SNAKE PREVIEW
--========================================

local SnakePreview = New("Frame", {
    Name = "SnakePreview",

    Size = UDim2.fromOffset(
        74,
        74
    ),

    Position = UDim2.fromOffset(
        24,
        24
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    BorderSizePixel = 0,

    ZIndex = 23
}, GameCard)

Corner(
    SnakePreview,
    18
)

--========================================
-- PREVIEW SNAKE
--========================================

local PreviewPositions = {
    {18, 30},
    {31, 30},
    {44, 30}
}

for i, position in ipairs(
    PreviewPositions
) do

    local segment = New("Frame", {
        Size = UDim2.fromOffset(
            15,
            15
        ),

        Position = UDim2.fromOffset(
            position[1],
            position[2]
        ),

        BackgroundColor3 =
            i == 3
            and CONFIG.SnakeHead
            or CONFIG.Snake,

        BorderSizePixel = 0,

        ZIndex = 24
    }, SnakePreview)

    Corner(
        segment,
        50
    )
end

--========================================
-- GAME CARD TEXT
--========================================

local CardTitle = Label(
    GameCard,

    "Lunar Snake",

    UDim2.fromOffset(
        280,
        32
    ),

    UDim2.fromOffset(
        120,
        25
    ),

    Enum.Font.GothamBold,

    22
)

CardTitle.ZIndex = 24

local CardDescription = Label(
    GameCard,

    "Classic snake with a Lunar style.",

    UDim2.fromOffset(
        330,
        24
    ),

    UDim2.fromOffset(
        120,
        59
    ),

    Enum.Font.Gotham,

    12
)

CardDescription.TextColor3 =
    CONFIG.Muted

CardDescription.ZIndex = 24

--========================================
-- PLAY BUTTON
--========================================

local PlayButton = New("TextButton", {
    Name = "PlayButton",

    Size = UDim2.fromOffset(
        170,
        44
    ),

    Position = UDim2.fromOffset(
        120,
        105
    ),

    BackgroundColor3 =
        CONFIG.PurpleDark,

    Text = "PLAY",

    TextColor3 =
        CONFIG.Text,

    TextSize = 13,

    Font =
        Enum.Font.GothamBold,

    AutoButtonColor = false,

    BorderSizePixel = 0,

    ZIndex = 30
}, GameCard)

Corner(
    PlayButton,
    12
)

--========================================
-- INFO CARDS
--========================================

local BestCard = New("Frame", {
    Name = "BestCard",

    Size = UDim2.new(
        0.48,
        -5,
        0,
        90
    ),

    Position = UDim2.fromOffset(
        10,
        235
    ),

    BackgroundColor3 =
        CONFIG.Panel,

    BorderSizePixel = 0,

    ZIndex = 22
}, Home)

Corner(
    BestCard,
    14
)

Stroke(
    BestCard,
    CONFIG.PurpleDark,
    1,
    0.55
)

local BestCaption = Label(
    BestCard,

    "BEST SCORE",

    UDim2.new(
        1,
        -20,
        0,
        24
    ),

    UDim2.fromOffset(
        10,
        8
    ),

    Enum.Font.Gotham,

    10
)

BestCaption.TextColor3 =
    CONFIG.Muted

local BestLabel = Label(
    BestCard,

    tostring(
        Save.BestScore or 0
    ),

    UDim2.new(
        1,
        -20,
        0,
        40
    ),

    UDim2.fromOffset(
        10,
        30
    ),

    Enum.Font.GothamBold,

    24
)

--========================================
-- MODE CARD
--========================================

local ModeCard = New("Frame", {
    Name = "ModeCard",

    Size = UDim2.new(
        0.48,
        -5,
        0,
        90
    ),

    Position = UDim2.new(
        0.52,
        0,
        0,
        235
    ),

    BackgroundColor3 =
        CONFIG.Panel,

    BorderSizePixel = 0,

    ZIndex = 22
}, Home)

Corner(
    ModeCard,
    14
)

Stroke(
    ModeCard,
    CONFIG.PurpleDark,
    1,
    0.55
)

local ModeCaption = Label(
    ModeCard,

    "MODE",

    UDim2.new(
        1,
        -20,
        0,
        24
    ),

    UDim2.fromOffset(
        10,
        8
    ),

    Enum.Font.Gotham,

    10
)

ModeCaption.TextColor3 =
    CONFIG.Muted

Label(
    ModeCard,

    "CLASSIC",

    UDim2.new(
        1,
        -20,
        0,
        40
    ),

    UDim2.fromOffset(
        10,
        30
    ),

    Enum.Font.GothamBold,

    18
)

--========================================
-- MINIMIZED BAR
--========================================

local MiniBar = New("TextButton", {
    Name = "MiniBar",

    Size = UDim2.fromOffset(
        190,
        48
    ),

    Position = UDim2.new(
        0.5,
        -95,
        0.5,
        -24
    ),

    BackgroundColor3 =
        CONFIG.Panel,

    Text = "",

    AutoButtonColor = false,

    BorderSizePixel = 0,

    Visible = false,

    Active = true,

    ZIndex = 100
}, Gui)

Corner(
    MiniBar,
    14
)

Stroke(
    MiniBar,
    CONFIG.PurpleDark,
    1,
    0.25
)

--========================================
-- MINI LOGO
--========================================

local MiniLogo = New("Frame", {
    Name = "MiniLogo",

    Size = UDim2.fromOffset(
        30,
        30
    ),

    Position = UDim2.fromOffset(
        9,
        9
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    BorderSizePixel = 0,

    ZIndex = 101
}, MiniBar)

Corner(
    MiniLogo,
    10
)

local MiniMoon = New("Frame", {
    Name = "MiniMoon",

    Size = UDim2.fromOffset(
        16,
        16
    ),

    Position = UDim2.new(
        0.5,
        -8,
        0.5,
        -8
    ),

    BackgroundColor3 =
        Color3.fromRGB(
            191,
            157,
            255
        ),

    BorderSizePixel = 0,

    ZIndex = 102
}, MiniLogo)

Corner(
    MiniMoon,
    50
)

local MiniMoonCut = New("Frame", {
    Size = UDim2.fromOffset(
        15,
        15
    ),

    Position = UDim2.fromOffset(
        6,
        -2
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    BorderSizePixel = 0,

    ZIndex = 103
}, MiniMoon)

Corner(
    MiniMoonCut,
    50
)

--========================================
-- MINI TITLE
--========================================

local MiniTitle = Label(
    MiniBar,

    "LUNAR SNAKE",

    UDim2.fromOffset(
        115,
        30
    ),

    UDim2.fromOffset(
        49,
        9
    ),

    Enum.Font.GothamBold,

    13
)

MiniTitle.ZIndex = 102

--========================================
-- BUTTON HOVER
--========================================

local function ButtonHover(
    button,
    normalColor,
    hoverColor
)
    local normalSize = button.Size

    button.MouseEnter:Connect(function()

        Tween(
            button,
            0.12,
            {
                BackgroundColor3 =
                    hoverColor,

                Size = UDim2.fromOffset(
                    normalSize.X.Offset + 2,
                    normalSize.Y.Offset + 2
                )
            }
        )
    end)

    button.MouseLeave:Connect(function()

        Tween(
            button,
            0.12,
            {
                BackgroundColor3 =
                    normalColor,

                Size = normalSize
            }
        )
    end)
end

ButtonHover(
    PlayButton,
    CONFIG.PurpleDark,
    CONFIG.Purple
)

ButtonHover(
    MinimizeButton,
    CONFIG.Panel2,
    CONFIG.PurpleDark
)

ButtonHover(
    CloseButton,
    CONFIG.Panel2,
    Color3.fromRGB(105, 43, 75)
)

--========================================
-- PAGE STATE
--========================================

local CurrentPage = "Home"
local Minimized = false

--========================================
-- SHOW HOME
--========================================

local function ShowHome()
    CurrentPage = "Home"

    Home.Visible = true

    Home.Position =
        UDim2.fromOffset(
            -14,
            0
        )

    Tween(
        Home,
        0.22,
        {
            Position =
                UDim2.fromOffset(
                    0,
                    0
                )
        }
    )
end

--========================================
-- SHOW GAME
--========================================

local function ShowGame()
    CurrentPage = "Game"

    Home.Visible = false
end

--========================================
-- PLAY BUTTON
--========================================

PlayButton.MouseButton1Click:Connect(function()
    ShowGame()
end)

--========================================
-- MINIMIZED BAR
--========================================

local MiniBar = New("TextButton", {
    Name = "MiniBar",

    Size = UDim2.fromOffset(
        190,
        48
    ),

    Position = UDim2.new(
        0.5,
        -95,
        0.5,
        -24
    ),

    BackgroundColor3 =
        CONFIG.Panel,

    Text = "",

    AutoButtonColor = false,

    BorderSizePixel = 0,

    Visible = false,

    Active = true,

    ZIndex = 100
}, Gui)

Corner(
    MiniBar,
    14
)

Stroke(
    MiniBar,
    CONFIG.PurpleDark,
    1,
    0.25
)

--========================================
-- MINI LOGO
--========================================

local MiniLogo = New("Frame", {
    Name = "MiniLogo",

    Size = UDim2.fromOffset(
        30,
        30
    ),

    Position = UDim2.fromOffset(
        9,
        9
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    BorderSizePixel = 0,

    ZIndex = 101
}, MiniBar)

Corner(
    MiniLogo,
    10
)

local MiniMoon = New("Frame", {
    Name = "MiniMoon",

    Size = UDim2.fromOffset(
        16,
        16
    ),

    Position = UDim2.new(
        0.5,
        -8,
        0.5,
        -8
    ),

    BackgroundColor3 =
        Color3.fromRGB(
            191,
            157,
            255
        ),

    BorderSizePixel = 0,

    ZIndex = 102
}, MiniLogo)

Corner(
    MiniMoon,
    50
)

local MiniMoonCut = New("Frame", {
    Size = UDim2.fromOffset(
        15,
        15
    ),

    Position = UDim2.fromOffset(
        6,
        -2
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    BorderSizePixel = 0,

    ZIndex = 103
}, MiniMoon)

Corner(
    MiniMoonCut,
    50
)

--========================================
-- MINI TITLE
--========================================

local MiniTitle = Label(
    MiniBar,

    "LUNAR SNAKE",

    UDim2.fromOffset(
        115,
        30
    ),

    UDim2.fromOffset(
        49,
        9
    ),

    Enum.Font.GothamBold,

    13
)

MiniTitle.ZIndex = 102

--========================================
-- BUTTON HOVER
--========================================

local function ButtonHover(
    button,
    normalColor,
    hoverColor
)
    local normalSize = button.Size

    button.MouseEnter:Connect(function()

        Tween(
            button,
            0.12,
            {
                BackgroundColor3 =
                    hoverColor,

                Size = UDim2.fromOffset(
                    normalSize.X.Offset + 2,
                    normalSize.Y.Offset + 2
                )
            }
        )
    end)

    button.MouseLeave:Connect(function()

        Tween(
            button,
            0.12,
            {
                BackgroundColor3 =
                    normalColor,

                Size = normalSize
            }
        )
    end)
end

ButtonHover(
    PlayButton,
    CONFIG.PurpleDark,
    CONFIG.Purple
)

ButtonHover(
    MinimizeButton,
    CONFIG.Panel2,
    CONFIG.PurpleDark
)

ButtonHover(
    CloseButton,
    CONFIG.Panel2,
    Color3.fromRGB(105, 43, 75)
)

--========================================
-- PAGE STATE
--========================================

local CurrentPage = "Home"
local Minimized = false

--========================================
-- SHOW HOME
--========================================

local function ShowHome()
    CurrentPage = "Home"

    Home.Visible = true

    Home.Position =
        UDim2.fromOffset(
            -14,
            0
        )

    Tween(
        Home,
        0.22,
        {
            Position =
                UDim2.fromOffset(
                    0,
                    0
                )
        }
    )
end

--========================================
-- SHOW GAME
--========================================

local function ShowGame()
    CurrentPage = "Game"

    Home.Visible = false
end

--========================================
-- PLAY BUTTON
--========================================

PlayButton.MouseButton1Click:Connect(function()
    ShowGame()
end)

--========================================
-- MINIMIZE
--========================================

local function MinimizeMenu()

    if Minimized then
        return
    end

    Minimized = true

    MiniBar.Visible = true

    MiniBar.Size =
        UDim2.fromOffset(
            165,
            42
        )

    Tween(
        Holder,
        0.22,
        {
            Size =
                UDim2.fromOffset(
                    500,
                    410
                ),

            BackgroundTransparency = 0.15
        },
        Enum.EasingStyle.Quad
    ).Completed:Connect(function()

        if not Holder.Parent then
            return
        end

        Holder.Visible = false

        Tween(
            MiniBar,
            0.25,
            {
                Size =
                    UDim2.fromOffset(
                        190,
                        48
                    )
            },
            Enum.EasingStyle.Back
        )
    end)
end

--========================================
-- RESTORE
--========================================

local function RestoreMenu()

    if not Minimized then
        return
    end

    Minimized = false

    MiniBar.Visible = false

    Holder.Visible = true

    Holder.Size =
        UDim2.fromOffset(
            500,
            410
        )

    Holder.BackgroundTransparency =
        0.15

    Tween(
        Holder,
        0.3,
        {
            Size =
                UDim2.fromOffset(
                    570,
                    470
                ),

            BackgroundTransparency = 0
        },
        Enum.EasingStyle.Back
    )
end

MinimizeButton.MouseButton1Click:Connect(
    MinimizeMenu
)

MiniBar.MouseButton1Click:Connect(
    RestoreMenu
)

--========================================
-- CLOSE
--========================================

local Closing = false

CloseButton.MouseButton1Click:Connect(function()

    if Closing then
        return
    end

    Closing = true

    Tween(
        Holder,
        0.25,
        {
            Size =
                UDim2.fromOffset(
                    520,
                    430
                ),

            BackgroundTransparency = 1
        },
        Enum.EasingStyle.Quad
    ).Completed:Connect(function()

        if Gui.Parent then
            Gui:Destroy()
        end
    end)
end)

--========================================
-- INITIAL ANIMATION
--========================================

Holder.Size =
    UDim2.fromOffset(
        520,
        430
    )

Holder.BackgroundTransparency = 1

Tween(
    Holder,
    0.4,
    {
        Size =
            UDim2.fromOffset(
                570,
                470
            ),

        BackgroundTransparency = 0
    },
    Enum.EasingStyle.Back
)

--========================================
-- INITIAL STATE
--========================================

Home.Visible = true

--========================================
-- END PART 1/4
--========================================

--========================================
-- LUNAR SNAKE
-- PART 2/4
-- GAME BOARD / SNAKE / FOOD / CONTROLS
--========================================

--========================================
-- GAME STATE
--========================================

local GamePage = New("Frame", {
    Name = "GamePage",

    Size = UDim2.fromScale(1, 1),

    Position = UDim2.fromScale(0, 0),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    Visible = false,

    ZIndex = 21
}, Content)

local GameRunning = false
local GamePaused = false

local CurrentScore = Save.Score or 0
local LocalBestScore = Save.BestScore or 0

local CurrentDirection = Save.Direction or "Right"
local DirectionQueue = {}

local MoveTimer = 0

--========================================
-- BOARD
--========================================

local BoardWidth =
    CONFIG.Width * CONFIG.CellSize

local BoardHeight =
    CONFIG.Height * CONFIG.CellSize

local Board = New("Frame", {
    Name = "Board",

    Size = UDim2.fromOffset(
        BoardWidth,
        BoardHeight
    ),

    Position = UDim2.fromOffset(
        8,
        8
    ),

    BackgroundColor3 =
        Color3.fromRGB(
            10,
            9,
            18
        ),

    BorderSizePixel = 0,

    ClipsDescendants = true,

    ZIndex = 25
}, GamePage)

Corner(Board, 14)

Stroke(
    Board,
    CONFIG.PurpleDark,
    1,
    0.25
)

--========================================
-- GRID
--========================================

for x = 0, CONFIG.Width do

    local line = New("Frame", {
        Size = UDim2.new(
            0,
            1,
            1,
            0
        ),

        Position = UDim2.fromOffset(
            x * CONFIG.CellSize,
            0
        ),

        BackgroundColor3 =
            CONFIG.Purple,

        BackgroundTransparency = 0.94,

        BorderSizePixel = 0,

        ZIndex = 26
    }, Board)
end

for y = 0, CONFIG.Height do

    local line = New("Frame", {
        Size = UDim2.new(
            1,
            0,
            0,
            1
        ),

        Position = UDim2.fromOffset(
            0,
            y * CONFIG.CellSize
        ),

        BackgroundColor3 =
            CONFIG.Purple,

        BackgroundTransparency = 0.94,

        BorderSizePixel = 0,

        ZIndex = 26
    }, Board)
end

--========================================
-- SNAKE CONTAINER
--========================================

local SnakeContainer = New("Frame", {
    Name = "SnakeContainer",

    Size = UDim2.fromScale(
        1,
        1
    ),

    Position = UDim2.fromScale(
        0,
        0
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ClipsDescendants = true,

    ZIndex = 30
}, Board)

--========================================
-- FOOD OBJECT
--========================================

local FoodObject = New("Frame", {
    Name = "Food",

    Size = UDim2.fromOffset(
        CONFIG.CellSize - 6,
        CONFIG.CellSize - 6
    ),

    BackgroundColor3 =
        CONFIG.Food,

    BorderSizePixel = 0,

    ZIndex = 32
}, SnakeContainer)

Corner(
    FoodObject,
    50
)

--========================================
-- RESTORE SNAKE
--========================================

local Snake = {}

if type(Save.Snake) == "table"
and #Save.Snake > 0 then

    for i, segment in ipairs(
        Save.Snake
    ) do

        if type(segment) == "table"
        and segment.X
        and segment.Y then

            table.insert(
                Snake,
                {
                    X = segment.X,
                    Y = segment.Y
                }
            )
        end
    end
end

if #Snake == 0 then

    Snake = {
        {
            X = 9,
            Y = 7
        },

        {
            X = 8,
            Y = 7
        },

        {
            X = 7,
            Y = 7
        }
    }
end

--========================================
-- RESTORE FOOD
--========================================

local Food = {
    X = 14,
    Y = 7
}

if type(Save.Food) == "table"
and Save.Food.X
and Save.Food.Y then

    Food.X = Save.Food.X
    Food.Y = Save.Food.Y
end

--========================================
-- DRAW SNAKE
--========================================

local function ClearSnake()

    for _, child in ipairs(
        SnakeContainer:GetChildren()
    ) do

        if child.Name == "SnakeSegment" then
            child:Destroy()
        end
    end
end

local function DrawSnake()

    ClearSnake()

    for i, segment in ipairs(Snake) do

        local size =
            CONFIG.CellSize - 4

        local object = New("Frame", {
            Name = "SnakeSegment",

            Size = UDim2.fromOffset(
                size,
                size
            ),

            Position = UDim2.fromOffset(
                segment.X *
                    CONFIG.CellSize + 2,

                segment.Y *
                    CONFIG.CellSize + 2
            ),

            BackgroundColor3 =
                i == 1
                and CONFIG.SnakeHead
                or CONFIG.Snake,

            BorderSizePixel = 0,

            ZIndex = 31
        }, SnakeContainer)

        Corner(
            object,
            7
        )
    end
end

--========================================
-- DRAW FOOD
--========================================

local function DrawFood()

    FoodObject.Position =
        UDim2.fromOffset(
            Food.X *
                CONFIG.CellSize + 3,

            Food.Y *
                CONFIG.CellSize + 3
        )
end

--========================================
-- GAME HEADER
--========================================

local ScorePanel = New("Frame", {
    Name = "ScorePanel",

    Size = UDim2.fromOffset(
        128,
        68
    ),

    Position = UDim2.fromOffset(
        414,
        8
    ),

    BackgroundColor3 =
        CONFIG.Panel,

    BorderSizePixel = 0,

    ZIndex = 35
}, GamePage)

Corner(
    ScorePanel,
    13
)

Stroke(
    ScorePanel,
    CONFIG.PurpleDark,
    1,
    0.45
)

local ScoreCaption = Label(
    ScorePanel,

    "SCORE",

    UDim2.fromOffset(
        108,
        18
    ),

    UDim2.fromOffset(
        10,
        6
    ),

    Enum.Font.Gotham,

    9
)

ScoreCaption.TextColor3 =
    CONFIG.Muted

local ScoreLabel = Label(
    ScorePanel,

    tostring(CurrentScore),

    UDim2.fromOffset(
        108,
        34
    ),

    UDim2.fromOffset(
        10,
        23
    ),

    Enum.Font.GothamBold,

    20
)

--========================================
-- STATUS LABEL
--========================================

local StatusLabel = Label(
    GamePage,

    "READY",

    UDim2.fromOffset(
        128,
        22
    ),

    UDim2.fromOffset(
        414,
        82
    ),

    Enum.Font.GothamBold,

    10
)

StatusLabel.TextColor3 =
    CONFIG.Muted

StatusLabel.TextXAlignment =
    Enum.TextXAlignment.Center

--========================================
-- MENU BUTTON
--========================================

local MenuButton = New("TextButton", {
    Name = "MenuButton",

    Size = UDim2.fromOffset(
        128,
        40
    ),

    Position = UDim2.fromOffset(
        414,
        112
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    Text = "MENU",

    TextColor3 =
        CONFIG.Text,

    TextSize = 11,

    Font =
        Enum.Font.GothamBold,

    AutoButtonColor = false,

    BorderSizePixel = 0,

    ZIndex = 36
}, GamePage)

Corner(
    MenuButton,
    11
)

--========================================
-- PAUSE BUTTON
--========================================

local PauseButton = New("TextButton", {
    Name = "PauseButton",

    Size = UDim2.fromOffset(
        128,
        40
    ),

    Position = UDim2.fromOffset(
        414,
        160
    ),

    BackgroundColor3 =
        CONFIG.PurpleDark,

    Text = "PAUSE",

    TextColor3 =
        CONFIG.Text,

    TextSize = 11,

    Font =
        Enum.Font.GothamBold,

    AutoButtonColor = false,

    BorderSizePixel = 0,

    ZIndex = 36
}, GamePage)

Corner(
    PauseButton,
    11
)

--========================================
-- CONTROLS PANEL
--========================================

local ControlPanel = New("Frame", {
    Name = "ControlPanel",

    Size = UDim2.fromOffset(
        128,
        170
    ),

    Position = UDim2.fromOffset(
        414,
        208
    ),

    BackgroundColor3 =
        CONFIG.Panel,

    BorderSizePixel = 0,

    ZIndex = 35
}, GamePage)

Corner(
    ControlPanel,
    13
)

Stroke(
    ControlPanel,
    CONFIG.PurpleDark,
    1,
    0.5
)

--========================================
-- CONTROL LABEL
--========================================

local ControlTitle = Label(
    ControlPanel,

    "CONTROLS",

    UDim2.fromOffset(
        108,
        20
    ),

    UDim2.fromOffset(
        10,
        7
    ),

    Enum.Font.GothamBold,

    9
)

ControlTitle.TextColor3 =
    CONFIG.Muted

ControlTitle.TextXAlignment =
    Enum.TextXAlignment.Center

--========================================
-- CONTROL BUTTON CREATOR
--========================================

local function CreateControlButton(
    name,
    text,
    position
)

    local button = New("TextButton", {
        Name = name,

        Size = UDim2.fromOffset(
            36,
            32
        ),

        Position = position,

        BackgroundColor3 =
            CONFIG.Panel2,

        Text = text,

        TextColor3 =
            CONFIG.Text,

        TextSize = 14,

        Font =
            Enum.Font.GothamBold,

        AutoButtonColor = false,

        BorderSizePixel = 0,

        ZIndex = 40
    }, ControlPanel)

    Corner(
        button,
        9
    )

    Stroke(
        button,
        CONFIG.PurpleDark,
        1,
        0.55
    )

    button.MouseEnter:Connect(function()

        Tween(
            button,
            0.1,
            {
                BackgroundColor3 =
                    CONFIG.PurpleDark
            }
        )
    end)

    button.MouseLeave:Connect(function()

        Tween(
            button,
            0.1,
            {
                BackgroundColor3 =
                    CONFIG.Panel2
            }
        )
    end)

    return button
end

--========================================
-- DIRECTION BUTTONS
--========================================

local UpButton =
    CreateControlButton(
        "UpButton",
        "▲",
        UDim2.fromOffset(
            46,
            32
        )
    )

local LeftButton =
    CreateControlButton(
        "LeftButton",
        "◀",
        UDim2.fromOffset(
            8,
            68
        )
    )

local RightButton =
    CreateControlButton(
        "RightButton",
        "▶",
        UDim2.fromOffset(
            84,
            68
        )
    )

local DownButton =
    CreateControlButton(
        "DownButton",
        "▼",
        UDim2.fromOffset(
            46,
            104
        )
    )

--========================================
-- KEYBOARD HINT
--========================================

local KeyboardHint = Label(
    ControlPanel,

    "WASD / ARROWS",

    UDim2.fromOffset(
        118,
        20
    ),

    UDim2.fromOffset(
        5,
        143
    ),

    Enum.Font.Gotham,

    8
)

KeyboardHint.TextColor3 =
    CONFIG.Muted

KeyboardHint.TextXAlignment =
    Enum.TextXAlignment.Center

--========================================
-- DIRECTION DATA
--========================================

local DirectionVector = {
    Up = {
        X = 0,
        Y = -1
    },

    Down = {
        X = 0,
        Y = 1
    },

    Left = {
        X = -1,
        Y = 0
    },

    Right = {
        X = 1,
        Y = 0
    }
}

local OppositeDirection = {
    Up = "Down",
    Down = "Up",
    Left = "Right",
    Right = "Left"
}

--========================================
-- INPUT QUEUE
--========================================

local function SetDirection(newDirection)

    if not GameRunning then
        return
    end

    if GamePaused then
        return
    end

    if not DirectionVector[newDirection] then
        return
    end

    local referenceDirection =
        DirectionQueue[
            #DirectionQueue
        ]
        or CurrentDirection

    if newDirection ==
        referenceDirection then
        return
    end

    if OppositeDirection[
        referenceDirection
    ] == newDirection then
        return
    end

    if #DirectionQueue >= 2 then
        return
    end

    table.insert(
        DirectionQueue,
        newDirection
    )
end

--========================================
-- CONTROL BUTTON EVENTS
--========================================

UpButton.MouseButton1Click:Connect(
    function()
        SetDirection("Up")
    end
)

DownButton.MouseButton1Click:Connect(
    function()
        SetDirection("Down")
    end
)

LeftButton.MouseButton1Click:Connect(
    function()
        SetDirection("Left")
    end
)

RightButton.MouseButton1Click:Connect(
    function()
        SetDirection("Right")
    end
)

--========================================
-- UPDATE SCORE
--========================================

local function UpdateScore()

    ScoreLabel.Text =
        tostring(CurrentScore)

    if CurrentScore >
        LocalBestScore then

        LocalBestScore =
            CurrentScore

        Save.BestScore =
            LocalBestScore
    end

    BestLabel.Text =
        tostring(LocalBestScore)
end

--========================================
-- SAVE GAME
--========================================

local function SaveGame()

    Save.Score =
        CurrentScore

    Save.BestScore =
        LocalBestScore

    Save.Direction =
        CurrentDirection

    Save.Running =
        GameRunning

    Save.Paused =
        GamePaused

    Save.Snake = {}

    for i, segment in ipairs(
        Snake
    ) do

        Save.Snake[i] = {
            X = segment.X,
            Y = segment.Y
        }
    end

    Save.Food = {
        X = Food.X,
        Y = Food.Y
    }

    Save.DirectionQueue = {}

    for i, direction in ipairs(
        DirectionQueue
    ) do

        Save.DirectionQueue[i] =
            direction
    end
end

--========================================
-- END PART 2/4
--========================================

--========================================
-- LUNAR SNAKE
-- PART 3/4
-- GAMEPLAY / PAUSE / GAME OVER / GAME LOOP
--========================================

--========================================
-- GAME OVER PANEL
--========================================

local GameOverPanel = New("Frame", {
    Name = "GameOverPanel",

    Size = UDim2.fromOffset(
        300,
        230
    ),

    Position = UDim2.new(
        0.5,
        -150,
        0.5,
        -115
    ),

    BackgroundColor3 =
        CONFIG.Panel,

    BorderSizePixel = 0,

    Visible = false,

    ZIndex = 80
}, GamePage)

Corner(
    GameOverPanel,
    18
)

Stroke(
    GameOverPanel,
    CONFIG.Purple,
    1,
    0.25
)

--========================================
-- GAME OVER TITLE
--========================================

local GameOverTitle = Label(
    GameOverPanel,

    "GAME OVER",

    UDim2.new(
        1,
        -30,
        0,
        38
    ),

    UDim2.fromOffset(
        15,
        20
    ),

    Enum.Font.GothamBold,

    24
)

GameOverTitle.TextXAlignment =
    Enum.TextXAlignment.Center

--========================================
-- FINAL SCORE
--========================================

local FinalScoreLabel = Label(
    GameOverPanel,

    "SCORE: 0",

    UDim2.new(
        1,
        -30,
        0,
        25
    ),

    UDim2.fromOffset(
        15,
        68
    ),

    Enum.Font.GothamBold,

    13
)

FinalScoreLabel.TextColor3 =
    CONFIG.Muted

FinalScoreLabel.TextXAlignment =
    Enum.TextXAlignment.Center

--========================================
-- FINAL BEST
--========================================

local FinalBestLabel = Label(
    GameOverPanel,

    "BEST: 0",

    UDim2.new(
        1,
        -30,
        0,
        25
    ),

    UDim2.fromOffset(
        15,
        94
    ),

    Enum.Font.Gotham,

    11
)

FinalBestLabel.TextColor3 =
    CONFIG.Muted

FinalBestLabel.TextXAlignment =
    Enum.TextXAlignment.Center

--========================================
-- RESTART BUTTON
--========================================

local RestartButton = New("TextButton", {
    Name = "RestartButton",

    Size = UDim2.fromOffset(
        125,
        42
    ),

    Position = UDim2.fromOffset(
        20,
        158
    ),

    BackgroundColor3 =
        CONFIG.PurpleDark,

    Text = "RESTART",

    TextColor3 =
        CONFIG.Text,

    TextSize = 11,

    Font =
        Enum.Font.GothamBold,

    AutoButtonColor = false,

    BorderSizePixel = 0,

    ZIndex = 82
}, GameOverPanel)

Corner(
    RestartButton,
    11
)

--========================================
-- GAME OVER MENU BUTTON
--========================================

local GameOverMenuButton = New("TextButton", {
    Name = "GameOverMenuButton",

    Size = UDim2.fromOffset(
        125,
        42
    ),

    Position = UDim2.fromOffset(
        155,
        158
    ),

    BackgroundColor3 =
        CONFIG.Panel2,

    Text = "MENU",

    TextColor3 =
        CONFIG.Text,

    TextSize = 11,

    Font =
        Enum.Font.GothamBold,

    AutoButtonColor = false,

    BorderSizePixel = 0,

    ZIndex = 82
}, GameOverPanel)

Corner(
    GameOverMenuButton,
    11
)

--========================================
-- PAUSE OVERLAY
--========================================

local PauseOverlay = New("Frame", {
    Name = "PauseOverlay",

    Size = UDim2.fromScale(
        1,
        1
    ),

    Position = UDim2.fromScale(
        0,
        0
    ),

    BackgroundColor3 =
        Color3.fromRGB(
            6,
            5,
            12
        ),

    BackgroundTransparency = 0.18,

    BorderSizePixel = 0,

    Visible = false,

    ZIndex = 70
}, GamePage)

Corner(
    PauseOverlay,
    14
)

--========================================
-- PAUSE TITLE
--========================================

local PauseTitle = Label(
    PauseOverlay,

    "PAUSED",

    UDim2.new(
        1,
        -40,
        0,
        40
    ),

    UDim2.fromOffset(
        20,
        105
    ),

    Enum.Font.GothamBold,

    25
)

PauseTitle.TextXAlignment =
    Enum.TextXAlignment.Center

--========================================
-- PAUSE DESCRIPTION
--========================================

local PauseDescription = Label(
    PauseOverlay,

    "Game progress is saved.",

    UDim2.new(
        1,
        -40,
        0,
        25
    ),

    UDim2.fromOffset(
        20,
        145
    ),

    Enum.Font.Gotham,

    11
)

PauseDescription.TextColor3 =
    CONFIG.Muted

PauseDescription.TextXAlignment =
    Enum.TextXAlignment.Center

--========================================
-- RESUME BUTTON
--========================================

local ResumeButton = New("TextButton", {
    Name = "ResumeButton",

    Size = UDim2.fromOffset(
        150,
        42
    ),

    Position = UDim2.new(
        0.5,
        -75,
        0,
        180
    ),

    BackgroundColor3 =
        CONFIG.PurpleDark,

    Text = "RESUME",

    TextColor3 =
        CONFIG.Text,

    TextSize = 11,

    Font =
        Enum.Font.GothamBold,

    AutoButtonColor = false,

    BorderSizePixel = 0,

    ZIndex = 72
}, PauseOverlay)

Corner(
    ResumeButton,
    11
)

--========================================
-- PAUSE STATE
--========================================

local function SetPaused(state)

    GamePaused = state

    PauseOverlay.Visible =
        state

    if state then

        StatusLabel.Text =
            "PAUSED"

        PauseButton.Text =
            "RESUME"

    else

        StatusLabel.Text =
            "RUNNING"

        PauseButton.Text =
            "PAUSE"
    end

    SaveGame()
end

--========================================
-- GENERATE FOOD
--========================================

local function IsSnakePosition(x, y)

    for _, segment in ipairs(
        Snake
    ) do

        if segment.X == x
        and segment.Y == y then

            return true
        end
    end

    return false
end

local function GenerateFood()

    local available = {}

    for x = 0, CONFIG.Width - 1 do

        for y = 0, CONFIG.Height - 1 do

            if not IsSnakePosition(
                x,
                y
            ) then

                table.insert(
                    available,
                    {
                        X = x,
                        Y = y
                    }
                )
            end
        end
    end

    if #available == 0 then
        return
    end

    local selected =
        available[
            math.random(
                1,
                #available
            )
        ]

    Food.X = selected.X
    Food.Y = selected.Y

    DrawFood()
end

--========================================
-- RESET GAME
--========================================

local function ResetGame()

    Snake = {
        {
            X = 9,
            Y = 7
        },

        {
            X = 8,
            Y = 7
        },

        {
            X = 7,
            Y = 7
        }
    }

    Food = {
        X = 14,
        Y = 7
    }

    CurrentScore = 0

    CurrentDirection = "Right"

    DirectionQueue = {}

    MoveTimer = 0

    GameRunning = true
    GamePaused = false

    GameOverPanel.Visible =
        false

    PauseOverlay.Visible =
        false

    PauseButton.Text =
        "PAUSE"

    StatusLabel.Text =
        "RUNNING"

    DrawSnake()
    DrawFood()
    UpdateScore()
    SaveGame()
end

--========================================
-- COLLISION CHECK
--========================================

local function CheckCollision(
    newHead,
    willEat
)

    if newHead.X < 0
    or newHead.X >= CONFIG.Width
    or newHead.Y < 0
    or newHead.Y >= CONFIG.Height then

        return true
    end

    local lastIndex =
        #Snake

    if not willEat then
        lastIndex =
            math.max(
                1,
                #Snake - 1
            )
    end

    for i = 2, lastIndex do

        local segment =
            Snake[i]

        if segment.X ==
            newHead.X

        and segment.Y ==
            newHead.Y then

            return true
        end
    end

    return false
end

--========================================
-- END GAME
--========================================

local function EndGame()

    GameRunning = false
    GamePaused = false

    DirectionQueue = {}

    StatusLabel.Text =
        "GAME OVER"

    FinalScoreLabel.Text =
        "SCORE: "
        .. tostring(CurrentScore)

    FinalBestLabel.Text =
        "BEST: "
        .. tostring(LocalBestScore)

    GameOverPanel.Visible =
        true

    PauseOverlay.Visible =
        false

    PauseButton.Text =
        "PAUSE"

    Save.Score =
        CurrentScore

    Save.BestScore =
        LocalBestScore

    Save.Running =
        false

    Save.Paused =
        false

    UpdateScore()

    Tween(
        GameOverPanel,
        0.28,
        {
            Size =
                UDim2.fromOffset(
                    310,
                    238
                )
        },
        Enum.EasingStyle.Back
    )
end

--========================================
-- MOVE SNAKE
--========================================

local function MoveSnake()

    if not GameRunning
    or GamePaused then
        return
    end

    -- Apply the next queued direction
    if #DirectionQueue > 0 then

        CurrentDirection =
            table.remove(
                DirectionQueue,
                1
            )
    end

    Save.Direction =
        CurrentDirection

    local vector =
        DirectionVector[
            CurrentDirection
        ]

    if not vector then
        return
    end

    local head =
        Snake[1]

    local newHead = {
        X = head.X + vector.X,
        Y = head.Y + vector.Y
    }

    local willEat =
        newHead.X == Food.X
        and newHead.Y == Food.Y

    if CheckCollision(
        newHead,
        willEat
    ) then

        EndGame()
        return
    end

    table.insert(
        Snake,
        1,
        newHead
    )

    if willEat then

        CurrentScore =
            CurrentScore + 1

        if CurrentScore >
            LocalBestScore then

            LocalBestScore =
                CurrentScore
        end

        GenerateFood()

        UpdateScore()

    else

        table.remove(
            Snake,
            #Snake
        )
    end

    DrawSnake()
    DrawFood()

    SaveGame()
end

--========================================
-- START GAME
--========================================

local function StartGame()

    if not GameRunning then

        if Save.Running
        and Save.Snake
        and #Save.Snake > 0 then

            GameRunning = true

            GamePaused =
                Save.Paused or false

            CurrentScore =
                Save.Score or 0

            LocalBestScore =
                Save.BestScore or 0

            CurrentDirection =
                Save.Direction
                or "Right"

            DirectionQueue = {}

            if type(
                Save.DirectionQueue
            ) == "table" then

                for _, direction in ipairs(
                    Save.DirectionQueue
                ) do

                    if DirectionVector[
                        direction
                    ] then

                        table.insert(
                            DirectionQueue,
                            direction
                        )
                    end
                end
            end

        else

            ResetGame()
        end
    end

    GamePage.Visible = true
    Home.Visible = false

    GameOverPanel.Visible =
        false

    if GamePaused then

        PauseOverlay.Visible =
            true

        PauseButton.Text =
            "RESUME"

        StatusLabel.Text =
            "PAUSED"

    else

        PauseOverlay.Visible =
            false

        PauseButton.Text =
            "PAUSE"

        StatusLabel.Text =
            "RUNNING"
    end

    DrawSnake()
    DrawFood()
    UpdateScore()
end

--========================================
-- PAUSE BUTTON
--========================================

PauseButton.MouseButton1Click:Connect(
    function()

        if not GameRunning then
            return
        end

        SetPaused(
            not GamePaused
        )
    end
)

--========================================
-- RESUME BUTTON
--========================================

ResumeButton.MouseButton1Click:Connect(
    function()

        if GameRunning then
            SetPaused(false)
        end
    end
)

--========================================
-- RESTART BUTTON
--========================================

RestartButton.MouseButton1Click:Connect(
    function()

        ResetGame()

        GamePage.Visible = true
        Home.Visible = false
    end
)

--========================================
-- GAME OVER MENU
--========================================

GameOverMenuButton.MouseButton1Click:Connect(
    function()

        GameOverPanel.Visible =
            false

        GamePage.Visible =
            false

        Home.Visible =
            true

        CurrentPage =
            "Home"

        SaveGame()
    end
)

--========================================
-- MENU BUTTON
--========================================

MenuButton.MouseButton1Click:Connect(
    function()

        -- Keep the current snake state.
        -- Do not move the page upward.
        SaveGame()

        GamePaused = true

        Save.Paused = true

        GamePage.Visible =
            false

        Home.Visible =
            true

        Home.Position =
            UDim2.fromOffset(
                0,
                0
            )

        CurrentPage =
            "Home"
    end
)

--========================================
-- PLAY BUTTON CONTINUE
--========================================

PlayButton.MouseButton1Click:Connect(
    function()

        GameOverPanel.Visible =
            false

        StartGame()
    end
)

--========================================
-- KEYBOARD INPUT
--========================================

UserInputService.InputBegan:Connect(
    function(input, processed)

        if processed then
            return
        end

        if not GameRunning then
            return
        end

        if input.UserInputType
            ~= Enum.UserInputType.Keyboard then
            return
        end

        local key =
            input.KeyCode

        if key == Enum.KeyCode.W
        or key == Enum.KeyCode.Up then

            SetDirection("Up")

        elseif key == Enum.KeyCode.S
        or key == Enum.KeyCode.Down then

            SetDirection("Down")

        elseif key == Enum.KeyCode.A
        or key == Enum.KeyCode.Left then

            SetDirection("Left")

        elseif key == Enum.KeyCode.D
        or key == Enum.KeyCode.Right then

            SetDirection("Right")

        elseif key == Enum.KeyCode.Space then

            SetPaused(
                not GamePaused
            )
        end
    end
)

--========================================
-- GAME LOOP
--========================================

local Connection

Connection = RunService.Heartbeat:Connect(
    function(deltaTime)

        if not Gui.Parent then

            if Connection then
                Connection:Disconnect()
            end

            return
        end

        if not GameRunning
        or GamePaused then
            return
        end

        -- Prevent huge jumps after frame drops.
        deltaTime =
            math.min(
                deltaTime,
                0.1
            )

        MoveTimer =
            MoveTimer + deltaTime

        -- Fixed-step movement.
        -- This prevents the snake from getting
        -- stuck when a frame takes longer than usual.

        while MoveTimer >=
            CONFIG.GameSpeed do

            MoveTimer =
                MoveTimer
                - CONFIG.GameSpeed

            MoveSnake()

            if not GameRunning then
                break
            end
        end
    end
)

--========================================
-- INITIAL DRAW
--========================================

DrawSnake()
DrawFood()
UpdateScore()

--========================================
-- END PART 3/4
--========================================

--========================================
-- LUNAR SNAKE
-- PART 4/4
-- DRAG / MOBILE / ANIMATIONS / CLEANUP
--========================================

--========================================
-- DRAG SYSTEM
--========================================

local function MakeDraggable(frame, handle)

    local dragging = false
    local dragStart
    local startPosition

    local dragInput

    handle.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
            or input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = true

                dragStart =
                    input.Position

                startPosition =
                    frame.Position

                input.Changed:Connect(
                    function()

                        if input.UserInputState ==
                            Enum.UserInputState.End then

                            dragging = false
                        end
                    end
                )
            end
        end
    )

    handle.InputChanged:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
            or input.UserInputType ==
                Enum.UserInputType.Touch then

                dragInput = input
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)

            if input ~= dragInput
            or not dragging then
                return
            end

            local delta =
                input.Position - dragStart

            frame.Position =
                UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset
                        + delta.X,

                    startPosition.Y.Scale,
                    startPosition.Y.Offset
                        + delta.Y
                )
        end
    )
end

--========================================
-- DRAG MAIN MENU
--========================================

MakeDraggable(
    Holder,
    TopBar
)

--========================================
-- DRAG MINIMIZED BAR
--========================================

MakeDraggable(
    MiniBar,
    MiniBar
)

--========================================
-- MINI BAR HOVER
--========================================

MiniBar.MouseEnter:Connect(
    function()

        Tween(
            MiniBar,
            0.14,
            {
                BackgroundColor3 =
                    CONFIG.Panel2
            }
        )

        Tween(
            MiniLogo,
            0.14,
            {
                BackgroundColor3 =
                    CONFIG.PurpleDark
            }
        )
    end
)

MiniBar.MouseLeave:Connect(
    function()

        Tween(
            MiniBar,
            0.14,
            {
                BackgroundColor3 =
                    CONFIG.Panel
            }
        )

        Tween(
            MiniLogo,
            0.14,
            {
                BackgroundColor3 =
                    CONFIG.Panel2
            }
        )
    end
)

--========================================
-- GAME BUTTON HOVERS
--========================================

local function SimpleHover(
    button,
    normal,
    hover
)

    button.MouseEnter:Connect(
        function()

            Tween(
                button,
                0.12,
                {
                    BackgroundColor3 =
                        hover
                }
            )
        end
    )

    button.MouseLeave:Connect(
        function()

            Tween(
                button,
                0.12,
                {
                    BackgroundColor3 =
                        normal
                }
            )
        end
    )
end

SimpleHover(
    MenuButton,
    CONFIG.Panel2,
    CONFIG.PurpleDark
)

SimpleHover(
    PauseButton,
    CONFIG.PurpleDark,
    CONFIG.Purple
)

SimpleHover(
    RestartButton,
    CONFIG.PurpleDark,
    CONFIG.Purple
)

SimpleHover(
    GameOverMenuButton,
    CONFIG.Panel2,
    CONFIG.PurpleDark
)

SimpleHover(
    ResumeButton,
    CONFIG.PurpleDark,
    CONFIG.Purple
)

--========================================
-- BUTTON PRESS ANIMATION
--========================================

local function PressAnimation(button)

    local originalSize =
        button.Size

    button.MouseButton1Down:Connect(
        function()

            Tween(
                button,
                0.07,
                {
                    Size = UDim2.fromOffset(
                        math.max(
                            20,
                            originalSize.X.Offset - 3
                        ),

                        math.max(
                            20,
                            originalSize.Y.Offset - 2
                        )
                    )
                },
                Enum.EasingStyle.Quad
            )
        end
    )

    button.MouseButton1Up:Connect(
        function()

            Tween(
                button,
                0.1,
                {
                    Size =
                        originalSize
                },
                Enum.EasingStyle.Back
            )
        end
    )
end

PressAnimation(PlayButton)
PressAnimation(MinimizeButton)
PressAnimation(CloseButton)

PressAnimation(MenuButton)
PressAnimation(PauseButton)

PressAnimation(RestartButton)
PressAnimation(GameOverMenuButton)
PressAnimation(ResumeButton)

--========================================
-- MOBILE SWIPE
--========================================

local SwipeStart = nil
local SwipeMinimum = 35

GamePage.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.Touch then

            SwipeStart =
                input.Position
        end
    end
)

GamePage.InputEnded:Connect(
    function(input)

        if input.UserInputType ~=
            Enum.UserInputType.Touch then
            return
        end

        if not SwipeStart then
            return
        end

        local delta =
            input.Position - SwipeStart

        SwipeStart = nil

        if delta.Magnitude <
            SwipeMinimum then
            return
        end

        if math.abs(delta.X) >
            math.abs(delta.Y) then

            if delta.X > 0 then

                SetDirection(
                    "Right"
                )

            else

                SetDirection(
                    "Left"
                )
            end

        else

            if delta.Y > 0 then

                SetDirection(
                    "Down"
                )

            else

                SetDirection(
                    "Up"
                )
            end
        end
    end
)

--========================================
-- GAME OVER ANIMATION
--========================================

local GameOverAnimationConnection

local function AnimateGameOver()

    GameOverPanel.Size =
        UDim2.fromOffset(
            260,
            200
        )

    GameOverPanel.BackgroundTransparency =
        0.35

    Tween(
        GameOverPanel,
        0.3,
        {
            Size =
                UDim2.fromOffset(
                    300,
                    230
                ),

            BackgroundTransparency = 0
        },
        Enum.EasingStyle.Back
    )
end

--========================================
-- GAME OVER WATCHER
--========================================

GameOverPanel:GetPropertyChangedSignal(
    "Visible"
):Connect(
    function()

        if GameOverPanel.Visible then

            AnimateGameOver()
        end
    end
)

--========================================
-- PAUSE ANIMATION
--========================================

PauseOverlay:GetPropertyChangedSignal(
    "Visible"
):Connect(
    function()

        if PauseOverlay.Visible then

            PauseOverlay.BackgroundTransparency =
                1

            PauseTitle.TextTransparency =
                1

            PauseDescription.TextTransparency =
                1

            ResumeButton.BackgroundTransparency =
                1

            Tween(
                PauseOverlay,
                0.2,
                {
                    BackgroundTransparency =
                        0.18
                }
            )

            Tween(
                PauseTitle,
                0.2,
                {
                    TextTransparency = 0
                }
            )

            Tween(
                PauseDescription,
                0.2,
                {
                    TextTransparency = 0
                }
            )

            Tween(
                ResumeButton,
                0.2,
                {
                    BackgroundTransparency = 0
                }
            )
        end
    end
)

--========================================
-- SAFE HOME TRANSITION
--========================================

local function SafeShowHome()

    CurrentPage = "Home"

    -- Always reset the page position.
    -- This prevents the menu from appearing
    -- above the normal position.

    Home.Position =
        UDim2.fromOffset(
            0,
            0
        )

    GamePage.Position =
        UDim2.fromOffset(
            0,
            0
        )

    GamePage.Visible =
        false

    Home.Visible =
        true

    GameOverPanel.Visible =
        false

    PauseOverlay.Visible =
        false
end

--========================================
-- REPLACE MENU TRANSITION
--========================================

MenuButton.MouseButton1Click:Connect(
    function()

        SaveGame()

        GamePaused = true

        Save.Paused = true

        SafeShowHome()
    end
)

--========================================
-- RESTORE GAME FROM HOME
--========================================

PlayButton.MouseButton1Click:Connect(
    function()

        Home.Position =
            UDim2.fromOffset(
                0,
                0
            )

        GamePage.Position =
            UDim2.fromOffset(
                0,
                0
            )

        GamePage.Visible =
            true

        Home.Visible =
            false

        StartGame()
    end
)

--========================================
-- SAVE BEFORE GUI DESTROY
--========================================

Gui.Destroying:Connect(
    function()

        pcall(
            function()
                SaveGame()
            end
        )
    end
)

--========================================
-- SAVE WHEN PLAYER LEAVES
--========================================

Players.PlayerRemoving:Connect(
    function(player)

        if player == Player then

            pcall(
                function()
                    SaveGame()
                end
            )
        end
    end
)

--========================================
-- SCORE UPDATE LOOP
--========================================

local ScoreUpdateConnection

ScoreUpdateConnection =
    RunService.RenderStepped:Connect(
        function()

            if not Gui.Parent then

                if ScoreUpdateConnection then
                    ScoreUpdateConnection:Disconnect()
                end

                return
            end

            if ScoreLabel
            and ScoreLabel.Parent then

                ScoreLabel.Text =
                    tostring(
                        CurrentScore
                    )
            end

            if BestLabel
            and BestLabel.Parent then

                BestLabel.Text =
                    tostring(
                        LocalBestScore
                    )
            end
        end
    )

--========================================
-- RESTORE SAVED DATA
--========================================

if Save.BestScore then

    LocalBestScore =
        Save.BestScore

end

if Save.Score then

    CurrentScore =
        Save.Score

end

BestLabel.Text =
    tostring(
        LocalBestScore
    )

ScoreLabel.Text =
    tostring(
        CurrentScore
    )

--========================================
-- PREPARE SAVED SNAKE
--========================================

if Save.Running
and Save.Snake
and #Save.Snake > 0 then

    GameRunning = true

    GamePaused =
        Save.Paused or false

    CurrentDirection =
        Save.Direction or "Right"

    DirectionQueue = {}

    if type(
        Save.DirectionQueue
    ) == "table" then

        for _, direction in ipairs(
            Save.DirectionQueue
        ) do

            if DirectionVector[
                direction
            ] then

                table.insert(
                    DirectionQueue,
                    direction
                )
            end
        end
    end

    DrawSnake()
    DrawFood()

else

    GameRunning = false
    GamePaused = false
end

--========================================
-- FINAL PAGE STATE
--========================================

Home.Position =
    UDim2.fromOffset(
        0,
        0
    )

GamePage.Position =
    UDim2.fromOffset(
        0,
        0
    )

GamePage.Visible =
    false

Home.Visible =
    true

--========================================
-- FINAL HOLDER STATE
--========================================

Holder.Visible =
    true

MiniBar.Visible =
    false

Minimized =
    false

--========================================
-- FINAL DATA SAVE
--========================================

pcall(
    function()
        SaveGame()
    end
)

--========================================
-- END PART 4/4
--========================================

--========================================
-- LUNAR SNAKE COMPLETE
--========================================
