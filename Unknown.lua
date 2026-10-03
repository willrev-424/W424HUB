repeat task.wait() until game:IsLoaded()

do local prev = _G.TestBypassFarm; if prev and type(prev.dead)=='boolean' then prev.dead = true end end
local HUB = { conns = {}, dead = false }
_G.TestBypassFarm = HUB
function track(conn) table.insert(HUB.conns, conn); return conn end

local Window   -- forward declaration for UI (W424_UI)
local Library

HUB.Unload = function()
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    pcall(function() clearAllEsp() end)
    if HUB._antiAfkConn then pcall(function() HUB._antiAfkConn:Disconnect() end) end
    pcall(function()
        if Window and Window.Close then Window:Close() end
    end)
    _G.TestBypassFarm = nil
    print("[W424 Hub] Unloaded")
end

Players           = game:GetService('Players')
ReplicatedStorage = game:GetService('ReplicatedStorage')
RunService        = game:GetService('RunService')
UserInputService  = game:GetService('UserInputService')
Workspace         = game:GetService('Workspace')
Lighting          = game:GetService('Lighting')
RS                = ReplicatedStorage
LP                = Players.LocalPlayer

-- CLIENT AC NEUTRALIZER & UGI CONSTANT WIPER (Layer 1 + Layer 2)
function bypassClientDetections()
    if typeof(filtergc) ~= "function" or typeof(debug) ~= "table" or typeof(debug.getupvalues) ~= "function" then
        return false, "no filtergc"
    end
    local ok, fn = pcall(function()
        return filtergc("function", {
            Constants = { "gmatch", "GetFullName" },
        }, true)
    end)
    if not ok or type(fn) ~= "function" then
        return false, "filter miss"
    end
    local setMeta = (typeof(setrawmetatable) == "function" and setrawmetatable)
        or (typeof(setmetatable) == "function" and setmetatable)
    if not setMeta then
        return false, "no setmeta"
    end
    local blocked = 0
    local okUv, ups = pcall(debug.getupvalues, fn)
    if not okUv or type(ups) ~= "table" then
        return false, "no upvalues"
    end
    for _, tbl in pairs(ups) do
        if typeof(tbl) == "table" then
            local okSet = pcall(setMeta, tbl, {
                __newindex = function() end,
            })
            if okSet then
                blocked = blocked + 1
            end
        end
    end
    return blocked > 0, blocked
end

pcall(bypassClientDetections)

pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local setmeta = setrawmetatable or setmetatable
    local getmeta = getrawmetatable or getmetatable

    if getgc and setmeta then
        for _, obj in ipairs(getgc(true)) do
            if typeof(obj) == "table" and not (getmeta and getmeta(obj)) then
                local mainrun = false
                for _, v in pairs(obj) do
                    if v == obj then
                        mainrun = true
                        break
                    end
                end
                if mainrun then
                    for _, v in pairs(obj) do
                        if typeof(v) == "number" and v >= 1 and v <= 3 and obj[v] == nil then
                            pcall(setmeta, obj, { __newindex = function() end })
                            break
                        end
                    end
                end
            end
        end
    end
end)

pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local setconstant = setconstant or (debug and debug.setconstant)
    local islclosure = islclosure or function(Function)
        return not pcall(setfenv, getfenv(Function))
    end

    if getgc and getconstants and setconstant then
        for _, Function in ipairs(getgc(true)) do
            if typeof(Function) == "function" and islclosure(Function) then
                local ok, Source = pcall(debug.info, Function, "s")
                if ok and type(Source) == "string" and Source:find("ReplicatedFirst", 1, true) and Source:find("UGI", 1, true) then
                    local okC, Constants = pcall(getconstants, Function)
                    if okC and type(Constants) == "table" then
                        for Index, Constant in next, Constants do
                            if type(Constant) == "string" and Constant == "Humanoid" then
                                pcall(setconstant, Function, Index, "")
                            end
                        end
                    end
                end
            end
        end
    end
end)

pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local islclosure = islclosure or function(fn) return not pcall(setfenv, getfenv(fn)) end
    local HookFn = hookfunction or replaceclosure or hookfunc
    if getgc and getconstants and HookFn and debug and debug.getstack and debug.setstack then
        for _, fn in ipairs(getgc(true)) do
            if typeof(fn) == "function" and islclosure(fn) then
                local ok, consts = pcall(getconstants, fn)
                if ok and type(consts) == "table" and table.find(consts, "X-14") then
                    local cb = nil
                    cb = HookFn(fn, function(...)
                        local stack = debug.getstack(1)
                        if type(stack) == "table" then
                            for idx, val in pairs(stack) do
                                if val == "X-14" then
                                    pcall(debug.setstack, 1, idx, nil)
                                end
                            end
                        end
                        if cb then return cb(...) end
                    end)
                end
            end
        end
    end
end)

pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local islclosure = islclosure or function(v) return not pcall(setfenv, getfenv(v)) end
    local getupvalues = getupvalues or (debug and debug.getupvalues)
    local getupvalue = getupvalue or (debug and debug.getupvalue)
    local setupvalue = setupvalue or (debug and debug.setupvalue)
    local clonefunction = clonefunction or function(f) return function(...) return f(...) end end

    if getgc and getupvalues and getupvalue and setupvalue then
        for _, v in ipairs(getgc(true)) do
            if typeof(v) == "function" and islclosure(v) then
                local ok, upvs = pcall(getupvalues, v)
                if ok and upvs and #upvs == 19 then
                    local ok2, u2 = pcall(getupvalue, v, 2)
                    if ok2 and typeof(u2) == "function" then
                        local old = clonefunction(u2)
                        pcall(setupvalue, v, 2, function(a, b)
                            if b and typeof(b) == "table" then
                                pcall(setmetatable, b, {})
                            end
                            return old(a, b)
                        end)
                    end
                end
            end
        end
    end
end)

-- CHARACTER & MOVEMENT HELPERS
function findChar() return LP.Character end
function findHum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
function findHRP()
    local ch = LP.Character
    return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart or ch:FindFirstChildWhichIsA("BasePart"))
end

local GetCharacter = findChar
local GetHumanoid  = findHum
local GetHRP       = findHRP

function GetRootCFrame()
    local hrp = findHRP()
    return hrp and hrp.CFrame
end

-- BAC TELEMETRY PACKET SPOOFER
bxor = bit32.bxor
unpack = table.unpack

function isGuid(n)
    return #n==36 and n:sub(9,9)=="-" and n:sub(14,14)=="-" and n:sub(19,19)=="-" and n:sub(24,24)=="-" and n:gsub("-",""):match("^%x+$")~=nil
end

local remoteSet, anyRemote = {}, nil

function scanRemotes()
    for _, s in ipairs(game:GetChildren()) do
        local ok, list = pcall(s.GetDescendants, s)
        if ok and list then
            for _, o in ipairs(list) do
                if o:IsA("RemoteEvent") and isGuid(o.Name) then
                    remoteSet[o] = true
                    anyRemote = anyRemote or o
                end
            end
        end
    end
end

scanRemotes()

function parseCounter(v)
    if type(v) ~= "string" then return end
    local n = v:match("^X%-(%d+)$")
    return n and tonumber(n)
end

function looksLikeState(t, r)
    if type(t) ~= "table" then return false end
    local hR, hM = false, false
    local ok = pcall(function()
        for _, v in pairs(t) do
            if v == r then hR = true
            elseif type(v) == "string" and v:match("^X%-%d+$") then hM = true end
        end
    end)
    return ok and hR and hM
end

function findState(r)
    for l=2,24 do
        local _, fn = pcall(debug.info, l, "f")
        if type(fn) == "function" then
            local _, ups = pcall(debug.getupvalues, fn)
            if type(ups) == "table" then
                for _, v in pairs(ups) do
                    if looksLikeState(v, r) then return v end
                    if type(v) == "table" then
                        local nested
                        pcall(function()
                            for _, x in pairs(v) do
                                if looksLikeState(x, r) then nested = x; return end
                            end
                        end)
                        if nested then return nested end
                    end
                end
            end
        end
    end
end

function mapState(st, a1, a2)
    local m = {}
    for k, v in pairs(st) do
        if type(v) == "string" then
            if v:match("^X%-%d+$") then m.marker = m.marker or k
            elseif a1 and v == a1 then m.arg1 = m.arg1 or k
            elseif a2 and v == a2 then m.arg2 = m.arg2 or k end
        end
    end
    return m
end

local model = nil

function digits(n)
    n = n % 1000
    return math.floor(n/100), math.floor(n/10)%10, n%10
end

function encode(m, c)
    local d1, d2, d3 = digits(c)
    return m.prefix .. string.char(bxor(d1, m.k1), bxor(d2, m.k2), bxor(d3, m.k3))
end

function learn(r, a1, a2)
    local st = findState(r)
    if not st then return end
    local map = mapState(st, a1, a2)
    if not map.marker then return end
    local c = parseCounter(rawget(st, map.marker))
    if not c then return end
    local d1, d2, d3 = digits(c)
    local m = {
        state = st, map = map, remote = r,
        prefix = a1:sub(1, 9),
        k1 = bxor(a1:byte(10), d1),
        k2 = bxor(a1:byte(11), d2),
        k3 = bxor(a1:byte(12), d3),
        offset = c - os.time(),
        arg2 = a2
    }
    if encode(m, c) == a1 then return m end
end

function liveCounter(m)
    if m.state and m.map.marker then
        local _, raw = pcall(rawget, m.state, m.map.marker)
        local c = parseCounter(raw)
        if c and math.abs((c - os.time()) - m.offset) <= 5 then
            return c
        end
    end
    return os.time() + m.offset
end

function refreshArg2(m)
    if m.state and m.map.arg2 then
        local _, v = pcall(rawget, m.state, m.map.arg2)
        if type(v) == "string" then m.arg2 = v end
    end
    return m.arg2
end

local HookFn = hookfunction or replaceclosure or hookfunc or detour_function

if anyRemote and HookFn then
    local oldFire
    oldFire = HookFn(anyRemote.FireServer, function(self, ...)
        local args = table.pack(...)
        if not remoteSet[self] then
            return oldFire(self, unpack(args, 1, args.n))
        end

        local a1 = args[1]

        if type(a1) == "string" and #a1 == 12 then
            if not model then
                model = learn(self, a1, args[2])
            else
                local c = parseCounter(rawget(model.state, model.map.marker))
                if c and encode(model, c) ~= a1 then
                    local m = learn(self, a1, args[2])
                    if m then m.spoofed = model.spoofed; model = m end
                end
            end
            return oldFire(self, unpack(args, 1, args.n))
        end

        if model and type(a1) == "string" and #a1 == 4 then
            local c = liveCounter(model)
            args[1] = encode(model, c)
            args[2] = refreshArg2(model)
            model.spoofed = (model.spoofed or 0) + 1
            return oldFire(self, unpack(args, 1, math.max(args.n, 2)))
        end

        return oldFire(self, unpack(args, 1, args.n))
    end)
end

task.spawn(function()
    while not HUB.dead do
        task.wait(10)
        local alive = false
        for r in pairs(remoteSet) do
            if r:IsDescendantOf(game) then alive = true; break end
        end
        if not alive then
            table.clear(remoteSet)
            anyRemote = nil
            model = nil
            scanRemotes()
        end
    end
end)

task.spawn(function()
    if not getgc then return end
    local st = nil

    function findIntegrityTable()
        local ok, objs = pcall(getgc, true)
        if ok and objs then
            for _, o in pairs(objs) do
                if type(o) == "table" then
                    local hit = false
                    pcall(function()
                        hit = (rawget(o, "ValidationLocked") ~= nil and rawget(o, "Evidence") ~= nil)
                            or (rawget(o, "ThreatLevel") ~= nil and rawget(o, "LastObservedSample") ~= nil)
                    end)
                    if hit then return o end
                end
            end
        end
        return nil
    end

    track(LP.CharacterAdded:Connect(function()
        task.wait(1)
        st = findIntegrityTable()
    end))

    while not HUB.dead do
        if not st then
            st = findIntegrityTable()
        end

        if st then
            pcall(function()
                local ev = rawget(st, "Evidence")
                if type(ev) == "table" then
                    if (tonumber(ev.Speed)    or 0) > 0 then rawset(ev, "Speed", 0) end
                    if (tonumber(ev.Teleport) or 0) > 0 then rawset(ev, "Teleport", 0) end
                    if (tonumber(ev.Flight)   or 0) > 0 then rawset(ev, "Flight", 0) end
                end
                if rawget(st, "ThreatLevel") ~= "Trusted" then rawset(st, "ThreatLevel", "Trusted") end
                if rawget(st, "ValidationLocked") == true then rawset(st, "ValidationLocked", false) end
                if rawget(st, "FirstSuspiciousAt") ~= nil then rawset(st, "FirstSuspiciousAt", nil) end
                if rawget(st, "KickQueued") == true then rawset(st, "KickQueued", false) end
                if rawget(st, "TamperScore") ~= nil then rawset(st, "TamperScore", 0) end
                if rawget(st, "InvalidHeartbeatCount") ~= nil then rawset(st, "InvalidHeartbeatCount", 0) end

                local los = rawget(st, "LastObservedSample")
                if los ~= nil then
                    if rawget(st, "LastGameplayTrustedSample") == nil then rawset(st, "LastGameplayTrustedSample", los) end
                    if rawget(st, "LastValidatedSample") == nil then rawset(st, "LastValidatedSample", los) end
                    if rawget(st, "LastValidatedGroundedSample") == nil then rawset(st, "LastValidatedGroundedSample", los) end
                    if rawget(st, "LastConfirmedGroundSample") == nil then rawset(st, "LastConfirmedGroundSample", los) end
                    if rawget(st, "LastGoodSample") == nil then rawset(st, "LastGoodSample", los) end
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- STATE
farmEnabled    = false
farmDelay      = 1.5
farmSpeed      = 750
moveMethod     = "Tween Glide"
targetRarities = {}
targetAreas    = {}
targetMutations = {}
ignoredEggs    = {}
lingerActive   = false
SAFE_WAYPOINT_POS   = Vector3.new(516.4, 70.6, -367.3)
MAIN_ROAD_Z         = -364.5
SAFE_BOUNDARY_X     = 580
SAFE_ZONE_SPEED     = 245
selectedAreaTp = "Forest"
Rift           = nil
S = {
    autoFavoritePets = false,
    autoFusePets = false,
    favRarities = {},
    favNames = {},
    fuseSelectedOnly = false,
    fuseNames = {},
    fuseRarities = {},
    jumpPowerEnabled = false,
    jumpPowerValue = 50,
    infiniteJumpEnabled = false,
    stealBigEggsOnly = false,
    autoHatchEnabled = false,
    autoPlantEnabled = false,
    autoUpgradeBase = false,
    autoUpgradeTreadmill = false,
    autoEquipBestPets = false,
    autoClaimRewards = false,
    autoSellPets = false,
    autoSellEggs = false,
    batAuraEnabled = false,
    batAuraRadius = 20,
    batAuraDelay = 0.2,
    flyEnabled = false,
    flySpeed = 60,
    walkSpeedEnabled = false,
    walkSpeedVal = 24,
    avoidTrapsEnabled = false,
    fpsBoost = false,
    reduceMap = false,
    hideAllPets = false,
    hideAllEggs = false,
    hideOwnerEggs = false,
    hideOtherEggs = false,
    hidePlotVisuals = false,
    hideMoneyFX = false,
    selectedSellPetRarities = {},
    selectedSellEggRarities = {},
    placeRarities = {},
}

-- MODULE LOADER
local EggState, PlotState, AreaEggSlotIdentity
function loadModules()
    pcall(function() EggState = require(ReplicatedStorage.Client.EggState) end)
    pcall(function() PlotState = require(ReplicatedStorage.Client.PlotState) end)
    pcall(function()
        AreaEggSlotIdentity = require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity)
    end)
    return EggState ~= nil
end
pcall(loadModules)

function GetNetRemote(name)
    local net = ReplicatedStorage:FindFirstChild("Packages")
        and ReplicatedStorage.Packages:FindFirstChild("Networking")
    return net and net:FindFirstChild(name)
end

-- MISSING VARIABLES & HELPERS
local SaveModule = nil
pcall(function() SaveModule = require(ReplicatedStorage.Shared.Save) end)

local DEFAULT_LOW_TIER_SELL = {
    ["Common"] = true, ["Uncommon"] = true, ["Rare"] = true,
    ["Epic"] = true, ["Legendary"] = true, ["Mythic"] = true,
}
local SELL_REQUEST_DELAY = 0.1
function getSellRarityFilter(selected)
    if not selected or not next(selected) then return DEFAULT_LOW_TIER_SELL end
    return selected
end

local esp = {
    enabled = false, eggs = true, traps = false, players = false,
    rareEggsOnly = false, maxDistance = 800,
    eggColor     = Color3.fromRGB(255, 200, 50),
    rareEggColor = Color3.fromRGB(255, 60, 220),
    trapColor    = Color3.fromRGB(255, 60, 60),
    playerColor  = Color3.fromRGB(100, 220, 100),
}

local espHighlights  = {}
local espFolder      = nil

function getEspFolder()
    if espFolder and espFolder.Parent then return espFolder end
    local parent = nil
    pcall(function()
        parent = gethui and gethui() or game:GetService("CoreGui")
    end)
    if not parent then parent = LP:FindFirstChild("PlayerGui") end
    espFolder = Instance.new("Folder")
    espFolder.Name = "SAE_ESP"
    espFolder.Parent = parent
    return espFolder
end

function createEspEntry(key, model, color, label)
    local old = espHighlights[key]
    if old then
        pcall(function() old.hl:Destroy() end)
        pcall(function() old.bb:Destroy() end)
    end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.FillColor = color
    hl.OutlineColor = color
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = getEspFolder()

    local anchor = Instance.new("Part")
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanQuery = false
    anchor.Transparency = 1
    anchor.Size = Vector3.new(0.1, 0.1, 0.1)
    if model:IsA("BasePart") then
        anchor.CFrame = model.CFrame
    elseif model:IsA("Model") and model.PrimaryPart then
        anchor.CFrame = model.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
    end
    anchor.Parent = getEspFolder()

    local bb = Instance.new("BillboardGui")
    bb.Adornee = anchor
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(200, 30)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.Parent = anchor

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.Text = label
    lbl.Parent = bb

    espHighlights[key] = { hl = hl, bb = bb, anchor = anchor, lbl = lbl }
end

function clearEsp(key)
    local e = espHighlights[key]
    if e then
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.anchor:Destroy() end)
        espHighlights[key] = nil
    end
end

function clearAllEsp()
    for k in pairs(espHighlights) do clearEsp(k) end
end

task.spawn(function()
    while not false do
        task.wait(1)
        if not esp.enabled then
            clearAllEsp()
        else
            pcall(function()
                local hrp = findHRP()
                local myPos = hrp and hrp.Position or Vector3.zero
                local activeKeys = {}

                if esp.eggs and EggState and EggState.ReadFieldEggs then
                    local ok, snap = pcall(EggState.ReadFieldEggs)
                    if ok and snap and snap.Records then
                        for _, egg in ipairs(snap.Records) do
                            if egg.State == "Slot" and egg.BoundsCFrame then
                                local pos = egg.BoundsCFrame.Position
                                local dist = (pos - myPos).Magnitude
                                if dist <= esp.maxDistance then
                                    local muts = egg.Mutations or {}
                                    local isRare = #muts > 0
                                    if not esp.rareEggsOnly or isRare then
                                        local rName = GetEggRarityInfo(egg)
                                        local mutText = isRare and (" [" .. table.concat(muts, ",") .. "]") or ""
                                        local label = (egg.AssetCategory or "Egg") .. " | " .. rName .. mutText .. " | " .. math.floor(dist) .. "m"
                                        local color = isRare and esp.rareEggColor or esp.eggColor
                                        local key = "egg_" .. tostring(egg.Uid)
                                        activeKeys[key] = true
                                        local model = Workspace:FindFirstChild(egg.Uid, true)
                                        if model then
                                            if not espHighlights[key] then
                                                createEspEntry(key, model, color, label)
                                            else
                                                pcall(function() espHighlights[key].lbl.Text = label end)
                                                local mp = model:IsA("BasePart") and model.CFrame or (model.PrimaryPart and model.PrimaryPart.CFrame + Vector3.new(0,3,0))
                                                if mp then espHighlights[key].anchor.CFrame = mp end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if esp.traps then
                    local debris = Workspace:FindFirstChild("__DEBRIS")
                    if debris then
                        for _, trap in ipairs(debris:GetChildren()) do
                            if trap.Name == "PlayerTrap" and trap:IsA("BasePart") then
                                local dist = (trap.Position - myPos).Magnitude
                                if dist <= esp.maxDistance then
                                    local key = "trap_" .. trap:GetDebugId()
                                    activeKeys[key] = true
                                    local owner = trap:GetAttribute("Owner") or "?"
                                    if not espHighlights[key] then
                                        createEspEntry(key, trap, esp.trapColor, "TRAP @" .. owner)
                                    end
                                end
                            end
                        end
                    end
                end

                if esp.players then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character then
                            local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if oHrp then
                                local dist = (oHrp.Position - myPos).Magnitude
                                if dist <= esp.maxDistance then
                                    local key = "plr_" .. p.UserId
                                    activeKeys[key] = true
                                    if not espHighlights[key] then
                                        createEspEntry(key, p.Character, esp.playerColor, p.Name .. " | " .. math.floor(dist) .. "m")
                                    else
                                        pcall(function() espHighlights[key].lbl.Text = p.Name .. " | " .. math.floor(dist) .. "m" end)
                                    end
                                end
                            end
                        end
                    end
                end

                for k in pairs(espHighlights) do
                    if not activeKeys[k] then clearEsp(k) end
                end
            end)
        end
    end
    clearAllEsp()
end)

-- ==============================================================
-- RARITY & AREA DICTIONARIES
-- ==============================================================
local RARITY_SCORE_MAP = {
    ["Light & Dark"]=2200, ["LightDark"]=2200, ["Light &Dark"]=2200,
    Exclusive=2100, Admin=2100,
    Mythical=2000, ["Squishy God"]=2000, BrainrotGod=2000,
    Brainrot=1900,
    Eternal=1800, Rainbow=1700, Prismatic=1600, Transcendent=1500,
    Celestial=1400, Cosmic=1300,
    Titan=1200, Superior=1200,
    Secret=1100, Divine=1000,
    Limited=900, Exotic=800, SuperRare=700,
    Mythic=600, Legendary=500, Epic=400, Rare=300,
    Uncommon=200, Common=100,
}
local RARITY_NAMES = {
    "Light & Dark","Exclusive","Admin","Mythical","Squishy God","BrainrotGod","Brainrot",
    "Eternal","Rainbow","Prismatic","Transcendent","Celestial","Cosmic",
    "Titan","Superior","Secret","Divine","Limited","Exotic","SuperRare",
    "Mythic","Legendary","Epic","Rare","Uncommon","Common"
}
local AREA_NAMES = {
    "Forest","Lake","Desert","Jungle","Snow","Volcano",
    "Abyss Ocean","Prehistoric","Cosmic","Cherry Blossom","Titan Temple",
    "Light Dark","Angels & Demons",
}

local AREA_COORDINATES = {
    ["Base / Plot"]    = Vector3.new(491.7, 70.4, -364.4),
    ["Forest"]         = Vector3.new(596.0, 68.0, -328.0),
    ["Lake"]           = Vector3.new(744.0, 68.5, -408.0),
    ["Desert"]         = Vector3.new(948.0, 69.5, -323.0),
    ["Jungle"]         = Vector3.new(1188.0, 68.5, -408.0),
    ["Snow"]           = Vector3.new(1492.0, 69.0, -315.0),
    ["Volcano"]        = Vector3.new(1882.0, 68.0, -398.0),
    ["Abyss Ocean"]    = Vector3.new(2280.0, 68.0, -326.0),
    ["Prehistoric"]    = Vector3.new(2812.0, 69.0, -398.0),
    ["Cosmic"]         = Vector3.new(3390.0, 68.0, -324.0),
    ["Cherry Blossom"] = Vector3.new(4028.0, 68.5, -396.0),
    ["Titan Temple"]   = Vector3.new(4796.0, 69.5, -328.0),
    ["Light Dark"]     = Vector3.new(5660.0, 70.0, -331.0),
    ["Angels & Demons"]= Vector3.new(5600.0, 85.0, -328.0),
    ["Demons"]         = Vector3.new(5600.0, 85.0, -328.0),
    ["Dragon Event"]   = Vector3.new(539.5, 68.0, -318.0),
}

