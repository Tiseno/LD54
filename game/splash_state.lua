-- https://github.com/LuaLS/lua-language-server/wiki/Annotations
local love = require "love"
local Pickle = require "pickle"
local Jar = require "jar"
local Color = require "color"
local Static = require "static"
local Global = require "global"
local Shared = require "shared"

---@class Splash
---@field tag "SPLASH"
---@field timer number
---@field world love.World
---@field objects (Garlic|Pickle|Jar)[]
---@field mouse_joint love.MouseJoint | nil
---@field pickle_count number
---@field preamble StaticText
---@field title StaticText
---@field sub_title StaticText
---@field begin_text StaticText
local Splash = {}

-- https://love2d.org/wiki/love.physics.newMouseJoint
---@return Splash
function Splash:new()
  ---@type Splash
  local new = {
    tag = "SPLASH",
    timer = 0,
    world = love.physics.newWorld(0, 981, true),
    objects = {},
    mouse_joint = nil,
    pickle_count = 0,
    preamble = Shared.StaticText:new("Ludum Dare 54", Static.font_small, Color.PICKLE_3),
    title = Shared.StaticText:new("Pickle Packer", Static.font_large, Color.PICKLE_2),
    sub_title = Shared.StaticText:new("", Static.font_large, Color.PICKLE_3),
    begin_text = Shared.StaticText:new("Press any key to begin", Static.font_medium, Color.PICKLE_4),
  }
  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()

  for _ = 1, 5 do
    table.insert(
      new.objects,
      Pickle:new(new.world, math.random(0, math.floor(window_width)), -window_height, math.random(1, 360) / 3.14)
    )
  end

  -- for i = 1, 1 do
  --   local x = i * 200
  --   local y = window_height - 100
  --   table.insert(new.objects, Jar:new(new.world, x, y))
  -- end

  Shared.create_static_boundaries(new.world, new.objects)
  self.__index = self
  return setmetatable(new, self)
end

---@param key love.KeyConstant
function Splash:keypressed(key)
  if key == "escape" then
    -- TODO disable this
    love.event.quit()
    return
  end

  -- if key == "space" then
  Global.send_message "BEGIN"
  -- end
end

function Splash:destroy_mouse_joint()
  if self.mouse_joint then
    self.mouse_joint:destroy()
    self.mouse_joint = nil
  end
end

---@param x number
---@param y number
---@param _ number
function Splash:mousepressed(x, y, _)
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
end

function Splash:mousemoved(x, y)
  Shared.highlight_when_no_mouse_joint(self.objects, self.mouse_joint, "JAR", x, y)
end

function Splash:mousereleased()
  self:destroy_mouse_joint()
end

local PICKLE_MAX = 200

---@param dt number
function Splash:update(dt)
  local SPAWN_PICKLE = 0.3
  self.timer = self.timer + dt
  if self.pickle_count < PICKLE_MAX and self.timer > SPAWN_PICKLE then
    self.timer = self.timer - SPAWN_PICKLE
    Shared.spawn_random_pickle(self.world, self.objects)
    self.pickle_count = self.pickle_count + 1
  end

  if self.mouse_joint then
    self.mouse_joint:setTarget(love.mouse.getPosition())
  end
  self.world:update(dt)
end

function Splash:draw()
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
  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()

  local title_y_offset = -200
  Shared.draw_static_text(self.preamble, window_width / 2, window_height / 2 + title_y_offset)
  title_y_offset = title_y_offset + self.preamble.text_height

  Shared.draw_static_text(self.title, window_width / 2, window_height / 2 + title_y_offset)
  title_y_offset = title_y_offset + self.sub_title.text_height

  Shared.draw_static_text(self.sub_title, window_width / 2, window_height / 2 + title_y_offset)

  Shared.draw_static_text(self.begin_text, window_width / 2, window_height / 2 + self.begin_text.text_height + 200)
end

return Splash
