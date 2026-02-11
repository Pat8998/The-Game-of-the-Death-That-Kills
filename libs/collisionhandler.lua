local CollisionHandler = {}

CollisionHandler.Game = {}

function CollisionHandler.beginContact(a, b, coll)
    -- print ("colliding" , a:getUserData() , "with" , b:getUserData())
    -- Get userdata of the colliding objects
    local userdataA = a:getUserData()
    local userdataB = b:getUserData()
    
    local bullet, other
    if userdataA == "bullet" or userdataB == "bullet" then
        if userdataA == "bullet" then
            bullet = a
            other = b
        else
            bullet = b
            other = a
        end
        if bullet and Entities.list[bullet:getBody()] then
            if other:getUserData() == "player" or other:getUserData() == "mob" then
                --ADD THZE PLAYER HEALTHE SYSTEM LOLLL
                for _, p in pairs(CollisionHandler.Game.Players.list) do
                    if p.fixture == other then
                        local shooter, weapon = Entities.list[bullet:getBody()].player, Entities.list[bullet:getBody()].weapon
                        table.insert(CollisionHandler.Game.DelayedCallbacks, 
                        {
                            t = love.timer.getTime(),
                            callback = function()
                                CollisionHandler.Game.Gamemodes.OnPlayerHit({
                                    hit = p,
                                    shooter = shooter,
                                    weapon = weapon
                                })
                            end
                        })
                        break
                    end
                    -- print(value.fixture, other)
                end
            elseif other:getUserData():match("^wall") then
                --idk put an effect on the wall or smth
            end
            -- if Entities.list[bullet:getBody()] then
            DestroyEntity(Entities.list[bullet:getBody()])
            -- end
        else
            print("Bullet has no body!")
        end
    end
end







-- PLACEHOLDERS BC I HAVE TO DEFINE THEM
function CollisionHandler.endContact(a, b, coll)
    -- print("End Contact")    
    -- local userdataA = a:getUserData()
    -- local userdataB = b:getUserData()
    -- local bullet, other
    -- if userdataA == "bullet" then
    --         DestroyEntity(Entities.list[a:getBody()])
    -- else
    --     if userdataB == "bullet" then
    --         DestroyEntity(Entities.list[b:getBody()])
    --     end
            
    -- end
end

function CollisionHandler.preSolve(a, b, coll)
    -- print("Pre Solve Contact")
end

function CollisionHandler.postSolve(a, b, coll, normalImpulse1, tangentImpulse1, normalImpulse2, tangentImpulse2)
    -- print("Post Solve Contact")
end

return CollisionHandler