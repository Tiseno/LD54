local Color = require "color"
local StaticRect = require "static_rect"
local Pickle = require "pickle"

local M = {}

function M.create_static_boundaries(world, objects)
  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()

  table.insert(objects, StaticRect:new(world, 0, window_height, window_width * 2, 50, Color.hex_color "#464b18"))
  table.insert(objects, StaticRect:new(world, 0, 0, 50, window_height * 2, Color.hex_color "#464b18"))
  table.insert(objects, StaticRect:new(world, window_width, 0, 50, window_height * 2, Color.hex_color "#464b18"))
  table.insert(objects, StaticRect:new(world, window_width - 100, 0, 200, window_height / 2, Color.hex_color "#464b18"))
  table.insert(
    objects,
    StaticRect:new(
      world,
      window_width - 100,
      window_height / 2 + 300,
      200,
      window_height / 2,
      Color.hex_color "#464b18"
    )
  )
end

function M.highlight_when_no_mouse_joint(objects, mouse_joint, defer_tag, x, y)
  local found_not_deferred = false
  local candidate = nil
  for _, value in ipairs(objects) do
    if value.highlight then
      value:un_highlight()
      if mouse_joint == nil and value:test_point(x, y) then
        if not found_not_deferred then
          candidate = value
          if value.tag ~= defer_tag then
            found_not_deferred = true
          end
        end
      end
    end
  end
  if candidate then
    candidate:highlight()
  end
end

function M.spawn_random_pickle(world, objects)
  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()
  table.insert(
    objects,
    Pickle:new(world, math.random(0, math.floor(window_width)), -window_height, math.random(1, 360) / 3.14)
  )
end

---@param static_text StaticText
function M.draw_static_text(static_text, x, y)
  love.graphics.setColor(unpack(static_text.color))
  love.graphics.print(
    static_text.text,
    static_text.font,
    x - static_text.text_width / 2,
    y,
    0,
    1,
    1,
    0,
    0,
    0,
    ---@diagnostic disable-next-line: redundant-parameter
    0
  )
end

---@class StaticText
---@field text string
---@field font love.Font
---@field text_width number
---@field text_height number
---@field color number[]
local StaticText = {}

---@type fun(self: StaticText, text: string, font: love.Font, color: number[]): StaticText
function StaticText:new(text, font, color)
  ---@type StaticText
  local new =
    { text = text, font = font, text_width = font:getWidth(text), text_height = font:getHeight(), color = color }
  return new
end

M.StaticText = StaticText

return M
