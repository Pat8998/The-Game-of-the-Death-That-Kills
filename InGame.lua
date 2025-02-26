local InGame = {}

function InGame.updateHost(params)
    -- Extract variables from the params table
    local dt = params.dt
    local players = params.players
    local player = params.localplayer
    local dmouse = params.dmouse
    local mouse = params.mouse
    local world = params.world
    local WallsHeight = params.WallsHeight
    local Shoot = params.Shoot
    local Entities = params.Entities
    local DestroyEntity = params.DestroyEntity

    -- Update mouse and player angle
    if not love.keyboard.isDown("lalt") and love.window.hasFocus() then
        love.mouse.setGrabbed(true)
        love.mouse.setVisible(false)
        player.angle = player.angle - dmouse.x / 40
        if player.angle > 2 * math.pi then
            player.angle = player.angle - 2 * math.pi
        elseif player.angle < -2 * math.pi then  -- Assuming you want to normalize negative angles too
            player.angle = player.angle + 2 * math.pi
        end
        if mouse.x <= 0 then
            love.mouse.setPosition(love.graphics.getWidth(), mouse.y)
        elseif mouse.x >= love.graphics.getWidth() - 1 then
            love.mouse.setPosition(0, mouse.y)
        end
        mouse.x, mouse.y = love.mouse.getPosition()
    else
        love.mouse.setGrabbed(false)
        love.mouse.setVisible(true)
    end

    -- Determine move speed
    local moveSpeed = dt * 500
    if love.keyboard.isDown("lshift") then
        moveSpeed = dt * 2200
    end

    -- Update movement based on keys pressed
    if love.keyboard.isDown("z") then
        player.mx = math.cos(player.angle) * moveSpeed
        player.my = math.sin(player.angle) * moveSpeed
    elseif love.keyboard.isDown("s") then
        player.mx = -math.cos(player.angle) * moveSpeed
        player.my = -math.sin(player.angle) * moveSpeed
    end
    if love.keyboard.isDown("d") then
        player.mx = -math.cos(player.angle + math.pi / 2) * moveSpeed
        player.my = -math.sin(player.angle + math.pi / 2) * moveSpeed
    elseif love.keyboard.isDown("q") then
        player.mx = math.cos(player.angle + math.pi / 2) * moveSpeed
        player.my = math.sin(player.angle + math.pi / 2) * moveSpeed
    end

    player.body:setLinearVelocity(player.mx, player.my)
    player.mx, player.my = 0, 0

    if love.mouse.isDown(2) then
        player.fov = math.max(math.pi / 3, player.fov - math.pi / 6 * dt * 4)
        WallsHeight = math.min(3, WallsHeight + dt * 4)
    else
        player.fov = math.min(math.pi / 2, player.fov + math.pi / 6 * dt * 4)
        WallsHeight = math.max(2, WallsHeight - dt * 4)
    end

    if mouse.lb then
        Shoot(dt, player, 0.1, "default")
    end

    -- Normalize angles to be within -pi to pi
    if player.angle < -math.pi then
        player.angle = player.angle + 2 * math.pi
    elseif player.angle > math.pi then
        player.angle = player.angle - 2 * math.pi
    end





    --update othe players





    world:update(dt)
    player.x, player.y = player.body:getPosition()

    for key, entity in pairs(Entities.list) do
        if entity.fixture:getUserData() == "bullet" then
            entity.life = entity.life - dt
            print(entity.life)
            if entity.life <= 0 then
                DestroyEntity(entity)
            end
        end
    end
end



function InGame.updateClient(params)
    -- Extract variables from the params table
    local dt = params.dt
    local player = params.player
    local dmouse = params.dmouse
    local mouse = params.mouse
    local world = params.world
    local WallsHeight = params.WallsHeight
    local Shoot = params.Shoot
    local Entities = params.Entities
    local DestroyEntity = params.DestroyEntity

    -- Update mouse and player angle
    if not love.keyboard.isDown("lalt") and love.window.hasFocus() then
        love.mouse.setGrabbed(true)
        love.mouse.setVisible(false)
        player.angle = player.angle - dmouse.x / 40
        if player.angle > 2 * math.pi then
            player.angle = player.angle - 2 * math.pi
        elseif player.angle < -2 * math.pi then  -- Assuming you want to normalize negative angles too
            player.angle = player.angle + 2 * math.pi
        end
        if mouse.x <= 0 then
            love.mouse.setPosition(love.graphics.getWidth(), mouse.y)
        elseif mouse.x >= love.graphics.getWidth() - 1 then
            love.mouse.setPosition(0, mouse.y)
        end
        mouse.x, mouse.y = love.mouse.getPosition()
    else
        love.mouse.setGrabbed(false)
        love.mouse.setVisible(true)
    end

    -- Determine move speed
    local moveSpeed = dt * 500
    if love.keyboard.isDown("lshift") then
        moveSpeed = dt * 2200
    end

    -- Update movement based on keys pressed
    if love.keyboard.isDown("z") then
        player.mx = math.cos(player.angle) * moveSpeed
        player.my = math.sin(player.angle) * moveSpeed
    elseif love.keyboard.isDown("s") then
        player.mx = -math.cos(player.angle) * moveSpeed
        player.my = -math.sin(player.angle) * moveSpeed
    end
    if love.keyboard.isDown("d") then
        player.mx = -math.cos(player.angle + math.pi / 2) * moveSpeed
        player.my = -math.sin(player.angle + math.pi / 2) * moveSpeed
    elseif love.keyboard.isDown("q") then
        player.mx = math.cos(player.angle + math.pi / 2) * moveSpeed
        player.my = math.sin(player.angle + math.pi / 2) * moveSpeed
    end

    player.body:setLinearVelocity(player.mx, player.my)
    player.mx, player.my = 0, 0

    if love.mouse.isDown(2) then
        player.fov = math.max(math.pi / 3, player.fov - math.pi / 6 * dt * 4)
        WallsHeight = math.min(3, WallsHeight + dt * 4)
    else
        player.fov = math.min(math.pi / 2, player.fov + math.pi / 6 * dt * 4)
        WallsHeight = math.max(2, WallsHeight - dt * 4)
    end

    if mouse.lb then
        Shoot(dt, player, 0.1, "default")
    end

    -- Normalize angles to be within -pi to pi
    if player.angle < -math.pi then
        player.angle = player.angle + 2 * math.pi
    elseif player.angle > math.pi then
        player.angle = player.angle - 2 * math.pi
    end

    world:update(dt)
    player.x, player.y = player.body:getPosition()

    for key, entity in pairs(Entities.list) do
        if entity.fixture:getUserData() == "bullet" then
            entity.life = entity.life - dt
            print(entity.life)
            if entity.life <= 0 then
                DestroyEntity(entity)
            end
        end
    end
end

return InGame