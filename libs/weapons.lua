local Weapons = {}

Weapons.list = {
    Default = {
        name = "Default",
        number = 0,
        shootDelay = 0.1,
        BulletDuration = 2,
        speed = 1,
        spread = 10*math.pi / 180,  -- Spread in rads
        damage = 10,
    },
    Shotgun = {
        name = "Shotgun",
        number = 1,
        shootDelay = 0.5,
        BulletDuration = 0.5,
        speed = 0.1,
        spread = 15*math.pi / 180,  -- Spread in rads
        damage = 19,
        bullets = function() return 2 + math.random(3) end,  -- Number of bullets shot at once
    },
    LongRifle = {
        name = "LongRifle",
        number = 2,
        shootDelay = 0.5,
        BulletDuration = 3,
        speed = 2,
        spread = 1*math.pi / 180,  -- Spread in rads
        spreadA = 0,  -- Spread when aimed
        damage = 50,
    },
    Rifle = {
        name = "Rifle",
        number = 3,
        shootDelay = 0.01,
        BulletDuration = 2,
        speed = 1.2,
        spread = 10*math.pi / 180,  -- Spread in rads
        damage = 5,
        mass = 25,
        rechargetime = 1.5,  -- Time to recharge the weapon
        maxmagazine = 50,  -- Maximum number of bullets in the magazine
    },
    -- Ball = {
    --     name = "Ball",
    --     number = 4,
    --     shootDelay = 0.01,
    --     BulletDuration = 2,
    --     speed = 0.5,
    --     spread = 10*math.pi / 180,  -- Spread in rads
    --     damage = 0,
    --     mass = 25,
    -- }
}

Weapons.weaponsNumber = {}
for _, weapon in pairs(Weapons.list) do
    Weapons.weaponsNumber[weapon.number] = weapon.name
    -- print("Weapon loaded: " .. weapon.name .. " with number " .. weapon.number)
end

function Weapons.nextWeapon(player)
        if player.weapon.number >= #Weapons.weaponsNumber then
            player.weapon = Weapons.list[Weapons.weaponsNumber[0]]
        else
            player.weapon = Weapons.list[Weapons.weaponsNumber[player.weapon.number + 1]]
        end
end
function Weapons.previousWeapon(player)
    if player.weapon.number <= 0 then
        player.weapon = Weapons.list[Weapons.weaponsNumber[#Weapons.weaponsNumber]]
    else
        player.weapon = Weapons.list[Weapons.weaponsNumber[player.weapon.number - 1]]
    end
end



function Weapons.Shoot(player, Entities, weapon)
    weapon = weapon or player.weapon or Weapons.list.Default  -- Use player's weapon or default if not specified
    local magazine = player.magazine[weapon.name]
    if love.timer.getTime() > player.NextShoot and magazine ~= 0 and weapon.name ~= "Reload" then
        local bullets = (type(weapon.bullets) == "function" and weapon.bullets() or weapon.bullets) or 1  -- Call function if present
        local spread
        spread = player.isZooming and (weapon.spreadA or weapon.spread /2 or 0) or (weapon.spread or 0)  -- Use spreadA if zooming, otherwise use spread
        repeat
            local body = love.physics.newBody(world, player.x, player.y, "dynamic")
            local fixture = love.physics.newFixture(body, Entities.defaultShapes.bullet, 1)
            local angle = player.angle + (math.random(-spread * 100, spread * 100) / 100)
            fixture:setUserData("bullet")
            fixture:setMask(player.number)
            fixture:setCategory(player.number)
            body:setBullet(true)
            body:setAngle(angle)
            body:setMass(body:getMass() * (weapon.mass or 1))
            body:applyLinearImpulse(math.cos(angle) * weapon.speed * 0.001 , math.sin(angle) * weapon.speed * 0.001)
            Entities.list[body] = {
                body = body,
                fixture = fixture,
                angle = player.angle,
                player = player,
                life = weapon.BulletDuration or 2,
                weapon = weapon}
            player.NextShoot = love.timer.getTime() + (weapon.shootDelay or 0.00001)  -- Default shoot delay if not specified
            bullets = bullets - 1
            magazine = magazine - 1
        until bullets < 1
    elseif magazine == 0  then
        player.NextShoot = love.timer.getTime() + (weapon.rechargetime or 0.5)  -- Recharge time if magazine is empty
        magazine = player.weapon.maxmagazine or -1  -- Reset magazine to max if not specified
    elseif weapon.name == "Reload" then
        player.NextShoot = love.timer.getTime() + (weapon.rechargetime or 0.5)  -- Recharge time if weapon is Reload
        player.magazine[player.weapon.name] = player.weapon.maxmagazine or -1  -- Reset magazine to max if not specified
    end
    player.magazine[weapon.name] = magazine  -- Update magazine count in player's table
end




return Weapons