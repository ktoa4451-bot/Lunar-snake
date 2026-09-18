--========================================
-- LUNAR SNAKE
-- PART 1/3
-- CORE / UI / HOME / GAME BOARD
--========================================

--========================================
-- SERVICES
--========================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--========================================
-- PERSISTENT DATA
--========================================

getgenv().LunarSnakeData = getgenv().LunarSnakeData or {
    BestScore = 0,
    Score = 0,
    Snake = nil,
    Food = nil,
    Direction = "Right",
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

    -- Slower than the previous version
    GameSpeed = 0.22,

    Background = Color3.fromRGB(8, 7, 15),
    Panel = Color3.fromRGB(15, 13, 25),
    Panel2 = Color3.fromRGB(20, 17, 33),

    Purple = Color3.fromRGB(142, 82, 255),
    PurpleDark = Color3.fromRGB(76, 42, 135),

    Text = Color3.fromRGB(240, 236, 255),
    Muted = Color3.fromRGB(155, 148, 180),

    Snake = Color3.fromRGB(164, 94, 255),
    SnakeHead = Color3.fromRGB(202, 156, 255),
    Food = Color3.fromRGB(255, 92, 166)
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
    local info = TweenInfo.new(
        time,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(object, info, properties)
    tween:Play()

    return tween
end

local function Label(parent, text, size, position, font, textSize)
    return New("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        Size = size,
        Position = position,
        Font = font or Enum.Font.Gotham,
        TextSize = textSize or 14,
        TextColor3 = CONFIG.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

--========================================
-- REMOVE OLD MENU
--========================================

local old = game:GetService("CoreGui"):FindFirstChild("LunarSnake")

if old then
    old:Destroy()
end

--========================================
-- SCREEN GUI
--========================================

local Gui = New("ScreenGui", {
    Name = "LunarSnake",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, game:GetService("CoreGui"))

--========================================
-- MAIN HOLDER
--========================================

local Holder = New("Frame", {
    Name = "Holder",
    Size = UDim2.fromOffset(570, 470),
    Position = UDim2.new(0.5, -285, 0.5, -235),
    BackgroundColor3 = CONFIG.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true
}, Gui)

Corner(Holder, 18)
Stroke(Holder, CONFIG.PurpleDark, 1, 0.25)

--========================================
-- ANIMATED BACKGROUND
--========================================

local Background = New("Frame", {
    Name = "Background",
    Size = UDim2.fromScale(1, 1),
    Position = UDim2.fromScale(0, 0),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 0
}, Holder)

for i = 1, 7 do
    local line = New("Frame", {
        Size = UDim2.fromOffset(2, 700),
        Position = UDim2.new(-0.2 + i * 0.18, 0, -0.4, 0),
        Rotation = 25,
        BackgroundColor3 = CONFIG.Purple,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        ZIndex = 0
    }, Background)

    task.spawn(function()
        while line.Parent do
            local start = line.Position

            Tween(
                line,
                4 + i * 0.35,
                {
                    Position = UDim2.new(
                        start.X.Scale + 0.22,
                        start.X.Offset,
                        start.Y.Scale,
                        start.Y.Offset
                    )
                },
                Enum.EasingStyle.Linear
            ).Completed:Wait()

            line.Position = UDim2.new(
                -0.35 + i * 0.18,
                0,
                -0.4,
                0
            )
        end
    end)
end

--========================================
-- TOP BAR
--========================================

local TopBar = New("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, -28, 0, 64),
    Position = UDim2.fromOffset(14, 10),
    BackgroundTransparency = 1,
    ZIndex = 10
}, Holder)

--========================================
-- LUNAR LOGO
--========================================

local LogoHolder = New("Frame", {
    Size = UDim2.fromOffset(42, 42),
    Position = UDim2.fromOffset(0, 8),
    BackgroundColor3 = CONFIG.Panel2,
    BorderSizePixel = 0
}, TopBar)

Corner(LogoHolder, 12)
Stroke(LogoHolder, CONFIG.PurpleDark, 1, 0.35)

local MoonOuter = New("Frame", {
    Size = UDim2.fromOffset(23, 23),
    Position = UDim2.new(0.5, -11, 0.5, -11),
    BackgroundColor3 = Color3.fromRGB(191, 157, 255),
    BorderSizePixel = 0
}, LogoHolder)

Corner(MoonOuter, 50)

local MoonCut = New("Frame", {
    Size = UDim2.fromOffset(21, 21),
    Position = UDim2.fromOffset(8, -2),
    BackgroundColor3 = CONFIG.Panel2,
    BorderSizePixel = 0
}, MoonOuter)

Corner(MoonCut, 50)

--========================================
-- TITLE
--========================================

local Title = Label(
    TopBar,
    "LUNAR SNAKE",
    UDim2.fromOffset(220, 28),
    UDim2.fromOffset(54, 7),
    Enum.Font.GothamBold,
    18
)

local Subtitle = Label(
    TopBar,
    "CLASSIC SNAKE GAME",
    UDim2.fromOffset(220, 20),
    UDim2.fromOffset(54, 32),
    Enum.Font.Gotham,
    10
)

Subtitle.TextColor3 = CONFIG.Muted

--========================================
-- MINIMIZE BUTTON
--========================================

local MinimizeButton = New("TextButton", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -72, 0, 12),
    BackgroundColor3 = CONFIG.Panel2,
    Text = "—",
    TextColor3 = CONFIG.Text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 20
}, TopBar)

Corner(MinimizeButton, 10)

--========================================
-- CLOSE BUTTON
--========================================

local CloseButton = New("TextButton", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -34, 0, 12),
    BackgroundColor3 = CONFIG.Panel2,
    Text = "×",
    TextColor3 = CONFIG.Text,
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 20
}, TopBar)

