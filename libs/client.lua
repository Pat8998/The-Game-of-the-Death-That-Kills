local Client = {}
local json = require("libs.external.lunajson")

function Client.Shoot(weapon, Game, LocalPlayer)
    local data = ({
        type = "shoot",
        weapon = weapon
    })
    -- if love.timer.getTime() > LocalPlayer.NextShoot then
    --     Game.Server.peer:send(json.encode(data), Game.enetChannels.ActionChannel)
    --     weapon = weapon or LocalPlayer.weapon or Game.Weapons.list.Default  -- Use specified weapon or default if not specified
    --     LocalPlayer.magazine[weapon.name] = LocalPlayer.magazine[weapon.name] - 1  -- Decrease magazine count
    --     LocalPlayer.NextShoot = love.timer.getTime() + (weapon.shootDelay or 0.5)  -- Recharge time
    --     if LocalPlayer.magazine[weapon.name] == 0 or weapon.name == "Reload" then
    --         LocalPlayer.magazine[weapon.name] = LocalPlayer.weapon.maxmagazine or 5  -- Reset magazine to max if not specified
    --         LocalPlayer.NextShoot = love.timer.getTime() + (weapon.rechargetime or 0.5)  -- Recharge time
    --         print(weapon.rechargetime)
    --     end
    -- end
end

function Client.Move(dir, player, Game)
    local data = ({
        type = "move",
        dir = dir,
        speed = player.moveSpeed,
        angle = player.angle,
        isZooming = player.isZooming,
        weapon = player.weapon.name
    })
    -- print("Sending move data to server: " .. dir .. " " .. speed)
    Game.Server.peer:send(json.encode(data), Game.enetChannels.ActionChannel)
    -- Game.Server.peer:send("caca", 3) -- This is a hack to force the server to send the player data
    
end

return Client