local areaKeys = {}
for k, _ in pairs(AREA_COORDINATES) do table.insert(areaKeys, k) end

-- ==============================================================
-- EGG HELPERS
-- ==============================================================
local _assetCache = {}
function getAssetData(record)
    if not record then return {} end
    local item = type(record.ItemData) == "table" and record.ItemData or record
    local cat = item.AssetCategory or item.Category or record.AssetCategory or record.Category
    if AssetsData and cat then
        local cached = _assetCache[cat]
        if cached then return cached end
        local ok, d = pcall(function()
            return (AssetsData.Directory or AssetsData)[cat] or {}
        end)
        if ok and d and next(d) then
            _assetCache[cat] = d
            return d
        end
    end
    return {
        EarningRate = record.EarningRate,
        ModelWeight = record.ModelWeight,
        DropWeight  = record.DropWeight,
        DisplayName = cat or record.DisplayName,
        Rarity      = record.Rarity,
        _id         = cat,
    }
end

function getEarningRate(record)
    if record and record.EarningRate then return tonumber(record.EarningRate) or 0 end
    return tonumber(getAssetData(record).EarningRate) or 0
end

function getModelWeight(record)
    if record and record.ModelWeight then return tonumber(record.ModelWeight) or 0 end
    return tonumber(getAssetData(record).ModelWeight) or 0
end

local _rarityKeyMap = nil
function buildRarityKeyMap()
    _rarityKeyMap = {}
    for canon, _ in pairs(RARITY_SCORE_MAP) do
        _rarityKeyMap[canon:lower():gsub("[^%a%d]", "")] = canon
    end
    _rarityKeyMap.lightdark = "Light & Dark"
    _rarityKeyMap.mythical  = "Mythical"
    _rarityKeyMap.brainrotgod = "BrainrotGod"
    _rarityKeyMap.brainrot  = "Brainrot"
    _rarityKeyMap.squishygod = "Squishy God"
    _rarityKeyMap.superrare = "SuperRare"
end

function normalizeRarityName(name)
    if not name then return nil end
    local s = tostring(name)
    if RARITY_SCORE_MAP[s] then return s end
    if not _rarityKeyMap then buildRarityKeyMap() end
    local key = s:lower():gsub("[^%a%d]", "")
    return _rarityKeyMap[key] or s
end

function getRarityName(record)
    local item = (record and type(record.ItemData) == "table") and record.ItemData or record
    if item then
        local r = item.Rarity or item.RarityTier or item.Tier
        if r then
            if type(r) == "table" and r._id then return normalizeRarityName(r._id) end
            if type(r) == "string" then return normalizeRarityName(r) end
        end
    end
    local d = getAssetData(record)
    return normalizeRarityName((d.Rarity and d.Rarity._id) or d.Rarity) or "Unknown"
end

function GetEggRarityInfo(egg)
    if not egg then return "Common", 100 end
    local name = getRarityName(egg)
    local score = RARITY_SCORE_MAP[name] or 100
    return name, score
end

function isRarityAllowed(name, filter)
    local f = filter or targetRarities
    if not f or not next(f) then return true end
    if not name or name == "" or name == "Unknown" then return true end
    if f[name] == true then return true end
    local nameLower = string.lower(tostring(name))
    for k, v in pairs(f) do
        if v == true and type(k) == "string" and string.lower(k) == nameLower then
            return true
        end
    end
    return false
end

function isAreaAllowed(areaId)
    if not next(targetAreas) then return true end
    if not areaId then return true end
    local aLower = tostring(areaId):lower()
    local aKey = aLower:gsub("[^%a%d]", "")
    for k in pairs(targetAreas) do
        local kLower = string.lower(k)
        if kLower == aLower then return true end
        if kLower:gsub("[^%a%d]", "") == aKey then return true end
    end
    return false
end

local _carriedUid = nil

function isCarryingEgg()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local dg = pg and pg:FindFirstChild("DropHeldEgg")
    if dg and dg.Enabled then return true end
    local ch = LP.Character
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and (
                t:GetAttribute("ItemType") == "AssetEgg" or
                t:GetAttribute("ItemType") == "PetEgg" or
                t:GetAttribute("Uid") ~= nil or
                t.Name:lower():find("egg")
            ) then return true end
        end
    end
    return false
end

function hasEggToolAnywhere(uid)
    if isCarryingEgg() then return true end
    local target = uid or _carriedUid
    if not target then return false end
    local containers = { LP.Character, LP:FindFirstChildOfClass("Backpack") }
    for _, c in ipairs(containers) do
        if c then
            for _, t in ipairs(c:GetChildren()) do
                if t:IsA("Tool") and tostring(t:GetAttribute("Uid")) == tostring(target) then
                    return true
                end
            end
        end
    end
    return false
end

function GetMatchingFieldEggs()
    if not EggState or not EggState.ReadFieldEggs then return {} end
    local ok, snap = pcall(EggState.ReadFieldEggs)
    if not ok or not snap or not snap.Records then return {} end
    local matched = {}
    for _, rec in ipairs(snap.Records) do
        if rec.State == "Slot" and rec.BoundsCFrame and rec.Uid then
            local ignored = ignoredEggs[rec.Uid] and (os.clock() - ignoredEggs[rec.Uid] < 3)
            if not ignored then
                local rName, rarScore = GetEggRarityInfo(rec)
                local rarOk = isRarityAllowed(rName, next(targetRarities) and targetRarities or nil)
                local areaOk = isAreaAllowed(rec.AreaId, next(targetAreas) and targetAreas or nil)
                local mutOk = isMutationAllowed(rec.Mutations, rec, targetMutations)
                if rarOk and areaOk and mutOk then
                    table.insert(matched, { record = rec, score = rarScore, rarity = rName })
                end
            end
        end
    end
    table.sort(matched, function(a, b) return a.score > b.score end)
    return matched
end

-- EXTRA FUNCTIONS
local EggToolDisplay = nil
pcall(function() EggToolDisplay = require(RS.Shared.Eggs.EggToolDisplay) end)

function SetNoKnockback(enabled)
    if enabled then
        pcall(function()
            local rigSync = GetNetRemote("RE/RigSync/Refresh")
            if rigSync and getconnections then
                for _, conn in ipairs(getconnections(rigSync.OnClientEvent)) do
                    pcall(function() conn:Disconnect() end)
                end
            end
        end)
    end
end
pcall(function() SetNoKnockback(true) end)

function GetLocalPlotCenter()
    local plotObj = PlotState and PlotState.ResolvePlot and PlotState.ResolvePlot()
    local pt = plotObj and plotObj.CenterPoint and (
        typeof(plotObj.CenterPoint) == "Vector3" and plotObj.CenterPoint or
        (plotObj.CenterPoint:IsA("BasePart") and plotObj.CenterPoint.Position)
    )
    if pt then
        return Vector3.new(pt.X, math.max(pt.Y, 70.4), pt.Z), CFrame.new(pt.X, math.max(pt.Y, 70.4), pt.Z)
    end
    return Vector3.new(464.7, 70.4, -364.0), CFrame.new(464.7, 70.4, -364.0)
end

function isMutationAllowed(muts, record, filter)
    local isParasite = (record and record.HasParasite == true)
        or (type(muts) == "table" and (table.find(muts, "Parasite") or table.find(muts, "Monstrous")))
        or (record and (record.BaseMutation == "Parasite" or record.BaseMutation == "Monstrous"))
    if not filter or type(filter) ~= "table" then return true end
    local count = 0; for _ in pairs(filter) do count = count + 1 end
    if count == 0 then return true end
    local hasMut = type(muts) == "table" and #muts > 0
    local allowed = false
    for _, opt in pairs(filter) do
        if type(opt) == "string" then
            if opt == "Normal Only" and not hasMut and not isParasite then allowed = true
            elseif opt == "Mutated Only" and (hasMut or isParasite) then allowed = true
            elseif (opt == "Parasite / Infested" or opt == "Monstrous") and isParasite then allowed = true
            elseif opt == "Silver Only" and type(muts) == "table" and table.find(muts, "Silver") then allowed = true
            elseif opt == "Gold Only" and type(muts) == "table" and (table.find(muts, "Gold") or table.find(muts, "Golden")) then allowed = true
            elseif opt == "Rainbow Only" and type(muts) == "table" and table.find(muts, "Rainbow") then allowed = true
            end
        end
    end
    return allowed
end

function isBigEgg(record)
    if not record then return false end
    local scale = tonumber(record.AssetScale) or 1
    local nestScale = tonumber(record.NestScale) or 1
    return scale >= 1.35 or nestScale >= 1.0
end

function DeleteOwnPetRenders()
    local count = 0
    function sweep(container)
        if not container then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                pcall(function() child:Destroy(); count = count + 1 end)
            end
        end
    end
    sweep(Workspace:FindFirstChild("Pets"))
    sweep(Workspace:FindFirstChild("RenderedPets"))
    return count
end

-- AUTO PLACE EGGS
function getPenInfo()
    local pd
    pcall(function() pd = PlotState and PlotState.ResolvePlot and PlotState.ResolvePlot() end)
    if not pd then return nil end
    local pa = pd.PetArea
    if not (pa and pa:IsA("BasePart")) then return nil end
    local cp = pa.CFrame
    local c = pd.CenterPoint
    if typeof(c) == "CFrame" then cp = c
    elseif typeof(c) == "Instance" and c:IsA("BasePart") then cp = c.CFrame end
    return pa, cp
end

function getMyEggRecords()
    if not EggState then return nil end
    local reader = EggState.ReadOwnedEggs or EggState.ReadOwnerEggs
    if not reader then return nil end
    local ok, snap = pcall(reader, LP.UserId)
    if not ok or type(snap) ~= "table" then return nil end
    return snap.Records or snap
end

function placeRarityOk(rec)
    if not next(S.placeRarities) then return true end
    local rName = GetEggRarityInfo(rec)
    return isRarityAllowed(rName, S.placeRarities)
end

