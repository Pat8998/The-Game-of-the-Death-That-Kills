-- The Game of the Death That Kills
-- Made by Patrick_8998

local Button = require("libs.buttons")
local Draw = require("libs.draw")
local InGame = require("libs.ingame")
local Walls = require("libs.walls")
local Player = require("libs.players")
local Multiplayer = require("libs.multiplayer")
local Client = require("libs.client")
local Weapons = require("libs.weapons")
local TouchScreen = require("libs.touchscreen")
local Gamemodes = require("libs.Gamemodes")
local CollisionHandler = require("libs.collisionhandler")
local Textures =  require('libs.textures')
local enet = require "enet"  --put it in global to call it from libraries ???
local utf8 = require("utf8")
local json = require("libs.external.lunajson")
local mouse ={x=0, y=0, lb=false, rb=false, mb=false}
local fps
local WallsHeight = 3
local Map = {walls = {list = {}}}
-- local Entities = {}
local Game = {
    Gamemodes = Gamemodes,
    DelayedCallbacks = {},  -- Table to hold delayed callbacks
    UI = {
        crosshair = Textures.crosshairTexture,  -- Crosshair texture
        crosshairSize = 1,  -- Size of the crosshair
    },
    InHostedGame = false,
    InClientGame = false,
    IsPaused = true,
    IsLoading = false,
    IsPublic = false,
    IsConnectedToHost = false,
    IsSplitscreen = true,
    InMM = false, --For now pause menu is main menu but it'll change
    IsJoining = 0,
    Server = {
        ipaddr = "localhost:6878",
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
    TouchScreen = TouchScreen,
    Buttons = {},  -- Buttons table to hold all buttons
    Entities = {},
    Players = {
        list = {},
        number = 1
    },
}
Gamemodes.Game = Game  -- Assign the Game table to Gamemodes
CollisionHandler.Game = Game  -- Assign the Game table to CollisionHandler
-- local Players = {
--     list = {},
--     number = 1
-- }
local Channels = {
    InputCommuncicationChannel = nil,
    OutputCommuncicationChannel = nil,
    GameChannel = nil
}
local LocalPlayer = Game.Players.list[0]
--canvas is great
--color mask for color



-- initialization
function love.load()
    do
        local desktopWidth, desktopHeight = math.max(love.window.getDesktopDimensions()), math.min(love.window.getDesktopDimensions()) 
        love.window.setMode(desktopWidth, desktopHeight, {fullscreen = false})
    end
    love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
    love.graphics.print("Loading...")
    Textures.load()  -- Load textures
    Game.IsMobile = love.system.getOS() == 'Android' or love.system.getOS() == 'iOS'
    Game.Buttons.PauseMenu = Button.PauseMenu(Game, InGame, Game.Players, Entities, Player, Map, Walls, Multiplayer)  -- Initialize buttons

    
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
	world:setCallbacks(CollisionHandler.beginContact, CollisionHandler.endContact, CollisionHandler.preSolve, CollisionHandler.postSolve)

    InGame.CreateLocalGame({
        world = world,
        Game = Game,
        Players = Game.Players,
        Entities = Entities,
        Player = Player,
        Map = Map
    })
    LocalPlayer = Game.Players.list[1]-- Create the local player and the walls

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
    if Game.IsMobile then
        LocalPlayer.weapon = Weapons.list.Rifle  -- Set the default weapon for mobile
        Game.IsSplitscreen = false  -- Disable splitscreen button on mobile
        love.window.setMode(1920, 1080, {fullscreen = true})
        Game.Buttons.MobileButtons = Button.MobileButtons(Game, LocalPlayer, Entities)  -- Initialize mobile buttons
    end
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
            players = Game.Players,                -- player table
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
            Players = Game.Players,
            Client = Client
        })
    else
        Game.IsPaused = true
    end
end









function love.draw()
    if (Game.InHostedGame or Game.InClientGame and not Game.IsPaused) and ( Game.InClientGame or not Game.IsSplitscreen) then
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
            Players = Game.Players
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
            Players = Game.Players
        })
    elseif Game.IsLoading then
        Draw.LoadingScreen(Game)
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
                Players = Game.Players
           })
        end)
            -- Draw the blurred canvas to the screen
---@diagnostic disable-next-line: undefined-field
        love.graphics.setShader(Textures.Shaders.blurShader)  -- Set the shader for the canvas
        love.graphics.draw(BGCanvas, 0, 0)
        love.graphics.setShader()  -- Reset the shader
        love.graphics.setCanvas()
        Draw:Menu(Game.Buttons.PauseMenu)
    end
end

