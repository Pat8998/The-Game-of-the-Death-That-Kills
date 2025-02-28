--TO DO :
-- make the bullets look realistic
-- and do things when they collide walls
-- and add multiplayer

--BIG PROBLEM : HOW TO KNOW WETHER YOU DRAW WALLS OR ENTITIES ?
-- CREATE A TO DRAW TABLE SORTED? WiTH AN IF THAT GETS THE BODY TYPE


local Button = require("buttons")
local Draw = require("draw")
local InGame = require("ingame")
local Walls = require("walls")
local Player = require("players")
local enet = require "enet"  --put it in global to call it from libraries ???
local Clients = {}          -- useless ??
local mouse ={x=0, y=0, lb=false, rb=false, mb=false}
local fps
local WallsHeight = 2
local test = "nil"
local data = {}
local Map = {walls = {list = {}}}
local Entities = {}
local Debug = "Debug"
local Game = {
    InHostedGame = false,
    InClientGame = false,
    IsPaused = true,
    Isloading = false,
    IsConnectedToHost = false,
    InMM = false --For now pause menu is main menu but it'll change
}
local Players = {
    list = {},
    number = 2
}
local LocalPlayer = Players.list[0]
local BackgroundImage = love.graphics.newImage('ayakaka.png')
local Buttons = {}

--canvas is great
--color mask for color



-- initialization
function love.load()
    love.window.setTitle("Title")
    love.window.setMode(1920, 1080, {fullscreen = false})
    love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
    local screen_width, screen_height = love.graphics.getWidth(), love.graphics.getHeight()
    print("hey")
    Buttons = {
        myButton = Button:new(screen_width/2  -100, 200, 200, 50, "Click Me!"),
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
            JoinGame()
        end),
        SetPublic =  Button:new(screen_width/2 -100, 600, 200, 50, "SetPublic", function ()
            SetPublic()
        end)
    }
    print("hey*2")
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

    

    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    Entities = {defaultShapes = {
        point = love.physics.newEdgeShape(0, 0, 0, 0),
        bullet = love.physics.newCircleShape(1)
    }, list = {}}

    Map.walls.list = Walls.default
    for key, Wall in pairs(Map.walls.list) do
        Wall.body = love.physics.newBody(world, Wall.pos[1][1], Wall.pos[1][2], "static")        -- Create the body at the first point of the wall
        -- Adjust the shape coordinates relative to the body's position
        local x1, y1 = 0, 0  -- Relative to Wall.body's position (Wall.pos[1])
        local x2, y2 = Wall.pos[2][1] - Wall.pos[1][1], Wall.pos[2][2] - Wall.pos[1][2]
        -- Create the shape with corrected coordinates
        Wall.shape = love.physics.newEdgeShape(x1, y1, x2, y2)
        -- Attach the shape to the body
        Wall.fixture = love.physics.newFixture(Wall.body, Wall.shape, 1)
        Wall.fixture:setUserData("wall" .. key)
        Wall.fixture:setCategory(16)
    end

    -- for players = palyers.number
    for i = 1, Players.number do
        table.insert(Players.list, Player.createPlayer(i, world))
        -- Players.list[i]s [Players.list[i].number] = Players.list[i]
    end
    LocalPlayer = Players.list[1]
    print(LocalPlayer)
end



function love.update(dt)
    fps=1/dt
    local dmouse = {x=love.mouse.getPosition()-mouse.x, y= love.mouse.getPosition()-mouse.y}
    mouse.x, mouse.y = love.mouse.getPosition()
    mouse.lb, mouse.rb, mouse.mb = love.mouse.isDown(1),love.mouse.isDown(2),love.mouse.isDown(3)
    if Game.IsPaused then
        Game.InHostedGame = false
        UpdateMenu(dt)
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
            Shoot = Shoot,                  -- Shoot function
            Entities = Entities,            -- Entities table with Entities.list
            DestroyEntity = DestroyEntity   -- function to destroy an entity
        
        })
        --if caca= dz then
            --send client info
        --end
    elseif Game.InClientGame then
        -- get the info idk how
        InGame.updateClient(

        )
    else
        Game.IsPaused = true
    end
    Debug = "Game is paused : " .. tostring(Game.IsPaused)
end


function UpdateMenu(dt)
    for key, button in pairs(Buttons) do
        button:update(mouse.x, mouse.y, mouse.lb)
    end
end







