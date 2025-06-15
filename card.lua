local Card = {}
Card.__index = Card

function Card:new(name, cost, power, text)
    local self = setmetatable({}, Card)
    self.name = name
    self.cost = cost
    self.power = power
    self.text = text

    self.x = 0
    self.y = 0
    self.width = 160
    self.height = 220
    self.dragOffsetX = 0
    self.dragOffsetY = 0

    return self
end

function Card:draw(x, y, scale)
    self.x = x or self.x
    self.y = y or self.y
    scale = scale or 1

    local drawWidth = self.width * scale
    local drawHeight = self.height * scale

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", self.x, self.y, drawWidth, drawHeight)

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(scale)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.name, 5, 5, self.width - 10, "center")
    love.graphics.printf("Cost: " .. self.cost, 5, 30, self.width - 10, "left")
    love.graphics.printf("Power: " .. self.power, 5, 50, self.width - 10, "left")
    love.graphics.printf(self.text, 5, 80, self.width - 10, "left")

    love.graphics.pop()
end



function Card:isMouseOver(mx, my)
    return mx >= self.x and mx <= self.x + self.width and
           my >= self.y and my <= self.y + self.height
end

return Card
