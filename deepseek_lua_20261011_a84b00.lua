local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local viewport = workspace.CurrentCamera.ViewportSize

local ConfigPath = "ZuperMing/Config/"
if not isfolder("ZuperMing") then makefolder("ZuperMing") end
if not isfolder("ZuperMing/Config") then makefolder("ZuperMing/Config") end

ConfigData = {}
Elements = {}
CURRENT_VERSION = nil

function SaveConfig(name)
    local fileName = ConfigPath .. (name or "Default") .. ".json"
    if writefile then
        ConfigData._version = CURRENT_VERSION
        writefile(fileName, HttpService:JSONEncode(ConfigData))
    end
end

function LoadConfigFromFile(name)
    local fileName = ConfigPath .. (name or "Default") .. ".json"
    if isfile and isfile(fileName) then
        local ok, result = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if ok and type(result) == "table" then
            ConfigData = result
            if LoadConfigElements then LoadConfigElements() end
            return true
        end
    end
    return false
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        local targetValue = ConfigData[key]
        if element.Set then
            if targetValue ~= nil then
                element:Set(targetValue)
            else
                if element.Type == "Toggle" then element:Set(false)
                elseif element.Type == "Slider" then element:Set(element.Default or 0)
                elseif element.Type == "Dropdown" then element:Set(element.Default or "")
                elseif element.Type == "Input" then element:Set("")
                end
            end
        end
    end
end

local Icons = {
    info       = "rbxassetid://10723415903",
    main       = "rbxassetid://10723407389",
    auto       = "rbxassetid://10734923214",
    shop       = "rbxassetid://10734952479",
    teleport   = "rbxassetid://10734886004",
    event      = "rbxassetid://10709789505",
    webhook    = "rbxassetid://10709775560",
    peformance = "rbxassetid://10734963400",
    misc       = "rbxassetid://10734972862",
    config     = "rbxassetid://10734950309",
    player     = "rbxassetid://10734972862",
}

local function isMobileDevice()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end
local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local sX = pxWidth / viewport.X
    local sY = pxHeight / viewport.Y
    if isMobile then
        if sX > 0.5 then sX = 0.5 end
        if sY > 0.3 then sY = 0.3 end
    end
    return UDim2.new(sX, 0, sY, 0)
end

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(
            StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
        )
        TweenService:Create(object, TweenInfo.new(0.2), { Position = pos }):Play()
    end
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then UpdatePos(input) end
    end)
end

function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Parent = Button
        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5
        Circle:TweenSizeAndPosition(
            UDim2.new(0, Size, 0, Size),
            UDim2.new(0.5, -Size/2, 0.5, -Size/2),
            "Out", "Quad", 0.5, false, nil
        )
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            wait(0.05)
        end
        Circle:Destroy()
    end)
end

local function GetExecutorName()
    local list = {
        "Solara","Delta","Xeno","Wave","Codex","Arceus X","Fluxus","Hydrogen",
        "Krnl","Synapse","ScriptWare","Vega","AWP","Swift","Evon","Cryptic",
        "Oxygen","Trigon","Valyse","Nihon","MacSploit","Sirhurt","Sentinel",
        "Ryu","Kiwi","Bunni","RbxStu","Severe","JJSploit",
    }
    local raw
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name then raw = name end
    end
    if not raw and getexecutorname then
        local ok, name = pcall(getexecutorname)
        if ok and name then raw = name end
    end
    if raw then
        for _, key in ipairs(list) do
            if string.find(string.lower(raw), string.lower(key)) then return key end
        end
        return raw
    end
    if getexploitlevel then return "Executor Lv." .. tostring(getexploitlevel()) end
    return "Unknown"
end

local ZuperMing = {}

function ZuperMing:MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title       = NotifyConfig.Title or "ZuperMing"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content     = NotifyConfig.Content or "Content"
    NotifyConfig.Color       = NotifyConfig.Color or Color3.fromRGB(55, 70, 255)
    NotifyConfig.Time        = NotifyConfig.Time or 0.5
    NotifyConfig.Delay       = NotifyConfig.Delay or 5

    local NotifyFunction = {}

    spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.ResetOnSpawn = false
            NotifyGui.Parent = CoreGui
        end
        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame")
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundTransparency = 1
            NotifyLayout.Position = UDim2.new(1, -20, 1, -20)
            NotifyLayout.Size = UDim2.new(0, 280, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(v,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 8) * Count)) }
                    ):Play()
                    Count = Count + 1
                end
            end)
        end
        local NotifyPosHeigh = 0
        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 8
        end

        local CalculationWidth = 240
        local ContentBounds = TextService:GetTextSize(
            NotifyConfig.Content, 12, Enum.Font.Gotham,
            Vector2.new(CalculationWidth, 9999)
        )
        local TotalFrameHeight = 28 + ContentBounds.Y + 12
        if TotalFrameHeight < 50 then TotalFrameHeight = 50 end

        local NotifyFrame = Instance.new("Frame")
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Size = UDim2.new(1, 0, 0, TotalFrameHeight)
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

        local NotifyFrameReal = Instance.new("Frame")
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 350, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Parent = NotifyFrame

        local NC = Instance.new("UICorner")
        NC.CornerRadius = UDim.new(0, 6)
        NC.Parent = NotifyFrameReal

        local Top = Instance.new("Frame")
        Top.Name = "Top"
        Top.BackgroundTransparency = 1
        Top.Size = UDim2.new(1, 0, 0, 28)
        Top.Parent = NotifyFrameReal

        local NTitle = Instance.new("TextLabel")
        NTitle.Font = Enum.Font.GothamBold
        NTitle.Text = NotifyConfig.Title
        NTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        NTitle.TextSize = 12
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.BackgroundTransparency = 1
        NTitle.AutomaticSize = Enum.AutomaticSize.X
        NTitle.Size = UDim2.new(0, 0, 1, 0)
        NTitle.Position = UDim2.new(0, 8, 0, 0)
        NTitle.Parent = Top

        local NDesc = Instance.new("TextLabel")
        NDesc.Font = Enum.Font.GothamBold
        NDesc.Text = NotifyConfig.Description
        NDesc.TextColor3 = NotifyConfig.Color
        NDesc.TextSize = 12
        NDesc.TextXAlignment = Enum.TextXAlignment.Left
        NDesc.BackgroundTransparency = 1
        NDesc.AutomaticSize = Enum.AutomaticSize.X
        NDesc.Size = UDim2.new(0, 0, 1, 0)
        NDesc.Parent = Top
        task.defer(function()
            NDesc.Position = UDim2.new(0, NTitle.AbsoluteSize.X + 10, 0, 0)
        end)

        local NClose = Instance.new("TextButton")
        NClose.Name = "Close"
        NClose.Text = ""
        NClose.BackgroundTransparency = 1
        NClose.AnchorPoint = Vector2.new(1, 0.5)
        NClose.Position = UDim2.new(1, -5, 0.5, 0)
        NClose.Size = UDim2.new(0, 20, 0, 20)
        NClose.Parent = Top

        local NCloseImg = Instance.new("ImageLabel")
        NCloseImg.Image = "rbxassetid://9886659671"
        NCloseImg.BackgroundTransparency = 1
        NCloseImg.AnchorPoint = Vector2.new(0.5, 0.5)
        NCloseImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        NCloseImg.Size = UDim2.new(0.6, 0, 0.6, 0)
        NCloseImg.Parent = NClose

        local NContent = Instance.new("TextLabel")
        NContent.Name = "Content"
        NContent.Font = Enum.Font.Gotham
        NContent.Text = NotifyConfig.Content
        NContent.TextColor3 = Color3.fromRGB(180, 180, 180)
        NContent.TextSize = 12
        NContent.BackgroundTransparency = 1
        NContent.TextXAlignment = Enum.TextXAlignment.Left
        NContent.TextYAlignment = Enum.TextYAlignment.Top
        NContent.TextWrapped = true
        NContent.AutomaticSize = Enum.AutomaticSize.Y
        NContent.Position = UDim2.new(0, 8, 0, 28)
        NContent.Size = UDim2.new(1, -16, 0, 0)
        NContent.Parent = NotifyFrameReal

        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then return false end
            waitbruh = true
            TweenService:Create(NotifyFrameReal,
                TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.In),
                { Position = UDim2.new(0, 350, 0, 0) }
            ):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end
        NClose.Activated:Connect(function() NotifyFunction:Close() end)
        TweenService:Create(NotifyFrameReal,
            TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 0, 0, 0) }
        ):Play()
        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    return NotifyFunction
