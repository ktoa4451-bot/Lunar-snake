--//====================================================//
--//                  LUNAR SNAKE                      //
--//                    PART 1/3                       //
--//====================================================//

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--//====================================================//
--//                     CONFIG                         //
--//====================================================//

local Config = {
    Width = 18,
    Height = 14,
    CellSize = 24,

    GameSpeed = 0.13,

    Background = Color3.fromRGB(7, 7, 14),
    Panel = Color3.fromRGB(13, 13, 25),
    Panel2 = Color3.fromRGB(20, 18, 35),

    Accent = Color3.fromRGB(145, 65, 255),
    Accent2 = Color3.fromRGB(190, 100, 255),

    Text = Color3.fromRGB(245, 245, 255),
    Muted = Color3.fromRGB(145, 140, 165),

    Snake = Color3.fromRGB(170, 75, 255),
    SnakeHead = Color3.fromRGB(205, 120, 255),
    Food = Color3.fromRGB(255, 75, 120)
}

--//====================================================//
--//                     HELPERS                        //
--//====================================================//

local function New(Class, Parent, Properties)
    local Object = Instance.new(Class)

    for Property, Value in pairs(Properties or {}) do
        pcall(function()
            Object[Property] = Value
        end)
    end

    Object.Parent = Parent

    return Object
end

local function Corner(Parent, Radius)
    return New("UICorner", Parent, {
        CornerRadius = UDim.new(0, Radius or 10)
    })
end

local function Stroke(Parent, Color, Thickness)
    return New("UIStroke", Parent, {
        Color = Color or Config.Accent,
        Thickness = Thickness or 1,
        Transparency = 0.2
    })
end

