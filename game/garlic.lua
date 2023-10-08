local COLOR = require "color"
local CATEGORY = require "category"

---@class Garlic
---@field tag "GARLIC"
---@field fixture love.Fixture
---@field radius number
---@field color number[]
---@field highlighted boolean
local Garlic = {}

local function random_garlic_color()
  return COLOR.hex_color "#e3d7c1"
end

---@param world love.World
---@param x number
---@param y number
function Garlic:new(world, x, y)
  local RADIUS = math.random(10, 15)

  local body = love.physics.newBody(world, x, y, "dynamic")
  local shape = love.physics.newCircleShape(RADIUS)
  local fixture = love.physics.newFixture(body, shape)
  fixture:setMask(CATEGORY.JAR_POLYGON)
  local color = random_garlic_color()
  local new = { tag = "GARLIC", fixture = fixture, radius = RADIUS, color = color, highlighted = false }
  fixture:setUserData(new)
  self.__index = self
  return setmetatable(new, self)
end

function Garlic:destroy()
  self.fixture:destroy()
end

function Garlic:draw()
  -- TODO draw a rounded body
  local x, y, angle = self.fixture:getBody():getTransform()
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.rotate(angle)
  if self.highlighted then
    love.graphics.setColor(unpack(COLOR.highlight(self.color)))
  else
    love.graphics.setColor(unpack(self.color))
  end
  love.graphics.circle("fill", 0, 0, self.radius)
  love.graphics.pop()
end

function Garlic:get_value()
  -- TODO calculate a value depending on the state
  return 1.9
end

function Garlic:test_point(x, y)
  local tx, ty, angle = self.fixture:getBody():getTransform()
  return self.fixture:getShape():testPoint(tx, ty, angle, x, y)
end

function Garlic:highlight()
  self.highlighted = true
end

function Garlic:un_highlight()
  self.highlighted = false
end

function Garlic:get_body()
  return self.fixture:getBody()
end

return Garlic
