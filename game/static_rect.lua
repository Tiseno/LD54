---@class StaticRect
---@field tag "STATIC_RECT"
---@field fixture love.Fixture
---@field color number[]
local StaticRect = {}

---@param world love.World
---@param x number
---@param y number
---@param w number
---@param h number
---@param color number[]
function StaticRect:new(world, x, y, w, h, color)
  local fixture =
    love.physics.newFixture(love.physics.newBody(world, x, y, "static"), love.physics.newRectangleShape(w, h))
  local new = {
    tag = "STATIC_RECT",
    fixture = fixture,
    color = color,
  }
  self.__index = self
  return setmetatable(new, self)
end

function StaticRect:draw()
  local x, y, angle = self.fixture:getBody():getTransform()
  local shape = self.fixture:getShape() --[[@as love.PolygonShape]]
  local x1, y1, x2, _, _, y3 = shape:getPoints()
  local w = math.abs(x1 - x2)
  local h = math.abs(y1 - y3)

  love.graphics.push()
  love.graphics.setColor(unpack(self.color))
  love.graphics.rectangle("fill", x - w / 2, y - h / 2, w, h)
  love.graphics.pop()
end

return StaticRect
