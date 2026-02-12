Draw = {}
Textures = require("libs.textures")


function Draw:Menu(Buttons)
    for key, button in pairs(Buttons) do
        button:draw()
    end
end

function Draw.LoadingScreen(Game)
    love.graphics.print("DROP FILE", 500, 500)
    love.graphics.setColor(1, 0, 0.1, 1)
    love.graphics.print("IP :" .. Game.Server.ipaddr, 10, 20, 0, 2, 2)
    
    love.graphics.setColor(1, 0.7, 0.1, 1)
    love.graphics.print(Game.Debug, 5, 5)
    --Spin a Circle ??
    if Game.IsJoining > 0 then
        love.graphics.setColor(1, 1, 1, 0.5)
        local angle = math.sin(love.timer.getTime()) * 2 * math.pi
        love.graphics.arc('line',
            'open',
            love.graphics.getWidth() - love.graphics.getWidth()/10,
            love.graphics.getHeight()/10,
            love.graphics.getHeight()/12,
            math.fmod((love.timer.getTime())* math.pi * 2, 2 * math.pi),
            math.fmod((love.timer.getTime())* math.pi * 2, 2 * math.pi) + math.pi *1.99,
            math.sin(love.timer.getTime() * 4) * 8 + 11)
    end
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2, 0.8)
end

