local scoreHandler = {}
scoreHandler.Events = {
    PlayerHit = 0,
    PlayerKilled = 1
}

function scoreHandler.Handle(params)
    local event = params.event
    local weapon = params.weapon
    if event == scoreHandler.Events.PlayerHit then
        local shooter = params.shooter
        local victim = params.victim
        if shooter and victim and shooter ~= victim and not victim.isDead then
            shooter.Score = math.floor(shooter.Score + (weapon or shooter.weapon).damage / 2)  -- Award 10 points for a hit
                -- print("Player " .. shooter.number .. " scored a hit on Player " .. victim.number .. ". New score: " .. shooter.Score)
            if victim.Health <= 0 then
                params.event = scoreHandler.Events.PlayerKilled
                scoreHandler.Handle(params)
                victim.isDead =true
            end
        end
    elseif event == scoreHandler.Events.PlayerKilled then
        local shooter = params.shooter
        local victim = params.victim
        if shooter and victim and shooter ~= victim and not victim.isDead then
            shooter.Score = math.floor(shooter.Score + victim.maxHealth /2)  -- Award 100 points for a kill
            victim.Score = math.max(0, victim.Score - victim.maxHealth /10)  -- Deduct 50 points from the victim
            -- print("Player " .. shooter.number .. " killed Player " .. victim.number .. ". New score: " .. shooter.Score)
        end
    end
end

return scoreHandler