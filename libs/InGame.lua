local InGame = {}


function InGame.UpdateMenu(dt, Game, mouse)
    for key, button in pairs(Game.Buttons) do
        button:update(mouse.x, mouse.y, mouse.lb)
    end
end

function InGame.updateHost(params)
    -- Extract variables from the params table
    local dt = params.dt
    local players = params.players
    local player = params.localplayer
    local dmouse = params.dmouse
    local mouse = params.mouse
    local world = params.world
    local Entities = params.Entities
    local DestroyEntity = params.DestroyEntity
    local Multiplayer = require("libs.multiplayer")
    local Game = params.Game
    local Channels = params.Channels
    local Player = params.Player
    local Map = params.Map

    -- Update mouse and player angle
    if not love.keyboard.isDown("lalt") and love.window.hasFocus() then
        love.mouse.setGrabbed(true)
        love.mouse.setVisible(false)
        player.angle = player.angle - dt * (dmouse.x) * (player.isZooming and 0.5 or 1)
        if player.angle > 2 * math.pi then
            player.angle = player.angle - 2 * math.pi
        elseif player.angle < -2 * math.pi then  -- Assuming you want to normalize negative angles too
            player.angle = player.angle + 2 * math.pi
        end
        if mouse.x <= 0 then
            love.mouse.setPosition(love.graphics.getWidth(), mouse.y)
        elseif mouse.x >= love.graphics.getWidth() - 1 then
            love.mouse.setPosition(0, mouse.y)
        end
        mouse.x, mouse.y = love.mouse.getPosition()
    else
        love.mouse.setGrabbed(false)
        love.mouse.setVisible(true)
    end

    -- Update movement based on keys pressed

    do
        local movement = love.keyboard.isDown("z") or love.keyboard.isDown("s") or love.keyboard.isDown("d") or love.keyboard.isDown("q")
        if player.isZooming and (movement) then
            player.moveSpeed = 1100
        elseif (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and movement then
                player.moveSpeed = 2 * 2200
            elseif movement then
                player.moveSpeed = 1 * 2200
            elseif not player.Glide then
                player.moveSpeed = 0
        end
        local dir = player.angle
        if love.keyboard.isDown("z") then
            dir = player.angle
            if love.keyboard.isDown("q") then
                dir = dir + math.pi / 4
            elseif love.keyboard.isDown("d") then
                dir = dir - math.pi / 4
            end
        elseif love.keyboard.isDown("s") then
            dir = dir + math.pi
            if love.keyboard.isDown("q") then
                dir = dir - math.pi / 4
            elseif love.keyboard.isDown("d") then
                dir = dir + math.pi / 4
            end
        elseif love.keyboard.isDown("d") then
            dir = dir - math.pi / 2
        elseif love.keyboard.isDown("q") then
            dir = dir + math.pi / 2
        end
        
        player.body:setLinearVelocity(
            math.cos(dir) * player.moveSpeed * dt,
            math.sin(dir) * player.moveSpeed * dt
        )
    end


    if love.mouse.isDown(2) then
        player.fov = math.max(math.pi / 3, player.fov - math.pi / 6 * dt * 4)
        player.ScaleFactor = math.min(3, player.ScaleFactor + dt * 4)
        player.isZooming = true
    else
        player.fov = math.min(math.pi / 2, player.fov + math.pi / 6 * dt * 4)
        player.ScaleFactor = math.max(2, player.ScaleFactor - dt * 4)
        player.isZooming = false
    end

    if mouse.lb then
        Game.Weapons.Shoot(player, Entities)
    end
    
    do
        local coucou = ""
        if Game.InHostedGame then 
            local     x1, y1 = player.body:getPosition()
            local     x2, y2 =  x1 + math.cos(player.angle) * 4000, y1 + math.sin(player.angle) * 3000
            -- x2, y2 = 1,1
                -- world:rayCast(x1, y1, x2, y2,
                -- -- world:rayCast(x2, y2, x1, y1,
                --     function(fixture, hitX, hitY, normalX, normalY, fraction)
                --         coucou ="Hit fixture with userdata:" .. fixture:getUserData() .. "    " ..  fraction  .. "\n"
                --         player.Highlight = fixture:getUserData()
                --         -- print("Hit fixture with userdata: " .. fixture:getUserData() .. " at fraction: " .. fraction)
                --         return 0 -- Stop at the first hit
                --     end
                -- )
        else
            coucou = "Not in hosted game"
        end
        Game.Debug = player.weapon.name .. "\n \n" .. coucou
    end



    --update othe players
    if Game.IsPublic then
        Multiplayer.ServerReceive(dt, players, Channels, Player, Game, Entities)
        for _, p in ipairs(players.list) do
            if p.peer ~= "local" then
                p.body:setLinearVelocity(
                    math.cos(p.dir) * p.moveSpeed * dt,
                    math.sin(p.dir) * p.moveSpeed * dt
                )
            end
        end
    end


    world:update(dt)
    for _, p in ipairs(players.list) do
        p.x, p.y = p.body:getPosition()
        if p.Health <= 0 then
            p.Health = p.maxHealth
            p.body:setPosition(0, 150)
            p.body:setLinearVelocity(0, 0)
            p.body:setAngularVelocity(26)
        end
        -- p.angle = p.body:getAngle()
    end
    for _, e in pairs(Entities.list) do
        e.x, e.y = e.body:getPosition()
        e.angle = e.body:getAngle()
    end

    for key, entity in pairs(Entities.list) do
        if entity.fixture:getUserData() == "bullet" then
            entity.life = entity.life - dt
            --print(entity.life)
            if entity.life <= 0 then
                DestroyEntity(entity)
            end
        end
    end
    if Game.IsPublic then
        Multiplayer.ServerSend(
            Game,
            players.list,
            Entities.list,
            Map.walls.list
        )
    end
end

function InGame.UpdateWhileLoading( params)
    local localPlayer = params.localplayer
    local enet = params.enet
    local Game = params.game



    -- local message = channel:pop()
    --     if message then
    --         if message == "Connected" then
    --             print("Connected to host!")
    --             Game.IsConnectedToHost = true
    --         elseif message == "Loaded" then
    --             print("Loaded!")
    --             Game.IsLoading = false
    --             Game.InClientGame = true
    --         end
    --     end
        -- print("Game.IsJoining: ", Game.IsJoining)


    if love.keyboard.isDown("escape") then
        Game.IsJoining = 0
        Game.IsLoading = false
        Game.InClientGame = false
        Game.IsPaused = true
    elseif love.keyboard.isDown("l") then
        Game.IsJoining = 1
        Game.Server.ipaddr = 'localhost:6969'
    end

    if Game.IsJoining == 1 then
        Game.Server.host = enet.host_create()
        Game.Server.peer = Game.Server.host:connect(Game.Server.ipaddr, Game.enetChannels.amount)  --3 is the number of channels. add more if needed
        print("Connecting to server at " .. Game.Server.ipaddr, "with", Game.enetChannels.amount, "channels")
        Game.IsJoining = 2
    elseif Game.IsJoining == 2 then
        local event = Game.Server.host:service()        -- No delay bc we can wait a frame it's ok
        if event then
            if event.type == "connect" then
                print("Connected to server!")
                Game.IsConnectedToHost = true
                Game.IsJoining = 3
            end
        end
    elseif Game.IsJoining == 3 then        
        local event = Game.Server.host:service()
        if event then
            if event.type == "receive" then
                if event.channel == Game.enetChannels.NumberChannel then
                    print("We are player number", event.data)
                    localPlayer.number = tonumber(event.data) --actually might be sent every frame? ACTUALLY NO BC I SEND TO ALL PEERS
                    Game.IsLoading, Game.InClientGame, Game.IsJoining, Game.IsPaused = false, true, 0, false
                    Game.Buttons.StartGame.isActive = false
                    Game.Buttons.JoinGame.isActive = false
                    Game.Buttons.SetPublic.isActive, Game.Buttons.StopServer.isActive = false, false
                    Game.Buttons.ClientResume.isActive = true
                    Game.Buttons.ClientDisconnect.isActive = true
                else
                    print("error wtf")
                end
            end
        end
    end
end


function InGame.updateClient(params)
    -- Extract variables from the params table
    local dt = params.dt
    local dmouse = params.dmouse
    local mouse = params.mouse
    local Game = params.Game
    local Entities = params.Entities
    local localplayer = params.localplayer
    local Map = params.Map
    local json = params.json
    local Players = params.Players
    local Client = params.Client

    Entities.list = {}


    if not Game.IsPaused then
        -- Update mouse and player angle
        if not love.keyboard.isDown("lalt") and love.window.hasFocus() then
            love.mouse.setGrabbed(true)
            love.mouse.setVisible(false)
            localplayer.angle = localplayer.angle - dmouse.x * dt * (localplayer.isZooming and 0.5 or 1)
            if localplayer.angle > 2 * math.pi then
                localplayer.angle = localplayer.angle - 2 * math.pi
            elseif localplayer.angle < -2 * math.pi then  -- Assuming you want to normalize negative angles too
            localplayer.angle = localplayer.angle + 2 * math.pi
            end
            if mouse.x <= 0 then
                love.mouse.setPosition(love.graphics.getWidth(), mouse.y)
            elseif mouse.x >= love.graphics.getWidth() - 1 then
                love.mouse.setPosition(0, mouse.y)
            end
            mouse.x, mouse.y = love.mouse.getPosition()
        else
                love.mouse.setGrabbed(false)
                love.mouse.setVisible(true)
        end

        do
            local movement = love.keyboard.isDown("z") or love.keyboard.isDown("s") or love.keyboard.isDown("d") or love.keyboard.isDown("q")
            if movement then
                if localplayer.isZooming then
                   localplayer.moveSpeed = 1100
                elseif love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    localplayer.moveSpeed = 4400
                else
                    localplayer.moveSpeed = 2200
                end
            elseif not localplayer.Glide then
                    localplayer.moveSpeed = 0
            end
            local dir = localplayer.angle
            if love.keyboard.isDown("z") and love.keyboard.isDown("q")  then
                dir = dir + math.pi / 4
            elseif love.keyboard.isDown("z") and love.keyboard.isDown("d") then
                dir = dir - math.pi / 4
            elseif love.keyboard.isDown("s") then
                dir = dir + math.pi
                if love.keyboard.isDown("q") then
                    dir = dir - math.pi / 4
                elseif love.keyboard.isDown("d") then
                    dir = dir + math.pi / 4
                end
            elseif love.keyboard.isDown("d") then
                dir = dir - math.pi / 2
            elseif love.keyboard.isDown("q") then
                dir = dir + math.pi / 2
            end
            if mouse.rb then
                localplayer.fov = math.max(math.pi / 3, localplayer.fov - math.pi / 6 * dt * 4)
                localplayer.ScaleFactor = math.min(3, localplayer.ScaleFactor + dt * 4)
                localplayer.isZooming = true
            else
                localplayer.fov = math.min(math.pi / 2, localplayer.fov + math.pi / 6 * dt * 4)
                localplayer.ScaleFactor = math.max(2, localplayer.ScaleFactor - dt * 4)
                localplayer.isZooming = false
            end

            Client.Move(dir, localplayer, Game)
        end
    end



    
    if mouse.lb then
        Client.Shoot(nil, Game, localplayer) --nil to avoid op weapons I guess
    end

    do
        local event = Game.Server.host:service(Game.Server.ReceiveTimeout)
        while Game.Server.host:check_events() do
            event = Game.Server.host:service()          --No delay 
        end
        if event then
            if event.type == "receive" then
                if event.channel == Game.enetChannels.EntityChannel then
                    -- print("Received from Game.Server (entities)")
                    local data = json.decode(event.data)
                    for i, obj in ipairs(data) do
                        --print("Received object:", obj.type, "at", obj.x, obj.y)
                    if obj.type == "Bullet" then
                        Entities.list[i] = {
                            x = obj.x,
                            y = obj.y,
                            type = "ball",  -- Assuming 1 is for Bullet
                            angle = obj.angle or 0,
                            number = obj.number or 0,
                        }
                    end
                    if obj.type == "Player" then
                        Players.list[obj.number] = {
                            x = obj.x,
                            y = obj.y,
                            type = "player",  -- Assuming 2 is for Player
                            angle = obj.angle or 0,
                            number = obj.number or 0,
                            --PLEASE I'd LIKE TO COPY EVERYTHING SO IT WONT BE AWfEFUL -> CLIENT PLAYER CREATE?
                            life = obj.life or 50,
                            weapon = obj.weapon or 'default'
                        }
                        if obj.number == localplayer.number then
                            localplayer.x = obj.x
                            localplayer.y = obj.y
                            localplayer.Health = obj.Health or 50
                            localplayer.magazine = obj.magazine or localplayer.magazine
                        end
                    end

                end
                elseif event.channel == Game.enetChannels.WallsChannel then
                    -- print("Received from server (walls):")                      -- NOT OFTEN BUT FOR NOW ITS OK But having one OR the other is kinda bad (idk wait for a specific channel?)
                    local data = json.decode(event.data)
                    -- Store old walls for cleanup
                    local oldWalls = Map.walls.list
                    Map.walls.list = {}
                        for i, obj in ipairs(data) do
                            -- If old wall exists, reuse its mesh
                            if oldWalls and oldWalls[i] and oldWalls[i].mesh then
                                Map.walls.list[i] = {
                                    pos = obj.pos,
                                    mesh = oldWalls[i].mesh
                                }
                            else
                                -- Create new mesh for new wall
                                local mesh = love.graphics.newMesh({
                                    { 10, 10, 0, 1 },
                                    { 10 * obj.pos[1][1], 10 * obj.pos[1][2], 0, 0 },
                                    { 10 * obj.pos[2][1], 10 * obj.pos[2][2], 1, 0 },
                                    { love.graphics.getWidth() - 10, love.graphics.getHeight() - 10, 1, 1 }
                                })
                                mesh:setTexture(Textures.wallTexture, "fan")
                                
                                Map.walls.list[i] = {
                                    pos = obj.pos,
                                    mesh = mesh
                                }
                            end
                        end
                    --print("Received walls from server, count: ", #Map.walls.list)
                    repeat
                        event = Game.Server.host:service(Game.Server.ReceiveTimeout)
                    until event.channel == Game.enetChannels.EntityChannel and event.type == "receive"
                    data = json.decode(event.data)
                    for i, obj in ipairs(data) do
                        --print("Received object:", obj.type, "at", obj.x, obj.y)
                    if obj.type == "Bullet" then
                        Entities.list[i] = {
                            x = obj.x,
                            y = obj.y,
                            type = "ball",  -- Assuming 1 is for Bullet
                            angle = obj.angle or 0,
                            number = obj.number or 0,
                        }
                    end
                    Entities.list = {}
                    if obj.type == "Player" then
                        Players.list[obj.number] = {
                            x = obj.x,
                            y = obj.y,
                            type = "player",  -- Assuming 2 is for Player
                            angle = obj.angle or 0,
                            number = obj.number or 0,
                            fov = obj.fov or math.pi / 2,
                        }
                        if obj.number == localplayer.number then
                            localplayer.x = obj.x
                            localplayer.y = obj.y
                            localplayer.fov = obj.fov or localplayer.fov or math.pi / 2
                        end
                    end

                end
                    
                else
                    print("Got message: ", event.data, "from", event.peer, "on channel", event.channel)
                end
            else
                print(event.type, event.peer, event.data)
            end
            
            Game.Debug = "Event this frame : yep"
        else
            Game.Debug = "Event this frame : nope"
            print( love.timer.getTime(),"No event this frame")
        end
    end
end



function InGame.CreateLocalGame(params)
    local world = params.world
    local Players = params.Players
    local Player = params.Player
    local Map = params.Map
    local Entities = params.Entities
    print(#Walls.default)
    Map.walls.list = Walls.setLocal(Walls.default)
    print("hello")
    -- for players = palyers.number
    for k in pairs(Players.list) do
        Players.list[k] = nil
    end
    for i = 1, Players.number do
        table.insert(Players.list, Player.createPlayer(i, world))
        -- Players.list[i]s [Players.list[i].number] = Players.list[i]
    end
    LocalPlayer = Players.list[1]
    Entities.list = {}
end

return InGame