Corner(CloseButton, 10)

--========================================
-- CONTENT
--========================================

local Content = New("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -28, 1, -86),
    Position = UDim2.fromOffset(14, 76),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 5
}, Holder)

--========================================
-- HOME PAGE
--========================================

local Home = New("Frame", {
    Name = "Home",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ZIndex = 5
}, Content)

--========================================
-- HOME CARD
--========================================

local GameCard = New("Frame", {
    Size = UDim2.new(1, -20, 0, 215),
    Position = UDim2.fromOffset(10, 8),
    BackgroundColor3 = CONFIG.Panel,
    BorderSizePixel = 0,
    ZIndex = 6
}, Home)

Corner(GameCard, 16)
Stroke(GameCard, CONFIG.PurpleDark, 1, 0.45)

--========================================
-- SNAKE ICON
--========================================

local SnakeIcon = New("Frame", {
    Size = UDim2.fromOffset(74, 74),
    Position = UDim2.fromOffset(24, 24),
    BackgroundColor3 = CONFIG.Panel2,
    BorderSizePixel = 0,
    ZIndex = 7
}, GameCard)

Corner(SnakeIcon, 18)

local SnakeDot1 = New("Frame", {
    Size = UDim2.fromOffset(15, 15),
    Position = UDim2.fromOffset(18, 30),
    BackgroundColor3 = CONFIG.Snake,
    BorderSizePixel = 0,
    ZIndex = 8
}, SnakeIcon)

Corner(SnakeDot1, 50)

local SnakeDot2 = New("Frame", {
    Size = UDim2.fromOffset(15, 15),
    Position = UDim2.fromOffset(31, 30),
    BackgroundColor3 = CONFIG.Snake,
    BorderSizePixel = 0,
    ZIndex = 8
}, SnakeIcon)

Corner(SnakeDot2, 50)

local SnakeDot3 = New("Frame", {
    Size = UDim2.fromOffset(15, 15),
    Position = UDim2.fromOffset(44, 30),
    BackgroundColor3 = CONFIG.SnakeHead,
    BorderSizePixel = 0,
    ZIndex = 8
}, SnakeIcon)

Corner(SnakeDot3, 50)

--========================================
-- HOME TEXT
--========================================

Label(
    GameCard,
    "Lunar Snake",
    UDim2.fromOffset(250, 32),
    UDim2.fromOffset(120, 25),
    Enum.Font.GothamBold,
    22
)

local Description = Label(
    GameCard,
    "Classic snake with a Lunar style.",
    UDim2.fromOffset(320, 24),
    UDim2.fromOffset(120, 59),
    Enum.Font.Gotham,
    12
)

Description.TextColor3 = CONFIG.Muted

--========================================
-- PLAY BUTTON
--========================================

local PlayButton = New("TextButton", {
    Size = UDim2.fromOffset(170, 44),
    Position = UDim2.fromOffset(120, 105),
    BackgroundColor3 = CONFIG.PurpleDark,
    Text = "PLAY",
    TextColor3 = CONFIG.Text,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 10
}, GameCard)

Corner(PlayButton, 12)

--========================================
-- BEST SCORE CARD
--========================================

local BestCard = New("Frame", {
    Size = UDim2.new(0.48, -5, 0, 90),
    Position = UDim2.fromOffset(10, 235),
    BackgroundColor3 = CONFIG.Panel,
    BorderSizePixel = 0,
    ZIndex = 6
}, Home)

Corner(BestCard, 14)
Stroke(BestCard, CONFIG.PurpleDark, 1, 0.55)

Label(
    BestCard,
    "BEST SCORE",
    UDim2.new(1, -20, 0, 24),
    UDim2.fromOffset(10, 9),
    Enum.Font.Gotham,
    10
).TextColor3 = CONFIG.Muted

local BestLabel = Label(
    BestCard,
    tostring(Save.BestScore),
    UDim2.new(1, -20, 0, 38),
    UDim2.fromOffset(10, 29),
    Enum.Font.GothamBold,
    24
)

--========================================
-- MODE CARD
--========================================

local ModeCard = New("Frame", {
    Size = UDim2.new(0.48, -5, 0, 90),
    Position = UDim2.new(0.52, 0, 0, 235),
    BackgroundColor3 = CONFIG.Panel,
    BorderSizePixel = 0,
    ZIndex = 6
}, Home)

Corner(ModeCard, 14)
Stroke(ModeCard, CONFIG.PurpleDark, 1, 0.55)

Label(
    ModeCard,
    "MODE",
    UDim2.new(1, -20, 0, 24),
    UDim2.fromOffset(10, 9),
    Enum.Font.Gotham,
    10
).TextColor3 = CONFIG.Muted

Label(
    ModeCard,
    "CLASSIC",
    UDim2.new(1, -20, 0, 38),
    UDim2.fromOffset(10, 29),
    Enum.Font.GothamBold,
    18
)

--========================================
-- GAME PAGE
--========================================

local GamePage = New("Frame", {
    Name = "GamePage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = 5
}, Content)

--========================================
-- GAME BOARD
--========================================

local Board = New("Frame", {
    Name = "Board",
    Size = UDim2.fromOffset(
        CONFIG.Width * CONFIG.CellSize,
        CONFIG.Height * CONFIG.CellSize
    ),
    Position = UDim2.fromOffset(0, 8),
    BackgroundColor3 = Color3.fromRGB(10, 9, 18),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 6
}, GamePage)

Corner(Board, 14)
Stroke(Board, CONFIG.PurpleDark, 1, 0.35)

--========================================
-- GRID
--========================================

for x = 1, CONFIG.Width - 1 do
    local line = New("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(
            0,
            x * CONFIG.CellSize,
            0,
            0
        ),
        BackgroundColor3 = CONFIG.Purple,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        ZIndex = 6
    }, Board)
