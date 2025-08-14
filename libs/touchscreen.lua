local TouchScreen = {}
TouchScreen.Touches = {}  -- Table to hold touch data

function TouchScreen.handle(params)
    local Game = params.Game
    local screen_width, screen_height = love.graphics.getDimensions()
    local localplayer = params.localplayer
    local LJoyTouched = false
    Game.Debug = ""
    for id, touch in pairs(Game.TouchScreen.Touches) do
        -- Process each touch
        -- Example: print touch coordinates
        -- Game.Debug = Game.Debug .. " X: " .. touch.x .. " Y: " .. touch.y .. "mx :" ..  touch.dx .. "my" .. touch.dy .. "\n"

        if touch.IsLeftJoy then
                localplayer.dir = localplayer.angle + math.atan2(touch.dx, touch.dy) + math.pi
                local movement = math.sqrt(touch.dx^2 + touch.dy^2) > 1  -- Calculate movement based on touch delta
                localplayer.moveSpeed = ((localplayer.isZooming and movement) and 100 or 200) * (math.max(math.abs(touch.dx), math.abs(touch.dy)))
                LJoyTouched = true
            else
                localplayer.angle = localplayer.angle - touch.dx * params.dt
            end
        end
    if not LJoyTouched then
            localplayer.moveSpeed = 0
    end
end


return TouchScreen

