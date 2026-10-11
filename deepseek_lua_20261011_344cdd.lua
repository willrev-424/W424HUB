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

local function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 999
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
        for _ = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            task.wait(0.05)
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

local function MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPosition
    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(
            StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
        )
        TweenService:Create(object, TweenInfo.new(0.15), { Position = pos }):Play()
    end
    topbar.InputBegan:Connect(function(input)
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
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then Update(input) end
    end)
end

local ZuperMing = {}

function ZuperMing:MakeNotify(cfg)
    cfg = cfg or {}
    cfg.Title = cfg.Title or "ZuperMing"
    cfg.Description = cfg.Description or "Notification"
    cfg.Content = cfg.Content or ""
    cfg.Color = cfg.Color or Color3.fromRGB(50, 100, 255)
    cfg.Time = cfg.Time or 0.4
    cfg.Delay = cfg.Delay or 4

    local NotifyFunction = {}
    spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local N = Instance.new("ScreenGui")
            N.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            N.Name = "NotifyGui"
            N.ResetOnSpawn = false
            N.Parent = CoreGui
        end
        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local L = Instance.new("Frame")
            L.AnchorPoint = Vector2.new(1, 1)
            L.BackgroundTransparency = 1
            L.Position = UDim2.new(1, -20, 1, -20)
            L.Size = UDim2.new(0, 280, 1, 0)
            L.Name = "NotifyLayout"
            L.Parent = CoreGui.NotifyGui
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for _, v in ipairs(CoreGui.NotifyGui.NotifyLayout:GetChildren()) do
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 6) * Count)) }):Play()
                    Count = Count + 1
                end
            end)
        end
        local posH = 0
        for _, v in ipairs(CoreGui.NotifyGui.NotifyLayout:GetChildren()) do
            posH = -(v.Position.Y.Offset) + v.Size.Y.Offset + 6
        end
        local TB = TextService:GetTextSize(cfg.Content, 12, Enum.Font.Gotham, Vector2.new(240, 9999))
        local TotalH = 26 + TB.Y + 12
        if TotalH < 48 then TotalH = 48 end

        local NF = Instance.new("Frame")
        NF.Name = "NotifyFrame"
        NF.BackgroundTransparency = 1
        NF.Size = UDim2.new(1, 0, 0, TotalH)
        NF.Parent = CoreGui.NotifyGui.NotifyLayout
        NF.AnchorPoint = Vector2.new(0, 1)
        NF.Position = UDim2.new(0, 0, 1, -posH)

        local Real = Instance.new("Frame")
        Real.Name = "Real"
        Real.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        Real.BorderSizePixel = 0
        Real.Position = UDim2.new(0, 320, 0, 0)
        Real.Size = UDim2.new(1, 0, 1, 0)
        Real.Parent = NF
        local RC = Instance.new("UICorner")
        RC.CornerRadius = UDim.new(0, 6)
        RC.Parent = Real

        local Accent = Instance.new("Frame")
        Accent.BackgroundColor3 = cfg.Color
        Accent.BorderSizePixel = 0
        Accent.Size = UDim2.new(0, 3, 1, -12)
        Accent.Position = UDim2.new(0, 6, 0, 6)
        Accent.Parent = Real
        local AC = Instance.new("UICorner")
        AC.CornerRadius = UDim.new(1, 0)
        AC.Parent = Accent

        local NT = Instance.new("TextLabel")
        NT.Font = Enum.Font.GothamBold
        NT.Text = cfg.Title
        NT.TextColor3 = Color3.fromRGB(255, 255, 255)
        NT.TextSize = 12
        NT.TextXAlignment = Enum.TextXAlignment.Left
        NT.BackgroundTransparency = 1
        NT.Position = UDim2.new(0, 16, 0, 6)
        NT.Size = UDim2.new(0.5, -20, 0, 14)
        NT.Parent = Real

        local ND = Instance.new("TextLabel")
        ND.Font = Enum.Font.GothamBold
        ND.Text = cfg.Description
        ND.TextColor3 = cfg.Color
        ND.TextSize = 11
        ND.TextXAlignment = Enum.TextXAlignment.Right
        ND.BackgroundTransparency = 1
        ND.AnchorPoint = Vector2.new(1, 0)
        ND.Position = UDim2.new(1, -10, 0, 7)
        ND.Size = UDim2.new(0.5, -16, 0, 14)
        ND.Parent = Real

        local NC = Instance.new("TextLabel")
        NC.Font = Enum.Font.Gotham
        NC.Text = cfg.Content
        NC.TextColor3 = Color3.fromRGB(180, 180, 180)
        NC.TextSize = 12
        NC.BackgroundTransparency = 1
        NC.TextXAlignment = Enum.TextXAlignment.Left
        NC.TextYAlignment = Enum.TextYAlignment.Top
        NC.TextWrapped = true
        NC.Position = UDim2.new(0, 16, 0, 24)
        NC.Size = UDim2.new(1, -26, 1, -28)
        NC.Parent = Real

        local Closed = false
        function NotifyFunction:Close()
            if Closed then return end
            Closed = true
            TweenService:Create(Real, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                { Position = UDim2.new(0, 320, 0, 0) }):Play()
            task.wait(0.35)
            NF:Destroy()
        end
        TweenService:Create(Real, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 0, 0, 0) }):Play()
        task.delay(cfg.Delay, function() NotifyFunction:Close() end)
    end)
    return NotifyFunction
end

function notif(msg, delay, color, title, desc)
    return ZuperMing:MakeNotify({
        Title = title or "ZuperMing", Description = desc or "Notification",
        Content = msg or "", Color = color or Color3.fromRGB(50, 100, 255), Delay = delay or 4
    })
end

