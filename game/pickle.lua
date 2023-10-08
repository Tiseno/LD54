local COLOR = require "color"
local CATEGORY = require "category"

---@class Pickle
---@field tag "PICKLE"
---@field fixture love.Fixture
---@field width number
---@field height number
---@field color number[]
---@field highlighted boolean
local Pickle = {}

local function random_pickle_color()
  local g = math.random(60, 120)
  local rb = math.random(1, math.floor(g * 0.5))
  return COLOR.rgb(rb, g, rb)
end

---@param world love.World
---@param x number
---@param y number
---@param orientation number
function Pickle:new(world, x, y, orientation)
  local WIDTH = math.random(20, 20)
  local HEIGHT = math.random(60, 60)

  local body = love.physics.newBody(world, x, y, "dynamic")
  -- body:setBullet(true) -- Makes it so that pickles can't tunnel through walls, but it makes everything glitchy instead
  local shape = love.physics.newRectangleShape(WIDTH, HEIGHT)
  local fixture = love.physics.newFixture(body, shape)
  fixture:setMask(CATEGORY.JAR_POLYGON)
  body:setAngle(orientation)
  -- TODO make a rounded body
  local color = random_pickle_color()
  local new = { tag = "PICKLE", fixture = fixture, width = WIDTH, height = HEIGHT, color = color, highlighted = false }
  fixture:setUserData(new)
  self.__index = self
  return setmetatable(new, self)
end

function Pickle:destroy()
  self.fixture:setUserData(nil)
  self.fixture:destroy()
end

function Pickle:draw()
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
  love.graphics.rectangle("fill", -self.width / 2, -self.height / 2, self.width, self.height)
  love.graphics.pop()
end

function Pickle:get_value()
  -- TODO calculate a value depending on the state of the pickle
  return 1
end

function Pickle:test_point(x, y)
  local tx, ty, angle = self.fixture:getBody():getTransform()
  return self.fixture:getShape():testPoint(tx, ty, angle, x, y)
end

function Pickle:highlight()
  self.highlighted = true
end

function Pickle:un_highlight()
  self.highlighted = false
end

function Pickle:get_body()
  return self.fixture:getBody()
end

return Pickle
