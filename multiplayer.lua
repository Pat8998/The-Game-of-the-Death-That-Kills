local Multiplayer = {}

function Multiplayer.Thread(ipaddr, Game)
    local enet = require("enet")
    print("Connecting to", ipaddr)
    local host = enet.host_create(ipaddr)
    Multiplayer.ThreadChannel = love.thread.getChannel("MultplayerThread") --this is the channel that the thread will use to communicate with the main thread
    
    local server = host:connect(ipaddr)
    while not Game.IsConnectedToHost do
        local event = host:service(1000)
        if event then
            print("got event")
            if event.type == "connect" then
                print("Successfully connected to", ipaddr)
                Game.IsConnectedToHost = true
                Multiplayer.ThreadChannel:push("Connected")
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
                Multiplayer.ThreadChannel:push("Loaded")
            end
        end
    end
    --Handle communications?
end

Multiplayer.ThreadChannel = nil

return Multiplayer