--TO DO :
-- make the bullets look realistic
-- and do things when they collide walls
-- and add multiplayer

--enet channel 2 for connect

local Button = require("libs.buttons")
local Draw = require("libs.draw")
local InGame = require("libs.ingame")
local Walls = require("libs.walls")
local Player = require("libs.players")
local Multiplayer = require("libs.multiplayer")
local Client = require("libs.client")
local Weapons = require("libs.weapons")
local Textures = function () return require('libs.textures') end
local enet = require "enet"  --put it in global to call it from libraries ???
local json = require("libs.external.lunajson")
local mouse ={x=0, y=0, lb=false, rb=false, mb=false}
local fps
local WallsHeight = 3
local test = "nil"
local data = {}
local Map = {walls = {list = {}}}
local Entities = {}
local Game = {
    DelayedCallbacks = {},  -- Table to hold delayed callbacks
    UI = {
        crosshair = Textures().crosshairTexture,  -- Crosshair texture
        crosshairSize = 1,  -- Size of the crosshair
    },
    InHostedGame = false,
    InClientGame = false,
    IsPaused = true,
    IsLoading = false,
    IsPublic = false,
    IsConnectedToHost = false,
    IsSplitscreen = false,
    InMM = false, --For now pause menu is main menu but it'll change
    IsJoining = 0,
    Server = {
        ipaddr = "localhost:6789",
        host = nil,
        peer = nil,  --peer is the connection to the host
        ReceiveTimeout = 100, --time to wait for the host to respond
    }   ,        --might have to move it somewhere else because Cannot send it th threads
    Clients = {},
    IsMajorFrame = false, -- If the game is in a major frame (update what neeed to be updated)
    SplitscreenPos = {},
    Debug = "debug",
    enetChannels = {
        NumberChannel = 0,
        EntityChannel = 1,
        WallsChannel = 2,
        ActionChannel = 3,

        amount = 4,  -- Number of channels used in the game
    },       -- If I ever add another channel (for chat or smth) I have to up the number of channels in the connect (multiplayer.lua line 13)
    Weapons = Weapons,  -- Weapons module
    Buttons = {},  -- Buttons table to hold all buttons

}
local Players = {
    list = {},
    number = 1
}
local Channels = {
    InputCommuncicationChannel = nil,
    OutputCommuncicationChannel = nil,
    GameChannel = nil
}
local LocalPlayer = Players.list[0]
local Buttons = {}
--canvas is great
--color mask for color



-- initialization
function love.load()
    do
        local desktopWidth, desktopHeight = love.window.getDesktopDimensions() 
        love.window.setMode(desktopWidth, desktopHeight, {fullscreen = false})
    end
    love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
    local screen_width, screen_height = love.graphics.getWidth(), love.graphics.getHeight()
