Draw = {}



function Draw:Menu(Buttons)
    for key, button in pairs(Buttons) do
        button:draw()
    end
end

function Draw.InGame(params)

    -- Extract variables from the passed table
    local player            = params.player
    local fps               = params.fps
    local Debug             = params.Debug
    local DrawRotatedRectangle = params.DrawRotatedRectangle
    local SortWalls         = params.SortWalls
    local Walls             = params.Walls
    local screen_width      = params.screen_width
    local screen_height     = params.screen_height
    local large_sreen_width = params.large_sreen_width
    local WallsHeight       = params.WallsHeight
    local Entities          = params.Entities

    -- Draw the player indicator and FPS/debug info
    love.graphics.setColor(255, 0, 0, 255)
    DrawRotatedRectangle("fill", player.x + 25, -player.y + 200, 10, 1, player.angle)
    love.graphics.print(fps)

    love.graphics.print("x: " .. tostring(player.x), 0, 20)
    love.graphics.print("y: " .. tostring(player.y), 0, 40)
    love.graphics.print("angle: " .. tostring(player.angle * 180 / math.pi), 0, 60)
    love.graphics.print(Debug, 0, 80)

    -- Draw walls
    love.graphics.setColor(255, 255, 255, 255)
    local sortedWalls = SortWalls(Walls)
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
            s = WallsHeight * screen_height / dist.s,
            e = WallsHeight * screen_height / dist.e
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

        -- Draw the minimap line for the wall
        love.graphics.line(value.pos[1][1] + 25, -value.pos[1][2] + 200, value.pos[2][1] + 25, -value.pos[2][2] + 200)
    end

    -- Draw entities
    for key, entity in pairs(Entities.list) do
        local x, y = entity.body:getPosition()
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
        love.graphics.circle("fill", screen_pos.x, screen_pos.y, math.min(100 / dist, 100), 500)
    end
end



return Draw