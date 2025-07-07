local Weapons = require "libs.weapons"
local Player = {}

function Player.createPlayer(number, world, peer)  --define xy angle but like im lazy
    player = {
        number = number,
        peer = peer or "local",
        x = 90,
        y = 204,
        angle = -32*math.pi/180 ,
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
        weapon = Weapons.list.Default,  -- Default weapon
    }
    player.body = love.physics.newBody(world,player.x,player.y,"dynamic")
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    player.fixture:setUserData("player")
    player.fixture:setCategory(player.number)     --I KNOW I WILL REGRET IT
    player.fixture:setMask(player.number)
    
    function player:destroy()
        if self.body then
            self.body:destroy()
        end
        self = nil
    end
    return player
end




return Player