function PlantAllCarriedEggsInPen()
    if not LP.Character then return 0 end
    if not EggState or not EggState.PlantEgg then return 0 end
    local pa, cp = getPenInfo()
    if not pa or not cp then return 0 end

    local records = getMyEggRecords()
    if type(records) ~= "table" then return 0 end

    local unplaced, occupied = {}, {}
    for uid, rec in pairs(records) do
        if type(rec) == "table" then
            local placement = rec.Placement
            if placement == nil then
                if placeRarityOk(rec) then unplaced[#unplaced + 1] = uid end
            else
                local lc = type(placement) == "table" and placement.LocalCFrame or nil
                if typeof(lc) == "CFrame" then
                    occupied[string.format("%.0f_%.0f", lc.X, lc.Z)] = true
                end
            end
        end
    end
    if #unplaced == 0 then return 0 end

    local MARGIN, STEP = 3, 5.5
    local sz = pa.Size
    local minx, maxx, minz, maxz = math.huge, -math.huge, math.huge, -math.huge
    for _, sx in ipairs({ -0.5, 0.5 }) do
        for _, sz2 in ipairs({ -0.5, 0.5 }) do
            local w = pa.CFrame:PointToWorldSpace(Vector3.new(sz.X * sx, 0, sz.Z * sz2))
            local l = cp:PointToObjectSpace(w)
            minx = math.min(minx, l.X); maxx = math.max(maxx, l.X)
            minz = math.min(minz, l.Z); maxz = math.max(maxz, l.Z)
        end
    end
    minx, maxx = minx + MARGIN, maxx - MARGIN
    minz, maxz = minz + MARGIN, maxz - MARGIN
    if maxx <= minx or maxz <= minz then return 0 end

    local slots = {}
    local x = minx
    while x <= maxx do
        local z = minz
        while z <= maxz do
            if not occupied[string.format("%.0f_%.0f", x, z)] then
                slots[#slots + 1] = { x = x, z = z }
            end
            z = z + STEP
        end
        x = x + STEP
    end
    if #slots == 0 then return 0 end

    local hrp = findHRP()
    if hrp and (hrp.Position - pa.CFrame.Position).Magnitude > 60 then
        hrp.CFrame = CFrame.new(pa.CFrame.Position + Vector3.new(0, 4, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.5)
    end

    local planted = 0
    for _, uid in ipairs(unplaced) do
        local eqOk
        pcall(function() eqOk = EggState.WearEggTool(uid) end)
        if eqOk ~= true then
            pcall(function()
                local ch = LP.Character
                local bag = LP:FindFirstChild("Backpack")
                for _, src in ipairs({ ch, bag }) do
                    if src then
                        for _, t in ipairs(src:GetChildren()) do
                            if t:IsA("Tool") and tostring(t:GetAttribute("UID")) == tostring(uid) then
                                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                                if hum and t.Parent ~= ch then hum:EquipTool(t) end
                                eqOk = true
                                return
                            end
                        end
                    end
                end
            end)
        end
        if eqOk == true then
            task.wait(0.15)
            for i = 1, #slots do
                local slot = slots[i]
                local res
                pcall(function()
                    res = EggState.PlantEgg(uid, CFrame.new(slot.x, -0.5, slot.z))
                end)
                if res == true then
                    planted = planted + 1
                    table.remove(slots, i)
                    break
                end
            end
        end
        task.wait(0.05)
    end
    return planted
end

-- BYPASS DELIVERY
local BYPASS_TARGET_CFRAME = CFrame.new(546.8, 70.6, -364.6)
local TARGET_PART_NAME     = "SpawnLocation"
local FLOAT_HEIGHT         = 6.7
local LEG_OFFSET           = Vector3.new(0, -FLOAT_HEIGHT, 0)
local BYPASS_HEIGHT_OFFSET = Vector3.new(0, FLOAT_HEIGHT, 0)

local _bypassConn    = nil
local _isBypassing   = false
local _canBypass     = true

function startBypass()
    local targetPart = Workspace:FindFirstChild(TARGET_PART_NAME, true)
    if not targetPart or not targetPart:IsA("BasePart") then return false end
    targetPart.CanCollide = false
    _isBypassing = true
    _bypassConn = RunService.Heartbeat:Connect(function()
        local hrp = findHRP()
        if not _isBypassing or not hrp or not hrp.Parent then return end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        targetPart.CFrame = hrp.CFrame * CFrame.new(LEG_OFFSET)
        hrp.CFrame = BYPASS_TARGET_CFRAME + BYPASS_HEIGHT_OFFSET
        targetPart.CFrame = BYPASS_TARGET_CFRAME
    end)
    return true
end

function stopBypass()
    _isBypassing = false
    if _bypassConn then
        _bypassConn:Disconnect()
        _bypassConn = nil
    end
    local hrp = findHRP()
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    task.spawn(function()
        _canBypass = false
        for i = 15, 1, -1 do
            if _isBypassing then return end
            task.wait(0.1)
        end
        _canBypass = true
    end)
end

function bypassDeliver(timeout)
    timeout = timeout or 5
    if not _canBypass then
        print("[W424] bypass cooldown, tunggu...")
        local t0 = os.clock()
        while not _canBypass and os.clock() - t0 < 2 do task.wait(0.1) end
    end
    print("[W424] bypass delivery start...")
    if not startBypass() then
        print("[W424] SpawnLocation not found!")
        return false
    end
    local t0 = os.clock()
    while os.clock() - t0 < timeout do
        if not isCarryingEgg() then break end
        task.wait(0.05)
    end
    stopBypass()
    return not isCarryingEgg()
end

-- TWEEN GLIDE NAVIGATION
function MoveToPoint(target, speed, easeOut)
    local hrp = findHRP()
    if not hrp or not target then return false end

    local start = hrp.Position
    local dist = (target - start).Magnitude
    if dist < 1.0 then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end

    speed = math.clamp(tonumber(speed) or farmSpeed or 750, 50, 1000)

    local t0 = os.clock()
    local totalDist = dist
    while not false do
        local dt = RunService.Heartbeat:Wait()
        dt = math.clamp(dt, 0.001, 1 / 30)
        hrp = findHRP()
        if not hrp then break end
        local curPos = hrp.Position
        if curPos.Y < 60 then
            hrp.CFrame = CFrame.new(curPos.X, 70.4, MAIN_ROAD_Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            curPos = hrp.Position
        end
        local toTarget = target - curPos
        local remain = toTarget.Magnitude
        if remain < 1.0 then break end
        local stepSpeed = speed
        if easeOut then
            local progress = 1 - math.clamp(remain / totalDist, 0, 1)
            stepSpeed = math.max(speed * (1 - progress * 0.8), 35)
        end
        local step = math.min(stepSpeed * dt, remain)
        local dir = toTarget.Unit
        local nextPos = curPos + dir * step
        hrp.CFrame = CFrame.lookAt(nextPos, nextPos + dir)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if os.clock() - t0 > (totalDist / 50 + 5) then break end
    end

    hrp = findHRP()
    if hrp then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    return true
end

function FlyToPoint(target, speed, easeOut)
    local hrp = findHRP()
    if not hrp or not target then return false end
    if HUB.dead then return false end

    speed = math.clamp(tonumber(speed) or farmSpeed or 750, 50, 1000)

    local startDist = (target - hrp.Position).Magnitude
    if startDist < 1.0 then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end

    local t0 = os.clock()
    -- generous timeout that scales with actual speed + ease-out slowdown
    local timeout = startDist / speed * 3 + 5

    while not HUB.dead do
        local dt = RunService.Heartbeat:Wait()
        dt = math.clamp(dt, 0.001, 1 / 30)
        hrp = findHRP()
        if not hrp then break end

        local curPos = hrp.Position
        if curPos.Y < 60 then
            hrp.CFrame = CFrame.new(curPos.X, 70.4, MAIN_ROAD_Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            curPos = hrp.Position
        end

        local toTarget = target - curPos
        local remain = toTarget.Magnitude
        if remain < 1.0 then break end

        local curSpeed = speed
        if easeOut then
            local progress = 1 - math.clamp(remain / startDist, 0, 1)
            curSpeed = math.max(speed * (1 - progress * 0.8), 35)
        end

        local step = math.min(curSpeed * dt, remain)
        local dir = toTarget.Unit
        local nextPos = curPos + dir * step
        nextPos = Vector3.new(nextPos.X, math.max(nextPos.Y, 70.0), nextPos.Z)

        -- Face forward using horizontal direction only (prevents flipping during steep climbs/descents)
        local face = Vector3.new(dir.X, 0, dir.Z)
        if face.Magnitude < 0.01 then
            local lv = hrp.CFrame.LookVector
            face = Vector3.new(lv.X, 0, lv.Z)
        end
        if face.Magnitude < 0.01 then face = Vector3.new(0, 0, 1) end

        -- PURE CFrame movement — do NOT set a non-zero velocity, it fights the teleport
        hrp.CFrame = CFrame.lookAt(nextPos, nextPos + face.Unit)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        if os.clock() - t0 > timeout then break end
    end

    hrp = findHRP()
    if hrp then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    return true
end

function TravelFlyDirect(targetPos, speed, isApproach)
    local hrp = findHRP()
    if not hrp or not targetPos then return false end
    if S.avoidTrapsEnabled then pcall(NeutralizeTraps) end

    local startPos = hrp.Position
    local isReturningToBase = (targetPos.X < SAFE_BOUNDARY_X)
    local flyAltitude = math.max(startPos.Y, targetPos.Y, 70.4) + 28

    if isReturningToBase then
        local pSky1 = Vector3.new(startPos.X, flyAltitude, startPos.Z)
        local pSkySafe = Vector3.new(SAFE_BOUNDARY_X, flyAltitude, MAIN_ROAD_Z)
        FlyToPoint(pSky1, speed, false)
        FlyToPoint(pSkySafe, speed, false)

        local pGroundSafe = Vector3.new(SAFE_BOUNDARY_X, 70.4, MAIN_ROAD_Z)
        FlyToPoint(pGroundSafe, SAFE_ZONE_SPEED, false)

        local pBaseRoad = Vector3.new(targetPos.X, 70.4, MAIN_ROAD_Z)
        MoveToPoint(pBaseRoad, SAFE_ZONE_SPEED, false)

        local pPen = targetPos + Vector3.new(0, 1.2, 0)
        MoveToPoint(pPen, SAFE_ZONE_SPEED, isApproach == true)
        return true
    else
        local totalDist = (targetPos - startPos).Magnitude
        if totalDist < 25 then
            FlyToPoint(Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z), speed, isApproach == true)
            return true
        end

        local pSky1 = Vector3.new(startPos.X, flyAltitude, startPos.Z)
        local pSky2 = Vector3.new(targetPos.X, flyAltitude, targetPos.Z)
        local pGround = Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z)

        FlyToPoint(pSky1, speed, false)
        FlyToPoint(pSky2, speed, false)
        FlyToPoint(pGround, speed, isApproach == true)
        return true
    end
end

function travelToEgg(targetPos, spd)
    spd = spd or farmSpeed
    if moveMethod == "Fly Glide" then
        TravelFlyDirect(targetPos, spd, true)
    else
        local hrp = findHRP()
        if not hrp then return end
        local startPos = hrp.Position
        if startPos.X < SAFE_BOUNDARY_X then
            local roadEntry = Vector3.new(SAFE_BOUNDARY_X + 20, 70.4, MAIN_ROAD_Z)
            MoveToPoint(roadEntry, spd, false)
        end
        MoveToPoint(targetPos, spd, true)
    end
end

function travelToBase(spd)
    spd = spd or farmSpeed
    if _isBypassing or _bypassConn then
        _isBypassing = false
        if _bypassConn then
            pcall(function() _bypassConn:Disconnect() end)
            _bypassConn = nil
        end
        task.wait(0.1)
    end
    if moveMethod == "Fly Glide" then
        TravelFlyDirect(SAFE_WAYPOINT_POS, spd, false)
    else
        MoveToPoint(SAFE_WAYPOINT_POS, spd, false)
    end
    for _ = 1, 3 do
        local hrpEnd = findHRP()
        if not hrpEnd then break end
        if (hrpEnd.Position - SAFE_WAYPOINT_POS).Magnitude <= 8 then break end
        MoveToPoint(SAFE_WAYPOINT_POS, spd, false)
    end
end

function ensureInSafeZone(spd)
    spd = spd or farmSpeed
    for _ = 1, 8 do
        local hrp = findHRP()
        if hrp then
            if (hrp.Position - SAFE_WAYPOINT_POS).Magnitude <= 12 then return true end
            travelToBase(spd)
            hrp = findHRP()
            if hrp and (hrp.Position - SAFE_WAYPOINT_POS).Magnitude <= 12 then return true end
        end
        task.wait(0.25)
    end
    return false
end

-- STEAL CORE HELPERS
function fireCarry(uid, slotKey, carryRemote, prompt)
    if carryRemote then pcall(function() carryRemote:InvokeServer(uid, slotKey) end) end
    pcall(function()
        if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(uid, slotKey) end
    end)
    if prompt then
        pcall(function()
            prompt.Enabled = true
            prompt.HoldDuration = 0
            fireproximityprompt(prompt, 0)
        end)
    end
end

function findPrompt(uid)
    local prompt = nil
    pcall(function()
        local sc = Workspace:FindFirstChild("AreaEggSlotsClient")
        local em = (sc and sc:FindFirstChild(uid)) or Workspace:FindFirstChild(uid, true)
        if em then
            prompt = em:FindFirstChild("CarryAreaEgg", true)
                or em:FindFirstChildWhichIsA("ProximityPrompt", true)
        end
    end)
    return prompt
end

function isRagdolled()
    local h = findHum()
    local ch = LP.Character
    if not h or not ch then return false end
    local hs = h:GetState()
    if hs == Enum.HumanoidStateType.Physics
        or hs == Enum.HumanoidStateType.Ragdoll
        or hs == Enum.HumanoidStateType.FallingDown then
        return true
    end
    if ch:GetAttribute("Ragdoll") == true
        or ch:GetAttribute("Ragdolled") == true
        or ch:GetAttribute("IsRagdoll") == true
        or ch:GetAttribute("Downed") == true
        or ch:GetAttribute("KnockedBack") == true then
        return true
    end
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("Motor6D") and not v.Enabled then return true end
    end
    local hrp = findHRP()
    if hrp then
        local vel = hrp.AssemblyLinearVelocity
        if Vector3.new(vel.X, 0, vel.Z).Magnitude > 25 then
            return true
        end
    end
    return false
end

function waitStandup(waitTime)
    local t0 = os.clock()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        pcall(function()
            local h = findHum()
            local ch = LP.Character
            if h then
                h.PlatformStand = false
                h.AutoRotate = true
            end
            if ch then
                for _, att in ipairs({"Ragdoll","Ragdolled","IsRagdoll","Downed","KnockedBack"}) do
                    if ch:GetAttribute(att) then ch:SetAttribute(att, false) end
                end
            end
        end)
    end)
    while os.clock() - t0 < waitTime and not false do
        if not isRagdolled() then break end
        local h = findHum()
        pcall(function()
            if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end)
        task.wait(0.05)
    end
    if conn then conn:Disconnect() end
    pcall(function()
        local ch = LP.Character
        if ch then
            for _, v in ipairs(ch:GetDescendants()) do
                if v:IsA("Motor6D") and not v.Enabled then
                    v.Enabled = true
                end
            end
        end
        local h = findHum()
        if h then
            h.PlatformStand = false
            h.AutoRotate = true
            h:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
    task.wait(0.05)
end

-- STEAL CYCLE
function stealCycle()
    if not farmEnabled then return false end

    pcall(function()
        local h = findHum()
        if h then h.PlatformStand = false; h.AutoRotate = true end
    end)

    local eggs = GetMatchingFieldEggs()
    if #eggs == 0 then return false end
    local record = eggs[1].record
    if not record or not record.Uid or not record.BoundsCFrame then return false end

    if EggState and EggState.ReadFieldEggs then
        local ok, snap = pcall(EggState.ReadFieldEggs)
        if ok and snap and snap.Records then
            local stillThere = false
            for _, r in ipairs(snap.Records) do
                if r.Uid == record.Uid and r.State == "Slot" then
                    stillThere = true; record = r; break
                end
            end
            if not stillThere then return false end
        end
    end

    local targetPos = record.BoundsCFrame.Position
    local speed = math.clamp(farmSpeed or 750, 50, 1000)

    local slotKey = nil
    if record.AreaId and record.NestId then
        pcall(function()
            if AreaEggSlotIdentity and AreaEggSlotIdentity.SlotKey then
                slotKey = AreaEggSlotIdentity.SlotKey(record.AreaId, record.NestId)
            end
        end)
        if not slotKey then
            slotKey = tostring(record.AreaId) .. ":" .. tostring(record.NestId)
        end
    end

    local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
    local carryRemote = net and net:FindFirstChild("RF/EggWorld/AskFieldEggCarry")
    local dropRemote  = net and net:FindFirstChild("RF/EggWorld/AskFieldEggDrop")

    function doCarry()
        if carryRemote then pcall(function() carryRemote:InvokeServer(record.Uid, slotKey) end) end
        pcall(function()
            if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end
        end)
        local p = nil
        pcall(function()
            local sc = Workspace:FindFirstChild("AreaEggSlotsClient")
            local em = (sc and sc:FindFirstChild(record.Uid)) or Workspace:FindFirstChild(record.Uid, true)
            if em then p = em:FindFirstChild("CarryAreaEgg", true) or em:FindFirstChildWhichIsA("ProximityPrompt", true) end
        end)
        if p then p.HoldDuration = 0; pcall(function() fireproximityprompt(p) end) end
    end

    travelToEgg(targetPos + Vector3.new(0, 1.2, 0), speed)
    if false or not farmEnabled then return false end

    local hrp = findHRP()
    if hrp then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.2, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    task.wait(0.5)

    doCarry()
    if not isCarryingEgg() and carryRemote then
        pcall(function() carryRemote:InvokeServer({ Uid = record.Uid, FirstAreaSlotKey = slotKey }) end)
    end

    local tPickup = os.clock()
    local lastRefresh = 0
    while os.clock() - tPickup < 3.0 and farmEnabled do
        if isCarryingEgg() then break end
        doCarry()
        if os.clock() - lastRefresh > 0.3 then
            lastRefresh = os.clock()
            pcall(function()
                local sc = Workspace:FindFirstChild("AreaEggSlotsClient")
                local em = (sc and sc:FindFirstChild(record.Uid)) or Workspace:FindFirstChild(record.Uid, true)
                if em then
                    local p2 = em:FindFirstChild("CarryAreaEgg", true) or em:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p2 then p2.Enabled = true; p2.HoldDuration = 0 end
                end
            end)
        end
        task.wait(0.08)
    end

    if not isCarryingEgg() then
        if dropRemote then pcall(function() dropRemote:InvokeServer() end) end
        if EggState and EggState.DropFieldEgg then pcall(EggState.DropFieldEgg) end
        ignoredEggs[record.Uid] = os.clock()
        print("[W424] carry failed")
        return false
    end

    _carriedUid = record.Uid
    print("[W424] carry OK, tunggu guard...")

    local startHealth = 100
    local hum0 = findHum()
    if hum0 then startHealth = hum0.Health end
    local wasHit = false
    lingerActive = true
    local tGuard = os.clock()
    while os.clock() - tGuard < 4.0 and not false and farmEnabled do
        if not isCarryingEgg() then wasHit = true; break end
        local h = findHum()
        if h then
            local hs = h:GetState()
            if h.Health < startHealth - 1.5
                or hs == Enum.HumanoidStateType.Physics
                or hs == Enum.HumanoidStateType.Ragdoll
                or hs == Enum.HumanoidStateType.FallingDown then
                wasHit = true
                local tPost = os.clock()
                while os.clock() - tPost < 0.85 and not false do
                    if not isCarryingEgg() then break end
                    task.wait(0.05)
                end
                break
            end
        end
        task.wait(0.05)
    end

    lingerActive = false
    if wasHit or not isCarryingEgg() then
        print("[W424] kena guard, spam carry saat ragdoll...")
        task.wait(0.1)

        local reCarryOk = false
        local tSpam = os.clock()
        while os.clock() - tSpam < 3.5 and not false and farmEnabled do
            if isCarryingEgg() then reCarryOk = true; break end
            doCarry()
            task.wait(0.08)
        end

        if not reCarryOk then
            print("[W424] carry spam failed, waiting for standup...")
            local tRag = os.clock()
            while os.clock() - tRag < 3.2 and not false do
                local h = findHum()
                if not h then break end
                local hs = h:GetState()
                if hs ~= Enum.HumanoidStateType.Physics
                    and hs ~= Enum.HumanoidStateType.Ragdoll
                    and hs ~= Enum.HumanoidStateType.FallingDown then break end
                pcall(function() h:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                task.wait(0.12)
            end
            task.wait(0.35)

            local hrpNow = findHRP()
            if hrpNow and (hrpNow.Position - targetPos).Magnitude > 14 then
                pcall(function()
                    hrpNow.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.8, 0))
                    hrpNow.AssemblyLinearVelocity = Vector3.zero
                    hrpNow.AssemblyAngularVelocity = Vector3.zero
                end)
                task.wait(0.35)
            end

            for _retry = 1, 3 do
                if isCarryingEgg() then reCarryOk = true; break end
                doCarry()
                task.wait(0.3)
                if isCarryingEgg() then reCarryOk = true; break end
            end
        end

        if not reCarryOk then
            if dropRemote then pcall(function() dropRemote:InvokeServer() end) end
            if EggState and EggState.DropFieldEgg then pcall(EggState.DropFieldEgg) end
            ignoredEggs[record.Uid] = os.clock()
            print("[W424] re-carry failed completely, skipping")
            return false
        end

        print("[W424] recarry OK!")
        local hrpEsc = findHRP()
        if hrpEsc then
            local toBase = SAFE_WAYPOINT_POS - hrpEsc.Position
            if toBase.Magnitude > 1 then
                local dist150 = toBase.Unit * 150
                hrpEsc.CFrame = CFrame.new(hrpEsc.Position + dist150)
                hrpEsc.AssemblyLinearVelocity = Vector3.zero
                hrpEsc.AssemblyAngularVelocity = Vector3.zero
            end
        end
        task.wait(0.2)
        print("[W424] bypass ON...")
        startBypass()
        task.wait(1.5)
    end

    local t0bypass = os.clock()
    while os.clock() - t0bypass < 5 do
        if not hasEggToolAnywhere(record.Uid) then break end
        task.wait(0.05)
    end
    stopBypass()
    if hasEggToolAnywhere(record.Uid) then
        print("[W424] timeout, egg not delivered yet, skipping")
        stopBypass()
        ignoredEggs[record.Uid] = os.clock()
        ensureInSafeZone(speed)
        return false
    end
    print("[W424] DELIVERED!, heading home now...")
    task.wait(0.1)
    local hrpNow = findHRP()
    if hrpNow then
        local dist = (hrpNow.Position - SAFE_WAYPOINT_POS).Magnitude
        if dist > 50 then
             print("[W424] Too far from base ("..dist.." studs), moving back now.")
             travelToBase(speed)
        else
             print("[W424] Close enough to base, no big move needed.")
        end
    end

    if hasEggToolAnywhere(record.Uid) then
        print("[W424] Still holding egg after movement attempt, ensuring safety first.")
        ensureInSafeZone(speed)
        _carriedUid = nil
        return false
    end

    ensureInSafeZone(speed)
    _carriedUid = nil

    print("[W424] cycle selesai")
    return true
end

-- ANTI RAGDOLL PERMANENT
track(RunService.Heartbeat:Connect(function()
    if lingerActive then return end
    local h = findHum()
    if not h then return end
    if h:GetState() == Enum.HumanoidStateType.Physics then
        h:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end))

-- FARM LOOP
task.spawn(function()
    while true do
        if farmEnabled then
            if hasEggToolAnywhere() then
                print("[W424] still carrying an egg, returning to base before next cycle...")
                travelToBase(farmSpeed)
                local tCarry = os.clock()
                while hasEggToolAnywhere() and os.clock() - tCarry < 6 do
                    task.wait(0.15)
                end
            end
            task.wait(math.max(tonumber(farmDelay) or 1.5, 1.0))
            if ensureInSafeZone(farmSpeed) then
                task.wait(0.8)
                local cycle = stealCycle
                local ok, err = pcall(cycle)
                if not ok then print("[W424] error: " .. tostring(err)) end
            else
                print("[W424] could not reach the safe zone, retrying...")
            end
        end
        task.wait(0.5)
    end
end)

pcall(function()
    local pps = game:GetService("ProximityPromptService")
    track(pps.PromptButtonHoldBegan:Connect(function(prompt, player)
        if player == LP and prompt.Name == "CarryAreaEgg" then
            prompt.HoldDuration = 0
        end
    end))
end)

-- BASE & AUTOMATION FUNCTIONS
function HatchAllReadyEggs()
    if not EggState or not (EggState.ReadOwnedEggs or EggState.ReadOwnerEggs) then return 0 end
    local reader = EggState.ReadOwnedEggs or EggState.ReadOwnerEggs
    local ok, snapshot = pcall(reader, LP.UserId)
    if not ok or not snapshot then return 0 end
    local count = 0
    local records = snapshot.Records or snapshot
    if typeof(records) ~= "table" then return 0 end
    for uid, eggData in pairs(records) do
        if typeof(eggData) == "table" then
            local isReady = false
            if EggState.IsReadyToHatch then isReady = EggState.IsReadyToHatch(eggData)
            else isReady = eggData.Placement ~= nil end
            if isReady then
                pcall(function()
                    if EggState.BeginHatch then EggState.BeginHatch(uid) end
                    task.wait(0.05)
                    if EggState.FinishHatch then EggState.FinishHatch(uid) end
                    count = count + 1
                end)
            end
        end
    end
    return count
end

function UpgradeHomesteadBase()
    local r1 = GetNetRemote("RE/Homestead/AskNearbyPurchase")
    if r1 then pcall(function() r1:FireServer() end) end
    local r2 = GetNetRemote("RE/Homestead/AskBaseTierRaise")
    if r2 then pcall(function() r2:FireServer() end) end
end

function UpgradeTreadmillTier()
    local rf = GetNetRemote("RF/Treadmill/AskTierRaise")
    if rf then pcall(function() rf:InvokeServer() end) end
end

function EquipBestPets()
    local rf = GetNetRemote("RF/Haul/WearBest") or GetNetRemote("RF/PenRoster/ConfirmEquipBestBadge")
    if rf then pcall(function() rf:InvokeServer() end) end
end

function SellSelectedPets()
    local re = GetNetRemote("RE/PetSatchel/SellPet")
    if not re or not SaveModule then return end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    local inv = save and save.Inventory
    if type(inv) ~= "table" then return end
    for uid, petData in pairs(inv) do
        if type(petData) == "table" and not petData.Locked then
            local rName = petData.Rarity or "Common"
            if isRarityAllowed(rName, getSellRarityFilter(S.selectedSellPetRarities)) then
                pcall(function() re:FireServer(uid) end)
                task.wait(SELL_REQUEST_DELAY)
            end
        end
    end
end

function SellSelectedEggs()
    if not SaveModule then return end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    local inv = save and save.EggInventory
    if type(inv) ~= "table" then return end
    local wear = GetNetRemote("RF/EggWorld/AskWearTool")
    local sell = GetNetRemote("RE/PetSatchel/SellPet")
    if not wear or not sell then return end
    for uid, eggData in pairs(inv) do
        if type(eggData) == "table" and not eggData.Placement and not eggData.Locked then
            local rName = GetEggRarityInfo(eggData)
            if isRarityAllowed(rName, getSellRarityFilter(S.selectedSellEggRarities)) then
                pcall(function() wear:InvokeServer(uid) end)
                pcall(function() sell:FireServer({ uid }) end)
                task.wait(SELL_REQUEST_DELAY)
            end
        end
    end
end

function ClaimAllAvailableRewards()
    pcall(function()
        local rf1 = GetNetRemote("RF/AwayEarnings/AskCollect")
        if rf1 then rf1:InvokeServer() end
    end)
    pcall(function()
        local rf2 = GetNetRemote("RF/Codex/AskRedeemAll")
        if rf2 then rf2:InvokeServer() end
    end)
    pcall(function()
        local rf3 = GetNetRemote("RF/GroupPerk/RedeemPerk")
        if rf3 then rf3:InvokeServer() end
    end)
end

function ResolveAreaId(name)
    local dir = AreasData and AreasData.Directory
    if type(dir) ~= "table" then return tostring(name) end
    local lower = string.lower(tostring(name))
    for id, info in pairs(dir) do
        if string.lower(tostring(id)) == lower then return id end
        if type(info) == "table" and info.DisplayName
            and string.lower(tostring(info.DisplayName)) == lower then
            return id
        end
    end
    return tostring(name)
end

local AreasData = nil
pcall(function() AreasData = require(RS.Data.Areas) end)
local RarityData = nil
pcall(function() RarityData = require(RS.Data.Rarity) end)
local AssetsData = nil
pcall(function() AssetsData = require(RS.Data.Assets) end)

function SafeTeleport(targetPos)
    local root = findHRP()
    if not root or not targetPos then return false end
    root.CFrame = CFrame.new(targetPos.X, math.max(targetPos.Y, 70.0), targetPos.Z)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return true
end

local AssetItemsMod = nil
pcall(function() AssetItemsMod = require(RS.Shared.Util.AssetItems) end)

-- AUTO FAVORITE
function FavoriteMatchesPet(category)
    if not category then return false end
    if next(S.favRarities) then
        local _, rarName = GetEggRarityInfo({ AssetCategory = category })
        if not S.favRarities[rarName] then return false end
    end
    if next(S.favNames) then
        for k in pairs(S.favNames) do
            if tostring(k):lower() == tostring(category):lower() then return true end
        end
        return false
    end
    return true
end

function AutoFavoritePets()
    if not SaveModule or not AssetItemsMod then return 0 end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    if not save or type(save.Inventory) ~= "table" then return 0 end
    local favRe = GetNetRemote("RE/PetSatchel/WriteFavourite")
        or GetNetRemote("RF/PetSatchel/WriteFavourite")
    if not favRe then return 0 end
    local count = 0
    for uid, data in pairs(save.Inventory) do
        local ok, decoded = pcall(AssetItemsMod.Decode, data)
        if ok and decoded and not decoded.IsFavorite then
            if FavoriteMatchesPet(decoded.Category) then
                pcall(function()
                    if favRe:IsA("RemoteEvent") then
                        favRe:FireServer(uid, true)
                    else
                        favRe:InvokeServer(uid, true)
                    end
                end)
                count = count + 1
                if count % 10 == 0 then task.wait(0.05) end
            end
        end
    end
    return count
end

-- AUTO FUSE
function FuseMatchesPet(category, rarName)
    if S.fuseSelectedOnly then
        if not next(S.fuseNames) then return false end
        return S.fuseNames[category] == true
    end
    if next(S.fuseRarities) then
        return S.fuseRarities[rarName] == true
    end
    return false
end

function AutoFusePets()
    if not SaveModule or not AssetItemsMod then return false, "modules not ready" end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    if not save or type(save.Inventory) ~= "table" then return false, "no save" end
    if type(save.FusionSlots) ~= "table" then return false, "no FusionSlots" end

    if save.FusionLocked == true then return false, "machine is fusing" end
    if save.FusionEggReward ~= false and save.FusionEggReward ~= nil then
        local revealNet = GetNetRemote("RF/Fusery/FinishReveal")
        if revealNet then pcall(function() revealNet:InvokeServer() end) end
        return false, "claim reward first"
    end

    local equipped = {}
    for _, uid in ipairs(save.EquippedAssets or {}) do equipped[tostring(uid)] = true end

    local groups = {}
    for uid, data in pairs(save.Inventory) do
        if not equipped[tostring(uid)] then
            local ok, decoded = pcall(AssetItemsMod.Decode, data)
            if ok and decoded and not decoded.IsFavorite and not decoded.InFuse then
                local cat = decoded.Category or ""
                local rarName = select(1, GetEggRarityInfo({ AssetCategory = cat }))
                if FuseMatchesPet(cat, rarName) then
                    groups[cat] = groups[cat] or {}
                    table.insert(groups[cat], tostring(uid))
                end
            end
        end
    end

    local cats = {}
    for c, uids in pairs(groups) do
        if #uids >= 3 then table.insert(cats, c) end
    end
    if #cats == 0 then return false, "no 3 pets of same category" end
    table.sort(cats)
    local chosen = groups[cats[1]]
    table.sort(chosen, function(a, b) return tostring(a) < tostring(b) end)

    local fuseNet   = GetNetRemote("RF/Fusery/BeginFuse")
    local insertNet = GetNetRemote("RF/Fusery/LoadPet")
    local revealNet = GetNetRemote("RF/Fusery/FinishReveal")
    local briefNet  = GetNetRemote("RF/Fusery/ConfirmBriefing")
    if not (fuseNet and insertNet and revealNet) then return false, "fuse remotes missing" end

    local price = tonumber(save.FusionPrice) or 0
    if price > 0 and (tonumber(save.Money) or 0) < price then
        return false, "not enough money for fuse"
    end

    local okAll, err = pcall(function()
        if briefNet then briefNet:InvokeServer() end
        for i = 1, 3 do
            local latest = nil
            pcall(function() latest = SaveModule.Get and SaveModule.Get() end)
            if latest and latest.Inventory and latest.Inventory[chosen[i]] then
                insertNet:InvokeServer(chosen[i])
            end
            task.wait(0.05)
        end
        fuseNet:InvokeServer()
        local t0 = os.clock()
        while os.clock() - t0 < 10 do
            local s = nil
            pcall(function() s = SaveModule.Get and SaveModule.Get() end)
            if not s then break end
            if s.FusionEggReward == true then break end
            if s.FusionLocked ~= true and s.FusionEggReward == false then break end
            task.wait(0.25)
        end
        revealNet:InvokeServer()
    end)
    return okAll, (okAll and "fused" or tostring(err))
end

-- RIFT
Rift = Rift or { autoFarm = false, autoReroll = false, prioritizeSteal = true, banners = {} }

function Rift.GetState()
    local rf = GetNetRemote("RF/Rift/AskState")
    if not rf then return nil end
    local ok, res = pcall(function() return rf:InvokeServer() end)
    if ok and type(res) == "table" then return res end
    return nil
end

function Rift.FindPets(reqs)
    if not SaveModule or not AssetItemsMod then return nil end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    if not save or type(save.Inventory) ~= "table" then return nil end
    local pool = {}
    for uid, data in pairs(save.Inventory) do
        local ok, decoded = pcall(AssetItemsMod.Decode, data)
        if ok and decoded and not decoded.IsFavorite and not decoded.InFuse then
            local cat = tostring(decoded.Category or "")
            pool[cat] = pool[cat] or {}
            table.insert(pool[cat], {
                uid = uid,
                value = tonumber(decoded.EarningRate) or tonumber(decoded.Value) or 0,
                placed = decoded.Placement ~= nil,
            })
        end
    end
    for _, list in pairs(pool) do
        table.sort(list, function(a, b)
            if a.placed ~= b.placed then return not a.placed end
            if a.value ~= b.value then return a.value < b.value end
            return tostring(a.uid) < tostring(b.uid)
        end)
    end
    local uids, used = {}, {}
    for _, req in ipairs(reqs) do
        local reqCat = tostring(type(req) == "table" and (req.Category or req.Name or req) or req):lower()
        local picked = nil
        for _, cand in ipairs(pool[reqCat] or {}) do
            if not used[cand.uid] then picked = cand; break end
        end
        if picked then
            table.insert(uids, picked.uid)
            used[picked.uid] = true
        end
    end
    return uids
end

function Rift.TravelToMachine()
    local obj  = Workspace:FindFirstChild("__OBJECTS")
    local mach = obj and obj:FindFirstChild("Machines") and obj.Machines:FindFirstChild("RiftMachine")
    if not mach then return false end
    local root = findHRP()
    if not root then return false end
    root.CFrame = mach:GetPivot() * CFrame.new(0, 3, 4)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.6)
    return true
end

function Rift.TradeIn(uids)
    local rf = GetNetRemote("RF/Rift/AskTradeIn")
    if not rf then return false end
    local ok, res = pcall(function() return rf:InvokeServer(uids) end)
    return ok and res ~= false and res ~= nil
end

function Rift.RunCycle()
    local state = Rift.GetState()
    if not state then return false, "no state" end
    local reqs = state.Requirements
    if not reqs or #reqs == 0 then return false, "no requirements" end
    local uids = Rift.FindPets(reqs)
    if not uids or #uids < #reqs then
        return false, "missing pets " .. (#uids or 0) .. "/" .. #reqs
    end
    if not Rift.TravelToMachine() then return false, "machine not found" end
    local ok = Rift.TradeIn(uids)
    return ok, ok and "traded!" or "trade failed"
end

task.spawn(function()
    while true do
        if Rift.autoFarm then
            local ok, err = pcall(Rift.RunCycle)
            if not ok then print("[Rift] error: " .. tostring(err)) end
            task.wait(5)
        else
            task.wait(2)
        end
    end
end)

-- UTILITY
function SetFullbright(on)
    if on then
        HUB._savedLighting = HUB._savedLighting or {
            Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
            Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
            FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
        }
        pcall(function()
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        end)
    elseif HUB._savedLighting then
        pcall(function()
            local s = HUB._savedLighting
            Lighting.Brightness = s.Brightness; Lighting.ClockTime = s.ClockTime
            Lighting.Ambient = s.Ambient; Lighting.OutdoorAmbient = s.OutdoorAmbient
            Lighting.FogEnd = s.FogEnd; Lighting.GlobalShadows = s.GlobalShadows
        end)
        HUB._savedLighting = nil
    end
end

-- RENAME NAMETAG → "I'm W424Hub"
local CUSTOM_NAME_TEXT = "I'm W424Hub"
local _renameLoopRunning = false
local _renameAllEnabled  = false

local function isPlayerRoot(adornee)
    if not adornee then return false end
    if not adornee:IsA("BasePart") then return false end
    if adornee.Name ~= "HumanoidRootPart" then return false end
    -- pastikan HRP ini milik player (ada di folder Players)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and adornee:IsDescendantOf(p.Character) then return true end
    end
    return false
end

local function renameOneNametag(bb, on)
    for _, txt in ipairs(bb:GetDescendants()) do
        if txt:IsA("TextLabel") then
            pcall(function()
                if on then
                    if txt:GetAttribute("W424_OrigTxt") == nil then
                        txt:SetAttribute("W424_OrigTxt", txt.Text)
                    end
                    txt.Text = CUSTOM_NAME_TEXT
                else
                    local o = txt:GetAttribute("W424_OrigTxt")
                    if o ~= nil then
                        txt.Text = o
                        txt:SetAttribute("W424_OrigTxt", nil)
                    end
                end
            end)
        end
    end
end

local function applyRenamePass(on)
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if not pg then return end

    -- 1) Humanoid default (backup, kalau game juga pakai)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h then
                pcall(function()
                    if on then
                        if h:GetAttribute("W424_OrigDN") == nil then
                            h:SetAttribute("W424_OrigDN", h.DisplayName)
                        end
                        h.DisplayName = CUSTOM_NAME_TEXT
                        if h.NameDisplayDistance <= 0 then h.NameDisplayDistance = 100 end
                    else
                        local o = h:GetAttribute("W424_OrigDN")
                        if o then h.DisplayName = o; h:SetAttribute("W424_OrigDN", nil) end
                    end
                end)
            end
        end
    end

    -- 2) Custom BillboardGui nametag di PlayerGui
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("BillboardGui") and isPlayerRoot(d.Adornee) then
            renameOneNametag(d, on)
        end
    end