end

for y = 1, CONFIG.Height - 1 do
    local line = New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(
            0,
            0,
            0,
            y * CONFIG.CellSize
        ),
        BackgroundColor3 = CONFIG.Purple,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        ZIndex = 6
    }, Board)
end

--========================================
-- SNAKE CONTAINER
--========================================

local SnakeContainer = New("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 10
}, Board)

local FoodObject = New("Frame", {
    Size = UDim2.fromOffset(
        CONFIG.CellSize - 6,
        CONFIG.CellSize - 6
    ),
    BackgroundColor3 = CONFIG.Food,
    BorderSizePixel = 0,
    ZIndex = 11
}, Board)

Corner(FoodObject, 50)

--========================================
-- GAME DATA
--========================================

local Snake = {}
local Direction = Save.Direction or "Right"
local WantedDirection = Direction

local Score = Save.Score or 0
local BestScore = Save.BestScore or 0

local GameRunning = Save.Running or false
local GamePaused = Save.Paused or false

local Food = Save.Food

--========================================
-- DEFAULT SNAKE
--========================================

if type(Save.Snake) == "table" and #Save.Snake > 0 then
    for i, segment in ipairs(Save.Snake) do
        Snake[i] = {
            X = segment.X,
            Y = segment.Y
        }
    end
else
    Snake = {
        {X = 8, Y = 7},
        {X = 7, Y = 7},
        {X = 6, Y = 7},
        {X = 5, Y = 7}
    }
end

if not Food then
    Food = {
        X = 13,
        Y = 7
    }
end

--========================================
-- DRAW SNAKE
--========================================

local function ClearSnake()
    for _, object in ipairs(SnakeContainer:GetChildren()) do
        object:Destroy()
    end
end

local function DrawSnake()
    ClearSnake()

    for index, segment in ipairs(Snake) do
        local part = New("Frame", {
            Size = UDim2.fromOffset(
                CONFIG.CellSize - 5,
                CONFIG.CellSize - 5
            ),

            Position = UDim2.fromOffset(
                (segment.X - 1) * CONFIG.CellSize + 2,
                (segment.Y - 1) * CONFIG.CellSize + 2
            ),

            BackgroundColor3 =
                index == 1
                and CONFIG.SnakeHead
                or CONFIG.Snake,

            BorderSizePixel = 0,
            ZIndex = index == 1 and 13 or 12
        }, SnakeContainer)

        Corner(part, 6)
    end
end

--========================================
-- DRAW FOOD
--========================================

local function DrawFood()
    FoodObject.Position = UDim2.fromOffset(
        (Food.X - 1) * CONFIG.CellSize + 3,
        (Food.Y - 1) * CONFIG.CellSize + 3
    )
end

DrawSnake()
DrawFood()

--========================================
-- GAME UI
--========================================

local ScoreLabel = Label(
    GamePage,
    "SCORE  " .. tostring(Score),
    UDim2.fromOffset(110, 28),
    UDim2.fromOffset(0, 330),
    Enum.Font.GothamBold,
    13
)

local BestGameLabel = Label(
    GamePage,
    "BEST  " .. tostring(BestScore),
    UDim2.fromOffset(110, 24),
    UDim2.fromOffset(0, 355),
    Enum.Font.Gotham,
    11
)

BestGameLabel.TextColor3 = CONFIG.Muted

--========================================
-- GAME STATUS
--========================================

local StatusLabel = Label(
    GamePage,
    "READY",
    UDim2.fromOffset(100, 24),
    UDim2.fromOffset(328, 8),
    Enum.Font.GothamBold,
    11
)

StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.TextColor3 = CONFIG.Muted

--========================================
-- MENU BUTTON
--========================================

local MenuButton = New("TextButton", {
    Size = UDim2.fromOffset(95, 34),
    Position = UDim2.fromOffset(328, 350),
    BackgroundColor3 = CONFIG.Panel2,
    Text = "MENU",
    TextColor3 = CONFIG.Text,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 20
}, GamePage)

Corner(MenuButton, 10)
Stroke(MenuButton, CONFIG.PurpleDark, 1, 0.4)

--========================================
-- PAUSE BUTTON
--========================================

local PauseButton = New("TextButton", {
    Size = UDim2.fromOffset(42, 42),
    Position = UDim2.fromOffset(456, 6),
    BackgroundColor3 = CONFIG.Panel2,
    Text = "Ⅱ",
    TextColor3 = CONFIG.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 20
}, GamePage)

Corner(PauseButton, 12)

--========================================
-- SAVE FUNCTION
--========================================

local function SaveGame()
    Save.BestScore = BestScore
    Save.Score = Score
    Save.Direction = Direction
    Save.Paused = GamePaused
    Save.Running = GameRunning

    Save.Snake = {}

    for i, segment in ipairs(Snake) do
        Save.Snake[i] = {
            X = segment.X,
            Y = segment.Y
        }
    end

    Save.Food = {
        X = Food.X,
        Y = Food.Y
    }
end

--========================================
-- UPDATE SCORE
--========================================

local function UpdateScore()
    ScoreLabel.Text = "SCORE  " .. tostring(Score)
    BestGameLabel.Text = "BEST  " .. tostring(BestScore)
    BestLabel.Text = tostring(BestScore)
end

UpdateScore()

--========================================
-- PAGE SWITCHING
--========================================

local function ShowHome()
    SaveGame()

    GamePage.Visible = false
    Home.Visible = true

    Tween(
        Home,
        0.25,
        {
            Position = UDim2.fromOffset(0, 0)
        }
    )
end

