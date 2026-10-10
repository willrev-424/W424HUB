local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

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
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and type(result) == "table" then
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
            if targetValue ~= nil then element:Set(targetValue)
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
    info = "rbxassetid://10723415903", main = "rbxassetid://10723407389", auto = "rbxassetid://10734923214",
    shop = "rbxassetid://10734952479", teleport = "rbxassetid://10734886004", event = "rbxassetid://10709789505",
    webhook = "rbxassetid://10709775560", peformance = "rbxassetid://10734963400", misc = "rbxassetid://10734972862",
    config = "rbxassetid://10734950309", 
}

local function isMobileDevice()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end
local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local scaleX = pxWidth / viewport.X
    local scaleY = pxHeight / viewport.Y
    if isMobile then
        if scaleX > 0.5 then scaleX = 0.5 end
        if scaleY > 0.3 then scaleY = 0.3 end
    end
    return UDim2.new(scaleX, 0, scaleY, 0)
end

local function MakeDraggable(topbarobject, object)
    local function CustomPos(topbarobject, object)
        local Dragging, DragInput, DragStart, StartPosition
        local function UpdatePos(input)
            local Delta = input.Position - DragStart
            local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
            TweenService:Create(object, TweenInfo.new(0.2), { Position = pos }):Play()
        end
        topbarobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true; DragStart = input.Position; StartPosition = object.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then Dragging = false end
                end)
            end
        end)
        topbarobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then UpdatePos(input) end
        end)
    end

    local function CustomSize(object)
        local Dragging, DragInput, DragStart, StartSize
        local minSizeX, minSizeY = 100, 100
        local defSizeX, defSizeY = isMobile and 470 or 640, isMobile and 270 or 400
        object.Size = UDim2.new(0, defSizeX, 0, defSizeY)

        local changesizeobject = Instance.new("Frame")
        changesizeobject.AnchorPoint = Vector2.new(1, 1)
        changesizeobject.BackgroundTransparency = 1
        changesizeobject.Size = UDim2.new(0, 40, 0, 40)
        changesizeobject.Position = UDim2.new(1, 20, 1, 20)
        changesizeobject.Name = "changesizeobject"
        changesizeobject.Parent = object

        local function UpdateSize(input)
            local Delta = input.Position - DragStart
            local newWidth = math.max(StartSize.X.Offset + Delta.X, minSizeX)
            local newHeight = math.max(StartSize.Y.Offset + Delta.Y, minSizeY)
            TweenService:Create(object, TweenInfo.new(0.2), { Size = UDim2.new(0, newWidth, 0, newHeight) }):Play()
        end

        changesizeobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true; DragStart = input.Position; StartSize = object.Size
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then Dragging = false end
                end)
            end
        end)
        changesizeobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then UpdateSize(input) end
        end)
    end
    CustomSize(object)
    CustomPos(topbarobject, object)
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
        Circle.Name = "Circle"
        Circle.Parent = Button
        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then Size = Button.AbsoluteSize.Y * 1.5
        elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then Size = Button.AbsoluteSize.X * 1.5 end
        local Time = 0.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size / 2, 0.5, -Size / 2), "Out", "Quad", Time, false, nil)
        for i = 1, 10 do Circle.ImageTransparency = Circle.ImageTransparency + 0.01; wait(Time / 10) end
        Circle:Destroy()
    end)
end

-- AUTO DETECT EXECUTOR
local function GetExecutorName()
    local executors = {
        ["Solara"]="Solara", ["Delta"]="Delta", ["Xeno"]="Xeno", ["Wave"]="Wave", ["Codex"]="Codex",
        ["Arceus X"]="Arceus X", ["ArceusX"]="Arceus X", ["Fluxus"]="Fluxus", ["Hydrogen"]="Hydrogen",
        ["Krnl"]="Krnl", ["Synapse"]="Synapse", ["ScriptWare"]="ScriptWare", ["Vega"]="Vega",
        ["AWP"]="AWP", ["Swift"]="Swift", ["Evon"]="Evon", ["Cryptic"]="Cryptic", ["Oxygen"]="Oxygen",
        ["Trigon"]="Trigon", ["Valyse"]="Valyse", ["Nihon"]="Nihon", ["MacSploit"]="MacSploit",
        ["Sirhurt"]="Sirhurt", ["Sentinel"]="Sentinel", ["Ryu"]="Ryu", ["Kiwi"]="Kiwi", ["Bunni"]="Bunni",
        ["RbxStu"]="RbxStu", ["Severe"]="Severe", ["JJSploit"]="JJSploit",
    }
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name and name ~= "" then
            for key, val in pairs(executors) do
                if string.find(string.lower(name), string.lower(key)) then return val end
            end
            return name
        end
    end
    if getexecutorname then
        local ok, name = pcall(getexecutorname)
        if ok and name and name ~= "" then return name end
    end
    if getexploitlevel then return "Executor Lv." .. tostring(getexploitlevel()) end
    return "Unknown"
end

local ZuperMing = {}

function ZuperMing:MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "ZuperMing"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(55, 70, 255)
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5
    
    local NotifyFunction = {}
    spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui"); NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; NotifyGui.Name = "NotifyGui"; NotifyGui.Parent = CoreGui
        end
        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame"); NotifyLayout.AnchorPoint = Vector2.new(1, 1); NotifyLayout.BackgroundTransparency = 1; NotifyLayout.Position = UDim2.new(1, -20, 1, -20); NotifyLayout.Size = UDim2.new(0, 300, 1, 0); NotifyLayout.Name = "NotifyLayout"; NotifyLayout.Parent = CoreGui.NotifyGui
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 8) * Count)) }):Play()
                    Count = Count + 1
                end
            end)
        end
        local NotifyPosHeigh = 0
        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 8 end

        local CalculationWidth = 240 
        local ContentBounds = TextService:GetTextSize(NotifyConfig.Content, 13, Enum.Font.GothamBold, Vector2.new(CalculationWidth, 9999))
        local TextHeight = ContentBounds.Y
        local HeaderHeight = 30
        local BottomPadding = 12
        local TotalFrameHeight = HeaderHeight + TextHeight + BottomPadding
        if TotalFrameHeight < 55 then TotalFrameHeight = 55 end

        local NotifyFrame = Instance.new("Frame"); local NotifyFrameReal = Instance.new("Frame"); local UICorner = Instance.new("UICorner"); local Top = Instance.new("Frame"); local TextLabel = Instance.new("TextLabel"); local TextLabel1 = Instance.new("TextLabel"); local Close = Instance.new("TextButton"); local ImageLabel = Instance.new("ImageLabel"); local TextLabel2 = Instance.new("TextLabel"); 
        NotifyFrame.Name = "NotifyFrame"; NotifyFrame.BackgroundTransparency = 1; NotifyFrame.Size = UDim2.new(1, 0, 0, TotalFrameHeight); NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout; NotifyFrame.AnchorPoint = Vector2.new(0, 1); NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))
        NotifyFrameReal.Name = "NotifyFrameReal"; NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(25, 25, 30); NotifyFrameReal.BorderSizePixel = 0; NotifyFrameReal.Position = UDim2.new(0, 350, 0, 0); NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0); NotifyFrameReal.Parent = NotifyFrame
        UICorner.Parent = NotifyFrameReal; UICorner.CornerRadius = UDim.new(0, 6)
        Top.Name = "Top"; Top.BackgroundTransparency = 1; Top.Size = UDim2.new(1, 0, 0, HeaderHeight); Top.Parent = NotifyFrameReal
        TextLabel.Font = Enum.Font.GothamBold; TextLabel.Text = NotifyConfig.Title; TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255); TextLabel.TextSize = 12; TextLabel.TextXAlignment = Enum.TextXAlignment.Left; TextLabel.BackgroundTransparency = 1; TextLabel.AutomaticSize = Enum.AutomaticSize.X; TextLabel.Size = UDim2.new(0, 0, 1, 0); TextLabel.Position = UDim2.new(0, 8, 0, 0); TextLabel.Parent = Top
        TextLabel1.Font = Enum.Font.GothamBold; TextLabel1.Text = NotifyConfig.Description; TextLabel1.TextColor3 = NotifyConfig.Color; TextLabel1.TextSize = 12; TextLabel1.TextXAlignment = Enum.TextXAlignment.Left; TextLabel1.BackgroundTransparency = 1; TextLabel1.AutomaticSize = Enum.AutomaticSize.X; TextLabel1.Size = UDim2.new(0, 0, 1, 0); TextLabel1.Parent = Top
        task.defer(function() TextLabel1.Position = UDim2.new(0, TextLabel.AbsoluteSize.X + 10, 0, 0) end)
        Close.Name = "Close"; Close.Text = ""; Close.BackgroundTransparency = 1; Close.AnchorPoint = Vector2.new(1, 0.5); Close.Position = UDim2.new(1, -5, 0.5, 0); Close.Size = UDim2.new(0, 20, 0, 20); Close.Parent = Top
        ImageLabel.Image = "rbxassetid://9886659671"; ImageLabel.BackgroundTransparency = 1; ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5); ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0); ImageLabel.Size = UDim2.new(0.6, 0, 0.6, 0); ImageLabel.Parent = Close
        TextLabel2.Name = "Content"; TextLabel2.Font = Enum.Font.Gotham; TextLabel2.Text = NotifyConfig.Content; TextLabel2.TextColor3 = Color3.fromRGB(180, 180, 180); TextLabel2.TextSize = 12; TextLabel2.BackgroundTransparency = 1; TextLabel2.TextXAlignment = Enum.TextXAlignment.Left; TextLabel2.TextYAlignment = Enum.TextYAlignment.Top; TextLabel2.TextWrapped = true; TextLabel2.AutomaticSize = Enum.AutomaticSize.Y; TextLabel2.Position = UDim2.new(0, 8, 0, HeaderHeight); TextLabel2.Size = UDim2.new(1, -16, 0, 0); TextLabel2.Parent = NotifyFrameReal

        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then return false end; waitbruh = true
            TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.In), { Position = UDim2.new(0, 350, 0, 0) }):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2); NotifyFrame:Destroy()
        end
        Close.Activated:Connect(function() NotifyFunction:Close() end)
        TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
        task.wait(tonumber(NotifyConfig.Delay)); NotifyFunction:Close()
    end)
    return NotifyFunction
