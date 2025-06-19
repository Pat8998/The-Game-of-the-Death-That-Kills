local InGame = {}


function InGame.updateHost(params)
    -- Extract variables from the params table
    local dt = params.dt
    local players = params.players
    local player = params.localplayer
    local dmouse = params.dmouse
    local mouse = params.mouse
    local world = params.world
    local Shoot = params.Shoot
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
        player.angle = player.angle - dmouse.x / 40
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

    -- Determine move speed
    local moveSpeed = dt * 500
    if love.keyboard.isDown("lshift") then
        moveSpeed = dt * 2200
    end

    -- Update movement based on keys pressed
    if love.keyboard.isDown("z") then
        player.mx = math.cos(player.angle) * moveSpeed
        player.my = math.sin(player.angle) * moveSpeed
    elseif love.keyboard.isDown("s") then
        player.mx = -math.cos(player.angle) * moveSpeed
        player.my = -math.sin(player.angle) * moveSpeed
    end
    if love.keyboard.isDown("d") then
        player.mx = -math.cos(player.angle + math.pi / 2) * moveSpeed
        player.my = -math.sin(player.angle + math.pi / 2) * moveSpeed
    elseif love.keyboard.isDown("q") then
        player.mx = math.cos(player.angle + math.pi / 2) * moveSpeed
        player.my = math.sin(player.angle + math.pi / 2) * moveSpeed
    end

    player.body:setLinearVelocity(player.mx, player.my)
    player.mx, player.my = 0, 0

    if love.mouse.isDown(2) then
        player.fov = math.max(math.pi / 3, player.fov - math.pi / 6 * dt * 4)
        player.ScaleFactor = math.min(3, player.ScaleFactor + dt * 4)
    else
        player.fov = math.min(math.pi / 2, player.fov + math.pi / 6 * dt * 4)
        player.ScaleFactor = math.max(2, player.ScaleFactor - dt * 4)
    end

    if mouse.lb then
        Shoot(dt, player, 0.1, "default")
    end

    -- Normalize angles to be within -pi to pi
    if player.angle < -math.pi then
        player.angle = player.angle + 2 * math.pi
    elseif player.angle > math.pi then
        player.angle = player.angle - 2 * math.pi
    end





    --update othe players
    if Game.IsPublic then
        Multiplayer.ServerReceive(players, Channels, Player, Game)
    end


    world:update(dt)
    for _, p in ipairs(players.list) do
        p.x, p.y = p.body:getPosition()
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