local function ShowGame()
    Home.Visible = false
    GamePage.Visible = true

    Tween(
        GamePage,
        0.25,
        {
            Position = UDim2.fromOffset(0, 0)
        }
    )
end

--========================================
-- PLAY BUTTON
--========================================

PlayButton.MouseButton1Click:Connect(function()
    ShowGame()

    if not GameRunning then
        GameRunning = true
        GamePaused = false
        StatusLabel.Text = "RUNNING"
    else
        StatusLabel.Text =
            GamePaused and "PAUSED" or "RUNNING"
    end

    SaveGame()
end)

--========================================
-- MENU BUTTON
--========================================

MenuButton.MouseButton1Click:Connect(function()
    ShowHome()
end)

--========================================
-- BUTTON HOVER
--========================================

local function ButtonHover(button, normal, hover)
    button.MouseEnter:Connect(function()
        Tween(
            button,
            0.15,
            {
                BackgroundColor3 = hover
            }
        )
    end)

    button.MouseLeave:Connect(function()
        Tween(
            button,
            0.15,
            {
                BackgroundColor3 = normal
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
    MenuButton,
    CONFIG.Panel2,
    CONFIG.PurpleDark
)

ButtonHover(
    PauseButton,
    CONFIG.Panel2,
    CONFIG.PurpleDark
)

ButtonHover(
    MinimizeButton,
    CONFIG.Panel2,
    CONFIG.PurpleDark
)

ButtonHover(
    CloseButton,
    CONFIG.Panel2,
    Color3.fromRGB(110, 45, 75)
)

--========================================
-- MINIMIZE STATE
--========================================

local MiniBar = New("TextButton", {
    Name = "MiniBar",
    Size = UDim2.fromOffset(190, 46),
    Position = UDim2.new(0.5, -95, 0.5, -23),
    BackgroundColor3 = CONFIG.Panel,
    Text = "",
    AutoButtonColor = false,
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 100
}, Gui)

Corner(MiniBar, 14)
Stroke(MiniBar, CONFIG.PurpleDark, 1, 0.25)

--========================================
-- MINI LOGO
--========================================

local MiniLogo = New("Frame", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.fromOffset(10, 9),
    BackgroundColor3 = CONFIG.Panel2,
    BorderSizePixel = 0,
    ZIndex = 101
}, MiniBar)

Corner(MiniLogo, 9)

local MiniMoon = New("Frame", {
    Size = UDim2.fromOffset(15, 15),
    Position = UDim2.new(0.5, -7, 0.5, -7),
    BackgroundColor3 = Color3.fromRGB(191, 157, 255),
    BorderSizePixel = 0,
    ZIndex = 102
}, MiniLogo)

Corner(MiniMoon, 50)

local MiniCut = New("Frame", {
    Size = UDim2.fromOffset(14, 14),
    Position = UDim2.fromOffset(6, -2),
    BackgroundColor3 = CONFIG.Panel2,
    BorderSizePixel = 0,
    ZIndex = 103
}, MiniMoon)

Corner(MiniCut, 50)

local MiniTitle = Label(
    MiniBar,
    "LUNAR SNAKE",
    UDim2.fromOffset(120, 28),
    UDim2.fromOffset(48, 9),
    Enum.Font.GothamBold,
    13
)

MiniTitle.ZIndex = 102

--========================================
-- MINIMIZE FUNCTION
--========================================

local Minimized = false

local function Minimize()
    SaveGame()

    Minimized = true
    Holder.Visible = false
    MiniBar.Visible = true

    MiniBar.Size = UDim2.fromOffset(160, 40)

    Tween(
        MiniBar,
        0.25,
        {
            Size = UDim2.fromOffset(190, 46)
        }
    )
end

local function Restore()
    Minimized = false
    MiniBar.Visible = false
    Holder.Visible = true

    Holder.Size = UDim2.fromOffset(520, 430)
    Holder.Position = UDim2.new(0.5, -260, 0.5, -215)

    Tween(
        Holder,
        0.3,
        {
            Size = UDim2.fromOffset(570, 470),
            Position = UDim2.new(0.5, -285, 0.5, -235)
        }
    )

    if GameRunning then
        StatusLabel.Text =
            GamePaused and "PAUSED" or "RUNNING"
    end
end

MinimizeButton.MouseButton1Click:Connect(Minimize)
MiniBar.MouseButton1Click:Connect(Restore)

--========================================
-- CLOSE BUTTON
--========================================

CloseButton.MouseButton1Click:Connect(function()
    SaveGame()

    Tween(
        Holder,
        0.25,
        {
            Size = UDim2.fromOffset(520, 430),
            BackgroundTransparency = 1
        }
    ).Completed:Connect(function()
        Gui:Destroy()
    end)
end)

--========================================
-- INITIAL POSITION
--========================================

Holder.Size = UDim2.fromOffset(520, 430)
Holder.BackgroundTransparency = 1

Tween(
    Holder,
    0.35,
    {
        Size = UDim2.fromOffset(570, 470),
        BackgroundTransparency = 0
    },
    Enum.EasingStyle.Back
)

--========================================
-- INITIAL PAGE
--========================================

Home.Visible = true
GamePage.Visible = false

--========================================
-- END PART 1/3
--========================================

--========================================
-- LUNAR SNAKE
-- PART 2/3
-- GAMEPLAY / CONTROLS / PAUSE
--========================================

--========================================
-- GAME VARIABLES
--========================================

local MoveTimer = 0
local CurrentDirection = Direction
local WantedDirection = Direction

local TouchStart = nil

--========================================
-- DIRECTION CHECK
--========================================

local Opposite = {
    Up = "Down",
    Down = "Up",
    Left = "Right",
    Right = "Left"
}

local DirectionVector = {
    Up = Vector2.new(0, -1),
    Down = Vector2.new(0, 1),
    Left = Vector2.new(-1, 0),
    Right = Vector2.new(1, 0)
}

local function SetDirection(newDirection)
    if not DirectionVector[newDirection] then
        return
    end

    if Opposite[CurrentDirection] == newDirection then
        return
    end

    WantedDirection = newDirection
end

--========================================
-- MOBILE CONTROLS PANEL
--========================================

local ControlPanel = New("Frame", {
    Name = "ControlPanel",
    Size = UDim2.fromOffset(100, 220),
    Position = UDim2.fromOffset(440, 58),
    BackgroundColor3 = CONFIG.Panel,
    BorderSizePixel = 0,
    ZIndex = 15
}, GamePage)

Corner(ControlPanel, 14)
Stroke(ControlPanel, CONFIG.PurpleDark, 1, 0.4)

--========================================
-- CONTROL BUTTON CREATOR
--========================================

local function CreateControlButton(name, text, position)
    local button = New("TextButton", {
        Name = name,
        Size = UDim2.fromOffset(48, 48),
        Position = position,
        BackgroundColor3 = CONFIG.Panel2,
        Text = text,
        TextColor3 = CONFIG.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 20
    }, ControlPanel)

    Corner(button, 12)
    Stroke(button, CONFIG.PurpleDark, 1, 0.5)

    button.MouseEnter:Connect(function()
        Tween(
            button,
            0.12,
            {
                BackgroundColor3 = CONFIG.PurpleDark,
                Size = UDim2.fromOffset(51, 51)
            }
        )
    end)

    button.MouseLeave:Connect(function()
        Tween(
            button,
            0.12,
            {
                BackgroundColor3 = CONFIG.Panel2,
                Size = UDim2.fromOffset(48, 48)
            }
        )
    end)

    return button
end

--========================================
-- DIRECTION BUTTONS
--========================================

local UpButton = CreateControlButton(
    "UpButton",
    "▲",
    UDim2.fromOffset(26, 10)
)

local LeftButton = CreateControlButton(
    "LeftButton",
    "◀",
    UDim2.fromOffset(0, 64)
)

local RightButton = CreateControlButton(
    "RightButton",
    "▶",
    UDim2.fromOffset(52, 64)
)

local DownButton = CreateControlButton(
    "DownButton",
    "▼",
    UDim2.fromOffset(26, 118)
)

--========================================
-- CONTROL LABEL
--========================================

local ControlText = Label(
    ControlPanel,
    "WASD / ARROWS",
    UDim2.new(1, -10, 0, 24),
    UDim2.fromOffset(5, 176),
    Enum.Font.GothamBold,
    9
)

ControlText.TextXAlignment = Enum.TextXAlignment.Center
ControlText.TextColor3 = CONFIG.Muted

--========================================
-- BUTTON EVENTS
--========================================

UpButton.MouseButton1Click:Connect(function()
    SetDirection("Up")
end)

DownButton.MouseButton1Click:Connect(function()
    SetDirection("Down")
end)

LeftButton.MouseButton1Click:Connect(function()
    SetDirection("Left")
end)

RightButton.MouseButton1Click:Connect(function()
    SetDirection("Right")
end)

--========================================
-- SCORE PANEL
--========================================

local ScorePanel = New("Frame", {
    Name = "ScorePanel",
    Size = UDim2.fromOffset(205, 55),
    Position = UDim2.fromOffset(0, 322),
    BackgroundColor3 = CONFIG.Panel,
    BorderSizePixel = 0,
    ZIndex = 15
}, GamePage)

Corner(ScorePanel, 12)
Stroke(ScorePanel, CONFIG.PurpleDark, 1, 0.45)

ScoreLabel.Parent = ScorePanel
ScoreLabel.Position = UDim2.fromOffset(12, 2)
ScoreLabel.Size = UDim2.fromOffset(180, 27)
ScoreLabel.ZIndex = 20

BestGameLabel.Parent = ScorePanel
BestGameLabel.Position = UDim2.fromOffset(12, 28)
BestGameLabel.Size = UDim2.fromOffset(180, 20)
BestGameLabel.ZIndex = 20

--========================================
-- GAME OVER PANEL
--========================================

local GameOverPanel = New("Frame", {
    Name = "GameOverPanel",
    Size = UDim2.fromOffset(390, 235),
    Position = UDim2.new(0.5, -195, 0.5, -118),
    BackgroundColor3 = CONFIG.Panel,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 80
}, GamePage)

Corner(GameOverPanel, 18)
Stroke(GameOverPanel, CONFIG.Purple, 1, 0.25)

local GameOverTitle = Label(
    GameOverPanel,
    "GAME OVER",
    UDim2.new(1, -30, 0, 40),
    UDim2.fromOffset(15, 25),
    Enum.Font.GothamBold,
    24
)

GameOverTitle.TextXAlignment = Enum.TextXAlignment.Center
GameOverTitle.ZIndex = 81

local FinalScoreLabel = Label(
    GameOverPanel,
    "SCORE  0",
    UDim2.new(1, -30, 0, 25),
    UDim2.fromOffset(15, 73),
    Enum.Font.GothamBold,
    13
)

FinalScoreLabel.TextXAlignment = Enum.TextXAlignment.Center
FinalScoreLabel.ZIndex = 81

local FinalBestLabel = Label(
    GameOverPanel,
    "BEST  0",
    UDim2.new(1, -30, 0, 25),
    UDim2.fromOffset(15, 98),
    Enum.Font.Gotham,
    11
)

FinalBestLabel.TextXAlignment = Enum.TextXAlignment.Center
FinalBestLabel.TextColor3 = CONFIG.Muted
FinalBestLabel.ZIndex = 81

--========================================
-- RESTART BUTTON
--========================================

local RestartButton = New("TextButton", {
    Size = UDim2.fromOffset(150, 42),
    Position = UDim2.fromOffset(25, 150),
    BackgroundColor3 = CONFIG.PurpleDark,
    Text = "RESTART",
    TextColor3 = CONFIG.Text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 82
}, GameOverPanel)

Corner(RestartButton, 11)

--========================================
-- GAME OVER MENU BUTTON
--========================================

local GameOverMenu = New("TextButton", {
    Size = UDim2.fromOffset(150, 42),
    Position = UDim2.fromOffset(215, 150),
    BackgroundColor3 = CONFIG.Panel2,
    Text = "MENU",
    TextColor3 = CONFIG.Text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 82
}, GameOverPanel)

Corner(GameOverMenu, 11)

--========================================
-- PAUSE OVERLAY
--========================================

local PauseOverlay = New("Frame", {
    Name = "PauseOverlay",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(5, 4, 10),
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 70
}, GamePage)

local PauseTitle = Label(
    PauseOverlay,
    "PAUSED",
    UDim2.new(1, 0, 0, 42),
    UDim2.fromOffset(0, 105),
    Enum.Font.GothamBold,
    26
)

PauseTitle.TextXAlignment = Enum.TextXAlignment.Center
PauseTitle.ZIndex = 71

local ResumeButton = New("TextButton", {
    Size = UDim2.fromOffset(150, 42),
    Position = UDim2.new(0.5, -75, 0, 165),
    BackgroundColor3 = CONFIG.PurpleDark,
    Text = "RESUME",
    TextColor3 = CONFIG.Text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 72
}, PauseOverlay)

Corner(ResumeButton, 11)

--========================================
-- PAUSE FUNCTION
--========================================

local function SetPaused(state)
    if not GameRunning then
        return
    end

    GamePaused = state
    Save.Paused = state

    PauseOverlay.Visible = state

    if state then
        StatusLabel.Text = "PAUSED"
    else
        StatusLabel.Text = "RUNNING"
    end

    SaveGame()
end

PauseButton.MouseButton1Click:Connect(function()
    SetPaused(not GamePaused)
end)

ResumeButton.MouseButton1Click:Connect(function()
    SetPaused(false)
end)

--========================================
-- FOOD GENERATION
--========================================

local function IsSnakePosition(x, y)
    for _, segment in ipairs(Snake) do
        if segment.X == x and segment.Y == y then
            return true
        end
    end

    return false
end

local function GenerateFood()
    local freeCells = {}

    for x = 1, CONFIG.Width do
        for y = 1, CONFIG.Height do
            if not IsSnakePosition(x, y) then
                table.insert(
                    freeCells,
                    {
                        X = x,
                        Y = y
                    }
                )
            end
        end
    end

    if #freeCells == 0 then
        return
    end

    local selected =
        freeCells[math.random(1, #freeCells)]

    Food = {
        X = selected.X,
        Y = selected.Y
    }

    DrawFood()
end

--========================================
-- RESET GAME
--========================================

local function ResetGame()
    Snake = {
        {X = 8, Y = 7},
        {X = 7, Y = 7},
        {X = 6, Y = 7},
        {X = 5, Y = 7}
    }

    Direction = "Right"
    WantedDirection = "Right"
    CurrentDirection = "Right"

    Score = 0
    GameRunning = true
    GamePaused = false

    GenerateFood()
    DrawSnake()
    DrawFood()
    UpdateScore()

    PauseOverlay.Visible = false
    GameOverPanel.Visible = false

    StatusLabel.Text = "RUNNING"

    SaveGame()
end

--========================================
-- COLLISION CHECK
--========================================

local function CheckCollision(head)
    if head.X < 1
        or head.X > CONFIG.Width
        or head.Y < 1
        or head.Y > CONFIG.Height then

        return true
    end

    for i = 2, #Snake do
        local segment = Snake[i]

        if segment.X == head.X
            and segment.Y == head.Y then

            return true
        end
    end

    return false
end

--========================================
-- GAME OVER
--========================================

local function EndGame()
    GameRunning = false
    GamePaused = false

    StatusLabel.Text = "GAME OVER"

    if Score > BestScore then
        BestScore = Score
    end

    FinalScoreLabel.Text =
        "SCORE  " .. tostring(Score)

    FinalBestLabel.Text =
        "BEST  " .. tostring(BestScore)

    UpdateScore()
    SaveGame()

    GameOverPanel.Visible = true
    GameOverPanel.Size = UDim2.fromOffset(350, 210)

    Tween(
        GameOverPanel,
        0.25,
        {
            Size = UDim2.fromOffset(390, 235)
        },
        Enum.EasingStyle.Back
    )
end

--========================================
-- MOVE SNAKE
--========================================

local function MoveSnake()
    if not GameRunning or GamePaused then
        return
    end

    if WantedDirection
        and Opposite[CurrentDirection] ~= WantedDirection then

        CurrentDirection = WantedDirection
        Direction = WantedDirection
    end

    local vector =
        DirectionVector[CurrentDirection]

    local head = Snake[1]

    local newHead = {
        X = head.X + vector.X,
        Y = head.Y + vector.Y
    }

    if CheckCollision(newHead) then
        EndGame()
        return
    end

    table.insert(
        Snake,
        1,
        newHead
    )

    if newHead.X == Food.X
        and newHead.Y == Food.Y then

        Score += 1

        if Score > BestScore then
            BestScore = Score
        end

        GenerateFood()
        UpdateScore()
    else
        table.remove(Snake)
    end

    DrawSnake()
    SaveGame()
end

--========================================
-- START / RESUME EXISTING GAME
--========================================

local function StartGame()
    if not GameRunning then
        ResetGame()
        return
    end

    GamePage.Visible = true
    Home.Visible = false

    PauseOverlay.Visible = GamePaused

    StatusLabel.Text =
        GamePaused and "PAUSED" or "RUNNING"

    UpdateScore()
    DrawSnake()
    DrawFood()
end

--========================================
-- RESTART
--========================================

RestartButton.MouseButton1Click:Connect(function()
    ResetGame()
end)

--========================================
-- GAME OVER MENU
--========================================

GameOverMenu.MouseButton1Click:Connect(function()
    GameOverPanel.Visible = false
    ShowHome()
end)

--========================================
-- PLAY BUTTON OVERRIDE
--========================================

PlayButton.MouseButton1Click:Connect(function()
    StartGame()
end)

--========================================
-- GAME LOOP
--========================================

RunService.Heartbeat:Connect(function(deltaTime)
    if not GameRunning or GamePaused then
        return
    end

    MoveTimer += deltaTime

    if MoveTimer >= CONFIG.GameSpeed then
        MoveTimer = 0
        MoveSnake()
    end
end)

--========================================
-- KEYBOARD CONTROLS
--========================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if not GamePage.Visible then
        return
    end

    if input.KeyCode == Enum.KeyCode.W
        or input.KeyCode == Enum.KeyCode.Up then

        SetDirection("Up")

    elseif input.KeyCode == Enum.KeyCode.S
        or input.KeyCode == Enum.KeyCode.Down then

        SetDirection("Down")

    elseif input.KeyCode == Enum.KeyCode.A
        or input.KeyCode == Enum.KeyCode.Left then

        SetDirection("Left")

    elseif input.KeyCode == Enum.KeyCode.D
        or input.KeyCode == Enum.KeyCode.Right then

        SetDirection("Right")

    elseif input.KeyCode == Enum.KeyCode.Space then

        SetPaused(not GamePaused)
    end
end)

--========================================
-- TOUCH SWIPE
--========================================

UserInputService.TouchStarted:Connect(function(touch)
    if GamePage.Visible then
        TouchStart = touch.Position
    end
end)

UserInputService.TouchEnded:Connect(function(touch)
    if not GamePage.Visible or not TouchStart then
        return
    end

    local difference =
        touch.Position - TouchStart

    TouchStart = nil

    if difference.Magnitude < 25 then
        return
    end

    if math.abs(difference.X) > math.abs(difference.Y) then
        if difference.X > 0 then
            SetDirection("Right")
        else
            SetDirection("Left")
        end
    else
        if difference.Y > 0 then
            SetDirection("Down")
        else
            SetDirection("Up")
        end
    end
end)

--========================================
-- BUTTON ANIMATIONS
--========================================

local function PressAnimation(button)
    button.MouseButton1Down:Connect(function()
        Tween(
            button,
            0.08,
            {
                Size = UDim2.fromOffset(
                    button.Size.X.Offset - 3,
                    button.Size.Y.Offset - 3
                )
            }
        )
    end)

    button.MouseButton1Up:Connect(function()
        Tween(
            button,
            0.08,
            {
                Size = UDim2.fromOffset(
                    button.Size.X.Offset + 3,
                    button.Size.Y.Offset + 3
                )
            }
        )
    end)
end

PressAnimation(UpButton)
PressAnimation(DownButton)
PressAnimation(LeftButton)
PressAnimation(RightButton)

--========================================
-- INITIAL RESTORE
--========================================

if Save.Running and Save.Snake and Save.Food then
    GameRunning = true
    GamePaused = Save.Paused or false

    StatusLabel.Text =
        GamePaused and "PAUSED" or "RUNNING"

    UpdateScore()
    DrawSnake()
    DrawFood()
end

--========================================
-- END PART 2/3
--========================================

--========================================
-- LUNAR SNAKE
-- PART 3/3
-- ANIMATIONS / DRAG / CLEANUP
--========================================

--========================================
-- DRAG SYSTEM
--========================================

local Dragging = false
local DragStart = nil
local StartPosition = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Holder.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not Dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local Delta = input.Position - DragStart

    Holder.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )
end)