end

function notif(msg, delay, color, title, desc)
    return ZuperMing:MakeNotify({ Title = title or "ZuperMing", Description = desc or "Notification", Content = msg or "Content", Color = color or Color3.fromRGB(232, 145, 234), Delay = delay or 4 })
end

-- =========================================================
-- BAGIAN UTAMA WINDOW
-- =========================================================
function ZuperMing:Window(GuiConfig)
    GuiConfig              = GuiConfig or {}
    GuiConfig.Title        = GuiConfig.Title or "Sena 6.2"
    GuiConfig.Footer       = GuiConfig.Footer or GetExecutorName()
    GuiConfig.ExecutorOverride = GuiConfig.ExecutorOverride or nil
    GuiConfig.Color        = GuiConfig.Color or Color3.fromRGB(50, 100, 255) 
    GuiConfig.BackgroundColor = GuiConfig.BackgroundColor or Color3.fromRGB(15, 15, 20)
    GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 130
    GuiConfig.Version      = GuiConfig.Version or 1
    GuiConfig.Icon         = GuiConfig.Icon or "rbxassetid://104396282819940" 
    GuiConfig.GameName     = GuiConfig.GameName or "Steal An Egg"
    GuiConfig.IsPremium    = GuiConfig.IsPremium or false 
    GuiConfig.LogoBg       = GuiConfig.LogoBg or "rbxassetid://104396282819940"

    CURRENT_VERSION = GuiConfig.Version
    local executorName = GuiConfig.ExecutorOverride or GetExecutorName()

    local GuiFunc = {}
    local ZuperMingb = Instance.new("ScreenGui");
    local DropShadowHolder = Instance.new("Frame");
    local DropShadow = Instance.new("ImageLabel");
    local Main = Instance.new("Frame");
    local UICorner = Instance.new("UICorner");
    local Top = Instance.new("Frame");
    local TextLabel = Instance.new("TextLabel");
    local UICorner1 = Instance.new("UICorner");
    local TitleIcon = Instance.new("ImageLabel");
    local Close = Instance.new("TextButton");
    local ImageLabel1 = Instance.new("ImageLabel");
    local Min = Instance.new("TextButton");
    local ImageLabel2 = Instance.new("ImageLabel");
    local LayersTab = Instance.new("Frame");
    local UICorner2 = Instance.new("UICorner");
    local DecideFrame = Instance.new("Frame");
    local Layers = Instance.new("Frame");
    local UICorner6 = Instance.new("UICorner");
    local NameTab = Instance.new("TextLabel");
    local LayersReal = Instance.new("Frame");
    local LayersFolder = Instance.new("Folder");
    local LayersPageLayout = Instance.new("UIPageLayout");
    local MainStroke = Instance.new("UIStroke");

    -- Footer
    local FooterFrame = Instance.new("Frame")
    local AvatarImage = Instance.new("ImageLabel")
    local AvatarCorner = Instance.new("UICorner")
    local WelcomeText = Instance.new("TextLabel")
    local FooterRightFrame = Instance.new("Frame")
    local UIListLayoutFooter = Instance.new("UIListLayout")
    
    local function CreateStatusPill(text, color)
        local Pill = Instance.new("Frame")
        Pill.Name = text .. "Pill"
        Pill.BackgroundColor3 = color or Color3.fromRGB(40, 40, 45)
        Pill.BackgroundTransparency = 0.1
        Pill.BorderSizePixel = 0
        Pill.Size = UDim2.new(0, 50, 0, 22) 
        Pill.Parent = FooterRightFrame
        
        local UICornerPill = Instance.new("UICorner")
        UICornerPill.CornerRadius = UDim.new(1, 0) 
        UICornerPill.Parent = Pill
        
        local PillText = Instance.new("TextLabel")
        PillText.Name = "PillText"
        PillText.Parent = Pill
        PillText.BackgroundTransparency = 1
        PillText.Size = UDim2.new(1, 0, 1, 0)
        PillText.Font = Enum.Font.GothamMedium
        PillText.Text = text
        PillText.TextColor3 = Color3.fromRGB(220, 220, 220)
        PillText.TextSize = 11
        PillText.TextXAlignment = Enum.TextXAlignment.Center
        
        local textBounds = TextService:GetTextSize(text, 11, Enum.Font.GothamMedium, Vector2.new(1000, 22))
        Pill.Size = UDim2.new(0, textBounds.X + 20, 0, 22)
        
        return Pill
    end

    ZuperMingb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ZuperMingb.Name = "ZuperMingb"
    ZuperMingb.ResetOnSpawn = false
    ZuperMingb.Parent = game:GetService("CoreGui")

    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadowHolder.Size = safeSize(640, 400)
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = ZuperMingb

    DropShadowHolder.Position = UDim2.new(0, (ZuperMingb.AbsoluteSize.X // 2 - DropShadowHolder.Size.X.Offset // 2), 0, (ZuperMingb.AbsoluteSize.Y // 2 - DropShadowHolder.Size.Y.Offset // 2))
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.4
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    Main = Instance.new("Frame")
    Main.BackgroundTransparency = 0.1
    Main.BackgroundColor3 = GuiConfig.BackgroundColor
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow
    
    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Name = "BackgroundImage"
    BackgroundImage.Parent = Main
    BackgroundImage.Image = GuiConfig.LogoBg
    BackgroundImage.ScaleType = Enum.ScaleType.Fit
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.ImageTransparency = 0.95
    BackgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImage.Position = UDim2.new(0.6, 0, 0.5, 0) 
    BackgroundImage.Size = UDim2.new(0.7, 0, 0.7, 0)
    BackgroundImage.ZIndex = 0

    MainStroke.Thickness = 2
    MainStroke.Color = Color3.fromRGB(120, 10, 30)
    MainStroke.Transparency = 0
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = Main

    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Main

    -- ================= TOP BAR (LAYOUT DIPERBAIKI) =================
    -- Header lebih tinggi biar teks gak nubruk
    Top.BackgroundTransparency = 1
    Top.Size = UDim2.new(1, 0, 0, 50) -- Dari 38 jadi 50 (longgar)
    Top.Name = "Top"
    Top.Parent = Main

    TitleIcon:Destroy()
    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Name = "LogoIcon"
    LogoIcon.Parent = Top
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Position = UDim2.new(0, 12, 0.5, 0)
    LogoIcon.AnchorPoint = Vector2.new(0, 0.5)
    LogoIcon.Size = UDim2.new(0, 32, 0, 32)
    LogoIcon.Image = GuiConfig.Icon 
    LogoIcon.ScaleType = Enum.ScaleType.Fit
    LogoIcon.ZIndex = 10

    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = GuiConfig.Title
    TextLabel.TextColor3 = GuiConfig.Color
    TextLabel.TextSize = 16
    TextLabel.TextXAlignment = Enum.TextXAlignment.Center
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(0.5, 0, 0, 20)
    TextLabel.Position = UDim2.new(0.5, 0, 0, 6) -- Turun sedikit biar gak nubruk atas
    TextLabel.AnchorPoint = Vector2.new(0.5, 0)
    TextLabel.Parent = Top

    UICorner1.Parent = Top

    local GameNameLabel = Instance.new("TextLabel")
    GameNameLabel.Font = Enum.Font.GothamMedium
    GameNameLabel.Text = GuiConfig.GameName
    GameNameLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    GameNameLabel.TextSize = 11
    GameNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    GameNameLabel.BackgroundTransparency = 1
    GameNameLabel.Size = UDim2.new(0.5, 0, 0, 14)
    GameNameLabel.Position = UDim2.new(0.5, 0, 0, 28) -- Di bawah judul, jarak pas
    GameNameLabel.AnchorPoint = Vector2.new(0.5, 0)
    GameNameLabel.Parent = Top

    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundTransparency = 1
    Close.Position = UDim2.new(1, -10, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top
    Close.ZIndex = 10

    ImageLabel1.Image = "rbxassetid://9886659671"
    ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel1.BackgroundTransparency = 1
    ImageLabel1.Position = UDim2.new(0.49, 0, 0.5, 0)
    ImageLabel1.Size = UDim2.new(1, -8, 1, -8)
    ImageLabel1.Parent = Close

    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundTransparency = 1
    Min.Position = UDim2.new(1, -42, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top
    Min.ZIndex = 10

    ImageLabel2.Image = "rbxassetid://9886659276"
    ImageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel2.BackgroundTransparency = 1
    ImageLabel2.ImageTransparency = 0.2
    ImageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel2.Size = UDim2.new(1, -9, 1, -9)
    ImageLabel2.Parent = Min

    -- ================= SIDEBAR KIRI =================
    LayersTab.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    LayersTab.BackgroundTransparency = 0.95
    LayersTab.BorderSizePixel = 0
    LayersTab.Position = UDim2.new(0, 10, 0, 62) -- Turun dari 50 ke 62 (kasih jarak)
    LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -112)
    LayersTab.Name = "LayersTab"
    LayersTab.Parent = Main
    LayersTab.ZIndex = 2

    UICorner2.CornerRadius = UDim.new(0, 2)
    UICorner2.Parent = LayersTab
    
    local TabSeparator = Instance.new("Frame")
    TabSeparator.Name = "TabSeparator"
    TabSeparator.Parent = Main
    TabSeparator.BackgroundColor3 = Color3.fromRGB(120, 10, 30)
    TabSeparator.BorderSizePixel = 0
    TabSeparator.Position = UDim2.new(0, GuiConfig["Tab Width"] + 17, 0, 50)
    TabSeparator.Size = UDim2.new(0, 2, 1, -50)
    TabSeparator.ZIndex = 5

    DecideFrame.AnchorPoint = Vector2.new(0.5, 0)
    DecideFrame.BackgroundColor3 = Color3.fromRGB(120, 10, 30)
    DecideFrame.BorderSizePixel = 0
    DecideFrame.Position = UDim2.new(0.5, 0, 0, 50) -- Di bawah header baru
    DecideFrame.Size = UDim2.new(1, 0, 0, 2)
    DecideFrame.Name = "DecideFrame"
    DecideFrame.Parent = Main

    Layers.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Layers.BackgroundTransparency = 0.7
    Layers.BorderSizePixel = 0
    Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 19, 0, 62)
    Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 10 + 19), 1, -112)
    Layers.Name = "Layers"
    Layers.Parent = Main

    UICorner6.CornerRadius = UDim.new(0, 2)
    UICorner6.Parent = Layers

    NameTab.Font = Enum.Font.GothamBold
    NameTab.Text = ""
    NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.TextSize = 22
    NameTab.TextWrapped = true
    NameTab.TextXAlignment = Enum.TextXAlignment.Left
    NameTab.BackgroundTransparency = 1
    NameTab.Size = UDim2.new(1, -10, 0, 30)
    NameTab.Position = UDim2.new(0, 10, 0, 5)
    NameTab.Name = "NameTab"
    NameTab.Parent = Layers

    LayersReal.AnchorPoint = Vector2.new(0, 1)
    LayersReal.BackgroundTransparency = 1
    LayersReal.ClipsDescendants = true
    LayersReal.Position = UDim2.new(0, 0, 1, 0)
    LayersReal.Size = UDim2.new(1, 0, 1, -38)
    LayersReal.Name = "LayersReal"
    LayersReal.Parent = Layers

    LayersFolder.Name = "LayersFolder"
    LayersFolder.Parent = LayersReal

    LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LayersPageLayout.Name = "LayersPageLayout"
    LayersPageLayout.Parent = LayersFolder
    LayersPageLayout.TweenTime = 0.5
    LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
    LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad

    local ScrollTab = Instance.new("ScrollingFrame");
    local UIListLayout = Instance.new("UIListLayout");
    ScrollTab.CanvasSize = UDim2.new(0, 0, 1.1, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundTransparency = 1
    ScrollTab.Size = UDim2.new(1, 0, 1, 0)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.Parent = LayersTab
    ScrollTab.ZIndex = 2
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollTab

    -- ================= FOOTER (LAYOUT DIPERBAIKI) =================
    FooterFrame.Name = "FooterFrame"
    FooterFrame.Parent = Main
    FooterFrame.AnchorPoint = Vector2.new(0.5, 1)
    FooterFrame.Position = UDim2.new(0.5, 0, 1, -8)
    FooterFrame.Size = UDim2.new(1, -20, 0, 40)
    FooterFrame.BackgroundTransparency = 1
    FooterFrame.ZIndex = 3
    
    AvatarImage.Name = "AvatarImage"
    AvatarImage.Parent = FooterFrame
    AvatarImage.AnchorPoint = Vector2.new(0, 0.5)
    AvatarImage.Position = UDim2.new(0, 2, 0.5, 0)
    AvatarImage.Size = UDim2.new(0, 30, 0, 30)
    AvatarImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AvatarImage.BackgroundTransparency = 0.8
    AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    AvatarImage.ZIndex = 4
    
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImage

    WelcomeText.Name = "WelcomeText"
    WelcomeText.Parent = FooterFrame
    WelcomeText.AnchorPoint = Vector2.new(0, 0.5)
    WelcomeText.Position = UDim2.new(0, 40, 0.5, 0)
    WelcomeText.Size = UDim2.new(0, 180, 1, 0)
    WelcomeText.BackgroundTransparency = 1
    WelcomeText.Font = Enum.Font.GothamMedium
    WelcomeText.Text = "Welcome, " .. LocalPlayer.DisplayName
    WelcomeText.TextColor3 = Color3.fromRGB(210, 210, 210)
    WelcomeText.TextSize = 12
    WelcomeText.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeText.TextTruncate = Enum.TextTruncate.AtEnd
    WelcomeText.ZIndex = 4

    FooterRightFrame.Name = "FooterRightFrame"
    FooterRightFrame.Parent = FooterFrame
    FooterRightFrame.AnchorPoint = Vector2.new(1, 0.5)
    FooterRightFrame.Position = UDim2.new(1, -2, 0.5, 0)
    FooterRightFrame.Size = UDim2.new(1, -230, 1, 0)
    FooterRightFrame.BackgroundTransparency = 1
    FooterRightFrame.ZIndex = 4

    UIListLayoutFooter.Parent = FooterRightFrame
    UIListLayoutFooter.FillDirection = Enum.FillDirection.Horizontal
    UIListLayoutFooter.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayoutFooter.VerticalAlignment = Enum.VerticalAlignment.Center
    UIListLayoutFooter.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayoutFooter.Padding = UDim.new(0, 6)

    local ExecutorPill = CreateStatusPill(executorName, Color3.fromRGB(40, 40, 45))
    ExecutorPill.LayoutOrder = 1
    local PremiumPill = CreateStatusPill(GuiConfig.IsPremium and "Premium" or "Free", Color3.fromRGB(40, 40, 45))
    PremiumPill.LayoutOrder = 2
    local PingPill = CreateStatusPill("Ping: --", Color3.fromRGB(40, 40, 45))
    PingPill.LayoutOrder = 3
    local FpsPill = CreateStatusPill("FPS: --", Color3.fromRGB(40, 40, 45))
    FpsPill.LayoutOrder = 4

    spawn(function()
        while task.wait(1) do
            local ping = "N/A"
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            PingPill.PillText.Text = "Ping: " .. (ping ~= "N/A" and ping or "--")
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            FpsPill.PillText.Text = "FPS: " .. fps
        end
    end)

    -- DIALOG
    local function CreateDialog(HostParent, TitleText, MsgText, OnYes)
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.3
        Overlay.ZIndex = 50
        Overlay.Parent = HostParent
        local Dialog = Instance.new("Frame")
        Dialog.Size = UDim2.new(0, 300, 0, 150)
        Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
        Dialog.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Dialog.BorderSizePixel = 0
        Dialog.ZIndex = 51
        Dialog.Parent = Overlay
        Instance.new("UICorner", Dialog).CornerRadius = UDim.new(0, 8)
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.Position = UDim2.new(0, 0, 0, 4)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.Text = TitleText or "Confirmation"
        Title.TextSize = 20
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.ZIndex = 52
        Title.Parent = Dialog
        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -20, 0, 60)
        Message.Position = UDim2.new(0, 10, 0, 30)
        Message.BackgroundTransparency = 1
        Message.Font = Enum.Font.Gotham
        Message.Text = MsgText or "Are you sure?"
        Message.TextSize = 14
        Message.TextColor3 = Color3.fromRGB(200, 200, 200)
        Message.TextWrapped = true
        Message.ZIndex = 52
        Message.Parent = Dialog
        local Yes = Instance.new("TextButton")
        Yes.Size = UDim2.new(0.45, -10, 0, 35)
        Yes.Position = UDim2.new(0.05, 0, 1, -55)
        Yes.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Yes.BackgroundTransparency = 0.935
        Yes.Text = "Yes"
        Yes.Font = Enum.Font.GothamBold
        Yes.TextSize = 15
        Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
        Yes.TextTransparency = 0.3
        Yes.ZIndex = 52
        Yes.Parent = Dialog
        Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 6)
        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.45, -10, 0, 35)
        Cancel.Position = UDim2.new(0.5, 10, 1, -55)
        Cancel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.BackgroundTransparency = 0.935
        Cancel.Text = "Cancel"
        Cancel.Font = Enum.Font.GothamBold
        Cancel.TextSize = 15
        Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.TextTransparency = 0.3
        Cancel.ZIndex = 52
        Cancel.Parent = Dialog
        Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)
        Yes.MouseButton1Click:Connect(function() Overlay:Destroy(); if OnYes then OnYes() end end)
        Cancel.MouseButton1Click:Connect(function() Overlay:Destroy() end)
    end

    local function UpdateSize1()
        local OffsetY = 0
        for _, child in ScrollTab:GetChildren() do
            if child.Name ~= "UIListLayout" then OffsetY = OffsetY + 4 + child.Size.Y.Offset end
        end
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end
    ScrollTab.ChildAdded:Connect(UpdateSize1)
    ScrollTab.ChildRemoved:Connect(UpdateSize1)

    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("ZuperMingb") then ZuperMingb:Destroy() end
    end

    -- Minimize Icon
    local MinimizeIcon = Instance.new("ImageButton")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = ZuperMingb
    MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0)
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    MinimizeIcon.BorderSizePixel = 0
    MinimizeIcon.Position = UDim2.new(0.5, 0, 0, 20)
    MinimizeIcon.Size = UDim2.new(0, 60, 0, 60)
    MinimizeIcon.Image = GuiConfig.Icon
    MinimizeIcon.ScaleType = Enum.ScaleType.Fit
    MinimizeIcon.Visible = false
    MinimizeIcon.ZIndex = 100
    Instance.new("UICorner", MinimizeIcon).CornerRadius = UDim.new(0, 12)
    
    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
        MinimizeIcon.Visible = true
    end)
    MinimizeIcon.Activated:Connect(function()
        MinimizeIcon.Visible = false
        DropShadowHolder.Visible = true
    end)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    MinimizeIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MinimizeIcon.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MinimizeIcon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        CreateDialog(DropShadowHolder, "ZuperMing Window", "Do you want to close this window?\nYou will not be able to open it again", function()
            ConfigData = { _version = CURRENT_VERSION }
            if LoadConfigElements then LoadConfigElements() end
            if ZuperMingb then ZuperMingb:Destroy() end
            if game.CoreGui:FindFirstChild("ToggleUIButton") then game.CoreGui.ToggleUIButton:Destroy() end
        end)
    end)

    local ToggleKey = Enum.KeyCode.F3
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == ToggleKey then
            if DropShadowHolder then DropShadowHolder.Visible = not DropShadowHolder.Visible end
        end
    end)

    function GuiFunc:ToggleUI()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game:GetService("CoreGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "ToggleUIButton"
        local MainButton = Instance.new("ImageLabel")
        MainButton.Parent = ScreenGui
        MainButton.Size = UDim2.new(0, 45, 0, 45)
        MainButton.Position = UDim2.new(0, 20, 0, 100)
        MainButton.BackgroundTransparency = 1
        MainButton.Image = GuiConfig.Icon
        MainButton.ScaleType = Enum.ScaleType.Fit
        local Button = Instance.new("TextButton")
        Button.Parent = MainButton
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""
        Button.MouseButton1Click:Connect(function()
            if DropShadowHolder then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
                ScreenGui.Enabled = not DropShadowHolder.Visible
            end
        end)
        ScreenGui.Enabled = not DropShadowHolder.Visible
        local drag = false
        local dragStart, startPos
        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = true; dragStart = input.Position; startPos = MainButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then drag = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    GuiFunc:ToggleUI()

    DropShadowHolder.Size = UDim2.new(0, 115 + TextLabel.TextBounds.X + 1 + GameNameLabel.TextBounds.X, 0, 350)
    MakeDraggable(Top, DropShadowHolder)

    -- DROPDOWN OVERLAY
    local MoreBlur = Instance.new("Frame");
    local UICorner28 = Instance.new("UICorner");
    local ConnectButton = Instance.new("TextButton");
    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.BorderSizePixel = 0
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = Layers
    MoreBlur.ZIndex = 50
    UICorner28.Parent = MoreBlur
    ConnectButton.Text = ""
    ConnectButton.BackgroundTransparency = 1
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Parent = MoreBlur

    local DropdownSelect = Instance.new("Frame");
    local UICorner36 = Instance.new("UICorner");
    local UIStroke14 = Instance.new("UIStroke");
    local DropdownSelectReal = Instance.new("Frame");
    local DropdownFolder = Instance.new("Folder");
    local DropPageLayout = Instance.new("UIPageLayout");

    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownSelect.BorderSizePixel = 0
    DropdownSelect.LayoutOrder = 1
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Parent = MoreBlur
    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 0.999 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
            task.wait(0.3); MoreBlur.Visible = false
        end
    end)
    UICorner36.CornerRadius = UDim.new(0, 3)
    UICorner36.Parent = DropdownSelect
    UIStroke14.Color = Color3.fromRGB(189, 162, 241)
    UIStroke14.Thickness = 2.5
    UIStroke14.Transparency = 0.8
    UIStroke14.Parent = DropdownSelect
    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownSelectReal.BackgroundTransparency = 0.7
    DropdownSelectReal.BorderSizePixel = 0
    DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownSelectReal.Size = UDim2.new(1, 1, 1, 1)
    DropdownSelectReal.Parent = DropdownSelect
    DropdownFolder.Name = "DropdownFolder"
    DropdownFolder.Parent = DropdownSelectReal
    DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
    DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
    DropPageLayout.TweenTime = 0.01
    DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropPageLayout.FillDirection = Enum.FillDirection.Vertical
    DropPageLayout.Parent = DropdownFolder

    -- ================= TABS (FIX TOMBOL BISA DIPENCET) =================
    local Tabs = {}
    local CountTab = 0
    local CountDropdown = 0
    function Tabs:AddTab(TabConfig)
        local TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""

        local ScrolLayers = Instance.new("ScrollingFrame");
        local UIListLayout1 = Instance.new("UIListLayout");
        ScrolLayers.ScrollBarThickness = 0
        ScrolLayers.Active = true
        ScrolLayers.LayoutOrder = CountTab
        ScrolLayers.BackgroundTransparency = 1
        ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
        ScrolLayers.Name = "ScrolLayers"
        ScrolLayers.Parent = LayersFolder
        UIListLayout1.Padding = UDim.new(0, 4)
        UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout1.Parent = ScrolLayers

        local Tab = Instance.new("Frame");
        local UICorner3 = Instance.new("UICorner");
        local TabButton = Instance.new("TextButton");
        local TabName = Instance.new("TextLabel")
        local FeatureImg = Instance.new("ImageLabel");
        local UIStroke2 = Instance.new("UIStroke");
        local UICorner4 = Instance.new("UICorner");

        Tab.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        Tab.BackgroundTransparency = CountTab == 0 and 0.85 or 0.98
        Tab.BorderSizePixel = 0
        Tab.LayoutOrder = CountTab
        Tab.Size = UDim2.new(1, 0, 0, 32) -- Sedikit lebih tinggi
        Tab.Name = "Tab"
        Tab.Parent = ScrollTab
        Tab.ZIndex = 3 -- Biar di atas
        
        local TabBorderStroke = Instance.new("UIStroke")
        TabBorderStroke.Name = "TabBorder"
        TabBorderStroke.Thickness = 1.5
        TabBorderStroke.Transparency = 1
        TabBorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TabBorderStroke.Parent = Tab
        local TabBorderGradient = Instance.new("UIGradient")
        TabBorderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 10, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 160, 255))
        })
        TabBorderGradient.Rotation = 90
        TabBorderGradient.Parent = TabBorderStroke

        UICorner3.CornerRadius = UDim.new(0, 6)
        UICorner3.Parent = Tab
        
        -- TOMBOL DULU (supaya gak ketutupan)
        TabButton.Font = Enum.Font.SourceSans
        TabButton.Text = ""
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Position = UDim2.new(0, 0, 0, 0)
        TabButton.Parent = Tab
        TabButton.ZIndex = 5 -- PALING ATAS biar bisa dipencet
        
        TabName.Font = Enum.Font.GothamBold
        TabName.Text = "| " .. tostring(TabConfig.Name)
        TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabName.TextSize = 14
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.BackgroundTransparency = 1
        TabName.Size = UDim2.new(1, 0, 1, 0)
        TabName.Position = UDim2.new(0, 30, 0, 0)
        TabName.Parent = Tab
        TabName.ZIndex = 4
        
        FeatureImg.BackgroundTransparency = 1
        FeatureImg.Position = UDim2.new(0, 9, 0, 8)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Parent = Tab
        FeatureImg.ZIndex = 4
        
        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = TabConfig.Name
            NameTab.Position = UDim2.new(0, 10, 0, 5)
            local ChooseFrame = Instance.new("Frame");
            ChooseFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ChooseFrame.BorderSizePixel = 0
            ChooseFrame.Position = UDim2.new(0, 2, 0, 5)
            ChooseFrame.Size = UDim2.new(0, 3, 0, 22)
            ChooseFrame.Parent = Tab
            ChooseFrame.ZIndex = 5
            local TabGradient = Instance.new("UIGradient")
            TabGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 80))
            })
            TabGradient.Rotation = 90
            TabGradient.Parent = ChooseFrame
            UIStroke2.Color = GuiConfig.Color
            UIStroke2.Thickness = 0
            UIStroke2.Parent = ChooseFrame
            UICorner4.Parent = ChooseFrame
        end
        if TabConfig.Icon ~= "" then
            if Icons[TabConfig.Icon] then FeatureImg.Image = Icons[TabConfig.Icon]
            else FeatureImg.Image = TabConfig.Icon end
        end
        
        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            local FrameChoose
            for a, s in ScrollTab:GetChildren() do
                for i, v in s:GetChildren() do
                    if v.Name == "ChooseFrame" then FrameChoose = v; break end
                end
            end
            if FrameChoose ~= nil and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                for _, TabFrame in ScrollTab:GetChildren() do
                    if TabFrame.Name == "Tab" then
                        TweenService:Create(TabFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.999 }):Play()
                    end
                end
                TweenService:Create(Tab, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.92 }):Play()
                TweenService:Create(FrameChoose, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Position = UDim2.new(0, 2, 0, 5 + (36 * Tab.LayoutOrder)) }):Play()
                LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
                task.wait(0.05)
                NameTab.Text = TabConfig.Name
                TweenService:Create(FrameChoose, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 1, 0, 2) }):Play()
                task.wait(0.2)
                TweenService:Create(FrameChoose, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 3, 0, 22) }):Play()
            end
        end)
        
        local Sections = {}
        local CountSection = 0
        function Sections:AddSection(Title, AlwaysOpen)
            local Title = Title or "Title"
            local Section = Instance.new("Frame");
            local SectionDecideFrame = Instance.new("Frame");
            local UICorner1 = Instance.new("UICorner");
            local UIGradient = Instance.new("UIGradient");
            Section.BackgroundTransparency = 0.999 
            Section.BorderSizePixel = 0
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, 0, 0, 32)
            Section.Name = "Section"
            Section.Parent = ScrolLayers

            local SectionReal = Instance.new("Frame");
            local UICorner = Instance.new("UICorner");
            local SectionButton = Instance.new("TextButton");
            local FeatureFrame = Instance.new("Frame");
            local FeatureImg = Instance.new("ImageLabel");
            local SectionTitle = Instance.new("TextLabel");
            SectionReal.AnchorPoint = Vector2.new(0.5, 0)
            SectionReal.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
            SectionReal.BackgroundTransparency = 0.95 
            SectionReal.BorderSizePixel = 0
            SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
            SectionReal.Size = UDim2.new(1, -2, 0, 32)
            SectionReal.Parent = Section
            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = SectionReal
            SectionButton.Text = ""
            SectionButton.BackgroundTransparency = 1
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.Parent = SectionReal
            SectionButton.ZIndex = 5
            FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
            FeatureFrame.BackgroundTransparency = 1
            FeatureFrame.Position = UDim2.new(1, -8, 0.5, 0)
            FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
            FeatureFrame.Parent = SectionReal
            FeatureImg.Image = "rbxassetid://16851841101"
            FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
            FeatureImg.BackgroundTransparency = 1
            FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            FeatureImg.Rotation = -90
            FeatureImg.Size = UDim2.new(1, 6, 1, 6)
            FeatureImg.Parent = FeatureFrame
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.TextYAlignment = Enum.TextYAlignment.Center
            SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 12, 0.5, 0)
            SectionTitle.Size = UDim2.new(1, -50, 0, 13)
            SectionTitle.Parent = SectionReal
            SectionDecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionDecideFrame.AnchorPoint = Vector2.new(0.5, 0)
            SectionDecideFrame.BorderSizePixel = 0
            SectionDecideFrame.Position = UDim2.new(0.5, 0, 0, 35)
            SectionDecideFrame.Size = UDim2.new(0, 0, 0, 2)
            SectionDecideFrame.Parent = Section
            UICorner1.Parent = SectionDecideFrame
            UIGradient.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 80)),
                    ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 80))
            }
            UIGradient.Parent = SectionDecideFrame

            local SectionAdd = Instance.new("Frame");
            local UICorner8 = Instance.new("UICorner");
            local UIListLayout2 = Instance.new("UIListLayout");
            SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
            SectionAdd.BackgroundTransparency = 0.999
            SectionAdd.BorderSizePixel = 0
            SectionAdd.ClipsDescendants = true
            SectionAdd.LayoutOrder = 1
            SectionAdd.Position = UDim2.new(0.5, 0, 0, 40)
            SectionAdd.Size = UDim2.new(1, 0, 0, 100)
            SectionAdd.Parent = Section
            UICorner8.CornerRadius = UDim.new(0, 2)
            UICorner8.Parent = SectionAdd
            UIListLayout2.Padding = UDim.new(0, 3)
            UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout2.Parent = SectionAdd

            local OpenSection = false
            local isAnimating = false
            local ANIM_TIME = 0.25
            local function UpdateSizeScroll()
                local OffsetY = 0
                for _, child in ScrolLayers:GetChildren() do
                    if child.Name ~= "UIListLayout" then OffsetY = OffsetY + 4 + child.Size.Y.Offset end
                end
                ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
            end
            local function UpdateSizeSection()
                if OpenSection then
                    local SectionSizeYWitdh = 40
                    for _, v in SectionAdd:GetChildren() do
                        if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                            SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
                        end
                    end
                    local tweenInfo = TweenInfo.new(ANIM_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    TweenService:Create(FeatureImg, tweenInfo, { Rotation = 0 }):Play()
                    TweenService:Create(Section, tweenInfo, { Size = UDim2.new(1, 1, 0, SectionSizeYWitdh) }):Play()
                    TweenService:Create(SectionAdd, tweenInfo, { Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 40) }):Play()
                    TweenService:Create(SectionDecideFrame, tweenInfo, { Size = UDim2.new(1, 0, 0, 2) }):Play()
                    task.delay(ANIM_TIME, UpdateSizeScroll)
                end
            end
            if AlwaysOpen == true then
                SectionButton:Destroy(); FeatureFrame:Destroy(); OpenSection = true; UpdateSizeSection()
            elseif AlwaysOpen == false then OpenSection = false
            else OpenSection = true; UpdateSizeSection() end

            if AlwaysOpen ~= true then
                SectionButton.Activated:Connect(function()
                    if isAnimating then return end
                    isAnimating = true
                    CircleClick(SectionButton, Mouse.X, Mouse.Y)
                    local tweenInfo = TweenInfo.new(ANIM_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    if OpenSection then
                        TweenService:Create(FeatureImg, tweenInfo, { Rotation = -90 }):Play()
                        TweenService:Create(Section, tweenInfo, { Size = UDim2.new(1, 1, 0, 32) }):Play()
                        TweenService:Create(SectionDecideFrame, tweenInfo, { Size = UDim2.new(0, 0, 0, 2) }):Play()
                        OpenSection = false
                        task.delay(ANIM_TIME, function() UpdateSizeScroll(); isAnimating = false end)
                    else
                        OpenSection = true; UpdateSizeSection()
                        task.delay(ANIM_TIME, function() isAnimating = false end)
                    end
                end)
            end
            if AlwaysOpen == true then
                OpenSection = true
                local SectionSizeYWitdh = 40
                for _, v in SectionAdd:GetChildren() do
                    if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                        SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
                    end
                end
                FeatureImg.Rotation = 0
                Section.Size = UDim2.new(1, 1, 0, SectionSizeYWitdh)
                SectionAdd.Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 40)
                SectionDecideFrame.Size = UDim2.new(1, 0, 0, 2)
                UpdateSizeScroll()
            end
            SectionAdd.ChildAdded:Connect(function() task.wait(0.05); UpdateSizeSection() end)
            SectionAdd.ChildRemoved:Connect(function() task.wait(0.05); UpdateSizeSection() end)

            local Items = {}
            local CountItem = 0

            function Items:AddToggle(ToggleConfig)
                local ToggleConfig = ToggleConfig or {}
                ToggleConfig.Title = ToggleConfig.Title or "Title"
                ToggleConfig.Content = ToggleConfig.Content or ""
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                local configKey = "Toggle_" .. ToggleConfig.Title
                if ConfigData[configKey] ~= nil then ToggleConfig.Default = ConfigData[configKey] end
                local ToggleFunc = { Value = ToggleConfig.Default }
                local isInCallback = false
                local Toggle = Instance.new("Frame")
                local UICorner20 = Instance.new("UICorner")
                local ToggleTitle = Instance.new("TextLabel")
                local ToggleContent = Instance.new("TextLabel")
                local ToggleButton = Instance.new("TextButton")
                local FeatureFrame2 = Instance.new("Frame")
                local UICorner22 = Instance.new("UICorner")
                local UIStroke8 = Instance.new("UIStroke")
                local ToggleCircle = Instance.new("Frame")
                local UICorner23 = Instance.new("UICorner")
                Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Toggle.BackgroundTransparency = 0.935
                Toggle.BorderSizePixel = 0
                Toggle.LayoutOrder = CountItem
                Toggle.Parent = SectionAdd
                UICorner20.CornerRadius = UDim.new(0, 4)
                UICorner20.Parent = Toggle
                ToggleTitle.Font = Enum.Font.GothamBold
                ToggleTitle.Text = ToggleConfig.Title
                ToggleTitle.TextSize = 14
                ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.Position = UDim2.new(0, 12, 0, 10)
                ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
                ToggleTitle.Parent = Toggle
                ToggleContent.Font = Enum.Font.Gotham
                ToggleContent.Text = ToggleConfig.Content
                ToggleContent.TextColor3 = Color3.fromRGB(180, 180, 180)
                ToggleContent.TextSize = 12
                ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
                ToggleContent.BackgroundTransparency = 1
                ToggleContent.Position = UDim2.new(0, 12, 0, 26)
                ToggleContent.Size = UDim2.new(1, -80, 0, 12)
                ToggleContent.TextWrapped = true
                ToggleContent.Parent = Toggle
                Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 36)
                ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 36)
                    UpdateSizeSection()
                end)
                ToggleButton.Text = ""
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Parent = Toggle
                ToggleButton.ZIndex = 5
                FeatureFrame2.AnchorPoint = Vector2.new(1, 0.5)
                FeatureFrame2.BackgroundTransparency = 0.92
                FeatureFrame2.BorderSizePixel = 0
                FeatureFrame2.Position = UDim2.new(1, -15, 0.5, 0)
                FeatureFrame2.Size = UDim2.new(0, 32, 0, 16)
                FeatureFrame2.Parent = Toggle
                FeatureFrame2.ZIndex = 4
                UICorner22.Parent = FeatureFrame2
                UIStroke8.Color = Color3.fromRGB(255, 255, 255)
                UIStroke8.Thickness = 2
                UIStroke8.Transparency = 0.9
                UIStroke8.Parent = FeatureFrame2
                ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
                ToggleCircle.Parent = FeatureFrame2
                ToggleCircle.ZIndex = 5
                UICorner23.CornerRadius = UDim.new(0, 15)
                UICorner23.Parent = ToggleCircle
                ToggleButton.Activated:Connect(function()
                    ToggleFunc.Value = not ToggleFunc.Value
                    ToggleFunc:Set(ToggleFunc.Value)
                end)
                function ToggleFunc:Set(Value)
                    ToggleFunc.Value = Value
                    ConfigData[configKey] = Value
                    if Value then
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 16, 0, 0) }):Play()
                        TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
                    else
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
                        TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
                    end
                    if not isInCallback then
                        isInCallback = true
                        task.spawn(function()
                            if typeof(ToggleConfig.Callback) == "function" then
                                local ok, err = pcall(function() ToggleConfig.Callback(Value) end)
                                if not ok then warn("Toggle Callback error:", err) end
                            end
                            task.wait(0.05); isInCallback = false
                        end)
                    end
                end
                ToggleFunc:Set(ToggleFunc.Value)
                CountItem = CountItem + 1
                ToggleFunc.Type = "Toggle"
                Elements[configKey] = ToggleFunc
                return ToggleFunc
            end

            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Title = ButtonConfig.Title or "Confirm"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                ButtonConfig.Confirm = ButtonConfig.Confirm or false
                ButtonConfig.ConfirmText = ButtonConfig.ConfirmText or "Are you sure?"
                local Button = Instance.new("Frame")
                Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Button.BackgroundTransparency = 0.935
                Button.Size = UDim2.new(1, 0, 0, 42)
                Button.LayoutOrder = CountItem
                Button.Parent = SectionAdd
                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Button
                local MainButton = Instance.new("TextButton")
                MainButton.Font = Enum.Font.GothamBold
                MainButton.Text = ButtonConfig.Title
                MainButton.TextSize = 14
                MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.BackgroundTransparency = 1
                MainButton.Size = UDim2.new(1, -12, 1, -10)
                MainButton.Position = UDim2.new(0, 6, 0, 5)
                MainButton.Parent = Button
                MainButton.ZIndex = 5
                MainButton.MouseButton1Click:Connect(function()
                    if ButtonConfig.Confirm then
                        CreateDialog(DropShadowHolder, "Confirmation", ButtonConfig.ConfirmText, ButtonConfig.Callback)
                    else
                        ButtonConfig.Callback()
                    end
                end)
                CountItem = CountItem + 1
            end

            function Items:AddSlider(SliderConfig)
                local SliderConfig = SliderConfig or {}
                SliderConfig.Title = SliderConfig.Title or "Slider"
                SliderConfig.Content = SliderConfig.Content or ""
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end
                local configKey = "Slider_" .. SliderConfig.Title
                if ConfigData[configKey] ~= nil then SliderConfig.Default = ConfigData[configKey] end
                local SliderFunc = { Value = SliderConfig.Default }
                local Slider = Instance.new("Frame");
                local UICorner15 = Instance.new("UICorner");
                local SliderTitle = Instance.new("TextLabel");
                local SliderContent = Instance.new("TextLabel");
                local SliderInput = Instance.new("Frame");
                local UICorner16 = Instance.new("UICorner");
                local TextBox = Instance.new("TextBox");
                local SliderFrame = Instance.new("Frame");
                local UICorner17 = Instance.new("UICorner");
                local SliderDraggable = Instance.new("Frame");
                local UICorner18 = Instance.new("UICorner");
                local SliderCircle = Instance.new("Frame");
                local UICorner19 = Instance.new("UICorner");
                Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Slider.BackgroundTransparency = 0.935
                Slider.BorderSizePixel = 0
                Slider.LayoutOrder = CountItem
                Slider.Size = UDim2.new(1, 0, 0, 48)
                Slider.Parent = SectionAdd
                UICorner15.CornerRadius = UDim.new(0, 4)
                UICorner15.Parent = Slider
                SliderTitle.Font = Enum.Font.GothamBold
                SliderTitle.Text = SliderConfig.Title
                SliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                SliderTitle.TextSize = 14
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Position = UDim2.new(0, 12, 0, 10)
                SliderTitle.Size = UDim2.new(1, -180, 0, 13)
                SliderTitle.Parent = Slider
                SliderContent.Font = Enum.Font.Gotham
                SliderContent.Text = SliderConfig.Content
                SliderContent.TextColor3 = Color3.fromRGB(180, 180, 180)
                SliderContent.TextSize = 12
                SliderContent.TextXAlignment = Enum.TextXAlignment.Left
                SliderContent.BackgroundTransparency = 1
                SliderContent.Position = UDim2.new(0, 12, 0, 26)
                SliderContent.Size = UDim2.new(1, -180, 0, 12)
                SliderContent.TextWrapped = true
                SliderContent.Parent = Slider
                Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 36)
                SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 36)
                    UpdateSizeSection()
                end)
                SliderInput.AnchorPoint = Vector2.new(0, 0.5)
                SliderInput.BackgroundTransparency = 1
                SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
                SliderInput.Size = UDim2.new(0, 28, 0, 20)
                SliderInput.Parent = Slider
                UICorner16.Parent = SliderInput
                TextBox.Font = Enum.Font.GothamBold
                TextBox.Text = "90"
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.TextSize = 14
                TextBox.BackgroundTransparency = 1
                TextBox.Size = UDim2.new(1, 0, 1, 0)
                TextBox.Parent = SliderInput
                SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderFrame.BackgroundTransparency = 0.8
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
                SliderFrame.Size = UDim2.new(0, 100, 0, 3)
                SliderFrame.Parent = Slider
                UICorner17.Parent = SliderFrame
                SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
                SliderDraggable.BackgroundColor3 = GuiConfig.Color
                SliderDraggable.BorderSizePixel = 0
                SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
                SliderDraggable.Size = UDim2.new(0.9, 0, 0, 1)
                SliderDraggable.Parent = SliderFrame
                UICorner18.Parent = SliderDraggable
                SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
                SliderCircle.BackgroundColor3 = GuiConfig.Color
                SliderCircle.BorderSizePixel = 0
                SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
                SliderCircle.Size = UDim2.new(0, 10, 0, 10)
                SliderCircle.Parent = SliderDraggable
                UICorner19.Parent = SliderCircle
                local Dragging = false
                local function Round(Number, Factor)
                    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
                    if Result < 0 then Result = Result + Factor end
                    return Result
                end
                function SliderFunc:Set(Value)
                    Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    SliderFunc.Value = Value
                    TextBox.Text = tostring(Value)
                    TweenService:Create(SliderDraggable, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1) }):Play()
                    SliderConfig.Callback(Value)
                    ConfigData[configKey] = Value
                end
                SliderFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        TweenService:Create(SliderCircle, TweenInfo.new(0.2), { Size = UDim2.new(0, 16, 0, 16) }):Play()
                        local SizeScale = math.clamp((Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                    end
                end)
                SliderFrame.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                        SliderConfig.Callback(SliderFunc.Value)
                        TweenService:Create(SliderCircle, TweenInfo.new(0.2), { Size = UDim2.new(0, 10, 0, 10) }):Play()
                    end
                end)
                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        local SizeScale = math.clamp((Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                    end
                end)
                TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local Valid = TextBox.Text:gsub("[^%d]", "")
                    if Valid ~= "" then
                        local ValidNumber = math.clamp(tonumber(Valid), SliderConfig.Min, SliderConfig.Max)
                        SliderFunc:Set(ValidNumber)
                    else
                        SliderFunc:Set(SliderConfig.Min)
                    end
                end)
                SliderFunc:Set(SliderConfig.Default)
                CountItem = CountItem + 1
                SliderFunc.Type = "Slider"
                Elements[configKey] = SliderFunc
                return SliderFunc
            end

            function Items:AddInput(InputConfig)
                local InputConfig = InputConfig or {}
                InputConfig.Title = InputConfig.Title or "Title"
                InputConfig.Placeholder = InputConfig.Placeholder or nil
                InputConfig.Content = InputConfig.Content or ""
                InputConfig.Callback = InputConfig.Callback or function() end
                InputConfig.Default = InputConfig.Default or ""
                local configKey = "Input_" .. InputConfig.Title
                if ConfigData[configKey] ~= nil then InputConfig.Default = ConfigData[configKey] end
                local InputFunc = { Value = InputConfig.Default }
                local Input = Instance.new("Frame");
                local UICorner12 = Instance.new("UICorner");
                local InputTitle = Instance.new("TextLabel");
                local InputContent = Instance.new("TextLabel");
                local InputFrame = Instance.new("Frame");
                local UICorner13 = Instance.new("UICorner");
                local InputTextBox = Instance.new("TextBox");
                Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Input.BackgroundTransparency = 0.935
                Input.BorderSizePixel = 0
                Input.LayoutOrder = CountItem
                Input.Size = UDim2.new(1, 0, 0, 48)
                Input.Parent = SectionAdd
                UICorner12.CornerRadius = UDim.new(0, 4)
                UICorner12.Parent = Input
                InputTitle.Font = Enum.Font.GothamBold
                InputTitle.Text = InputConfig.Title or "TextBox"
                InputTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                InputTitle.TextSize = 14
                InputTitle.TextXAlignment = Enum.TextXAlignment.Left
                InputTitle.BackgroundTransparency = 1
                InputTitle.Position = UDim2.new(0, 12, 0, 10)
                InputTitle.Size = UDim2.new(1, -180, 0, 13)
                InputTitle.Parent = Input
                InputContent.Font = Enum.Font.Gotham
                InputContent.Text = InputConfig.Content or "Input here"
                InputContent.TextColor3 = Color3.fromRGB(180, 180, 180)
                InputContent.TextSize = 12
                InputContent.TextXAlignment = Enum.TextXAlignment.Left
                InputContent.BackgroundTransparency = 1
                InputContent.Position = UDim2.new(0, 12, 0, 26)
                InputContent.Size = UDim2.new(1, -180, 0, 12)
                InputContent.TextWrapped = true
                InputContent.Parent = Input
                Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 36)
                InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 36)
                    UpdateSizeSection()
                end)
                InputFrame.AnchorPoint = Vector2.new(1, 0.5)
                InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputFrame.BackgroundTransparency = 0.95
                InputFrame.BorderSizePixel = 0
                InputFrame.ClipsDescendants = true
                InputFrame.Position = UDim2.new(1, -10, 0.5, 0)
                InputFrame.Size = UDim2.new(0, 140, 0, 28)
                InputFrame.Parent = Input
                UICorner13.CornerRadius = UDim.new(0, 4)
                UICorner13.Parent = InputFrame
                InputTextBox.CursorPosition = -1
                InputTextBox.Font = Enum.Font.GothamBold
                InputTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                InputTextBox.PlaceholderText = InputConfig.Placeholder or "Input Here"
                InputTextBox.Text = InputConfig.Default
                InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputTextBox.TextSize = 13
                InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
                InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
                InputTextBox.BackgroundTransparency = 1
                InputTextBox.Position = UDim2.new(0, 8, 0.5, 0)
                InputTextBox.Size = UDim2.new(1, -16, 1, -8)
                InputTextBox.Parent = InputFrame
                InputTextBox.ClearTextOnFocus = false
                function InputFunc:Set(Value)
                    InputTextBox.Text = Value
                    InputFunc.Value = Value
                    InputConfig.Callback(Value)
                    ConfigData[configKey] = Value
                end
                InputFunc:Set(InputFunc.Value)
                InputTextBox.FocusLost:Connect(function()
                    InputFunc:Set(InputTextBox.Text)
                end)
                CountItem = CountItem + 1
                InputFunc.Type = "Input"
                Elements[configKey] = InputFunc
                return InputFunc
            end

            function Items:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.Parent = SectionAdd
                Divider.AnchorPoint = Vector2.new(0.5, 0)
                Divider.Position = UDim2.new(0.5, 0, 0, 0)
                Divider.Size = UDim2.new(1, 0, 0, 2)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BorderSizePixel = 0
                Divider.LayoutOrder = CountItem
                local UIGradient = Instance.new("UIGradient")
                UIGradient.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 80)),
                    ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 80))
                }
                UIGradient.Parent = Divider
                Instance.new("UICorner", Divider).CornerRadius = UDim.new(0, 2)
                CountItem = CountItem + 1
                return Divider
            end

            function Items:AddParagraph(ParagraphConfig)
                local ParagraphConfig = ParagraphConfig or {}
                ParagraphConfig.Title = ParagraphConfig.Title or "Title"
                ParagraphConfig.Content = ParagraphConfig.Content or "Content"
                local ParagraphFunc = {}
                local Paragraph = Instance.new("Frame")
                local UICorner14 = Instance.new("UICorner")
                local ParagraphTitle = Instance.new("TextLabel")
                local ParagraphContent = Instance.new("TextLabel")
                Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Paragraph.BackgroundTransparency = 0.935
                Paragraph.BorderSizePixel = 0
                Paragraph.LayoutOrder = CountItem
                Paragraph.Size = UDim2.new(1, 0, 0, 50)
                Paragraph.Parent = SectionAdd
                UICorner14.CornerRadius = UDim.new(0, 4)
                UICorner14.Parent = Paragraph
                ParagraphTitle.Font = Enum.Font.GothamBold
                ParagraphTitle.Text = ParagraphConfig.Title
                ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ParagraphTitle.TextSize = 14
                ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphTitle.BackgroundTransparency = 1
                ParagraphTitle.Position = UDim2.new(0, 12, 0, 10)
                ParagraphTitle.Size = UDim2.new(1, -16, 0, 13)
                ParagraphTitle.Parent = Paragraph
                ParagraphContent.Font = Enum.Font.Gotham
                ParagraphContent.Text = ParagraphConfig.Content
                ParagraphContent.TextColor3 = Color3.fromRGB(180, 180, 180)
                ParagraphContent.TextSize = 12
                ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphContent.BackgroundTransparency = 1
                ParagraphContent.Position = UDim2.new(0, 12, 0, 26)
                ParagraphContent.Size = UDim2.new(1, -16, 0, 12)
                ParagraphContent.TextWrapped = true
                ParagraphContent.Parent = Paragraph
                local ParagraphButton
                if ParagraphConfig.ButtonText then
                    ParagraphButton = Instance.new("TextButton")
                    ParagraphButton.Position = UDim2.new(0, 12, 0, 44)
                    ParagraphButton.Size = UDim2.new(1, -24, 0, 28)
                    ParagraphButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    ParagraphButton.BackgroundTransparency = 0.935
                    ParagraphButton.Font = Enum.Font.GothamBold
                    ParagraphButton.TextSize = 13
                    ParagraphButton.TextTransparency = 0.3
                    ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    ParagraphButton.Text = ParagraphConfig.ButtonText
                    ParagraphButton.Parent = Paragraph
                    ParagraphButton.ZIndex = 5
                    Instance.new("UICorner", ParagraphButton).CornerRadius = UDim.new(0, 6)
                    if ParagraphConfig.ButtonCallback then
                        ParagraphButton.MouseButton1Click:Connect(ParagraphConfig.ButtonCallback)
                    end
                end
                local function UpdateSize()
                    local totalHeight = ParagraphContent.TextBounds.Y + 36
                    if ParagraphButton then totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 5 end
                    Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
                end
                UpdateSize()
                ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
                function ParagraphFunc:SetContent(content)
                    content = content or "Content"
                    ParagraphContent.Text = content
                    UpdateSize()
                end
                CountItem = CountItem + 1
                return ParagraphFunc
            end

            function Items:AddDropdown(DropdownConfig)
                local DropdownConfig = DropdownConfig or {}
                DropdownConfig.Title = DropdownConfig.Title or "Title"
                DropdownConfig.Content = DropdownConfig.Content or ""
                DropdownConfig.Multi = DropdownConfig.Multi or false
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or (DropdownConfig.Multi and {} or nil)
                DropdownConfig.Callback = DropdownConfig.Callback or function() end
                local configKey = "Dropdown_" .. DropdownConfig.Title
                if ConfigData[configKey] ~= nil then DropdownConfig.Default = ConfigData[configKey] end
                local DropdownFunc = { Value = DropdownConfig.Default, Options = DropdownConfig.Options }
                local Dropdown = Instance.new("Frame")
                local DropdownButton = Instance.new("TextButton")
                local UICorner10 = Instance.new("UICorner")
                local DropdownTitle = Instance.new("TextLabel")
                local DropdownContent = Instance.new("TextLabel")
                local SelectOptionsFrame = Instance.new("Frame")
                local UICorner11 = Instance.new("UICorner")
                local OptionSelecting = Instance.new("TextLabel")
                local OptionImg = Instance.new("ImageLabel")
                Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Dropdown.BackgroundTransparency = 0.935
                Dropdown.BorderSizePixel = 0
                Dropdown.LayoutOrder = CountItem
                Dropdown.Size = UDim2.new(1, 0, 0, 48)
                Dropdown.Parent = SectionAdd
                UICorner10.CornerRadius = UDim.new(0, 4)
                UICorner10.Parent = Dropdown
                DropdownButton.Text = ""
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.Parent = Dropdown
                DropdownButton.ZIndex = 5
                DropdownTitle.Font = Enum.Font.GothamBold
                DropdownTitle.Text = DropdownConfig.Title
                DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                DropdownTitle.TextSize = 14
                DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
                DropdownTitle.BackgroundTransparency = 1
                DropdownTitle.Position = UDim2.new(0, 12, 0, 10)
                DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
                DropdownTitle.Parent = Dropdown
                DropdownContent.Font = Enum.Font.Gotham
                DropdownContent.Text = DropdownConfig.Content
                DropdownContent.TextColor3 = Color3.fromRGB(180, 180, 180)
                DropdownContent.TextSize = 12
                DropdownContent.TextWrapped = true
                DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
                DropdownContent.BackgroundTransparency = 1
                DropdownContent.Position = UDim2.new(0, 12, 0, 26)
                DropdownContent.Size = UDim2.new(1, -180, 0, 12)
                DropdownContent.Parent = Dropdown
                Dropdown.Size = UDim2.new(1, 0, 0, DropdownContent.AbsoluteSize.Y + 36)
                DropdownContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    Dropdown.Size = UDim2.new(1, 0, 0, DropdownContent.AbsoluteSize.Y + 36)
                    UpdateSizeSection()
                end)
                SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
                SelectOptionsFrame.BackgroundTransparency = 0.95
                SelectOptionsFrame.Position = UDim2.new(1, -10, 0.5, 0)
                SelectOptionsFrame.Size = UDim2.new(0, 140, 0, 28)
                SelectOptionsFrame.Parent = Dropdown
                UICorner11.CornerRadius = UDim.new(0, 4)
                UICorner11.Parent = SelectOptionsFrame
                DropdownButton.Activated:Connect(function()
                    if not MoreBlur.Visible then
                        MoreBlur.Visible = true
                        DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
                        TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                        local maxWidth = 0
                        for _, v in ipairs(DropdownConfig.Options) do
                            local text = (type(v) == "table" and v.Label) or tostring(v)
                            local size = TextService:GetTextSize(text, 14, Enum.Font.GothamBold, Vector2.new(math.huge, 30))
                            if size.X > maxWidth then maxWidth = size.X end
                        end
                        local newWidth = maxWidth + 60
                        if newWidth < 150 then newWidth = 150 end
                        DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
                        local currentYScale = DropdownSelect.Size.Y.Scale
                        local currentYOffset = DropdownSelect.Size.Y.Offset
                        DropdownSelect.Size = UDim2.new(0, newWidth, currentYScale, currentYOffset)
                        TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -10, 0.5, 0) }):Play()
                    end
                end)
                OptionSelecting.Font = Enum.Font.GothamBold
                OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
                OptionSelecting.TextSize = 13
                OptionSelecting.TextTransparency = 0.6
                OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
                OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
                OptionSelecting.BackgroundTransparency = 1
                OptionSelecting.Position = UDim2.new(0, 8, 0.5, 0)
                OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
                OptionSelecting.Parent = SelectOptionsFrame
                OptionImg.Image = "rbxassetid://16851841101"
                OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
                OptionImg.AnchorPoint = Vector2.new(1, 0.5)
                OptionImg.BackgroundTransparency = 1
                OptionImg.Position = UDim2.new(1, -5, 0.5, 0)
                OptionImg.Size = UDim2.new(0, 20, 0, 20)
                OptionImg.Parent = SelectOptionsFrame
                local DropdownContainer = Instance.new("Frame")
                DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
                DropdownContainer.BackgroundTransparency = 1
                DropdownContainer.Parent = DropdownFolder
                local SearchBox = Instance.new("TextBox")
                SearchBox.PlaceholderText = "Search"
                SearchBox.Font = Enum.Font.Gotham
                SearchBox.Text = ""
                SearchBox.TextSize = 13
                SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                SearchBox.BackgroundTransparency = 0.9
                SearchBox.BorderSizePixel = 0
                SearchBox.Size = UDim2.new(1, 0, 0, 25)
                SearchBox.Position = UDim2.new(0, 0, 0, 0)
                SearchBox.ClearTextOnFocus = false
                SearchBox.Parent = DropdownContainer
                local ScrollSelect = Instance.new("ScrollingFrame")
                ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
                ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
                ScrollSelect.ScrollBarImageTransparency = 1
                ScrollSelect.BorderSizePixel = 0
                ScrollSelect.BackgroundTransparency = 1
                ScrollSelect.ScrollBarThickness = 0
                ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
                ScrollSelect.Parent = DropdownContainer
                local UIListLayout4 = Instance.new("UIListLayout")
                UIListLayout4.Padding = UDim.new(0, 3)
                UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout4.Parent = ScrollSelect
                UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
                end)
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = string.lower(SearchBox.Text)
                    for _, option in pairs(ScrollSelect:GetChildren()) do
                        if option.Name == "Option" and option:FindFirstChild("OptionText") then
                            local text = string.lower(option.OptionText.Text)
                            option.Visible = query == "" or string.find(text, query, 1, true)
                        end
                    end
                    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
                end)
                function DropdownFunc:Clear()
                    for _, DropFrame in ScrollSelect:GetChildren() do
                        if DropFrame.Name == "Option" then DropFrame:Destroy() end
                    end
                    DropdownFunc.Value = DropdownConfig.Multi and {} or nil
                    DropdownFunc.Options = {}
                    OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                end
                function DropdownFunc:AddOption(option)
                    local label, value
                    if typeof(option) == "table" and option.Label and option.Value ~= nil then
                        label = tostring(option.Label)
                        value = option.Value
                    else
                        label = tostring(option)
                        value = option
                    end
                    local Option = Instance.new("Frame")
                    local OptionButton = Instance.new("TextButton")
                    local OptionText = Instance.new("TextLabel")
                    local ChooseFrame = Instance.new("Frame")
                    local UIStroke15 = Instance.new("UIStroke")
                    local UICorner38 = Instance.new("UICorner")
                    local UICorner37 = Instance.new("UICorner")
                    Option.BackgroundTransparency = 1
                    Option.Size = UDim2.new(1, 0, 0, 30)
                    Option.Name = "Option"
                    Option.Parent = ScrollSelect
                    UICorner37.CornerRadius = UDim.new(0, 3)
                    UICorner37.Parent = Option
                    OptionButton.BackgroundTransparency = 1
                    OptionButton.Size = UDim2.new(1, 0, 1, 0)
                    OptionButton.Text = ""
                    OptionButton.Parent = Option
                    OptionButton.ZIndex = 5
                    OptionText.Font = Enum.Font.GothamBold
                    OptionText.Text = label
                    OptionText.TextSize = 14
                    OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
                    OptionText.Position = UDim2.new(0, 8, 0, 8)
                    OptionText.Size = UDim2.new(1, -100, 0, 13)
                    OptionText.BackgroundTransparency = 1
                    OptionText.TextXAlignment = Enum.TextXAlignment.Left
                    OptionText.Parent = Option
                    Option:SetAttribute("RealValue", value)
                    ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
                    ChooseFrame.BackgroundColor3 = GuiConfig.Color
                    ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
                    ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
                    ChooseFrame.Parent = Option
                    UIStroke15.Color = GuiConfig.Color
                    UIStroke15.Thickness = 1.6
                    UIStroke15.Transparency = 0.999
                    UIStroke15.Parent = ChooseFrame
                    UICorner38.Parent = ChooseFrame
                    OptionButton.Activated:Connect(function()
                        if DropdownConfig.Multi then
                            if not table.find(DropdownFunc.Value, value) then
                                table.insert(DropdownFunc.Value, value)
                            else
                                for i, v in pairs(DropdownFunc.Value) do
                                    if v == value then table.remove(DropdownFunc.Value, i); break end
                                end
                            end
                        else
                            DropdownFunc.Value = value
                        end
                        DropdownFunc:Set(DropdownFunc.Value)
                    end)
                end
                function DropdownFunc:Set(Value)
                    if DropdownConfig.Multi then
                        DropdownFunc.Value = type(Value) == "table" and Value or {}
                    else
                        DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
                    end
                    ConfigData[configKey] = DropdownFunc.Value
                    local texts = {}
                    for _, Drop in ScrollSelect:GetChildren() do
                        if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                            local v = Drop:GetAttribute("RealValue")
                            local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or DropdownFunc.Value == v
                            if selected then
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 1, 0, 12) }):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
                                TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = 0.935 }):Play()
                                table.insert(texts, Drop.OptionText.Text)
                            else
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.1), { Size = UDim2.new(0, 0, 0, 0) }):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.1), { Transparency = 0.999 }):Play()
                                TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                            end
                        end
                    end
                    OptionSelecting.Text = (#texts == 0) and (DropdownConfig.Multi and "Select Options" or "Select Option") or table.concat(texts, ", ")
                    if DropdownConfig.Callback then
                        if DropdownConfig.Multi then DropdownConfig.Callback(DropdownFunc.Value)
                        else DropdownConfig.Callback(tostring(DropdownFunc.Value or "")) end
                    end
                end
                function DropdownFunc:SetValue(val) self:Set(val) end
                function DropdownFunc:GetValue() return self.Value end
                function DropdownFunc:SetValues(newList, selecting)
                    newList = newList or {}
                    selecting = selecting or (DropdownConfig.Multi and {} or nil)
                    DropdownFunc:Clear()
                    for _, v in ipairs(newList) do DropdownFunc:AddOption(v) end
                    DropdownFunc.Options = newList
                    DropdownFunc:Set(selecting)
                end
                DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)
                CountItem = CountItem + 1
                CountDropdown = CountDropdown + 1
                DropdownFunc.Type = "Dropdown"
                Elements[configKey] = DropdownFunc
                return DropdownFunc
            end

            function Items:AddSubSection(title)
                title = title or "Sub Section"
                local SubSection = Instance.new("Frame")
                SubSection.Parent = SectionAdd
                SubSection.BackgroundTransparency = 1
                SubSection.Size = UDim2.new(1, 0, 0, 24)
                SubSection.LayoutOrder = CountItem
                local Background = Instance.new("Frame")
                Background.Parent = SubSection
                Background.Size = UDim2.new(1, 0, 1, 0)
                Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Background.BackgroundTransparency = 0.935
                Background.BorderSizePixel = 0
                Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)
                local Label = Instance.new("TextLabel")
                Label.Parent = SubSection
                Label.AnchorPoint = Vector2.new(0, 0.5)
                Label.Position = UDim2.new(0, 12, 0.5, 0)
                Label.Size = UDim2.new(1, -24, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.GothamBold
                Label.Text = "── " .. title .. " ──"
                Label.TextColor3 = Color3.fromRGB(230, 230, 230)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                CountItem = CountItem + 1
                return SubSection
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