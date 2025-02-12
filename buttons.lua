--local love = require(love)
local Button = {}

function Button:new(x, y, width, height, text, onClick)
    -- Create a new button object
    local btn = {}
    setmetatable(btn, self)
    self.__index = self

    -- Button properties
    btn.x = x
    btn.y = y
    btn.width = width
    btn.height = height
    btn.text = text or "Button"
    btn.onClick = onClick or function() print("Button n°", self, "was pressed") end  -- Default: no action
    btn.isHovered = false

    return btn
end

function Button:draw()
    -- Draw the button rectangle
    if self.isHovered then
        love.graphics.setColor(0.8, 0.8, 0.8)  -- Highlight color
    else
        love.graphics.setColor(1, 1, 1)  -- Default color
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw the button text
    love.graphics.setColor(0, 0, 0)  -- Text color
    love.graphics.printf(self.text, self.x, self.y + self.height / 4, self.width, "center")
end

function Button:update(mouseX, mouseY, isMousePressed)
    -- Check if the mouse is over the button
    self.isHovered = mouseX >= self.x and mouseX <= self.x + self.width
                     and mouseY >= self.y and mouseY <= self.y + self.height

    -- Execute the onClick function if clicked
    if self.isHovered and isMousePressed then
        self.onClick()
    end
end

return Button
