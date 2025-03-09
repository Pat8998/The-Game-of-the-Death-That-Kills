local Multiplayer = {}
local json = require("libs.dkjson")
Multiplayer.ThreadChannel = nil
Multiplayer.Host = nil

function Multiplayer.Thread(ipaddr, Game)
    local enet = require("enet")
    local ffi = require("ffi")

    print("Connecting to", ipaddr)
    local host = enet.host_create()
    GameChannel = love.thread.getChannel("MultplayerThread") --this is the channel that the thread will use to communicate with the main thread
    host:channel_limit(3)
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
        local event = host:check_events()
        if event then
            if event.type == "receive" then
                print("Got message: ", event.data, "from", event.peer, "on channel", event.channel)
                event.peer:send("world")
            else
                print(event.type, event.peer, event.data)
            end
        -- else
        --     print("No event")
        end
    end
end



function Multiplayer.StartServer(ipaddr)
    local enet = require("enet")
    local host = enet.host_create(ipaddr)
    host:channel_limit(3)
    print("host created")
    return host
end




function Multiplayer.ServerSend (Game, players, Entities, Walls)     --additionnaly send player number on the rght channel if there's bad things happening
    local data = {}
    for _, Entity in ipairs(Entities) do
        table.insert(data, {
            type = "Bullet",
            x = Entity.body:getPosition(),
            y = Entity.body:getPosition()[2]
        })
    end
    for _, p in ipairs(players) do
        table.insert(data, {
            type = "Player",
            x = p.body:getPosition(),
            y = p.body:getPosition()[2]
        })
    end
    Game.Server:broadcast(json.encode(data), Game.enetChannels.EntityChannel)
    data = {}
    for _, Wall in ipairs(Walls) do
        table.insert(data, {
            pos = Wall.pos
        })
    end
    Game.Server:broadcast(json.encode(data), Game.enetChannels.WallsChannel)
    -- Game.Server:broadcast(json.encode({
    --     type = "update",
    --     player = player,
    --     players = players,
    --     Entities = Entities
    -- }))

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