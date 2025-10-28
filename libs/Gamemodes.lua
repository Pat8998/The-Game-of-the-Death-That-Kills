local Gamemodes = {}

Gamemodes.Game = {}

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

function Gamemodes.OnPlayerHit(params)
    local hit = params.hit
    local shooter = params.shooter
    local weapon = params.weapon
    local damage = weapon and weapon.damage or shooter.weapon.damage or 1
    hit.Health = hit.Health - damage
    if hit.Health <= 0 and not hit.isDead then
        hit.isDead = true
        table.insert(Gamemodes.Game.DelayedCallbacks,
        {
            t = love.timer.getTime() + 1,
            callback = function()
                hit.Health = hit.maxHealth
                hit.body:setPosition(0, 150)
                hit.body:setLinearVelocity(0, 0)
                hit.body:setAngularVelocity(26)
                hit.isDead = false
            end
        })
        hit.Score = math.max(0, hit.Score - hit.maxHealth/10)
        shooter.Score = shooter.Score + hit.maxHealth/2 + (math.min(damage, hit.Health + damage))/2
    else if not hit.isDead then
        
        -- Optional: feedback for non-lethal hits
        shooter.Score = shooter.Score + damage/2
    end
    end
end

function Gamemodes.reset(Game, Players)
    for _, p in pairs(Players.list) do
        p.body:setPosition(-10, 50 - p.number * 50)
        p.body:setLinearVelocity(0, 0)
        p.Health = p.maxHealth
        p.Score = 0
    end
end

return Gamemodes