local games = {
    [93978595733734] = "https://raw.githubusercontent.com/willrev-424/W424HUB/refs/heads/main/W424Hub_VD.lua",
    [119259569670784] = "https://raw.githubusercontent.com/willrev-424/W424HUB/refs/heads/main/W424Hub_SNA.lua",
}

local currentPlaceID = game.PlaceId
local currentUniverseID = game.GameId

local scriptURL = games[currentUniverseID] or games[currentPlaceID]

if scriptURL then
    print("W424: Loading script for ID " .. (games[currentUniverseID] and "Universe" or "Place"))
    loadstring(game:HttpGet(scriptURL))()
else
    local msg = "\nMap not supported yet!\nPlaceId: " .. tostring(currentPlaceID) .. "\nUniverseId: " .. tostring(currentUniverseID)
    game.Players.LocalPlayer:Kick(msg)
    print(msg)
end