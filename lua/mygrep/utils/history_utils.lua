---@module 'mygrep.utils.history_utils'
---@brief
---@description
---
local M = {}

---Returns true if parameter s is from type string and not empty string, else false
---@param s any
---@return boolean
function M.is_valid_query(s)
  return type(s) == "string" and s ~= ""
end


---Returns the index of val in t or -1
---@param t any[]
---@param val any
---@return integer
function M.index_of(t, val)
  for i, v in ipairs(t) do
    if v == val then return i end
  end
  return -1
end


---Returns the tool specific path for storing data
---@param tool ToolName
---@return string
function M.get_storage_path(tool)
  local dir = vim.fn.stdpath("data") .. "/mygrep"
  vim.fn.mkdir(dir, "p")
  return dir .. "/" .. tool .. ".json"
end

return M
