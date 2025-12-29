local input = {}

function input.load()
    if love.system.getOS() == "Linux" then
        local maps = {}
        for line in love.filesystem.lines("input_config/mappings") do
            table.insert(maps, line)
        end
        for _, map in pairs(maps) do
            if map ~= "" then
                print("  Loading:", map)
                love.joystick.loadGamepadMappings(map)
            else
                print("  Skipping empty line")
            end

        end
    end
end

return input