function Draw.InGameSplitscreen(params)
        love.graphics.setCanvas(InGameCanvas)  -- Set the canvas as the target
        love.graphics.clear(0, 0, 0, 0)    -- Clear it (transparent)
        love.graphics.setCanvas()
        local pos = {x = 0, y = 0, width = love.graphics.getWidth(), height = love.graphics.getHeight()}
        local LocalPlayers = {}
        for _, player in pairs(params.Players.list) do
            if player.peer == "local" then
                LocalPlayers[player.number] = player
            end
        end
        for _, player in pairs(LocalPlayers) do
                params.player = player
                InGameCanvas:renderTo(function ()
                    love.graphics.clear(0, 0, 0, 0)  -- Clear the canvas for each player
                    Draw.InGame(params)
                    if #LocalPlayers > 1 then
                        love.graphics.setColor(1, 1, 1, 0.9)  -- Reset color to white
                        love.graphics.setLineWidth(3)
                        love.graphics.rectangle("line", -1, -1, love.graphics.getWidth() + 2, love.graphics.getHeight() + 2)  -- Draw a border around the canvas
                    end
                end)
                pos = params.Game.SplitscreenPos[#LocalPlayers][_]
                love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white
                love.graphics.draw(InGameCanvas, pos.x, pos.y, 0, pos.width/InGameCanvas:getWidth(), pos.height/InGameCanvas:getHeight())

        end
end




function Draw.InGame(params)

    -- Extract variables from the passed table
    local Textures          = params.Textures
    local player            = params.player
    local fps               = params.fps
    local Game             = params.Game
    local Walls             = params.Walls
    local screen_width      = params.screen_width
    local screen_height     = params.screen_height
    local WallsHeight       = params.WallsHeight
    local Entities          = params.Entities
    local Players           = params.Players
    
    local large_sreen_width = 2*math.pi*love.graphics.getWidth()/player.fov

    -- Draw the player indicator and FPS/debug info
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.print(fps)

    love.graphics.print("x: " .. tostring(player.x), 0, 20)
    love.graphics.print("y: " .. tostring(player.y), 0, 40)
    love.graphics.print("angle: " .. tostring(player.angle * 180 / math.pi), 0, 60)
    love.graphics.print(Game.Debug, 0, 80)

    --FLOOR
    do
        love.graphics.setColor(0.1, 0.1, 1, 1)
        local distfrimeye = player.height / math.sin((screen_height/screen_width) * player.fov / 2)
        local widthdistance = 2 * distfrimeye * math.tan(player.fov / 2)
        -- love.graphics.print(screen_width .. "\n" .. screen_height, 200, 200, 0, 2 , 2)
        local shader = Textures.Shaders.floorShader
        if Game.IsMobile then
            shader:send("screenSize", {love.window.getDesktopDimensions()})
        else
            shader:send("screenSize", {screen_width, screen_height})
        end
        shader:send("fov", player.fov)
        shader:send("gridSize", 1)
        -- shader:send("lineWidth", 0.02)
        shader:send("cameraYaw", player.angle)
        shader:send("cameraPitch", player.pitch)
        shader:send("cameraPos", {-player.y, player.height, -player.x})
        
        love.graphics.setShader(shader)
        -- love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.draw(Textures.floorTexture, 0, 0, 0, screen_width, screen_height)
        love.graphics.setShader()
    end


    local TTD = {}
    local types = {
        "wall",
        "entity",
        "player",
        "remImg"
    }
    for _, v in pairs(Walls)            do table.insert(TTD, v) v.type = types[1]  end
    for _, v in pairs(Entities.list)    do table.insert(TTD, v) v.type = types[2] end
    for _, v in pairs(Players.list)     do table.insert(TTD, v) v.type = types[3] end
    if Game.InHostedGame then
        for _, v in pairs(TTD) do
            v.dist = love.physics.getDistance(player.fixture, v.fixture)
        end
    else
        for _, v in pairs(TTD) do
            if v.type == "wall" then
                v.dist = ((v.pos[1][1] + v.pos[2][1])/2 - player.x)^2 + ((v.pos[1][2] + v.pos[2][2])/2 - player.y)^2
            else
                v.dist = (v.x - player.x)^2 + (v.y - player.y)^2
            end
        end
    end
    for _, v in pairs(Entities.remImg) do table.insert(TTD, v) v.type = types[4] v.dist = (v.x - player.x)^2 + (v.y - player.y)^2 end
    table.sort(TTD, function(a, b)
        return a.dist > b.dist
    end)
    
    love.graphics.setColor(255, 255, 255, 255)
    
    for key, object in pairs(TTD) do
        -- print("drawing object " .. tostring(key) .. " of type " .. tostring(object.type) .. " at distance " .. tostring(object.dist))
        if object.type == "wall" then
            -- Draw walls
            love.graphics.setLineWidth(1)
                local relative_pos = {
                    s = { x = object.pos[1][1] - player.x, y = object.pos[1][2] - player.y },
                    e = { x = object.pos[2][1] - player.x, y = object.pos[2][2] - player.y }
                }
                local angle = {
                    s = math.atan2(relative_pos.s.y, relative_pos.s.x) - player.angle + player.fov / 2,
                    e = math.atan2(relative_pos.e.y, relative_pos.e.x) - player.angle + player.fov / 2
                }
                if math.abs(angle.s - angle.e) > math.pi then
                    if angle.s - angle.e > 0 then
                        angle.e = angle.e + 2 * math.pi
                    elseif angle.s - angle.e < 0 then
                        angle.e = angle.e - 2 * math.pi
                    end
                end
                local dist = {
                    s = math.sqrt(relative_pos.s.x^2 + relative_pos.s.y^2),
                    e = math.sqrt(relative_pos.e.x^2 + relative_pos.e.y^2)
                }
                local screen_pos = {
                    s = screen_width - (angle.s) * screen_width / player.fov,
                    e = screen_width - (angle.e) * screen_width / player.fov
                }
                if screen_pos.s > large_sreen_width or screen_pos.e > large_sreen_width then
                    screen_pos.s, screen_pos.e = screen_pos.s - large_sreen_width, screen_pos.e - large_sreen_width
                elseif screen_pos.s < -large_sreen_width + screen_width or screen_pos.e < -large_sreen_width + screen_width then
                    screen_pos.s, screen_pos.e = screen_pos.s + large_sreen_width, screen_pos.e + large_sreen_width
                end
                local vert_angle = {
                    s= {b = math.atan((player.height) / dist.s),
                        t = math.atan((WallsHeight - player.height) / dist.s)},
                    e = {b = math.atan((player.height) / dist.e),
                        t = math.atan((WallsHeight - player.height) / dist.e)}
                }
                local height = {
                    s = {
                        b = screen_height / 2 + vert_angle.s.b * screen_height / ((screen_height/screen_width) * player.fov),
                        t = screen_height / 2 - vert_angle.s.t * screen_height / ((screen_height/screen_width) * player.fov)
                    },
                    e = {
                        b = screen_height / 2 + vert_angle.e.b * screen_height / ((screen_height/screen_width) * player.fov),
                        t = screen_height / 2 - vert_angle.e.t * screen_height / ((screen_height/screen_width) * player.fov)
                    }
                }
                local vertices = {
                    screen_pos.s, height.s.t,
                    screen_pos.s, height.s.b,
                    screen_pos.e, height.e.b,
                    screen_pos.e, height.e.t
                }
                love.graphics.setColor(1, 63/255, 194/255)
                love.graphics.polygon('fill', vertices)
                love.graphics.setColor(197/255, 49/255, 150/255)
                love.graphics.polygon('line', vertices)
                
                vertices = {
                    { vertices[1], vertices[2], 0, 1 },
                    { vertices[3], vertices[4], 0, 0 },
                    { vertices[5], vertices[6], 1, 0 },
                    { vertices[7], vertices[8], 1, 1 }
                }
                
                object.mesh:setVertices(vertices)
                love.graphics.draw(object.mesh)
                
                
                
                -- Draw the minimap line for the wall
                love.graphics.line(object.pos[1][1] + 25, -object.pos[1][2] + 200, object.pos[2][1] + 25, -object.pos[2][2] + 200)
            
                
                -- Draw entities
        elseif object.type == "entity" then
            -- Draw the entity on the minimap
            love.graphics.setColor(1, 1, 0, 1)
            local x, y = object.x, object.y or object.body:getPosition()
            love.graphics.points(x + 25, -y + 200)
 
            if object.weapon and object.weapon.type == Game.Weapons.types.ball then
                local relative_pos = {
                    x = x - player.x,
                    y = y - player.y
                }
                local angle = math.atan2(relative_pos.y, relative_pos.x) - player.angle + player.fov / 2
                -- local relative_angle = object.angle + angle
                -- print(relative_angle)
                local dist = math.sqrt(relative_pos.x^2 + relative_pos.y^2)
                local screen_pos = {
                    x = screen_width - (angle) * screen_width / player.fov,
                    y = 500 * math.exp(-dist) + screen_height / 2
                }
                if screen_pos.x > large_sreen_width then
                    screen_pos.x = screen_pos.x - large_sreen_width
                elseif screen_pos.x < -large_sreen_width + screen_width then
                    screen_pos.x = screen_pos.x + large_sreen_width
                end
                --if entity.body:geuserdata == ball
                love.graphics.circle("fill", screen_pos.x, screen_pos.y, math.min(100 / dist, 100), 500)
            end
        elseif object.type == "remImg" then
            local x, y = object.x, object.y
            local x2, y2 = x+ math.cos(object.angle) * 10, y + math.sin(object.angle) * 10
            local relative_pos = {
                x = x - player.x,
                y = y - player.y,
                x2 = x2 - player.x,
                y2 = y2 - player.y
            }
            local angle = {y = math.atan2(relative_pos.y, relative_pos.x) - player.angle + player.fov / 2 ,
                           p = math.atan(((object.height or 1.3) - player.height) / math.sqrt(relative_pos.x^2 + relative_pos.y^2))
            }

            local angle2 = {y = math.atan2(relative_pos.y2, relative_pos.x2) - player.angle + player.fov / 2,
                            p = math.atan(((object.height or 1.3) - player.height) / math.sqrt(relative_pos.x2^2 + relative_pos.y2^2))
            }
            -- local relative_angle = object.angle + angle
            local dist = math.sqrt(relative_pos.x^2 + relative_pos.y^2)
            local dist2 = math.sqrt(relative_pos.x2^2 + relative_pos.y2^2)
            if object.imgType == "bullet" then
                local screen_pos = {
                    x   = screen_width - (angle.y) * screen_width / player.fov,
                    y   = screen_height / 2 - angle.p * screen_height / ((screen_height/screen_width) * player.fov),
                    x2  = screen_width - (angle2.y) * screen_width / player.fov,
                    y2  = screen_height / 2 - angle2.p * screen_height / ((screen_height/screen_width) * player.fov)
                }
                if screen_pos.x > large_sreen_width then
                    screen_pos.x = screen_pos.x - large_sreen_width -- Don't draw if it's too far to the right (behind the player)
                elseif screen_pos.x < -large_sreen_width + screen_width  then
                    screen_pos.x = screen_pos.x2 + large_sreen_width-- Wrap around to the left if it's too far to the left
                end
                if screen_pos.x2 > large_sreen_width then
                    screen_pos.x2 = screen_pos.x2 - large_sreen_width
                elseif screen_pos.x2 < -large_sreen_width + screen_width then
                    screen_pos.x2 = screen_pos.x2 + large_sreen_width
                end

                --If not enough angle then make it so it looks coming out of the nozzle?
                if math.abs(screen_pos.x - screen_pos.x2) < 10  then
                    local test = 0.5
                    if player.isZooming then
                        screen_pos.x = (screen_width/2 + math.cos(object.angle) * 5) * 1/(dist*test) + screen_pos.x * (1 - 1/(dist*test))
                        screen_pos.y = math.min(screen_pos.y, screen_height/2 + screen_height/9) -- Don't let the bullet go below a certain point on the screen, determined by the weapon I guesss
                    else                        screen_pos.x = (screen_width/2) * 1/(dist*0.5) + screen_pos.x * (1 - 1/(dist*0.5))
                        screen_pos.y = math.min(screen_pos.y, screen_height/2 + screen_height/9)
                        screen_pos.x = (screen_width - screen_width/9  + math.cos(object.angle) * 5) * 1/(dist*test) + screen_pos.x * (1 - 1/(dist*test))
                    end
                end
                love.graphics.setColor(1, 0, 0.5, 1)
                love.graphics.setLineJoin("bevel")
                love.graphics.setLineStyle("rough")
                love.graphics.setLineWidth(7)
                love.graphics.line(screen_pos.x, screen_pos.y , screen_pos.x2, screen_pos.y2)

            elseif object.imgType == "text" then
                local screen_pos = 
                {
                     x = screen_width - (angle.y) * screen_width / player.fov,
                     y = screen_height / 2 - angle.p * screen_height / ((screen_height/screen_width) * player.fov) + object.life * screen_height/10 -screen_height/5 
                } 
                if screen_pos.x > large_sreen_width then
                    screen_pos.x = screen_pos.x - large_sreen_width 
                elseif screen_pos.x < -large_sreen_width + screen_width then
                    screen_pos.x = screen_pos.x + large_sreen_width 
                end
                love.graphics.setColor(1, 0.1, 0.1, object.life * 2)
                love.graphics.print(object.text, screen_pos.x, screen_pos.y,  nil ,  5, nil, nil, nil, 0.1* math.sin(love.timer.getTime()))
            end
        else
            local otherplayer = object
            otherplayer.height = otherplayer.height or 1.6  -- Default height if not specified
            otherplayer.Health = otherplayer.Health or 100  -- Default health if not specified
            -- Draw other players
            local x, y = otherplayer.x, otherplayer.y
            love.graphics.points(x + 25, -y + 200)
            
            local relative_pos = {
                x = x - player.x,
                y = y - player.y
            }
            local dist = math.sqrt(relative_pos.x^2 + relative_pos.y^2)
            local angle = {y = math.atan2(relative_pos.y, relative_pos.x) - player.angle + player.fov / 2,
                           p = { t = math.atan(((otherplayer.height) - player.height) / dist),
                                 b = math.atan2(otherplayer.height , dist)}
            }
            local screen_pos = {
                x = screen_width - (angle.y) * screen_width / player.fov,
                y = screen_height / 2 - angle.p.t * screen_height / ((screen_height/screen_width) * player.fov)
            }
            if screen_pos.x > large_sreen_width then
                screen_pos.x = screen_pos.x - large_sreen_width
            elseif screen_pos.x < -large_sreen_width + screen_width then
                screen_pos.x = screen_pos.x + large_sreen_width
            end
            -- local w, h = otherplayer.shape:getRadius() * 2, otherplayer.shape:getRadius() * 2
            local w, h = 2 * (math.atan(2/dist) * screen_width) / player.fov,        --so far radius is 2
                         angle.p.b * screen_height / ((screen_height/screen_width) * player.fov)
            love.graphics.setColor(0.001, 1, 0.001)
            love.graphics.setLineWidth(5)
            love.graphics.rectangle("line", screen_pos.x - w/2 , screen_pos.y - h/2 , w, h)
            love.graphics.setColor(1, 1, 1, otherplayer.Health > 0 and 0.5 or 2)
            local texture = otherplayer.Health > 0 and Textures.player.default or Textures.deathTexture
            love.graphics.draw(texture, screen_pos.x - w/2 , screen_pos.y - h/2, 0, w / texture:getWidth(), h / texture:getHeight())
            love.graphics.setColor(1, 0.1, 0.1, 1)
            love.graphics.print(otherplayer.number, screen_pos.x, screen_pos.y - h/2, 0.1 * math.sin(love.timer.getTime() * 10), 1.5, 1.5)
        end
    end
        HUD(
            player,
            Game
        )
end

function HUD(LocalPlayer, Game)
    local size = 1
    local screen_width, screen_height = love.graphics.getDimensions()
    
    love.graphics.setLineWidth(1)
    --CROSSHAIR
    love.graphics.setColor(1, 1, 1, 1)
    if Game.UI.crosshair == "internal" then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.setLineWidth(2)
        love.graphics.line(screen_width/2 + size *-30 + 5 * (LocalPlayer.isZooming and 1 or 0) - 10 * (LocalPlayer.moveSpeed/4400), screen_height/2, screen_width/2 + size * -10 + 5 * (LocalPlayer.isZooming and 1 or 0) - 10 * (LocalPlayer.moveSpeed/2200), screen_height/2)
        love.graphics.line(screen_width/2 + size * 30 - 5 * (LocalPlayer.isZooming and 1 or 0) + 10 * (LocalPlayer.moveSpeed/4400), screen_height/2, screen_width/2 + size *  10 - 5 * (LocalPlayer.isZooming and 1 or 0) + 10 * (LocalPlayer.moveSpeed/2200), screen_height/2)
        love.graphics.line(screen_width/2, screen_height/2  - size * 30 + 5 * (LocalPlayer.isZooming and 1 or 0) - 10 * (LocalPlayer.moveSpeed/4400), screen_width/2 , screen_height/2 - size * 10 + 5 * (LocalPlayer.isZooming and 1 or 0) - 10 * (LocalPlayer.moveSpeed/2200))
        love.graphics.line(screen_width/2, screen_height/2  + size * 30 - 5 * (LocalPlayer.isZooming and 1 or 0) + 10 * (LocalPlayer.moveSpeed/4400), screen_width/2 , screen_height/2 + size * 10 - 5 * (LocalPlayer.isZooming and 1 or 0) + 10 * (LocalPlayer.moveSpeed/2200))
    else
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.draw(Textures.crosshairTexture, screen_width/2 - size * Textures.crosshairTexture:getWidth() / 2, screen_height/2 - size * Textures.crosshairTexture:getHeight() / 2)
    end

    if Game.IsMobile then
        --Joystick
        for id, Touch in pairs(Game.TouchScreen.Touches) do
            if Touch.IsLeftJoy then
                local x, y = Touch.x - Touch.sx, Touch.y - Touch.sy
                local angle = math.atan2(y, x)
                local distance = math.sqrt(x^2 + y^2)
                local radius = screen_height/7  -- Radius of the joystick area
                local smallradius = radius / 4
                if distance > radius - smallradius then
                    x, y = (radius - smallradius) * math.cos(angle), (radius - smallradius) * math.sin(angle)  -- Limit the touch position to the joystick area
                end
                love.graphics.setColor(0.1, 0.1, 1, 0.5)
                love.graphics.circle("fill", Touch.sx, Touch.sy, radius, 30)
                love.graphics.setColor(1, 1, 1, 0.8)
                love.graphics.circle("fill", Touch.sx + x, Touch.sy + y, smallradius, 30)
            end
            
        end

        --buttons
        Draw:Menu(Game.Buttons.MobileButtons)
    end

    --MINIMAP
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.line(25 + LocalPlayer.x, 200 - LocalPlayer.y, 25 + LocalPlayer.x + 5 * math.cos(LocalPlayer.angle), 200 - LocalPlayer.y - 5 * math.sin(LocalPlayer.angle))
    
    do
        --WEAPON
        love.graphics.setColor(1, 1, 1, 0.9)
        local weaponIMG = (not LocalPlayer.isZooming and (Textures.weapons[LocalPlayer.weapon.name] or Textures.weapons.Default).normal) or
                                                          ((Textures.weapons[LocalPlayer.weapon.name] or Textures.weapons.Default).aimed)
        weaponIMG:setFilter("nearest", "nearest")
        local weaponScale = LocalPlayer.isZooming and (screen_height) / weaponIMG:getHeight() or (screen_height/2) / weaponIMG:getHeight()
        local weaponShearing = {
            x = (LocalPlayer.moveSpeed / (LocalPlayer.isZooming and 22000 or 44000)) * math.sin(love.timer.getTime() * (LocalPlayer.moveSpeed / 550)) -- bobbing effect
                + (LocalPlayer.isZooming and (LocalPlayer.fov/(math.pi/3) - 1) or LocalPlayer.fov/(math.pi/2) - 1),  -- zooming effect
            y = 0.5 * (LocalPlayer.isZooming and (LocalPlayer.fov/(math.pi/3) - 1) or  - (LocalPlayer.fov/(math.pi/2) - 1))
        }
        local weaponText = (LocalPlayer.weapon.name ) or "<3"
        love.graphics.print(weaponText, screen_width - 8 * weaponText:len(), 5, 1, 2, 2)
        love.graphics.draw(weaponIMG,
        (LocalPlayer.isZooming and screen_width/2 - weaponIMG:getWidth()/2 * weaponScale * size) or (screen_width - weaponIMG:getWidth() * weaponScale * size),
        LocalPlayer.isZooming and 0 or screen_height - weaponIMG:getHeight() * weaponScale * size,
        0,
        weaponScale * size,
        nil, nil, nil,
        weaponShearing.x, weaponShearing.y)

        love.graphics.setColor(1, 0, 1, 0.5)
        love.graphics.rectangle("fill", screen_width - 2 * size, screen_height/2 + math.min(200 * size, screen_height/2 - 100 * size), -32 * size, 100 * size)
        love.graphics.setColor(0.9, (love.timer.getTime() > LocalPlayer.NextShoot) and 0.5 or 1, (love.timer.getTime() > LocalPlayer.NextShoot) and 0.9 or 0, 0.8)
        love.graphics.rectangle("fill", screen_width - 3 * size, screen_height/2 + math.min(200 * size, screen_height/2 - 100 * size) + 99, -30 * size, -100 * size * (LocalPlayer.magazine[LocalPlayer.weapon.name])/(LocalPlayer.weapon.maxmagazine or LocalPlayer.magazine[LocalPlayer.weapon.name]))

    end

    --SCORE
    local time = love.timer.getTime()
    local i = LocalPlayer.Score
    love.graphics.print("SCORE: " .. tostring(LocalPlayer.Score), screen_width/10 * size, 20, 0, 2, 2.1)
    love.graphics.setColor(
        math.sin(time   ) * 0.5 + 0.5,
        math.sin(time   +math.pi/3 * i) * 0.5 + 0.5,
        math.sin(time   +2*math.pi/3 * i) * 0.5 + 0.5,
            2)
    love.graphics.print("SCORE: " .. tostring(LocalPlayer.Score), screen_width/10 * size, 20, 0, 2, 2)
    
    --LIFEBAR
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 20, screen_height - 30, size * screen_width / 10, 20)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", 21, screen_height - 29, (LocalPlayer.Health / LocalPlayer.maxHealth) * screen_width / 10 -2 , 18)
    love.graphics.setColor(math.abs(LocalPlayer.Health / LocalPlayer.maxHealth - 1), LocalPlayer.Health / LocalPlayer.maxHealth, 0, 1)
    love.graphics.print(tostring(LocalPlayer.Health), size * screen_width / 10 + 30, screen_height -27)

    if LocalPlayer.Health <= 0 then
        love.graphics.draw(Textures.deathTexture, 0,0, 0.1 * math.sin(love.timer.getTime() * 10), screen_width / Textures.deathTexture:getWidth(), screen_height/Textures.deathTexture:getHeight(), 0, 0, nil, nil, nil)
    end

    -- DrawRotatedRectangle("fill", player.x + 25, -player.y + 200, 10, 1, player.angle)
    
    
end


--function used just for the minimap lol
function DrawRotatedRectangle(mode, x, y, width, height, angle)
	-- We cannot rotate the rectangle directly, but we
	-- can move and rotate the coordinate system.
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(-angle)
	love.graphics.rectangle(mode, 0, 0, width, height) -- origin in the top left corner
--	love.graphics.rectangle(mode, -width/2, -height/2, width, height) -- origin in the middle
	love.graphics.pop()
end


return Draw
