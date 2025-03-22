local Multiplayer = {}
local json = require("libs.external.lunajson")
Multiplayer.ThreadChannel = nil
Multiplayer.Host = nil

local ffi = require("ffi")


-- -- Create a function to allocate shared memory
-- function Multiplayer.CreateSharedState(maxEntities, maxWalls)
--     -- Define your C structs
--     ffi.cdef[[
--         typedef struct {
--             double x, y;
--         } Vec2;
        
--         typedef struct {
--             Vec2 pos;
--             double angle;
--             int number;
--         } Entity;
        
--         typedef struct {
--             Vec2 start;
--             Vec2 end;
--         } Wall;
--         ]]
--     local Entities = ffi.new("Entity[?]", maxEntities)
--     local Walls = ffi.new("Wall[?]", maxWalls)
--     return {Entities = Entities, Walls = Walls}
-- end


function Multiplayer.JoinGame(ipaddr, Game, SharedStatesPointer)
    local ThreadScrpit = string.dump(Multiplayer.Thread)
    local MultplayerThread = love.thread.newThread(ThreadScrpit)
    MultplayerThread:start(ipaddr, Game, tonumber(ffi.cast("uintptr_t",  SharedStatesPointer)))
    Multiplayer.ThreadChannel = love.thread.getChannel("MultplayerThread")
end




function Multiplayer.Thread(ipaddr, Game, GameStatePointer)
    local enet = require("enet")
    local json = require("libs.external.lunajson")
    local ffi = require("ffi")    
    local FFIUtils = require("libs.FFIutils")
    local gameState = ffi.cast("GameState*", ffi.cast("uintptr_t", GameStatePointer))
    local Entities = gameState.entities
    local Walls = gameState.walls




    print("Connecting to", ipaddr)
    local host = enet.host_create()
    GameChannel = love.thread.getChannel("MultplayerThread") --this is the channel that the thread will use to communicate with the main thread
    -- host:channel_limit(3)
    local server = host:connect(ipaddr, 3)  --3 is the number of channels. add more if needed
    -- Channel:push(server)
    while not Game.IsConnectedToHost do
        local event = host:service(1000)
        if event then
            print("got event")
            if event.type == "connect" then
                print("Successfully connected to", ipaddr)
                Game.IsConnectedToHost = true
                GameChannel:push("Connected")
            else
                print (event.type, event.peer, event.data)
            end
        end
    end
    while Game.IsLoading do
        local event = host:service(100)
        if event then
            if event.type == "receive" then
                if event.channel == Game.enetChannels.NumberChannel then
                    print("We are player number", event.data)
                    -- LocalPlayer.number = event.data --actually might be sent every frame? ACTUALLY NO BC I SEND TO ALL PEERS
                    Game.IsLoading, Game.InClientGame = false, true
                    GameChannel:push("Loaded")
                else
                    print("error wtf")
                end
            end
        end
    end
    print("Game started")
    --Handle communications?
    while Game.InClientGame do
        local event = host:service()
        if event then
            if event.type == "receive" then
                if event.channel == Game.enetChannels.EntityChannel then
                    -- print("Received from server (entities):", event.data)
                    local data = json.decode(event.data)
                    -- for i, obj in ipairs(data) do
                    --     Entities[i].pos.x = obj.x
                    --     Entities[i-1].pos.y = obj.y
                    --     Entities[i-1].type = (obj.type == "Bullet") and 1 or 2
                    --     Entities[i-1].angle = obj.angle or 0
                    --     Entities[i-1].number = obj.number or 0
                    -- end      -- PROBLEMS
                elseif event.channel == Game.enetChannels.WallsChannel then
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
    end
end



function Multiplayer.StartServer(ipaddr)
    local enet = require("enet")
    local host = enet.host_create(ipaddr, 64, 3)
    -- host:channel_limit(3)
    print("host created")
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
            angle = p.angle
        })
    end
    -- print("Sending data", json.encode(data))
    Game.Server:broadcast(json.encode(data), Game.enetChannels.EntityChannel)
    data = {}
    for _, Wall in ipairs(Walls) do
        table.insert(data, {
            pos = Wall.pos
        })
    end
    Game.Server:broadcast(json.encode(data), Game.enetChannels.WallsChannel)
    Game.Server:flush()
    -- print("Sent data", json.encode(data))
end


function Multiplayer.ServerReceive (players, Channels, Player, Game)
    for index, peer in ipairs(Game.Clients) do
        local event = peer:receive()
        if event then
            if event.type == "receive" then
                print("Got message: ", event.data, "from", event.peer)
                event.peer:send("world")
            else
                print(event.type, event.peer, event.data)
            end
        end
    end
    local event = Game.Server:service()
    if event then
        if event.type == "connect" then
            print("A client connected from", event.peer)
            players.list[#players.list + 1] = Player.createPlayer(#players.list + 1, world)
            print("Sending player number", players.list[#players.list].number)
            event.peer:send(players.list[#players.list].number, Game.enetChannels.NumberChannel)
            Game.Clients[#Game.Clients + 1] = event.peer
        else
            print(event.type, event.peer, event.data)
        end
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