--TO DO :
-- make the bullets look realistic
-- and do things when they collide walls
-- and add multiplayer

--BIG PROBLEM : HOW TO KNOW WETHER YOU DRAW WALLS OR ENTITIES ?
-- CREATE A TO DRAW TABLE SORTED? WiTH AN IF THAT GETS THE BODY TYPE
--enet channel 2 for connect

local Button = require("libs.buttons")
local Draw = require("libs.draw")
local InGame = require("libs.ingame")
local Walls = require("libs.walls")
local Player = require("libs.players")
local Multiplayer = require("libs.multiplayer")
local Client = require("libs.client")
local Weapons = require("libs.weapons")
local enet = require "enet"  --put it in global to call it from libraries ???
local json = require("libs.external.lunajson")
local mouse ={x=0, y=0, lb=false, rb=false, mb=false}
local fps
local WallsHeight = 2
local test = "nil"
local data = {}
local Map = {walls = {list = {}}}
local Entities = {}
local Game = {
    InHostedGame = false,
    InClientGame = false,
    IsPaused = true,
    IsLoading = false,
    IsPublic = false,
    IsConnectedToHost = false,
    InMM = false, --For now pause menu is main menu but it'll change
    IsJoining = 0,
    Server = {
        ipaddr = "localhost:6789",
        host = nil,
        peer = nil,  --peer is the connection to the host
        ReceiveTimeout = 100, --time to wait for the host to respond
    }   ,        --might have to move it somewhere else because Cannot send it th threads
    Clients = {},
    IsMajorFrame = false, -- If the game is in a major frame (update what neeed ds to be updated)
    Debug = "debug",
    enetChannels = {
        NumberChannel = 0,
        EntityChannel = 1,
        WallsChannel = 2,
        ActionChannel = 3,

        amount = 4,  -- Number of channels used in the game
    },       -- If I ever add another channel (for chat or smth) I have to up the number of channels in the connect (multiplayer.lua line 13)
--     Shoot = function (dt, player, speed, Bullet_type)
--         local body = love.physics.newBody(world, player.x, player.y, "dynamic")
--         local fixture = love.physics.newFixture(body, Entities.defaultShapes.bullet, 1)
--         local angle = player.angle + math.random(-200, 200)*0.0001
--         fixture:setUserData("bullet")
--         fixture:setMask(player.number)
--         fixture:setCategory(player.number)
--         body:setBullet(true)
--         body:applyLinearImpulse(math.cos(angle) *speed , math.sin(angle) *speed)
--         Entities.list[body] = {body = body, fixture = fixture, angle = player.angle, player = player, life = 2}
-- end,
    Weapons = Weapons,  -- Weapons module
    Buttons = {},  -- Buttons table to hold all buttons

}
local Players = {
    list = {},
    number = 2
}
local Channels = {
    InputCommuncicationChannel = nil,
    OutputCommuncicationChannel = nil,
    GameChannel = nil
}
local LocalPlayer = Players.list[0]
local Buttons = {}
local Textures = {
    wallTexture = love.graphics.newImage("assets/wall.png"),
    -- playerTexture = love.graphics.newImage("assets/player.png"),
    -- bulletTexture = love.graphics.newImage("assets/bullet.png"),
    -- crosshairTexture = love.graphics.newImage("assets/crosshair.png"),
    ayakakaTexture = love.graphics.newImage("assets/ayakaka.png")
}
--canvas is great
--color mask for color



