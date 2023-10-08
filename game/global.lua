local M = {}

---@type ("BEGIN"|"RESTART")[]
M.messages = {}
---@type fun(message: "BEGIN"|"RESTART")
function M.send_message(message)
  M.messages[#M.messages + 1] = message
end

function M.reset_messages()
  M.messages = {}
end

return M