local function Tween(Object, Time, Properties)
    if not Object then
        return
    end

    local Animation = TweenService:Create(
        Object,
        TweenInfo.new(
            Time or 0.25,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        Properties
    )

    Animation:Play()

    return Animation
end

local function Label(Parent, Text, Size, Position, TextSize, Color)
    return New("TextLabel", Parent, {
        Size = Size,
        Position = Position,

        BackgroundTransparency = 1,

        Text = Text,
        TextColor3 = Color or Config.Text,
        TextSize = TextSize or 14,

        Font = Enum.Font.GothamSemibold,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 20
    })
end

--//====================================================//
--//                    SCREEN GUI                     //
--//====================================================//

local Old = game:GetService("CoreGui"):FindFirstChild("LunarSnake")

if Old then
    Old:Destroy()
end

local Gui = New("ScreenGui", game:GetService("CoreGui"), {
    Name = "LunarSnake",

    ResetOnSpawn = false,
    IgnoreGuiInset = true,

    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

    DisplayOrder = 999999
})

--//====================================================//
--//                    MAIN HOLDER                    //
--//====================================================//

local Holder = New("Frame", Gui, {
    Size = UDim2.fromOffset(570, 470),

    Position = UDim2.new(
        0.5,
        -285,
        0.5,
        -235
    ),

    BackgroundColor3 = Config.Background,

    BorderSizePixel = 0,

    ZIndex = 1
})

Corner(Holder, 18)
Stroke(Holder, Config.Accent, 1)

--//====================================================//
--//                    BACKGROUND                     //
--//====================================================//

local Background = New("Frame", Holder, {
    Size = UDim2.fromScale(1, 1),

    BackgroundColor3 = Config.Background,

    BorderSizePixel = 0,

    ClipsDescendants = true,

    ZIndex = 1
})

Corner(Background, 18)

-- Purple glow lines

for i = 1, 7 do
    local Line = New("Frame", Background, {
        Size = UDim2.fromOffset(3, 650),

        Position = UDim2.new(
            -0.15 + (i * 0.18),
            0,
            -0.25,
            0
        ),

        Rotation = 25,

        BackgroundColor3 = Config.Accent,

        BackgroundTransparency = 0.91,

        BorderSizePixel = 0,

        ZIndex = 2
    })

    task.spawn(function()
        local Start = Line.Position.X.Scale

        while Line.Parent do
            local Offset = math.sin(os.clock() * 0.7 + i) * 0.06

            Line.Position = UDim2.new(
                Start + Offset,
                0,
                -0.25,
                0
            )

            task.wait(0.03)
        end
    end)
end

--//====================================================//
--//                      TOP BAR                     //
--//====================================================//

local TopBar = New("Frame", Holder, {
    Size = UDim2.new(1, -16, 0, 58),

    Position = UDim2.fromOffset(8, 8),

    BackgroundColor3 = Config.Panel,

    BorderSizePixel = 0,

    ZIndex = 10
})

Corner(TopBar, 13)
Stroke(TopBar, Config.Accent, 1)

-- Moon logo

local Logo = New("TextLabel", TopBar, {
    Size = UDim2.fromOffset(42, 42),

    Position = UDim2.fromOffset(8, 8),

    BackgroundColor3 = Config.Accent,

    BackgroundTransparency = 0.1,

    BorderSizePixel = 0,

    Text = "☾",

    TextColor3 = Config.Text,

    TextSize = 27,

    Font = Enum.Font.GothamBold,

    TextXAlignment = Enum.TextXAlignment.Center,

    TextYAlignment = Enum.TextYAlignment.Center,

    ZIndex = 20
})

Corner(Logo, 12)

-- Title

Label(
    TopBar,
    "LUNAR SNAKE",
    UDim2.fromOffset(220, 25),
    UDim2.fromOffset(60, 7),
    17,
    Config.Text
)

Label(
    TopBar,
    "CLASSIC SNAKE GAME",
    UDim2.fromOffset(220, 20),
    UDim2.fromOffset(61, 29),
    10,
    Config.Muted
)

-- Score

local ScoreLabel = Label(
    TopBar,
    "SCORE  0",
    UDim2.fromOffset(110, 40),
    UDim2.new(1, -230, 0, 9),
    12,
    Config.Text
)

ScoreLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Close

local CloseButton = New("TextButton", TopBar, {
    Size = UDim2.fromOffset(40, 40),

    Position = UDim2.new(1, -48, 0, 9),

    BackgroundColor3 = Config.Panel2,

    BorderSizePixel = 0,

    Text = "×",

    TextColor3 = Config.Text,

    TextSize = 25,

    Font = Enum.Font.GothamMedium,

    AutoButtonColor = false,

    ZIndex = 30
})

Corner(CloseButton, 11)

--//====================================================//
--//                  CONTENT AREA                    //
--//====================================================//

local Content = New("Frame", Holder, {
    Size = UDim2.new(1, -20, 1, -82),

    Position = UDim2.fromOffset(10, 72),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ZIndex = 5
})

--//====================================================//
--//                   HOME PAGE                      //
--//====================================================//

local Home = New("Frame", Content, {
    Size = UDim2.fromScale(1, 1),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ZIndex = 5
})

-- Game card

local GameCard = New("Frame", Home, {
    Size = UDim2.new(1, -20, 0, 180),

    Position = UDim2.fromOffset(10, 10),

    BackgroundColor3 = Config.Panel,

    BorderSizePixel = 0,

    ZIndex = 6
})

Corner(GameCard, 16)
Stroke(GameCard, Config.Accent, 1)

-- Snake icon

local SnakeIcon = Label(
    GameCard,
    "🐍",
    UDim2.fromOffset(110, 100),
    UDim2.fromOffset(20, 25),
    70,
    Config.Text
)

SnakeIcon.TextXAlignment = Enum.TextXAlignment.Center

-- Main title

local MainTitle = Label(
    GameCard,
    "LUNAR SNAKE",
    UDim2.new(1, -170, 0, 42),
    UDim2.fromOffset(145, 25),
    25,
    Config.Text
)

MainTitle.Font = Enum.Font.GothamBold

-- Description

Label(
    GameCard,
    "Classic Snake",
    UDim2.new(1, -170, 0, 25),
    UDim2.fromOffset(146, 67),
    12,
    Config.Muted
)

Label(
    GameCard,
    "Eat the food and grow.",
    UDim2.new(1, -170, 0, 25),
    UDim2.fromOffset(146, 90),
    11,
    Config.Muted
)

-- Play button

local PlayButton = New("TextButton", GameCard, {
    Size = UDim2.new(1, -175, 0, 42),

    Position = UDim2.fromOffset(145, 125),

    BackgroundColor3 = Config.Accent,

    BorderSizePixel = 0,

    Text = "▶  PLAY",

    TextColor3 = Config.Text,

    TextSize = 14,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 30
})

Corner(PlayButton, 11)

--//====================================================//
--//                   INFO CARDS                     //
--//====================================================//

local InfoHolder = New("Frame", Home, {
    Size = UDim2.new(1, -20, 0, 75),

    Position = UDim2.fromOffset(10, 202),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ZIndex = 5
})

local BestCard = New("Frame", InfoHolder, {
    Size = UDim2.new(0.48, 0, 1, 0),

    Position = UDim2.fromScale(0, 0),

    BackgroundColor3 = Config.Panel,

    BorderSizePixel = 0,

    ZIndex = 6
})

Corner(BestCard, 12)
Stroke(BestCard, Config.Accent, 1)

Label(
    BestCard,
    "BEST SCORE",
    UDim2.new(1, -20, 0, 25),
    UDim2.fromOffset(10, 7),
    10,
    Config.Muted
)

local BestLabel = Label(
    BestCard,
    "0",
    UDim2.new(1, -20, 0, 35),
    UDim2.fromOffset(10, 30),
    20,
    Config.Text
)

BestLabel.Font = Enum.Font.GothamBold

local ModeCard = New("Frame", InfoHolder, {
    Size = UDim2.new(0.48, 0, 1, 0),

    Position = UDim2.new(0.52, 0, 0, 0),

    BackgroundColor3 = Config.Panel,

    BorderSizePixel = 0,

    ZIndex = 6
})

Corner(ModeCard, 12)
Stroke(ModeCard, Config.Accent, 1)

Label(
    ModeCard,
    "MODE",
    UDim2.new(1, -20, 0, 25),
    UDim2.fromOffset(10, 7),
    10,
    Config.Muted
)

Label(
    ModeCard,
    "CLASSIC",
    UDim2.new(1, -20, 0, 35),
    UDim2.fromOffset(10, 30),
    15,
    Config.Text
)

--//====================================================//
--//                    GAME PAGE                     //
--//====================================================//

local GamePage = New("Frame", Content, {
    Size = UDim2.fromScale(1, 1),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    Visible = false,

    ZIndex = 5
})

-- Game board

local BoardWidth = Config.Width * Config.CellSize
local BoardHeight = Config.Height * Config.CellSize

local Board = New("Frame", GamePage, {
    Size = UDim2.fromOffset(
        BoardWidth,
        BoardHeight
    ),

    Position = UDim2.new(
        0.5,
        -(BoardWidth / 2),
        0,
        8
    ),

    BackgroundColor3 = Color3.fromRGB(5, 5, 11),

    BorderSizePixel = 0,

    ClipsDescendants = true,

    ZIndex = 10
})

Corner(Board, 12)
Stroke(Board, Config.Accent, 1)

-- Grid

for X = 1, Config.Width - 1 do
    New("Frame", Board, {
        Size = UDim2.new(
            0,
            1,
            1,
            0
        ),

        Position = UDim2.fromOffset(
            X * Config.CellSize,
            0
        ),

        BackgroundColor3 = Config.Accent,

        BackgroundTransparency = 0.94,

        BorderSizePixel = 0,

        ZIndex = 11
    })
end

for Y = 1, Config.Height - 1 do
    New("Frame", Board, {
        Size = UDim2.new(
            1,
            0,
            0,
            1
        ),

        Position = UDim2.fromOffset(
            0,
            Y * Config.CellSize
        ),

        BackgroundColor3 = Config.Accent,

        BackgroundTransparency = 0.94,

        BorderSizePixel = 0,

        ZIndex = 11
    })
end

-- Snake container

local SnakeContainer = New("Frame", Board, {
    Size = UDim2.fromScale(1, 1),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ZIndex = 20
})

--//====================================================//
--//                  SNAKE DATA                       //
--//====================================================//

local Snake = {
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

local Direction = {
    X = 1,
    Y = 0
}

local NextDirection = {
    X = 1,
    Y = 0
}

local Food = {
    X = 13,
    Y = 7
}

local Score = 0
local BestScore = 0

local Running = false
local GameOver = false

--//====================================================//
--//                 DRAW SNAKE                        //
--//====================================================//

local function ClearSnake()
    for _, Object in ipairs(SnakeContainer:GetChildren()) do
        Object:Destroy()
    end
end

local function DrawSnake()
    ClearSnake()

    for Index, Segment in ipairs(Snake) do

        local IsHead = Index == 1

        local SegmentFrame = New(
            "Frame",
            SnakeContainer,
            {
                Size = UDim2.fromOffset(
                    Config.CellSize - 3,
                    Config.CellSize - 3
                ),

                Position = UDim2.fromOffset(
                    (Segment.X - 1) * Config.CellSize + 1,
                    (Segment.Y - 1) * Config.CellSize + 1
                ),

                BackgroundColor3 =
                    IsHead
                    and Config.SnakeHead
                    or Config.Snake,

                BorderSizePixel = 0,

                ZIndex = 22
            }
        )

        Corner(
            SegmentFrame,
            IsHead and 8 or 6
        )
    end
end

--//====================================================//
--//                    FOOD                          //
--//====================================================//

local FoodObject = New("TextLabel", Board, {
    Size = UDim2.fromOffset(
        Config.CellSize,
        Config.CellSize
    ),

    BackgroundTransparency = 1,

    Text = "●",

    TextColor3 = Config.Food,

    TextSize = 19,

    Font = Enum.Font.GothamBold,

    TextXAlignment = Enum.TextXAlignment.Center,

    TextYAlignment = Enum.TextYAlignment.Center,

    ZIndex = 21
})

local function DrawFood()
    FoodObject.Position = UDim2.fromOffset(
        (Food.X - 1) * Config.CellSize,
        (Food.Y - 1) * Config.CellSize
    )
end

-- Initial draw

DrawSnake()
DrawFood()

--//====================================================//
--//                  PAGE SWITCH                     //
--//====================================================//

local function OpenGame()
    if Running then
        return
    end

    Home.Visible = false
    GamePage.Visible = true

    Tween(
        GamePage,
        0.25,
        {
            BackgroundTransparency = 0
        }
    )
end

local function OpenHome()
    Running = false
    Home.Visible = true
    GamePage.Visible = false
end

-- Play

PlayButton.MouseButton1Click:Connect(function()
    OpenGame()
end)

-- Close

CloseButton.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

-- Hover effects

PlayButton.MouseEnter:Connect(function()
    Tween(
        PlayButton,
        0.15,
        {
            BackgroundColor3 = Config.Accent2
        }
    )
end)

PlayButton.MouseLeave:Connect(function()
    Tween(
        PlayButton,
        0.15,
        {
            BackgroundColor3 = Config.Accent
        }
    )
end)

--//====================================================//
--//                KEYBOARD CONTROL                   //
--//====================================================//

UserInputService.InputBegan:Connect(function(Input, Processed)

    if Processed then
        return
    end

    if not Running then
        return
    end

    if Input.KeyCode == Enum.KeyCode.W
        or Input.KeyCode == Enum.KeyCode.Up then

        if Direction.Y ~= 1 then
            NextDirection = {
                X = 0,
                Y = -1
            }
        end

    elseif Input.KeyCode == Enum.KeyCode.S
        or Input.KeyCode == Enum.KeyCode.Down then

        if Direction.Y ~= -1 then
            NextDirection = {
                X = 0,
                Y = 1
            }
        end

    elseif Input.KeyCode == Enum.KeyCode.A
        or Input.KeyCode == Enum.KeyCode.Left then

        if Direction.X ~= 1 then
            NextDirection = {
                X = -1,
                Y = 0
            }
        end

    elseif Input.KeyCode == Enum.KeyCode.D
        or Input.KeyCode == Enum.KeyCode.Right then

        if Direction.X ~= -1 then
            NextDirection = {
                X = 1,
                Y = 0
            }
        end
    end
end)

--//====================================================//
--//                 END PART 1/3                      //
--////====================================================//

--//====================================================//
--//                  LUNAR SNAKE                      //
--//                    PART 2/3                       //
--//             GAMEPLAY / CONTROLS / SCORE           //
--//====================================================//


--//====================================================//
--//                  GAME VARIABLES                   //
--//====================================================//

local GameRunning = false
local GamePaused = false
local CurrentScore = 0
local LocalBestScore = 0

local MoveTimer = 0

local CurrentDirection = {
    X = 1,
    Y = 0
}

local WantedDirection = {
    X = 1,
    Y = 0
}


--//====================================================//
--//                 BOARD POSITION                    //
--//====================================================//

-- Move the board to the left so mobile controls
-- have their own separate area.

Board.Position = UDim2.fromOffset(0, 8)


--//====================================================//
--//                 CONTROL PANEL                    //
--//====================================================//

local ControlPanel = New("Frame", GamePage, {
    Size = UDim2.fromOffset(92, 335),

    Position = UDim2.new(
        1,
        -92,
        0,
        8
    ),

    BackgroundColor3 = Config.Panel,

    BorderSizePixel = 0,

    ZIndex = 25
})

Corner(ControlPanel, 14)
Stroke(ControlPanel, Config.Accent, 1)


--//====================================================//
--//                  PAUSE BUTTON                     //
--//====================================================//

local PauseButton = New("TextButton", ControlPanel, {
    Size = UDim2.fromOffset(48, 40),

    Position = UDim2.new(
        0.5,
        -24,
        0,
        10
    ),

    BackgroundColor3 = Config.Panel2,

    BorderSizePixel = 0,

    Text = "Ⅱ",

    TextColor3 = Config.Text,

    TextSize = 20,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 30
})

Corner(PauseButton, 11)
Stroke(PauseButton, Config.Accent, 1)


--//====================================================//
--//                 DIRECTION BUTTON                  //
--//====================================================//

local function CreateDirectionButton(
    Text,
    Position
)
    local Button = New("TextButton", ControlPanel, {
        Size = UDim2.fromOffset(42, 42),

        Position = Position,

        BackgroundColor3 = Config.Panel2,

        BorderSizePixel = 0,

        Text = Text,

        TextColor3 = Config.Text,

        TextSize = 20,

        Font = Enum.Font.GothamBold,

        AutoButtonColor = false,

        ZIndex = 30
    })

    Corner(Button, 11)
    Stroke(Button, Config.Accent, 1)

    Button.MouseEnter:Connect(function()
        Tween(
            Button,
            0.12,
            {
                BackgroundColor3 = Config.Accent
            }
        )
    end)

    Button.MouseLeave:Connect(function()
        Tween(
            Button,
            0.12,
            {
                BackgroundColor3 = Config.Panel2
            }
        )
    end)

    return Button
end


--//====================================================//
--//              MOBILE DIRECTION BUTTONS             //
--//====================================================//

local UpButton = CreateDirectionButton(
    "▲",
    UDim2.new(
        0.5,
        -21,
        0,
        65
    )
)

local LeftButton = CreateDirectionButton(
    "◀",
    UDim2.new(
        0.5,
        -44,
        0,
        112
    )
)

local RightButton = CreateDirectionButton(
    "▶",
    UDim2.new(
        0.5,
        2,
        0,
        112
    )
)

local DownButton = CreateDirectionButton(
    "▼",
    UDim2.new(
        0.5,
        -21,
        0,
        159
    )
)


--//====================================================//
--//                  CONTROL LABEL                   //
--//====================================================//

local ControlLabel = Label(
    ControlPanel,
    "CONTROLS",
    UDim2.fromOffset(82, 20),
    UDim2.fromOffset(5, 212),
    9,
    Config.Muted
)

ControlLabel.TextXAlignment = Enum.TextXAlignment.Center


--//====================================================//
--//                   SCORE PANEL                    //
--//====================================================//

local ScorePanel = New("Frame", GamePage, {
    Size = UDim2.fromOffset(150, 30),

    Position = UDim2.fromOffset(0, 350),

    BackgroundColor3 = Config.Panel,

    BorderSizePixel = 0,

    ZIndex = 25
})

Corner(ScorePanel, 9)

local GameScoreLabel = Label(
    ScorePanel,
    "SCORE  0",
    UDim2.fromScale(1, 1),
    UDim2.fromOffset(0, 0),
    11,
    Config.Text
)

GameScoreLabel.TextXAlignment = Enum.TextXAlignment.Center


--//====================================================//
--//                    BEST SCORE                     //
--//====================================================//

local BestGameLabel = Label(
    GamePage,
    "BEST  0",
    UDim2.fromOffset(100, 30),
    UDim2.fromOffset(165, 350),
    11,
    Config.Muted
)

BestGameLabel.TextXAlignment = Enum.TextXAlignment.Center


--//====================================================//
--//                 GAME OVER PANEL                  //
--//====================================================//

local GameOverPanel = New("Frame", GamePage, {
    Size = UDim2.fromOffset(280, 205),

    Position = UDim2.new(
        0.5,
        -140,
        0.5,
        -103
    ),

    BackgroundColor3 = Config.Panel,

    BorderSizePixel = 0,

    Visible = false,

    ZIndex = 100
})

Corner(GameOverPanel, 16)
Stroke(GameOverPanel, Config.Accent, 2)


--//====================================================//
--//                 GAME OVER TITLE                  //
--//====================================================//

local GameOverTitle = Label(
    GameOverPanel,
    "GAME OVER",
    UDim2.new(1, -20, 0, 45),
    UDim2.fromOffset(10, 20),
    23,
    Config.Text
)

GameOverTitle.TextXAlignment = Enum.TextXAlignment.Center
GameOverTitle.Font = Enum.Font.GothamBold


--//====================================================//
--//                 FINAL SCORE                     //
--//====================================================//

local FinalScoreLabel = Label(
    GameOverPanel,
    "SCORE  0",
    UDim2.new(1, -20, 0, 25),
    UDim2.fromOffset(10, 65),
    12,
    Config.Muted
)

FinalScoreLabel.TextXAlignment = Enum.TextXAlignment.Center


local FinalBestLabel = Label(
    GameOverPanel,
    "BEST  0",
    UDim2.new(1, -20, 0, 25),
    UDim2.fromOffset(10, 90),
    12,
    Config.Muted
)

FinalBestLabel.TextXAlignment = Enum.TextXAlignment.Center


--//====================================================//
--//                  RESTART BUTTON                   //
--//====================================================//

local RestartButton = New("TextButton", GameOverPanel, {
    Size = UDim2.fromOffset(125, 38),

    Position = UDim2.fromOffset(15, 145),

    BackgroundColor3 = Config.Accent,

    BorderSizePixel = 0,

    Text = "↻  PLAY AGAIN",

    TextColor3 = Config.Text,

    TextSize = 11,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 110
})

Corner(RestartButton, 10)


--//====================================================//
--//                    HOME BUTTON                   //
--//====================================================//

local HomeButton = New("TextButton", GameOverPanel, {
    Size = UDim2.fromOffset(115, 38),

    Position = UDim2.fromOffset(150, 145),

    BackgroundColor3 = Config.Panel2,

    BorderSizePixel = 0,

    Text = "⌂  MENU",

    TextColor3 = Config.Text,

    TextSize = 11,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 110
})

Corner(HomeButton, 10)
Stroke(HomeButton, Config.Accent, 1)


--//====================================================//
--//                  PAUSE OVERLAY                    //
--//====================================================//

local PauseOverlay = New("Frame", GamePage, {
    Size = UDim2.fromOffset(280, 170),

    Position = UDim2.new(
        0.5,
        -140,
        0.5,
        -85
    ),

    BackgroundColor3 = Config.Panel,

    BorderSizePixel = 0,

    Visible = false,

    ZIndex = 90
})

Corner(PauseOverlay, 16)
Stroke(PauseOverlay, Config.Accent, 2)


--//====================================================//
--//                    PAUSE TITLE                   //
--//====================================================//

local PauseTitle = Label(
    PauseOverlay,
    "PAUSED",
    UDim2.new(1, -20, 0, 45),
    UDim2.fromOffset(10, 20),
    23,
    Config.Text
)

PauseTitle.TextXAlignment = Enum.TextXAlignment.Center
PauseTitle.Font = Enum.Font.GothamBold


--//====================================================//
--//                RESUME BUTTON                    //
--//====================================================//

local ResumeButton = New("TextButton", PauseOverlay, {
    Size = UDim2.fromOffset(120, 40),

    Position = UDim2.new(
        0.5,
        -60,
        1,
        -58
    ),

    BackgroundColor3 = Config.Accent,

    BorderSizePixel = 0,

    Text = "▶  RESUME",

    TextColor3 = Config.Text,

    TextSize = 12,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 100
})

Corner(ResumeButton, 10)


--//====================================================//
--//                  RANDOM FOOD                    //
--//====================================================//

local function IsSnakePosition(X, Y)
    for _, Segment in ipairs(Snake) do
        if Segment.X == X and Segment.Y == Y then
            return true
        end
    end

    return false
end


local function GenerateFood()

    local Attempts = 0

    repeat
        Food.X = math.random(
            1,
            Config.Width
        )

        Food.Y = math.random(
            1,
            Config.Height
        )

        Attempts += 1

        if Attempts > 200 then
            break
        end

    until not IsSnakePosition(
        Food.X,
        Food.Y
    )

    DrawFood()
end


--//====================================================//
--//                   RESET GAME                     //
--//====================================================//

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

    Direction = {
        X = 1,
        Y = 0
    }

    NextDirection = {
        X = 1,
        Y = 0
    }

    CurrentDirection = {
        X = 1,
        Y = 0
    }

    WantedDirection = {
        X = 1,
        Y = 0
    }

    Score = 0
    CurrentScore = 0

    GamePaused = false
    GameOver = false

    MoveTimer = 0

    PauseOverlay.Visible = false
    GameOverPanel.Visible = false

    ScoreLabel.Text = "SCORE  0"

    GameScoreLabel.Text = "SCORE  0"

    BestGameLabel.Text =
        "BEST  " .. tostring(LocalBestScore)

    GenerateFood()

    DrawSnake()
    DrawFood()
end


--//====================================================//
--//                 DIRECTION SYSTEM                 //
--//====================================================//

local function SetDirection(X, Y)

    if not GameRunning then
        return
    end

    if GamePaused then
        return
    end

    -- Prevent instant 180-degree turns

    if X == -CurrentDirection.X
        and Y == -CurrentDirection.Y then
        return
    end

    if X == -Direction.X
        and Y == -Direction.Y then
        return
    end

    WantedDirection = {
        X = X,
        Y = Y
    }

    NextDirection = {
        X = X,
        Y = Y
    }
end


--//====================================================//
--//              MOBILE BUTTON EVENTS                //
--//====================================================//

UpButton.MouseButton1Click:Connect(function()
    SetDirection(0, -1)
end)

DownButton.MouseButton1Click:Connect(function()
    SetDirection(0, 1)
end)

LeftButton.MouseButton1Click:Connect(function()
    SetDirection(-1, 0)
end)

RightButton.MouseButton1Click:Connect(function()
    SetDirection(1, 0)
end)


--//====================================================//
--//                  PAUSE SYSTEM                    //
--//====================================================//

local function SetPaused(State)

    if not GameRunning then
        return
    end

    GamePaused = State

    PauseOverlay.Visible = State

    if State then
        PauseButton.Text = "▶"
    else
        PauseButton.Text = "Ⅱ"
    end
end


PauseButton.MouseButton1Click:Connect(function()

    if GamePaused then
        SetPaused(false)
    else
        SetPaused(true)
    end

end)


ResumeButton.MouseButton1Click:Connect(function()
    SetPaused(false)
end)


--//====================================================//
--//                  GAME OVER                       //
--//====================================================//

local function EndGame()

    GameRunning = false
    Running = false

    GameOver = true
    GamePaused = false

    PauseOverlay.Visible = false

    FinalScoreLabel.Text =
        "SCORE  " .. tostring(CurrentScore)

    FinalBestLabel.Text =
        "BEST  " .. tostring(LocalBestScore)

    GameOverPanel.Visible = true

    GameOverPanel.Size =
        UDim2.fromOffset(240, 175)

    Tween(
        GameOverPanel,
        0.25,
        {
            Size = UDim2.fromOffset(280, 205)
        }
    )
end


--//====================================================//
--//                 COLLISION CHECK                  //
--//====================================================//

local function CheckCollision(HeadX, HeadY)

    -- Wall collision

    if HeadX < 1
        or HeadX > Config.Width
        or HeadY < 1
        or HeadY > Config.Height then

        return true
    end

    -- Self collision

    for Index = 2, #Snake do

        local Segment = Snake[Index]

        if Segment.X == HeadX
            and Segment.Y == HeadY then

            return true
        end
    end

    return false
end


--//====================================================//
--//                  MOVE SNAKE                      //
--//====================================================//

local function MoveSnake()

    Direction = {
        X = NextDirection.X,
        Y = NextDirection.Y
    }

    CurrentDirection = {
        X = Direction.X,
        Y = Direction.Y
    }

    local Head = Snake[1]

    local NewHead = {
        X = Head.X + Direction.X,
        Y = Head.Y + Direction.Y
    }

    if CheckCollision(
        NewHead.X,
        NewHead.Y
    ) then

        EndGame()

        return
    end

    table.insert(
        Snake,
        1,
        NewHead
    )

    -- Food eaten

    if NewHead.X == Food.X
        and NewHead.Y == Food.Y then

        CurrentScore += 1

        Score = CurrentScore

        if CurrentScore > LocalBestScore then
            LocalBestScore = CurrentScore
        end

        ScoreLabel.Text =
            "SCORE  " .. tostring(CurrentScore)

        GameScoreLabel.Text =
            "SCORE  " .. tostring(CurrentScore)

        BestGameLabel.Text =
            "BEST  " .. tostring(LocalBestScore)

        BestLabel.Text =
            tostring(LocalBestScore)

        GenerateFood()

    else
        table.remove(
            Snake,
            #Snake
        )
    end

    DrawSnake()
end


--//====================================================//
--//                   START GAME                     //
--//====================================================//

local function StartGame()

    ResetGame()

    GameRunning = true
    Running = true

    Home.Visible = false
    GamePage.Visible = true

    GameOverPanel.Visible = false
    PauseOverlay.Visible = false

    Tween(
        GamePage,
        0.22,
        {
            BackgroundTransparency = 0
        }
    )
end


--//====================================================//
--//                 PLAY BUTTON                     //
--//====================================================//

PlayButton.MouseButton1Click:Connect(function()
    StartGame()
end)


--//====================================================//
--//                RESTART BUTTON                   //
--//====================================================//

RestartButton.MouseButton1Click:Connect(function()
    StartGame()
end)


--//====================================================//
--//                   HOME BUTTON                   //
--//====================================================//

HomeButton.MouseButton1Click:Connect(function()

    GameRunning = false
    Running = false

    GamePaused = false
    GameOver = false

    GameOverPanel.Visible = false
    PauseOverlay.Visible = false

    Home.Visible = true
    GamePage.Visible = false

end)


--//====================================================//
--//                 BUTTON EFFECTS                   //
--//====================================================//

RestartButton.MouseEnter:Connect(function()

    Tween(
        RestartButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent2
        }
    )

end)


RestartButton.MouseLeave:Connect(function()

    Tween(
        RestartButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent
        }
    )

end)


