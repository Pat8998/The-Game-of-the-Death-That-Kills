local Multiplayer = {}
Multiplayer.ThreadChannel = nil
Multiplayer.Host = nil

function Multiplayer.Thread(ipaddr, Game)
    local enet = require("enet")
    local ffi = require("ffi")

    print("Connecting to", ipaddr)
    local host = enet.host_create()
    GameChannel = love.thread.getChannel("MultplayerThread") --this is the channel that the thread will use to communicate with the main thread
    local server = host:connect(ipaddr)
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
                print("Received message", event.data)
                -- LocalPlayer.number = event.data --actually might be sent every frame? ACTUALLY NO BC I SEND TO ALL PEERS
                Game.IsLoading = false
                GameChannel:push("Loaded")
            end
        end
    end
    --Handle communications?
end



function Multiplayer.StartServer(Game)
    local GameChannel = love.thread.getChannel("GameServerThread") --this is the channel that the thread will use to communicate with the main thread
    local InputCommuncicationChannel = love.thread.getChannel("InputServerThread")
    local OutputCommuncicationChannel = love.thread.getChannel("OutputServerThread")
    local enet = require("enet")
    local host = enet.host_create("localhost:6789")
    print("host created")
    --setup a thread which does things right when somebody tries to connect ?
    while Game.IsPublic do
        Game = GameChannel:demand(0.0001) or Game
        local event = host:service(100)
        if event then
            if event.type == "connect" then
                print("A client connected from", event.peer)
                OutputCommuncicationChannel:push("Connected")
                event.peer:send(InputCommuncicationChannel:demand())
            elseif event.type == "receive" then
                print("Got message: ", event.data, "from", event.peer)
                event.peer:send("world")
            else
                print(event.type, event.peer, event.data)
            end
        -- else
        --     print(Game.IsPublic)
        end
    end
    host:destroy()
    print("Server stopped")
end

function Multiplayer.ServerSend (players, player, Entities)
    --broadcast
end


function Multiplayer.ServerReceive (players, Channels, Player, players)
    local event = Channels.OutputCommuncicationChannel:pop()
    if event then
        if event == "Connected" then
            print("New player connected!")
            players[#players + 1] = Player.createPlayer(#players + 1, world)
            print("Sending player number", players[#players].number)                    --Somehow it sends the wrong number
            Channels.InputCommuncicationChannel:push(players[#players].number)
        elseif event == "Update" then
            print("Loaded!")
            Game.IsLoading = false
            Game.InClientGame = true
        end
    end
end





return Multiplayer