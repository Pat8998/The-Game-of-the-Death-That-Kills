--local love = require(love)
local Button = {}

function Button:new(x, y, text, onClick, params)
    -- Create a new button object
    local btn = {}
    setmetatable(btn, self)
    self.__index = self

    -- Button properties
    btn.x = x
    btn.y = y
    btn.width = params.width or 100  -- Default width
    btn.height = params.height or 100
    btn.text = text or "Button"
    btn.onClick = onClick or function() print("Button", self.text, "was pressed") end  -- Default: no action
    btn.isHovered = false
    btn.isClicked = false
    btn.isActive = params.isActive == true or params.isActive == nil  -- Button is active by default
    btn.isRound = params.isRound or false  -- Button can be round
    btn.hoveredText = params.hoveredText  -- Text to show when hovered
    return btn
end

function Button:draw()
    -- Draw the button rectangle
    if self.isActive then
        if self.isHovered then            
            local time = love.timer.getTime() *2 + math.fmod(self.y, love.graphics.getWidth()/7) * math.pi/3
            love.graphics.setColor(math.abs(math.sin(time) * 1 + 0.0),
            math.abs(math.sin(time + math.pi/3) *1 + 0.0),
            math.abs(math.sin(time + 2* math.pi/3) * 1)
            )
        else
            love.graphics.setColor(1, 1, 1)  -- Highlight color
  -- Default color
        end
        if self.isRound then
            love.graphics.setLineWidth(5)
            love.graphics.circle("line", self.x, self.y, self.width / 2)
            love.graphics.printf((self.isHovered and self.hoveredText) and self.hoveredText or self.text, self.x - self.width/2, self.y - self.width/20, self.width, "center")
        else
            -- Draw a rectangle for the button
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(0, 0, 0)  -- Text color
            love.graphics.printf((self.isHovered and self.hoveredText) and self.hoveredText or self.text, self.x, self.y + self.height / 4, self.width, "center")
        end

        -- Draw the button text
    end
end

function Button:update(mouseX, mouseY, isMousePressed)
    if self.isActive then
        -- Check if the mouse is over the button
        self.isHovered = self.isRound and (
            (mouseX - self.x)^2 + (mouseY - self.y)^2 <= (self.width / 2)^2
        ) or  (
            mouseX >= self.x and mouseX <= self.x + self.width
            and mouseY >= self.y and mouseY <= self.y + self.height
        )

        -- Execute the onClick function if clicked
        if self.isHovered and isMousePressed then
            self.onClick()
            self.isClicked = true  -- Set clicked state to true
        else
            self.isClicked = false  -- Reset clicked state if not hovered or pressed
        end
    end
end