HomeButton.MouseEnter:Connect(function()

    Tween(
        HomeButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent
        }
    )

end)


HomeButton.MouseLeave:Connect(function()

    Tween(
        HomeButton,
        0.12,
        {
            BackgroundColor3 = Config.Panel2
        }
    )

end)


--//====================================================//
--//                  GAME LOOP                       //
--//====================================================//

RunService.Heartbeat:Connect(function(DeltaTime)

    if not GameRunning then
        return
    end

    if GamePaused then
        return
    end

    if GameOver then
        return
    end

    MoveTimer += DeltaTime

    if MoveTimer >= Config.GameSpeed then

        MoveTimer = 0

        MoveSnake()
    end

end)


--//====================================================//
--//                 INITIAL STATE                    //
--//====================================================//

BestGameLabel.Text =
    "BEST  " .. tostring(LocalBestScore)

BestLabel.Text =
    tostring(LocalBestScore)

GameScoreLabel.Text =
    "SCORE  0"


--//====================================================//
--//                END OF PART 2/3                  //
--//====================================================//

--========================================
-- LUNAR SNAKE - PART 3/3
-- FINAL CONTROLS / ANIMATIONS / CLEANUP
--========================================


--========================================
-- BACK TO MENU BUTTON
--========================================

local BackButton = New("TextButton", GamePage, {
    Size = UDim2.fromOffset(100, 32),

    Position = UDim2.fromOffset(0, 388),

    BackgroundColor3 = Config.Panel2,

    BorderSizePixel = 0,

    Text = "← MENU",

    TextColor3 = Config.Text,

    TextSize = 11,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 30
})

