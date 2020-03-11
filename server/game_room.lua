game_room = 
{
    users = {0, 0},
    peers = {0, 0},
    grid = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    turn = 1
}

function game_room:new(obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function game_room:is_full()

    if(self.users[1] ~= 0 and self.users[2] ~= 0) then
        return true
    end
    
    return false
end

function game_room:add_user(event_peer)

    print("adding user")
    print(event_peer:connect_id())

    for x = 1, 2 do
        if(self.users[x] == 0) then
            self.peers[x] = event_peer
            self.users[x] = event_peer:connect_id()
            self.peers[x]:send(json.encode({type = 1, connection_id = self.users[x], assigned_number = x}))
            return
        end
    end

end

function game_room:remove_user(event_peer)

    local peer_id_to_delete = event_peer:connect_id()
    --print("removing user"..peer_id_to_delete)

    for x = 1, 2 do
        if(self.peers[x] == event_peer) then
            --print("removed user: "..x)
            self.peers[x] = 0
            self.users[x] = 0
            return
        end
    end
    --print("disconnecting nobody(?)")

end

--event.peer:send("disconnect")
function game_room:send_game_data()

    for x = 1, 2 do
        if(self.users[x] ~= 0) then
            self.peers[x]:send(json.encode( {type = 3, grid_data = self.grid, current_turn = self.turn} ))
        end
    end
    --if turn is grater than 2 game ended, the turn-2 is the id of the winner
    if(self.turn > 2) then
        --send queued packets
        host:flush()
        print("game ended")
        --temporary, wait 10 seconds then disconnect users of the "room"
        sleep(10.0)
        self.peers[1]:disconnect()
        self.peers[2]:disconnect()
        self:reset()
        print("room free")
    end
end

function game_room:reset()
    self.users = {0, 0}
    self.peers = {0, 0}
    self.grid = {0, 0, 0, 0, 0, 0, 0, 0, 0}
    self.turn = 1
end

function game_room:check_win()
    --check win
    if(self.grid[5]~=0)then
        if(self.grid[1] == self.grid[9] and self.grid[5] == self.grid[9]) then
            self.turn = self.grid[5] + 2
            --print("win")
        end
        if(self.grid[3] == self.grid[7] and self.grid[5] == self.grid[7]) then
            self.turn = self.grid[5] + 2
            --print("win")
        end
    end
    
    for x=0, 2 do
        local index = (x * 3) + 1
        local indey = x + 1
        if((self.grid[index] == self.grid[index+1] and self.grid[index] == self.grid[index+2] and self.grid[index] ~= 0) or
            (self.grid[indey] == self.grid[indey+3] and self.grid[indey] == self.grid[indey+6] and self.grid[indey] ~= 0)) then
            
            self.turn = self.grid[(x * 3) + 1 + x] + 2

            --print("win"..x.." "..index.." "..indey)
            --print("end"..self.turn)
            --print("xvalues "..self.grid[index].." "..self.grid[index+1].." "..self.grid[index+2].." ")
            --print("yvalues "..self.grid[indey].." "..self.grid[indey+3].." "..self.grid[indey+6].." ")
            
        end
    end
end

function game_room:move(connection_id, cell_index)
    for x = 1, 2 do
        if(self.users[x] == connection_id) then
            if(self.turn == x)then
                if(self.grid[cell_index] == 0) then
                    self.grid[cell_index] = x
                    self.turn = self.turn % 2
                    self.turn = self.turn + 1
                    self:check_win()
                end
            end
        end
    end
end