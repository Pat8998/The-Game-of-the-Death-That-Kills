local input = {}

local hori = "0300910d0d0f0000c100000011010000,HORIPAD S,a:b1,b:b2,x:b0,y:b3,back:b8,guide:b12,start:b9,leftshoulder:b4,rightshoulder:b5,leftstick:b10,rightstick:b11,dpup:h0.1,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:b6,righttrigger:b7,platform:Linux,"

function input.load()
    if love.system.getOS() == "Linux" then
        love.joystick.loadGamepadMappings(hori)
    end
end

return input