Corner(BackButton, 9)
Stroke(BackButton, Config.Accent, 1)


--========================================
-- BACK BUTTON HOVER
--========================================

BackButton.MouseEnter:Connect(function()

    Tween(
        BackButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent
        }
    )

end)


BackButton.MouseLeave:Connect(function()

    Tween(
        BackButton,
        0.12,
        {
            BackgroundColor3 = Config.Panel2
        }
    )

end)


--========================================
-- BACK BUTTON EVENT
--========================================

BackButton.MouseButton1Click:Connect(function()

    GameRunning = false
    Running = false

    GamePaused = false
    GameOver = false

    PauseOverlay.Visible = false
    GameOverPanel.Visible = false

    GamePage.Visible = false
    Home.Visible = true

end)


--========================================
-- KEYBOARD INPUT
--========================================

UserInputService.InputBegan:Connect(function(
    Input,
    Processed
)

    if Processed then
        return
    end

    if not GameRunning then
        return
    end

    if GamePaused then
        return
    end

    if GameOver then
        return
    end

    local Key = Input.KeyCode

    if Key == Enum.KeyCode.W
        or Key == Enum.KeyCode.Up then

        SetDirection(
            0,
            -1
        )

    elseif Key == Enum.KeyCode.S
        or Key == Enum.KeyCode.Down then

        SetDirection(
            0,
            1
        )

    elseif Key == Enum.KeyCode.A
        or Key == Enum.KeyCode.Left then

        SetDirection(
            -1,
            0
        )

    elseif Key == Enum.KeyCode.D
        or Key == Enum.KeyCode.Right then

        SetDirection(
            1,
            0
        )

    elseif Key == Enum.KeyCode.Space then

        if GamePaused then
            SetPaused(false)
        else
            SetPaused(true)
        end

    end

end)