end

function notif(msg, delay, color, title, desc)
    return ZuperMing:MakeNotify({
        Title = title or "ZuperMing",
        Description = desc or "Notification",
        Content = msg or "Content",
        Color = color or Color3.fromRGB(232, 145, 234),
        Delay = delay or 4
    })
end

-- =========================================================
-- BAGIAN UTAMA WINDOW (TOTAL REWRITE)
-- =========================================================
function ZuperMing:Window(GuiConfig)
    GuiConfig              = GuiConfig or {}
    GuiConfig.Title        = GuiConfig.Title or "ZuperMing"
    GuiConfig.GameName     = GuiConfig.GameName or "Game"
    GuiConfig.Icon         = GuiConfig.Icon or "rbxassetid://104396282819940"
    GuiConfig.LogoBg       = GuiConfig.LogoBg or ""
    GuiConfig.Color        = GuiConfig.Color or Color3.fromRGB(50, 100, 255)
    GuiConfig.Background   = GuiConfig.Background or Color3.fromRGB(15, 15, 20)
    GuiConfig.Premium      = GuiConfig.Premium or "Free"
    GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 60
    GuiConfig.ShowSearch   = (GuiConfig.ShowSearch ~= false)

    local executorName = GetExecutorName()

    -- === DIMENSI ===
    local TOP_H    = 50
    local BOTTOM_H = 40
    local SIDE_W   = GuiConfig["Tab Width"]

    local GuiFunc = {}

    -- === SCREEN GUI ===
    local ZuperMingb = Instance.new("ScreenGui")
    ZuperMingb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ZuperMingb.Name = "ZuperMingb"
    ZuperMingb.ResetOnSpawn = false
    ZuperMingb.Parent = CoreGui

    -- === SHADOW HOLDER ===
    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadowHolder.Size = UDim2.new(0, 640, 0, 400)
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = ZuperMingb

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.4
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.Parent = DropShadowHolder

    -- === MAIN FRAME ===
    local Main = Instance.new("Frame")
    Main.BackgroundColor3 = GuiConfig.Background
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(120, 10, 30)
    MainStroke.Thickness = 2
    MainStroke.Parent = Main

    -- Background Image (Optional)
    if GuiConfig.LogoBg ~= "" then
        local BGImg = Instance.new("ImageLabel")
        BGImg.Name = "BGImg"
        BGImg.Image = GuiConfig.LogoBg
        BGImg.BackgroundTransparency = 1
        BGImg.ImageTransparency = 0.9
        BGImg.ScaleType = Enum.ScaleType.Fit
        BGImg.AnchorPoint = Vector2.new(0.5, 0.5)
        BGImg.Position = UDim2.new(0.6, 0, 0.5, 0)
        BGImg.Size = UDim2.new(0.7, 0, 0.7, 0)
        BGImg.ZIndex = 0
        BGImg.Parent = Main
    end

    -- === HEADER (TOP BAR) ===
    local Top = Instance.new("Frame")
    Top.Name = "Top"
    Top.BackgroundTransparency = 1
    Top.Size = UDim2.new(1, 0, 0, TOP_H)
    Top.ZIndex = 5
    Top.Parent = Main

    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Name = "LogoIcon"
    LogoIcon.Parent = Top
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Position = UDim2.new(0, 12, 0.5, 0)
    LogoIcon.AnchorPoint = Vector2.new(0, 0.5)
    LogoIcon.Size = UDim2.new(0, 30, 0, 30)
    LogoIcon.Image = GuiConfig.Icon
    LogoIcon.ScaleType = Enum.ScaleType.Fit
    LogoIcon.ZIndex = 6

    local Title = Instance.new("TextLabel")
    Title.Font = Enum.Font.GothamBold
    Title.Text = GuiConfig.Title
    Title.TextColor3 = GuiConfig.Color
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 52, 0, 6)
    Title.Size = UDim2.new(0, 200, 0, 20)
    Title.ZIndex = 6
    Title.Parent = Top

    local GameName = Instance.new("TextLabel")
    GameName.Font = Enum.Font.GothamMedium
    GameName.Text = GuiConfig.GameName
    GameName.TextColor3 = Color3.fromRGB(180, 180, 190)
    GameName.TextSize = 12
    GameName.TextXAlignment = Enum.TextXAlignment.Left
    GameName.BackgroundTransparency = 1
    GameName.Position = UDim2.new(0, 52, 0, 26)
    GameName.Size = UDim2.new(0, 200, 0, 16)
    GameName.ZIndex = 6
    GameName.Parent = Top

    -- Search (Kanan header)
    if GuiConfig.ShowSearch then
        local SearchFrame = Instance.new("Frame")
        SearchFrame.Name = "SearchFrame"
        SearchFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        SearchFrame.BorderSizePixel = 0
        SearchFrame.Position = UDim2.new(0, 260, 0, 12)
        SearchFrame.Size = UDim2.new(0, 220, 0, 26)
        SearchFrame.ZIndex = 6
        SearchFrame.Parent = Top

        local SFC = Instance.new("UICorner")
        SFC.CornerRadius = UDim.new(1, 0)
        SFC.Parent = SearchFrame

        local SearchIcon = Instance.new("ImageLabel")
        SearchIcon.Image = "rbxassetid://3926305904"
        SearchIcon.ImageRectOffset = Vector2.new(964, 324)
        SearchIcon.ImageRectSize = Vector2.new(36, 36)
        SearchIcon.BackgroundTransparency = 1
        SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
        SearchIcon.Position = UDim2.new(0, 10, 0.5, 0)
        SearchIcon.Size = UDim2.new(0, 14, 0, 14)
        SearchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
        SearchIcon.ZIndex = 7
        SearchIcon.Parent = SearchFrame

        local SearchBox = Instance.new("TextBox")
        SearchBox.Font = Enum.Font.Gotham
        SearchBox.PlaceholderText = "Search"
        SearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
        SearchBox.Text = ""
        SearchBox.TextSize = 12
        SearchBox.TextColor3 = Color3.fromRGB(230, 230, 230)
        SearchBox.TextXAlignment = Enum.TextXAlignment.Left
        SearchBox.BackgroundTransparency = 1
        SearchBox.Position = UDim2.new(0, 30, 0, 0)
        SearchBox.Size = UDim2.new(1, -36, 1, 0)
        SearchBox.ClearTextOnFocus = false
        SearchBox.ZIndex = 7
        SearchBox.Parent = SearchFrame
    end

    -- Minimize button
    local Min = Instance.new("TextButton")
    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundTransparency = 1
    Min.Position = UDim2.new(1, -38, 0.5, 0)
    Min.Size = UDim2.new(0, 26, 0, 26)
    Min.Name = "Min"
    Min.ZIndex = 6
    Min.Parent = Top

    local MinIcon = Instance.new("ImageLabel")
    MinIcon.Image = "rbxassetid://9886659276"
    MinIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinIcon.BackgroundTransparency = 1
    MinIcon.ImageTransparency = 0.2
    MinIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinIcon.Size = UDim2.new(0, 12, 0, 12)
    MinIcon.ZIndex = 7
    MinIcon.Parent = Min

    -- Close button
    local Close = Instance.new("TextButton")
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundTransparency = 1
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 26, 0, 26)
    Close.Name = "Close"
    Close.ZIndex = 6
    Close.Parent = Top

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Image = "rbxassetid://9886659671"
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(0, 12, 0, 12)
    CloseIcon.ZIndex = 7
    CloseIcon.Parent = Close

    -- Garis Merah di bawah header
    local HeaderLine = Instance.new("Frame")
    HeaderLine.Name = "HeaderLine"
    HeaderLine.BackgroundColor3 = Color3.fromRGB(120, 10, 30)
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Position = UDim2.new(0, 0, 0, TOP_H)
    HeaderLine.Size = UDim2.new(1, 0, 0, 2)
    HeaderLine.ZIndex = 5
    HeaderLine.Parent = Main

    -- === SIDEBAR KIRI (ICON ONLY) ===
    local LayersTab = Instance.new("Frame")
    LayersTab.Name = "LayersTab"
    LayersTab.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    LayersTab.BackgroundTransparency = 0.4
    LayersTab.BorderSizePixel = 0
    LayersTab.Position = UDim2.new(0, 0, 0, TOP_H + 2)
    LayersTab.Size = UDim2.new(0, SIDE_W, 1, -(TOP_H + BOTTOM_H + 2))
    LayersTab.ZIndex = 4
    LayersTab.Parent = Main

    local ScrollTab = Instance.new("ScrollingFrame")
    ScrollTab.CanvasSize = UDim2.new(0, 0, 1.1, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundTransparency = 1
    ScrollTab.BorderSizePixel = 0
    ScrollTab.Size = UDim2.new(1, 0, 1, 0)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.Parent = LayersTab

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Parent = ScrollTab

    -- === PEMISAH VERTIKAL ===
    local VertSep = Instance.new("Frame")
    VertSep.Name = "VertSep"
    VertSep.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    VertSep.BorderSizePixel = 0
    VertSep.Position = UDim2.new(0, SIDE_W, 0, TOP_H + 2)
    VertSep.Size = UDim2.new(0, 1, 1, -(TOP_H + BOTTOM_H + 2))
    VertSep.ZIndex = 4
    VertSep.Parent = Main

    -- === PANEL KANAN (KONTEN) ===
    local Layers = Instance.new("Frame")
    Layers.Name = "Layers"
    Layers.BackgroundTransparency = 1
    Layers.BorderSizePixel = 0
    Layers.Position = UDim2.new(0, SIDE_W + 1, 0, TOP_H + 2)
    Layers.Size = UDim2.new(1, -(SIDE_W + 1), 1, -(TOP_H + BOTTOM_H + 2))
    Layers.ZIndex = 4
    Layers.Parent = Main

    local LayersFolder = Instance.new("Folder")
    LayersFolder.Name = "LayersFolder"
    LayersFolder.Parent = Layers

    local LayersPageLayout = Instance.new("UIPageLayout")
    LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LayersPageLayout.Name = "LayersPageLayout"
    LayersPageLayout.Parent = LayersFolder
    LayersPageLayout.TweenTime = 0.5
    LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
    LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad

    -- === FOOTER ===
    local FooterFrame = Instance.new("Frame")
    FooterFrame.Name = "FooterFrame"
    FooterFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    FooterFrame.BackgroundTransparency = 0.3
    FooterFrame.BorderSizePixel = 0
    FooterFrame.AnchorPoint = Vector2.new(0, 1)
    FooterFrame.Position = UDim2.new(0, 0, 1, 0)
    FooterFrame.Size = UDim2.new(1, 0, 0, BOTTOM_H)
    FooterFrame.ZIndex = 5
    FooterFrame.Parent = Main

    local FooterCorner = Instance.new("UICorner")
    FooterCorner.CornerRadius = UDim.new(0, 12)
    FooterCorner.Parent = FooterFrame

    -- Avatar kiri
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Name = "AvatarFrame"
    AvatarFrame.BackgroundTransparency = 1
    AvatarFrame.Position = UDim2.new(0, 10, 0.5, 0)
    AvatarFrame.AnchorPoint = Vector2.new(0, 0.5)
    AvatarFrame.Size = UDim2.new(0, 26, 0, 26)
    AvatarFrame.ZIndex = 6
    AvatarFrame.Parent = FooterFrame

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarFrame

    local Avatar = Instance.new("ImageLabel")
    Avatar.Name = "Avatar"
    Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Avatar.BorderSizePixel = 0
    Avatar.Size = UDim2.new(1, 0, 1, 0)
    Avatar.Image = ""
    Avatar.ZIndex = 7
    Avatar.Parent = AvatarFrame

    local AvatarImgCorner = Instance.new("UICorner")
    AvatarImgCorner.CornerRadius = UDim.new(1, 0)
    AvatarImgCorner.Parent = Avatar

    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        if ok and img then Avatar.Image = img end
    end)

    -- Welcome text
    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Name = "WelcomeLabel"
    WelcomeLabel.Font = Enum.Font.GothamMedium
    WelcomeLabel.Text = "Welcome, " .. LocalPlayer.DisplayName
    WelcomeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    WelcomeLabel.TextSize = 12
    WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 44, 0.5, 0)
    WelcomeLabel.AnchorPoint = Vector2.new(0, 0.5)
    WelcomeLabel.Size = UDim2.new(0, 180, 1, 0)
    WelcomeLabel.ZIndex = 6
    WelcomeLabel.Parent = FooterFrame

    -- Pills Container (Kanan)
    local PillsContainer = Instance.new("Frame")
    PillsContainer.Name = "PillsContainer"
    PillsContainer.BackgroundTransparency = 1
    PillsContainer.AnchorPoint = Vector2.new(1, 0.5)
    PillsContainer.Position = UDim2.new(1, -10, 0.5, 0)
    PillsContainer.Size = UDim2.new(0, 400, 1, 0)
    PillsContainer.ZIndex = 6
    PillsContainer.Parent = FooterFrame

    local PillsLayout = Instance.new("UIListLayout")
    PillsLayout.FillDirection = Enum.FillDirection.Horizontal
    PillsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    PillsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    PillsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PillsLayout.Padding = UDim.new(0, 5)
    PillsLayout.Parent = PillsContainer

    local function MakePill(name, order)
        local Pill = Instance.new("Frame")
        Pill.Name = name
        Pill.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        Pill.BorderSizePixel = 0
        Pill.LayoutOrder = order
        Pill.Size = UDim2.new(0, 60, 0, 22)
        Pill.ZIndex = 7
        Pill.Parent = PillsContainer

        local C = Instance.new("UICorner")
        C.CornerRadius = UDim.new(1, 0)
        C.Parent = Pill

        local L = Instance.new("TextLabel")
        L.Name = "Label"
        L.Font = Enum.Font.GothamMedium
        L.Text = ""
        L.TextColor3 = Color3.fromRGB(220, 220, 220)
        L.TextSize = 11
        L.BackgroundTransparency = 1
        L.Size = UDim2.new(1, -14, 1, 0)
        L.Position = UDim2.new(0, 7, 0, 0)
        L.TextXAlignment = Enum.TextXAlignment.Center
        L.ZIndex = 8
        L.Parent = Pill

        return Pill, L
    end

    local FPSChip, FPSText         = MakePill("FPS", 1)
    local PingChip, PingText       = MakePill("Ping", 2)
    local PremiumChip, PremiumText = MakePill("Premium", 3)
    local ExecChip, ExecText       = MakePill("Executor", 4)

    task.spawn(function()
        while ZuperMingb.Parent do
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            FPSText.Text = tostring(fps) .. " FPS"
            task.wait(0.5)
        end
    end)

    task.spawn(function()
        while ZuperMingb.Parent do
            local ok, ping = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            if ok and ping then
                PingText.Text = tostring(math.floor(ping)) .. " ms"
            else
                PingText.Text = "0 ms"
            end
            task.wait(1)
        end
    end)

    PremiumText.Text = GuiConfig.Premium
    ExecText.Text = executorName

    -- Auto Resize Pills
    for _, pill in ipairs(PillsContainer:GetChildren()) do
        if pill:IsA("Frame") then
            local lbl = pill:FindFirstChild("Label")
            if lbl then
                local bounds = TextService:GetTextSize(lbl.Text, 11, Enum.Font.GothamMedium, Vector2.new(1000, 22))
                pill.Size = UDim2.new(0, bounds.X + 18, 0, 22)
                lbl:GetPropertyChangedSignal("Text"):Connect(function()
                    local b = TextService:GetTextSize(lbl.Text, 11, Enum.Font.GothamMedium, Vector2.new(1000, 22))
                    pill.Size = UDim2.new(0, b.X + 18, 0, 22)
                end)
            end
        end
    end

    -- === MINIMIZE ICON ===
    local MinimizeIcon = Instance.new("ImageButton")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = ZuperMingb
    MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0)
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    MinimizeIcon.BorderSizePixel = 0
    MinimizeIcon.Position = UDim2.new(0.5, 0, 0, 20)
    MinimizeIcon.Size = UDim2.new(0, 56, 0, 56)
    MinimizeIcon.Image = GuiConfig.Icon
    MinimizeIcon.ScaleType = Enum.ScaleType.Fit
    MinimizeIcon.Visible = false
    MinimizeIcon.ZIndex = 100

    local MIC = Instance.new("UICorner")
    MIC.CornerRadius = UDim.new(0, 12)
    MIC.Parent = MinimizeIcon

    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
        MinimizeIcon.Visible = true
    end)

    MinimizeIcon.Activated:Connect(function()
        MinimizeIcon.Visible = false
        DropShadowHolder.Visible = true
    end)

    local dragging, dragStart, startPos
    MinimizeIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MinimizeIcon.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MinimizeIcon.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- === CLOSE DIALOG ===
    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.3
        Overlay.ZIndex = 50
        Overlay.Parent = DropShadowHolder

        local Dialog = Instance.new("Frame")
        Dialog.Size = UDim2.new(0, 300, 0, 150)
        Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
        Dialog.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
        Dialog.BorderSizePixel = 0
        Dialog.ZIndex = 51
        Dialog.Parent = Overlay
        Instance.new("UICorner", Dialog).CornerRadius = UDim.new(0, 8)

        local DTitle = Instance.new("TextLabel")
        DTitle.Size = UDim2.new(1, 0, 0, 40)
        DTitle.Position = UDim2.new(0, 0, 0, 4)
        DTitle.BackgroundTransparency = 1
        DTitle.Font = Enum.Font.GothamBold
        DTitle.Text = GuiConfig.Title
        DTitle.TextSize = 20
        DTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        DTitle.ZIndex = 52
        DTitle.Parent = Dialog

        local DMessage = Instance.new("TextLabel")
        DMessage.Size = UDim2.new(1, -20, 0, 60)
        DMessage.Position = UDim2.new(0, 10, 0, 30)
        DMessage.BackgroundTransparency = 1
        DMessage.Font = Enum.Font.Gotham
        DMessage.Text = "Do you want to close this window?\nYou won't be able to open it again."
        DMessage.TextSize = 13
        DMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
        DMessage.TextWrapped = true
        DMessage.ZIndex = 52
        DMessage.Parent = Dialog

        local Yes = Instance.new("TextButton")
        Yes.Size = UDim2.new(0.45, -10, 0, 32)
        Yes.Position = UDim2.new(0.05, 0, 1, -50)
        Yes.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Yes.BackgroundTransparency = 0.9
        Yes.Text = "Yes"
        Yes.Font = Enum.Font.GothamBold
        Yes.TextSize = 14
        Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
        Yes.TextTransparency = 0.3
        Yes.ZIndex = 52
        Yes.Parent = Dialog
        Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 6)

        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.45, -10, 0, 32)
        Cancel.Position = UDim2.new(0.5, 10, 1, -50)
        Cancel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.BackgroundTransparency = 0.9
        Cancel.Text = "Cancel"
        Cancel.Font = Enum.Font.GothamBold
        Cancel.TextSize = 14
        Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.TextTransparency = 0.3
        Cancel.ZIndex = 52
        Cancel.Parent = Dialog
        Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)

        Yes.MouseButton1Click:Connect(function()
            ConfigData = { _version = CURRENT_VERSION }
            if LoadConfigElements then LoadConfigElements() end
            if ZuperMingb then ZuperMingb:Destroy() end
            if CoreGui:FindFirstChild("ToggleUIButton") then
                CoreGui.ToggleUIButton:Destroy()
            end
        end)
        Cancel.MouseButton1Click:Connect(function() Overlay:Destroy() end)
    end)

    -- === TOGGLE UI BUTTON (Floating Logo) ===
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "ToggleUIButton"
    ToggleGui.ResetOnSpawn = false
    ToggleGui.Parent = CoreGui

    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Parent = ToggleGui
    ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 100)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Image = GuiConfig.Icon
    ToggleBtn.ScaleType = Enum.ScaleType.Fit

    ToggleBtn.MouseButton1Click:Connect(function()
        DropShadowHolder.Visible = not DropShadowHolder.Visible
        ToggleGui.Enabled = not DropShadowHolder.Visible
    end)

    local tDrag, tDragStart, tStartPos
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            tDrag = true
            tDragStart = input.Position
            tStartPos = ToggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then tDrag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if tDrag and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - tDragStart
            ToggleBtn.Position = UDim2.new(
                tStartPos.X.Scale, tStartPos.X.Offset + delta.X,
                tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y
            )
        end
    end)

    -- F3 Toggle
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F3 then
            if DropShadowHolder and DropShadowHolder.Parent then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end
    end)

    -- Make Draggable
    MakeDraggable(Top, DropShadowHolder)

    -- === FUNGSI: Update ScrollTab Size ===
    local function UpdateSize1()
        local total = 0
        for _, child in ScrollTab:GetChildren() do
            if child.Name ~= "UIListLayout" and child.Name ~= "TabLayout" then
                total = total + 4 + child.Size.Y.Offset
            end
        end
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, total)
    end
    ScrollTab.ChildAdded:Connect(UpdateSize1)
    ScrollTab.ChildRemoved:Connect(UpdateSize1)

    -- === TABS ===
    local Tabs = {}
    local CountTab = 0

    function Tabs:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""

        local ScrolLayers = Instance.new("ScrollingFrame")
        ScrolLayers.ScrollBarThickness = 0
        ScrolLayers.Active = true
        ScrolLayers.LayoutOrder = CountTab
        ScrolLayers.BackgroundTransparency = 1
        ScrolLayers.BorderSizePixel = 0
        ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
        ScrolLayers.Name = "ScrolLayers"
        ScrolLayers.Parent = LayersFolder

        local ScrolLayout = Instance.new("UIListLayout")
        ScrolLayout.Padding = UDim.new(0, 4)
        ScrolLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ScrolLayout.Parent = ScrolLayers

        -- Tab Icon Button (di sidebar)
        local Tab = Instance.new("Frame")
        Tab.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
        Tab.BackgroundTransparency = 1
        Tab.BorderSizePixel = 0
        Tab.LayoutOrder = CountTab
        Tab.Size = UDim2.new(0, 40, 0, 40)
        Tab.Name = "Tab"
        Tab.Parent = ScrollTab

        local UICorner3 = Instance.new("UICorner")
        UICorner3.CornerRadius = UDim.new(0, 8)
        UICorner3.Parent = Tab

        local TabButton = Instance.new("TextButton")
        TabButton.Text = ""
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.BackgroundTransparency = 1
        FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
        FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        FeatureImg.Size = UDim2.new(0, 22, 0, 22)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab

        if TabConfig.Icon ~= "" then
            if Icons[TabConfig.Icon] then
                FeatureImg.Image = Icons[TabConfig.Icon]
            else
                FeatureImg.Image = TabConfig.Icon
            end
            FeatureImg.ImageColor3 = Color3.fromRGB(180, 180, 180)
        end

        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            Tab.BackgroundTransparency = 0.85
            FeatureImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end

        -- Judul Tab di atas konten
        local TabTitle = Instance.new("TextLabel")
        TabTitle.Name = "TabTitle"
        TabTitle.Font = Enum.Font.GothamBold
        TabTitle.Text = TabConfig.Name
        TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabTitle.TextSize = 20
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabTitle.BackgroundTransparency = 1
        TabTitle.Position = UDim2.new(0, 15, 0, 10)
        TabTitle.Size = UDim2.new(1, -20, 0, 26)
        TabTitle.Parent = ScrolLayers

        -- Padding atas biar section gak numpuk judul
        local Pad = Instance.new("Frame")
        Pad.Name = "Pad"
        Pad.BackgroundTransparency = 1
        Pad.Size = UDim2.new(1, 0, 0, 5)
        Pad.LayoutOrder = -1
        Pad.Parent = ScrolLayers

        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            if Tab.LayoutOrder == LayersPageLayout.CurrentPage.LayoutOrder then return end
            for _, TabFrame in ScrollTab:GetChildren() do
                if TabFrame.Name == "Tab" then
                    TweenService:Create(TabFrame,
                        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                        { BackgroundTransparency = 1 }
                    ):Play()
                    local img = TabFrame:FindFirstChild("FeatureImg")
                    if img then
                        TweenService:Create(img, TweenInfo.new(0.3),
                            { ImageColor3 = Color3.fromRGB(180, 180, 180) }):Play()
                    end
                end
            end
            TweenService:Create(Tab,
                TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 0.85 }
            ):Play()
            TweenService:Create(FeatureImg, TweenInfo.new(0.3),
                { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
        end)

        local Sections = {}
        local CountSection = 0

        function Sections:AddSection(Title, AlwaysOpen)
            Title = Title or "Title"

            local Section = Instance.new("Frame")
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, 0, 0, 34)
            Section.Name = "Section"
            Section.Parent = ScrolLayers

            local SectionReal = Instance.new("Frame")
            SectionReal.AnchorPoint = Vector2.new(0.5, 0)
            SectionReal.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
            SectionReal.BackgroundTransparency = 0.5
            SectionReal.BorderSizePixel = 0
            SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
            SectionReal.Size = UDim2.new(1, -10, 0, 34)
            SectionReal.Name = "SectionReal"
            SectionReal.Parent = Section

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = SectionReal

            local SectionButton = Instance.new("TextButton")
            SectionButton.Text = ""
            SectionButton.BackgroundTransparency = 1
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.Name = "SectionButton"
            SectionButton.Parent = SectionReal

            local FeatureFrame = Instance.new("Frame")
            FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
            FeatureFrame.BackgroundTransparency = 1
            FeatureFrame.Position = UDim2.new(1, -10, 0.5, 0)
            FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
            FeatureFrame.Parent = SectionReal

            local SectionArrow = Instance.new("ImageLabel")
            SectionArrow.Image = "rbxassetid://16851841101"
            SectionArrow.ImageColor3 = Color3.fromRGB(200, 200, 200)
            SectionArrow.AnchorPoint = Vector2.new(0.5, 0.5)
            SectionArrow.BackgroundTransparency = 1
            SectionArrow.Position = UDim2.new(0.5, 0, 0.5, 0)
            SectionArrow.Rotation = -90
            SectionArrow.Size = UDim2.new(0, 16, 0, 16)
            SectionArrow.Parent = FeatureFrame

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
            SectionTitle.TextSize = 15
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
            SectionTitle.Position = UDim2.new(0, 14, 0.5, 0)
            SectionTitle.Size = UDim2.new(1, -50, 0, 20)
            SectionTitle.Parent = SectionReal

            local SectionAdd = Instance.new("Frame")
            SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
            SectionAdd.BackgroundTransparency = 1
            SectionAdd.ClipsDescendants = true
            SectionAdd.LayoutOrder = 1
            SectionAdd.Position = UDim2.new(0.5, 0, 0, 40)
            SectionAdd.Size = UDim2.new(1, -10, 0, 0)
            SectionAdd.Name = "SectionAdd"
            SectionAdd.Parent = Section

            local UIListLayout2 = Instance.new("UIListLayout")
            UIListLayout2.Padding = UDim.new(0, 3)
            UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout2.Parent = SectionAdd

            local OpenSection = false
            local isAnimating = false
            local ANIM_TIME = 0.25
            local ANIM_STYLE = Enum.EasingStyle.Quart
            local ANIM_DIR = Enum.EasingDirection.Out

            local function UpdateSizeScroll()
                local total = 0
                for _, child in ScrolLayers:GetChildren() do
                    if child.Name ~= "UIListLayout" and child.Name ~= "ScrolLayout" and child.Name ~= "TabTitle" then
                        total = total + 4 + child.Size.Y.Offset
                    end
                end
                ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, total)
            end

            local function UpdateSizeSection()
                if OpenSection then
                    local total = 40
                    for _, v in SectionAdd:GetChildren() do
                        if v.Name ~= "UIListLayout" then
                            total = total + v.Size.Y.Offset + 3
                        end
                    end
                    local ti = TweenInfo.new(ANIM_TIME, ANIM_STYLE, ANIM_DIR)
                    TweenService:Create(SectionArrow, ti, { Rotation = 0 }):Play()
                    TweenService:Create(Section, ti, { Size = UDim2.new(1, 0, 0, total) }):Play()
                    TweenService:Create(SectionAdd, ti, { Size = UDim2.new(1, -10, 0, total - 40) }):Play()
                    task.delay(ANIM_TIME, UpdateSizeScroll)
                end
            end

            if AlwaysOpen == true then
                SectionButton:Destroy()
                FeatureFrame:Destroy()
                OpenSection = true
                UpdateSizeSection()
            elseif AlwaysOpen == false then
                OpenSection = false
            else
                OpenSection = true
                UpdateSizeSection()
            end

            if AlwaysOpen ~= true then
                SectionButton.Activated:Connect(function()
                    if isAnimating then return end
                    isAnimating = true
                    CircleClick(SectionButton, Mouse.X, Mouse.Y)
                    local ti = TweenInfo.new(ANIM_TIME, ANIM_STYLE, ANIM_DIR)
                    if OpenSection then
                        TweenService:Create(SectionArrow, ti, { Rotation = -90 }):Play()
                        TweenService:Create(Section, ti, { Size = UDim2.new(1, 0, 0, 34) }):Play()
                        OpenSection = false
                        task.delay(ANIM_TIME, function()
                            UpdateSizeScroll()
                            isAnimating = false
                        end)
                    else
                        OpenSection = true
                        UpdateSizeSection()
                        task.delay(ANIM_TIME, function() isAnimating = false end)
                    end
                end)
            end

            SectionAdd.ChildAdded:Connect(function()
                task.wait(0.05)
                UpdateSizeSection()
            end)
            SectionAdd.ChildRemoved:Connect(function()
                task.wait(0.05)
                UpdateSizeSection()
            end)

            local Items = {}
            local CountItem = 0

            -- === TOGGLE ===
            function Items:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Title = ToggleConfig.Title or "Title"
                ToggleConfig.Content = ToggleConfig.Content or ""
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end

                local configKey = "Toggle_" .. ToggleConfig.Title
                if ConfigData[configKey] ~= nil then
                    ToggleConfig.Default = ConfigData[configKey]
                end

                local ToggleFunc = { Value = ToggleConfig.Default }

                local Toggle = Instance.new("Frame")
                Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Toggle.BackgroundTransparency = 0.94
                Toggle.BorderSizePixel = 0
                Toggle.LayoutOrder = CountItem
                Toggle.Size = UDim2.new(1, 0, 0, 46)
                Toggle.Parent = SectionAdd

                local TUIC = Instance.new("UICorner")
                TUIC.CornerRadius = UDim.new(0, 4)
                TUIC.Parent = Toggle

                local TTitle = Instance.new("TextLabel")
                TTitle.Font = Enum.Font.GothamBold
                TTitle.Text = ToggleConfig.Title
                TTitle.TextSize = 14
                TTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                TTitle.TextXAlignment = Enum.TextXAlignment.Left
                TTitle.BackgroundTransparency = 1
                TTitle.Position = UDim2.new(0, 12, 0, 10)
                TTitle.Size = UDim2.new(1, -80, 0, 14)
                TTitle.Parent = Toggle

                local TContent = Instance.new("TextLabel")
                TContent.Font = Enum.Font.Gotham
                TContent.Text = ToggleConfig.Content
                TContent.TextColor3 = Color3.fromRGB(160, 160, 160)
                TContent.TextSize = 12
                TContent.TextXAlignment = Enum.TextXAlignment.Left
                TContent.BackgroundTransparency = 1
                TContent.Position = UDim2.new(0, 12, 0, 26)
                TContent.Size = UDim2.new(1, -80, 0, 12)
                TContent.TextWrapped = true
                TContent.Parent = Toggle

                local TButton = Instance.new("TextButton")
                TButton.Text = ""
                TButton.BackgroundTransparency = 1
                TButton.Size = UDim2.new(1, 0, 1, 0)
                TButton.Parent = Toggle

                local TSwitch = Instance.new("Frame")
                TSwitch.AnchorPoint = Vector2.new(1, 0.5)
                TSwitch.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                TSwitch.BorderSizePixel = 0
                TSwitch.Position = UDim2.new(1, -14, 0.5, 0)
                TSwitch.Size = UDim2.new(0, 32, 0, 16)
                TSwitch.Parent = Toggle

                local TSIC = Instance.new("UICorner")
                TSIC.CornerRadius = UDim.new(1, 0)
                TSIC.Parent = TSwitch

                local TCircle = Instance.new("Frame")
                TCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                TCircle.BorderSizePixel = 0
                TCircle.AnchorPoint = Vector2.new(0, 0.5)
                TCircle.Position = UDim2.new(0, 2, 0.5, 0)
                TCircle.Size = UDim2.new(0, 12, 0, 12)
                TCircle.Parent = TSwitch

                local TCIC = Instance.new("UICorner")
                TCIC.CornerRadius = UDim.new(1, 0)
                TCIC.Parent = TCircle

                TButton.Activated:Connect(function()
                    ToggleFunc.Value = not ToggleFunc.Value
                    ToggleFunc:Set(ToggleFunc.Value)
                end)

                function ToggleFunc:Set(Value)
                    ToggleFunc.Value = Value
                    ConfigData[configKey] = Value
                    if Value then
                        TweenService:Create(TTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
                        TweenService:Create(TCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 16, 0.5, 0) }):Play()
                        TweenService:Create(TSwitch, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color }):Play()
                    else
                        TweenService:Create(TTitle, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(231, 231, 231) }):Play()
                        TweenService:Create(TCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, 0) }):Play()
                        TweenService:Create(TSwitch, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(60, 60, 65) }):Play()
                    end
                    task.spawn(function()
                        local ok, err = pcall(ToggleConfig.Callback, Value)
                        if not ok then warn("Toggle error:", err) end
                    end)
                end

                ToggleFunc:Set(ToggleFunc.Value)
                CountItem = CountItem + 1
                ToggleFunc.Type = "Toggle"
                Elements[configKey] = ToggleFunc
                return ToggleFunc
            end

            -- === BUTTON ===
            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Title = ButtonConfig.Title or "Confirm"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                ButtonConfig.SubTitle = ButtonConfig.SubTitle or nil
                ButtonConfig.SubCallback = ButtonConfig.SubCallback or function() end

                local Button = Instance.new("Frame")
                Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Button.BackgroundTransparency = 0.94
                Button.Size = UDim2.new(1, 0, 0, 38)
                Button.LayoutOrder = CountItem
                Button.Parent = SectionAdd

                local BUC = Instance.new("UICorner")
                BUC.CornerRadius = UDim.new(0, 4)
                BUC.Parent = Button

                local MainButton = Instance.new("TextButton")
                MainButton.Font = Enum.Font.GothamBold
                MainButton.Text = ButtonConfig.Title
                MainButton.TextSize = 14
                MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.TextTransparency = 0.2
                MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.BackgroundTransparency = 0.94
                MainButton.Size = ButtonConfig.SubTitle
                    and UDim2.new(0.5, -6, 1, -8)
                    or UDim2.new(1, -12, 1, -8)
                MainButton.Position = UDim2.new(0, 6, 0, 4)
                MainButton.Parent = Button

                local MBC = Instance.new("UICorner")
                MBC.CornerRadius = UDim.new(0, 4)
                MBC.Parent = MainButton

                MainButton.MouseButton1Click:Connect(function()
                    CircleClick(MainButton, Mouse.X, Mouse.Y)
                    ButtonConfig.Callback()
                end)

                if ButtonConfig.SubTitle then
                    local SubButton = Instance.new("TextButton")
                    SubButton.Font = Enum.Font.GothamBold
                    SubButton.Text = ButtonConfig.SubTitle
                    SubButton.TextSize = 14
                    SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.TextTransparency = 0.2
                    SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundTransparency = 0.94
                    SubButton.Size = UDim2.new(0.5, -6, 1, -8)
                    SubButton.Position = UDim2.new(0.5, 0, 0, 4)
                    SubButton.Parent = Button

                    local SBC = Instance.new("UICorner")
                    SBC.CornerRadius = UDim.new(0, 4)
                    SBC.Parent = SubButton

                    SubButton.MouseButton1Click:Connect(function()
                        CircleClick(SubButton, Mouse.X, Mouse.Y)
                        ButtonConfig.SubCallback()
                    end)
                end

                CountItem = CountItem + 1
            end

            -- === SLIDER ===
            function Items:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Title = SliderConfig.Title or "Slider"
                SliderConfig.Content = SliderConfig.Content or ""
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end

                local configKey = "Slider_" .. SliderConfig.Title
                if ConfigData[configKey] ~= nil then
                    SliderConfig.Default = ConfigData[configKey]
                end

                local SliderFunc = { Value = SliderConfig.Default }

                local Slider = Instance.new("Frame")
                Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Slider.BackgroundTransparency = 0.94
                Slider.BorderSizePixel = 0
                Slider.LayoutOrder = CountItem
                Slider.Size = UDim2.new(1, 0, 0, 50)
                Slider.Parent = SectionAdd

                local SUC = Instance.new("UICorner")
                SUC.CornerRadius = UDim.new(0, 4)
                SUC.Parent = Slider

                local STitle = Instance.new("TextLabel")
                STitle.Font = Enum.Font.GothamBold
                STitle.Text = SliderConfig.Title
                STitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                STitle.TextSize = 14
                STitle.TextXAlignment = Enum.TextXAlignment.Left
                STitle.BackgroundTransparency = 1
                STitle.Position = UDim2.new(0, 12, 0, 8)
                STitle.Size = UDim2.new(1, -100, 0, 14)
                STitle.Parent = Slider

                local SValueBox = Instance.new("TextLabel")
                SValueBox.Font = Enum.Font.GothamBold
                SValueBox.Text = tostring(SliderConfig.Default)
                SValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                SValueBox.TextSize = 14
                SValueBox.TextXAlignment = Enum.TextXAlignment.Right
                SValueBox.BackgroundTransparency = 1
                SValueBox.AnchorPoint = Vector2.new(1, 0)
                SValueBox.Position = UDim2.new(1, -12, 0, 8)
                SValueBox.Size = UDim2.new(0, 50, 0, 14)
                SValueBox.Parent = Slider

                local SBar = Instance.new("Frame")
                SBar.AnchorPoint = Vector2.new(0.5, 1)
                SBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                SBar.BorderSizePixel = 0
                SBar.Position = UDim2.new(0.5, 0, 1, -10)
                SBar.Size = UDim2.new(1, -24, 0, 4)
                SBar.Parent = Slider

                local SBUC = Instance.new("UICorner")
                SBUC.CornerRadius = UDim.new(1, 0)
                SBUC.Parent = SBar

                local SFill = Instance.new("Frame")
                SFill.AnchorPoint = Vector2.new(0, 0.5)
                SFill.BackgroundColor3 = GuiConfig.Color
                SFill.BorderSizePixel = 0
                SFill.Position = UDim2.new(0, 0, 0.5, 0)
                SFill.Size = UDim2.new(0, 0, 1, 0)
                SFill.Parent = SBar

                local SFUC = Instance.new("UICorner")
                SFUC.CornerRadius = UDim.new(1, 0)
                SFUC.Parent = SFill

                local SButton = Instance.new("TextButton")
                SButton.Text = ""
                SButton.BackgroundTransparency = 1
                SButton.Size = UDim2.new(1, 0, 1, 0)
                SButton.Parent = SBar

                local Dragging = false
                local function Round(Number, Factor)
                    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
                    if Result < 0 then Result = Result + Factor end
                    return Result
                end

                function SliderFunc:Set(Value)
                    Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    SliderFunc.Value = Value
                    SValueBox.Text = tostring(Value)
                    local ratio = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    TweenService:Create(SFill, TweenInfo.new(0.2), { Size = UDim2.new(ratio, 0, 1, 0) }):Play()
                    SliderConfig.Callback(Value)
                    ConfigData[configKey] = Value
                end

                SButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        local ratio = math.clamp(
                            (input.Position.X - SBar.AbsolutePosition.X) / SBar.AbsoluteSize.X,
                            0, 1
                        )
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * ratio))
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                        local ratio = math.clamp(
                            (input.Position.X - SBar.AbsolutePosition.X) / SBar.AbsoluteSize.X,
                            0, 1
                        )
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * ratio))
                    end
                end)

                SliderFunc:Set(SliderConfig.Default)
                CountItem = CountItem + 1
                SliderFunc.Type = "Slider"
                Elements[configKey] = SliderFunc
                return SliderFunc
            end

            -- === INPUT ===
            function Items:AddInput(InputConfig)
                InputConfig = InputConfig or {}
                InputConfig.Title = InputConfig.Title or "Input"
                InputConfig.Placeholder = InputConfig.Placeholder or nil
                InputConfig.Content = InputConfig.Content or ""
                InputConfig.Callback = InputConfig.Callback or function() end
                InputConfig.Default = InputConfig.Default or ""

                local configKey = "Input_" .. InputConfig.Title
                if ConfigData[configKey] ~= nil then
                    InputConfig.Default = ConfigData[configKey]
                end

                local InputFunc = { Value = InputConfig.Default }

                local Input = Instance.new("Frame")
                Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Input.BackgroundTransparency = 0.94
                Input.BorderSizePixel = 0
                Input.LayoutOrder = CountItem
                Input.Size = UDim2.new(1, 0, 0, 46)
                Input.Parent = SectionAdd

                local IUC = Instance.new("UICorner")
                IUC.CornerRadius = UDim.new(0, 4)
                IUC.Parent = Input

                local ITitle = Instance.new("TextLabel")
                ITitle.Font = Enum.Font.GothamBold
                ITitle.Text = InputConfig.Title
                ITitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                ITitle.TextSize = 14
                ITitle.TextXAlignment = Enum.TextXAlignment.Left
                ITitle.BackgroundTransparency = 1
                ITitle.Position = UDim2.new(0, 12, 0, 10)
                ITitle.Size = UDim2.new(1, -160, 0, 14)
                ITitle.Parent = Input

                local IContent = Instance.new("TextLabel")
                IContent.Font = Enum.Font.Gotham
                IContent.Text = InputConfig.Content
                IContent.TextColor3 = Color3.fromRGB(160, 160, 160)
                IContent.TextSize = 12
                IContent.TextXAlignment = Enum.TextXAlignment.Left
                IContent.BackgroundTransparency = 1
                IContent.Position = UDim2.new(0, 12, 0, 26)
                IContent.Size = UDim2.new(1, -160, 0, 12)
                IContent.TextWrapped = true
                IContent.Parent = Input

                local IBox = Instance.new("Frame")
                IBox.AnchorPoint = Vector2.new(1, 0.5)
                IBox.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
                IBox.BorderSizePixel = 0
                IBox.Position = UDim2.new(1, -10, 0.5, 0)
                IBox.Size = UDim2.new(0, 140, 0, 28)
                IBox.Parent = Input

                local IBUC = Instance.new("UICorner")
                IBUC.CornerRadius = UDim.new(0, 4)
                IBUC.Parent = IBox

                local ITextBox = Instance.new("TextBox")
                ITextBox.Font = Enum.Font.Gotham
                ITextBox.PlaceholderText = InputConfig.Placeholder or "Input"
                ITextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                ITextBox.Text = InputConfig.Default
                ITextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                ITextBox.TextSize = 13
                ITextBox.TextXAlignment = Enum.TextXAlignment.Left
                ITextBox.BackgroundTransparency = 1
                ITextBox.Position = UDim2.new(0, 8, 0, 0)
                ITextBox.Size = UDim2.new(1, -16, 1, 0)
                ITextBox.ClearTextOnFocus = false
                ITextBox.Parent = IBox

                function InputFunc:Set(Value)
                    ITextBox.Text = Value
                    InputFunc.Value = Value
                    ConfigData[configKey] = Value
                    InputConfig.Callback(Value)
                end

                InputFunc:Set(InputConfig.Default)

                ITextBox.FocusLost:Connect(function()
                    InputFunc:Set(ITextBox.Text)
                end)

                CountItem = CountItem + 1
                InputFunc.Type = "Input"
                Elements[configKey] = InputFunc
                return InputFunc
            end

            -- === DIVIDER ===
            function Items:AddDivider()
                local Div = Instance.new("Frame")
                Div.Name = "Divider"
                Div.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                Div.BorderSizePixel = 0
                Div.LayoutOrder = CountItem
                Div.Size = UDim2.new(1, -20, 0, 1)
                Div.Parent = SectionAdd

                CountItem = CountItem + 1
                return Div
            end

            -- === PARAGRAPH ===
            function Items:AddParagraph(ParagraphConfig)
                ParagraphConfig = ParagraphConfig or {}
                ParagraphConfig.Title = ParagraphConfig.Title or "Title"
                ParagraphConfig.Content = ParagraphConfig.Content or "Content"
                local ParagraphFunc = {}

                local Para = Instance.new("Frame")
                Para.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Para.BackgroundTransparency = 0.94
                Para.BorderSizePixel = 0
                Para.LayoutOrder = CountItem
                Para.Size = UDim2.new(1, 0, 0, 46)
                Para.Parent = SectionAdd

                local PUC = Instance.new("UICorner")
                PUC.CornerRadius = UDim.new(0, 4)
                PUC.Parent = Para

                local PTitle = Instance.new("TextLabel")
                PTitle.Font = Enum.Font.GothamBold
                PTitle.Text = ParagraphConfig.Title
                PTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                PTitle.TextSize = 14
                PTitle.TextXAlignment = Enum.TextXAlignment.Left
                PTitle.BackgroundTransparency = 1
                PTitle.Position = UDim2.new(0, 12, 0, 10)
                PTitle.Size = UDim2.new(1, -24, 0, 14)
                PTitle.Parent = Para

                local PContent = Instance.new("TextLabel")
                PContent.Font = Enum.Font.Gotham
                PContent.Text = ParagraphConfig.Content
                PContent.TextColor3 = Color3.fromRGB(180, 180, 180)
                PContent.TextSize = 12
                PContent.TextXAlignment = Enum.TextXAlignment.Left
                PContent.TextYAlignment = Enum.TextYAlignment.Top
                PContent.BackgroundTransparency = 1
                PContent.Position = UDim2.new(0, 12, 0, 26)
                PContent.Size = UDim2.new(1, -24, 0, 12)
                PContent.TextWrapped = true
                PContent.Parent = Para

                local function UpdateSize()
                    Para.Size = UDim2.new(1, 0, 0, PContent.TextBounds.Y + 34)
                end
                UpdateSize()
                PContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)

                function ParagraphFunc:SetContent(content)
                    PContent.Text = content or "Content"
                    UpdateSize()
                end

                CountItem = CountItem + 1
                return ParagraphFunc
            end

            -- === DROPDOWN ===
            function Items:AddDropdown(DropdownConfig)
                DropdownConfig = DropdownConfig or {}
                DropdownConfig.Title = DropdownConfig.Title or "Dropdown"
                DropdownConfig.Content = DropdownConfig.Content or ""
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or nil
                DropdownConfig.Callback = DropdownConfig.Callback or function() end

                local configKey = "Dropdown_" .. DropdownConfig.Title
                if ConfigData[configKey] ~= nil then
                    DropdownConfig.Default = ConfigData[configKey]
                end

                local DropdownFunc = { Value = DropdownConfig.Default }

                local DD = Instance.new("Frame")
                DD.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                DD.BackgroundTransparency = 0.94
                DD.BorderSizePixel = 0
                DD.LayoutOrder = CountItem
                DD.Size = UDim2.new(1, 0, 0, 46)
                DD.Parent = SectionAdd

                local DDUC = Instance.new("UICorner")
                DDUC.CornerRadius = UDim.new(0, 4)
                DDUC.Parent = DD

                local DDTitle = Instance.new("TextLabel")
                DDTitle.Font = Enum.Font.GothamBold
                DDTitle.Text = DropdownConfig.Title
                DDTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                DDTitle.TextSize = 14
                DDTitle.TextXAlignment = Enum.TextXAlignment.Left
                DDTitle.BackgroundTransparency = 1
                DDTitle.Position = UDim2.new(0, 12, 0, 10)
                DDTitle.Size = UDim2.new(1, -160, 0, 14)
                DDTitle.Parent = DD

                local DDContent = Instance.new("TextLabel")
                DDContent.Font = Enum.Font.Gotham
                DDContent.Text = DropdownConfig.Content
                DDContent.TextColor3 = Color3.fromRGB(160, 160, 160)
                DDContent.TextSize = 12
                DDContent.TextXAlignment = Enum.TextXAlignment.Left
                DDContent.BackgroundTransparency = 1
                DDContent.Position = UDim2.new(0, 12, 0, 26)
                DDContent.Size = UDim2.new(1, -160, 0, 12)
                DDContent.TextWrapped = true
                DDContent.Parent = DD

                local DDBox = Instance.new("Frame")
                DDBox.AnchorPoint = Vector2.new(1, 0.5)
                DDBox.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
                DDBox.BorderSizePixel = 0
                DDBox.Position = UDim2.new(1, -10, 0.5, 0)
                DDBox.Size = UDim2.new(0, 140, 0, 28)
                DDBox.Parent = DD

                local DDBUC = Instance.new("UICorner")
                DDBUC.CornerRadius = UDim.new(0, 4)
                DDBUC.Parent = DDBox

                local DDSelect = Instance.new("TextLabel")
                DDSelect.Font = Enum.Font.Gotham
                DDSelect.Text = "Select..."
                DDSelect.TextColor3 = Color3.fromRGB(180, 180, 180)
                DDSelect.TextSize = 13
                DDSelect.TextXAlignment = Enum.TextXAlignment.Left
                DDSelect.BackgroundTransparency = 1
                DDSelect.Position = UDim2.new(0, 10, 0, 0)
                DDSelect.Size = UDim2.new(1, -30, 1, 0)
                DDSelect.Parent = DDBox

                local DDArrow = Instance.new("ImageLabel")
                DDArrow.Image = "rbxassetid://16851841101"
                DDArrow.ImageColor3 = Color3.fromRGB(180, 180, 180)
                DDArrow.AnchorPoint = Vector2.new(1, 0.5)
                DDArrow.BackgroundTransparency = 1
                DDArrow.Position = UDim2.new(1, -5, 0.5, 0)
                DDArrow.Rotation = 90
                DDArrow.Size = UDim2.new(0, 14, 0, 14)
                DDArrow.Parent = DDBox

                local DDButton = Instance.new("TextButton")
                DDButton.Text = ""
                DDButton.BackgroundTransparency = 1
                DDButton.Size = UDim2.new(1, 0, 1, 0)
                DDButton.Parent = DDBox

                -- Dropdown popup di luar
                local DropdownPopup = Instance.new("Frame")
                DropdownPopup.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
                DropdownPopup.BorderSizePixel = 0
                DropdownPopup.Size = UDim2.new(0, 200, 0, 150)
                DropdownPopup.Position = UDim2.new(0, 0, 0, 0)
                DropdownPopup.Visible = false
                DropdownPopup.ZIndex = 50
                DropdownPopup.Parent = Main

                local DPUC = Instance.new("UICorner")
                DPUC.CornerRadius = UDim.new(0, 6)
                DPUC.Parent = DropdownPopup

                local DPStroke = Instance.new("UIStroke")
                DPStroke.Color = GuiConfig.Color
                DPStroke.Thickness = 1.5
                DPStroke.Parent = DropdownPopup

                local DPList = Instance.new("ScrollingFrame")
                DPList.ScrollBarThickness = 0
                DPList.BackgroundTransparency = 1
                DPList.BorderSizePixel = 0
                DPList.Size = UDim2.new(1, -8, 1, -8)
                DPList.Position = UDim2.new(0, 4, 0, 4)
                DPList.CanvasSize = UDim2.new(0, 0, 0, 0)
                DPList.Parent = DropdownPopup

                local DPListLayout = Instance.new("UIListLayout")
                DPListLayout.Padding = UDim.new(0, 3)
                DPListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DPListLayout.Parent = DPList

                DPListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    DPList.CanvasSize = UDim2.new(0, 0, 0, DPListLayout.AbsoluteContentSize.Y + 8)
                end)

                local function RefreshOptions()
                    for _, opt in ipairs(DPList:GetChildren()) do
                        if opt.Name == "Option" then opt:Destroy() end
                    end

                    local maxW = 150
                    for _, rawOpt in ipairs(DropdownConfig.Options) do
                        local label = tostring(rawOpt)
                        local txtBounds = TextService:GetTextSize(label, 13, Enum.Font.Gotham, Vector2.new(1000, 30))
                        if txtBounds.X + 30 > maxW then maxW = txtBounds.X + 30 end

                        local Opt = Instance.new("TextButton")
                        Opt.Name = "Option"
                        Opt.Font = Enum.Font.Gotham
                        Opt.Text = label
                        Opt.TextColor3 = Color3.fromRGB(220, 220, 220)
                        Opt.TextSize = 13
                        Opt.TextXAlignment = Enum.TextXAlignment.Left
                        Opt.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                        Opt.BackgroundTransparency = 1
                        Opt.Size = UDim2.new(1, 0, 0, 28)
                        Opt.Parent = DPList

                        local OptCorner = Instance.new("UICorner")
                        OptCorner.CornerRadius = UDim.new(0, 4)
                        OptCorner.Parent = Opt

                        Opt.MouseButton1Click:Connect(function()
                            DropdownFunc:Set(label)
                            DropdownPopup.Visible = false
                            DDArrow.Rotation = 90
                        end)
                    end

                    DropdownPopup.Size = UDim2.new(0, maxW, 0, math.min(150, (#DropdownConfig.Options * 31) + 8))
                end

                RefreshOptions()

                function DropdownFunc:Set(Value)
                    DropdownFunc.Value = Value
                    if Value and Value ~= "" then
                        DDSelect.Text = tostring(Value)
                        DDSelect.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        DDSelect.Text = "Select..."
                        DDSelect.TextColor3 = Color3.fromRGB(180, 180, 180)
                    end
                    ConfigData[configKey] = Value
                    DropdownConfig.Callback(Value)
                end

                DDButton.MouseButton1Click:Connect(function()
                    DropdownPopup.Visible = not DropdownPopup.Visible
                    if DropdownPopup.Visible then
                        local boxPos = DDBox.AbsolutePosition
                        local mainPos = Main.AbsolutePosition
                        local relX = boxPos.X - mainPos.X
                        local relY = boxPos.Y - mainPos.Y + DDBox.AbsoluteSize.Y + 2
                        DropdownPopup.Position = UDim2.new(0, relX + DDBox.AbsoluteSize.X - DropdownPopup.AbsoluteSize.X, 0, relY)
                        DDArrow.Rotation = -90
                    else
                        DDArrow.Rotation = 90
                    end
                end)

                DropdownFunc:Set(DropdownConfig.Default)

                CountItem = CountItem + 1
                DropdownFunc.Type = "Dropdown"
                Elements[configKey] = DropdownFunc
                return DropdownFunc
            end

            CountSection = CountSection + 1
            return Items
        end

        CountTab = CountTab + 1
        return Sections
    end

    -- Klik di luar dropdown untuk tutup
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            for _, v in ipairs(Main:GetDescendants()) do
                if v.Name == "DropdownPopup" and v.Visible then
                    -- biarkan dropdown handling sendiri
                end
            end
        end
    end)

    return Tabs
end

return ZuperMing