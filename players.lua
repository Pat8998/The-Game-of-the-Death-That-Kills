local Player = {}

function Player.createPlayer(number, world)  --define xy angle but like im lazy
    player = {
        number = number,
        x = 90,
        y = 204,
        angle = -32*math.pi/180 ,
        fov = math.pi/2,
        mx = 0,
        my = 0,
        ScaleFactor = 1,
        InPauseMenu = false,
        shape = love.physics.newCircleShape(2),
    }
    player.body = love.physics.newBody(world,player.x,player.y,"dynamic")
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    player.fixture:setUserData("player")
    player.fixture:setCategory(player.number)     --I KNOW I WILL REGRET IT
    player.fixture:setMask(player.number)
    return player
end





return Player