--========================================
-- TOUCH SWIPE CONTROL
--========================================

local TouchStart = nil

UserInputService.TouchStarted:Connect(function(
    Touch,
    Processed
)

    if Processed then
        return
    end

    if not GameRunning then
        return
    end

    TouchStart = Touch.Position

end)


UserInputService.TouchEnded:Connect(function(
    Touch,
    Processed
)

    if Processed then
        return
    end

    if not TouchStart then
        return
    end

    if not GameRunning then
        TouchStart = nil
        return
    end

    local Delta =
        Touch.Position - TouchStart

    TouchStart = nil

    if math.abs(Delta.X) < 25
        and math.abs(Delta.Y) < 25 then

        return
    end

    if math.abs(Delta.X) >
        math.abs(Delta.Y) then

        if Delta.X > 0 then

            SetDirection(
                1,
                0
            )

        else

            SetDirection(
                -1,
                0
            )

        end

    else

        if Delta.Y > 0 then

            SetDirection(
                0,
                1
            )

        else

            SetDirection(
                0,
                -1
            )

        end

    end

end)


--========================================
-- PAUSE BUTTON ANIMATION
--========================================

PauseButton.MouseEnter:Connect(function()

    Tween(
        PauseButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent
        }
    )

end)


PauseButton.MouseLeave:Connect(function()

    if GamePaused then
        return
    end

    Tween(
        PauseButton,
        0.12,
        {
            BackgroundColor3 = Config.Panel2
        }
    )

end)


