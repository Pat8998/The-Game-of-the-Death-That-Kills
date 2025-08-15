--local love = require(love)
local Button = {}

function Button:new(x, y, width, height, text, onClick, isActive)
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
    btn.onClick = onClick or function() print("Button", self.text, "was pressed") end  -- Default: no action
    btn.isHovered = false
    btn.isActive = isActive == nil or isActive == true  -- Explicitly check if isActive is nil
    return btn
end

function Button:draw()
    -- Draw the button rectangle
    if self.isActive then
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
end

function Button:update(mouseX, mouseY, isMousePressed)
    if self.isActive then
        -- Check if the mouse is over the button
        self.isHovered = mouseX >= self.x and mouseX <= self.x + self.width
                        and mouseY >= self.y and mouseY <= self.y + self.height

        -- Execute the onClick function if clicked
        if self.isHovered and isMousePressed then
            self.onClick()
        end
    end
end



function Button.PauseMenu(Game, InGame, Players, Entities, Player, Map, Walls, Multiplayer)
    local screen_width, screen_height = love.graphics.getDimensions()
    local buttonNumber = 5
    local b = {
        Debug = Button:new(10, 10, 10, 10, "debug", function()
            love.system.vibrate(0.1)
            love.window.setMode(2560, 1440, {fullscreen = true})
            Game.IsMobile = not Game.IsMobile
            
            Game.Buttons.MobileButtons = Button.MobileButtons(Game, LocalPlayer, Entities) 
                --love.graphics.setDPIScale(720)
                
            end),
        Quit = Button:new(screen_width/2 -100,          2 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), 200, screen_height/(buttonNumber + 4), "Quit", function()
            love.event.quit()
        end),
        StartGame = Button:new(screen_width/2 -100,     3 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), 200, screen_height/(buttonNumber + 4), "Start game ❤!", function()
            print("Game Started !")
            Game.InHostedGame = true
            Game.IsPaused = false
        end),
        SplitScreen = Button:new(screen_width/2 -320, 3.5 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), 200, screen_height/(buttonNumber + 4), "SplitScreen", function()
            Game.IsSplitscreen = not Game.IsSplitscreen
            if Game.IsSplitscreen then
                Game.Buttons.PauseMenu.SplitScreen.text = "SingleScreen"
                Game.Buttons.PauseMenu.SplitScreen.x = love.graphics.getWidth()/2 + 120
            else
                Game.Buttons.PauseMenu.SplitScreen.text = "SplitScreen"
                Game.Buttons.PauseMenu.SplitScreen.x = love.graphics.getWidth()/2 - 320
            end
        end, {isActive = false}),  -- Button to toggle splitscreen
        GenerateWalls = Button:new(screen_width/2 -100, 4 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), 200, screen_height/(buttonNumber + 4), "Generate Walls", function()
            Walls:clear(Map.walls.list)   -- Clear the walls list
            Map.walls.list = Walls:generate(56, 10, 2)
        end),
        JoinGame = Button:new(screen_width/2 -100,      5 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), 200, screen_height/(buttonNumber + 4), "Join Game", function ()
        Game.IsLoading = true
        Game.Server.ipaddr = ''
        --Game.Server.ipaddr = "localhost:6789"
        --Game.IsJoining = 1
        end),
        SetPublic =  Button:new(screen_width/2 -100,    6 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), 200, screen_height/(buttonNumber + 4), "SetPublic", function ()
            Game.IsPublic = true
            -- love.thread.newThread(string.dump(Multiplayer.StartServer)):start(Game)
            --ABOVE LINE IF ANY LAG IS CAUSED WITHOUT THE THREAD
            Game.Server.host = Multiplayer.StartServer("*:6969", Game.enetChannels.amount)
            Game.Buttons.PauseMenu.SetPublic.isActive = false
            Game.Buttons.PauseMenu.StopServer.isActive = true
        end),
        StopServer = Button:new(screen_width/2 -100,    7 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), 200, screen_height/(buttonNumber + 4), "StopServer", function ()
            Game.IsPublic = false
            -- love.thread.getChannel("MultplayerThread"):push(Game)
            --ABOVE LINES IF ANY LAG IS CAUSED WITHOUT THE THREAD
            Game.Server.host = Game.Server.host:destroy()
            print("Server stopped")
            Game.Buttons.PauseMenu.SetPublic.isActive = true
            Game.Buttons.PauseMenu.StopServer.isActive = false
        end, {isActive = false}),
        ClientResume = Button:new(screen_width/2 -100,      3 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), 200, screen_height/(buttonNumber + 4), "Resume", function ()
            Game.IsPaused = false
        end, {isActive = false}),
        ClientDisconnect = Button:new(screen_width/2 -100,  5 * screen_height/(buttonNumber + 2) - screen_height/(buttonNumber + 3), 200, screen_height/(buttonNumber + 4), "Disconnect", function ()
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
        end, {isActive = false}),
    }
    return b
end


function Button.MobileButtons(Game, localplayer, Entities)
    local b = {
        Shoot = Button:new(love.graphics.getWidth() -100, love.graphics.getHeight() - 100, 80, 80, "Shoot", function()
            
            Game.Weapons.Shoot(localplayer, Entities)
            -- Add shooting logic here
        end),
    }
    return b
end











return Button