end

local function startRenameLoop()
    if _renameLoopRunning then return end
    _renameLoopRunning = true
    task.spawn(function()
        while _renameLoopRunning do
            if _renameAllEnabled then
                pcall(applyRenamePass, true)
            end
            task.wait(0.5)
        end
    end)
end

function ApplyRenameNametags(on)
    _renameAllEnabled = on
    if on then
        startRenameLoop()
        applyRenamePass(true)
    else
        applyRenamePass(false)
        _renameLoopRunning = false
    end
end

function applyMovementTweaks()
    local h = findHum()
    if not h then return end
    if S.jumpPowerEnabled then
        pcall(function() h.UseJumpPower = true; h.JumpPower = S.jumpPowerValue end)
    end
    if S.infiniteJumpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end

-- FLY (WASD)
local _flyConns = {}
local _flyBV    = nil
function stopFly()
    for _, c in ipairs(_flyConns) do pcall(function() c:Disconnect() end) end
    _flyConns = {}
    if _flyBV then pcall(function() _flyBV:Destroy() end); _flyBV = nil end
    local h = findHum()
    if h then pcall(function() h.PlatformStand = false; h:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
end

function startFly()
    stopFly()
    local hrp = findHRP()
    local h   = findHum()
    if not hrp or not h then return end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "W424Fly"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    _flyBV = bv
    h.PlatformStand = true
    local cam = Workspace.CurrentCamera
    table.insert(_flyConns, RunService.RenderStepped:Connect(function()
        if not S.flyEnabled then stopFly(); return end
        local hrpNow = findHRP()
        if not hrpNow or not _flyBV or not _flyBV.Parent then return end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        local speed = math.clamp(tonumber(S.flySpeed) or 60, 10, 400)
        _flyBV.Velocity = (dir.Magnitude > 0) and (dir.Unit * speed) or Vector3.zero
    end))
end

-- ANTI-TRAP
local _trapCacheAt = 0
function NeutralizeTraps(force)
    if not force and not S.avoidTrapsEnabled then return 0 end
    local now = os.clock()
    if not force and (now - _trapCacheAt) < 1.5 then return 0 end
    _trapCacheAt = now
    local n = 0
    for _, v in ipairs(Workspace:GetChildren()) do
        local ok = pcall(function()
            local nm = v.Name:lower()
            if (v:IsA("BasePart") or v:IsA("Model"))
                and (nm:find("trap") or nm:find("spike") or nm:find("bear trap")) then
                v:Destroy(); n = n + 1
            end
        end)
    end
    return n
end

function ApplyAntiTrap(on)
    if HUB._trapConn then pcall(function() HUB._trapConn:Disconnect() end); HUB._trapConn = nil end
    if not on then return end
    pcall(NeutralizeTraps, true)
    HUB._trapConn = Workspace.DescendantAdded:Connect(function(v)
        if not S.avoidTrapsEnabled then return end
        local nm = v.Name:lower()
        if (v:IsA("BasePart") or v:IsA("Model"))
            and (nm:find("trap") or nm:find("spike")) then
            task.defer(function() pcall(function() v:Destroy() end) end)
        end
    end)
end

-- ============================================================
-- [W424 HUB PERFORMANCE MODULE - Adapted for your source]
-- ============================================================
local setCapFps, uncapFps, getActiveFpsCap, killScaryEffect, applyFpsBoost, restoreFpsBoost, _hide, purgePlayerTraps
do
    local activeFpsCap = nil
    function setCapFps(targetFps)
        local num = tonumber(targetFps)
        if not num then return false end
        num = math.clamp(math.floor(num), 1, 999)
        local setFn = rawget(_G, "setfpscap") or rawget(_G, "set_fps_cap")
            or (type(setfpscap) == "function" and setfpscap)
        if not setFn then return false end
        local ok = pcall(setFn, num)
        if ok then activeFpsCap = num end
        return ok
    end
    function uncapFps() return setCapFps(999) end
    function getActiveFpsCap() return activeFpsCap end

    local _boost = { on = false, conns = {}, old = {} }
    local function purgeCRA()
        if _hide and _hide.setHideAllPets then _hide.setHideAllPets(true) end
    end
    local function purgePlacedEggRenders()
        if _hide and _hide.setHideOtherEggs then _hide.setHideOtherEggs(true) end
    end
    function purgePlayerTraps()
        local debris = Workspace:FindFirstChild("__DEBRIS")
        if not debris then return end
        for _, child in ipairs(debris:GetChildren()) do
            if child.Name == "PlayerTrap" then
                pcall(function() child:Destroy() end)
            end
        end
    end
    _hide = {}

    _hide.petsConns = {}
    _hide.savedPets = {}
    _hide.ownerEggsConns = {}
    _hide.savedOwnerEggs = {}
    _hide.otherEggsConns = {}
    _hide.savedOtherEggs = {}
    _hide.allEggsConns = {}
    _hide.savedAllEggs = {}
    _hide.plotVisualConns = {}
    _hide.savedPlotVisuals = {}
    _hide.moneyConns = {}
    _hide.origMoneyShow = nil

    local function getAllPlacedEggFolders()
        local out = {}
        for _, c in ipairs(Workspace:GetChildren()) do
            if c.Name == "PlacedEggRenders" then table.insert(out, c) end
        end
        return out
    end
    local function getAllCRAFolders()
        local out = {}
        for _, c in ipairs(Workspace:GetChildren()) do
            if c.Name == "ClientRenderedAssets" then table.insert(out, c) end
        end
        return out
    end
    local function isOwnEgg(m)
        local prefix = tostring(LP.UserId) .. "_"
        return tostring(m.Name):sub(1, #prefix) == prefix
    end

    _hide.setHideAllPets = function(on)
        for _, c in ipairs(_hide.petsConns) do pcall(function() c:Disconnect() end) end
        _hide.petsConns = {}
        if not on then
            for inst, saved in pairs(_hide.savedPets) do
                if inst and inst.Parent then
                    pcall(function()
                        if inst:IsA("BasePart") then
                            inst.LocalTransparencyModifier = saved.ltm
                            inst.Transparency = saved.trans
                        elseif inst:IsA("Decal") or inst:IsA("Texture") then
                            inst.Transparency = saved.trans
                        elseif inst:IsA("Highlight") or inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") or inst:IsA("Sparkles") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("BillboardGui") or inst:IsA("SurfaceGui") then
                            inst.Enabled = saved.enabled
                        end
                    end)
                end
            end
            _hide.savedPets = {}
            return
        end
        local function hideInst(d)
            if d:IsA("BasePart") then
                if _hide.savedPets[d] == nil then
                    _hide.savedPets[d] = { ltm = d.LocalTransparencyModifier, trans = d.Transparency }
                end
                d.LocalTransparencyModifier = 1
                d.Transparency = 1
            elseif d:IsA("Decal") or d:IsA("Texture") then
                if _hide.savedPets[d] == nil then
                    _hide.savedPets[d] = { trans = d.Transparency }
                end
                d.Transparency = 1
            elseif d:IsA("Highlight") or d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Sparkles") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                if _hide.savedPets[d] == nil then
                    _hide.savedPets[d] = { enabled = d.Enabled }
                end
                d.Enabled = false
            end
        end
        local function hideFolder(folder)
            if not folder then return end
            for _, d in ipairs(folder:GetDescendants()) do hideInst(d) end
            table.insert(_hide.petsConns, folder.DescendantAdded:Connect(hideInst))
        end
        for _, folder in ipairs(getAllCRAFolders()) do hideFolder(folder) end
        table.insert(_hide.petsConns, Workspace.ChildAdded:Connect(function(c)
            if c.Name == "ClientRenderedAssets" then hideFolder(c) end
        end))
    end

    _hide.setHideOwnerEggs = function(on)
        for _, c in ipairs(_hide.ownerEggsConns) do pcall(function() c:Disconnect() end) end
        _hide.ownerEggsConns = {}
        if not on then
            for inst, saved in pairs(_hide.savedOwnerEggs) do
                if inst and inst.Parent then
                    pcall(function()
                        if inst:IsA("BasePart") then
                            inst.LocalTransparencyModifier = saved.ltm
                            inst.Transparency = saved.trans
                        elseif inst:IsA("Decal") or inst:IsA("Texture") then
                            inst.Transparency = saved.trans
                        elseif inst:IsA("Highlight") or inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("BillboardGui") or inst:IsA("SurfaceGui") then
                            inst.Enabled = saved.enabled
                        end
                    end)
                end
            end
            _hide.savedOwnerEggs = {}
            return
        end
        local function hideEggModel(m)
            if not isOwnEgg(m) then return end
            for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("BasePart") then
                    if _hide.savedOwnerEggs[d] == nil then
                        _hide.savedOwnerEggs[d] = { ltm = d.LocalTransparencyModifier, trans = d.Transparency }
                    end
                    d.LocalTransparencyModifier = 1
                    d.Transparency = 1
                elseif d:IsA("Decal") or d:IsA("Texture") then
                    if _hide.savedOwnerEggs[d] == nil then
                        _hide.savedOwnerEggs[d] = { trans = d.Transparency }
                    end
                    d.Transparency = 1
                elseif d:IsA("Highlight") or d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                    if _hide.savedOwnerEggs[d] == nil then
                        _hide.savedOwnerEggs[d] = { enabled = d.Enabled }
                    end
                    d.Enabled = false
                end
            end
        end
        for _, folder in ipairs(getAllPlacedEggFolders()) do
            for _, m in ipairs(folder:GetChildren()) do hideEggModel(m) end
            table.insert(_hide.ownerEggsConns, folder.ChildAdded:Connect(hideEggModel))
        end
        table.insert(_hide.ownerEggsConns, Workspace.ChildAdded:Connect(function(c)
            if c.Name == "PlacedEggRenders" then
                for _, m in ipairs(c:GetChildren()) do hideEggModel(m) end
                table.insert(_hide.ownerEggsConns, c.ChildAdded:Connect(hideEggModel))
            end
        end))
    end

    _hide.setHideOtherEggs = function(on)
        for _, c in ipairs(_hide.otherEggsConns) do pcall(function() c:Disconnect() end) end
        _hide.otherEggsConns = {}
        if not on then
            for inst, saved in pairs(_hide.savedOtherEggs) do
                if inst and inst.Parent then
                    pcall(function()
                        if inst:IsA("BasePart") then
                            inst.LocalTransparencyModifier = saved.ltm
                            inst.Transparency = saved.trans
                        elseif inst:IsA("Decal") or inst:IsA("Texture") then
                            inst.Transparency = saved.trans
                        elseif inst:IsA("Highlight") or inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("BillboardGui") or inst:IsA("SurfaceGui") then
                            inst.Enabled = saved.enabled
                        end
                    end)
                end
            end
            _hide.savedOtherEggs = {}
            return
        end
        local function hideOtherEggModel(m)
            if isOwnEgg(m) then return end
            for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("BasePart") then
                    if _hide.savedOtherEggs[d] == nil then
                        _hide.savedOtherEggs[d] = { ltm = d.LocalTransparencyModifier, trans = d.Transparency }
                    end
                    d.LocalTransparencyModifier = 1
                    d.Transparency = 1
                elseif d:IsA("Decal") or d:IsA("Texture") then
                    if _hide.savedOtherEggs[d] == nil then
                        _hide.savedOtherEggs[d] = { trans = d.Transparency }
                    end
                    d.Transparency = 1
                elseif d:IsA("Highlight") or d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                    if _hide.savedOtherEggs[d] == nil then
                        _hide.savedOtherEggs[d] = { enabled = d.Enabled }
                    end
                    d.Enabled = false
                end
            end
        end
        for _, folder in ipairs(getAllPlacedEggFolders()) do
            for _, m in ipairs(folder:GetChildren()) do hideOtherEggModel(m) end
            table.insert(_hide.otherEggsConns, folder.ChildAdded:Connect(hideOtherEggModel))
        end
        table.insert(_hide.otherEggsConns, Workspace.ChildAdded:Connect(function(c)
            if c.Name == "PlacedEggRenders" then
                for _, m in ipairs(c:GetChildren()) do hideOtherEggModel(m) end
                table.insert(_hide.otherEggsConns, c.ChildAdded:Connect(hideOtherEggModel))
            end
        end))
    end

    _hide.setHideAllEggs = function(on)
        for _, c in ipairs(_hide.allEggsConns) do pcall(function() c:Disconnect() end) end
        _hide.allEggsConns = {}
        if not on then
            for inst, saved in pairs(_hide.savedAllEggs) do
                if inst and inst.Parent then
                    pcall(function()
                        if inst:IsA("BasePart") then
                            inst.LocalTransparencyModifier = saved.ltm
                            inst.Transparency = saved.trans
                        elseif inst:IsA("Decal") or inst:IsA("Texture") then
                            inst.Transparency = saved.trans
                        elseif inst:IsA("Highlight") or inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("BillboardGui") or inst:IsA("SurfaceGui") then
                            inst.Enabled = saved.enabled
                        end
                    end)
                end
            end
            _hide.savedAllEggs = {}
            return
        end
        local function hideAnyEggModel(m)
            for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("BasePart") then
                    if _hide.savedAllEggs[d] == nil then
                        _hide.savedAllEggs[d] = { ltm = d.LocalTransparencyModifier, trans = d.Transparency }
                    end
                    d.LocalTransparencyModifier = 1
                    d.Transparency = 1
                elseif d:IsA("Decal") or d:IsA("Texture") then
                    if _hide.savedAllEggs[d] == nil then
                        _hide.savedAllEggs[d] = { trans = d.Transparency }
                    end
                    d.Transparency = 1
                elseif d:IsA("Highlight") or d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                    if _hide.savedAllEggs[d] == nil then
                        _hide.savedAllEggs[d] = { enabled = d.Enabled }
                    end
                    d.Enabled = false
                end
            end
        end
        for _, folder in ipairs(getAllPlacedEggFolders()) do
            for _, m in ipairs(folder:GetChildren()) do hideAnyEggModel(m) end
            table.insert(_hide.allEggsConns, folder.ChildAdded:Connect(hideAnyEggModel))
        end
        table.insert(_hide.allEggsConns, Workspace.ChildAdded:Connect(function(c)
            if c.Name == "PlacedEggRenders" then
                for _, m in ipairs(c:GetChildren()) do hideAnyEggModel(m) end
                table.insert(_hide.allEggsConns, c.ChildAdded:Connect(hideAnyEggModel))
            end
        end))
    end

    _hide.setHidePlotVisuals = function(on)
        for _, c in ipairs(_hide.plotVisualConns) do pcall(function() c:Disconnect() end) end
        _hide.plotVisualConns = {}
        if not on then
            for inst, saved in pairs(_hide.savedPlotVisuals) do
                if inst and inst.Parent then
                    pcall(function()
                        if inst:IsA("BasePart") then
                            inst.LocalTransparencyModifier = saved.ltm
                            inst.Transparency = saved.trans
                        elseif inst:IsA("Decal") or inst:IsA("Texture") then
                            inst.Transparency = saved.trans
                        elseif inst:IsA("SurfaceGui") or inst:IsA("BillboardGui") or inst:IsA("Highlight") or inst:IsA("ParticleEmitter") then
                            inst.Enabled = saved.enabled
                        end
                    end)
                end
            end
            _hide.savedPlotVisuals = {}
            return
        end
        local function hidePlotDescendant(d)
            if d:IsA("BasePart") then
                if d.Parent and d.Parent.Name == "COLLISIONS" then return end
                if _hide.savedPlotVisuals[d] == nil then
                    _hide.savedPlotVisuals[d] = { ltm = d.LocalTransparencyModifier, trans = d.Transparency }
                end
                d.LocalTransparencyModifier = 1
                d.Transparency = 1
            elseif d:IsA("Decal") or d:IsA("Texture") then
                if _hide.savedPlotVisuals[d] == nil then
                    _hide.savedPlotVisuals[d] = { trans = d.Transparency }
                end
                d.Transparency = 1
            elseif d:IsA("SurfaceGui") or d:IsA("BillboardGui") or d:IsA("Highlight") or d:IsA("ParticleEmitter") then
                if _hide.savedPlotVisuals[d] == nil then
                    _hide.savedPlotVisuals[d] = { enabled = d.Enabled }
                end
                d.Enabled = false
            end
        end
        local targets = {}
        local plots = Workspace:FindFirstChild("Plots")
        if plots then table.insert(targets, plots) end
        local obj = Workspace:FindFirstChild("__OBJECTS")
        local build = obj and obj:FindFirstChild("Build")
        if build then
            for _, child in ipairs(build:GetChildren()) do
                if tonumber(child.Name) then table.insert(targets, child) end
            end
        end
        local stands = Workspace:FindFirstChild("Stands")
        if stands then table.insert(targets, stands) end
        for _, target in ipairs(targets) do
            for _, d in ipairs(target:GetDescendants()) do hidePlotDescendant(d) end
            table.insert(_hide.plotVisualConns, target.DescendantAdded:Connect(hidePlotDescendant))
        end
    end

    _hide.setHideMoneyFX = function(on)
        for _, c in ipairs(_hide.moneyConns) do pcall(function() c:Disconnect() end) end
        _hide.moneyConns = {}
        local ps = LP:FindFirstChild("PlayerScripts")
        local mod = ps and ps:FindFirstChild("GUI") and ps.GUI:FindFirstChild("ActiveAssetIncomePopup")
        if mod then
            local ok, popupModule = pcall(require, mod)
            if ok and type(popupModule) == "table" and type(popupModule.Show) == "function" then
                if not _hide.origMoneyShow then _hide.origMoneyShow = popupModule.Show end
                if on then
                    popupModule.Show = function(...)
                        if S.hideMoneyFX then return end
                        return _hide.origMoneyShow(...)
                    end
                else
                    popupModule.Show = _hide.origMoneyShow
                end
            end
        end
        if not on then return end
        local function dropMoney(d)
            if d.Name:find("Income") or d.Name:find("SyncedIncomeCash") or d.Name:find("Cash") then
                pcall(function() d:Destroy() end)
            end
        end
        local terrain = Workspace:FindFirstChildOfClass("Terrain") or Workspace:FindFirstChild("Terrain")
        if terrain then
            for _, d in ipairs(terrain:GetChildren()) do dropMoney(d) end
            table.insert(_hide.moneyConns, terrain.ChildAdded:Connect(dropMoney))
            table.insert(_hide.moneyConns, terrain.DescendantAdded:Connect(dropMoney))
        end
        table.insert(_hide.moneyConns, Workspace.ChildAdded:Connect(dropMoney))
    end

    _hide.purgeAllVisualsNow = function()
        S.hideAllPets = true
        S.hideOwnerEggs = true
        S.hideOtherEggs = true
        S.hideAllEggs = true
        S.hidePlotVisuals = true
        S.hideMoneyFX = true
        _hide.setHideAllPets(true)
        _hide.setHideOwnerEggs(true)
        _hide.setHideOtherEggs(true)
        _hide.setHideAllEggs(true)
        _hide.setHidePlotVisuals(true)
        _hide.setHideMoneyFX(true)
    end

    function killScaryEffect()
        pcall(function()
            local client = ReplicatedStorage:FindFirstChild("Client")
            local mod = client and client:FindFirstChild("ScaryEffectController")
            if mod then local sec = require(mod) if sec and sec.Stop then sec:Stop() end end
        end)
        local pg = LP and LP:FindFirstChild("PlayerGui")
        if pg then
            local v = pg:FindFirstChild("Vignette")
            if v then pcall(function() v:Destroy() end) end
        end
    end

    local function boostEffectStream()
        local function disableEffect(v)
            pcall(function()
                if v:IsA("Sound") then
                    v.PlayOnRemove = false
                    v:Stop()
                else
                    v.Enabled = false
                end
            end)
        end
        local c1 = Workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
                disableEffect(v)
            end
        end)
        local c2 = Workspace.ChildAdded:Connect(function(v)
            if v.Name == "ClientRenderedAssets" then purgeCRA()
            elseif v.Name == "PlacedEggRenders" then purgePlacedEggRenders() end
        end)
        local c3, c6
        local c4
        local rbe = LP and LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("RunBackEffects")
        if rbe then
            pcall(function() rbe.Enabled = false end)
            c4 = rbe.Changed:Connect(function(p)
                if p == "Enabled" and rbe.Enabled ~= false then pcall(function() rbe.Enabled = false end) end
            end)
        end
        local c5
        local pg = LP and LP:FindFirstChild("PlayerGui")
        if pg then
            c5 = pg.ChildAdded:Connect(function(v)
                if v.Name == "Vignette" then pcall(function() v:Destroy() end) end
            end)
        end
        _boost.conns = { c1, c2, c3, c4, c5, c6 }
    end

    function applyFpsBoost()
        _boost.on = true
        setCapFps(120)
        pcall(function()
            Lighting.Technology = Enum.Technology.Compatibility
            Lighting.GlobalShadows = false
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        end)
        pcall(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    pcall(function() v.Material = Enum.Material.SmoothPlastic end)
                    pcall(function() v.Color = Color3.fromRGB(120, 120, 120) end)
                    pcall(function() v.CastShadow = false end)
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    pcall(function() v.Texture = "" end)
                elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    pcall(function() v.Enabled = false end)
                elseif v:IsA("Trail") or v:IsA("Beam") then
                    pcall(function() v.Enabled = false end)
                elseif v:IsA("Sound") then
                    pcall(function() v.PlayOnRemove = false; v:Stop() end)
                end
            end
        end)
        pcall(function()
            local pg = LP and LP:FindFirstChild("PlayerGui")
            if pg then
                local OURS = {
                    W424UI = true, W424Toggle = true,
                    __W424_Panel_logs = true, __W424_Panel_eggs = true, __W424_Panel_inventory = true,
                }
                for _, g in ipairs(pg:GetChildren()) do
                    if not OURS[g.Name] then
                        for _, v in ipairs(g:GetDescendants()) do
                            if v:IsA("GuiObject") then
                                pcall(function() v.BackgroundTransparency = 1 end)
                                pcall(function() v.BorderSizePixel = 0 end)
                            end
                            if v:IsA("ImageLabel") or v:IsA("ImageButton") then
                                pcall(function() v.Image = "" end)
                            end
                        end
                    end
                end
            end
        end)
        purgeCRA()
        purgePlacedEggRenders()
        killScaryEffect()
        boostEffectStream()
    end

    function restoreFpsBoost()
        if not _boost.on then return end
        _boost.on = false
        for _, c in ipairs(_boost.conns) do if c then pcall(function() c:Disconnect() end) end end
        _boost.conns = {}
        if _hide and _hide.setHideAllPets then _hide.setHideAllPets(S.hideAllPets or false) end
        if _hide and _hide.setHideOtherEggs then _hide.setHideOtherEggs(S.hideOtherEggs or false) end
        pcall(function()
            local rbe = LP and LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("RunBackEffects")
            if rbe then rbe.Enabled = true end
        end)
    end
end

_G.__W424_FPS = { apply = applyFpsBoost, restore = restoreFpsBoost }

-- ============================================================
-- FAKE AVATAR V2 — COPY AVA (Integrated in Player Tab)
-- ============================================================
local CopyAva = {
    CurrentAvatar = nil,
    OriginalId    = LP.UserId,
    RespawnConn   = nil,
    Applying      = false,
    SelectedFav   = nil,
    Favorites     = {},
    UsernameInput = "",
}

local COPYAVA_RANDOM_IDS = {978663613, 5261700291, 1846241644, 4993456331, 424866237, 4312175249}
local COPYAVA_FAV_FILE   = "W424_SAE_Config/copyava_favorites.json"

-- ============ FAVORITES STORAGE ============
local function LoadCopyAvaFavorites()
    CopyAva.Favorites = {}
    pcall(function()
        if not isfolder("W424_SAE_Config") then makefolder("W424_SAE_Config") end
        if isfile(COPYAVA_FAV_FILE) then
            local raw = readfile(COPYAVA_FAV_FILE)
            local data = game:GetService("HttpService"):JSONDecode(raw)
            if type(data) == "table" then CopyAva.Favorites = data end
        end
    end)
end

local function SaveCopyAvaFavorites()
    pcall(function()
        if not isfolder("W424_SAE_Config") then makefolder("W424_SAE_Config") end
        writefile(COPYAVA_FAV_FILE, game:GetService("HttpService"):JSONEncode(CopyAva.Favorites))
    end)
end
LoadCopyAvaFavorites()

-- ============ RESOLVE USERNAME / ID ============
local function ResolveUser(input)
    if input == nil then return nil, nil end
    local txt = tostring(input):gsub("%s+", ""):gsub("^@", "")
    if txt == "" then return nil, nil end

    local id = tonumber(txt)
    if id then
        local ok, name = pcall(function() return Players:GetNameFromUserIdAsync(id) end)
        if ok and name then return id, name end
    else
        local ok, uid = pcall(function() return Players:GetUserIdFromNameAsync(txt) end)
        if ok and uid then
            local ok2, name = pcall(function() return Players:GetNameFromUserIdAsync(uid) end)
            if ok2 and name then return uid, name end
        end
    end
    return nil, nil
end

-- ============ LOAD ASSET KE KARAKTER ============
local function LoadAssetKeKarakter(appearance, character, head)
    if not appearance or not character then return end
    local meshItems = {}
    local bodyColors, shirt, pants, shirtGraphic = nil, nil, nil, nil
    local accessories = {}

    local function collectItems(parent)
        if not parent then return end
        for _, item in pairs(parent:GetChildren()) do
            if item:IsA("CharacterMesh") then
                table.insert(meshItems, item)
            elseif item:IsA("BodyColors") then
                bodyColors = item
            elseif item:IsA("Shirt") then
                shirt = item
            elseif item:IsA("Pants") then
                pants = item
            elseif item:IsA("ShirtGraphic") then
                shirtGraphic = item
            elseif item:IsA("Accessory") then
                table.insert(accessories, item)
            elseif item:IsA("SpecialMesh") then
                table.insert(meshItems, item)
            elseif item:IsA("Decal") and item.Name == "face" then
                table.insert(meshItems, item)
            elseif item:IsA("Folder") or item:IsA("Model") then
                collectItems(item)
            end
        end
    end

    collectItems(appearance)

    if bodyColors and character then
        local existing = character:FindFirstChildOfClass("BodyColors")
            or character:FindFirstChild("Body Colors")
        if existing then existing:Destroy() end
        bodyColors:Clone().Parent = character
    end

    if shirt and character then
        local existing = character:FindFirstChildOfClass("Shirt")
        if existing then existing:Destroy() end
        shirt:Clone().Parent = character
    end

    if pants and character then
        local existing = character:FindFirstChildOfClass("Pants")
        if existing then existing:Destroy() end
        pants:Clone().Parent = character
    end

    if shirtGraphic and character then
        local existing = character:FindFirstChildOfClass("ShirtGraphic")
        if existing then existing:Destroy() end
        shirtGraphic:Clone().Parent = character
    end

    for _, mesh in pairs(meshItems) do
        if mesh and mesh:IsA("CharacterMesh") then
            pcall(function() mesh:Clone().Parent = character end)
        end
    end

    if head then
        for _, mesh in pairs(meshItems) do
            if mesh and mesh:IsA("SpecialMesh") then
                pcall(function()
                    local headMesh = head:FindFirstChildOfClass("SpecialMesh")
                    if headMesh then headMesh:Destroy() end
                    mesh:Clone().Parent = head
                end)
            elseif mesh and mesh:IsA("Decal") and mesh.Name == "face" then
                pcall(function()
                    local existingFace = head:FindFirstChild("face")
                    if existingFace then existingFace:Destroy() end
                    mesh:Clone().Parent = head
                end)
            end
        end
    end

    if #accessories > 0 then
        task.spawn(function()
            for _, accessory in pairs(accessories) do
                pcall(function()
                    local clone = accessory:Clone()
                    local handle = clone:FindFirstChild("Handle")
                    if handle then
                        handle.CanCollide = false
                        handle.Massless = true
                        local att = handle:FindFirstChildOfClass("Attachment")
                        if att then
                            local targetAtt = character:FindFirstChild(att.Name, true)
                            if targetAtt and targetAtt.Parent then
                                local weld = Instance.new("Weld")
                                weld.Part0 = handle
                                weld.Part1 = targetAtt.Parent
                                weld.C0 = att.CFrame
                                weld.C1 = targetAtt.CFrame
                                weld.Parent = handle
                            end
                        end
                        clone.Parent = character
                    else
                        clone.Parent = character
                    end
                end)
            end
        end)
    end
end

-- ============ APPLY APPEARANCE ============
local function ApplyFakeAvaAppearance(userId)
    if not userId then return false end
    local character = LP.Character
    if not character then return false end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local success, appearance = pcall(function()
        return Players:GetCharacterAppearanceAsync(userId)
    end)
    if not success or not appearance then
        Notify("CopyAva", "Gagal load appearance", 3)
        return false
    end

    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants")
            or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors")
            or obj:IsA("CharacterMesh") or obj.Name == "Body Colors" then
            obj:Destroy()
        end
    end

    local head = character:FindFirstChild("Head")
    if head then
        local headMesh = head:FindFirstChildOfClass("SpecialMesh")
        if headMesh then headMesh:Destroy() end
        local faceMesh = head:FindFirstChild("face")
        if faceMesh then faceMesh:Destroy() end
    end

    local appearanceInfo = nil
    local ok, info = pcall(function()
        return Players:GetCharacterAppearanceInfoAsync(userId)
    end)
    if ok and info then appearanceInfo = info end

    if appearanceInfo and appearanceInfo.scales then
        for scaleName, val in pairs(appearanceInfo.scales) do
            local s = humanoid:FindFirstChild(scaleName)
            if not s then
                s = Instance.new("NumberValue")
                s.Name = scaleName
                s.Parent = humanoid
            end
            s.Value = val
        end
    end

    task.wait(0.2)
    LoadAssetKeKarakter(appearance, character, head)

    if appearanceInfo and appearanceInfo.assets and head then
        task.spawn(function()
            for _, asset in pairs(appearanceInfo.assets) do
                if asset.assetType and asset.assetType.name == "Face" then
                    local existingFace = head:FindFirstChild("face")
                    if existingFace then existingFace:Destroy() end
                    pcall(function()
                        local f = Instance.new("Decal")
                        f.Name = "face"
                        f.Texture = "rbxassetid://" .. asset.id
                        f.Face = Enum.NormalId.Front
                        f.Parent = head
                    end)
                    break
                end
            end
        end)
    end

    pcall(function() appearance:Destroy() end)
    return true
end

-- ============ APPLY AVATAR + RESPAWN HOOK ============
local function ApplyAvatar(useridOrName)
    if CopyAva.Applying then return end
    CopyAva.Applying = true

    task.spawn(function()
        local id, name = ResolveUser(useridOrName)
        if not id then
            Notify("CopyAva", "User tidak ditemukan", 3)
            CopyAva.Applying = false
            return
        end

        CopyAva.CurrentAvatar = { id = id, name = name }

        if CopyAva.RespawnConn then
            CopyAva.RespawnConn:Disconnect()
            CopyAva.RespawnConn = nil
        end

        local ok = false
        if LP.Character then
            ok = ApplyFakeAvaAppearance(id)
        end

        CopyAva.RespawnConn = LP.CharacterAdded:Connect(function()
            task.wait(1)
            if CopyAva.CurrentAvatar then
                ApplyFakeAvaAppearance(CopyAva.CurrentAvatar.id)
            end
        end)

        Notify("CopyAva", ok and ("Berhasil copy: " .. name) or ("Gagal apply: " .. name), 3)
        CopyAva.Applying = false
    end)
end

-- ============ OPTIONS BUILDER ============
local function GetCopyAvaOnlinePlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list, p.Name) end
    end
    return list