--========================================
-- TOP BAR ANIMATION
--========================================

local function TopButtonHover(button)
    local originalSize = button.Size

    button.MouseEnter:Connect(function()
        Tween(
            button,
            0.15,
            {
                BackgroundColor3 = CONFIG.PurpleDark,
                Size = UDim2.fromOffset(
                    originalSize.X.Offset + 2,
                    originalSize.Y.Offset + 2
                )
            }
        )
    end)

    button.MouseLeave:Connect(function()
        Tween(
            button,
            0.15,
            {
                BackgroundColor3 = CONFIG.Panel2,
                Size = originalSize
            }
        )
    end)
end

TopButtonHover(MinimizeButton)
TopButtonHover(CloseButton)

--========================================
-- MINI BAR HOVER
--========================================

MiniBar.MouseEnter:Connect(function()
    Tween(
        MiniBar,
        0.15,
        {
            BackgroundColor3 = CONFIG.Panel2
        }
    )
end)

MiniBar.MouseLeave:Connect(function()
    Tween(
        MiniBar,
        0.15,
        {
            BackgroundColor3 = CONFIG.Panel
        }
    )
end)

--========================================
-- PAUSE ANIMATION
--========================================

PauseButton.MouseButton1Click:Connect(function()
    Tween(
        PauseButton,
        0.08,
        {
            Size = UDim2.fromOffset(38, 38)
        }
    )

    task.delay(0.08, function()
        if PauseButton.Parent then
            Tween(
                PauseButton,
                0.12,
                {
                    Size = UDim2.fromOffset(42, 42)
                }
            )
        end
    end)
end)