function ZuperMing:Window(GuiConfig)
    GuiConfig            = GuiConfig or {}
    GuiConfig.Title      = GuiConfig.Title or "Sena 6.2"
    GuiConfig.GameName   = GuiConfig.GameName or "Steal An Egg"
    GuiConfig.Icon       = GuiConfig.Icon or "rbxassetid://104396282819940"
    GuiConfig.LogoBg     = GuiConfig.LogoBg or ""
    GuiConfig.Color      = GuiConfig.Color or Color3.fromRGB(50, 100, 255)
    GuiConfig.Background = GuiConfig.Background or Color3.fromRGB(15, 15, 20)
    GuiConfig.Premium    = GuiConfig.Premium or "Free"
    GuiConfig.TabWidth   = GuiConfig.TabWidth or 60
    GuiConfig.ShowSearch = GuiConfig.ShowSearch ~= false

    local executorName = GetExecutorName()
    local TOP_H    = 54
    local BOTTOM_H = 42
    local SIDE_W   = GuiConfig.TabWidth

    local GuiFunc = {}

    local Screen = Instance.new("ScreenGui")
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Screen.Name = "ZuperMingb"
    Screen.ResetOnSpawn = false
    Screen.Parent = CoreGui

    local ShadowHolder = Instance.new("Frame")
    ShadowHolder.BackgroundTransparency = 1
    ShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    ShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    ShadowHolder.Size = UDim2.new(0, 640, 0, 400)
    ShadowHolder.Name = "ShadowHolder"
    ShadowHolder.Parent = Screen

    local Shadow = Instance.new("ImageLabel")
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.45
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Parent = ShadowHolder

    local Main = Instance.new("Frame")
    Main.BackgroundColor3 = GuiConfig.Background
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -40, 1, -40)
    Main.Name = "Main"
    Main.ClipsDescendants = true
    Main.Parent = Shadow

    local MC = Instance.new("UICorner")
    MC.CornerRadius = UDim.new(0, 10)
    MC.Parent = Main

    local MS = Instance.new("UIStroke")
    MS.Color = Color3.fromRGB(120, 10, 30)
    MS.Thickness = 1.5
    MS.Parent = Main

    if GuiConfig.LogoBg ~= "" then
        local BGImg = Instance.new("ImageLabel")
        BGImg.Name = "BGImg"
        BGImg.Image = GuiConfig.LogoBg
        BGImg.BackgroundTransparency = 1
        BGImg.ImageTransparency = 0.92
        BGImg.ScaleType = Enum.ScaleType.Fit
        BGImg.AnchorPoint = Vector2.new(0.5, 0.5)
        BGImg.Position = UDim2.new(0.65, 0, 0.55, 0)
        BGImg.Size = UDim2.new(0.7, 0, 0.7, 0)
        BGImg.ZIndex = 1
        BGImg.Parent = Main
    end

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, TOP_H)
    Header.ZIndex = 10
    Header.Parent = Main

    local HC = Instance.new("UICorner")
    HC.CornerRadius = UDim.new(0, 10)
    HC.Parent = Header

    local HLine = Instance.new("Frame")
    HLine.Name = "HLine"
    HLine.BackgroundColor3 = Color3.fromRGB(120, 10, 30)
    HLine.BorderSizePixel = 0
    HLine.Position = UDim2.new(0, 0, 1, -1)
    HLine.Size = UDim2.new(1, 0, 0, 1)
    HLine.ZIndex = 11
    HLine.Parent = Header

    local Logo = Instance.new("ImageLabel")
    Logo.Name = "Logo"
    Logo.Parent = Header
    Logo.BackgroundTransparency = 1
    Logo.Position = UDim2.new(0, 12, 0.5, 0)
    Logo.AnchorPoint = Vector2.new(0, 0.5)
    Logo.Size = UDim2.new(0, 30, 0, 30)
    Logo.Image = GuiConfig.Icon
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.ZIndex = 12

    local TitleL = Instance.new("TextLabel")
    TitleL.Font = Enum.Font.GothamBold
    TitleL.Text = GuiConfig.Title
    TitleL.TextColor3 = GuiConfig.Color
    TitleL.TextSize = 15
    TitleL.TextXAlignment = Enum.TextXAlignment.Left
    TitleL.BackgroundTransparency = 1
    TitleL.Position = UDim2.new(0, 50, 0, 8)
    TitleL.Size = UDim2.new(0, 200, 0, 18)
    TitleL.ZIndex = 12
    TitleL.Parent = Header

    local GameL = Instance.new("TextLabel")
    GameL.Font = Enum.Font.GothamMedium
    GameL.Text = GuiConfig.GameName
    GameL.TextColor3 = Color3.fromRGB(170, 170, 180)
    GameL.TextSize = 11
    GameL.TextXAlignment = Enum.TextXAlignment.Left
    GameL.BackgroundTransparency = 1
    GameL.Position = UDim2.new(0, 50, 0, 28)
    GameL.Size = UDim2.new(0, 200, 0, 14)
    GameL.ZIndex = 12
    GameL.Parent = Header

    if GuiConfig.ShowSearch then
        local SF = Instance.new("Frame")
        SF.Name = "SF"
        SF.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        SF.BackgroundTransparency = 0.2
        SF.BorderSizePixel = 0
        SF.AnchorPoint = Vector2.new(0, 0.5)
        SF.Position = UDim2.new(0, 255, 0.5, 0)
        SF.Size = UDim2.new(0, 220, 0, 26)
        SF.ZIndex = 12
        SF.Parent = Header

        local SFC = Instance.new("UICorner")
        SFC.CornerRadius = UDim.new(1, 0)
        SFC.Parent = SF

        local SI = Instance.new("ImageLabel")
        SI.Image = "rbxassetid://3926305904"
        SI.ImageRectOffset = Vector2.new(964, 324)
        SI.ImageRectSize = Vector2.new(36, 36)
        SI.BackgroundTransparency = 1
        SI.AnchorPoint = Vector2.new(0, 0.5)
        SI.Position = UDim2.new(0, 10, 0.5, 0)
        SI.Size = UDim2.new(0, 14, 0, 14)
        SI.ImageColor3 = Color3.fromRGB(160, 160, 160)
        SI.ZIndex = 13
        SI.Parent = SF

        local SB = Instance.new("TextBox")
        SB.Font = Enum.Font.Gotham
        SB.PlaceholderText = "Search"
        SB.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
        SB.Text = ""
        SB.TextSize = 12
        SB.TextColor3 = Color3.fromRGB(230, 230, 230)
        SB.TextXAlignment = Enum.TextXAlignment.Left
        SB.BackgroundTransparency = 1
        SB.Position = UDim2.new(0, 30, 0, 0)
        SB.Size = UDim2.new(1, -36, 1, 0)
        SB.ClearTextOnFocus = false
        SB.ZIndex = 13
        SB.Parent = SF
    end

    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = ""
    MinBtn.AnchorPoint = Vector2.new(1, 0.5)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position = UDim2.new(1, -38, 0.5, 0)
    MinBtn.Size = UDim2.new(0, 26, 0, 26)
    MinBtn.ZIndex = 12
    MinBtn.Parent = Header

    local MinIcon = Instance.new("ImageLabel")
    MinIcon.Image = "rbxassetid://9886659276"
    MinIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinIcon.BackgroundTransparency = 1
    MinIcon.ImageTransparency = 0.2
    MinIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinIcon.Size = UDim2.new(0, 12, 0, 12)
    MinIcon.ZIndex = 13
    MinIcon.Parent = MinBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = ""
    CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -8, 0.5, 0)
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.ZIndex = 12
    CloseBtn.Parent = Header

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Image = "rbxassetid://9886659671"
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(0, 12, 0, 12)
    CloseIcon.ZIndex = 13
    CloseIcon.Parent = CloseBtn

    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.BackgroundTransparency = 1
    Body.Position = UDim2.new(0, 0, 0, TOP_H)
    Body.Size = UDim2.new(1, 0, 1, -(TOP_H + BOTTOM_H))
    Body.ZIndex = 5
    Body.Parent = Main

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Sidebar.BackgroundTransparency = 0.4
    Sidebar.BorderSizePixel = 0
    Sidebar.Size = UDim2.new(0, SIDE_W, 1, 0)
    Sidebar.ZIndex = 6
    Sidebar.Parent = Body

    local ScrollTab = Instance.new("ScrollingFrame")
    ScrollTab.CanvasSize = UDim2.new(0, 0, 1, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundTransparency = 1
    ScrollTab.BorderSizePixel = 0
    ScrollTab.Size = UDim2.new(1, 0, 1, 0)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.ZIndex = 7
    ScrollTab.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Parent = ScrollTab

    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingTop = UDim.new(0, 6)
    TabPad.Parent = ScrollTab

    local VertSep = Instance.new("Frame")
    VertSep.Name = "VertSep"
    VertSep.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    VertSep.BorderSizePixel = 0
    VertSep.Position = UDim2.new(0, SIDE_W, 0, 0)
    VertSep.Size = UDim2.new(0, 1, 1, 0)
    VertSep.ZIndex = 6
    VertSep.Parent = Body

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, SIDE_W + 1, 0, 0)
    Content.Size = UDim2.new(1, -(SIDE_W + 1), 1, 0)
    Content.ZIndex = 6
    Content.Parent = Body

    local PagesFolder = Instance.new("Folder")
    PagesFolder.Name = "PagesFolder"
    PagesFolder.Parent = Content

    local PagesLayout = Instance.new("UIPageLayout")
    PagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PagesLayout.Name = "PagesLayout"
    PagesLayout.Parent = PagesFolder
    PagesLayout.TweenTime = 0.35
    PagesLayout.EasingDirection = Enum.EasingDirection.InOut
    PagesLayout.EasingStyle = Enum.EasingStyle.Quad
    PagesLayout.GamepadInputEnabled = false
    PagesLayout.TouchInputEnabled = false

    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Footer.BackgroundTransparency = 0.3
    Footer.BorderSizePixel = 0
    Footer.AnchorPoint = Vector2.new(0, 1)
    Footer.Position = UDim2.new(0, 0, 1, 0)
    Footer.Size = UDim2.new(1, 0, 0, BOTTOM_H)
    Footer.ZIndex = 10
    Footer.Parent = Main

    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(0, 10)
    FC.Parent = Footer

    local FLine = Instance.new("Frame")
    FLine.Name = "FLine"
    FLine.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    FLine.BorderSizePixel = 0
    FLine.Position = UDim2.new(0, 0, 0, 0)
    FLine.Size = UDim2.new(1, 0, 0, 1)
    FLine.ZIndex = 11
    FLine.Parent = Footer

    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Name = "AvatarFrame"
    AvatarFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    AvatarFrame.BorderSizePixel = 0
    AvatarFrame.Position = UDim2.new(0, 12, 0.5, 0)
    AvatarFrame.AnchorPoint = Vector2.new(0, 0.5)
    AvatarFrame.Size = UDim2.new(0, 26, 0, 26)
    AvatarFrame.ZIndex = 12
    AvatarFrame.Parent = Footer

    local AvC = Instance.new("UICorner")
    AvC.CornerRadius = UDim.new(1, 0)
    AvC.Parent = AvatarFrame

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Name = "AvatarImg"
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.ZIndex = 13
    AvatarImg.Parent = AvatarFrame

    local AvIC = Instance.new("UICorner")
    AvIC.CornerRadius = UDim.new(1, 0)
    AvIC.Parent = AvatarImg

    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        if ok and img then AvatarImg.Image = img end
    end)

    local WelcomeL = Instance.new("TextLabel")
    WelcomeL.Name = "WelcomeL"
    WelcomeL.Font = Enum.Font.GothamMedium
    WelcomeL.Text = "Welcome, " .. LocalPlayer.DisplayName
    WelcomeL.TextColor3 = Color3.fromRGB(220, 220, 220)
    WelcomeL.TextSize = 12
    WelcomeL.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeL.TextTruncate = Enum.TextTruncate.AtEnd
    WelcomeL.BackgroundTransparency = 1
    WelcomeL.Position = UDim2.new(0, 46, 0.5, 0)
    WelcomeL.AnchorPoint = Vector2.new(0, 0.5)
    WelcomeL.Size = UDim2.new(0, 180, 1, 0)
    WelcomeL.ZIndex = 12
    WelcomeL.Parent = Footer

    local PillsContainer = Instance.new("Frame")
    PillsContainer.Name = "PillsContainer"
    PillsContainer.BackgroundTransparency = 1
    PillsContainer.AnchorPoint = Vector2.new(1, 0.5)
    PillsContainer.Position = UDim2.new(1, -12, 0.5, 0)
    PillsContainer.Size = UDim2.new(0, 420, 1, 0)
    PillsContainer.ZIndex = 12
    PillsContainer.Parent = Footer

    local PillsLayout = Instance.new("UIListLayout")
    PillsLayout.FillDirection = Enum.FillDirection.Horizontal
    PillsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    PillsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    PillsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PillsLayout.Padding = UDim.new(0, 5)
    PillsLayout.Parent = PillsContainer

    local function MakePill(order)
        local P = Instance.new("Frame")
        P.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        P.BorderSizePixel = 0
        P.LayoutOrder = order
        P.Size = UDim2.new(0, 50, 0, 22)
        P.ZIndex = 13
        P.Parent = PillsContainer

        local PC = Instance.new("UICorner")
        PC.CornerRadius = UDim.new(1, 0)
        PC.Parent = P

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
        L.ZIndex = 14
        L.Parent = P

        return P, L
    end

    local FpsPill, FpsText = MakePill(1)
    local PingPill, PingText = MakePill(2)
    local PremPill, PremText = MakePill(3)
    local ExecPill, ExecText = MakePill(4)

    task.spawn(function()
        while Screen.Parent do
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            FpsText.Text = tostring(fps) .. " FPS"
            task.wait(0.5)
        end
    end)

    task.spawn(function()
        while Screen.Parent do
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

    PremText.Text = GuiConfig.Premium
    ExecText.Text = executorName

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

    local MinIconBtn = Instance.new("ImageButton")
    MinIconBtn.Name = "MinimizeIcon"
    MinIconBtn.Parent = Screen
    MinIconBtn.AnchorPoint = Vector2.new(0.5, 0)
    MinIconBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    MinIconBtn.BorderSizePixel = 0
    MinIconBtn.Position = UDim2.new(0.5, 0, 0, 20)
    MinIconBtn.Size = UDim2.new(0, 56, 0, 56)
    MinIconBtn.Image = GuiConfig.Icon
    MinIconBtn.ScaleType = Enum.ScaleType.Fit
    MinIconBtn.Visible = false
    MinIconBtn.ZIndex = 100

    local MIC = Instance.new("UICorner")
    MIC.CornerRadius = UDim.new(0, 12)
    MIC.Parent = MinIconBtn

    MinBtn.Activated:Connect(function()
        CircleClick(MinBtn, Mouse.X, Mouse.Y)
        ShadowHolder.Visible = false
        MinIconBtn.Visible = true
    end)

    MinIconBtn.Activated:Connect(function()
        MinIconBtn.Visible = false
        ShadowHolder.Visible = true
    end)

    local mDrag, mDragStart, mStartPos
    MinIconBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            mDrag = true
            mDragStart = input.Position
            mStartPos = MinIconBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then mDrag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if mDrag and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mDragStart
            MinIconBtn.Position = UDim2.new(
                mStartPos.X.Scale, mStartPos.X.Offset + delta.X,
                mStartPos.Y.Scale, mStartPos.Y.Offset + delta.Y
            )
        end
    end)

    CloseBtn.Activated:Connect(function()
        CircleClick(CloseBtn, Mouse.X, Mouse.Y)
        Screen:Destroy()
        if CoreGui:FindFirstChild("ToggleUIButton") then
            CoreGui.ToggleUIButton:Destroy()
        end
    end)

    local ToggleBtnGui = Instance.new("ScreenGui")
    ToggleBtnGui.Name = "ToggleUIButton"
    ToggleBtnGui.ResetOnSpawn = false
    ToggleBtnGui.Parent = CoreGui

    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Parent = ToggleBtnGui
    ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 100)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Image = GuiConfig.Icon
    ToggleBtn.ScaleType = Enum.ScaleType.Fit

    ToggleBtn.MouseButton1Click:Connect(function()
        ShadowHolder.Visible = not ShadowHolder.Visible
        ToggleBtnGui.Enabled = not ShadowHolder.Visible
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

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F3 then
            if ShadowHolder and ShadowHolder.Parent then
                ShadowHolder.Visible = not ShadowHolder.Visible
            end
        end
    end)

    MakeDraggable(Header, ShadowHolder)

    local Tabs = {}
    local CountTab = 0

    function Tabs:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""

        local Page = Instance.new("ScrollingFrame")
        Page.Name = "Page"
        Page.ScrollBarThickness = 0
        Page.Active = true
        Page.LayoutOrder = CountTab
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Parent = PagesFolder

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 4)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 8)
        PagePad.PaddingLeft = UDim.new(0, 10)
        PagePad.PaddingRight = UDim.new(0, 10)
        PagePad.Parent = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        local PageTitle = Instance.new("TextLabel")
        PageTitle.Name = "PageTitle"
        PageTitle.Font = Enum.Font.GothamBold
        PageTitle.Text = TabConfig.Name
        PageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        PageTitle.TextSize = 20
        PageTitle.TextXAlignment = Enum.TextXAlignment.Left
        PageTitle.BackgroundTransparency = 1
        PageTitle.LayoutOrder = -10
        PageTitle.Size = UDim2.new(1, 0, 0, 26)
        PageTitle.Parent = Page

        local TabBtn = Instance.new("Frame")
        TabBtn.Name = "TabBtn"
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.LayoutOrder = CountTab
        TabBtn.Size = UDim2.new(0, 40, 0, 40)
        TabBtn.Parent = ScrollTab

        local TBC = Instance.new("UICorner")
        TBC.CornerRadius = UDim.new(0, 8)
        TBC.Parent = TabBtn

        local TBtn = Instance.new("TextButton")
        TBtn.Text = ""
        TBtn.BackgroundTransparency = 1
        TBtn.Size = UDim2.new(1, 0, 1, 0)
        TBtn.Name = "TBtn"
        TBtn.ZIndex = 20
        TBtn.Parent = TabBtn

        local TImg = Instance.new("ImageLabel")
        TImg.BackgroundTransparency = 1
        TImg.AnchorPoint = Vector2.new(0.5, 0.5)
        TImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        TImg.Size = UDim2.new(0, 22, 0, 22)
        TImg.Name = "TImg"
        TImg.ZIndex = 15
        TImg.Parent = TabBtn

        if TabConfig.Icon ~= "" then
            if Icons[TabConfig.Icon] then
                TImg.Image = Icons[TabConfig.Icon]
            else
                TImg.Image = TabConfig.Icon
            end
            TImg.ImageColor3 = Color3.fromRGB(180, 180, 180)
        end

        if CountTab == 0 then
            TabBtn.BackgroundTransparency = 0.85
            TImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end

        TBtn.Activated:Connect(function()
            CircleClick(TBtn, Mouse.X, Mouse.Y)
            if TabBtn.LayoutOrder == PagesLayout.CurrentPage.LayoutOrder then return end
            for _, tf in ScrollTab:GetChildren() do
                if tf.Name == "TabBtn" then
                    TweenService:Create(tf, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
                    local img = tf:FindFirstChild("TImg")
                    if img then
                        TweenService:Create(img, TweenInfo.new(0.25),
                            { ImageColor3 = Color3.fromRGB(180, 180, 180) }):Play()
                    end
                end
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.25), { BackgroundTransparency = 0.85 }):Play()
            TweenService:Create(TImg, TweenInfo.new(0.25),
                { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            PagesLayout:JumpToIndex(TabBtn.LayoutOrder)
        end)

        local Sections = {}
        local CountSection = 0

        function Sections:AddSection(Title, AlwaysOpen)
            Title = Title or "Title"

            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, 0, 0, 34)
            Section.Parent = Page

            local SectionReal = Instance.new("Frame")
            SectionReal.Name = "SectionReal"
            SectionReal.AnchorPoint = Vector2.new(0.5, 0)
            SectionReal.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
            SectionReal.BackgroundTransparency = 0.5
            SectionReal.BorderSizePixel = 0
            SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
            SectionReal.Size = UDim2.new(1, 0, 0, 34)
            SectionReal.Parent = Section

            local SRUC = Instance.new("UICorner")
            SRUC.CornerRadius = UDim.new(0, 6)
            SRUC.Parent = SectionReal

            local SectionBtn = Instance.new("TextButton")
            SectionBtn.Text = ""
            SectionBtn.BackgroundTransparency = 1
            SectionBtn.Size = UDim2.new(1, 0, 1, 0)
            SectionBtn.Name = "SectionBtn"
            SectionBtn.ZIndex = 20
            SectionBtn.Parent = SectionReal

            local ArrowFrame = Instance.new("Frame")
            ArrowFrame.AnchorPoint = Vector2.new(1, 0.5)
            ArrowFrame.BackgroundTransparency = 1
            ArrowFrame.Position = UDim2.new(1, -10, 0.5, 0)
            ArrowFrame.Size = UDim2.new(0, 20, 0, 20)
            ArrowFrame.Name = "ArrowFrame"
            ArrowFrame.Parent = SectionReal

            local Arrow = Instance.new("ImageLabel")
            Arrow.Image = "rbxassetid://16851841101"
            Arrow.ImageColor3 = Color3.fromRGB(200, 200, 200)
            Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(0.5, 0, 0.5, 0)
            Arrow.Rotation = -90
            Arrow.Size = UDim2.new(0, 16, 0, 16)
            Arrow.Name = "Arrow"
            Arrow.Parent = ArrowFrame

            local STitle = Instance.new("TextLabel")
            STitle.Font = Enum.Font.GothamBold
            STitle.Text = Title
            STitle.TextColor3 = Color3.fromRGB(230, 230, 230)
            STitle.TextSize = 14
            STitle.TextXAlignment = Enum.TextXAlignment.Left
            STitle.BackgroundTransparency = 1
            STitle.AnchorPoint = Vector2.new(0, 0.5)
            STitle.Position = UDim2.new(0, 14, 0.5, 0)
            STitle.Size = UDim2.new(1, -50, 0, 20)
            STitle.Name = "STitle"
            STitle.Parent = SectionReal

            local SectionAdd = Instance.new("Frame")
            SectionAdd.Name = "SectionAdd"
            SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
            SectionAdd.BackgroundTransparency = 1
            SectionAdd.ClipsDescendants = true
            SectionAdd.LayoutOrder = 1
            SectionAdd.Position = UDim2.new(0.5, 0, 0, 40)
            SectionAdd.Size = UDim2.new(1, 0, 0, 0)
            SectionAdd.Parent = Section

            local SAL = Instance.new("UIListLayout")
            SAL.Padding = UDim.new(0, 3)
            SAL.SortOrder = Enum.SortOrder.LayoutOrder
            SAL.Parent = SectionAdd

            local OpenSection = false
            local Animating = false
            local AT = 0.22

            local function UpdateSizeScroll()
                local total = 0
                for _, c in Page:GetChildren() do
                    if c.Name == "Section" then
                        total = total + 4 + c.Size.Y.Offset
                    end
                end
                Page.CanvasSize = UDim2.new(0, 0, 0, total + 60)
            end

            local function UpdateSizeSection()
                if OpenSection then
                    local total = 40
                    for _, v in SectionAdd:GetChildren() do
                        if v.Name ~= "UIListLayout" then
                            total = total + v.Size.Y.Offset + 3
                        end
                    end
                    local ti = TweenInfo.new(AT, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    TweenService:Create(Arrow, ti, { Rotation = 0 }):Play()
                    TweenService:Create(Section, ti, { Size = UDim2.new(1, 0, 0, total) }):Play()
                    TweenService:Create(SectionAdd, ti, { Size = UDim2.new(1, 0, 0, total - 40) }):Play()
                    task.delay(AT, UpdateSizeScroll)
                end
            end

            if AlwaysOpen == true then
                SectionBtn:Destroy()
                ArrowFrame:Destroy()
                OpenSection = true
                UpdateSizeSection()
            elseif AlwaysOpen == false then
                OpenSection = false
            else
                OpenSection = true
                UpdateSizeSection()
            end

            if AlwaysOpen ~= true then
                SectionBtn.Activated:Connect(function()
                    if Animating then return end
                    Animating = true
                    CircleClick(SectionBtn, Mouse.X, Mouse.Y)
                    local ti = TweenInfo.new(AT, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    if OpenSection then
                        TweenService:Create(Arrow, ti, { Rotation = -90 }):Play()
                        TweenService:Create(Section, ti, { Size = UDim2.new(1, 0, 0, 34) }):Play()
                        OpenSection = false
                        task.delay(AT, function()
                            UpdateSizeScroll()
                            Animating = false
                        end)
                    else
                        OpenSection = true
                        UpdateSizeSection()
                        task.delay(AT, function() Animating = false end)
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

                local T = Instance.new("Frame")
                T.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                T.BackgroundTransparency = 0.94
                T.BorderSizePixel = 0
                T.LayoutOrder = CountItem
                T.Size = UDim2.new(1, 0, 0, 46)
                T.Name = "Toggle"
                T.Parent = SectionAdd

                local TUC = Instance.new("UICorner")
                TUC.CornerRadius = UDim.new(0, 4)
                TUC.Parent = T

                local TT = Instance.new("TextLabel")
                TT.Font = Enum.Font.GothamBold
                TT.Text = ToggleConfig.Title
                TT.TextSize = 14
                TT.TextColor3 = Color3.fromRGB(231, 231, 231)
                TT.TextXAlignment = Enum.TextXAlignment.Left
                TT.BackgroundTransparency = 1
                TT.Position = UDim2.new(0, 12, 0, 10)
                TT.Size = UDim2.new(1, -80, 0, 14)
                TT.Name = "TT"
                TT.Parent = T

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
                TContent.Name = "TContent"
                TContent.Parent = T

                local TBtn = Instance.new("TextButton")
                TBtn.Text = ""
                TBtn.BackgroundTransparency = 1
                TBtn.Size = UDim2.new(1, 0, 1, 0)
                TBtn.Name = "TBtn"
                TBtn.ZIndex = 20
                TBtn.Parent = T

                local TSwitch = Instance.new("Frame")
                TSwitch.AnchorPoint = Vector2.new(1, 0.5)
                TSwitch.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                TSwitch.BorderSizePixel = 0
                TSwitch.Position = UDim2.new(1, -14, 0.5, 0)
                TSwitch.Size = UDim2.new(0, 32, 0, 16)
                TSwitch.Name = "TSwitch"
                TSwitch.Parent = T

                local TSIC = Instance.new("UICorner")
                TSIC.CornerRadius = UDim.new(1, 0)
                TSIC.Parent = TSwitch

                local TCircle = Instance.new("Frame")
                TCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                TCircle.BorderSizePixel = 0
                TCircle.AnchorPoint = Vector2.new(0, 0.5)
                TCircle.Position = UDim2.new(0, 2, 0.5, 0)
                TCircle.Size = UDim2.new(0, 12, 0, 12)
                TCircle.Name = "TCircle"
                TCircle.Parent = TSwitch

                local TCIC = Instance.new("UICorner")
                TCIC.CornerRadius = UDim.new(1, 0)
                TCIC.Parent = TCircle

                TBtn.Activated:Connect(function()
                    ToggleFunc.Value = not ToggleFunc.Value
                    ToggleFunc:Set(ToggleFunc.Value)
                end)

                function ToggleFunc:Set(Value)
                    ToggleFunc.Value = Value
                    ConfigData[configKey] = Value
                    if Value then
                        TweenService:Create(TT, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
                        TweenService:Create(TCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 16, 0.5, 0) }):Play()
                        TweenService:Create(TSwitch, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color }):Play()
                    else
                        TweenService:Create(TT, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(231, 231, 231) }):Play()
                        TweenService:Create(TCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, 0) }):Play()
                        TweenService:Create(TSwitch, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(60, 60, 65) }):Play()
                    end
                    task.spawn(function()
                        local ok, err = pcall(ToggleConfig.Callback, Value)
                        if not ok then warn("Toggle error:", err) end
                    end)
                end

                ToggleFunc:Set(ToggleConfig.Default)
                CountItem = CountItem + 1
                ToggleFunc.Type = "Toggle"
                Elements[configKey] = ToggleFunc
                return ToggleFunc
            end

            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Title = ButtonConfig.Title or "Confirm"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                ButtonConfig.SubTitle = ButtonConfig.SubTitle or nil
                ButtonConfig.SubCallback = ButtonConfig.SubCallback or function() end

                local B = Instance.new("Frame")
                B.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                B.BackgroundTransparency = 0.94
                B.BorderSizePixel = 0
                B.LayoutOrder = CountItem
                B.Size = UDim2.new(1, 0, 0, 38)
                B.Name = "Button"
                B.Parent = SectionAdd

                local BUC = Instance.new("UICorner")
                BUC.CornerRadius = UDim.new(0, 4)
                BUC.Parent = B

                local MB = Instance.new("TextButton")
                MB.Font = Enum.Font.GothamBold
                MB.Text = ButtonConfig.Title
                MB.TextSize = 14
                MB.TextColor3 = Color3.fromRGB(255, 255, 255)
                MB.TextTransparency = 0.2
                MB.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                MB.BackgroundTransparency = 0.94
                MB.Size = ButtonConfig.SubTitle
                    and UDim2.new(0.5, -6, 1, -8)
                    or UDim2.new(1, -12, 1, -8)
                MB.Position = UDim2.new(0, 6, 0, 4)
                MB.Name = "MB"
                MB.ZIndex = 20
                MB.Parent = B

                local MBC = Instance.new("UICorner")
                MBC.CornerRadius = UDim.new(0, 4)
                MBC.Parent = MB

                MB.MouseButton1Click:Connect(function()
                    CircleClick(MB, Mouse.X, Mouse.Y)
                    ButtonConfig.Callback()
                end)

                if ButtonConfig.SubTitle then
                    local SB = Instance.new("TextButton")
                    SB.Font = Enum.Font.GothamBold
                    SB.Text = ButtonConfig.SubTitle
                    SB.TextSize = 14
                    SB.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SB.TextTransparency = 0.2
                    SB.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    SB.BackgroundTransparency = 0.94
                    SB.Size = UDim2.new(0.5, -6, 1, -8)
                    SB.Position = UDim2.new(0.5, 0, 0, 4)
                    SB.Name = "SB"
                    SB.ZIndex = 20
                    SB.Parent = B

                    local SBC = Instance.new("UICorner")
                    SBC.CornerRadius = UDim.new(0, 4)
                    SBC.Parent = SB

                    SB.MouseButton1Click:Connect(function()
                        CircleClick(SB, Mouse.X, Mouse.Y)
                        ButtonConfig.SubCallback()
                    end)
                end

                CountItem = CountItem + 1
            end

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

                local S = Instance.new("Frame")
                S.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                S.BackgroundTransparency = 0.94
                S.BorderSizePixel = 0
                S.LayoutOrder = CountItem
                S.Size = UDim2.new(1, 0, 0, 50)
                S.Name = "Slider"
                S.Parent = SectionAdd

                local SUC = Instance.new("UICorner")
                SUC.CornerRadius = UDim.new(0, 4)
                SUC.Parent = S

                local ST = Instance.new("TextLabel")
                ST.Font = Enum.Font.GothamBold
                ST.Text = SliderConfig.Title
                ST.TextColor3 = Color3.fromRGB(230, 230, 230)
                ST.TextSize = 14
                ST.TextXAlignment = Enum.TextXAlignment.Left
                ST.BackgroundTransparency = 1
                ST.Position = UDim2.new(0, 12, 0, 8)
                ST.Size = UDim2.new(1, -100, 0, 14)
                ST.Name = "ST"
                ST.Parent = S

                local SV = Instance.new("TextLabel")
                SV.Font = Enum.Font.GothamBold
                SV.Text = tostring(SliderConfig.Default)
                SV.TextColor3 = Color3.fromRGB(255, 255, 255)
                SV.TextSize = 14
                SV.TextXAlignment = Enum.TextXAlignment.Right
                SV.BackgroundTransparency = 1
                SV.AnchorPoint = Vector2.new(1, 0)
                SV.Position = UDim2.new(1, -12, 0, 8)
                SV.Size = UDim2.new(0, 50, 0, 14)
                SV.Name = "SV"
                SV.Parent = S

                local SBar = Instance.new("Frame")
                SBar.AnchorPoint = Vector2.new(0.5, 1)
                SBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                SBar.BorderSizePixel = 0
                SBar.Position = UDim2.new(0.5, 0, 1, -10)
                SBar.Size = UDim2.new(1, -24, 0, 4)
                SBar.Name = "SBar"
                SBar.Parent = S

                local SBUC = Instance.new("UICorner")
                SBUC.CornerRadius = UDim.new(1, 0)
                SBUC.Parent = SBar

                local SFill = Instance.new("Frame")
                SFill.AnchorPoint = Vector2.new(0, 0.5)
                SFill.BackgroundColor3 = GuiConfig.Color
                SFill.BorderSizePixel = 0
                SFill.Position = UDim2.new(0, 0, 0.5, 0)
                SFill.Size = UDim2.new(0, 0, 1, 0)
                SFill.Name = "SFill"
                SFill.Parent = SBar

                local SFUC = Instance.new("UICorner")
                SFUC.CornerRadius = UDim.new(1, 0)
                SFUC.Parent = SFill

                local SBtn = Instance.new("TextButton")
                SBtn.Text = ""
                SBtn.BackgroundTransparency = 1
                SBtn.Size = UDim2.new(1, 0, 1, 0)
                SBtn.Name = "SBtn"
                SBtn.ZIndex = 20
                SBtn.Parent = SBar

                local Dragging = false
                local function Round(Number, Factor)
                    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
                    if Result < 0 then Result = Result + Factor end
                    return Result
                end

                function SliderFunc:Set(Value)
                    Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    SliderFunc.Value = Value
                    SV.Text = tostring(Value)
                    local ratio = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    TweenService:Create(SFill, TweenInfo.new(0.15), { Size = UDim2.new(ratio, 0, 1, 0) }):Play()
                    SliderConfig.Callback(Value)
                    ConfigData[configKey] = Value
                end

                SBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        local ratio = math.clamp((input.Position.X - SBar.AbsolutePosition.X) / SBar.AbsoluteSize.X, 0, 1)
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
                        local ratio = math.clamp((input.Position.X - SBar.AbsolutePosition.X) / SBar.AbsoluteSize.X, 0, 1)
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * ratio))
                    end
                end)

                SliderFunc:Set(SliderConfig.Default)
                CountItem = CountItem + 1
                SliderFunc.Type = "Slider"
                Elements[configKey] = SliderFunc
                return SliderFunc
            end

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

                local I = Instance.new("Frame")
                I.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                I.BackgroundTransparency = 0.94
                I.BorderSizePixel = 0
                I.LayoutOrder = CountItem
                I.Size = UDim2.new(1, 0, 0, 46)
                I.Name = "Input"
                I.Parent = SectionAdd

                local IUC = Instance.new("UICorner")
                IUC.CornerRadius = UDim.new(0, 4)
                IUC.Parent = I

                local IT = Instance.new("TextLabel")
                IT.Font = Enum.Font.GothamBold
                IT.Text = InputConfig.Title
                IT.TextColor3 = Color3.fromRGB(230, 230, 230)
                IT.TextSize = 14
                IT.TextXAlignment = Enum.TextXAlignment.Left
                IT.BackgroundTransparency = 1
                IT.Position = UDim2.new(0, 12, 0, 10)
                IT.Size = UDim2.new(1, -160, 0, 14)
                IT.Name = "IT"
                IT.Parent = I

                local IC = Instance.new("TextLabel")
                IC.Font = Enum.Font.Gotham
                IC.Text = InputConfig.Content
                IC.TextColor3 = Color3.fromRGB(160, 160, 160)
                IC.TextSize = 12
                IC.TextXAlignment = Enum.TextXAlignment.Left
                IC.BackgroundTransparency = 1
                IC.Position = UDim2.new(0, 12, 0, 26)
                IC.Size = UDim2.new(1, -160, 0, 12)
                IC.TextWrapped = true
                IC.Name = "IC"
                IC.Parent = I

                local IBox = Instance.new("Frame")
                IBox.AnchorPoint = Vector2.new(1, 0.5)
                IBox.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
                IBox.BorderSizePixel = 0
                IBox.Position = UDim2.new(1, -10, 0.5, 0)
                IBox.Size = UDim2.new(0, 140, 0, 28)
                IBox.Name = "IBox"
                IBox.Parent = I

                local IBUC = Instance.new("UICorner")
                IBUC.CornerRadius = UDim.new(0, 4)
                IBUC.Parent = IBox

                local ITB = Instance.new("TextBox")
                ITB.Font = Enum.Font.Gotham
                ITB.PlaceholderText = InputConfig.Placeholder or "Input"
                ITB.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                ITB.Text = InputConfig.Default
                ITB.TextColor3 = Color3.fromRGB(255, 255, 255)
                ITB.TextSize = 13
                ITB.TextXAlignment = Enum.TextXAlignment.Left
                ITB.BackgroundTransparency = 1
                ITB.Position = UDim2.new(0, 8, 0, 0)
                ITB.Size = UDim2.new(1, -16, 1, 0)
                ITB.ClearTextOnFocus = false
                ITB.Name = "ITB"
                ITB.ZIndex = 20
                ITB.Parent = IBox

                function InputFunc:Set(Value)
                    ITB.Text = Value
                    InputFunc.Value = Value
                    ConfigData[configKey] = Value
                    InputConfig.Callback(Value)
                end

                InputFunc:Set(InputConfig.Default)

                ITB.FocusLost:Connect(function()
                    InputFunc:Set(ITB.Text)
                end)

                CountItem = CountItem + 1
                InputFunc.Type = "Input"
                Elements[configKey] = InputFunc
                return InputFunc
            end

            function Items:AddDivider()
                local D = Instance.new("Frame")
                D.Name = "Divider"
                D.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                D.BorderSizePixel = 0
                D.LayoutOrder = CountItem
                D.Size = UDim2.new(1, 0, 0, 1)
                D.Parent = SectionAdd

                CountItem = CountItem + 1
                return D
            end

            function Items:AddParagraph(ParaConfig)
                ParaConfig = ParaConfig or {}
                ParaConfig.Title = ParaConfig.Title or "Title"
                ParaConfig.Content = ParaConfig.Content or "Content"
                local ParaFunc = {}

                local P = Instance.new("Frame")
                P.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                P.BackgroundTransparency = 0.94
                P.BorderSizePixel = 0
                P.LayoutOrder = CountItem
                P.Size = UDim2.new(1, 0, 0, 46)
                P.Name = "Paragraph"
                P.Parent = SectionAdd

                local PUC = Instance.new("UICorner")
                PUC.CornerRadius = UDim.new(0, 4)
                PUC.Parent = P

                local PT = Instance.new("TextLabel")
                PT.Font = Enum.Font.GothamBold
                PT.Text = ParaConfig.Title
                PT.TextColor3 = Color3.fromRGB(231, 231, 231)
                PT.TextSize = 14
                PT.TextXAlignment = Enum.TextXAlignment.Left
                PT.BackgroundTransparency = 1
                PT.Position = UDim2.new(0, 12, 0, 10)
                PT.Size = UDim2.new(1, -24, 0, 14)
                PT.Name = "PT"
                PT.Parent = P

                local PC = Instance.new("TextLabel")
                PC.Font = Enum.Font.Gotham
                PC.Text = ParaConfig.Content
                PC.TextColor3 = Color3.fromRGB(180, 180, 180)
                PC.TextSize = 12
                PC.TextXAlignment = Enum.TextXAlignment.Left
                PC.TextYAlignment = Enum.TextYAlignment.Top
                PC.BackgroundTransparency = 1
                PC.Position = UDim2.new(0, 12, 0, 26)
                PC.Size = UDim2.new(1, -24, 0, 12)
                PC.TextWrapped = true
                PC.Name = "PC"
                PC.Parent = P

                local function UpdateSize()
                    P.Size = UDim2.new(1, 0, 0, PC.TextBounds.Y + 34)
                end
                UpdateSize()
                PC:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)

                function ParaFunc:SetContent(c)
                    PC.Text = c or "Content"
                    UpdateSize()
                end

                CountItem = CountItem + 1
                return ParaFunc
            end

            function Items:AddDropdown(DDConfig)
                DDConfig = DDConfig or {}
                DDConfig.Title = DDConfig.Title or "Dropdown"
                DDConfig.Content = DDConfig.Content or ""
                DDConfig.Options = DDConfig.Options or {}
                DDConfig.Default = DDConfig.Default or nil
                DDConfig.Callback = DDConfig.Callback or function() end

                local configKey = "Dropdown_" .. DDConfig.Title
                if ConfigData[configKey] ~= nil then
                    DDConfig.Default = ConfigData[configKey]
                end

                local DDFunc = { Value = DDConfig.Default }

                local D = Instance.new("Frame")
                D.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                D.BackgroundTransparency = 0.94
                D.BorderSizePixel = 0
                D.LayoutOrder = CountItem
                D.Size = UDim2.new(1, 0, 0, 46)
                D.Name = "Dropdown"
                D.Parent = SectionAdd

                local DUC = Instance.new("UICorner")
                DUC.CornerRadius = UDim.new(0, 4)
                DUC.Parent = D

                local DT = Instance.new("TextLabel")
                DT.Font = Enum.Font.GothamBold
                DT.Text = DDConfig.Title
                DT.TextColor3 = Color3.fromRGB(230, 230, 230)
                DT.TextSize = 14
                DT.TextXAlignment = Enum.TextXAlignment.Left
                DT.BackgroundTransparency = 1
                DT.Position = UDim2.new(0, 12, 0, 10)
                DT.Size = UDim2.new(1, -160, 0, 14)
                DT.Name = "DT"
                DT.Parent = D

                local DC = Instance.new("TextLabel")
                DC.Font = Enum.Font.Gotham
                DC.Text = DDConfig.Content
                DC.TextColor3 = Color3.fromRGB(160, 160, 160)
                DC.TextSize = 12
                DC.TextXAlignment = Enum.TextXAlignment.Left
                DC.BackgroundTransparency = 1
                DC.Position = UDim2.new(0, 12, 0, 26)
                DC.Size = UDim2.new(1, -160, 0, 12)
                DC.TextWrapped = true
                DC.Name = "DC"
                DC.Parent = D

                local DBox = Instance.new("Frame")
                DBox.AnchorPoint = Vector2.new(1, 0.5)
                DBox.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
                DBox.BorderSizePixel = 0
                DBox.Position = UDim2.new(1, -10, 0.5, 0)
                DBox.Size = UDim2.new(0, 140, 0, 28)
                DBox.Name = "DBox"
                DBox.Parent = D

                local DBUC = Instance.new("UICorner")
                DBUC.CornerRadius = UDim.new(0, 4)
                DBUC.Parent = DBox

                local DSel = Instance.new("TextLabel")
                DSel.Font = Enum.Font.Gotham
                DSel.Text = "Select..."
                DSel.TextColor3 = Color3.fromRGB(180, 180, 180)
                DSel.TextSize = 13
                DSel.TextXAlignment = Enum.TextXAlignment.Left
                DSel.BackgroundTransparency = 1
                DSel.Position = UDim2.new(0, 10, 0, 0)
                DSel.Size = UDim2.new(1, -30, 1, 0)
                DSel.Name = "DSel"
                DSel.Parent = DBox

                local DArrow = Instance.new("ImageLabel")
                DArrow.Image = "rbxassetid://16851841101"
                DArrow.ImageColor3 = Color3.fromRGB(180, 180, 180)
                DArrow.AnchorPoint = Vector2.new(1, 0.5)
                DArrow.BackgroundTransparency = 1
                DArrow.Position = UDim2.new(1, -5, 0.5, 0)
                DArrow.Rotation = 90
                DArrow.Size = UDim2.new(0, 14, 0, 14)
                DArrow.Name = "DArrow"
                DArrow.Parent = DBox

                local DBtn = Instance.new("TextButton")
                DBtn.Text = ""
                DBtn.BackgroundTransparency = 1
                DBtn.Size = UDim2.new(1, 0, 1, 0)
                DBtn.Name = "DBtn"
                DBtn.ZIndex = 20
                DBtn.Parent = DBox

                local Popup = Instance.new("Frame")
                Popup.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
                Popup.BorderSizePixel = 0
                Popup.Size = UDim2.new(0, 200, 0, 150)
                Popup.Position = UDim2.new(0, 0, 0, 0)
                Popup.Visible = false
                Popup.ZIndex = 100
                Popup.Name = "Popup"
                Popup.Parent = Main

                local PUC = Instance.new("UICorner")
                PUC.CornerRadius = UDim.new(0, 6)
                PUC.Parent = Popup

                local PStr = Instance.new("UIStroke")
                PStr.Color = GuiConfig.Color
                PStr.Thickness = 1.5
                PStr.Parent = Popup

                local PList = Instance.new("ScrollingFrame")
                PList.ScrollBarThickness = 0
                PList.BackgroundTransparency = 1
                PList.BorderSizePixel = 0
                PList.Size = UDim2.new(1, -8, 1, -8)
                PList.Position = UDim2.new(0, 4, 0, 4)
                PList.CanvasSize = UDim2.new(0, 0, 0, 0)
                PList.Name = "PList"
                PList.ZIndex = 101
                PList.Parent = Popup

                local PLL = Instance.new("UIListLayout")
                PLL.Padding = UDim.new(0, 3)
                PLL.SortOrder = Enum.SortOrder.LayoutOrder
                PLL.Parent = PList

                PLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    PList.CanvasSize = UDim2.new(0, 0, 0, PLL.AbsoluteContentSize.Y + 8)
                end)

                local maxW = 150
                for _, rawOpt in ipairs(DDConfig.Options) do
                    local label = tostring(rawOpt)
                    local tb = TextService:GetTextSize(label, 13, Enum.Font.Gotham, Vector2.new(1000, 30))
                    if tb.X + 30 > maxW then maxW = tb.X + 30 end

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
                    Opt.ZIndex = 102
                    Opt.Parent = PList

                    local OC = Instance.new("UICorner")
                    OC.CornerRadius = UDim.new(0, 4)
                    OC.Parent = Opt

                    Opt.MouseButton1Click:Connect(function()
                        DDFunc:Set(label)
                        Popup.Visible = false
                        DArrow.Rotation = 90
                    end)
                end

                Popup.Size = UDim2.new(0, maxW, 0, math.min(150, (#DDConfig.Options * 31) + 8))

                function DDFunc:Set(Value)
                    DDFunc.Value = Value
                    if Value and Value ~= "" then
                        DSel.Text = tostring(Value)
                        DSel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        DSel.Text = "Select..."
                        DSel.TextColor3 = Color3.fromRGB(180, 180, 180)
                    end
                    ConfigData[configKey] = Value
                    DDConfig.Callback(Value)
                end

                DBtn.MouseButton1Click:Connect(function()
                    Popup.Visible = not Popup.Visible
                    if Popup.Visible then
                        local boxPos = DBox.AbsolutePosition
                        local mainPos = Main.AbsolutePosition
                        local relX = boxPos.X - mainPos.X
                        local relY = boxPos.Y - mainPos.Y + DBox.AbsoluteSize.Y + 2
                        Popup.Position = UDim2.new(0, relX + DBox.AbsoluteSize.X - Popup.AbsoluteSize.X, 0, relY)
                        DArrow.Rotation = -90
                    else
                        DArrow.Rotation = 90
                    end
                end)

                DDFunc:Set(DDConfig.Default)

                CountItem = CountItem + 1
                DDFunc.Type = "Dropdown"
                Elements[configKey] = DDFunc
                return DDFunc
            end

            CountSection = CountSection + 1
            return Items
        end

        CountTab = CountTab + 1
        return Sections
    end

    return Tabs
end

return ZuperMing