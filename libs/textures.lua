local Textures = {}

function Textures.load()
        Textures.wallTexture = love.graphics.newImage("assets/wall.png")
        -- playerTexture = love.graphics.newImage("assets/player.png"),
        -- bulletTexture = love.graphics.newImage("assets/bullet.png"),
        Textures.crosshairTexture = love.graphics.newImage("assets/crosshair.png")
        Textures.ayakakaTexture = love.graphics.newImage("assets/ayakaka.png")
        Textures.deathTexture = love.graphics.newImage("assets/death.png")
        Textures.floorTexture = love.graphics.newImage("assets/floor.png")
        Textures.player = {
            default = love.graphics.newImage("assets/croc_def.jpg"),
            aimed  = love.graphics.newImage("assets/croc_mc.jpg")
        }
        Textures.weapons = {
            Default = {
                normal = love.graphics.newImage("assets/rifle_n.png"),
                aimed  = love.graphics.newImage("assets/rifle_a.png")
            },
            Shotgun = {
                normal = love.graphics.newImage("assets/shotgun_n.png"),
                aimed  = love.graphics.newImage("assets/shotgun_a.png")
            },
            LongRifle = {
                normal = love.graphics.newImage("assets/longrifle_n.png"),
                aimed  = love.graphics.newImage("assets/longrifle_a.png")
            },
        }
    for key, value in pairs(Textures) do
        print("Loaded texture: " .. key, value)
    end
    Textures.floorTexture:setWrap("repeat", "repeat")
    Textures.Shaders = {
        floorShader = love.graphics.newShader("libs/shaders/floor.glsl"),
        blurShader = love.graphics.newShader("libs/shaders/blur.glsl"),
    }
end

return Textures