--========================================
-- RESUME HOVER
--========================================

ButtonHover(
    ResumeButton,
    CONFIG.PurpleDark,
    CONFIG.Purple
)

ButtonHover(
    RestartButton,
    CONFIG.PurpleDark,
    CONFIG.Purple
)

ButtonHover(
    GameOverMenu,
    CONFIG.Panel2,
    CONFIG.PurpleDark
)

--========================================
-- GAME OVER BUTTON ANIMATION
--========================================

RestartButton.MouseButton1Click:Connect(function()
    Tween(
        GameOverPanel,
        0.15,
        {
            BackgroundTransparency = 0.35
        }
    )

    task.delay(0.15, function()
        if GameOverPanel.Parent then
            GameOverPanel.BackgroundTransparency = 0
        end
    end)
end)

--========================================
-- PLAY BUTTON PRESS
--========================================

PlayButton.MouseButton1Down:Connect(function()
    Tween(
        PlayButton,
        0.08,
        {
            Size = UDim2.fromOffset(164, 40)
        }
    )
end)

PlayButton.MouseButton1Up:Connect(function()
    Tween(
        PlayButton,
        0.1,
        {
            Size = UDim2.fromOffset(170, 44)
        }
    )
end)

--========================================
-- MENU BUTTON PRESS
--========================================

