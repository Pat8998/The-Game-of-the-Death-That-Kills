local Gamemodes = {}

Gamemodes.list = { --IDEAS IDNOT KNOW REALLLY
    Deathmatch = {
        name = "Deathmatch",
        maxPlayers = 8,
        respawnTime = 3,  -- Time in seconds before a player respawns
    },
    TeamDeathmatch = {
        name = "TeamDeathmatch",
        maxPlayers = 16,
        respawnTime = 5,
        teams = 2,  -- Number of teams
    },
    CaptureTheFlag = {
        name = "CaptureTheFlag",
        maxPlayers = 16,
        respawnTime = 5,
        teams = 2,
        flagRespawnTime = 10,  -- Time in seconds before a flag respawns
    }
}


function Gamemodes.reset(Game, Players)
    for _, p in pairs(Players.list) do
        p.body:setPosition(-10, 50 - p.number * 50)
        p.body:setLinearVelocity(0, 0)
        p.Health = p.maxHealth
        p.Score = 0
    end
end

return Gamemodes