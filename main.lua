--RATHER THAN ADJUSTING THE ANGLES
--HOW ABOUT I ADJUST SCREEN POSITIONNING
--SO WHEN ITS LIKE OVER 360 * width /FOV = large_sreen_width
-- IT IS RATHER just over 0
-- for both coordinates
-- See ya


local mouse ={x=0, y=0, lb=false, rb=false, mb=false}
local fps
local WallsHeight = 2
local test = "nil"
local data = {}
local Walls = {}
local Debug = "Debug"
--canvas is great
--color mask for color



-- initialization
function love.load()
    love.window.setTitle("Title")
    love.window.setMode(1920, 1080, {fullscreen = false})
    love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))


    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
	-- world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    Walls = {{pos = {{0, 0}, {10, 0}}},
    {pos = {{10, 10}, {0, 10}}},
    {pos = {{0, 10}, {0, 0}}},
    {pos = {{20, 0}, {20, 10}}},
    {pos = {{20, 10}, {10, 10}}},
    {pos = {{30, 10}, {20, 10}}},
    {pos = {{20, 10}, {20, 0}}},
    {pos = {{30, 0}, {40, 0}}},
    {pos = {{40, 10}, {30, 10}}},
    {pos = {{50, 0}, {50, 10}}},
    {pos = {{50, 10}, {40, 10}}},
    {pos = {{60, 10}, {50, 10}}},
    {pos = {{50, 10}, {50, 0}}},
    {pos = {{70, 0}, {70, 10}}},
    {pos = {{70, 10}, {60, 10}}},
    {pos = {{70, 0}, {80, 0}}},
    {pos = {{80, 10}, {70, 10}}},
    {pos = {{70, 10}, {70, 0}}},
    {pos = {{80, 0}, {90, 0}}},
    {pos = {{90, 10}, {80, 10}}},
    {pos = {{100, 0}, {100, 10}}},
    {pos = {{100, 10}, {90, 10}}},
    {pos = {{10, 10}, {10, 20}}},
    {pos = {{10, 20}, {0, 20}}},
    {pos = {{0, 20}, {0, 10}}},
    {pos = {{20, 10}, {20, 20}}},
    {pos = {{10, 20}, {10, 10}}},
    {pos = {{30, 10}, {30, 20}}},
    {pos = {{20, 20}, {20, 10}}},
    {pos = {{40, 10}, {40, 20}}},
    {pos = {{40, 20}, {30, 20}}},
    {pos = {{30, 20}, {30, 10}}},
    {pos = {{40, 10}, {50, 10}}},
    {pos = {{40, 20}, {40, 10}}},
    {pos = {{50, 10}, {60, 10}}},
    {pos = {{60, 10}, {60, 20}}},
    {pos = {{70, 10}, {70, 20}}},
    {pos = {{60, 20}, {60, 10}}},
    {pos = {{80, 20}, {70, 20}}},
    {pos = {{70, 20}, {70, 10}}},
    {pos = {{80, 10}, {90, 10}}},
    {pos = {{90, 20}, {80, 20}}},
    {pos = {{100, 10}, {100, 20}}},
    {pos = {{10, 20}, {10, 30}}},
    {pos = {{0, 30}, {0, 20}}},
    {pos = {{10, 20}, {20, 20}}},
    {pos = {{10, 30}, {10, 20}}},
    {pos = {{20, 20}, {30, 20}}},
    {pos = {{30, 20}, {30, 30}}},
    {pos = {{30, 20}, {40, 20}}},
    {pos = {{30, 30}, {30, 20}}},
    {pos = {{40, 20}, {50, 20}}},
    {pos = {{50, 30}, {40, 30}}},
    {pos = {{60, 20}, {60, 30}}},
    {pos = {{60, 30}, {50, 30}}},
    {pos = {{60, 20}, {70, 20}}},
    {pos = {{60, 30}, {60, 20}}},
    {pos = {{70, 20}, {80, 20}}},
    {pos = {{80, 20}, {80, 30}}},
    {pos = {{90, 20}, {90, 30}}},
    {pos = {{90, 30}, {80, 30}}},
    {pos = {{80, 30}, {80, 20}}},
    {pos = {{100, 20}, {100, 30}}},
    {pos = {{90, 30}, {90, 20}}},
    {pos = {{0, 40}, {0, 30}}},
    {pos = {{20, 40}, {10, 40}}},
    {pos = {{20, 30}, {30, 30}}},
    {pos = {{30, 40}, {20, 40}}},
    {pos = {{30, 30}, {40, 30}}},
    {pos = {{40, 40}, {30, 40}}},
    {pos = {{40, 30}, {50, 30}}},
    {pos = {{50, 40}, {40, 40}}},
    {pos = {{60, 30}, {60, 40}}},
    {pos = {{70, 40}, {60, 40}}},
    {pos = {{60, 40}, {60, 30}}},
    {pos = {{70, 30}, {80, 30}}},
    {pos = {{80, 40}, {70, 40}}},
    {pos = {{90, 30}, {90, 40}}},
    {pos = {{100, 30}, {100, 40}}},
    {pos = {{90, 40}, {90, 30}}},
    {pos = {{10, 40}, {10, 50}}},
    {pos = {{0, 50}, {0, 40}}},
    {pos = {{10, 40}, {20, 40}}},
    {pos = {{10, 50}, {10, 40}}},
    {pos = {{30, 40}, {30, 50}}},
    {pos = {{30, 50}, {20, 50}}},
    {pos = {{30, 40}, {40, 40}}},
    {pos = {{40, 50}, {30, 50}}},
    {pos = {{30, 50}, {30, 40}}},
    {pos = {{40, 40}, {50, 40}}},
    {pos = {{50, 50}, {40, 50}}},
    {pos = {{50, 40}, {60, 40}}},
    {pos = {{60, 40}, {60, 50}}},
    {pos = {{60, 40}, {70, 40}}},
    {pos = {{60, 50}, {60, 40}}},
    {pos = {{80, 40}, {80, 50}}},
    {pos = {{80, 50}, {70, 50}}},
    {pos = {{90, 40}, {90, 50}}},
    {pos = {{80, 50}, {80, 40}}},
    {pos = {{100, 40}, {100, 50}}},
    {pos = {{90, 50}, {90, 40}}},
    {pos = {{0, 50}, {10, 50}}},
    {pos = {{0, 60}, {0, 50}}},
    {pos = {{10, 50}, {20, 50}}},
    {pos = {{20, 50}, {20, 60}}},
    {pos = {{20, 60}, {10, 60}}},
    {pos = {{20, 50}, {30, 50}}},
    {pos = {{20, 60}, {20, 50}}},
    {pos = {{30, 50}, {40, 50}}},
    {pos = {{40, 60}, {30, 60}}},
    {pos = {{50, 60}, {40, 60}}},
    {pos = {{60, 60}, {50, 60}}},
    {pos = {{70, 50}, {70, 60}}},
    {pos = {{70, 60}, {60, 60}}},
    {pos = {{80, 50}, {80, 60}}},
    {pos = {{70, 60}, {70, 50}}},
    {pos = {{80, 50}, {90, 50}}},
    {pos = {{80, 60}, {80, 50}}},
    {pos = {{90, 50}, {100, 50}}},
    {pos = {{100, 50}, {100, 60}}},
    {pos = {{10, 70}, {0, 70}}},
    {pos = {{0, 70}, {0, 60}}},
    {pos = {{10, 60}, {20, 60}}},
    {pos = {{20, 70}, {10, 70}}},
    {pos = {{20, 60}, {30, 60}}},
    {pos = {{30, 70}, {20, 70}}},
    {pos = {{40, 60}, {40, 70}}},
    {pos = {{40, 70}, {30, 70}}},
    {pos = {{40, 60}, {50, 60}}},
    {pos = {{50, 60}, {50, 70}}},
    {pos = {{40, 70}, {40, 60}}},
    {pos = {{60, 60}, {60, 70}}},
    {pos = {{50, 70}, {50, 60}}},
    {pos = {{60, 60}, {70, 60}}},
    {pos = {{70, 60}, {70, 70}}},
    {pos = {{60, 70}, {60, 60}}},
    {pos = {{80, 60}, {80, 70}}},
    {pos = {{70, 70}, {70, 60}}},
    {pos = {{90, 70}, {80, 70}}},
    {pos = {{80, 70}, {80, 60}}},
    {pos = {{100, 60}, {100, 70}}},
    {pos = {{100, 70}, {90, 70}}},
    {pos = {{10, 70}, {10, 80}}},
    {pos = {{0, 80}, {0, 70}}},
    {pos = {{10, 70}, {20, 70}}},
    {pos = {{20, 80}, {10, 80}}},
    {pos = {{10, 80}, {10, 70}}},
    {pos = {{20, 70}, {30, 70}}},
    {pos = {{30, 80}, {20, 80}}},
    {pos = {{30, 70}, {40, 70}}},
    {pos = {{40, 70}, {50, 70}}},
    {pos = {{50, 80}, {40, 80}}},
    {pos = {{60, 70}, {60, 80}}},
    {pos = {{70, 80}, {60, 80}}},
    {pos = {{60, 80}, {60, 70}}},
    {pos = {{70, 70}, {80, 70}}},
    {pos = {{80, 70}, {80, 80}}},
    {pos = {{90, 70}, {90, 80}}},
    {pos = {{80, 80}, {80, 70}}},
    {pos = {{90, 70}, {100, 70}}},
    {pos = {{100, 70}, {100, 80}}},
    {pos = {{90, 80}, {90, 70}}},
    {pos = {{0, 90}, {0, 80}}},
    {pos = {{20, 80}, {20, 90}}},
    {pos = {{20, 90}, {10, 90}}},
    {pos = {{30, 90}, {20, 90}}},
    {pos = {{20, 90}, {20, 80}}},
    {pos = {{30, 80}, {40, 80}}},
    {pos = {{40, 90}, {30, 90}}},
    {pos = {{50, 80}, {50, 90}}},
    {pos = {{50, 90}, {40, 90}}},
    {pos = {{50, 80}, {60, 80}}},
    {pos = {{60, 80}, {60, 90}}},
    {pos = {{50, 90}, {50, 80}}},
    {pos = {{70, 80}, {70, 90}}},
    {pos = {{60, 90}, {60, 80}}},
    {pos = {{70, 80}, {80, 80}}},
    {pos = {{80, 90}, {70, 90}}},
    {pos = {{70, 90}, {70, 80}}},
    {pos = {{80, 80}, {90, 80}}},
    {pos = {{100, 80}, {100, 90}}},
    {pos = {{100, 90}, {90, 90}}},
    {pos = {{0, 90}, {10, 90}}},
    {pos = {{10, 90}, {10, 100}}},
    {pos = {{0, 100}, {0, 90}}},
    {pos = {{10, 90}, {20, 90}}},
    {pos = {{10, 100}, {10, 90}}},
    {pos = {{20, 90}, {30, 90}}},
    {pos = {{30, 90}, {40, 90}}},
    {pos = {{40, 90}, {40, 100}}},
    {pos = {{40, 100}, {30, 100}}},
    {pos = {{40, 90}, {50, 90}}},
    {pos = {{40, 100}, {40, 90}}},
    {pos = {{50, 90}, {60, 90}}},
    {pos = {{60, 100}, {50, 100}}},
    {pos = {{60, 90}, {70, 90}}},
    {pos = {{70, 90}, {80, 90}}},
    {pos = {{80, 100}, {70, 100}}},
    {pos = {{80, 90}, {90, 90}}},
    {pos = {{90, 100}, {80, 100}}},
    {pos = {{90, 90}, {100, 90}}},
    {pos = {{100, 90}, {100, 100}}}
        -- {{100,100}, {100, 200}},
        --  {{100,100}, {200, 100}},
        -- {{200,200}, {100, 200}},
        -- {{200,200}, {200, 100}
    }
    player = { x = 90, y = 204, angle = -32*math.pi/180 , fov = math.pi/2, shape = love.physics.newCircleShape(2), mx = 0, my = 0}
    player.body = love.physics.newBody(world,player.x,player.y,"dynamic")
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    player.fixture:setUserData("player")for key, Wall in pairs(Walls) do
        Wall.body = love.physics.newBody(world, Wall.pos[1][1], Wall.pos[1][2], "static")        -- Create the body at the first point of the wall
        -- Adjust the shape coordinates relative to the body's position
        local x1, y1 = 0, 0  -- Relative to Wall.body's position (Wall.pos[1])
        local x2, y2 = Wall.pos[2][1] - Wall.pos[1][1], Wall.pos[2][2] - Wall.pos[1][2]
        -- Create the shape with corrected coordinates
        Wall.shape = love.physics.newEdgeShape(x1, y1, x2, y2)
        -- Attach the shape to the body
        Wall.fixture = love.physics.newFixture(Wall.body, Wall.shape, 1)
        Wall.fixture:setUserData("wall" .. key)
    end
end



function love.update(dt)
    local dmouse = {x=love.mouse.getPosition()-mouse.x, y= love.mouse.getPosition()-mouse.y}
    mouse.x, mouse.y = love.mouse.getPosition()
    if not love.keyboard.isDown("lalt") and love.window.hasFocus() then
        love.mouse.setGrabbed(true)
        love.mouse.setVisible(false)
        player.angle = player.angle - dmouse.x/40
        if player.angle>2*math.pi then
            player.angle = player.angle - 2*math.pi
        elseif player.angle>2*math.pi then
            player.angle = player.angle + 2*math.pi
        end
        if mouse.x <= 0 then
            love.mouse.setPosition(love.graphics.getWidth(), mouse.y)
        elseif mouse.x >= love.graphics.getWidth()-1 then
            love.mouse.setPosition(0, mouse.y)
        end
        mouse.x, mouse.y = love.mouse.getPosition()
    else
        love.mouse.setGrabbed(false)
        love.mouse.setVisible(true)
    end



    -- if love.keyboard.isDown("left") then
    --     player.angle = player.angle - dt * 2
    -- elseif love.keyboard.isDown("right") then
    --     player.angle = player.angle + dt * 2
    -- end

    local moveSpeed = dt * 500
    if love.keyboard.isDown("lshift") then
        moveSpeed = dt*2200
    end
    if love.keyboard.isDown("z") then
         player.mx =   math.cos(player.angle) * moveSpeed
         player.my =   math.sin(player.angle) * moveSpeed
    elseif love.keyboard.isDown("s") then
         player.mx = - math.cos(player.angle) * moveSpeed
         player.my = - math.sin(player.angle) * moveSpeed
    end
    if love.keyboard.isDown("d") then
         player.mx = - math.cos(player.angle+math.pi/2) * moveSpeed
         player.my = - math.sin(player.angle+math.pi/2) * moveSpeed
    elseif love.keyboard.isDown("q") then
         player.mx =   math.cos(player.angle+math.pi/2) * moveSpeed
         player.my =   math.sin(player.angle+math.pi/2) * moveSpeed
    end
    player.body:setLinearVelocity(player.mx, player.my)
    player.mx, player.my = 0, 0
    if love.mouse.isDown(2) then
        player.fov = math.max(math.pi / 3, player.fov - math.pi/6*dt*4)
        WallsHeight = math.min(3, WallsHeight + dt*4)
    else
        player.fov = math.min(math.pi / 2, player.fov + math.pi/6*dt*4)
        WallsHeight = math.max(2, WallsHeight - dt*4)
    end


    -- Normalize angles to be within -pi to pi
        if player.angle < -math.pi then
            player.angle = player.angle + 2 * math.pi
        elseif player.angle > math.pi then
            player.angle = player.angle - 2 * math.pi
        end

    world:update(dt)
    player.x, player.y = player.body:getPosition()
    fps=dt*3600
end

function love.draw()
    local screen_width = love.graphics.getWidth()
    local large_sreen_width = 2*math.pi*screen_width/player.fov
    love.graphics.setColor(255, 0, 0, 255)
    DrawRotatedRectangle("fill", player.x, -player.y +200, 20, 1, player.angle)
    love.graphics.print(fps)

    love.graphics.print("x: " .. tostring(player.x), 0,20)
    love.graphics.print("y: " .. tostring(player.y), 0,40)
    love.graphics.print("angle: " .. tostring(player.angle*180/math.pi), 0,60)
	love.graphics.print(Debug, 0, 80)

    love.graphics.setColor(255, 255, 255, 255)
    local Walls = SortWalls(Walls)
    for key, value in pairs(Walls) do
        local relative_pos = {
            s = {x = value.pos[1][1] - player.x, y = value.pos[1][2] - player.y},
            e = {x = value.pos[2][1] - player.x, y = value.pos[2][2] - player.y}
        }
        local angle = {
---@diagnostic disable-next-line: deprecated
            s = math.atan2(relative_pos.s.y, relative_pos.s.x) - player.angle + player.fov / 2,
---@diagnostic disable-next-line: deprecated
            e = math.atan2(relative_pos.e.y, relative_pos.e.x) - player.angle + player.fov / 2
        }
        if math.abs(angle.s-angle.e) > math.pi then
            if angle.s-angle.e >0 then
                angle.e = angle.e + 2*math.pi
            elseif angle.s-angle.e <0  then
                angle.e = angle.e - 2*math.pi
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

        if screen_pos.s > large_sreen_width or screen_pos.e >large_sreen_width then
            screen_pos.s, screen_pos.e = screen_pos.s - large_sreen_width, screen_pos.e -large_sreen_width
        elseif screen_pos.s < -large_sreen_width+screen_width or screen_pos.e < -large_sreen_width+screen_width  then
            screen_pos.s, screen_pos.e = screen_pos.s + large_sreen_width, screen_pos.e + large_sreen_width
        end
        local height = {
            s = WallsHeight*love.graphics.getHeight() / (dist.s),
            e = WallsHeight*love.graphics.getHeight() / (dist.e)
        }
        local vertices = {
            screen_pos.s, love.graphics.getHeight() / 2 + height.s,
            screen_pos.s, love.graphics.getHeight() / 2 - height.s,
            screen_pos.e, love.graphics.getHeight() / 2 - height.e,
            screen_pos.e, love.graphics.getHeight() / 2 + height.e
        }
        --love.graphics.setColor((key == 1 or key == 4) and 1 or 0, (key == 2 or key == 4) and 1 or 0, key == 3 and 1 or 0)
        love.graphics.setColor(1, 63/255, 194/255)
        love.graphics.polygon( 'fill', vertices)
        love.graphics.setColor(197/255, 49/255, 150/255)
        love.graphics.polygon( 'line', vertices)

        -- if key == 4 then
        --     print(  angle.s-angle.e)
        -- end

        --MINImap :

        love.graphics.line(value.pos[1][1], -value.pos[1][2]+200, value.pos[2][1], -value.pos[2][2]+200)
        end

end

function love.keypressed(key)
    if key == "end" then
        love.window.close()
    end
    if key == "c" then
        love.mouse.setCursor(love.mouse.newCursor("ayakaka.png", 0, 0))
    end
    if key == "lalt" then
        love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
end



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

function SortWalls(walls)
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
    -- Sorting the walls
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







-- function beginContact(a, b, coll)
-- 	Persisting = 1
-- 	local x, y = coll:getNormal()
-- 	local textA = a:getUserData()
-- 	local textB = b:getUserData()
-- -- Get the normal vector of the collision and concatenate it with the collision information
-- 	Text = Text.."\n 1.)" .. textA.." colliding with "..textB.." with a vector normal of: ("..x..", "..y..")"
-- 	love.window.setTitle ("Persisting: "..Persisting)
-- end

-- function endContact(a, b, coll)
-- 	Persisting = 0
-- 	local textA = a:getUserData()
-- 	local textB = b:getUserData()
-- -- Update the Text to indicate that the objects are no longer colliding
-- 	Text = Text.."\n 3.)" .. textA.." uncolliding with "..textB
-- 	love.window.setTitle ("Persisting: "..Persisting)
-- end

-- function preSolve(a, b, coll)
-- 	if Persisting == 1 then
-- 	local textA = a:getUserData()
-- 	local textB = b:getUserData()
-- -- If this is the first update where the objects are touching, add a message to the Text
-- 		Text = Text.."\n 2.)" .. textA.." touching "..textB..": "..Persisting
-- 	elseif Persisting <= 10 then
-- -- If the objects have been touching for less than 20 updates, add a count to the Text
-- 		Text = Text.." "..Persisting
-- 	end
	
-- -- Update the Persisting counter to keep track of how many updates the objects have been touching
-- 	Persisting = Persisting + 1
-- 	love.window.setTitle ("Persisting: "..Persisting)
-- end

-- function postSolve(a, b, coll, normalimpulse, tangentimpulse)
-- -- This function is empty, no actions are performed after the collision resolution
-- -- It can be used to gather additional information or perform post-collision calculations if needed
-- end