MenuButton.MouseButton1Down:Connect(function()
    Tween(
        MenuButton,
        0.08,
        {
            Size = UDim2.fromOffset(91, 31)
        }
    )
end)

MenuButton.MouseButton1Up:Connect(function()
    Tween(
        MenuButton,
        0.1,
        {
            Size = UDim2.fromOffset(95, 34)
        }
    )
end)

--========================================
-- PAUSE OVERLAY ANIMATION
--========================================

local PauseVisibleConnection

PauseVisibleConnection = RunService.RenderStepped:Connect(function()
    if not PauseOverlay.Parent then
        PauseVisibleConnection:Disconnect()
        return
    end

    if PauseOverlay.Visible then
        PauseTitle.TextTransparency = 0
        ResumeButton.TextTransparency = 0
    end
end)

--========================================
-- GAME PAGE ENTRY
--========================================

GamePage:GetPropertyChangedSignal("Visible"):Connect(function()
    if GamePage.Visible then
        GamePage.Position = UDim2.fromOffset(18, 0)

        Tween(
            GamePage,
            0.25,
            {
                Position = UDim2.fromOffset(0, 0)
            },
            Enum.EasingStyle.Quart
        )
    end
end)

--========================================
-- HOME PAGE ENTRY
--========================================

Home:GetPropertyChangedSignal("Visible"):Connect(function()
    if Home.Visible then
        Home.Position = UDim2.fromOffset(-18, 0)

        Tween(
            Home,
            0.25,
            {
                Position = UDim2.fromOffset(0, 0)
            },
            Enum.EasingStyle.Quart
        )
    end
end)

