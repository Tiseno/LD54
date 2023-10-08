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
---@field sell_instructions_1 StaticText
---@field sell_instructions_2 StaticText
---@field paused_title StaticText
---@field paused_1 StaticText
---@field paused_2 StaticText
local Main = {}

function Main:remove_object(object)
  for index, value in ipairs(self.objects) do
    if value == object then
      table.remove(self.objects, index)
      return
    end
  end
end

local sell_area = { topLeftX = 1050, topLeftY = 200, bottomRightX = 1225, bottomRightY = 500 }

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
    sell_instructions_1 = Shared.StaticText:new("Put jar here", Static.font_small, Color.WHITE),
    sell_instructions_2 = Shared.StaticText:new("to sell", Static.font_small, Color.WHITE),
    paused_title = Shared.StaticText:new("Paused", Static.font_large, Color.WHITE),
    paused_1 = Shared.StaticText:new("P - Unpause", Static.font_medium, Color.WHITE),
    paused_2 = Shared.StaticText:new("Space - Restart", Static.font_medium, Color.WHITE),
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
      new.world:queryBoundingBox(
        sell_area.topLeftX,
        sell_area.topLeftY,
        sell_area.bottomRightX,
        sell_area.bottomRightY,
        ---@param fixture love.Fixture
        function(fixture)
          local entity = fixture:getUserData()
          if entity and entity.tag == "JAR" and entity:is_sellable() then
            new.cash = new.cash + entity:worth()
            local jar_content = entity:get_pickles()
            for index, value in ipairs(jar_content) do
              value:destroy()
              Main.remove_object(new, value)
            end
            entity:destroy()
            Main.remove_object(new, entity)
            return false
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
    end
  end

  if self.state == "PAUSED" then
    if key == "space" then
      Global.send_message "RESTART"
    end
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

local OBJECTS_MAX = 700
local SPAWN_PICKLE = 0.4

---@param dt number
function Main:update(dt)
  if self.state == "RUNNING" then
    self.timer = self.timer + dt
    if self.timer > SPAWN_PICKLE then
      self.timer = self.timer - SPAWN_PICKLE
      if #self.objects < OBJECTS_MAX then
        Shared.spawn_random_pickle(self.world, self.objects)
      end
    end

    if self.mouse_joint then
      self.mouse_joint:setTarget(love.mouse.getPosition())
    end

    for _, o in ipairs(self.objects) do
      if o.update then
        o:update()
      end
    end

    for _, o in ipairs(self.ui_elements) do
      o:update()
    end

    self.world:queryBoundingBox(
      sell_area.topLeftX,
      sell_area.topLeftY,
      sell_area.bottomRightX,
      sell_area.bottomRightY,
      ---@param fixture love.Fixture
      function(fixture)
        local entity = fixture:getUserData()
        if entity and entity.tag == "JAR" then
          local x, y = entity:get_body():getPosition()
          if
            sell_area.topLeftX < x
            and x < sell_area.bottomRightX
            and sell_area.topLeftY < y
            and y < sell_area.bottomRightY
          then
            entity:set_sellable()
          end
        end
        return true
      end
    )
    self.timer = self.timer + dt
    self.world:update(dt)
  end
end

function Main:draw()
  love.graphics.clear()
  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()

  Shared.draw_static_text(self.sell_instructions_1, 1136, 325)
  Shared.draw_static_text(self.sell_instructions_2, 1136, 360)

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
    local title_y_offset = -200

    Shared.draw_static_text(self.paused_title, window_width / 2, window_height / 2 + title_y_offset)
    title_y_offset = title_y_offset + self.paused_title.text_height

    title_y_offset = title_y_offset + self.paused_1.text_height
    Shared.draw_static_text(self.paused_1, window_width / 2, window_height / 2 + title_y_offset)
    title_y_offset = title_y_offset + self.paused_2.text_height
    Shared.draw_static_text(self.paused_2, window_width / 2, window_height / 2 + title_y_offset)
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
