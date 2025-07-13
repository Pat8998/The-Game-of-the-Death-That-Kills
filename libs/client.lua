local Client = {}
local json = require("libs.external.lunajson")

function Client.Shoot(weapon, Game)
    weapon = weapon or "default"  -- Default to "pistol" if no type is provided
    local data = ({
        type = "shoot",
        weapon = weapon
    })
    Game.Server.peer:send(json.encode(data), Game.enetChannels.ActionChannel)
end

function Client.Move(dir, player, Game)
    local data = ({
        type = "move",
        dir = dir,
        speed = player.moveSpeed,
        angle = player.angle,
        isZooming = player.isZooming,
    })
    -- print("Sending move data to server: " .. dir .. " " .. speed)
    Game.Server.peer:send(json.encode(data), Game.enetChannels.ActionChannel)
    -- Game.Server.peer:send("caca", 3) -- This is a hack to force the server to send the player data

end

return Client