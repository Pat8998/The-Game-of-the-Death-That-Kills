local Weapons = require "libs.weapons"
local Player = {}

function Player.createPlayer(number, world, peer, joystick)  --define xy angle but like im lazy
    local localplayer = {
        number = number,
        peer = peer or "local",
        joystick = joystick ,  -- Joystick object if available
        sensivity = 1, deadzone = 0.01,
        x = 90 
        + number * 50 --PUT THAT BACK , HERE FOR TESTING PURPOSES
        ,y = 204,
        angle = -32*math.pi/180 ,
        pitch = 0,
        height = 1.6,
        fov = math.pi/2,
        mx = 0,
        my = 0,
        dir = 0,
        ScaleFactor = 1,
        InPauseMenu = false,
        Glide = false,
        moveSpeed = 0,
        shape = love.physics.newCircleShape(2),
        Health = 100,
        maxHealth = 100,
        NextShoot = 0.1,
        NextWeaponSwitch = 0.1,  -- may regroup in player.timers table
        -- weapon = Weapons.list.Ball,
        weapon = Weapons.list.Default,  -- Default weapon
        magazine = {},
        Score = 0,
        oldMov = false,
    }
    localplayer.body = love.physics.newBody(world,localplayer.x,localplayer.y,"dynamic")
    localplayer.fixture = love.physics.newFixture(localplayer.body, localplayer.shape, 1)
    localplayer.fixture:setUserData("player")
    localplayer.fixture:setCategory(localplayer.number)     --I KNOW I WILL REGRET IT
    localplayer.fixture:setMask(localplayer.number)
    
    for k, weapon in pairs(Weapons.list) do
        localplayer.magazine[weapon.name] = weapon.maxmagazine or 10  -- Initialize magazine for each weapon
    end

    function localplayer:destroy()
        if self.body then
            self.body:destroy()
        end
        self = nil
    end
    return localplayer
end




return Player