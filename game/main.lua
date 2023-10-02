-- https://github.com/LuaLS/lua-language-server/wiki/Annotations
local love = require "love"
local Static = require "static"
local Main = require "main_state"
local Global = require "global"
local Splash = require "splash_state"

---@type Splash | Main
local state = nil

local function handle_messages()
  for _, message in ipairs(Global.messages) do
    if message == "BEGIN" then
      state = Main:new()
    end
    if message == "SPLASH" then
      state = Splash:new()
    end
  end
  Global.reset_messages()
end

local function load_static()
  Static.font_small = love.graphics.newFont(16)
  Static.font_medium = love.graphics.newFont(32)
  Static.font_large = love.graphics.newFont(64)
end

love.load = function()
  math.randomseed(os.time())
  load_static()
  state = Splash:new()
end

---@type love.keypressed
love.keypressed = function(key)
  state:keypressed(key)
end

---@type love.mousepressed
love.mousepressed = function(x, y, button, _, _)
  state:mousepressed(x, y, button)
end

---@type love.mousereleased
love.mousereleased = function(x, y, button, _, _)
  state:mousereleased(x, y, button)
end

---@type love.mousemoved
love.mousemoved = function(x, y, _, _, _)
  state:mousemoved(x, y)
end

---@type love.update
love.update = function(dt)
  handle_messages()
  state:update(dt)
end

---@type love.draw
love.draw = function()
  state:draw()
end
