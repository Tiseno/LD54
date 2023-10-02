local M = {}

---@type ("BEGIN"|"SPLASH")[]
M.messages = {}
---@type fun(message: "BEGIN"|"SPLASH")
function M.send_message(message)
  M.messages[#M.messages + 1] = message
end

function M.reset_messages()
  M.messages = {}
end

return M