--========================================
-- GAME OVER BUTTON ANIMATIONS
--========================================

RestartButton.MouseEnter:Connect(function()

    Tween(
        RestartButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent2
        }
    )

end)


RestartButton.MouseLeave:Connect(function()

    Tween(
        RestartButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent
        }
    )

end)


HomeButton.MouseEnter:Connect(function()

    Tween(
        HomeButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent
        }
    )

end)


HomeButton.MouseLeave:Connect(function()

    Tween(
        HomeButton,
        0.12,
        {
            BackgroundColor3 = Config.Panel2
        }
    )

end)


--========================================
-- CLOSE BUTTON ANIMATION
--========================================

CloseButton.MouseEnter:Connect(function()

    Tween(
        CloseButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent
        }
    )

end)


CloseButton.MouseLeave:Connect(function()

    Tween(
        CloseButton,
        0.12,
        {
            BackgroundColor3 = Config.Panel2
        }
    )

end)


--========================================
-- MINIMIZE BUTTON ANIMATION
--========================================

MinimizeButton.MouseEnter:Connect(function()

    Tween(
        MinimizeButton,
        0.12,
        {
            BackgroundColor3 = Config.Accent
        }
    )

end)


MinimizeButton.MouseLeave:Connect(function()

    Tween(
        MinimizeButton,
        0.12,
        {
            BackgroundColor3 = Config.Panel2
        }
    )

end)


