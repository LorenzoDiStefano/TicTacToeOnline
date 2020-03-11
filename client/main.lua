--Dependencies
local mynet = require "net_client"

--Graphic vars
local WindowSize = 601

--Shader stuff
local pixelcode = "shaders/pixel_shader.glsl"
local vertexcode = "shaders/vertex_shader.glsl"
local alpha_shader = love.graphics.newShader(pixelcode, vertexcode)

--Game vars
local my_net_client = net_client:new()

function love.load()
    --setting up window
    love.window.setTitle("Tic Tac Toe")
    love.window.setMode(WindowSize, WindowSize)
    --Loading assets
    img_grid = love.graphics.newImage("img/background.png")
    img_o = love.graphics.newImage("img/o.png")
    img_x = love.graphics.newImage("img/x.png")
    --connecting to server
    my_net_client:connect("localhost:6789")

end

function love.draw()
    if(my_net_client.connected ~= 0) then
        love.graphics.setShader()
        my_net_client.game_info:draw()
        love.graphics.setShader(alpha_shader)
        my_net_client:draw()
    else
        love.graphics.print("waiting for server", 20, 20)
    end
end

function love.update(dt)
    my_net_client:net_update()
    my_net_client:game_update(dt)
end

function math.Clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end