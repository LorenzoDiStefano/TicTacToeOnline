game_info = 
{
    --grid
    cells = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    --logic stuff
    client_turn = false,
    client_img_id = 0,
    client_move_image = 0,
    --client move vars
    move_possible = false,
    move_image = img_o
}

-- methods

function game_info:new(obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function game_info:set_move_image(index)

    self.client_img_id = index
    print("ind"..index)
    if(self.client_img_id == 1) then
        self.client_move_image = love.graphics.newImage("img/o.png")
    else
        self.client_move_image = love.graphics.newImage("img/x.png")
    end
end

function game_info:set_data(data_packet)

    self.cells = data_packet.grid_data
    if(data_packet.current_turn == self.client_img_id) then
        self.client_turn = true
    else
        self.client_turn = false
    end

end

function game_info:print()
    local res = "Game grid :"
    for i = 1, 9 do
        if((i - 1) % 3 == 0) then
            res = res .. "\n"
        else
            res = res .. " "
        end
    res = res .. self.cells[i]
    end
end

function game_info:draw()

    love.graphics.draw(img_grid, 0, 0)

    for i = 1, table.getn(self.cells) do
        local x = ((i - 1) % 3)
        local y = math.floor(((i - 1) / 3))
        if (self.cells[i] == 1) then
            love.graphics.draw(img_o, 22 + (x * 190), 22 + (y * 190))
        elseif (self.cells[i] == 2) then
            love.graphics.draw(img_x, 22 + (x * 190), 22 + (y * 190))
            
        end
    end
end