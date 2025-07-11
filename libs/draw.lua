Draw = {}



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
    DrawRotatedRectangle("fill", player.x + 25, -player.y + 200, 10, 1, player.angle)
    love.graphics.print(fps)

    love.graphics.print("x: " .. tostring(player.x), 0, 20)
    love.graphics.print("y: " .. tostring(player.y), 0, 40)
    love.graphics.print("angle: " .. tostring(player.angle * 180 / math.pi), 0, 60)
    love.graphics.print(Game.Debug, 0, 80)

    -- Draw walls
    love.graphics.setColor(255, 255, 255, 255)
    local sortedWalls = SortWalls(Walls, player)
    for key, value in pairs(sortedWalls) do
        local relative_pos = {
            s = { x = value.pos[1][1] - player.x, y = value.pos[1][2] - player.y },
            e = { x = value.pos[2][1] - player.x, y = value.pos[2][2] - player.y }
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
            { vertices[1], vertices[2], 0, 0 },
            { vertices[3], vertices[4], 0, 1 },
            { vertices[5], vertices[6], 1, 1 },
            { vertices[7], vertices[8], 1, 0 }
        }
        local mesh = love.graphics.newMesh(vertices)
        mesh:setTexture(Textures.wallTexture, "fan")
        love.graphics.draw(mesh)




        -- Draw the minimap line for the wall
        love.graphics.line(value.pos[1][1] + 25, -value.pos[1][2] + 200, value.pos[2][1] + 25, -value.pos[2][2] + 200)
    end

    -- Draw entities
    for key, entity in pairs(Entities.list) do
        local x, y = entity.x, entity.y or entity.body:getPosition()
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
    end
    love.graphics.setColor(0.001, 1, 0.001)
    for key, otherplayer in pairs(Players.list) do
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
        love.graphics.rectangle("fill", screen_pos.x, screen_pos.y, 0.4 * screen_width / (dist), 0.8 * screen_height / dist)
    end
    HUD(
        player
    )
end

function HUD(LocalPlayer)
    local size = 1
    --LIFEBAR
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 20, love.graphics.getHeight() - 30, size * love.graphics.getWidth() / 10, 20)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", 21, love.graphics.getHeight() - 29, (LocalPlayer.Health / LocalPlayer.maxHealth) * love.graphics.getWidth() / 10 -2 , 18)
    love.graphics.setColor(math.abs(LocalPlayer.Health / LocalPlayer.maxHealth - 1), LocalPlayer.Health / LocalPlayer.maxHealth, 0, 1)
    love.graphics.print(tostring(LocalPlayer.Health), size * love.graphics.getWidth() / 10 + 30, love.graphics.getHeight() -27)
    
    
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