function InGame.UpdateWhileLoading(channel, Game, enet, json, Server)
    local message = channel:pop()
        if message then
            if message == "Connected" then
                print("Connected to host!")
                Game.IsConnectedToHost = true
            elseif message == "Loaded" then
                print("Loaded!")
                Game.IsLoading = false
                Game.InClientGame = true
            end
        end
        print("Game.IsJoining: ", Game.IsJoining)
        if Game.IsJoining == 1 then
            Server.host = enet.host_create()
            local server = Server.host:connect(Server.ipaddr, 3)  --3 is the number of channels. add more if needed
            print("Connecting to server at " .. Server.ipaddr)
            Game.IsJoining = 2
        elseif Game.IsJoining == 2 then
            local event = Server.host:service(0)
            if event then
                if event.type == "connect" then
                    print("Connected to server!")
                    Game.IsConnectedToHost = true
                    Game.IsJoining = 3
                end
            end
        elseif Game.IsJoining == 3 then        
        local event = Server.host:service(100)
        if event then
            if event.type == "receive" then
                if event.channel == Game.enetChannels.NumberChannel then
                    print("We are player number", event.data)
                    -- LocalPlayer.number = event.data --actually might be sent every frame? ACTUALLY NO BC I SEND TO ALL PEERS
                    Game.IsLoading, Game.InClientGame, Game.IsJoining = false, true, false
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
    local player = params.localplayer
    local Map = params.Map
    local Server = params.Server
    local json = params.json

    -- Update mouse and player angle
    if not love.keyboard.isDown("lalt") and love.window.hasFocus() then
        love.mouse.setGrabbed(true)
        love.mouse.setVisible(false)
        player.angle = player.angle - dmouse.x / 40
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

    -- Determine move speed
    local moveSpeed = dt * 500
    if love.keyboard.isDown("lshift") then
        moveSpeed = dt * 2200
    end

    -- Update movement based on keys pressed
    -- if love.keyboard.isDown("z") then
    --     player.mx = math.cos(player.angle) * moveSpeed
    --     player.my = math.sin(player.angle) * moveSpeed
    -- elseif love.keyboard.isDown("s") then
    --     player.mx = -math.cos(player.angle) * moveSpeed
    --     player.my = -math.sin(player.angle) * moveSpeed
    -- end
    -- if love.keyboard.isDown("d") then
    --     player.mx = -math.cos(player.angle + math.pi / 2) * moveSpeed
    --     player.my = -math.sin(player.angle + math.pi / 2) * moveSpeed
    -- elseif love.keyboard.isDown("q") then
    --     player.mx = math.cos(player.angle + math.pi / 2) * moveSpeed
    --     player.my = math.sin(player.angle + math.pi / 2) * moveSpeed
    -- end

    -- -- player.body:setLinearVelocity(player.mx, player.my)
    -- player.mx, player.my = 0, 0

    -- if love.mouse.isDown(2) then
    --     player.fov = math.max(math.pi / 3, player.fov - math.pi / 6 * dt * 4)
    --     WallsHeight = math.min(3, WallsHeight + dt * 4)
    -- else
    --     player.fov = math.min(math.pi / 2, player.fov + math.pi / 6 * dt * 4)
    --     WallsHeight = math.max(2, WallsHeight - dt * 4)
    -- end

    -- if mouse.lb then
    --     Shoot(dt, player, 0.1, "default")
    -- end




    -- Normalize angles to be within -pi to pi
    if player.angle < -math.pi then
        player.angle = player.angle + 2 * math.pi
    elseif player.angle > math.pi then
        player.angle = player.angle - 2 * math.pi
    end


    -- Entities.list = {}
    -- local entityState = SharedStates.entities
    -- print("Entity count: ", (SharedStates.entityCount))  
    -- print("Entity count: ", tonumber(SharedStates.entityCount))       -- Prints the pointer istead of the  value
    -- for i = 0, SharedStates.entityCount-1 do
    --     local entity = entityState[i]
    --     Entities.list[i+1] = {
    --         x = entity.pos.x,
    --         y = entity.pos.y,
    --         type = entity.type,
    --         angle = entity.angle,
    --         number = entity.number
    --     }
    -- end        
    local event = Server.host:service()

    if event then
        if event.type == "receive" then
            if event.channel == Game.enetChannels.EntityChannel then
                -- print("Received from server (entities):", event.data)
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
                    Entities.list = {}
                    -- Entities[i].pos.x = obj.x
                    -- Entities[i-1].pos.y = obj.y
                    -- Entities[i-1].type = (obj.type == "Bullet") and 1 or 2
                    -- Entities[i-1].angle = obj.angle or 0
                    -- Entities[i-1].number = obj.number or 0
                end      -- PROBLEMS
            elseif event.channel == Game.enetChannels.WallsChannel then
                print("Received from server (walls):", event.data)
                local data = json.decode(event.data)
                Map.walls.list = {}
                for i, obj in ipairs(data) do
                    --print("Received wall:", obj.type, "from", obj.pos[1][2], "to", obj.pos[2][2])
                    Map.walls.list[i] = {
                        pos = obj.pos,
                    }
                end
            else
            print("Got message: ", event.data, "from", event.peer, "on channel", event.channel)
            end
        else
            print(event.type, event.peer, event.data)
        end
    -- else
    --     print("No event")
    end
    -- server:send("hi", 0)
    -- host:flush()
    --print("Entities list length: ", #Entities.list)
        -- Do something with the data















end

return InGame