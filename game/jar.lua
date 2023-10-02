local Color = require "color"
local Category = require "category"
local Static = require "static"

---@class Jar
---@field tag "JAR"
---@field world love.World
---@field color number[]
---@field chain_fixture love.Fixture
---@field polygon_fixture love.Fixture
---@field highlighted boolean
---@field width number
---@field height number
local Jar = {}

local JAR_THICKNESS = 3

local JAR_OUTLINE = Color.hex_color "#67676767"
local JAR_GLASS = Color.hex_color "#7f7f7f33"

---@param world love.World
---@param x number
---@param y number
function Jar:new(world, x, y)
  local WIDTH = math.random(60, 180)
  local HEIGHT = math.random(80, 200)
  local NECK_OFFSET_X = math.random(10, math.floor(WIDTH / 2 - 20))
  local NECK_OFFSET_Y = math.random(10, 30)

  local body = love.physics.newBody(world, x, y, "dynamic")
  -- body:setBullet(true) -- Makes it so that pickles can't tunnel through walls, but it makes everything glitchy instead

  local chain_shape = love.physics.newChainShape(
    false,
    -WIDTH / 2 + NECK_OFFSET_X,
    -NECK_OFFSET_Y - HEIGHT / 2,
    -WIDTH / 2,
    -HEIGHT / 2,
    -WIDTH / 2,
    HEIGHT / 2,
    WIDTH / 2,
    HEIGHT / 2,
    WIDTH / 2,
    0 - HEIGHT / 2,
    WIDTH / 2 - NECK_OFFSET_X,
    -NECK_OFFSET_Y - HEIGHT / 2
  )
  local polygon_shape = love.physics.newPolygonShape(
    -WIDTH / 2 + NECK_OFFSET_X,
    -NECK_OFFSET_Y - HEIGHT / 2,
    -WIDTH / 2,
    -HEIGHT / 2,
    -WIDTH / 2,
    HEIGHT / 2,
    WIDTH / 2,
    HEIGHT / 2,
    WIDTH / 2,
    -HEIGHT / 2,
    WIDTH / 2 - NECK_OFFSET_X,
    -NECK_OFFSET_Y - HEIGHT / 2
  )
  local chain_fixture = love.physics.newFixture(body, chain_shape)
  local polygon_fixture = love.physics.newFixture(body, polygon_shape)
  polygon_fixture:setCategory(Category.JAR_POLYGON)

  local sensor_fixture = love.physics.newFixture(body, polygon_shape)
  sensor_fixture:setSensor(true)

  -- sensor_fixture:get

  -- left_side_body:setAngle(orientation) -- TODO how do we rotate everthing in a better way? This is a little glitchy

  local new = {
    tag = "JAR",
    world = world,
    color = JAR_OUTLINE,
    chain_fixture = chain_fixture,
    polygon_fixture = polygon_fixture,
    highlighted = false,
    width = WIDTH,
    height = HEIGHT,
  }
  polygon_fixture:setUserData(new)
  self.__index = self
  return setmetatable(new, self)
end

-- TODO sensor for the jar detecting all pickles inside it

function Jar:update()
  -- TODO calculate worth here instead of in the draw
end

function Jar:worth()
  local x, y, _ = self.chain_fixture:getBody():getTransform()

  local shape = self.polygon_fixture:getShape() --[[@as love.PolygonShape]]

  local x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, _, _ = shape:getPoints()
  local xs = { x1, x2, x3, x4, x5 }
  local ys = { y1, y2, y3, y4, y5 }
  local xmin, xmax = math.min(unpack(xs)), math.max(unpack(xs))
  local ymin, ymax = math.min(unpack(ys)), math.max(unpack(ys))

  local pickle_value = 0
  local garlic_value = 0

  self.world:queryBoundingBox(
    x + xmin,
    y + ymin,
    x + xmax,
    y + ymax,
    ---@param fixture love.Fixture
    function(fixture)
      if self.polygon_fixture:testPoint(fixture:getBody():getPosition()) then
        local entity = fixture:getUserData()
        if entity and entity.get_value then
          if entity.tag == "PICKLE" then
            pickle_value = pickle_value + entity:get_value()
          elseif entity.tag == "GARLIC" then
            garlic_value = garlic_value + entity:get_value()
          end
        end
      end
      return true -- signifies that we should continue with the rest of the fixtures
    end
  )
  return pickle_value + pickle_value * (25 - (garlic_value - 5) * (garlic_value - 5))
end

function Jar:is_sellable()
  local _, _, angle = self.chain_fixture:getBody():getTransform()
  local normalized_angle = angle % math.pi
  if normalized_angle > math.pi / 2 then
    normalized_angle = normalized_angle - math.pi
  end
  return -0.1 < normalized_angle and normalized_angle < 0.1
end

function Jar:draw()
  local x, y, angle = self.chain_fixture:getBody():getTransform()
  local shape = self.chain_fixture:getShape() --[[@as love.ChainShape]]
  local points = { shape:getPoints() }

  local worth = tonumber(self:worth())
  local text = ""
  if worth > 0 then
    text = "$" .. worth
  end

  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.rotate(angle)
  if self.highlighted then
    love.graphics.setColor(unpack(Color.highlight(JAR_OUTLINE)))
  else
    love.graphics.setColor(unpack(JAR_OUTLINE))
  end
  love.graphics.setLineWidth(JAR_THICKNESS)
  love.graphics.line(unpack(points))
  love.graphics.setColor(unpack(JAR_GLASS))
  love.graphics.polygon("fill", unpack(points))
  love.graphics.translate(points[1], points[2])
  love.graphics.setFont(Static.font_small)

  if self:is_sellable() then
    love.graphics.setColor(unpack(Color.GOLDEN))
  else
    love.graphics.setColor(unpack(Color.RED))
  end
  love.graphics.print(text, 0, 0, 0, 1, 1, 0, 0, 0, 0)
  love.graphics.pop()
end

function Jar:test_point(x, y)
  local tx, ty, angle = self.polygon_fixture:getBody():getTransform()
  return self.polygon_fixture:getShape():testPoint(tx, ty, angle, x, y)
end

function Jar:highlight()
  self.highlighted = true
end

function Jar:un_highlight()
  self.highlighted = false
end

function Jar:get_body()
  return self.chain_fixture:getBody()
end

return Jar
