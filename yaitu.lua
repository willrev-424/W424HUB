-- [BAGIAN 1 DARI 7]
-- AstraComponents.lua
-- Extension untuk AstraUiLib — API mirip Obsidian
-- Simpan sebagai file terpisah di GitHub

local Components = {}

-- ==========================================
-- REGISTRY (Toggles & Options)
-- ==========================================
local Toggles = {}
local Options = {}

Components.Toggles = Toggles
Components.Options = Options

-- ==========================================
-- UTIL
-- ==========================================
local function Create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(60, 60, 70)
    s.Thickness = thickness or 1
    s.Transparency = 0.4
    s.Parent = parent
    return s
end

local function GetPage(tab)
    -- AstraUiLib tab biasanya punya .Page atau .Frame
    return tab.Page or tab.Frame or tab.Container or tab
end

-- ==========================================
-- NOTIFY (expose dari AstraUiLib atau fallback)
-- ==========================================
local NotifyContainer

local function EnsureNotifyContainer()
    if NotifyContainer and NotifyContainer.Parent then return NotifyContainer end
    local gui = Instance.new("ScreenGui")
    gui.Name = "AstraNotify"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        if gethui then gui.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = game:GetService("CoreGui")
        else gui.Parent = game:GetService("CoreGui") end
    end)
    if not gui.Parent then gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    NotifyContainer = gui
    return gui
end

function Components.Notify(config)
    config = config or {}
    local gui = EnsureNotifyContainer()
    local title = config.Title or "Notification"
    local desc = config.Description or config.Text or ""
    local duration = config.Time or 3

    local frame = Create("Frame", {
        Size = UDim2.new(0, 280, 0, 50),
        Position = UDim2.new(1, 20, 0, 20),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        Parent = gui,
    })
    Corner(frame, 8)
    Stroke(frame, Color3.fromRGB(80, 80, 100), 1)

    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local descLbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.new(0, 10, 0, 26),
        BackgroundTransparency = 1,
        Text = desc,
        TextColor3 = Color3.fromRGB(180, 180, 200),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    -- Stack notif: hitung posisi
    local count = 0
    for _, child in ipairs(gui:GetChildren()) do
        if child ~= frame and child:IsA("Frame") then count = count + 1 end
    end
    frame.Position = UDim2.new(1, 20, 0, 20 + (count * 60))

    local tweenIn = game:GetService("TweenService"):Create(
        frame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = UDim2.new(1, -300, 0, 20 + (count * 60)) }
    )
    tweenIn:Play()

    task.delay(duration, function()
        if not frame.Parent then return end
        local tweenOut = game:GetService("TweenService"):Create(
            frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = UDim2.new(1, 20, frame.Position.Y.Scale, frame.Position.Y.Offset) }
        )
        tweenOut:Play()
        tweenOut.Completed:Wait()
        frame:Destroy()
    end)
end

