local Player = {}

function Player.createPlayer(number, world)
    player = { x = 90, y = 204, angle = -32*math.pi/180 , fov = math.pi/2, shape = love.physics.newCircleShape(2), mx = 0, my = 0, number = number, InPauseMenu = false}
    player.body = love.physics.newBody(world,player.x,player.y,"dynamic")
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    player.fixture:setUserData("player")
    player.fixture:setCategory(player.number)     --I KNOW I WILL REGRET IT
    player.fixture:setMask(player.number)
    return player
end





return Player