-- initialization
function love.load()
    love.window.setTitle("Title")
    love.window.setFullscreen(true)
    love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), {fullscreen = false})
    love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
    local screen_width, screen_height = love.graphics.getWidth(), love.graphics.getHeight()
    Game.Buttons = {
        Quit = Button:new(screen_width/2 -100, 200, 200, 50, "Quit", function()
            love.event.quit()
        end),
        StartGame = Button:new(screen_width/2 -100, 300, 200, 50, "Start game ❤!", function()
            print("Game Started !")
            Game.InHostedGame = true
            Game.IsPaused = false
        end),
        GenerateWalls = Button:new(screen_width/2 -100, 400, 200, 50, "Generate Walls", function()
            Walls:clear(Map.walls.list)   -- Clear the walls list
            Map.walls.list = Walls:generate(20)
        end),
        JoinGame = Button:new(screen_width/2 -100, 500, 200, 50, "Join Game", function ()
        Game.IsLoading = true
        --Game.Server.ipaddr = "localhost:6789"
        --Game.IsJoining = 1
        end),
        SetPublic =  Button:new(screen_width/2 -100, 600, 200, 50, "SetPublic", function ()
            Game.IsPublic = true
            -- love.thread.newThread(string.dump(Multiplayer.StartServer)):start(Game)
            --ABOVE LINE IF ANY LAG IS CAUSED WITHOUT THE THREAD
            Game.Server.host = Multiplayer.StartServer("*:6969", Game.enetChannels.amount)
            Game.Buttons.SetPublic.isActive = false
            Game.Buttons.StopServer.isActive = true
        end),
        StopServer = Button:new(screen_width/2 -100, 700, 200, 50, "StopServer", function ()
            Game.IsPublic = false
            -- love.thread.getChannel("MultplayerThread"):push(Game)
            --ABOVE LINES IF ANY LAG IS CAUSED WITHOUT THE THREAD
            Game.Server.host = Game.Server.host:destroy()
            print("Server stopped")
            Game.Buttons.SetPublic.isActive = true
            Game.Buttons.StopServer.isActive = false
        end, {isActive = false}),
        ClientResume = Button:new(screen_width/2 -100, 300, 200, 50, "Resume", function ()
            Game.IsPaused = false
        end, {isActive = false}),
        ClientDisconnect = Button:new(screen_width/2 -100, 500, 200, 50, "Disconnect", function ()
            Game.Server.peer:disconnect()
            repeat
                print("Waiting for disconnection...", Game.Server.peer:state())
                Game.Server.host:service(100)  -- Ensure all messages are sent
            until Game.Server.peer:state() == "disconnected"
            InGame.CreateLocalGame({
                world = world,
                Game = Game,
                Players = Players,
                Entities = Entities,
                Player = Player,
                Map = Map
            })
            LocalPlayer = Players.list[1]-- Create the local player and the walls
            Game.InClientGame = false
            Game.Buttons.ClientResume.isActive = false
            Game.Buttons.ClientDisconnect.isActive = false
            Game.Buttons.StartGame.isActive = true
            Game.Buttons.JoinGame.x = love.graphics.getWidth()/2 +110            -- ACTUALLY IT MAKES YOU CLICK ON JOIN  without
            Game.Buttons.JoinGame.isActive = true
            Game.Buttons.SetPublic.isActive = true
            Game.Buttons.StopServer.isActive = false

        end, {isActive = false}),


    }

    
    InGameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    blurShader = love.graphics.newShader[[
        extern number blurSize;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec4 sum = vec4(0.0);
            sum += Texel(texture, texture_coords + vec2(-blurSize, -blurSize)) * 0.05;
            sum += Texel(texture, texture_coords + vec2( 0.0,    -blurSize)) * 0.09;
            sum += Texel(texture, texture_coords + vec2( blurSize, -blurSize)) * 0.05;
            sum += Texel(texture, texture_coords + vec2(-blurSize,  0.0))    * 0.09;
            sum += Texel(texture, texture_coords)                          * 0.62;
            sum += Texel(texture, texture_coords + vec2( blurSize,  0.0))    * 0.09;
            sum += Texel(texture, texture_coords + vec2(-blurSize,  blurSize)) * 0.05;
            sum += Texel(texture, texture_coords + vec2( 0.0,     blurSize)) * 0.09;
            sum += Texel(texture, texture_coords + vec2( blurSize,  blurSize)) * 0.05;
            return sum * color;
        }
    ]]
    blurShader:send("blurSize", 1.0 / 100.0)




    Entities = {defaultShapes = {
        point = love.physics.newEdgeShape(0, 0, 0, 0),
        bullet = love.physics.newCircleShape(1)
    }, list = {}}


    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    InGame.CreateLocalGame({
        world = world,
        Game = Game,
        Players = Players,
        Entities = Entities,
        Player = Player,
        Map = Map
    })
    LocalPlayer = Players.list[1]-- Create the local player and the walls


    -- Channels.InputCommuncicationChannel = love.thread.getChannel("InputServerThread")
    -- Channels.OutputCommuncicationChannel = love.thread.getChannel("OutputServerThread")
    -- Channels.GameChannel = love.thread.getChannel("GameServerThread")
