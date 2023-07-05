Paddle = Class{}

function Paddle:init(x, y, width, height, speed)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = speed
end

function Paddle:update(dt,direction)
    if direction=="UP" then
        self.y = math.max(0, self.y - self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
