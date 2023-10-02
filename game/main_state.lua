local Color = require "color"
local StaticRect = require "static_rect"
local Shared = require "shared"
local Global = require "global"
local Static = require "static"
local UiButton = require "ui_button"
local Jar = require "jar"

---@class Main
---@field tag "MAIN"
---@field timer number
---@field state "RUNNING"|"PAUSED"
---@field world love.World
---@field objects (Garlic|Pickle|Jar)[]
---@field statics StaticRect[]
---@field ui_elements UiButton[]
---@field mouse_joint love.MouseJoint | nil
---@field cash number
---@field paused_title StaticText
---@field paused_1 StaticText
---@field paused_2 StaticText
local Main = {}

---@return Main
function Main:new()
  ---@type Main
  local new = {
    tag = "MAIN",
    state = "RUNNING",
    timer = 0,
    world = love.physics.newWorld(0, 981, true),
    objects = {},
    statics = {},
    ui_elements = {},
    mouse_joint = nil,
    cash = 20,
    sell_sensor = nil,
    paused_title = Shared.StaticText:new("Paused", Static.font_large, Color.PICKLE_2),
    paused_1 = Shared.StaticText:new("P - Unpause", Static.font_medium, Color.PICKLE_3),
    paused_2 = Shared.StaticText:new("Esc - Exit", Static.font_medium, Color.PICKLE_3),
  }

  Shared.create_static_boundaries(new.world, new.statics)

  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()

  table.insert(
    new.objects,
    StaticRect:new(new.world, 0, window_height, window_width * 2, 50, Color.hex_color "#464b18")
  )

  table.insert(
    new.ui_elements,
    UiButton:new(1060, 510, 80, 30, "Sell Jar", Static.font_small, Color.GOLDEN, Color.BLACK, function()
      print "Tried to sell"
      new.world:queryBoundingBox(
        1056,
        471,
        1230,
        504,
        ---@param fixture love.Fixture
        function(fixture)
          local entity = fixture:getUserData()
          if entity and entity.tag then
            print("found entity in sell depot " .. entity.tag)
          end
          if entity and entity.tag == "JAR" and entity:is_sellable() then
            new.cash = new.cash + entity:worth()
            -- TODO remove jar and its pickles from objects
            -- Probably entity:get_pickles
          end
          return true
        end
      )
    end)
  )

  local jar_cost = 15
  table.insert(
    new.ui_elements,
    UiButton:new(1060, 160, 120, 30, "Buy Jar $" .. jar_cost, Static.font_small, Color.GOLDEN, Color.BLACK, function()
      new.cash = new.cash - jar_cost
      table.insert(new.objects, Jar:new(new.world, 100, 0))
    end)
  )

  self.__index = self
  return setmetatable(new, self)
end

function Main:keypressed(key)
  if key == "escape" then
    if self.state == "RUNNING" then
      self.state = "PAUSED"
    else
      love.event.quit()
      return
    end
  end

  if key == "space" then
    Global.send_message "SPLASH"
  end

  if key == "p" then
    if self.state == "PAUSED" then
      self.state = "RUNNING"
    elseif self.state == "RUNNING" then
      self.state = "PAUSED"
    end
  end
end

function Main:destroy_mouse_joint()
  if self.mouse_joint then
    self.mouse_joint:destroy()
    self.mouse_joint = nil
  end
end

---@param x number
---@param y number
---@param button number
function Main:mousepressed(x, y, button)
  print(x, y)
  local candidate = nil
  for _, value in ipairs(self.objects) do
    if value.tag == "PICKLE" or value.tag == "GARLIC" then
      if value:test_point(x, y) then
        candidate = value
        break
      end
    end
    if value.tag == "JAR" then
      if value:test_point(x, y) then
        candidate = value
      end
    end
  end
  if candidate then
    self:destroy_mouse_joint()
    self.mouse_joint = love.physics.newMouseJoint(candidate:get_body(), x, y)
  end

  for _, o in ipairs(self.ui_elements) do
    o:mousepressed(x, y, button)
  end
end

function Main:mousemoved(x, y)
  Shared.highlight_when_no_mouse_joint(self.objects, self.mouse_joint, "JAR", x, y)
end

function Main:mousereleased()
  self:destroy_mouse_joint()
end

---@param dt number
function Main:update(dt)
  if self.state == "RUNNING" then
    local SPAWN_PICKLE = 0.4
    self.timer = self.timer + dt
    if self.timer > SPAWN_PICKLE then
      self.timer = self.timer - SPAWN_PICKLE
      Shared.spawn_random_pickle(self.world, self.objects)
    end

    if self.mouse_joint then
      self.mouse_joint:setTarget(love.mouse.getPosition())
    end

    for _, o in ipairs(self.ui_elements) do
      o:update()
    end

    self.timer = self.timer + dt
    self.world:update(dt)
  end
end

function Main:draw()
  love.graphics.clear()
  for _, o in ipairs(self.objects) do
    if o.tag ~= "JAR" then
      o:draw()
    end
  end

  for _, o in ipairs(self.objects) do
    if o.tag == "JAR" then
      o:draw()
    end
  end

  for _, o in ipairs(self.statics) do
    o:draw()
  end

  for _, o in ipairs(self.ui_elements) do
    o:draw()
  end

  if self.state == "PAUSED" then
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local title_y_offset = -200

    Shared.draw_static_text(self.paused_title, window_width / 2, window_height / 2 + title_y_offset)
    title_y_offset = title_y_offset + self.paused_title.text_height

    title_y_offset = title_y_offset + self.paused_1.text_height
    Shared.draw_static_text(self.paused_1, window_width / 2, window_height / 2 + title_y_offset)
    Shared.draw_static_text(
      self.paused_2,
      window_width / 2,
      window_height / 2 + title_y_offset + self.paused_2.text_height
    )
  end

  love.graphics.setFont(Static.font_medium)
  if self.cash < 0 then
    love.graphics.setColor(unpack(Color.RED))
  else
    love.graphics.setColor(unpack(Color.GOLDEN))
  end
  love.graphics.print("Cash: $" .. self.cash, 1060, 0, 0, 1, 1, 0, 0, 0, 0)
end

return Main