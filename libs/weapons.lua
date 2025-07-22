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
        damage = 30,
        bullets = function() return 2 + math.random(3) end,  -- Number of bullets shot at once
    },
    LongRifle = {
        name = "LongRifle",
        number = 2,
        shootDelay = 0.5,
        BulletDuration = 3,
        speed = 2,
        spread = 1*math.pi / 180,  -- Spread in rads
        damage = 50,
    },
    Rifle = {
        name = "Rifle",
        number = 3,
        shootDelay = 0.01,
        BulletDuration = 2,
        speed = 0.7,
        spread = 10*math.pi / 180,  -- Spread in rads
        damage = 5,
        mass = 25,
        rechargetime = 0.5,  -- Time to recharge the weapon
        maxmagazine = 10,  -- Maximum number of bullets in the magazine
        magazine = 10,
    },    
    Ball = {
        name = "Ball",
        number = 4,
        shootDelay = 0.01,
        BulletDuration = 2,
        speed = 0.5,
        spread = 10*math.pi / 180,  -- Spread in rads
        damage = 0,
        mass = 25,
    },
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
    -- print("Next weapon: " .. player.weapon.name)
end
function Weapons.previousWeapon(player)
    if player.weapon.number <= 0 then
        player.weapon = Weapons.list[Weapons.weaponsNumber[#Weapons.weaponsNumber]]
    else
        player.weapon = Weapons.list[Weapons.weaponsNumber[player.weapon.number - 1]]
    end
    -- print("previous weapon: " .. player.weapon.name)
end



function Weapons.Shoot(player, Entities, weapon)
    weapon = weapon or player.weapon or Weapons.list.Default  -- Use player's weapon or default if not specified
    if love.timer.getTime() > player.NextShoot then
        local bullets = (type(weapon.bullets) == "function" and weapon.bullets() or weapon.bullets) or 1  -- Call function if present
        local spread
        if player.isZooming then
            spread = weapon.spread/5  -- Use default weapon if player is zooming
        else
            spread = weapon.spread or 0  -- Use default weapon spread if not specified
        end
        repeat
            local body = love.physics.newBody(world, player.x, player.y, "dynamic")
            local fixture = love.physics.newFixture(body, Entities.defaultShapes.bullet, 1)
            local angle = player.angle + (math.random(-spread * 100, spread * 100) / 100)
            -- print("angle : " .. (angle - player.angle) * 180 / math.pi)
            fixture:setUserData("bullet")
            fixture:setMask(player.number)
            fixture:setCategory(player.number)
            body:setBullet(true)
            body:setAngle(angle)
            body:setMass(body:getMass() * (weapon.mass or 1))  -- Reduce mass for Ball weapon
            body:applyLinearImpulse(math.cos(angle) * weapon.speed * 0.001 , math.sin(angle) * weapon.speed * 0.001)
            Entities.list[body] = {body = body, fixture = fixture, angle = player.angle, player = player, life = weapon.BulletDuration or 2, weapon = weapon}
            player.NextShoot = love.timer.getTime() + (weapon.shootDelay or 0.00001)  -- Default shoot delay if not specified
            bullets = bullets - 1
        until bullets < 1
    end
end




return Weapons