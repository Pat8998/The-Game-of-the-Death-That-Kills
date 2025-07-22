Draw = {}
Textures = require("libs.textures")


function Draw:Menu(Buttons)
    for key, button in pairs(Buttons) do
        button:draw()
    end
end

function Draw.LoadingScreen()
    love.graphics.print("DROP FILE", 500, 500)
    --Spin a Circle ??
    love.graphics.setBackgroundColor(0.2, 0.2, 0.9, 1)
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
    local large_sreen_width = params.large_sreen_width
    local WallsHeight       = params.WallsHeight
    local Entities          = params.Entities
    local Players           = params.Players

    -- Draw the player indicator and FPS/debug info
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.print(fps)

    love.graphics.print("x: " .. tostring(player.x), 0, 20)
    love.graphics.print("y: " .. tostring(player.y), 0, 40)
    love.graphics.print("angle: " .. tostring(player.angle * 180 / math.pi), 0, 60)
    love.graphics.print(Game.Debug, 0, 80)

    local TTD = {}
    local types = {
        "wall",
        "entity",
        "player"
    }
    for _, v in pairs(Walls) do TTD[_] = v v.type = types[1] end
    for _, v in pairs(Entities.list) do TTD[_] = v v.type = types[2] end
    for _, v in pairs(Players.list) do TTD[_] = v v.type = types[3] end
    if Game.InHostedGame then
        table.sort(TTD, function(a, b)
            return love.physics.getDistance(a.fixture, player.fixture) > love.physics.getDistance(b.fixture, player.fixture)
        end)
    else
        for _, v in pairs(TTD) do
            if v.type == "wall" then
                v.dist = math.sqrt(((v.pos[1][1] + v.pos[2][1])/2 - player.x)^2 + ((v.pos[1][2] + v.pos[2][2])/2 - player.y)^2)
            else
                v.dist = math.sqrt((v.x - player.x)^2 + (v.y - player.y)^2)
            end
        end
        table.sort(TTD, function(a, b)
            return a.dist > b.dist
        end)
    end

    -- Draw walls
    love.graphics.setColor(255, 255, 255, 255)

    for key, object in pairs(TTD) do
        if object.type == "wall" then
            love.graphics.setLineWidth(1)
                local relative_pos = {
                    s = { x = object.pos[1][1] - player.x, y = object.pos[1][2] - player.y },
                    e = { x = object.pos[2][1] - player.x, y = object.pos[2][2] - player.y }
                }
                local angle = {
                    ---@diagnostic disable-next-line: deprecated
                    s = math.atan2(relative_pos.s.y, relative_pos.s.x) - player.angle + player.fov / 2,
                    ---@diagnostic disable-next-line: deprecated
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
                local height = {
                    s = player.ScaleFactor * WallsHeight * screen_height / dist.s,
                    e = player.ScaleFactor * WallsHeight * screen_height / dist.e
                }
                local vertices = {
                    screen_pos.s, screen_height / 2 + height.s,
                    screen_pos.s, screen_height / 2 - height.s,
                    screen_pos.e, screen_height / 2 - height.e,
                    screen_pos.e, screen_height / 2 + height.e
                }
                love.graphics.setColor(1, 63/255, 194/255)
                love.graphics.polygon('fill', vertices)
                love.graphics.setColor(197/255, 49/255, 150/255)
                love.graphics.polygon('line', vertices)
                
                vertices = {
                    -- { vertices[1], vertices[2], 0, 0 },
                    -- { vertices[3], vertices[4], 0, 1 },
                    -- { vertices[5], vertices[6], 1, 1 },
                    -- { vertices[7], vertices[8], 1, 0 }
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
            
            local relative_pos = {
                x = x - player.x,
                y = y - player.y
            }
            ---@diagnostic disable-next-line: deprecated
            local angle = math.atan2(relative_pos.y, relative_pos.x) - player.angle + player.fov / 2
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

        else
            local otherplayer = object
            -- Draw other players
            -- print(otherplayer.y)
            local x, y = otherplayer.x, otherplayer.y
            love.graphics.points(x + 25, -y + 200)
            
            local relative_pos = {
                x = x - player.x,
                y = y - player.y
            }
            ---@diagnostic disable-next-line: deprecated
            local angle = math.atan2(relative_pos.y, relative_pos.x) - player.angle + player.fov / 2
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
            -- local w, h = otherplayer.shape:getRadius() * 2, otherplayer.shape:getRadius() * 2
            local w, h = 2 * (math.atan(2/dist) * screen_width) / player.fov, 5 * screen_height / dist        --so far radius =2
            love.graphics.setColor(0.001, 1, 0.001)
            love.graphics.setLineWidth(5)
            love.graphics.rectangle("line", screen_pos.x - w/2 , screen_pos.y - h/2, w, h)
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(Textures.ayakakaTexture, screen_pos.x - w/2 , screen_pos.y - h/2, 0, w / Textures.ayakakaTexture:getWidth(), h / Textures.ayakakaTexture:getHeight())
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
            -- x = (LocalPlayer.isZooming and -1 or 1) * (LocalPlayer.fov - math.pi/2) * (LocalPlayer.fov - math.pi/3),
            y = 0.5 * (LocalPlayer.isZooming and (LocalPlayer.fov/(math.pi/3) - 1) or  - (LocalPlayer.fov/(math.pi/2) - 1))
        }
        local weaponText = (LocalPlayer.weapon.name .. weaponScale) or "<3"
        love.graphics.print(weaponText, screen_width - 8 * weaponText:len(), 5, 1, 2, 2)
        love.graphics.draw(weaponIMG,
        (LocalPlayer.isZooming and screen_width/2 - weaponIMG:getWidth()/2 * weaponScale * size) or (screen_width - weaponIMG:getWidth() * weaponScale * size),
        LocalPlayer.isZooming and 0 or screen_height - weaponIMG:getHeight() * weaponScale * size,
        0,
        weaponScale * size,
        nil, nil, nil,
        weaponShearing.x, weaponShearing.y)
    end
    
    --LIFEBAR
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 20, screen_height - 30, size * screen_width / 10, 20)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", 21, screen_height - 29, (LocalPlayer.Health / LocalPlayer.maxHealth) * screen_width / 10 -2 , 18)
    love.graphics.setColor(math.abs(LocalPlayer.Health / LocalPlayer.maxHealth - 1), LocalPlayer.Health / LocalPlayer.maxHealth, 0, 1)
    love.graphics.print(tostring(LocalPlayer.Health), size * screen_width / 10 + 30, screen_height -27)



    -- DrawRotatedRectangle("fill", player.x + 25, -player.y + 200, 10, 1, player.angle)
    
    
