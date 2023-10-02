local Color = require "color"

---@class UiButton
---@field tag "UI_BUTTON"
---@field x number
---@field y number
---@field w number
---@field h number
---@field text string
---@field font love.Font
---@field color number[]
---@field text_color number[]
---@field highlighted boolean
---@field callback fun(): nil
local UiButton = {}

---@param x number
---@param y number
---@param w number
---@param h number
---@param text string
---@param font love.Font
---@param color number[]
---@param text_color number[]
---@param callback? (fun(): nil)
function UiButton:new(x, y, w, h, text, font, color, text_color, callback)
  local new = {
    tag = "UI_BUTTON",
    x = x,
    y = y,
    w = w,
    h = h,
    text = text,
    font = font,
    color = color,
    text_color = text_color,
    highlighted = false,
    callback = callback,
  }
  self.__index = self
  return setmetatable(new, self)
end

function UiButton:draw()
  love.graphics.push()
  if self.highlighted then
    love.graphics.setColor(unpack(Color.highlight(self.color)))
  else
    love.graphics.setColor(unpack(self.color))
  end
  love.graphics.translate(self.x, self.y)
  love.graphics.rectangle("fill", 0, 0, self.w, self.h)
  love.graphics.translate(self.w / 2 - self.font:getWidth(self.text) / 2, self.h / 2 - self.font:getHeight() / 2)
  love.graphics.setColor(unpack(self.text_color))
  love.graphics.setFont(self.font)
  love.graphics.print(self.text, 0, 0, 0, 1, 1, 0, 0, 0, 0)
  love.graphics.pop()
end

function UiButton:update()
  local x, y = love.mouse.getPosition()
  self.highlighted = self.x < x and x < self.x + self.w and self.y < y and y < self.y + self.h
end

function UiButton:mousepressed(_, _, _)
  if self.highlighted then
    self.callback()
  end
end

return UiButton