function love.draw()
    local screen_width = love.graphics.getWidth()
    local large_sreen_width = 2*math.pi*screen_width/LocalPlayer.fov
    local screen_height = love.graphics.getHeight()
    if Game.InHostedGame or Game.InClientGame then
        Draw.InGame({
            player = LocalPlayer,                         -- your player table
            fps = fps,                               -- your current FPS value
            Debug = Debug,                           -- your debug text/variable
            Walls = Map.walls.list,                           -- your walls table
            screen_width = love.graphics.getWidth(),
            screen_height = love.graphics.getHeight(),
            large_sreen_width = large_sreen_width,   -- your large screen width variable
            WallsHeight = WallsHeight,               -- your WallsHeight variable
            Entities = Entities,                      -- your entities table
            Players = Players
   })
    elseif Game.Isloading then
        Draw.LoadingScreen()
    else
        love.graphics.setCanvas(InGameCanvas)  -- Set the canvas as the target
        love.graphics.clear(0, 0, 0, 0)    -- Clear it (transparent)
        love.graphics.setCanvas()            -- Reset to the default screen
        InGameCanvas:renderTo(function ()
            Draw.InGame({
                player = LocalPlayer,                         -- your player table
                fps = fps,                               -- your current FPS value
                Debug = Debug,                           -- your debug text/variable
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
        Draw:Menu(Buttons)
    end
end




function love.keypressed(key)
    if key == "end" then
        love.window.close()
    end
    if key == "c" then
        love.mouse.setCursor(love.mouse.newCursor("ayakaka.png", 0, 0))
    end
    if key == "lalt" then
        love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
    if key == "escape" then
        Game.IsPaused = not Game.IsPaused
        love.mouse.setGrabbed(not Game.IsPaused)
        love.mouse.setVisible(Game.IsPaused)
    end
end







function love.filedropped(file )
    local content = file:read() -- Read the entire contents of the file

    -- Parse the contents of the file as needed
    -- For example, print the contents to the console
    print(content)
end


function Shoot(dt, player, speed, Bullet_type)
    local body = love.physics.newBody(world, player.x, player.y, "dynamic")
    local fixture = love.physics.newFixture(body, Entities.defaultShapes.bullet, 1)
    local angle = player.angle + math.random(-200, 200)*0.0001
    fixture:setUserData("bullet")
    fixture:setMask(player.number)
    fixture:setCategory(player.number)
    body:setBullet(true)
    body:applyLinearImpulse(math.cos(angle) *speed , math.sin(angle) *speed)
    Entities.list[body] = {body = body, fixture = fixture, angle = player.angle, player = player, life = 2}
end

function DestroyEntity(entity)
    print(entity)
    if entity ~= nil then 
        local body = entity.body
        Entities.list[body].body:destroy()  -- Destroy the body
        Entities.list[body] = nil           -- Remove the object from the table
    end
end

function beginContact(a, b, coll)
    print ("colliding" , a:getUserData() , "with" , b:getUserData())
    Debug ="colliding" .. a:getUserData() .. "with" .. b:getUserData()
    -- Get userdata of the colliding objects
    local userdataA = a:getUserData()
    local userdataB = b:getUserData()

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
        elseif other:getUserData():match("^wall") then
            --idk put an effect on the wall or smth
        end
        DestroyEntity(Entities.list[bullet:getBody()])
    end
end


function JoinGame() --actually have to thread it
    Game.IsLoading = true
    local ipaddr = nil
    while not ipaddr do
        local name, file = love.event.wait()
        if name == "filedropped" then
            ipaddr = file:read() -- Read the entire contents of the file
            print("got file")
        end
    end
    local host = enet.host_create()
    local server = host:connect(ipaddr)
    while not Game.IsConnectedToHost do
        local event = host:service(1000)
        if event then
            print("got event")
            if event.type == "connect" then
                print("Successfully connected to", ipaddr)
                Game.IsConnectedToHost = true
            end
        end
    end
    while Game.IsLoading do
        local event = host:service(100)
        if event then
            if event.type == "receive" then
                print("Received message", event.data)
                -- LocalPlayer.number = event.data --actually might be sent every frame? ACTUALLY NO BC I SEND TO ALL PEERS
                Game.IsLoading = false
            end
        end
    end
    --LocalPlayer = Players.list[key]
end


function SetPublic()
    local host = enet.host_create("localhost:6789")
    --setup a thread which does things right when somebody tries to connect
end















function endContact(a, b, coll)
    -- print("End Contact")
end

function preSolve(a, b, coll)
    -- print("Pre Solve Contact")
end

function postSolve(a, b, coll, normalImpulse1, tangentImpulse1, normalImpulse2, tangentImpulse2)
    -- print("Post Solve Contact")
end
-- function endContact(a, b, coll)
-- 	Persisting = 0
-- 	local textA = a:getUserData()
-- 	local textB = b:getUserData()
-- -- Update the Text to indicate that the objects are no longer colliding
-- 	Text = Text.."\n 3.)" .. textA.." uncolliding with "..textB
-- 	love.window.setTitle ("Persisting: "..Persisting)
-- end

-- function preSolve(a, b, coll)
-- 	if Persisting == 1 then
-- 	local textA = a:getUserData()
-- 	local textB = b:getUserData()
-- -- If this is the first update where the objects are touching, add a message to the Text
-- 		Text = Text.."\n 2.)" .. textA.." touching "..textB..": "..Persisting
-- 	elseif Persisting <= 10 then
-- -- If the objects have been touching for less than 20 updates, add a count to the Text
-- 		Text = Text.." "..Persisting
-- 	end
	
-- -- Update the Persisting counter to keep track of how many updates the objects have been touching
-- 	Persisting = Persisting + 1
-- 	love.window.setTitle ("Persisting: "..Persisting)
-- end

-- function postSolve(a, b, coll, normalimpulse, tangentimpulse)
-- -- This function is empty, no actions are performed after the collision resolution
-- -- It can be used to gather additional information or perform post-collision calculations if needed
-- end

--RATHER THAN ADJUSTING THE ANGLES
--HOW ABOUT I ADJUST SCREEN POSITIONNING
--SO WHEN ITS LIKE OVER 360 * width /FOV = large_sreen_width
-- IT IS RATHER just over 0
-- for both coordinates
-- See ya