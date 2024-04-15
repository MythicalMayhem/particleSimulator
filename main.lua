local utils = require('./utils')
local settings = require('./settings')
local physics = require('./physics')
local templates = require('./templates')
math.randomseed(os.time())
local printstr = ''

local n = settings.gasCloud
local atoms = {}
function collisionCheck(a, b)
    local distance = math.sqrt((a.pos.x - b.pos.x) ^ 2 + (a.pos.y - b.pos.y) ^ 2)
    if distance <= (a.radius + b.radius) then
        a.velocity.x, a.velocity.y, b.velocity.x, b.velocity.y = physics.response_velocities(a, b)
        a.pos.x = a.pos.x + a.velocity.x
        a.pos.y = a.pos.y + a.velocity.y
        b.pos.x = b.pos.x + b.velocity.x
        b.pos.y = b.pos.y + b.velocity.y
    end
end
function combine(a, b, i, j)
    local distance = math.sqrt((a.pos.x - b.pos.x) ^ 2 + (a.pos.y - b.pos.y) ^ 2)
    if (distance <= (a.radius + b.radius) - 1) then
        if a.mass > b.mass then
            a.mass = a.mass + b.mass
            a.radius = a.radius + 1
            printstr = a.mass
            table.remove(atoms, j)
        else
            b.mass = b.mass + a.mass
            b.radius = b.radius + 1
            printstr = b.mass
            table.remove(atoms, i)

        end
    end
end

local BB = math.random(0, love.graphics.getHeight() - 1)
local line = {
    b = BB,
    a = (love.graphics.getHeight() - BB - BB) / (love.graphics.getWidth() - 0),
    x = 0,
    y = BB,
    x2 = love.graphics.getWidth(),
    y2 = love.graphics.getHeight() - BB

}

function love.load()

    -- y = ax +b

    local sign = -1

    local chunk = (line.x2 - line.x - 200) / n
    for i = 1, n do
        sign = -sign
        local margin = math.random(-50, 50)
        local temp = templates.hydrogen:new()
        local x = chunk * i + 100
        local y = line.a * x + line.b + ((n / 2) - math.abs((n / 2) - i)) * sign + margin

        temp.pos.x = math.min(love.graphics.getWidth(), x)
        temp.pos.y = math.min(love.graphics.getHeight(), y)
        if not (temp.x == love.graphics.getWidth() or temp.y == love.graphics.getHeight()) then
            atoms[i] = temp
        end
    end
end

local fps = 0
local debounce = os.time()
function love.update(dt)
    if os.time() - debounce > 0.05 then
        fps = 1 / dt
        debounce = os.time()
    end
    for i, atom in pairs(atoms) do

        local fx, fy = 0, 0
        for l, neighbor in pairs(atoms) do
            if not (l == i) then
                local dx = atom.pos.x - neighbor.pos.x
                local dy = atom.pos.y - neighbor.pos.y

                local d = math.sqrt(dx * dx + dy * dy)
                if (d > 1) and (d < 5) then
                    local F = -1 / d
                    fx = fx + F * dx
                    fy = fy + F * dy
                end
            end
        end
        atom.velocity.x = atom.velocity.x
        atom.velocity.y = atom.velocity.y
        for l, neighbor in pairs(atoms) do
            if not (l == i) then
                collisionCheck(atom, neighbor)
                combine(atom, neighbor, i, l)
            end
        end

        if not ((atom.pos.x - atom.radius >= 0) and (atom.pos.x + atom.radius <= love.graphics.getWidth())) then
            atom.velocity.x = atom.velocity.x * -1
        end
        if not ((atom.pos.y - atom.radius >= 0) and (atom.pos.y + atom.radius <= love.graphics.getHeight())) then
            atom.velocity.y = atom.velocity.y * -1
        end
        atom.pos.x = utils.clamp(atom.pos.x + atom.velocity.x, 0, love.graphics.getWidth())
        atom.pos.y = utils.clamp(atom.pos.y + atom.velocity.y, 0, love.graphics.getHeight())
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(fps))
    love.graphics.print(tostring('\n' .. printstr))
    -- love.graphics.line(line.x, line.y, line.x2, line.y2)
    for k, atom in ipairs(atoms) do
        love.graphics.setColor(atom.color[1], atom.color[2], atom.color[3])
        love.graphics.circle("fill", atom.pos.x, atom.pos.y, atom.radius)
    end
end