end



function love.update(dt)
    fps=1/dt
    -- fps = love.timer.getFPS()
    Game.IsMajorFrame = IsMajorFrame()  -- Check if it's a major frame
    local dmouse = {x=love.mouse.getPosition()-mouse.x, y= love.mouse.getPosition()-mouse.y}
    mouse.x, mouse.y = love.mouse.getPosition()
    mouse.lb, mouse.rb, mouse.mb = love.mouse.isDown(1),love.mouse.isDown(2),love.mouse.isDown(3)
    if Game.IsPaused then
        Game.InHostedGame = false
        if Game.IsLoading then
            -- Multiplayer.ThreadChannel = Multiplayer.ThreadChannel or love.thread.getChannel("MultplayerThread")
            InGame.UpdateWhileLoading({
                game = Game,
                enet = enet,
                localplayer = LocalPlayer,
            })
        else
            InGame.UpdateMenu(dt, Game, mouse)
        end
    elseif not Game.InClientGame and not Game.InMM then
        Game.InHostedGame = true
    end
    if Game.InHostedGame then
        InGame.updateHost({
            dt = dt,
            players = Players,                -- player table
            localplayer = LocalPlayer,
            dmouse = dmouse,                -- dmouse table (must contain dmouse.x)
            mouse = mouse,                  -- mouse table (must contain x, y, lb, etc.)
            world = world,                  -- physics world
            Entities = Entities,            -- Entities table with Entities.list
            DestroyEntity = DestroyEntity,   -- function to destroy an entity
            Multiplayer = Multiplayer,
            Game = Game,
            Channels = Channels,
            Player = Player,
            Map = Map
        })
    -- Channels.GameChannel:push(Game)     -- USELESS
        --if caca= dz then
            --send client info
        --end
    elseif Game.InClientGame then
        InGame.updateClient({
            dt = dt,
            dmouse = dmouse,                -- dmouse table (must contain dmouse.x)
            mouse = mouse,                  -- mouse table (must contain x, y, lb, etc.)
            Multiplayer = Multiplayer,
            Game = Game,
            Entities = Entities,
            localplayer = LocalPlayer,
            Map = Map,
            json = json,
            Players = Players,
            Client = Client
        })
    else
        Game.IsPaused = true
    end
end









function love.draw()
    local large_sreen_width = 2*math.pi*love.graphics.getWidth()/LocalPlayer.fov
    if Game.InHostedGame or Game.InClientGame and not Game.IsPaused then
        Draw.InGame({
            Textures = Textures,                     -- your textures table
            player = LocalPlayer,                         -- your player table
            fps = fps,                               -- your current FPS value
            Game = Game,                           -- your debug text/variable
            Walls = Map.walls.list,                           -- your walls table
            screen_width = love.graphics.getWidth(),
            screen_height = love.graphics.getHeight(),
            large_sreen_width = large_sreen_width,   -- your large screen width variable
            WallsHeight = WallsHeight,               -- your WallsHeight variable
            Entities = Entities,                      -- your entities table
            Players = Players
   })
    elseif Game.IsLoading then
        Draw.LoadingScreen()
    else    --MM for now I guess
        love.graphics.setCanvas(InGameCanvas)  -- Set the canvas as the target
        love.graphics.clear(0, 0, 0, 0)    -- Clear it (transparent)
        love.graphics.setCanvas()            -- Reset to the default screen
        InGameCanvas:renderTo(function ()
            Draw.InGame({
                Textures = Textures,  -- your textures table
                player = LocalPlayer,                         -- your player table
                fps = fps,                               -- your current FPS value
                Game = Game,                           -- your debug text/variable
                Walls = Map.walls.list,                           -- your walls table
                screen_width = love.graphics.getWidth(),
                screen_height = love.graphics.getHeight(),
                large_sreen_width = large_sreen_width,   -- your large screen width variable
                WallsHeight = WallsHeight,               -- your WallsHeight variable
                Entities = Entities,                      -- your entities table
                Players = Players
           })
        end)
            -- Draw the blurred canvas to the screen
        love.graphics.setShader(blurShader)
        love.graphics.draw(InGameCanvas, 0, 0)
        love.graphics.setShader()  -- Reset shader for further drawing
        Draw:Menu(Game.Buttons)
    end
