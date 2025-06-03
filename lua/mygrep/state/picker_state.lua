---@module 'mygrep.state.picker_state'
---@brief Holds reference to the current active Telescope picker
local M = {}

---@type TelescopePicker|nil
local current = nil

---Sets the current picker
---@param picker table
function M.set(picker)
  current = picker
end

---Returns the current picker
---@return table|nil
function M.get()
  return current
end

---Resets the current picker (clears state)
function M.clear()
  current = nil
end

return M
