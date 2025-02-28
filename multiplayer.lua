local Multiplayer = {}
Multiplayer.ThreadChannel = nil
Multiplayer.Host = nil

function Multiplayer.Thread(ipaddr, Game)
    local enet = require("enet")
    print("Connecting to", ipaddr)
    local host = enet.host_create()
    Channel = love.thread.getChannel("MultplayerThread") --this is the channel that the thread will use to communicate with the main thread
    local server = host:connect(ipaddr)
    while not Game.IsConnectedToHost do
        local event = host:service(1000)
        if event then
            print("got event")
            if event.type == "connect" then
                print("Successfully connected to", ipaddr)
                Game.IsConnectedToHost = true
                Channel:push("Connected")
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
                Channel:push("Loaded")
            end
        end
    end
    --Handle communications?
end



function Multiplayer.StartServer()
    local enet = require("enet")
    if not Host then
        Host = enet.host_create("localhost:6789")
        print("host created")
    end
    --setup a thread which does things right when somebody tries to connect ?
    while Game.InHostedGame and  do
        
    end
end




return Multiplayer