--Dependencies
local game_info_lib = require ("game_info")
local enet = require "enet"
json = require("json_lua/json")

--Class
net_client = 
{
    game_info = game_info:new(),
    server = 0,
    host = 0,
    connection_id = 0,
    connected = 0
}

--Constructor
function net_client:new(obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    --init vars
    self.host = enet.host_create()


    return obj
end

--Functions
function net_client:connect(address)
    self.server = self.host:connect(address)
end

function net_client:net_update()
    --Wait for events, send and receive any ready packets
    local event = self.host:service(16)

    --as long as i have packets (event ~= nil) check packets
    while event do
        if event.type == "receive" then
            --decode packet data, all packets have a type
            local packet_data = json.decode(event.data)

            --received a "welcome" packet
            if(packet_data.type == 1) then

                self.connection_id = packet_data.connection_id

                self.game_info:set_move_image(packet_data.assigned_number)

                print("My connection id is: " .. self.connection_id .. " and my assigned image is: " .. packet_data.assigned_number)

            --received a "game_info" packet
            elseif(packet_data.type == 3) then
                self.game_info:set_data(packet_data)
            end

        --Connection packet
        elseif event.type == "connect" then
            self.connected = 1
            print(event.peer, "connected.")

        --Disconnection packet
        elseif event.type == "disconnect" then
            --quit application on getting disconnection on failed attempts/connection lost/end of the game
            love.event.quit( exitstatus )
            print(event.peer, "disconnected.")
        end
        --unqueue packet
        event = self.host:service()
    end
end

function net_client:game_update(dt)

    if(self.connected == 0)then
        return
    end

    local x_mouse, y_mouse = love.mouse.getPosition() -- get the position of the mouse

    x_mouse = math.Clamp(x_mouse, 0, 601)
    y_mouse = math.Clamp(y_mouse, 0, 601)

    local grid_x = math.floor(x_mouse / 198)
    local grid_y = math.floor(y_mouse / 198)

    move_hover_x = ( grid_x * 190) + 22
    move_hover_y = ( grid_y * 190) + 22

    local grid_index = grid_x + (grid_y * 3)

    if(self.game_info.cells[grid_index + 1] == 0) then
        self.game_info.move_possible = true
        local mouse_down = love.mouse.isDown(1)
        if(mouse_down and self.game_info.client_turn) then
            self.server:send(json.encode( {type = 2, connection_id = self.connection_id, cell_index = grid_index + 1} ))
        end
    else
        self.game_info.move_possible = false
    end
end

function net_client:draw()
    if(self.game_info.move_possible == true and self.game_info.client_turn) then
        love.graphics.draw(self.game_info.client_move_image, move_hover_x, move_hover_y)
    end
        
end