end




function love.keypressed(key)
    if key == "end" then
        love.window.close()
    end
    if key == "c" then
        love.mouse.setCursor(love.mouse.newCursor("assets.ayakaka.png", 0, 0))
    end
    if key == "lalt" then
        love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
    if key == "escape" then
        Game.IsPaused = not Game.IsPaused
        love.mouse.setGrabbed(not Game.IsPaused)
        love.mouse.setVisible(Game.IsPaused)
    end
    if key == "g" then
        LocalPlayer.Glide = not LocalPlayer.Glide
    end
    if key == "kp+" then
        LocalPlayer.Health = LocalPlayer.Health + 1
    elseif key == 'kp-' then
        LocalPlayer.Health = LocalPlayer.Health - 1
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        Weapons.nextWeapon(LocalPlayer)
    else
        Weapons.previousWeapon(LocalPlayer)
    end
end






function love.filedropped(file )
    local content = file:read() -- Read the entire contents of the file
    if Game.IsLoading then
            Game.IsJoining = 1
            Game.Server.ipaddr = content
    end
end

function IsMajorFrame()
    -- return false
    return math.fmod(math.random(1, 60), 60) == 0
end



function DestroyEntity(entity)
    if entity ~= nil then
        local body = entity.body
        Entities.list[body].body:destroy()  -- Destroy the body
        Entities.list[body] = nil           -- Remove the object from the table
    end
end

function beginContact(a, b, coll)
    -- print ("colliding" , a:getUserData() , "with" , b:getUserData())
    Debug ="colliding" .. a:getUserData() .. "with" .. b:getUserData()
    -- Get userdata of the colliding objects
    local userdataA = a:getUserData()
    local userdataB = b:getUserData()

    local bullet, other
    -- If one object is "deletable" and the other is not a "player"
    if userdataA == "bullet" or userdataB == "bullet" then
        if userdataA == "bullet" then
            bullet = a
            other = b
        else
            bullet = b
            other = a
        end
        if other:getUserData() == "player" or other:getUserData() == "mob" then
            --ADD THZE PLAYER HEALTHE SYSTEM LOLLL
            for key, value in pairs(Players.list) do
                if value.fixture == other then
                    value.Health = value.Health - 10
                    break
                end
                -- print(value.fixture, other)
            end
        elseif other:getUserData():match("^wall") then
            --idk put an effect on the wall or smth
        end
        DestroyEntity(Entities.list[bullet:getBody()])
    end
end


-- function JoinGame()
--     local ThreadScrpit = string.dump(Multiplayer.Thread)
--     local MultplayerThread = love.thread.newThread(ThreadScrpit)
--     MultplayerThread:start()
--     Multiplayer.ThreadChannel = love.thread.getChannel("MultplayerThread")
-- end


















function endContact(a, b, coll)
    -- print("End Contact")
end

function preSolve(a, b, coll)
    -- print("Pre Solve Contact")
end

function postSolve(a, b, coll, normalImpulse1, tangentImpulse1, normalImpulse2, tangentImpulse2)
    -- print("Post Solve Contact")
end
--RATHER THAN ADJUSTING THE ANGLES
--HOW ABOUT I ADJUST SCREEN POSITIONNING
--SO WHEN ITS LIKE OVER 360 * width /FOV = large_sreen_width
-- IT IS RATHER just over 0
-- for both coordinates
-- See ya