end

local function GetCopyAvaFavOptions()
    local list = {}
    for _, fav in ipairs(CopyAva.Favorites) do
        table.insert(list, tostring(fav.name or "?") .. " (" .. tostring(fav.id) .. ")")
    end
    return list
end

-- Additional worker loops
task.spawn(function()
    while true do
        task.wait(2.5)
        if S.autoHatchEnabled then pcall(HatchAllReadyEggs) end
        if S.autoPlantEnabled then pcall(PlantAllCarriedEggsInPen) end
        if S.autoUpgradeBase then pcall(UpgradeHomesteadBase) end
        if S.autoUpgradeTreadmill then pcall(UpgradeTreadmillTier) end
        if S.autoEquipBestPets then pcall(EquipBestPets) end
        if S.autoClaimRewards then pcall(ClaimAllAvailableRewards) end
        if S.autoSellPets then pcall(SellSelectedPets) end
        if S.autoSellEggs then pcall(SellSelectedEggs) end
        if S.autoFavoritePets then pcall(AutoFavoritePets) end
        if S.autoFusePets then pcall(AutoFusePets) end
    end
end)

-- Movement tweaks loop
track(RunService.Heartbeat:Connect(function()
    if HUB.dead then return end
    if S.walkSpeedEnabled then
        local h = findHum()
        if h then pcall(function() h.WalkSpeed = math.clamp(S.walkSpeedVal or 24, 16, 500) end) end
    end
    if S.jumpPowerEnabled or S.infiniteJumpEnabled then
        pcall(applyMovementTweaks)
    end
end))

