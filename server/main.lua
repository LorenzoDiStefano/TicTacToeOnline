local enet = require "enet"
socket = require "socket"
local gamre_room_lib = require "game_room"
json = require("json_lua/json")

function love.load()
    host = enet.host_create("localhost:6789", 2)
    hostReceived = 0
end

function love.draw()
    --player 1
    love.graphics.print(game_room.users[1], 5, 5)
    if(game_room.users[1] ~= 0) then
        love.graphics.print(game_room.users[1], 20, 5)
    end
    --player 2
    love.graphics.print(game_room.users[2], 5, 20)
    if(game_room.users[2]~= 0) then
        love.graphics.print(game_room.users[2], 20, 20)
    end
    --stuff
    local is_full_bool = game_room:is_full()
    love.graphics.print( tostring(is_full_bool) , 5, 35)

end

function love.update(dt)
    event = host:service(50)
    while event do
        if event.type == "receive" then
          --print("Got message: ", event.data, event.peer)
            packet_data = json.decode(event.data)

            if(packet_data.type == 2) then

                local client_id = packet_data.connection_id
                local move_index = packet_data.cell_index
                game_room:move(client_id,move_index)


            print("client: " .. client_id .. "moved on index: " .. move_index)
            end
          
        elseif event.type == "connect" then

            local bool_is_full= game_room:is_full()

            if(bool_is_full) then
                print("max users accepted")
                --event.peer:send("disconnect")
            else
                game_room:add_user(event.peer)
            end
        elseif event.type == "disconnect" then
            game_room:remove_user(event.peer)
            --print(event.peer, "disconnected.")
        end
        event = host:service()
    end
    game_room:send_game_data()
    --print(host:peer_count())--max connections
end

game_room = game_room:new()

function sleep(sec)
    socket.select(nil, nil, sec)
end