function Button.PauseMenu(Game, InGame, Players, Entities, Player, Map, Walls, Multiplayer)
    local screen_width, screen_height = love.graphics.getDimensions()
    local buttonNumber = 5
    local b = {
        Debug = Button:new(10, 10,  "debug", 
            function()
                love.system.vibrate(0.1)
                love.window.setMode(2560, 1440, {fullscreen = true})
                Game.IsMobile = not Game.IsMobile
                
                Game.Buttons.MobileButtons = Button.MobileButtons(Game, LocalPlayer, Entities) 
                    --love.graphics.setDPIScale(720)
                end,
            {width = 50, height = 50, isActive =false}),
        Quit = Button:new(screen_width/2 -100,          2 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), "Quit", 
            function() love.event.quit() end,
            {width = 200, height = screen_height/(buttonNumber + 4) }),
        StartGame = Button:new(screen_width/2 -100,     3 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), "Start game <3 !",
            function()
                print("Game Started !")
                Game.InHostedGame = true
                Game.IsPaused = false
            end,  {width = 200, height = screen_height/(buttonNumber + 4)}),
        SplitScreen = Button:new(screen_width/2 -320, 3.5 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), "SplitScreen", 
            function()
                Game.IsSplitscreen = not Game.IsSplitscreen
                if Game.IsSplitscreen then
                    Game.Buttons.PauseMenu.SplitScreen.text = "SingleScreen"
                    Game.Buttons.PauseMenu.SplitScreen.x = love.graphics.getWidth()/2 + 120
                else
                    Game.Buttons.PauseMenu.SplitScreen.text = "SplitScreen"
                    Game.Buttons.PauseMenu.SplitScreen.x = love.graphics.getWidth()/2 - 320
                end
            end, {width = 200, height = screen_height/(buttonNumber + 4), isActive = false}),  -- Button to toggle splitscreen
        GenerateWalls = Button:new(screen_width/2 -100, 4 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), "Generate Walls", 
            function()
                Walls:clear(Map.walls.list)   -- Clear the walls list
                Map.walls.list = Walls:generate(56, 10, 2)
            end, {width = 200, height = screen_height/(buttonNumber + 4)}),
        JoinGame = Button:new(screen_width/2 -100,      5 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), "Join Game",
            function ()
            Game.IsLoading = true
            Game.Server.ipaddr = ''
            --Game.Server.ipaddr = "localhost:6789"
            --Game.IsJoining = 1
            end, {width = 200, height = screen_height/(buttonNumber + 4)}),
        SetPublic =  Button:new(screen_width/2 -100,    6 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), "SetPublic", 
            function ()
                Game.IsPublic = true
                Game.Server.host = Multiplayer.StartServer("*:6969", Game.enetChannels.amount)
                Game.Buttons.PauseMenu.SetPublic.isActive = false
                Game.Buttons.PauseMenu.StopServer.isActive = true
                Game.Buttons.PauseMenu.StopServer.hoveredText = "Local : " .. Multiplayer.getLocalIP() .. "\n" ..
                                                                "Public : " .. Multiplayer.getPublicIP()
            end, {width = 200, height = screen_height/(buttonNumber + 4)}),
        StopServer = Button:new(screen_width/2 -100,    7 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), "StopServer", 
            function ()
                Game.IsPublic = false
                -- love.thread.getChannel("MultplayerThread"):push(Game)
                --ABOVE LINES IF ANY LAG IS CAUSED WITHOUT THE THREAD
                Game.Server.host = Game.Server.host:destroy()
                print("Server stopped")
                Game.Buttons.PauseMenu.SetPublic.isActive = true
                Game.Buttons.PauseMenu.StopServer.isActive = false
            end, {width = 200, height = screen_height/(buttonNumber + 4), isActive = false, hoveredText = "CACA !!"}),
        ClientResume = Button:new(screen_width/2 -100,      3 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), "Resume", 
            function ()
                Game.IsPaused = false
            end, {width = 200, height = screen_height/(buttonNumber + 4), isActive = false}),
        ClientDisconnect = Button:new(screen_width/2 -100,  5 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), "Disconnect", 
            function ()
                                                                                    ---@diagnostic disable-next-line: undefined-field
                Game.Server.peer:disconnect()
                repeat
                                                                                    ---@diagnostic disable-next-line: undefined-field
                    print("Waiting for disconnection...", Game.Server.peer:state())
                    Game.Server.host:service(100)  -- Ensure all messages are sent
                                                                                    ---@diagnostic disable-next-line: undefined-field
                until Game.Server.peer:state() == "disconnected"
                InGame.CreateLocalGame({
                    world = world,
                    Game = Game,
                    Players = Players,
                    Entities = Entities,
                    Player = Player,
                    Map = Map
                })
                LocalPlayer = Players.list[1]
                Game.InClientGame = false
                Game.Buttons.PauseMenu.ClientResume.isActive = false
                Game.Buttons.PauseMenu.ClientDisconnect.isActive = false
                Game.Buttons.PauseMenu.StartGame.isActive = true
                Game.Buttons.PauseMenu.JoinGame.x = love.graphics.getWidth()/2 +110            -- ACTUALLY IT MAKES YOU CLICK ON JOIN  without
                Game.Buttons.PauseMenu.JoinGame.isActive = true
                Game.Buttons.PauseMenu.SetPublic.isActive = true
                Game.Buttons.PauseMenu.StopServer.isActive = false
            end, {width = 200, height = screen_height/(buttonNumber + 4), isActive = false}),
    }
    return b
end


function Button.MobileButtons(Game, localplayer, Entities)
    local b = {
        Shoot = Button:new(love.graphics.getWidth() -  100, love.graphics.getHeight() - 100, "Shoot", 
            function()
                if not Game.InClientGame then
                    Game.Weapons.Shoot(localplayer, Entities)
                end
            end, {width = love.graphics.getHeight()/5, isRound = true}),
        NextWeapon = Button:new(love.graphics.getWidth() - 8 * localplayer.weapon.name:len(), 8 * localplayer.weapon.name:len(), "",
            function()
                Game.Weapons.nextWeapon(localplayer)
                Game.Buttons.MobileButtons.NextWeapon.x = love.graphics.getWidth() - 8 * localplayer.weapon.name:len()
                Game.Buttons.MobileButtons.NextWeapon.y = 8 * localplayer.weapon.name:len()
                table.insert(Game.DelayedCallbacks,
                    {
                        t = love.timer.getTime() + 0.1,
                        callback = function()
                            Game.Buttons.MobileButtons.NextWeapon.isActive = true
                        end
                    })
                Game.Buttons.MobileButtons.NextWeapon.isActive = false
            end, {width = 7 * localplayer.weapon.name:len(), isRound = true, hoveredText = "THIS IS AN EASTEER EGG"}),
    }
    return b
end











return Button