--========================================
-- MINI BUTTON ANIMATION
--========================================

MiniButton.MouseEnter:Connect(function()

    Tween(
        MiniButton,
        0.12,
        {
            Size = UDim2.fromOffset(
                60,
                60
            ),

            BackgroundColor3 = Config.Accent
        }
    )

end)


MiniButton.MouseLeave:Connect(function()

    Tween(
        MiniButton,
        0.12,
        {
            Size = UDim2.fromOffset(
                56,
                56
            ),

            BackgroundColor3 = Config.Panel
        }
    )

end)


--========================================
-- OPEN ANIMATION
--========================================

Holder.Size = UDim2.fromOffset(
    500,
    410
)

Holder.BackgroundTransparency = 1

task.defer(function()

    Tween(
        Holder,
        0.35,
        {
            Size = UDim2.fromOffset(
                570,
                470
            ),

            BackgroundTransparency = 0
        }
    )

end)


--========================================
-- INITIAL GAME STATE
--========================================

Home.Visible = true
GamePage.Visible = false

GameOverPanel.Visible = false
PauseOverlay.Visible = false

MiniButton.Visible = false

GameRunning = false
Running = false

GamePaused = false
GameOver = false


--========================================
-- SAFE CLOSE CLEANUP
--========================================

Gui.Destroying:Connect(function()

    GameRunning = false
    Running = false

    GamePaused = true
    Config.Runtime.Destroyed = true

end)


--========================================
-- FINAL STATUS
--========================================

print(
    "[Lunar Snake] Loaded successfully."
)

print(
    "[Lunar Snake] Use PLAY to start."
)

print(
    "[Lunar Snake] WASD / Arrow Keys / Touch Swipe enabled."
)


--========================================
-- END OF LUNAR SNAKE
--========================================