--========================================
-- MINIMIZE ANIMATION
--========================================

MinimizeButton.MouseButton1Click:Connect(function()
    SaveGame()

    local shrinkTween = Tween(
        Holder,
        0.22,
        {
            Size = UDim2.fromOffset(500, 410),
            BackgroundTransparency = 0.15
        },
        Enum.EasingStyle.Quad
    )

    shrinkTween.Completed:Connect(function()
        if Holder.Parent then
            Holder.Visible = false
            MiniBar.Visible = true

            MiniBar.Size = UDim2.fromOffset(160, 40)

            Tween(
                MiniBar,
                0.25,
                {
                    Size = UDim2.fromOffset(190, 46)
                },
                Enum.EasingStyle.Back
            )
        end
    end)
end)

--========================================
-- RESTORE ANIMATION
--========================================

MiniBar.MouseButton1Click:Connect(function()
    SaveGame()

    MiniBar.Visible = false
    Holder.Visible = true

    Holder.Size = UDim2.fromOffset(500, 410)
    Holder.BackgroundTransparency = 0.15

    Tween(
        Holder,
        0.3,
        {
            Size = UDim2.fromOffset(570, 470),
            BackgroundTransparency = 0
        },
        Enum.EasingStyle.Back
    )
end)

--========================================
-- SAVE BEFORE GUI REMOVAL
--========================================

Gui.Destroying:Connect(function()
    SaveGame()
end)

--========================================
-- KEEP SCORE UPDATED
--========================================

RunService.RenderStepped:Connect(function()
    if not Gui.Parent then
        return
    end

    if BestScore > Save.BestScore then
        Save.BestScore = BestScore
    end

    if Score ~= Save.Score and GameRunning then
        Save.Score = Score
    end
end)

--========================================
-- FINAL RESTORE
--========================================

BestLabel.Text = tostring(BestScore)
ScoreLabel.Text = "SCORE  " .. tostring(Score)
BestGameLabel.Text = "BEST  " .. tostring(BestScore)

if GameRunning then
    GamePage.Visible = true
    Home.Visible = false

    PauseOverlay.Visible = GamePaused

    StatusLabel.Text =
        GamePaused and "PAUSED" or "RUNNING"
else
    GamePage.Visible = false
    Home.Visible = true
end

--========================================
-- FINAL OPEN ANIMATION
--========================================

task.delay(0.05, function()
    if Holder.Parent then
        Holder.Size = UDim2.fromOffset(520, 430)
        Holder.BackgroundTransparency = 1

        Tween(
            Holder,
            0.4,
            {
                Size = UDim2.fromOffset(570, 470),
                BackgroundTransparency = 0
            },
            Enum.EasingStyle.Back
        )
    end
end)

--========================================
-- LUNAR SNAKE READY
--========================================

print("Lunar Snake loaded successfully.")
print("Best Score:", BestScore)
print("Current Score:", Score)

--========================================
-- END PART 3/3
--========================================
