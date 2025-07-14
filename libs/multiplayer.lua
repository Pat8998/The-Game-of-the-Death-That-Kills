local Multiplayer = {}
local json = require("libs.external.lunajson")
Multiplayer.ThreadChannel = nil
Multiplayer.Host = nil

function Multiplayer.StartServer(ipaddr, channelsamount)
    local enet = require("enet")
    local host = enet.host_create(ipaddr, 64, channelsamount)  --64 is the max number of clients, 4 is the number of channels
    -- host:channel_limit(3)
    print("host created \n")
    return host
end




function Multiplayer.ServerSend (Game, players, Entities, Walls)     --additionnaly send player number on the rght channel if there's bad things happening
    local data = {}
    for _, Entity in pairs(Entities) do
        local x, y = Entity.body:getPosition()
        table.insert(data, {
            type = "Bullet",
            x = x,
            y = y
        })
    end
    for _, p in pairs(players) do
        table.insert(data, {
            type = "Player",
            x = p.x,
            y = p.y,
            number = p.number,
            angle = p.angle,
            Health = p.Health
        })
    end
    -- print("Sending data", json.encode(data))
    Game.Server.host:broadcast(json.encode(data), Game.enetChannels.EntityChannel)
    if Game.IsMajorFrame then
        -- print("Sending walls data")
        data = {}
        for _, Wall in ipairs(Walls) do
            table.insert(data, {
                pos = Wall.pos
            })
        end
        Game.Server.host:broadcast(json.encode(data), Game.enetChannels.WallsChannel)
    end
    Game.Server.host:flush()
    -- print("Sent data", json.encode(data))
end


