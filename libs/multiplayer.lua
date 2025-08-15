local Multiplayer = {}
local json = require("libs.external.lunajson")
local socket = require("socket")
local http = require("socket.http")


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
            Health = p.Health,
            magazine = p.magazine,
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
                        event.player.weapon = Game.Weapons.list[data.weapon] or event.player.weapon or Game.Weapons.list.default
                        if event.player.isZooming and data.speed > 0 then
                            event.player.moveSpeed = 1100
                        elseif data.speed <= 4400 then
                            event.player.moveSpeed = data.speed
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
                        Game.Weapons.Shoot(event.player, Entities, data.weapon or event.player.weapon)  -- Call the shoot function with the player and weapon type
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



function Multiplayer.getLocalIP()
    local udp = socket.udp()
    udp:setpeername("8.8.8.8", 80) -- Google DNS, won't actually send
    local ip = udp:getsockname()
    udp:close()
    return ip
end
function Multiplayer.getPublicIP()
    local body, code = http.request("https://api.ipify.org")
    if code == 200 then
        return body
    else
        return "Error getting IP"
    end
end


return Multiplayer