end

function SortWalls(walls, player)
    -- table.sort(walls, function(a, b)
    -- local dist_a = {
    --     s = math.sqrt((a[1][1] - player.x)^2 + (a[1][2] - player.y)^2),
    --     e = math.sqrt((a[2][1] - player.x)^2 + (a[2][2] - player.y)^2)
    -- }
    -- local dist_b = {
    --     s = math.sqrt((b[1][1] - player.x)^2 + (b[1][2] - player.y)^2),
    --     e = math.sqrt((b[2][1] - player.x)^2 + (b[2][2] - player.y)^2)
    -- }
    -- local min_dist_a = math.min(dist_a.s, dist_a.e)
    -- local min_dist_b = math.min(dist_b.s, dist_b.e)

    -- return min_dist_a > min_dist_b
    -- end)


    --Sorting the walls
    table.sort(walls, function(a, b)
        -- Calculate the midpoint of wall 'a'
        local mid_a_x = (a.pos[1][1] + a.pos[2][1]) / 2
        local mid_a_y = (a.pos[1][2] + a.pos[2][2]) / 2

        -- Calculate the distance from player to the midpoint of wall 'a'
        local dist_a = math.sqrt((mid_a_x - player.x)^2 + (mid_a_y - player.y)^2)

        -- Calculate the midpoint of wall 'b'
        local mid_b_x = (b.pos[1][1] + b.pos[2][1]) / 2
        local mid_b_y = (b.pos[1][2] + b.pos[2][2]) / 2

        -- Calculate the distance from player to the midpoint of wall 'b'
        local dist_b = math.sqrt((mid_b_x - player.x)^2 + (mid_b_y - player.y)^2)

        -- Compare the distances
        return dist_a > dist_b
    end)

    return walls
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