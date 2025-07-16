local Textures = {}

Textures = {
    wallTexture = love.graphics.newImage("assets/wall.png"),
    -- playerTexture = love.graphics.newImage("assets/player.png"),
    -- bulletTexture = love.graphics.newImage("assets/bullet.png"),
    crosshairTexture = love.graphics.newImage("assets/crosshair.png"),
    ayakakaTexture = love.graphics.newImage("assets/ayakaka.png"),
    weapons = {
        Default = {
            normal = love.graphics.newImage("assets/rifle_n.png"),
            aimed  = love.graphics.newImage("assets/rifle_a.png")
        },
        Shotgun = {
            normal = love.graphics.newImage("assets/shotgun_n.png"),
            aimed  = love.graphics.newImage("assets/shotgun_a.png")
        },
        Rifle = {
            normal = love.graphics.newImage("assets/longrifle_n.png"),
            aimed  = love.graphics.newImage("assets/longrifle_a.png")
        },

    }
}


return Textures