---@diagnostic disable-next-line: cast-local-type
    Textures = Textures()
    Game.Buttons = {
        Quit = Button:new(screen_width/2 -100, 200, 200, 50, "Quit", function()
            love.event.quit()
        end),
        StartGame = Button:new(screen_width/2 -100, 300, 200, 50, "Start game ❤!", function()
            print("Game Started !")
            Game.InHostedGame = true
            Game.IsPaused = false
        end),
        SplitScreen = Button:new(screen_width/2 -320, 350, 200, 50, "SplitScreen", function()
            Game.IsSplitscreen = not Game.IsSplitscreen
            if Game.IsSplitscreen then
                Game.Buttons.SplitScreen.text = "SingleScreen"
                Game.Buttons.SplitScreen.x = love.graphics.getWidth()/2 + 120
            else
                Game.Buttons.SplitScreen.text = "SplitScreen"
                Game.Buttons.SplitScreen.x = love.graphics.getWidth()/2 - 320
            end
        end),
        GenerateWalls = Button:new(screen_width/2 -100, 400, 200, 50, "Generate Walls", function()
            Walls:clear(Map.walls.list)   -- Clear the walls list
            Map.walls.list = Walls:generate(56, 10, 2)
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
                                                                                ---@diagnostic disable-next-line: undefined-field
            Game.Server.peer:disconnect()
            repeat
                                                                                ---@diagnostic disable-next-line: undefined-field
                print("Waiting for disconnection...", Game.Server.peer:state())
                Game.Server.host:service(100)  -- Ensure all messages are sent
                                                                                ---@diagnostic disable-next-line: undefined-field
            until Game.Server.peer:state() == "disconnected"
            InGame.CreateLocalGame({
                world = world,
                Game = Game,
                Players = Players,
                Entities = Entities,
                Player = Player,
                Map = Map
            })
            LocalPlayer = Players.list[1]
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
    BGCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    Textures.Shaders.blurShader:send("blurSize", 1.0 / 100.0)




    Entities = {defaultShapes = {
        point = love.physics.newEdgeShape(0, 0, 0, 0),
        bullet = love.physics.newCircleShape(0.01)
        -- bullet = love.physics.newEdgeShape(0, 0, 10, 0)  --IDK Crashes PHYSICS
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

    Game.SplitscreenPos = {
        {{x = 0, y = 0 , width = love.graphics.getWidth(), height = love.graphics.getHeight()}}, --I mean there is no need to draw spitscreen if you're alone
        {
            {x = 0, y = 0, width = love.graphics.getWidth()/2, height = love.graphics.getHeight()},  -- Left side
            {x = love.graphics.getWidth()/2, y = 0, width = love.graphics.getWidth()/2, height = love.graphics.getHeight()}  -- Right side
        },
        {
            {x = 0, y = 0, width = love.graphics.getWidth()/2, height = love.graphics.getHeight()/2},  -- Top side - right
            {x = love.graphics.getWidth()/2, y = 0, width = love.graphics.getWidth()/2, height = love.graphics.getHeight()/2},  -- Top side - left
            {x = 0, y = love.graphics.getHeight()/2, width = love.graphics.getWidth(), height = love.graphics.getHeight()/2}  -- Bottom side
        },
        {
            {x = 0, y = 0, width = love.graphics.getWidth()/2, height = love.graphics.getHeight()/2},  -- Top left
            {x = love.graphics.getWidth()/2, y = 0, width = love.graphics.getWidth()/2, height = love.graphics.getHeight()/2},  -- Top right
            {x = 0, y = love.graphics.getHeight()/2, width = love.graphics.getWidth()/2, height = love.graphics.getHeight()/2},  -- Bottom left
            {x = love.graphics.getWidth()/2, y = love.graphics.getHeight()/2, width = love.graphics.getWidth()/2, height = love.graphics.getHeight()/2}  -- Bottom right
        }

    }
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
    if (Game.InHostedGame or Game.InClientGame and not Game.IsPaused) and not Game.IsSplitscreen then
        Draw.InGame({
            Textures = Textures,                     -- your textures table
            player = LocalPlayer,                         -- your player table
            fps = fps,                               -- your current FPS value
            Game = Game,                           -- your debug text/variable
            Walls = Map.walls.list,                           -- your walls table
            screen_width = love.graphics.getWidth(),
            screen_height = love.graphics.getHeight(),
            WallsHeight = WallsHeight,               -- your WallsHeight variable
            Entities = Entities,                      -- your entities table
            Players = Players
   })
    elseif Game.IsSplitscreen and not Game.IsPaused then     
        Draw.InGameSplitscreen({
            Textures = Textures,  -- your textures table
            player = LocalPlayer,                         -- your player table
            fps = fps,                               -- your current FPS value
            Game = Game,                           -- your debug text/variable
            Walls = Map.walls.list,                           -- your walls table
            screen_width = love.graphics.getWidth(),
            screen_height = love.graphics.getHeight(),
            WallsHeight = WallsHeight,               -- your WallsHeight variable
            Entities = Entities,                      -- your entities table
            Players = Players
        })
    elseif Game.IsLoading then
        Draw.LoadingScreen()
    else    --MM for now I guess
        love.graphics.setCanvas(BGCanvas)  -- Set the canvas as the target
        love.graphics.clear(0, 0, 0, 0)    -- Clear it (transparent)
        love.graphics.setCanvas()            -- Reset to the default screen
        BGCanvas:renderTo(function ()
            Draw.InGame({
                Textures = Textures,  -- your textures table
                player = LocalPlayer,                         -- your player table
                fps = fps,                               -- your current FPS value
                Game = Game,                           -- your debug text/variable
                Walls = Map.walls.list,                           -- your walls table
                screen_width = love.graphics.getWidth(),
                screen_height = love.graphics.getHeight(),
                WallsHeight = WallsHeight,               -- your WallsHeight variable
                Entities = Entities,                      -- your entities table
                Players = Players
           })
        end)
            -- Draw the blurred canvas to the screen
        love.graphics.setShader(Textures.Shaders.blurShader)  -- Set the shader for the canvas
        love.graphics.draw(BGCanvas, 0, 0)
        love.graphics.setShader()  -- Reset the shader
        love.graphics.setCanvas()
        Draw:Menu(Game.Buttons)
    end
end

function love.joystickadded( joystick )
    print("Joystick added: " .. joystick:getName(), joystick:getID())
    if joystick:isGamepad() then
        if joystick:getID() == 0 then --To do tests put 1
            LocalPlayer.joystick = joystick  -- Assign the joystick to the local player
        else
            local assigned = {}
            for _, v in ipairs(Players.list) do
                assigned[v.number] = true
            end
            local new_number = 1
            while assigned[new_number] do
                new_number = new_number + 1
            end
            Players.list[new_number] = Player.createPlayer(new_number, world, nil, joystick)  -- Create a new player with the joystick
            -- joystick.Player = Players.list[new_number]  -- Assign the player to the joystick
            -- print(joystick.Player.joystick.Player.joystick)
        end
    end
end
function love.joystickremoved( joystick )
    print("Joystick removed: " .. joystick:getName(), joystick:getID())
    for i, player in ipairs(Players.list) do
        if player.joystick == joystick then
            player:destroy()  -- Destroy the player associated with the joystick
            table.remove(Players.list, i)  -- Remove the player from the list
            break
        end
    end
end


function love.keypressed(key)
    if key == "end" then
            love.event.quit()
    end 
    if key == "c" then
                            ---@diagnostic disable-next-line: undefined-field
        if Game.UI.crosshair == Textures.crosshairTexture then
            Game.UI.crosshair = "internal"
            love.mouse.setCursor(love.mouse.getSystemCursor("sizeall"))
        else
            love.mouse.setCursor(love.mouse.newCursor("assets/ayakaka.png", 10, 10))
                            ---@diagnostic disable-next-line: undefined-field
            Game.UI.crosshair = Textures.crosshairTexture
        end
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
        local assigned = {}
        for _, v in ipairs(Players.list) do
            assigned[v.number] = true
        end
        local new_number = 1
        while assigned[new_number] do
            new_number = new_number + 1
        end
        Players.list[new_number] = Player.createPlayer(new_number, world)
    elseif key == 'kp-' then
        table.remove(Players.list, #Players.list)  -- Remove the player from the list
    elseif key == 'kp*' then
        LocalPlayer.Health = LocalPlayer.Health + 1
    elseif key == 'kp/' then
        LocalPlayer.Health = LocalPlayer.Health - 1
    end
    if key == 'r' then
        LocalPlayer.magazine[LocalPlayer.weapon.name] = 0 
        if Game.InHostedGame then
            Game.Weapons.Shoot(LocalPlayer, Entities, LocalPlayer.weapon)  -- Shoot with the current weapon
        elseif Game.InClientGame then
            Client.Shoot({name = 'Reload'}, Game, LocalPlayer)  -- This wont work I think best is to createe a reload weapon
        end
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
                    value.Health = value.Health - (Entities.list[bullet:getBody()] or LocalPlayer).weapon.damage
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

--BIG PROBLEM : HOW TO KNOW WETHER YOU DRAW WALLS OR ENTITIES ?
-- CREATE A TO DRAW TABLE SORTED? WiTH AN IF THAT GETS THE BODY TYPE