-- ==========================================
-- GROUPBOX
-- ==========================================
function Components.CreateGroupbox(tab, name, side)
    local page = GetPage(tab)

    local holder = Create("Frame", {
        Name = name .. "_Group",
        Size = UDim2.new(0, 300, 0, 30),
        Position = side == "Right" and UDim2.new(0, 320, 0, 10) or UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(22, 22, 28),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    Corner(holder, 8)
    Stroke(holder, Color3.fromRGB(55, 55, 70), 1)

    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(220, 220, 235),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })

    local container = Create("Frame", {
        Name = "Container",
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 30),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = holder,
    })

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = container

    local groupObj = {
        _holder = holder,
        _container = container,
        _layout = layout,
        _name = name,
    }

    -- ===== ADD TOGGLE =====
    function groupObj:AddToggle(id, config)
        config = config or {}
        local state = config.Default or false

        local row = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Parent = self._container,
        })

        local btn = Create("TextButton", {
            Size = UDim2.new(0, 32, 0, 16),
            Position = UDim2.new(1, -32, 0.5, -8),
            BackgroundColor3 = state and Color3.fromRGB(90, 200, 120) or Color3.fromRGB(50, 50, 60),
            Text = "",
            BorderSizePixel = 0,
            Parent = row,
        })
        Corner(btn, 8)

        local knob = Create("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = state and UDim2.new(1, -13, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = btn,
        })
        Corner(knob, 6)

        local lbl = Create("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Text or id,
            TextColor3 = Color3.fromRGB(210, 210, 225),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })

        local toggleObj = {
            Value = state,
            _config = config,
            _id = id,
        }

        function toggleObj:_render()
            local on = self.Value
            btn.BackgroundColor3 = on and Color3.fromRGB(90, 200, 120) or Color3.fromRGB(50, 50, 60)
            knob.Position = on and UDim2.new(1, -13, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        end

        function toggleObj:SetValue(v)
            if self.Value == v then return end
            self.Value = v
            self:_render()
            if self._config.Callback then
                task.spawn(function()
                    pcall(self._config.Callback, v)
                end)
            end
        end

        btn.MouseButton1Click:Connect(function()
            toggleObj:SetValue(not toggleObj.Value)
        end)

        toggleObj:_render()

        -- ===== KEY PICKER (chained) =====
        function toggleObj:AddKeyPicker(keyId, kconfig)
            kconfig = kconfig or {}
            local keyObj = {
                Key = kconfig.Default or "None",
                _config = kconfig,
                _toggleRef = toggleObj,
            }

            function keyObj:SetValue(v)
                toggleObj:SetValue(v)
            end

            function keyObj:GetValue()
                return toggleObj.Value
            end

            -- Simple key listener
            if kconfig.Default and kconfig.Default ~= "None" then
                local keyCode = Enum.KeyCode[kconfig.Default]
                if keyCode then
                    game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if input.KeyCode == keyCode then
                            local newVal = not toggleObj.Value
                            toggleObj:SetValue(newVal)
                            if kconfig.Callback then
                                task.spawn(function() pcall(kconfig.Callback, newVal) end)
                            end
                        end
                    end)
                end
            end

            Toggles[keyId] = keyObj
            Options[keyId] = keyObj
            return toggleObj
        end

        Toggles[id] = toggleObj
        Options[id] = toggleObj
        return toggleObj
    end

    -- ===== ADD SLIDER =====
    function groupObj:AddSlider(id, config)
        config = config or {}
        local state = config.Default or config.Min or 0
        local minV = config.Min or 0
        local maxV = config.Max or 100
        local roundN = config.Rounding or 0

        local row = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = self._container,
        })

        local lbl = Create("TextLabel", {
            Size = UDim2.new(1, -50, 0, 18),
            BackgroundTransparency = 1,
            Text = (config.Text or id) .. ": " .. tostring(state) .. (config.Suffix or ""),
            TextColor3 = Color3.fromRGB(210, 210, 225),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })

        local bar = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.new(0, 0, 0, 26),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BorderSizePixel = 0,
            Parent = row,
        })
        Corner(bar, 3)

        local fill = Create("Frame", {
            Size = UDim2.new((state - minV) / (maxV - minV), 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(100, 160, 255),
            BorderSizePixel = 0,
            Parent = bar,
        })
        Corner(fill, 3)

        local sliderObj = { Value = state, _config = config, _id = id }

        function sliderObj:SetValue(v)
            v = math.clamp(v, minV, maxV)
            if roundN > 0 then
                v = math.floor(v * (10 ^ roundN) + 0.5) / (10 ^ roundN)
            else
                v = math.floor(v + 0.5)
            end
            self.Value = v
            fill.Size = UDim2.new((v - minV) / (maxV - minV), 0, 1, 0)
            lbl.Text = (config.Text or id) .. ": " .. tostring(v) .. (config.Suffix or "")
            if config.Callback then
                task.spawn(function() pcall(config.Callback, v) end)
            end
        end

        local dragging = false

        local function updateFromInput(input)
            local relX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = minV + relX * (maxV - minV)
            sliderObj:SetValue(val)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromInput(input)
            end
        end)

        bar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                updateFromInput(input)
            end
        end)

        Toggles[id] = sliderObj
        Options[id] = sliderObj
        return sliderObj
    end

    -- ===== ADD CHECKBOX =====
    function groupObj:AddCheckbox(id, config)
        config = config or {}
        local state = config.Default or false

        local row = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Parent = self._container,
        })

        local box = Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 0, 0.5, -8),
            BackgroundColor3 = state and Color3.fromRGB(100, 160, 255) or Color3.fromRGB(40, 40, 50),
            BorderSizePixel = 0,
            Parent = row,
        })
        Corner(box, 4)

        local check = Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = state and "✓" or "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            Parent = box,
        })

        local lbl = Create("TextLabel", {
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 22, 0, 0),
            BackgroundTransparency = 1,
            Text = config.Text or id,
            TextColor3 = Color3.fromRGB(210, 210, 225),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })

        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = row,
        })

        local cbObj = { Value = state, _config = config, _id = id }

        function cbObj:SetValue(v)
            self.Value = v
            box.BackgroundColor3 = v and Color3.fromRGB(100, 160, 255) or Color3.fromRGB(40, 40, 50)
            check.Text = v and "✓" or ""
            if config.Callback then
                task.spawn(function() pcall(config.Callback, v) end)
            end
        end

        btn.MouseButton1Click:Connect(function()
            cbObj:SetValue(not cbObj.Value)
        end)

        -- ===== COLOR PICKER (chained) =====
        function cbObj:AddColorPicker(colorId, cconfig)
            local colorObj = { Value = cconfig.Default or Color3.fromRGB(255, 255, 255), _config = cconfig }
            function colorObj:SetValue(c)
                self.Value = c
                if cconfig.Callback then task.spawn(function() pcall(cconfig.Callback, c) end) end
            end
            Toggles[colorId] = colorObj
            Options[colorId] = colorObj
            return cbObj
        end

        Toggles[id] = cbObj
        Options[id] = cbObj
        return cbObj
    end

    -- ===== ADD BUTTON =====
    function groupObj:AddButton(config)
        config = config or {}
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Color3.fromRGB(45, 45, 55),
            Text = config.Text or "Button",
            TextColor3 = Color3.fromRGB(220, 220, 235),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = true,
            Parent = self._container,
        })
        Corner(btn, 5)

        btn.MouseButton1Click:Connect(function()
            if config.Func then task.spawn(function() pcall(config.Func) end) end
        end)

        return { _btn = btn }
    end

    -- ===== ADD INPUT =====
    function groupObj:AddInput(id, config)
        config = config or {}
        local row = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Parent = self._container,
        })

        local box = Create("TextBox", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(35, 35, 45),
            Text = config.Default or "",
            PlaceholderText = config.Placeholder or (config.Text or "Input..."),
            PlaceholderColor3 = Color3.fromRGB(120, 120, 140),
            TextColor3 = Color3.fromRGB(220, 220, 235),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Parent = row,
        })
        Corner(box, 5)

        local pad = Instance.new("UIPadding", box)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)

        local inputObj = { Value = config.Default or "", _config = config, _id = id }

        box.FocusLost:Connect(function()
            local v = box.Text
            if config.Numeric then
                local num = tonumber(v)
                if not num then return end
            end
            inputObj.Value = v
            if config.Callback then task.spawn(function() pcall(config.Callback, v) end) end
        end)

        Toggles[id] = inputObj
        Options[id] = inputObj
        return inputObj
    end

    -- ===== ADD DROPDOWN =====
    function groupObj:AddDropdown(id, config)
        config = config or {}
        local values = config.Values or {}
        local state = config.Default
        local multi = config.Multi or false

        local row = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Parent = self._container,
        })

        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(35, 35, 45),
            Text = "",
            BorderSizePixel = 0,
            Parent = row,
        })
        Corner(btn, 5)

        local lbl = Create("TextLabel", {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(state or config.Text or "Select..."),
            TextColor3 = Color3.fromRGB(220, 220, 235),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = btn,
        })

        local arrow = Create("TextLabel", {
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -22, 0, 0),
            BackgroundTransparency = 1,
            Text = "v",
            TextColor3 = Color3.fromRGB(150, 150, 170),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Parent = btn,
        })

        local listHolder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = Color3.fromRGB(28, 28, 35),
            BorderSizePixel = 0,
            Visible = false,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 5,
            Parent = row,
        })
        Corner(listHolder, 5)

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = listHolder

        local listPad = Instance.new("UIPadding", listHolder)
        listPad.PaddingTop = UDim.new(0, 4)
        listPad.PaddingBottom = UDim.new(0, 4)
        listPad.PaddingLeft = UDim.new(0, 4)
        listPad.PaddingRight = UDim.new(0, 4)

        local dropObj = { Value = state, _config = config, _id = id }

        local function rebuildList()
            for _, c in ipairs(listHolder:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _, v in ipairs(values) do
                local item = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                    Text = tostring(v),
                    TextColor3 = Color3.fromRGB(200, 200, 215),
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    BorderSizePixel = 0,
                    Parent = listHolder,
                })
                Corner(item, 4)

                item.MouseButton1Click:Connect(function()
                    dropObj:SetValue(v)
                    listHolder.Visible = false
                end)
            end
        end

        function dropObj:SetValue(v)
            if multi then
                if type(v) == "table" then
                    self.Value = v
                end
            else
                self.Value = v
                lbl.Text = tostring(v)
            end
            if config.Callback then
                task.spawn(function() pcall(config.Callback, v) end)
            end
        end

        function dropObj:SetValues(newValues)
            values = newValues
            rebuildList()
        end

        btn.MouseButton1Click:Connect(function()
            listHolder.Visible = not listHolder.Visible
            if listHolder.Visible then rebuildList() end
        end)

        rebuildList()

        Toggles[id] = dropObj
        Options[id] = dropObj
        return dropObj
    end

    -- ===== ADD LABEL =====
    function groupObj:AddLabel(text)
        local lbl = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = text or "",
            TextColor3 = Color3.fromRGB(180, 180, 200),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self._container,
        })

        local labelObj = { _lbl = lbl }

        function labelObj:AddKeyPicker(keyId, kconfig)
            kconfig = kconfig or {}
            local keyObj = { Key = kconfig.Default or "None", _config = kconfig }
            function keyObj:SetValue(v) end
            function keyObj:GetValue() return keyObj.Key end
            Toggles[keyId] = keyObj
            Options[keyId] = keyObj
            return labelObj
        end

        return labelObj
    end

    -- ===== ADD DIVIDER =====
    function groupObj:AddDivider()
        local div = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Color3.fromRGB(55, 55, 70),
            BorderSizePixel = 0,
            Parent = self._container,
        })
        return div
    end

    return groupObj
end

-- ==========================================
-- DRAGGABLE LABEL (watermark)
-- ==========================================
function Components.CreateDraggableLabel(text)
    local gui = EnsureNotifyContainer()
    local frame = Create("Frame", {
        Size = UDim2.new(0, 200, 0, 22),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Visible = false,
        Parent = gui,
    })
    Corner(frame, 6)
    Stroke(frame, Color3.fromRGB(80, 80, 100), 1)

    local lbl = Create("TextLabel", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 235),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local drag = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if not drag then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local obj = { _frame = frame, _lbl = lbl }
    function obj:SetText(t) lbl.Text = t end
    function obj:SetVisible(v) frame.Visible = v end
    return obj
end

-- ==========================================
-- UNLOAD
-- ==========================================
function Components.Unload()
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "AstraNotify" or gui.Name == "AstraUILib" then
            pcall(function() gui:Destroy() end)
        end
    end
end

return Components
