local TouchScreen = {}
TouchScreen.Touches = {}  -- Table to hold touch data

function TouchScreen.handle(params)
    local Game = params.Game
    local screen_width, screen_height = love.graphics.getDimensions()
    local localplayer = params.localplayer
    local LJoyTouched = false
    Game.Debug = ""
    for id, touch in pairs(Game.TouchScreen.Touches) do
        -- Game.Debug = Game.Debug .. " X: " .. touch.x .. " Y: " .. touch.y .. "mx :" ..  touch.dx .. "my" .. touch.dy .. "\n"
        if touch.IsLeftJoy then
            local lx, ly = touch.sx - touch.x, touch.sy - touch.y
                localplayer.dir = localplayer.angle + math.atan2(lx, ly)
                local movement = math.min(math.sqrt(lx^2 + ly^2) / (screen_height/8), 2)  -- Calculate movement based on touch delta
                localplayer.moveSpeed = ((localplayer.isZooming and movement > 1) and 1100 or 2200) * (movement)
                LJoyTouched = true
                Game.Debug = movement
            else
                localplayer.angle = localplayer.angle - touch.dx * params.dt
            end
        end
    if not LJoyTouched then
            localplayer.moveSpeed = 0
    end
end


return TouchScreen