local M = {}

-- https://colorpicker.me
---@type fun(r: integer, g: integer, b: integer): number[]
local function rgb(r, g, b)
  return { r / 255, g / 255, b / 255 }
end

---@type fun(r: integer, g: integer, b: integer, a: integer): number[]
local function rgba(r, g, b, a)
  return { r / 255, g / 255, b / 255, a / 255 }
end

---@type fun(hex_string: string): number[]
local function hex_color(hex_string)
  assert(#hex_string == 7 or #hex_string == 4 or #hex_string == 9 or #hex_string == 5)
  if #hex_string == 7 then
    return rgb(
      tonumber(hex_string:sub(2, 3), 16),
      tonumber(hex_string:sub(4, 5), 16),
      tonumber(hex_string:sub(6, 7), 16)
    )
  elseif #hex_string == 4 then
    return rgb(
      tonumber(hex_string:sub(2, 2) .. hex_string:sub(2, 2), 16),
      tonumber(hex_string:sub(3, 3) .. hex_string:sub(3, 3), 16),
      tonumber(hex_string:sub(4, 4) .. hex_string:sub(4, 4), 16)
    )
  elseif #hex_string == 9 then
    return rgba(
      tonumber(hex_string:sub(2, 3), 16),
      tonumber(hex_string:sub(4, 5), 16),
      tonumber(hex_string:sub(6, 7), 16),
      tonumber(hex_string:sub(8, 9), 16)
    )
  else
    return rgba(
      tonumber(hex_string:sub(2, 2) .. hex_string:sub(2, 2), 16),
      tonumber(hex_string:sub(3, 3) .. hex_string:sub(3, 3), 16),
      tonumber(hex_string:sub(4, 4) .. hex_string:sub(4, 4), 16),
      tonumber(hex_string:sub(5, 5) .. hex_string:sub(5, 5), 16)
    )
  end
end

---@param color number[]
local function highlight(color)
  return { color[1] + 0.1, color[2] + 0.1, color[3] + 0.1 }
end

M.WHITE = hex_color "#FFF"
M.BLACK = hex_color "#000"
M.BLUE = hex_color "#00F"
M.RED = hex_color "#F00"
M.TEAL = hex_color "#0FF"
M.GREEN = hex_color "#0F0"
M.YELLOW = hex_color "#FF0"
M.ORANGE = hex_color "#F80"
M.PURPLE = hex_color "#F0F"
M.GOLDEN = hex_color "#FFD700"

M.PICKLE_1 = hex_color "#384d3e"
M.PICKLE_2 = hex_color "#4e5650"
M.PICKLE_3 = hex_color "#273635"
M.PICKLE_4 = hex_color "#5d814c"
M.PICKLE_5 = hex_color "#577047"

M.rgb = rgb
M.hex_color = hex_color
M.highlight = highlight

return M