function Multiplayer.ServerReceive (dt, players, Channels, Player, Game, Entities)
    -- for index, player in ipairs(players.list) do
    --     if player.peer ~= "local" then
    --         local event = player.peer:receive()
    --         if event then
    --             print("Got message: ", event.data, "from", event.peer , "on channel", event.channel)
    --             if event.type == "receive" then
    --                 event.peer:send("world")
    --             else
    --                 print(event.type, event.peer, event.data)
    --             end
    --         end
    --     end
    -- end
    local event = Game.Server.host:service()  
    while event do
        if event.type == "connect" then
            print("A client connected from", event.peer)
            
            -- Find the first unassigned player number
            local assigned = {}
            for _, v in ipairs(players.list) do
                assigned[v.number] = true
            end
            local new_number = 1
            while assigned[new_number] do
                new_number = new_number + 1
            end
            players.list[new_number] = Player.createPlayer(new_number, world, event.peer)
            print("Sending player number", players.list[#players.list].number)
            event.peer:send(players.list[#players.list].number, Game.enetChannels.NumberChannel)
            Game.Clients[#Game.Clients + 1] = event.peer
            Game.IsMajorFrame = true  -- Set the major frame flag to true when a new client connects
        elseif event.type == "disconnect" then
            print("A client disconnected from", event.peer)
            for i, client in ipairs(Game.Clients) do
                if client == event.peer then
                    table.remove(Game.Clients, i)
                    break
                end
            end
            for i, client in pairs(players.list) do
                -- print("Checking player", client.number, "against peer", event.peer)
                if client.peer == event.peer then
                    print("Player", client.number, "destroyed")
                    client:destroy()  -- Destroy the player object
                    table.remove(players.list, i)  -- Remove the player from the list
                    break
                end
            end
        elseif event.type == "receive" then
            if event.channel == Game.enetChannels.ActionChannel then
                -- print("Received action from player", event.peer, ":", event.data)
                local data = json.decode(event.data)
                if data then
                    if data.type == "move" then
                        for i, client in pairs(players.list) do
                            if client.peer == event.peer then
                                event.player = client
                                break
                            end
                        end
                        -- print("Received move command from player", event.player, ":", data.dir, data.speed)
                        event.player.dir = data.dir
                        -- print("Player", event.player.number, "moving in direction", event.player.dir, "with speed", data.speed)
                        event.player.isZooming = data.isZooming or false
                        if event.player.isZooming and data.speed < 0 then
                            event.player.moveSpeed = 1100
                        elseif data.speed == 4400 then
                            event.player.moveSpeed = 4400
                        elseif data.speed == 2200 then
                            event.player.moveSpeed = 2200
                        elseif not event.player.Glide then
                            event.player.moveSpeed = 0
                        end
                        event.player.angle = data.angle
                    elseif data.type == "shoot" then
                        for i, client in pairs(players.list) do
                            if client.peer == event.peer then
                                event.player = client
                                break
                            end
                        end
                        Game.Weapons.Shoot(event.player, Entities, data.weapon)  -- Call the shoot function with the player and weapon type
                        -- SO RIGHT NOW CLIENTS CAN CALL OP WEAPONS BUT ITS FINE
                    end
                end
            else
                print("event ", event.type, event.peer, event.data, event.channel)
            end
        end
        event = Game.Server.host:service()
    end
end






return Multiplayer







--OLD FUNCTION USED WITH THREADS
-- function Multiplayer.StartServer(Game)
--     local GameChannel = love.thread.getChannel("GameServerThread") --this is the channel that the thread will use to communicate with the main thread
--     local InputCommuncicationChannel = love.thread.getChannel("InputServerThread")
--     local OutputCommuncicationChannel = love.thread.getChannel("OutputServerThread")
--     local enet = require("enet")
--     local host = enet.host_create("localhost:6789")
--     print("host created")
--     --setup a thread which does things right when somebody tries to connect ?
--     while Game.IsPublic do
--         Game = GameChannel:demand(0.0001) or Game
--         local event = host:service(100)
--         if event then
--             if event.type == "connect" then
--                 print("A client connected from", event.peer)
--                 OutputCommuncicationChannel:push("Connected")
--                 event.peer:send(InputCommuncicationChannel:demand())
--             elseif event.type == "receive" then
--                 print("Got message: ", event.data, "from", event.peer)
--                 event.peer:send("world")
--             else
--                 print(event.type, event.peer, event.data)
--             end
--         -- else
--         --     print(Game.IsPublic)
--         end
--     end
--     host:destroy()
--     print("Server stopped")
-- end
-- function Multiplayer.ServerReceive (players, Channels, Player, players)
--     local event = Channels.OutputCommuncicationChannel:pop()
--     if event then
--         if event == "Connected" then
--             print("New player connected!")
--             players.list[#players.list + 1] = Player.createPlayer(#players.list + 1, world)
--             print("Sending player number", players.list[#players.list].number)                    --Somehow it sends the wrong number
--             Channels.InputCommuncicationChannel:push(players.list[#players.list].number)
--         elseif event == "Update" then
--             print("Loaded!")
--             Game.IsLoading = false
--             Game.InClientGame = true
--         end
--     end
-- end




-- function Multiplayer.Thread(ipaddr, Game, GameStatePointer)
--     local enet = require("enet")
--     local json = require("libs.external.lunajson")
--     local ffi = require("ffi")    
--     local FFIUtils = require("libs.FFIutils")
--     local gameState = ffi.cast("GameState*", ffi.cast("uintptr_t", GameStatePointer))
--     local Entities = gameState.entities
--     local Walls = gameState.walls




--     print("Connecting to", ipaddr)
--     local host = enet.host_create()
--     GameChannel = love.thread.getChannel("MultplayerThread") --this is the channel that the thread will use to communicate with the main thread
--     -- host:channel_limit(3)
--     local server = host:connect(ipaddr, 3)  --3 is the number of channels. add more if needed
--     -- Channel:push(server)
--     while not Game.IsConnectedToHost do
--         local event = host:service(1000)
--         if event then
--             print("got event")
--             if event.type == "connect" then
--                 print("Successfully connected to", ipaddr)
--                 Game.IsConnectedToHost = true
--                 GameChannel:push("Connected")
--             else
--                 print (event.type, event.peer, event.data)
--             end
--         end
--     end
--     while Game.IsLoading do
--         local event = host:service(100)
--         if event then
--             if event.type == "receive" then
--                 if event.channel == Game.enetChannels.NumberChannel then
--                     print("We are player number", event.data)
--                     -- LocalPlayer.number = event.data --actually might be sent every frame? ACTUALLY NO BC I SEND TO ALL PEERS
--                     Game.IsLoading, Game.InClientGame = false, true
--                     GameChannel:push("Loaded")
--                 else
--                     print("error wtf")
--                 end
--             end
--         end
--     end
--     print("Game started")
--     --Handle communications?
--     while Game.InClientGame do
--         local event = host:service()
--         if event then
--             if event.type == "receive" then
--                 if event.channel == Game.enetChannels.EntityChannel then
--                     -- print("Received from server (entities):", event.data)
--                     local data = json.decode(event.data)
--                     for i, obj in ipairs(data) do
--                         print("Received object:", obj.type, "at", obj.x, obj.y)
--                     --     Entities[i].pos.x = obj.x
--                     --     Entities[i-1].pos.y = obj.y
--                     --     Entities[i-1].type = (obj.type == "Bullet") and 1 or 2
--                     --     Entities[i-1].angle = obj.angle or 0
--                     --     Entities[i-1].number = obj.number or 0
--                     end      -- PROBLEMS
--                 elseif event.channel == Game.enetChannels.WallsChannel then
--                 else
--                 print("Got message: ", event.data, "from", event.peer, "on channel", event.channel)
--                 end
--             else
--                 print(event.type, event.peer, event.data)
--             end
--         -- else
--         --     print("No event")
--         end
--         -- server:send("hi", 0)
--         -- host:flush()
--     end
-- end