function love.joystickadded( joystick )
    print("Joystick added: " .. joystick:getName(), joystick:getID())
    if joystick:isGamepad() then
        if joystick:getID() == 1 and Game.IsMobile then --To do tests put 1
            LocalPlayer.joystick = joystick  -- Assign the joystick to the local player
        else
            local assigned = {}
            for _, v in ipairs(Game.Players.list) do
                assigned[v.number] = true
            end
            local new_number = 1
            while assigned[new_number] do
                new_number = new_number + 1
            end
            Game.Players.list[new_number] = Player.createPlayer(new_number, world, nil, joystick)  -- Create a new player with the joystick
            -- joystick.Player = Game.Players.list[new_number]  -- Assign the player to the joystick
            -- print(joystick.Player.joystick.Player.joystick)
            Game.Buttons.PauseMenu.SplitScreen.isActive = true  -- Enable the splitscreen button
        end
    end
end
function love.joystickremoved( joystick )
    print("Joystick removed: " .. joystick:getName(), joystick:getID())
    for i, player in ipairs(Game.Players.list) do
        if player.joystick == joystick and player.number == LocalPlayer.number then
            player:destroy()  -- Destroy the player associated with the joystick
            table.remove(Game.Players.list, i)  -- Remove the player from the list
            break
        end
    end
end


function love.keypressed(key, scan)
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
        if Game.IsLoading then 
            Game.IsJoining = 0
            Game.IsLoading = false
            Game.InClientGame = false
            Game.IsPaused = true
        else
            Game.IsPaused = not Game.IsPaused
            love.mouse.setGrabbed(not Game.IsPaused)
            love.mouse.setVisible(Game.IsPaused)
        end
        love.system.vibrate(0.01)    
    elseif scan == "return" or key == 'kpenter' then
        Game.IsJoining = 1
        if Game.Server.ipaddr == "" then
            Game.Server.ipaddr = 'localhost:6969'
        end
    elseif key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(Game.Server.ipaddr, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            Game.Server.ipaddr = string.sub(Game.Server.ipaddr, 1, byteoffset - 1)
        end
    end
    if key == "g" then
        LocalPlayer.Glide = not LocalPlayer.Glide
    end
    if key == "kp+" then
        local assigned = {}
        for _, v in ipairs(Game.Players.list) do
            assigned[v.number] = true
        end
        local new_number = 1
        while assigned[new_number] do
            new_number = new_number + 1
        end
        Game.Players.list[new_number] = Player.createPlayer(new_number, world)
        Game.Buttons.PauseMenu.SplitScreen.isActive = true  -- Enable the splitscreen button
    elseif key == 'kp-' then
        table.remove(Game.Players.list, #Game.Players.list)  -- Remove the player from the list
    elseif key == 'kp*' then
        LocalPlayer.Health = LocalPlayer.Health + 1
    elseif key == 'kp/' then
        LocalPlayer.Health = LocalPlayer.Health - 1
    elseif key == "kp0" then
        Gamemodes.reset(Game, Game.Players)
    end
    if key == 'r' then
        LocalPlayer.magazine[LocalPlayer.weapon.name] = 0 
        if Game.InHostedGame then
            Game.Weapons.Shoot(LocalPlayer, Entities, LocalPlayer.weapon)  -- Shoot with the current weapon
        elseif Game.InClientGame then
            Client.Shoot({name = 'Reload'}, Game, LocalPlayer)  -- This wont work I think best is to createe a reload weapon
        end
    end
    Game.Debug = scan
end

function love.textinput(text)
    if Game.IsLoading then
        Game.Server.ipaddr = Game.Server.ipaddr .. text  -- Append the text to the IP address
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        Weapons.nextWeapon(LocalPlayer)
    else
        Weapons.previousWeapon(LocalPlayer)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    local screen_width, screen_height = love.graphics.getDimensions()
        Game.TouchScreen.Touches[id] = {
        sx = x,
        sy = y,
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        pressure = pressure,  -- Default pressure value
        IsLeftJoy = x < screen_width / 2 and y > screen_height/2
    }
end

function love.touchmoved( id, x, y, dx, dy, pressure )
    Game.TouchScreen.Touches[id].x = x
    Game.TouchScreen.Touches[id].y = y
    Game.TouchScreen.Touches[id].dx = dx
    Game.TouchScreen.Touches[id].dy = dy
    Game.TouchScreen.Touches[id].pressure = pressure
end

function love.touchreleased(id , x, y, dx , dy , pressure )
    Game.TouchScreen.Touches[id] = nil  -- Remove the touch data when released
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
        Entities.list[body].fixture:destroy()  -- Destroy the fixture
        Entities.list[body].body:destroy()  -- Destroy the body
        Entities.list[body] = nil           -- Remove the object from the table
    end
end