-- Bat Aura loop
task.spawn(function()
    local batRe = GetNetRemote("RE/BatSwing/Trigger")
    while true do
        task.wait(S.batAuraDelay)
        if S.batAuraEnabled and batRe then
            local hrp = findHRP()
            if hrp then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if oHrp and (oHrp.Position - hrp.Position).Magnitude <= S.batAuraRadius then
                            pcall(function() batRe:FireServer() end)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- BOSS ARENA (Abyss Overlord)
local Boss = { autoJoin = false, autoFight = false, hazardImmune = false,
    arenaReady = false, claimed = {}, _dataTried = false,
    arenaApproach = "Crystals First", glideSpeed = 260,
    engageDistance = 7, swingInterval = 0.15,
    _target = nil, _targetPart = nil, _targetAt = 0,
    _stepAt = 0, _swingAt = 0, _batAt = 0,
    Data = nil, MasteryData = nil,
    MilestoneFallback = {"Mastery3","Mastery5","Mastery10","Mastery15","Mastery20","Mastery30"},
    _hazardRemotes = {}, hazardHook = false, hazardHookTried = false,
}

function Boss.EnsureData()
    if Boss._dataTried then return end
    Boss._dataTried = true
    pcall(function() Boss.Data = require(RS.Data.BossEvent) end)
    pcall(function() Boss.MasteryData = require(RS.Data.BossMastery) end)
    pcall(function()
        local hazard = GetNetRemote("RE/BossEvent/HazardHit")
        local blackHole = GetNetRemote("RE/BossEvent/BlackHoleHit")
        for _, remote in ipairs({ hazard, blackHole }) do
            if type(remote) == "userdata" and remote:IsA("RemoteEvent") then
                Boss._hazardRemotes[remote] = true
            end
        end
    end)
end

function Boss.IsInArena()
    return LP:GetAttribute("InBossArena") == true
end

function Boss.SecondsUntilOpen()
    Boss.EnsureData()
    if Boss.Data and type(Boss.Data.SecondsUntilNextOpen) == "function" then
        local ok, secs = pcall(function() return Boss.Data.SecondsUntilNextOpen() end)
        if ok and tonumber(secs) then return tonumber(secs) end
    end
    return nil
end

function Boss.InstallHazardHook()
    if Boss.hazardHook then return true end
    if Boss.hazardHookTried then return false end
    Boss.hazardHookTried = true

    local touchOnly = false
    pcall(function()
        touchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end)
    if touchOnly then
        Notify("Boss Hazards", "Hazard immunity is not supported on mobile", 4)
        return false
    end

    local HookFn = hookfunction or replaceclosure or hookfunc
    if not HookFn then return false end
    local hazard = GetNetRemote("RE/BossEvent/HazardHit")
    if type(hazard) ~= "userdata" or not hazard:IsA("RemoteEvent") then return false end
    local oldFire = hazard.FireServer
    if type(oldFire) ~= "function" then return false end

    local ok = pcall(function()
        HookFn(oldFire, function(self, ...)
            if Boss.hazardImmune and Boss._hazardRemotes[self] then
                return
            end
            return oldFire(self, ...)
        end)
    end)
    Boss.hazardHook = ok
    return ok
end

function Boss.Snapshot()
    local rf = GetNetRemote("RF/BossEvent/AskSnapshot")
    if not rf then return nil end
    local ok, res = pcall(function() return rf:InvokeServer() end)
    if ok and type(res) == "table" then return res end
    return nil
end

function Boss.IsOpen()
    Boss.EnsureData()
    local snap = Boss.Snapshot()
    if snap then
        if snap.Open ~= nil then return snap.Open == true end
        if snap.BossHealth and snap.BossMaxHealth then
            return (tonumber(snap.BossHealth) or 0) > 0
        end
    end
    if Boss.Data and type(Boss.Data.SecondsUntilNextOpen) == "function" then
        local ok, secs = pcall(function() return Boss.Data.SecondsUntilNextOpen() end)
        if ok and tonumber(secs) then return tonumber(secs) <= 0 end
    end
    return false
end

function Boss.Join()
    local rf = GetNetRemote("RF/BossEvent/AskEnter")
    if not rf then return false end
    local ok, res = pcall(function() return rf:InvokeServer() end)
    return ok and res ~= false and res ~= nil
end

function Boss.ClaimMastery()
    Boss.EnsureData()
    local rf = GetNetRemote("RF/BossMastery/AskClaimMilestone")
    if not rf then return 0 end
    local ids = {}
    if Boss.MasteryData and type(Boss.MasteryData.Milestones) == "table" then
        for _, m in pairs(Boss.MasteryData.Milestones) do
            if type(m) == "table" and type(m.Id) == "string" and not Boss.claimed[m.Id] then
                table.insert(ids, m.Id)
            end
        end
    end
    if #ids == 0 then
        for _, id in ipairs(Boss.MilestoneFallback) do
            if not Boss.claimed[id] then table.insert(ids, id) end
        end
    end
    local claimed = 0
    for _, id in ipairs(ids) do
        local ok2, res = pcall(function() return rf:InvokeServer(id) end)
        if ok2 and res ~= false and res ~= nil then
            Boss.claimed[id] = true
            claimed = claimed + 1
        end
    end
    return claimed
end

function Boss.FindBat()
    local char = LP.Character
    if not char then return nil end
    local held = char:FindFirstChildWhichIsA("Tool")
    if held and held:GetAttribute("IsBat") == true then return held end
    local bag = LP:FindFirstChild("Backpack")
    if bag then
        for _, c in ipairs(bag:GetChildren()) do
            if c:IsA("Tool") and c:GetAttribute("IsBat") == true then
                c.Parent = char; return c
            end
        end
    end
    local wear = GetNetRemote("RF/Codex/AskWearFieldBat")
    if wear then pcall(function() wear:InvokeServer() end) end
    task.wait(0.25)
    if bag then
        for _, c in ipairs(bag:GetChildren()) do
            if c:IsA("Tool") and c:GetAttribute("IsBat") == true then
                c.Parent = char; return c
            end
        end
    end
    return nil
end

function Boss.FindTarget()
    local arena = Workspace:FindFirstChild("BossArena")
    if not arena then return nil end
    local root = findHRP()
    if not root then return nil end
    local best, bestDist = nil, math.huge
    local towers = arena:FindFirstChild("CrystalTowers")
    if towers then
        for _, tower in ipairs(towers:GetChildren()) do
            local hb = tower:FindFirstChild("Hitbox", true)
            if hb and hb:IsA("BasePart") then
                local hp = tonumber(hb:GetAttribute("Health"))
                if hp == nil or hp > 0 then
                    local d = (root.Position - hb.Position).Magnitude
                    if d < bestDist then best, bestDist = hb, d end
                end
            end
        end
    end
    if best and Boss.arenaApproach == "Crystals First" then
        return best, "Crystal"
    end

    local boss = arena:FindFirstChild("Boss")
    if boss then
        local aim = boss:FindFirstChild("UpperHand1.R", true) or boss.PrimaryPart
        if aim and aim:IsA("BasePart") then
            local d = (root.Position - aim.Position).Magnitude
            if d < bestDist then best, bestDist = aim, d end
        end
    end

    return best, (best and best:IsDescendantOf(towers or arena) and "Boss" or nil)
end

function Boss.CurrentTarget()
    local now = os.clock()
    local held = Boss._targetPart
    if held and held.Parent and (now - (Boss._targetAt or 0)) < 0.35 then
        local hp = tonumber(held:GetAttribute("Health"))
        if hp == nil or hp > 0 then return held, Boss._target end
    end
    local part, kind = Boss.FindTarget()
    Boss._targetPart, Boss._target, Boss._targetAt = part, kind, now
    return part, kind
end

function Boss.GlideStep(target)
    local root = findHRP()
    if not root or not target then return false end
    local offset = root.Position - target.Position
    offset = Vector3.new(offset.X, 0, offset.Z)
    if offset.Magnitude < 0.5 then offset = Vector3.new(0, 0, 1) end
    local destination = target.Position + offset.Unit * 5
    local toGo = destination - root.Position
    local remain = toGo.Magnitude
    if remain < 1.0 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    local now = os.clock()
    local dt = math.clamp(now - (Boss._stepAt or now), 0.001, 0.1)
    Boss._stepAt = now
    local speed = math.clamp(tonumber(Boss.glideSpeed) or 260, 60, 500)
    local dir = toGo.Unit
    local step = math.min(speed * dt, remain)
    local nextPos = root.Position + dir * step
    local face = Vector3.new(dir.X, 0, dir.Z)
    if face.Magnitude < 0.01 then face = root.CFrame.LookVector end
    root.CFrame = CFrame.lookAt(nextPos, nextPos + face.Unit)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return false
end

function Boss.EnsureBat()
    local char = LP.Character
    if not char then return nil end
    local held = char:FindFirstChildWhichIsA("Tool")
    if held and held:GetAttribute("IsBat") == true then return held end
    local now = os.clock()
    if now - (Boss._batAt or 0) < 1.5 then return nil end
    Boss._batAt = now
    return Boss.FindBat()
end

function Boss.Fight()
    if not Boss.IsInArena() then return false end
    local root = findHRP()
    if not root then return false end
    local target, kind = Boss.CurrentTarget()
    if not target then return false end
    local dist = (root.Position - target.Position).Magnitude
    if dist > Boss.engageDistance then
        Boss.GlideStep(target)
        Boss._target = kind
        return true
    end
    local now = os.clock()
    if now - (Boss._swingAt or 0) < Boss.swingInterval then return true end
    Boss._swingAt = now
    local bat = Boss.EnsureBat()
    if bat then pcall(function() bat:Activate() end) end
    local swing = GetNetRemote("RE/BatSwing/Trigger")
    if swing then pcall(function() swing:FireServer() end) end
    return true
end

task.spawn(function()
    while true do
        if Boss.autoJoin or Boss.autoFight then
            if Boss.IsInArena() then
                if Boss.autoFight then pcall(Boss.Fight) end
                RunService.Heartbeat:Wait()
            else
                local ok, open = pcall(Boss.IsOpen)
                Boss.arenaReady = (ok and open == true)
                if Boss.arenaReady and Boss.autoJoin then pcall(Boss.Join) end
                task.wait(2)
            end
        else
            task.wait(1)
        end
    end
end)

--  EGG SCANNER MODULE
local EggScannerRef = nil

function InitEggScanner()
    local Players           = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService  = game:GetService("UserInputService")
    local LP                = Players.LocalPlayer

    local CONFIG = {
        LogoId    = "rbxassetid://109462748520607",
        Title     = "W424 // EGG SCANNER",
        ToggleKey = Enum.KeyCode.RightShift,
        NotifyNewEgg = true,
    }

    function tryRequire(...)
        for _, path in ipairs({...}) do
            local ok, result = pcall(function()
                local cur = ReplicatedStorage
                for seg in string.gmatch(path, "[^.]+") do
                    cur = cur:FindFirstChild(seg)
                    if not cur then return nil end
                end
                return require(cur)
            end)
            if ok and result then return result end
        end
        return nil
    end

    local EggState = tryRequire("Client.EggState", "Shared.EggState")
    local EggToolDisplay = tryRequire("Shared.Eggs.EggToolDisplay", "Client.Eggs.EggToolDisplay")
    local AssetsData = tryRequire("Data.Assets", "Shared.Assets", "Assets")
    local AssetDirectory = AssetsData and (AssetsData.Directory or AssetsData) or nil
    local SaveModule = tryRequire("Shared.Save", "Client.Save")
    local AssetItemsMod = tryRequire("Shared.Util.AssetItems", "Util.AssetItems")

    if not EggState then warn("[EggScanner] EggState tidak ditemukan!"); return end

    local RARITY_SCORE_MAP = {
        ["Light & Dark"]=2200, Exclusive=2100, Admin=2100,
        Mythical=2000, ["Squishy God"]=2000, BrainrotGod=2000, Brainrot=1900,
        Eternal=1800, Rainbow=1700, Prismatic=1600, Transcendent=1500,
        Celestial=1400, Cosmic=1300, Titan=1200, Superior=1200,
        Secret=1100, Divine=1000, Limited=900, Exotic=800, SuperRare=700,
        Mythic=600, Legendary=500, Epic=400, Rare=300, Uncommon=200, Common=100,
    }

    local _assetCache = {}
    function getAssetData(record)
        if not record then return {} end
        local item = type(record.ItemData) == "table" and record.ItemData or record
        local cat = item.AssetCategory or item.Category or record.AssetCategory or record.Category
        if AssetDirectory and cat then
            local cached = _assetCache[cat]; if cached then return cached end
            local ok, d = pcall(function() return AssetDirectory[cat] or {} end)
            if ok and d and next(d) then _assetCache[cat] = d; return d end
        end
        return { DisplayName = cat, Rarity = record.Rarity, _id = cat }
    end

    function normalizeRarityName(name)
        if not name then return nil end
        local s = tostring(name)
        if RARITY_SCORE_MAP[s] then return s end
        local key = s:lower():gsub("[^%a%d]", "")
        local map = {
            lightdark="Light & Dark", mythical="Mythical", brainrotgod="BrainrotGod",
            brainrot="Brainrot", squishygod="Squishy God", superrare="SuperRare",
        }
        return map[key] or s
    end

    function getRarityName(record)
        local item = (record and type(record.ItemData) == "table") and record.ItemData or record
        if item then
            local r = item.Rarity or item.RarityTier or item.Tier
            if r then
                if type(r) == "table" and r._id then return normalizeRarityName(r._id) end
                if type(r) == "string" then return normalizeRarityName(r) end
                if type(r) == "table" and (r.DisplayName or r.Name) then
                    return normalizeRarityName(r.DisplayName or r.Name)
                end
            end
        end
        local d = getAssetData(record)
        return normalizeRarityName((d.Rarity and d.Rarity._id) or d.Rarity) or "Unknown"
    end

    function getModelWeight(record)
        if not record then return 0 end
        if record.ModelWeight then return tonumber(record.ModelWeight) or 0 end
        local d = getAssetData(record)
        return tonumber(d.ModelWeight) or 0
    end

    function getEggIcon(rec)
        if EggToolDisplay and type(EggToolDisplay.getIcon) == "function" then
            local ok, icon = pcall(function() return EggToolDisplay.getIcon(rec.Uid) end)
            if ok and type(icon) == "string" and icon ~= "" then return icon end
        end
        local d = getAssetData(rec)
        if d then
            for _, k in ipairs({"Icon","Image","TextureId","Thumbnail"}) do
                if type(d[k]) == "string" and d[k] ~= "" then return d[k] end
            end
        end
        return nil
    end

    function formatWeight(amount)
        amount = tonumber(amount) or 0
        if amount >= 1e9 then return string.format("%.1fb kg", amount/1e9) end
        if amount >= 1e6 then return string.format("%.1fm kg", amount/1e6) end
        if amount >= 1e3 then return string.format("%.1fk kg", amount/1e3) end
        return tostring(math.floor(amount)) .. " kg"
    end

    function safeGet(t, ...)
        if type(t) ~= "table" then return nil end
        for _, key in ipairs({...}) do
            if t[key] ~= nil then return t[key] end
        end
        return nil
    end

    function isEggRecord(rec)
        if type(rec) ~= "table" then return false end
        return safeGet(rec, "AssetCategory", "Category", "ItemId", "Name") ~= nil
    end

    function tryDecode(data)
        if not AssetItemsMod or type(AssetItemsMod.Decode) ~= "function" then return data end
        local ok, decoded = pcall(AssetItemsMod.Decode, data)
        if ok and type(decoded) == "table" then return decoded end
        return data
    end
        
        function readOwnedEggs()
        local merged = {}

        -- ✅ PRIORITAS: SaveModule.EggInventory (98 egg, sumber lengkap)
        if SaveModule and type(SaveModule.Get) == "function" then
            local ok, save = pcall(SaveModule.Get)
            if ok and type(save) == "table" and type(save.EggInventory) == "table" then
                for k, v in pairs(save.EggInventory) do
                    if type(v) == "table" then merged[k] = v end
                end
            end
        end

        -- Fallback ke EggState kalau Save kosong
        if next(merged) == nil then
            local reader = EggState.ReadOwnedEggs or EggState.ReadOwnerEggs
            if reader then
                local ok, snap = pcall(reader, LP.UserId)
                if ok and type(snap) == "table" then
                    local recs = snap.Records or snap
                    if type(recs) == "table" then
                        for k, v in pairs(recs) do
                            if type(v) == "table" then merged[k] = v end
                        end
                    end
                end
            end
        end

        local total = 0
        for _ in pairs(merged) do total = total + 1 end
        print("[EggScanner] readOwnedEggs → total=" .. total)
        return next(merged) and merged or nil
    end

    local EggScanner = {
        gui = nil, main = nil,
        activeTab = "All",
        search = "", rarityFilter = "Any",
        lastKey = "", resetLbl = nil, listFrame = nil,
        seenUids = {}, newCount = 0, notifLbl = nil,
    }

    local RARITY_COLORS = {
        Any=Color3.fromRGB(170,170,180), Common=Color3.fromRGB(180,180,180),
        Uncommon=Color3.fromRGB(90,191,90), Rare=Color3.fromRGB(74,144,217),
        Epic=Color3.fromRGB(166,79,214), Legendary=Color3.fromRGB(245,166,35),
        Mythic=Color3.fromRGB(231,76,60), Divine=Color3.fromRGB(0,229,255),
        Secret=Color3.fromRGB(255,110,199), Cosmic=Color3.fromRGB(224,86,253),
        Eternal=Color3.fromRGB(26,188,156), Brainrot=Color3.fromRGB(255,111,97),
        Mythical=Color3.fromRGB(255,220,100), Exclusive=Color3.fromRGB(255,118,117),
        Prismatic=Color3.fromRGB(253,121,168), Transcendent=Color3.fromRGB(255,159,67),
        Celestial=Color3.fromRGB(255,224,102), SuperRare=Color3.fromRGB(120,200,255),
        Limited=Color3.fromRGB(200,100,255), Exotic=Color3.fromRGB(255,140,200),
        Titan=Color3.fromRGB(255,90,90), Superior=Color3.fromRGB(255,180,100),
        ["Light & Dark"]=Color3.fromRGB(220,220,240), Admin=Color3.fromRGB(255,80,80),
    }
    function rarityColor(n) return RARITY_COLORS[n] or Color3.fromRGB(180,180,190) end

    function buildPanel()
        if EggScanner.gui and EggScanner.gui.Parent then return end
        local parent
        pcall(function() parent = gethui and gethui() or game:GetService("CoreGui") end)
        if not parent then parent = LP:WaitForChild("PlayerGui") end

        local gui = Instance.new("ScreenGui")
        gui.Name = "W424_EggScanner"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 99994
        gui.Parent = parent
        EggScanner.gui = gui

        local main = Instance.new("Frame")
        main.Name = "Main"
        main.Active = true
        main.Size = UDim2.fromOffset(260, 300)
        main.Position = UDim2.new(0, 20, 0.5, -150)
        main.BackgroundColor3 = Color3.fromRGB(16, 22, 38)   -- 🎨 blue tint
        main.BackgroundTransparency = 0.03
        main.BorderSizePixel = 0
        main.Parent = gui
        EggScanner.main = main
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", main)
        stroke.Color = Color3.fromRGB(50, 70, 110)          -- 🎨 blue stroke
        stroke.Thickness = 1

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Active = true
        header.Size = UDim2.new(1, 0, 0, 22)
        header.BackgroundTransparency = 1
        header.Parent = main

        local logo = Instance.new("ImageLabel")
        logo.Size = UDim2.fromOffset(14, 14)
        logo.Position = UDim2.new(0, 7, 0.5, -7)
        logo.BackgroundTransparency = 1
        logo.Image = CONFIG.LogoId
        logo.ScaleType = Enum.ScaleType.Fit
        logo.Active = false
        logo.Parent = header

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -80, 1, 0)
        title.Position = UDim2.new(0, 25, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = CONFIG.Title
        title.TextColor3 = Color3.fromRGB(240, 240, 250)
        title.TextSize = 9
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Active = false
        title.Parent = header

        local notifLbl = Instance.new("TextLabel")
        notifLbl.Size = UDim2.fromOffset(22, 14)
        notifLbl.Position = UDim2.new(1, -60, 0.5, -7)
        notifLbl.BackgroundTransparency = 1
        notifLbl.Text = ""
        notifLbl.TextColor3 = Color3.fromRGB(130, 220, 130)
        notifLbl.TextSize = 7
        notifLbl.Font = Enum.Font.GothamBold
        notifLbl.TextXAlignment = Enum.TextXAlignment.Right
        notifLbl.Active = false
        notifLbl.Parent = header
        EggScanner.notifLbl = notifLbl

        local minBtn = Instance.new("TextButton")
        minBtn.Size = UDim2.fromOffset(16, 16)
        minBtn.Position = UDim2.new(1, -38, 0, 3)
        minBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 64)   -- 🎨 blue tint
        minBtn.Text = "—"
        minBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
        minBtn.Font = Enum.Font.GothamBold
        minBtn.TextSize = 10
        minBtn.BorderSizePixel = 0
        minBtn.Parent = header
        Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.fromOffset(16, 16)
        closeBtn.Position = UDim2.new(1, -20, 0, 3)
        closeBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 64)   -- 🎨 blue tint
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 9
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = header
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
        closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

        local restoreBtn = Instance.new("TextButton")
        restoreBtn.Name = "Restore"
        restoreBtn.Size = UDim2.fromOffset(52, 22)
        restoreBtn.Position = UDim2.new(0, 20, 0.5, -150)
        restoreBtn.BackgroundColor3 = Color3.fromRGB(16, 22, 38)   -- 🎨 blue tint
        restoreBtn.BackgroundTransparency = 0.03
        restoreBtn.Text = "W424  ▸"
        restoreBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
        restoreBtn.Font = Enum.Font.GothamBold
        restoreBtn.TextSize = 9
        restoreBtn.BorderSizePixel = 0
        restoreBtn.Visible = false
        restoreBtn.Active = true
        restoreBtn.Parent = gui
        Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 6)
        local rStroke = Instance.new("UIStroke", restoreBtn)
        rStroke.Color = Color3.fromRGB(50, 70, 110)             -- 🎨 blue stroke
        rStroke.Thickness = 1

        minBtn.MouseButton1Click:Connect(function()
            main.Visible = false
            restoreBtn.Position = main.Position
            restoreBtn.Visible = true
        end)
        restoreBtn.MouseButton1Click:Connect(function()
            restoreBtn.Visible = false
            main.Visible = true
        end)

        do
            local rdragging, rdragStart, rstartPos = false, nil, nil
            restoreBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    rdragging = true; rdragStart = input.Position; rstartPos = restoreBtn.Position
                end
            end)
            restoreBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then rdragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if not rdragging then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                    local delta = input.Position - rdragStart
                    restoreBtn.Position = UDim2.new(
                        rstartPos.X.Scale, rstartPos.X.Offset + delta.X,
                        rstartPos.Y.Scale, rstartPos.Y.Offset + delta.Y)
                end
            end)
        end

        local tabBar = Instance.new("Frame")
        tabBar.Size = UDim2.new(1, -14, 0, 17)
        tabBar.Position = UDim2.new(0, 7, 0, 22)
        tabBar.BackgroundColor3 = Color3.fromRGB(22, 30, 50)   -- 🎨 blue tint
        tabBar.BorderSizePixel = 0
        tabBar.Parent = main
        Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 4)

        local tl = Instance.new("UIListLayout", tabBar)
        tl.FillDirection = Enum.FillDirection.Horizontal
        tl.Padding = UDim.new(0, 2)
        tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tl.VerticalAlignment = Enum.VerticalAlignment.Center

        function mkTab(name)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.3333, -2, 1, -3)
            b.BackgroundColor3 = Color3.fromRGB(22, 30, 50)   -- 🎨 blue tint
            b.Text = name
            b.TextColor3 = Color3.fromRGB(180, 180, 200)
            b.TextSize = 7
            b.Font = Enum.Font.GothamBold
            b.BorderSizePixel = 0
            b.Parent = tabBar
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
            return b
        end
        local tabAll = mkTab("All")
        local tabBag = mkTab("Bag")
        local tabPen = mkTab("Pen")

        function styleTab(btn, active)
            if active then
                btn.BackgroundColor3 = Color3.fromRGB(220, 232, 252)   -- 🎨 blue tint
                btn.TextColor3 = Color3.fromRGB(14, 22, 40)
            else
                btn.BackgroundColor3 = Color3.fromRGB(22, 30, 50)      -- 🎨 blue tint
                btn.TextColor3 = Color3.fromRGB(180, 190, 210)
            end
        end

        function setTab(t)
            EggScanner.activeTab = t
            styleTab(tabAll, t == "All")
            styleTab(tabBag, t == "Bag")
            styleTab(tabPen, t == "Pen")
            EggScanner.lastKey = ""
        end
        setTab("All")
        tabAll.MouseButton1Click:Connect(function() setTab("All") end)
        tabBag.MouseButton1Click:Connect(function() setTab("Bag") end)
        tabPen.MouseButton1Click:Connect(function() setTab("Pen") end)

        local resetLbl = Instance.new("TextLabel")
        resetLbl.Size = UDim2.new(1, -14, 0, 11)
        resetLbl.Position = UDim2.new(0, 8, 0, 42)
        resetLbl.BackgroundTransparency = 1
        resetLbl.Text = "Bag: -- | Pen: --"
        resetLbl.TextColor3 = Color3.fromRGB(100, 180, 240)
        resetLbl.TextSize = 7
        resetLbl.Font = Enum.Font.GothamMedium
        resetLbl.TextXAlignment = Enum.TextXAlignment.Left
        resetLbl.Active = false
        resetLbl.Parent = main
        EggScanner.resetLbl = resetLbl

        local sFrame = Instance.new("Frame")
        sFrame.Size = UDim2.new(1, -14, 0, 17)
        sFrame.Position = UDim2.new(0, 7, 0, 56)
        sFrame.BackgroundColor3 = Color3.fromRGB(24, 32, 52)   -- 🎨 blue tint
        sFrame.BorderSizePixel = 0
        sFrame.Parent = main
        Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)

        local sBox = Instance.new("TextBox")
        sBox.Size = UDim2.new(1, -46, 1, -2)
        sBox.Position = UDim2.new(0, 6, 0, 1)
        sBox.BackgroundTransparency = 1
        sBox.Text = ""
        sBox.PlaceholderText = "Search..."
        sBox.PlaceholderColor3 = Color3.fromRGB(120, 130, 155)
        sBox.TextColor3 = Color3.fromRGB(230, 235, 245)
        sBox.TextSize = 7
        sBox.Font = Enum.Font.Gotham
        sBox.TextXAlignment = Enum.TextXAlignment.Left
        sBox.ClearTextOnFocus = false
        sBox.Parent = sFrame
        sBox:GetPropertyChangedSignal("Text"):Connect(function()
            EggScanner.search = sBox.Text
            EggScanner.lastKey = ""
        end)

        local clearBtn = Instance.new("TextButton")
        clearBtn.Size = UDim2.fromOffset(36, 13)
        clearBtn.Position = UDim2.new(1, -39, 0, 2)
        clearBtn.BackgroundColor3 = Color3.fromRGB(32, 42, 68)   -- 🎨 blue tint
        clearBtn.Text = "Clear"
        clearBtn.TextColor3 = Color3.fromRGB(200, 210, 225)
        clearBtn.TextSize = 6
        clearBtn.Font = Enum.Font.GothamBold
        clearBtn.BorderSizePixel = 0
        clearBtn.Parent = sFrame
        Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 3)
        clearBtn.MouseButton1Click:Connect(function()
            sBox.Text = ""
            EggScanner.search = ""
            EggScanner.rarityFilter = "Any"
            EggScanner.lastKey = ""
        end)

        local chipsScroll = Instance.new("ScrollingFrame")
        chipsScroll.Size = UDim2.new(1, -14, 0, 17)
        chipsScroll.Position = UDim2.new(0, 7, 0, 78)
        chipsScroll.BackgroundTransparency = 1
        chipsScroll.BorderSizePixel = 0
        chipsScroll.ScrollBarThickness = 2
        chipsScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 90, 130)
        chipsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        chipsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
        chipsScroll.ScrollingDirection = Enum.ScrollingDirection.X
        chipsScroll.Parent = main

        local cl = Instance.new("UIListLayout", chipsScroll)
        cl.FillDirection = Enum.FillDirection.Horizontal
        cl.Padding = UDim.new(0, 3)
        cl.VerticalAlignment = Enum.VerticalAlignment.Center

        local chipOrder = { "Any","Divine","Eternal","Secret","Cosmic","Mythic",
                            "Legendary","Epic","Rare","Uncommon","Common" }
        local chipButtons = {}

        function styleChip(b, active, col)
            if active then
                b.BackgroundColor3 = col
                b.TextColor3 = Color3.fromRGB(15, 15, 20)
            else
                b.BackgroundColor3 = Color3.fromRGB(24, 32, 52)   -- 🎨 blue tint
                b.TextColor3 = col
            end
        end

        for _, rn in ipairs(chipOrder) do
            local col = rarityColor(rn)
            local chip = Instance.new("TextButton")
            chip.AutomaticSize = Enum.AutomaticSize.X
            chip.Size = UDim2.fromOffset(0, 14)
            chip.BackgroundColor3 = Color3.fromRGB(24, 32, 52)   -- 🎨 blue tint
            chip.Text = rn
            chip.TextColor3 = col
            chip.TextSize = 6
            chip.Font = Enum.Font.GothamBold
            chip.BorderSizePixel = 0
            chip.Parent = chipsScroll
            Instance.new("UICorner", chip).CornerRadius = UDim.new(0, 7)
            local pad = Instance.new("UIPadding", chip)
            pad.PaddingLeft  = UDim.new(0, 5)
            pad.PaddingRight = UDim.new(0, 5)
            chipButtons[rn] = chip
            styleChip(chip, rn == "Any", col)
            chip.MouseButton1Click:Connect(function()
                EggScanner.rarityFilter = rn
                EggScanner.lastKey = ""
                for k, cb in pairs(chipButtons) do
                    styleChip(cb, k == rn, rarityColor(k))
                end
            end)
        end

        local listFrame = Instance.new("ScrollingFrame")
        listFrame.Size = UDim2.new(1, -14, 1, -106)
        listFrame.Position = UDim2.new(0, 7, 0, 100)
        listFrame.BackgroundTransparency = 1
        listFrame.BorderSizePixel = 0
        listFrame.ScrollBarThickness = 3
        listFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 90, 130)
        listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        listFrame.Parent = main
        EggScanner.listFrame = listFrame

        local ll = Instance.new("UIListLayout", listFrame)
        ll.Padding = UDim.new(0, 3)
        ll.SortOrder = Enum.SortOrder.LayoutOrder

        -- ============================================================
        -- DRAG + RESIZE
        -- ============================================================
        local dragging, dragStart, startPos = false, nil, nil
        local resizing, resizeStart, resizeStartSize = false, nil, nil

        local resizeHandle = Instance.new("TextButton")
        resizeHandle.Name = "ResizeHandle"
        resizeHandle.Size = UDim2.fromOffset(16, 16)
        resizeHandle.Position = UDim2.new(1, -18, 1, -18)
        resizeHandle.BackgroundColor3 = Color3.fromRGB(32, 42, 68)   -- 🎨 blue tint
        resizeHandle.BackgroundTransparency = 0.25
        resizeHandle.Text = "◢"
        resizeHandle.TextColor3 = Color3.fromRGB(200, 210, 230)
        resizeHandle.TextSize = 11
        resizeHandle.Font = Enum.Font.GothamBold
        resizeHandle.BorderSizePixel = 0
        resizeHandle.ZIndex = 10
        resizeHandle.Parent = main
        Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 3)

        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                dragging = false
                resizeStart = input.Position
                resizeStartSize = main.AbsoluteSize
            end
        end)
        resizeHandle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)

        function beginDrag(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = main.Position
            end
        end
        function endDrag(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end

        header.InputBegan:Connect(beginDrag)
        header.InputEnded:Connect(endDrag)

        main.InputBegan:Connect(function(input)
            if resizing then return end
            if (input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch) and not dragging then
                beginDrag(input)
            end
        end)
        main.InputEnded:Connect(endDrag)

        UserInputService.InputChanged:Connect(function(input)
            if resizing then
                if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                    local delta = input.Position - resizeStart
                    local newW = math.clamp(resizeStartSize.X + delta.X, 220, 700)
                    local newH = math.clamp(resizeStartSize.Y + delta.Y, 220, 800)
                    main.Size = UDim2.fromOffset(newW, newH)
                end
                return
            end
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    function createCard(parent, d, order)
        local col = rarityColor(d.rarity)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -2, 0, 30)
        card.BackgroundColor3 = d.isNew and Color3.fromRGB(24, 32, 24) or Color3.fromRGB(20, 26, 42)   -- 🎨 blue tint
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Parent = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

        -- Background transparan tambahan (glass look)
        local cardBg = Instance.new("Frame")
        cardBg.Name = "CardBG"
        cardBg.Size = UDim2.fromScale(1, 1)
        cardBg.BackgroundColor3 = Color3.fromRGB(140, 180, 255)
        cardBg.BackgroundTransparency = 0.88
        cardBg.BorderSizePixel = 0
        cardBg.ZIndex = 0
        cardBg.Parent = card
        Instance.new("UICorner", cardBg).CornerRadius = UDim.new(0, 4)

        local bgStroke = Instance.new("UIStroke", cardBg)
        bgStroke.Color = Color3.fromRGB(140, 180, 255)
        bgStroke.Thickness = 1
        bgStroke.Transparency = 0.75

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 2, 1, -4)
        accent.Position = UDim2.new(0, 2, 0, 2)
        accent.BackgroundColor3 = col
        accent.BorderSizePixel = 0
        accent.ZIndex = 2
        accent.Parent = card
        Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

        local iconBox = Instance.new("Frame")
        iconBox.Size = UDim2.fromOffset(20, 20)
        iconBox.Position = UDim2.new(0, 8, 0, 5)
        iconBox.BackgroundColor3 = Color3.fromRGB(28, 36, 56)   -- 🎨 blue tint
        iconBox.BorderSizePixel = 0
        iconBox.ZIndex = 2
        iconBox.Parent = card
        Instance.new("UICorner", iconBox).CornerRadius = UDim.new(0, 4)

        local iconUrl = getEggIcon(d.record)
        if iconUrl then
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.fromScale(1, 1)
            img.BackgroundTransparency = 1
            img.Image = iconUrl
            img.ScaleType = Enum.ScaleType.Fit
            img.ZIndex = 3
            img.Parent = iconBox
            Instance.new("UICorner", img).CornerRadius = UDim.new(0, 4)
        else
            local l = Instance.new("TextLabel")
            l.Size = UDim2.fromScale(1, 1)
            l.BackgroundTransparency = 1
            l.Text = (d.eggName or "?"):sub(1, 2)
            l.TextColor3 = col
            l.TextSize = 8
            l.Font = Enum.Font.GothamBold
            l.ZIndex = 3
            l.Parent = iconBox
        end

        local eggName = Instance.new("TextLabel")
        eggName.Size = UDim2.new(1, -160, 0, 9)
        eggName.Position = UDim2.new(0, 34, 0, 3)
        eggName.BackgroundTransparency = 1
        eggName.Text = d.eggName or "Unknown"
        eggName.TextColor3 = Color3.fromRGB(240, 240, 250)
        eggName.TextSize = 7
        eggName.Font = Enum.Font.GothamBold
        eggName.TextXAlignment = Enum.TextXAlignment.Left
        eggName.TextTruncate = Enum.TextTruncate.AtEnd
        eggName.ZIndex = 2
        eggName.Active = false
        eggName.Parent = card

        local petName = Instance.new("TextLabel")
        petName.Size = UDim2.new(1, -160, 0, 8)
        petName.Position = UDim2.new(0, 34, 0, 12)
        petName.BackgroundTransparency = 1
        petName.Text = d.petName or "-"
        petName.TextColor3 = Color3.fromRGB(150, 160, 185)
        petName.TextSize = 6
        petName.Font = Enum.Font.Gotham
        petName.TextXAlignment = Enum.TextXAlignment.Left
        petName.TextTruncate = Enum.TextTruncate.AtEnd
        petName.ZIndex = 2
        petName.Active = false
        petName.Parent = card

        local rarLine = Instance.new("TextLabel")
        rarLine.Size = UDim2.new(1, -160, 0, 8)
        rarLine.Position = UDim2.new(0, 34, 0, 20)
        rarLine.BackgroundTransparency = 1
        local mutTxt = "No Mut"
        if type(d.mutations) == "table" and #d.mutations > 0 then
            local ok, joined = pcall(table.concat, d.mutations, ",")
            if ok then mutTxt = joined end
        end
        rarLine.Text = d.rarity .. " • " .. mutTxt
        rarLine.TextColor3 = col
        rarLine.TextSize = 6
        rarLine.Font = Enum.Font.GothamMedium
        rarLine.TextXAlignment = Enum.TextXAlignment.Left
        rarLine.TextTruncate = Enum.TextTruncate.AtEnd
        rarLine.ZIndex = 2
        rarLine.Active = false
        rarLine.Parent = card

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.fromOffset(80, 10)
        statusLbl.Position = UDim2.new(1, -86, 0, 3)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = d.placed and "🏠 Pen" or "🎒 Bag"
        statusLbl.TextColor3 = d.placed and Color3.fromRGB(180, 200, 240) or Color3.fromRGB(130, 220, 130)
        statusLbl.TextSize = 7
        statusLbl.Font = Enum.Font.GothamBold
        statusLbl.TextXAlignment = Enum.TextXAlignment.Right
        statusLbl.ZIndex = 2
        statusLbl.Active = false
        statusLbl.Parent = card

        local subLbl = Instance.new("TextLabel")
        subLbl.Size = UDim2.fromOffset(80, 9)
        subLbl.Position = UDim2.new(1, -86, 0, 14)
        subLbl.BackgroundTransparency = 1
        if d.placed and d.area and d.area ~= "?" then
            subLbl.Text = d.area
        else
            subLbl.Text = formatWeight(d.weight or 0)
        end
        subLbl.TextColor3 = Color3.fromRGB(150, 160, 185)
        subLbl.TextSize = 7
        subLbl.Font = Enum.Font.Gotham
        subLbl.TextXAlignment = Enum.TextXAlignment.Right
        subLbl.TextTruncate = Enum.TextTruncate.AtEnd
        subLbl.ZIndex = 2
        subLbl.Active = false
        subLbl.Parent = card
    end

        function collectData()
        local records = readOwnedEggs()
        if type(records) ~= "table" then return {}, 0, 0 end

        -- ✅ FIX FINAL: cache uid yang ada di PlacedEggRenders (O(1) lookup)
        local placedSet = {}
        local placedFolder = Workspace:FindFirstChild("PlacedEggRenders")
        if placedFolder then
            for _, child in ipairs(placedFolder:GetChildren()) do
                -- Format child: "<userId>_<eggUid>" → ambil eggUid
                local childUid = tostring(child.Name):match("_([^_]+)$") or child.Name
                placedSet[childUid] = true
            end
        end

        local search = (EggScanner.search or ""):lower()
        local rFilter = EggScanner.rarityFilter
        local tab = EggScanner.activeTab
        local out = {}
        local newCount = 0
        local bagCount, penCount = 0, 0

        for uid, rawRec in pairs(records) do
            local rec = tryDecode(rawRec)
            if isEggRecord(rec) then
                local uidStr = tostring(safeGet(rec, "Uid", "UID", "uid", "Id", "ID") or uid)
                local category = tostring(safeGet(rec, "AssetCategory", "Category", "ItemId", "Name") or "Unknown")

                -- ✅ FIX FINAL: cek membership di PlacedEggRenders
                local uidClean = tostring(uid):gsub("^%d+_", "")
                local isPlaced = placedSet[uidClean] == true

                if isPlaced then penCount = penCount + 1
                else bagCount = bagCount + 1 end

                local tabMatch = true
                if tab == "Bag" and isPlaced then tabMatch = false end
                if tab == "Pen" and not isPlaced then tabMatch = false end

                if tabMatch then
                    local rar = "Unknown"
                    pcall(function() rar = getRarityName(rec) end)

                    local petCat = "-"
                    local itemData = safeGet(rec, "ItemData", "Item")
                    if type(itemData) == "table" then
                        petCat = tostring(safeGet(itemData, "AssetCategory", "Category", "Name") or petCat)
                    end
                    if petCat == "-" then
                        petCat = tostring(safeGet(rec, "PetCategory", "PetName", "DisplayName") or "-")
                    end

                    local asset = AssetDirectory and AssetDirectory[category]
                    local eggName = tostring((asset and (asset.DisplayName or asset.Name)) or category)

                    local area = tostring(safeGet(rec, "AreaId", "Area", "area", "Zone") or "?")

                    local muts = safeGet(rec, "Mutations", "mutations", "Mutation") or {}
                    if type(muts) ~= "table" then muts = {} end

                    local weight = tonumber(safeGet(rec, "ModelWeight", "Weight", "weight", "kg", "Mass")) or 0
                    if weight == 0 then weight = getModelWeight(rec) end

                    local matchSearch = true
                    if search ~= "" then
                        matchSearch = eggName:lower():find(search, 1, true) ~= nil
                            or petCat:lower():find(search, 1, true) ~= nil
                            or category:lower():find(search, 1, true) ~= nil
                    end

                    local matchRarity = (rFilter == "Any") or (rar == rFilter)

                    if matchSearch and matchRarity then
                        local isNew = not EggScanner.seenUids[uidStr]
                        if isNew then
                            EggScanner.seenUids[uidStr] = true
                            newCount = newCount + 1
                        end
                        table.insert(out, {
                            uid = uidStr, eggName = eggName, petName = petCat,
                            rarity = rar, mutations = muts, area = area,
                            weight = weight, placed = isPlaced, isNew = isNew,
                            record = rec,
                        })
                    end
                end
            end
        end

        EggScanner.newCount = newCount
        if EggScanner.notifLbl then
            if newCount > 0 then
                EggScanner.notifLbl.Text = "+" .. newCount .. " new"
                EggScanner.notifLbl.TextColor3 = Color3.fromRGB(130, 220, 130)
            else
                EggScanner.notifLbl.Text = ""
            end
        end
        if EggScanner.resetLbl then
            EggScanner.resetLbl.Text = string.format("Bag: %d | Pen: %d", bagCount, penCount)
        end

        table.sort(out, function(a, b)
            if a.isNew ~= b.isNew then return a.isNew end
            if a.weight ~= b.weight then return a.weight > b.weight end
            local sa = RARITY_SCORE_MAP[a.rarity] or 0
            local sb = RARITY_SCORE_MAP[b.rarity] or 0
            return sa > sb
        end)
        return out, bagCount, penCount
    end

    function render()
        local lf = EggScanner.listFrame
        if not lf then return end
        local data = collectData()

        local keys = {}
        for _, d in ipairs(data) do
            table.insert(keys, d.uid .. "_" .. (d.isNew and "N" or "-"))
        end
        local key = table.concat(keys, "|") .. "|T:" .. EggScanner.activeTab
            .. "|S:" .. EggScanner.search .. "|R:" .. EggScanner.rarityFilter
        if key == EggScanner.lastKey then return end
        EggScanner.lastKey = key

        for _, c in ipairs(lf:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
        end

        if #data == 0 then
            local msg = "No eggs"
            if EggScanner.activeTab == "Bag" then msg = "Bag is empty"
            elseif EggScanner.activeTab == "Pen" then msg = "Pen is empty" end
            local e = Instance.new("TextLabel")
            e.Size = UDim2.new(1, 0, 0, 36)
            e.BackgroundTransparency = 1
            e.Text = msg
            e.TextColor3 = Color3.fromRGB(140, 150, 175)
            e.TextSize = 8
            e.Font = Enum.Font.Gotham
            e.TextWrapped = true
            e.Parent = lf
            return
        end

        for i, d in ipairs(data) do
            createCard(lf, d, i)
        end
    end

    buildPanel()
    EggScanner.gui.Enabled = false

    task.spawn(function()
        while EggScanner.gui and EggScanner.gui.Parent do
            task.wait(1)
            pcall(render)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == CONFIG.ToggleKey then
            if EggScanner.gui then
                EggScanner.gui.Enabled = not EggScanner.gui.Enabled
            end
        end
    end)

    _G.W424_EggScanner = EggScanner
    EggScannerRef = EggScanner
    print("[W424 EggScanner] Loaded! RightShift to toggle.")
end

pcall(InitEggScanner)

function SetEggScannerVisible(state)
    if _G.W424_EggScanner and _G.W424_EggScanner.gui then
        _G.W424_EggScanner.gui.Enabled = state and true or false
        return true
    end
    return false
end

-- ============================================================
-- W424 UI
-- ============================================================
local repo = "https://raw.githubusercontent.com/willrev-424/W424HUB/refs/heads/main/W424_UI.lua"

do
    local success, lib = pcall(function()
        local L = loadstring(game:HttpGet(repo))
        assert(L, "W424_UI library not found")
        local lib = L()
        assert(lib, "W424_UI returned nil")
        return lib
    end)
    if success and lib then
        Library = lib
    else
        warn("[W424Hub] Gagal load W424_UI:", tostring(lib))
        return
    end
end

if not Library then return end

function Notify(title, text, dur)
    pcall(function()
        if notif then
            notif(tostring(title) .. ": " .. tostring(text))
        end
    end)
    print(string.format("[W424 Hub] %s: %s", tostring(title), tostring(text)))
end

Window = Library:Window({
    Title       = "W424 HUB PREMIUM",
    Footer      = "| Steal a egg",
    Description = "Steal An Egg Automation",
    Image       = "109462748520607",
    Icon        = "rbxassetid://109462748520607",
    Color       = Color3.fromRGB(30, 133, 243),
    ["Tab Width"] = 130,
    Version     = 3
})

pcall(function()
    Window:Tag({
        Title = "Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"),
        Color = Color3.fromRGB(100, 100, 100),
        Radius = 13
    })
end)

function getSection(tab, title, expanded)
    return tab:AddSection(title, expanded ~= false)
end

local InfoTab   = Window:AddTab({ Name = "Server"   })
local FarmTab   = Window:AddTab({ Name = "Farm"    })
local BaseTab   = Window:AddTab({ Name = "Base"    })
local StoreTab  = Window:AddTab({ Name = "Store"   })
local PlayerTab = Window:AddTab({ Name = "Player"  })
local MiscTab   = Window:AddTab({ Name = "Misc"    })
local EventTab  = Window:AddTab({ Name = "Event"   })
local ConfigTab = Window:AddTab({ Name = "Config"  })

function rarityValues()
    local t = { "All" }
    for _, v in ipairs(RARITY_NAMES) do t[#t + 1] = v end
    return t
end

function applyMultiFilter(target, v)
    table.clear(target)
    if type(v) == "table" then
        for _, o in ipairs(v) do
            if o ~= "All" then target[o] = true end
        end
    elseif type(v) == "string" and v ~= "All" then
        target[v] = true
    end
end

grpInfo = getSection(InfoTab, "Server", true)

grpInfo:AddButton({
    Title = "Return to Lobby",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Return To Lobby",
            Text = "Back...",
            Icon = "rbxassetid://82799775499788",
            Duration = 3
        })

        ReplicatedStorage.Remotes.Game.loadcharevent:FireServer()
    end
})
grpInfo:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Rejoin Server",
            Text = "Rejoining server...",
            Icon = "rbxassetid://82799775499788",
            Duration = 3
        })

        task.delay(1, function()
            TeleportService:Teleport(game.PlaceId)
        end)
    end
})
grpInfo:AddButton({
    Title = "Server Hop",
    Callback = function()
        notif("Finding new server...", 1)
        
        local success, result = pcall(function()
            return game:HttpGet(string.format(
                "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", 
                game.PlaceId
            ))
        end)
        
        if success then
            local serverList = game:GetService("HttpService"):JSONDecode(result)
            
            if serverList and serverList.data then
                local servers = {}
                for _, server in ipairs(serverList.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        table.insert(servers, server)
                    end
                end
                
                if #servers > 0 then
                    local randomServer = servers[math.random(1, #servers)]
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id, Players.LocalPlayer)
                else
                    notif("No available servers found!")
                end
            else
                notif("Failed to get server list!")
            end
        else
            notif("Error connecting to Roblox API!")
        end
    end
})
grpInfo:AddButton({
    Title = "Server Hop (Small Server)",
    Callback = function()
        notif("Searching for a small server...", 2)
        
        local success, result = pcall(function()
            return game:HttpGet(string.format(
                "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", 
                game.PlaceId
            ))
        end)
        
        if success then
            local serverList = game:GetService("HttpService"):JSONDecode(result)
            
            if serverList and serverList.data then
                local targetServer = nil
                
                for _, server in ipairs(serverList.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        if server.playing <= 5 then 
                            targetServer = server
                            break
                        end
                    end
                end
                
                if targetServer then
                    notif("Found server with " .. targetServer.playing .. " players!", 2)
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, targetServer.id, game.Players.LocalPlayer)
                else
                    notif("No small servers ( < 5 players) found!")
                end
            else
                notif("Failed to parse server list!")
            end
        else
            notif("API Error!")
        end
    end
})

-- FARM TAB
local grpSteal = getSection(FarmTab, "Steal", true)

grpSteal:AddToggle({
    Title   = "Auto Steal Egg",
    Content = "Enable automatic egg steal cycle",
    Default = false,
    Callback = function(v)
        farmEnabled = v
        if v then pcall(loadModules) end
        Notify("Farm", v and "Auto Steal ON" or "Auto Steal OFF")
    end,
})

grpSteal:AddDropdown({
    Title    = "Movement Method",
    Content  = "Choose movement method",
    Options  = { "Tween Glide", "Fly Glide" },
    Default  = "Tween Glide",
    Callback = function(v) moveMethod = v end,
})

grpSteal:AddSlider({
    Title     = "Farm Speed",
    Content   = "Movement speed while stealing",
    Min       = 50,
    Max       = 1000,
    Default   = 750,
    Increment = 1,
    Callback  = function(v) farmSpeed = v end,
})

grpSteal:AddSlider({
    Title     = "Farm Delay",
    Content   = "Delay between steal cycles (seconds)",
    Min       = 1,
    Max       = 10,
    Default   = 2,
    Increment = 1,
    Callback  = function(v) farmDelay = v end,
})

local grpFilter = getSection(FarmTab, "Filters", true)

grpFilter:AddDropdown({
    Title    = "Filter Rarity",
    Content  = "Allowed rarities (empty = all)",
    Options  = rarityValues(),
    Default  = {},
    Multi    = true,
    Callback = function(v)
        applyMultiFilter(targetRarities, v)
        Notify("Filter", "Rarity filter updated")
    end,
})

grpFilter:AddDropdown({
    Title    = "Filter Area",
    Content  = "Allowed areas (empty = all)",
    Options  = (function()
        local t = { "All" }
        for _, v in ipairs(AREA_NAMES) do t[#t + 1] = v end
        return t
    end)(),
    Default  = {},
    Multi    = true,
    Callback = function(v)
        applyMultiFilter(targetAreas, v)
        Notify("Filter", "Area filter updated")
    end,
})

grpFilter:AddDropdown({
    Title    = "Filter Mutation",
    Content  = "Mutations allowed to steal (empty = all)",
    Options  = { "Normal Only", "Mutated Only", "Parasite / Infested", "Monstrous", "Silver Only", "Gold Only", "Rainbow Only" },
    Default  = {},
    Multi    = true,
    Callback = function(v)
        applyMultiFilter(targetMutations, v)
        Notify("Filter", "Mutation filter updated")
    end,
})

grpFilter:AddToggle({
    Title   = "Steal Big Eggs Only",
    Content = "Only target big eggs",
    Default = false,
    Callback = function(v) S.stealBigEggsOnly = v end,
})

local grpActions = getSection(FarmTab, "Actions", true)

grpActions:AddButton({
    Title   = "Steal Once",
    Content = "Run one steal cycle",
    Callback = function()
        task.spawn(function()
            local cycle = stealCycle
            local ok, err = pcall(cycle)
            Notify("Farm", ok and "Done" or tostring(err))
        end)
    end,
})

grpActions:AddButton({
    Title   = "Clear Ignored Eggs",
    Content = "Clear ignored egg list",
    Callback = function()
        table.clear(ignoredEggs)
        Notify("Farm", "Cleared")
    end,
})

-- BASE TAB
local grpBaseAuto = getSection(BaseTab, "Automation", true)

grpBaseAuto:AddToggle({
    Title   = "Auto Place Eggs",
    Content = "Automatically place eggs in pen",
    Default = false,
    Callback = function(v) S.autoPlantEnabled = v end,
})

grpBaseAuto:AddDropdown({
    Title    = "Place Rarities",
    Content  = "Rarities allowed to be placed (All = every rarity)",
    Options  = rarityValues(),
    Default  = {},
    Multi    = true,
    Callback = function(v)
        applyMultiFilter(S.placeRarities, v)
        Notify("Place", "Rarity filter updated")
    end,
})

grpBaseAuto:AddToggle({
    Title   = "Auto Hatch Eggs",
    Content = "Automatically hatch ready eggs",
    Default = false,
    Callback = function(v) S.autoHatchEnabled = v end,
})

grpBaseAuto:AddToggle({
    Title   = "Auto Upgrade Base",
    Content = "Auto upgrade homestead base tier",
    Default = false,
    Callback = function(v) S.autoUpgradeBase = v end,
})

grpBaseAuto:AddToggle({
    Title   = "Auto Upgrade Treadmill",
    Content = "Auto upgrade treadmill tier",
    Default = false,
    Callback = function(v) S.autoUpgradeTreadmill = v end,
})

grpBaseAuto:AddToggle({
    Title   = "Auto Equip Best Pets",
    Content = "Auto equip best pets",
    Default = false,
    Callback = function(v) S.autoEquipBestPets = v end,
})

grpBaseAuto:AddToggle({
    Title   = "Auto Claim Rewards",
    Content = "Auto claim rewards",
    Default = false,
    Callback = function(v) S.autoClaimRewards = v end,
})

grpBaseAuto:AddToggle({
    Title   = "Auto Favorite Pets",
    Content = "Auto favorite matching pets",
    Default = false,
    Callback = function(v) S.autoFavoritePets = v end,
})

grpBaseAuto:AddDropdown({
    Title    = "Fav Rarities",
    Content  = "Rarities to favorite (empty = all)",
    Options  = rarityValues(),
    Default  = {},
    Multi    = true,
    Callback = function(v)
        applyMultiFilter(S.favRarities, v)
    end,
})

local grpBaseRun = getSection(BaseTab, "Run Now", true)

grpBaseRun:AddButton({
    Title   = "Place Eggs Now",
    Content = "Place all unplaced eggs now",
    Callback = function()
        task.spawn(function()
            local n = PlantAllCarriedEggsInPen()
            Notify("Place", "Planted " .. tostring(n) .. " eggs")
        end)
    end,
})

grpBaseRun:AddButton({
    Title   = "Hatch All Now",
    Content = "Hatch all ready eggs now",
    Callback = function()
        task.spawn(function()
            local n = HatchAllReadyEggs()
            Notify("Hatch", "Hatched " .. tostring(n) .. " eggs")
        end)
    end,
})

grpBaseRun:AddButton({
    Title   = "Claim All Rewards",
    Content = "Claim all available rewards",
    Callback = function() pcall(ClaimAllAvailableRewards); Notify("Rewards", "Claimed") end,
})

grpBaseRun:AddButton({
    Title   = "Upgrade Base Now",
    Content = "Upgrade base tier now",
    Callback = function() pcall(UpgradeHomesteadBase); Notify("Base", "Upgraded") end,
})

grpBaseRun:AddButton({
    Title   = "Upgrade Treadmill Now",
    Content = "Upgrade treadmill tier now",
    Callback = function() pcall(UpgradeTreadmillTier); Notify("Treadmill", "Upgraded") end,
})

grpBaseRun:AddButton({
    Title   = "Favorite Now",
    Content = "Favorite matching pets now",
    Callback = function()
        task.spawn(function()
            local n = AutoFavoritePets()
            Notify("Favorite", "Favorited " .. tostring(n))
        end)
    end,
})

-- STORE TAB
local grpStorePet = getSection(StoreTab, "Pets", true)

grpStorePet:AddToggle({
    Title   = "Auto Sell Low-Tier Pets",
    Content = "Automatically sell low-tier pets",
    Default = false,
    Callback = function(v) S.autoSellPets = v end,
})

grpStorePet:AddDropdown({
    Title    = "Pet Sell Rarities",
    Content  = "Rarities to sell (empty = default low tier)",
    Options  = rarityValues(),
    Default  = {},
    Multi    = true,
    Callback = function(v)
        applyMultiFilter(S.selectedSellPetRarities, v)
    end,
})

grpStorePet:AddButton({
    Title   = "Sell Pets Now",
    Content = "Sell selected pets now",
    Callback = function()
        task.spawn(function() pcall(SellSelectedPets); Notify("Sell", "Done") end)
    end,
})

local grpStoreEgg = getSection(StoreTab, "Eggs", true)

grpStoreEgg:AddToggle({
    Title   = "Auto Sell Low-Tier Eggs",
    Content = "Automatically sell low-tier eggs",
    Default = false,
    Callback = function(v) S.autoSellEggs = v end,
})

grpStoreEgg:AddDropdown({
    Title    = "Egg Sell Rarities",
    Content  = "Rarities to sell (empty = default low tier)",
    Options  = rarityValues(),
    Default  = {},
    Multi    = true,
    Callback = function(v)
        applyMultiFilter(S.selectedSellEggRarities, v)
    end,
})

grpStoreEgg:AddButton({
    Title   = "Sell Eggs Now",
    Content = "Sell selected eggs now",
    Callback = function()
        task.spawn(function() pcall(SellSelectedEggs); Notify("Sell", "Done") end)
    end,
})

-- PLAYER TAB
local grpPlayerCombat = getSection(PlayerTab, "Combat", true)

grpPlayerCombat:AddToggle({
    Title   = "Anti-Trap",
    Content = "Destroy enemy trap hitboxes",
    Default = false,
    Callback = function(v)
        S.avoidTrapsEnabled = v
        ApplyAntiTrap(v)
        Notify("Anti-Trap", v and "ON" or "OFF")
    end,
})

grpPlayerCombat:AddToggle({
    Title   = "Boss: Auto Join",
    Content = "Auto join boss arena when open",
    Default = false,
    Callback = function(v) Boss.autoJoin = v; Notify("Boss", v and "Auto Join ON" or "OFF") end,
})

grpPlayerCombat:AddToggle({
    Title   = "Boss: Auto Fight",
    Content = "Auto fight boss in arena",
    Default = false,
    Callback = function(v) Boss.autoFight = v; Notify("Boss", v and "Auto Fight ON" or "OFF") end,
})

grpPlayerCombat:AddDropdown({
    Title    = "Boss Strategy",
    Content  = "Target priority",
    Options  = { "Crystals First", "Boss First" },
    Default  = "Crystals First",
    Callback = function(v) Boss.arenaApproach = v end,
})

grpPlayerCombat:AddSlider({
    Title     = "Boss Glide Speed",
    Content   = "Boss fight movement speed",
    Min       = 100,
    Max       = 500,
    Default   = 260,
    Increment = 5,
    Callback  = function(v) Boss.glideSpeed = v end,
})

grpPlayerCombat:AddButton({
    Title   = "Join Boss Arena Now",
    Content = "Join boss arena now",
    Callback = function()
        task.spawn(function()
            local ok = Boss.Join()
            Notify("Boss", ok and "Joined!" or "Not open yet")
        end)
    end,
})

grpPlayerCombat:AddButton({
    Title   = "Check Arena Status",
    Content = "Check if boss arena is open",
    Callback = function()
        task.spawn(function()
            local open = Boss.IsOpen()
            if open then
                Notify("Boss", "Arena OPEN")
            else
                local secs = Boss.SecondsUntilOpen()
                if secs then
                    Notify("Boss", "Arena closed — opens in " .. math.floor(secs) .. "s")
                else
                    Notify("Boss", "Arena closed")
                end
            end
        end)
    end,
})

grpPlayerCombat:AddButton({
    Title   = "Claim Boss Mastery",
    Content = "Claim all boss mastery milestones",
    Callback = function()
        task.spawn(function()
            local n = Boss.ClaimMastery()
            Notify("Boss", "Claimed " .. tostring(n) .. " milestones")
        end)
    end,
})

grpPlayerCombat:AddToggle({
    Title   = "Boss: Hazard Immune",
    Content = "Block arena hazard damage (not mobile)",
    Default = false,
    Callback = function(v)
        Boss.hazardImmune = v
        if v then
            local ok = Boss.InstallHazardHook()
            Notify("Boss Hazards", ok and "Hazard Immune ON" or "Not supported on this device")
        else
            Notify("Boss Hazards", "OFF")
        end
    end,
})

grpPlayerCombat:AddToggle({
    Title   = "Bat / Slap Aura",
    Content = "Auto swing bat at nearby players",
    Default = false,
    Callback = function(v) S.batAuraEnabled = v; Notify("Bat Aura", v and "ON" or "OFF") end,
})

grpPlayerCombat:AddSlider({
    Title     = "Aura Radius",
    Content   = "Bat aura radius (studs)",
    Min       = 5,
    Max       = 60,
    Default   = 20,
    Increment = 1,
    Callback  = function(v) S.batAuraRadius = v end,
})

grpPlayerCombat:AddSlider({
    Title     = "Swing Delay",
    Content   = "Delay between swings (x0.1s)",
    Min       = 1,
    Max       = 20,
    Default   = 2,
    Increment = 1,
    Callback  = function(v) S.batAuraDelay = v / 10 end,
})

grpPlayerCombat:AddButton({
    Title   = "Swing Bat Once",
    Content = "Manually trigger bat swing",
    Callback = function()
        local re = GetNetRemote("RE/BatSwing/Trigger")
        if re then pcall(function() re:FireServer() end) end
        Notify("Bat", "Triggered")
    end,
})

grpPlayerCombat:AddToggle({
    Title   = "Auto Fuse Pets",
    Content = "Automatically fuse matching pets",
    Default = false,
    Callback = function(v) S.autoFusePets = v; Notify("Fuse", v and "ON" or "OFF") end,
})

grpPlayerCombat:AddToggle({
    Title   = "Fuse: Selected Only (whitelist)",
    Content = "Only fuse selected categories",
    Default = false,
    Callback = function(v) S.fuseSelectedOnly = v end,
})

grpPlayerCombat:AddDropdown({
    Title    = "Fuse Rarities",
    Content  = "Rarities allowed to fuse (empty = disabled for safety)",
    Options  = rarityValues(),
    Default  = {},
    Multi    = true,
    Callback = function(v)
        applyMultiFilter(S.fuseRarities, v)
    end,
})

grpPlayerCombat:AddButton({
    Title   = "Fuse Once",
    Content = "Run one fuse cycle",
    Callback = function()
        task.spawn(function()
            if not next(S.fuseRarities) and not S.fuseSelectedOnly then
                Notify("Fuse", "Set Fuse Rarities first (safety)")
                return
            end
            local ok, msg = AutoFusePets()
            Notify("Fuse", ok and "Fused!" or tostring(msg or "failed"))
        end)
    end,
})

local grpPlayerMove = getSection(PlayerTab, "Movement", true)

grpPlayerMove:AddToggle({
    Title   = "Enable WalkSpeed",
    Content = "Override walk speed",
    Default = false,
    Callback = function(v)
        S.walkSpeedEnabled = v
        if not v then local h = findHum(); if h then h.WalkSpeed = 16 end end
    end,
})

grpPlayerMove:AddSlider({
    Title     = "WalkSpeed Value",
    Content   = "Walk speed value",
    Min       = 16,
    Max       = 500,
    Default   = 24,
    Increment = 1,
    Callback  = function(v) S.walkSpeedVal = v end,
})

grpPlayerMove:AddToggle({
    Title   = "Enable JumpPower",
    Content = "Override jump power",
    Default = false,
    Callback = function(v)
        S.jumpPowerEnabled = v
        if not v then local h = findHum(); if h then h.JumpPower = 50 end end
    end,
})

grpPlayerMove:AddSlider({
    Title     = "JumpPower Value",
    Content   = "Jump power value",
    Min       = 50,
    Max       = 300,
    Default   = 60,
    Increment = 1,
    Callback  = function(v) S.jumpPowerValue = v end,
})

grpPlayerMove:AddToggle({
    Title   = "Infinite Jump (hold Space)",
    Content = "Jump infinitely while holding Space",
    Default = false,
    Callback = function(v) S.infiniteJumpEnabled = v end,
})

grpPlayerMove:AddToggle({
    Title   = "Smooth Fly (WASD)",
    Content = "Enable WASD flight mode",
    Default = false,
    Callback = function(v)
        S.flyEnabled = v
        if v then startFly() else stopFly() end
        Notify("Fly", v and "Enabled" or "Disabled")
    end,
})

grpPlayerMove:AddSlider({
    Title     = "Fly Speed",
    Content   = "Fly speed value",
    Min       = 20,
    Max       = 250,
    Default   = 60,
    Increment = 1,
    Callback  = function(v) S.flySpeed = v end,
})

local grpPlayerUtil = getSection(PlayerTab, "Utility", true)

grpPlayerUtil:AddToggle({
    Title   = "Rename Nametag → I'm W424Hub",
    Content = "Ganti semua nametag (kamu + pemain lain) jadi \"I'm W424Hub\"",
    Default = false,
    Callback = function(v)
        ApplyRenameNametags(v)
        Notify("Nametag", v and "Renamed to I'm W424Hub" or "Restored")
    end,
})

grpPlayerUtil:AddToggle({
    Title   = "No Knockback",
    Content = "Disable RigSync knockback",
    Default = true,
    Callback = function(v)
        pcall(function() SetNoKnockback(v) end)
        Notify("No Knockback", v and "ON" or "OFF")
    end,
})

grpPlayerUtil:AddToggle({
    Title   = "Anti-AFK",
    Content = "Prevent AFK kick",
    Default = false,
    Callback = function(v) SetAntiAFK(v) end,
})

grpPlayerUtil:AddToggle({
    Title   = "Fullbright",
    Content = "Maximize lighting",
    Default = false,
    Callback = function(v) SetFullbright(v) end,
})

grpPlayerUtil:AddButton({
    Title   = "Delete Pet Renders (FPS)",
    Content = "Delete rendered pet models",
    Callback = function()
        local n = DeleteOwnPetRenders()
        Notify("FPS", "Removed " .. tostring(n) .. " models")
    end,
})

grpPlayerUtil:AddDropdown({
    Title    = "Select Area",
    Content  = "Choose target area for travel",
    Options  = areaKeys,
    Default  = "Forest",
    Callback = function(v) selectedAreaTp = v end,
})

grpPlayerUtil:AddButton({
    Title   = "Travel to Area",
    Content = "Travel to selected area",
    Callback = function()
        local pos = AREA_COORDINATES[selectedAreaTp]
        if pos then
            Notify("Travel", "Traveling to " .. selectedAreaTp)
            task.spawn(function() MoveToPoint(pos, farmSpeed, false) end)
        end
    end,
})

-- ============================================================
-- [NEW] Performance Section (W424 HUB style)
-- ============================================================
local grpPlayerPerf = getSection(PlayerTab, "Performance", true)

grpPlayerPerf:AddToggle({
    Title   = "Boost FPS",
    Content = "One-color world, no shadows/fx, transparent PlayerGui, 120 FPS cap",
    Default = false,
    Callback = function(v)
        S.fpsBoost = v
        if v then applyFpsBoost() else restoreFpsBoost() end
        Notify("FPS", v and "Boost ON" or "Boost OFF")
    end,
})

grpPlayerPerf:AddButton({
    Title   = "Apply FPS Boost Now",
    Content = "Run the boost immediately",
    Callback = function()
        applyFpsBoost()
        Notify("FPS", "Boost applied")
    end,
})

grpPlayerPerf:AddSubSection("Hide & Anti-Lag Visuals")

grpPlayerPerf:AddToggle({
    Title   = "Hide All Pets (Max FPS)",
    Content = "Hides rendered pet models in base (heaviest load - anti-lag)",
    Default = false,
    Callback = function(v)
        S.hideAllPets = v
        _hide.setHideAllPets(v)
    end,
})

grpPlayerPerf:AddToggle({
    Title   = "Hide Owner Eggs Placed",
    Content = "Hides your own placed eggs on your plot",
    Default = false,
    Callback = function(v)
        S.hideOwnerEggs = v
        _hide.setHideOwnerEggs(v)
    end,
})

grpPlayerPerf:AddToggle({
    Title   = "Hide Other Eggs Placed",
    Content = "Hides other players' placed eggs from your client",
    Default = false,
    Callback = function(v)
        S.hideOtherEggs = v
        _hide.setHideOtherEggs(v)
    end,
})

grpPlayerPerf:AddToggle({
    Title   = "Hide All Placed Eggs",
    Content = "Hides all placed eggs across all plots for a clean base",
    Default = false,
    Callback = function(v)
        S.hideAllEggs = v
        _hide.setHideAllEggs(v)
    end,
})

grpPlayerPerf:AddToggle({
    Title   = "Hide Plot Visuals & Fences",
    Content = "Makes all plot fences, signs, decor invisible",
    Default = false,
    Callback = function(v)
        S.hidePlotVisuals = v
        _hide.setHidePlotVisuals(v)
    end,
})

grpPlayerPerf:AddToggle({
    Title   = "Hide Floating Money Text",
    Content = "Blocks all income popup dollar text (+$$$) from pets",
    Default = false,
    Callback = function(v)
        S.hideMoneyFX = v
        _hide.setHideMoneyFX(v)
    end,
})

grpPlayerPerf:AddButton({
    Title   = "Clean All Visuals Now (Max FPS)",
    Content = "Instantly purge all heavy pet models, eggs, fences, money popups, particles",
    Callback = function()
        _hide.purgeAllVisualsNow()
        Notify("FPS", "All visuals purged!")
    end,
})

grpPlayerPerf:AddSubSection("Fake Ava (Copy Ava)")

-- ============ UI ============
grpPlayerPerf:AddInput({
    Title = "Username / ID",
    Content = "Ketik username atau UserID target",
    Placeholder = "Contoh: @username atau 123456789",
    Finished = true,
    Callback = function(v) CopyAva.UsernameInput = v end
})

local CopyAvaPlayerDropRef = grpPlayerPerf:AddDropdown({
    Title = "Player Online",
    Content = "Pilih player yang sedang online",
    Options = GetCopyAvaOnlinePlayers(),
    Callback = function(opt)
        if opt and opt ~= "" then
            CopyAva.UsernameInput = opt
        end
    end
})

grpPlayerPerf:AddButton({
    Title = "Apply Avatar",
    Content = "Copy avatar dari username/ID di atas",
    Callback = function()
        if CopyAva.UsernameInput == "" or CopyAva.UsernameInput == nil then
            Notify("CopyAva", "Masukkan username / pilih player dulu!", 3)
            return
        end
        ApplyAvatar(CopyAva.UsernameInput)
    end
})

grpPlayerPerf:AddButton({
    Title = "Random Avatar",
    Content = "Copy avatar random",
    Callback = function()
        ApplyAvatar(COPYAVA_RANDOM_IDS[math.random(1, #COPYAVA_RANDOM_IDS)])
    end
})

grpPlayerPerf:AddButton({
    Title = "Reset Avatar",
    Content = "Kembalikan ke avatar original kamu",
    Callback = function()
        CopyAva.CurrentAvatar = nil
        if CopyAva.RespawnConn then
            CopyAva.RespawnConn:Disconnect()
            CopyAva.RespawnConn = nil
        end
        task.spawn(function()
            local ok = ApplyFakeAvaAppearance(CopyAva.OriginalId)
            Notify("CopyAva", ok and "Avatar direset" or "Gagal reset avatar", 3)
        end)
    end
})

grpPlayerPerf:AddSubSection("Favorites")

local CopyAvaFavDropRef = grpPlayerPerf:AddDropdown({
    Title = "Select Favorite",
    Content = "Pilih avatar favorit",
    Options = GetCopyAvaFavOptions(),
    Callback = function(opt)
        if opt and opt ~= "" then CopyAva.SelectedFav = opt end
    end
})

grpPlayerPerf:AddButton({
    Title = "Add to Favorites",
    Content = "Simpan avatar sekarang ke favorites",
    Callback = function()
        if not CopyAva.CurrentAvatar then
            Notify("CopyAva", "Belum ada avatar yang di-apply!", 3)
            return
        end
        for _, v in ipairs(CopyAva.Favorites) do
            if tonumber(v.id) == tonumber(CopyAva.CurrentAvatar.id) then
                Notify("CopyAva", "Sudah ada di favorite", 3)
                return
            end
        end
        table.insert(CopyAva.Favorites, {
            id = CopyAva.CurrentAvatar.id,
            name = CopyAva.CurrentAvatar.name
        })
        SaveCopyAvaFavorites()
        if CopyAvaFavDropRef then CopyAvaFavDropRef:SetValues(GetCopyAvaFavOptions()) end
        Notify("CopyAva", "Ditambahkan ke favorite", 3)
    end
})

grpPlayerPerf:AddButton({
    Title = "Load Favorite",
    Content = "Apply avatar dari favorite terpilih",
    Callback = function()
        if not CopyAva.SelectedFav then
            Notify("CopyAva", "Pilih favorite dulu!", 3)
            return
        end
        for _, fav in ipairs(CopyAva.Favorites) do
            local display = tostring(fav.name or "?") .. " (" .. tostring(fav.id) .. ")"
            if display == CopyAva.SelectedFav then
                ApplyAvatar(fav.id)
                return
            end
        end
        Notify("CopyAva", "Favorite tidak ditemukan", 3)
    end
})

grpPlayerPerf:AddButton({
    Title = "Delete Favorite",
    Content = "Hapus favorite terpilih",
    Callback = function()
        if not CopyAva.SelectedFav then
            Notify("CopyAva", "Pilih favorite dulu!", 3)
            return
        end
        for i, fav in ipairs(CopyAva.Favorites) do
            local display = tostring(fav.name or "?") .. " (" .. tostring(fav.id) .. ")"
            if display == CopyAva.SelectedFav then
                table.remove(CopyAva.Favorites, i)
                break
            end
        end
        SaveCopyAvaFavorites()
        CopyAva.SelectedFav = nil
        if CopyAvaFavDropRef then CopyAvaFavDropRef:SetValues(GetCopyAvaFavOptions()) end
        Notify("CopyAva", "Favorite dihapus", 3)
    end
})

-- ============ AUTO REFRESH PLAYER LIST (tiap 5 detik) ============
task.spawn(function()
    while true do
        task.wait(5)
        if CopyAvaPlayerDropRef then
            pcall(function()
                CopyAvaPlayerDropRef:SetValues(GetCopyAvaOnlinePlayers())
            end)
        end
    end
end)

-- MISC TAB
local grpEsp = getSection(MiscTab, "ESP", true)

grpEsp:AddToggle({
    Title   = "Egg Scanner",
    Content = "Panel Egg Scanner (All / Bag / Pen)",
    Default = false,
    Callback = function(v)
        if not SetEggScannerVisible(v) then
            Notify("Scanner", "Belum siap / EggState tidak ketemu", 3)
        end
    end,
})

grpEsp:AddToggle({
    Title   = "Enable Egg ESP",
    Content = "Show ESP on eggs",
    Default = false,
    Callback = function(v) esp.enabled = v; esp.eggs = v end,
})

grpEsp:AddToggle({
    Title   = "Rare Eggs Only",
    Content = "Only show rare eggs",
    Default = false,
    Callback = function(v) esp.rareEggsOnly = v end,
})

grpEsp:AddToggle({
    Title   = "Trap ESP",
    Content = "Show ESP on traps",
    Default = false,
    Callback = function(v) esp.traps = v end,
})

grpEsp:AddToggle({
    Title   = "Player ESP",
    Content = "Show ESP on players",
    Default = false,
    Callback = function(v) esp.players = v end,
})

grpEsp:AddSlider({
    Title     = "Max ESP Distance",
    Content   = "Max distance for ESP display",
    Min       = 50,
    Max       = 2000,
    Default   = 800,
    Increment = 50,
    Callback  = function(v) esp.maxDistance = v end,
})

local grpServer = getSection(MiscTab, "Server", true)

grpServer:AddButton({
    Title   = "Server Hop (Low Pop)",
    Content = "Hop to a low population server",
    Callback = function()
        task.spawn(function()
            Notify("Server Hop", "Searching...", 2)
            local placeId = game.PlaceId
            local currentJobId = game.JobId
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if not req then Notify("Server Hop", "Executor not supported", 3); return end
            local ok, result = pcall(function()
                local url = string.format(
                    "https://games.roblox.com/v1/games/%d/servers/0?sortOrder=Asc&limit=100", placeId)
                local response = req({ Url = url, Method = "GET" })
                return game:GetService("HttpService"):JSONDecode(response.Body)
            end)
            if ok and result and result.data then
                local valid = {}
                for _, server in ipairs(result.data) do
                    if server.id ~= currentJobId and server.playing < server.maxPlayers and server.playing > 0 then
                        table.insert(valid, server)
                    end
                end
                table.sort(valid, function(a, b) return a.playing < b.playing end)
                if #valid > 0 then
                    Notify("Server Hop", "Hopping (" .. valid[1].playing .. " players)", 3)
                    game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, valid[1].id, LP)
                else
                    Notify("Server Hop", "No server found", 3)
                end
            else
                Notify("Server Hop", "Failed to fetch servers", 3)
            end
        end)
    end,
})

local grpScript = getSection(MiscTab, "Script", true)

grpScript:AddButton({
    Title   = "Unload Script",
    Content = "Unload W424 Hub",
    Callback = function()
        if HUB.Unload then pcall(HUB.Unload) end
    end,
})

-- EVENT TAB
local grpRift = getSection(EventTab, "Rift Event", true)

grpRift:AddToggle({
    Title   = "Rift: Auto Farm Pet",
    Content = "Auto farm rift pet trade",
    Default = false,
    Callback = function(v) Rift.autoFarm = v; Notify("Rift", v and "ON" or "OFF") end,
})

grpRift:AddToggle({
    Title   = "Rift: Prioritize Steal",
    Content = "Prioritize stealing over rift",
    Default = true,
    Callback = function(v) Rift.prioritizeSteal = v end,
})

grpRift:AddButton({
    Title   = "Rift: Trade Now",
    Content = "Run one rift trade cycle",
    Callback = function()
        task.spawn(function()
            local ok, msg = Rift.RunCycle()
            Notify("Rift", ok and "Traded!" or tostring(msg))
        end)
    end,
})

grpRift:AddButton({
    Title   = "Rift: Check Status",
    Content = "Check rift requirements",
    Callback = function()
        task.spawn(function()
            local st = Rift.GetState()
            if st then
                local reqs = st.Requirements or {}
                Notify("Rift", "Requirements: " .. tostring(#reqs))
            else
                Notify("Rift", "No state / not in event")
            end
        end)
    end,
})

-- CONFIG TAB (Save / Load / Autoload)
local ConfigFolder = "W424_SAE_Config/"
local AutoloadFile = ConfigFolder .. "Autoload.txt"

if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

function CollectUIValues()
    return {
        _version          = "1.0",
        farmEnabled       = farmEnabled,
        farmDelay         = farmDelay,
        farmSpeed         = farmSpeed,
        moveMethod        = moveMethod,
        targetRarities    = targetRarities,
        targetAreas       = targetAreas,
        targetMutations   = targetMutations,
        selectedAreaTp    = selectedAreaTp,
        S                 = S,
        esp               = {
            enabled = esp.enabled, eggs = esp.eggs, traps = esp.traps,
            players = esp.players, rareEggsOnly = esp.rareEggsOnly,
            maxDistance = esp.maxDistance,
        },
    }
end

function ApplyConfigToUI(data)
    if not data then return end
    farmEnabled    = data.farmEnabled or false
    farmDelay      = data.farmDelay or 1.5
    farmSpeed      = data.farmSpeed or 750
    moveMethod     = data.moveMethod or "Tween Glide"
    targetRarities = data.targetRarities or {}
    targetAreas    = data.targetAreas or {}
    targetMutations = data.targetMutations or {}
    selectedAreaTp = data.selectedAreaTp or "Forest"
    if type(data.S) == "table" then
        for k, v in pairs(data.S) do S[k] = v end
    end
    if type(data.esp) == "table" then
        for k, v in pairs(data.esp) do esp[k] = v end
    end
end

function SaveConfigToFile(name)
    if not name or name == "" then Notify("Config", "Nama config kosong!", 2); return false end
    local data = CollectUIValues()
    local ok, json = pcall(function() return game:GetService("HttpService"):JSONEncode(data) end)
    if not ok then Notify("Config", "Encode failed", 2); return false end
    writefile(ConfigFolder .. name .. ".json", json)
    Notify("Config", "Saved: " .. name, 2)
    return true
end

function LoadConfigFromFile(name)
    if not name or name == "" then Notify("Config", "Nama config kosong!", 2); return false end
    local path = ConfigFolder .. name .. ".json"
    if not isfile(path) then Notify("Config", "Tidak ada: " .. name, 2); return false end
    local ok, data = pcall(function()
        local content = readfile(path)
        return game:GetService("HttpService"):JSONDecode(content)
    end)
    if not ok or type(data) ~= "table" then Notify("Config", "JSON invalid", 2); return false end
    ApplyConfigToUI(data)
    Notify("Config", "Loaded: " .. name, 2)
    return true
end

function GetConfigList()
    local list = {}
    if isfolder(ConfigFolder) then
        for _, v in ipairs(listfiles(ConfigFolder)) do
            if v:sub(-5) == ".json" then
                local name = v:match("([^/\\]+)$"):gsub(".json", "")
                table.insert(list, name)
            end
        end
    end
    return list
end

local SelectedConfig = ""
local CurrentLoaded  = "None"
local AutoloadConfig = isfile(AutoloadFile) and readfile(AutoloadFile) or "None"

local grpCfg = getSection(ConfigTab, "Config Manager", true)

local StatusPara = grpCfg:AddParagraph({
    Title   = "Config Status",
    Content = "Current: " .. CurrentLoaded .. " | Autoload: " .. AutoloadConfig,
})

function UpdateStatus()
    pcall(function()
        StatusPara:SetContent("Current: " .. CurrentLoaded .. " | Autoload: " .. AutoloadConfig)
    end)
end

grpCfg:AddInput({
    Title = "Config Name", Content = "Nama config baru",
    Placeholder = "my_config", Finished = true,
    Callback = function(v) SelectedConfig = v end,
})

local CfgDropdown = grpCfg:AddDropdown({
    Title = "Select Config", Content = "Pilih config yang sudah ada",
    Options = GetConfigList(),
    Callback = function(opt) SelectedConfig = opt end,
})

grpCfg:AddButton({
    Title = "Save Config", Content = "Simpan config dengan nama di atas",
    Callback = function()
        if SaveConfigToFile(SelectedConfig) then
            CfgDropdown:SetValues(GetConfigList())
        end
    end,
    SubTitle = "Load Config",
    SubCallback = function()
        if LoadConfigFromFile(SelectedConfig) then
            CurrentLoaded = SelectedConfig
            UpdateStatus()
        end
    end,
})

grpCfg:AddButton({
    Title = "Delete Config", Content = "Hapus config terpilih",
    Callback = function()
        local path = ConfigFolder .. SelectedConfig .. ".json"
        if isfile(path) then
            delfile(path)
            CfgDropdown:SetValues(GetConfigList())
            Notify("Config", "Deleted: " .. SelectedConfig, 2)
        else Notify("Config", "Tidak ditemukan", 2) end
    end,
    SubTitle = "Set Autoload",
    SubCallback = function()
        if SelectedConfig and SelectedConfig ~= "" then
            AutoloadConfig = SelectedConfig
            writefile(AutoloadFile, AutoloadConfig)
            UpdateStatus()
            Notify("Config", "Autoload = " .. SelectedConfig, 2)
        else Notify("Config", "Pilih config dulu", 2) end
    end,
})

grpCfg:AddButton({
    Title = "Refresh List", Content = "Refresh daftar config",
    Callback = function() CfgDropdown:SetValues(GetConfigList()) end,
    SubTitle = "Clear Autoload",
    SubCallback = function()
        AutoloadConfig = "None"
        if isfile(AutoloadFile) then delfile(AutoloadFile) end
        UpdateStatus()
        Notify("Config", "Autoload cleared", 2)
    end,
})

-- Auto-load autoload
if AutoloadConfig ~= "None" then
    task.spawn(function()
        task.wait(1)
        if LoadConfigFromFile(AutoloadConfig) then
            CurrentLoaded = AutoloadConfig
            UpdateStatus()
        end
    end)
end

-- INIT
task.spawn(function()
    task.wait(2)
    pcall(function() SetNoKnockback(true) end)
end)

-- Anti-AFK default OFF (dikontrol UI)

Notify("W424 Hub", "Loaded successfully!", 3)
print("[W424 Hub] Loaded!")
