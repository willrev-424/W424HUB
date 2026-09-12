local games = {
    [6739698191] = "https://raw.githubusercontent.com/willrev-424/W424HUB/refs/heads/main/W424_VD.lua",         -- Violence District Universe

    [121864768012064] = "https://raw.githubusercontent.com/willrev-424/W424HUB/refs/heads/main/W424_FishIt.lua",
    [93978595733734] = "https://raw.githubusercontent.com/willrev-424/W424HUB/refs/heads/main/W424_VD.lua",
    [16732694052] = "https://raw.githubusercontent.com/willrev-424/W424HUB/refs/heads/main/W424_Fisch.lua",
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
