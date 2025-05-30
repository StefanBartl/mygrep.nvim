---@module 'mygrep.utils.safe_call'
---@brief Provides a safe wrapper around pcall() with structured result
---@description
--- This module wraps `pcall()` into a structured response object.
--- Instead of relying on boolean + varargs, it returns:
--- `{ ok = true, result = ..., err = nil }`
--- or
--- `{ ok = false, result = nil, err = <message> }`
--- It is recommended for use in all IO, decoding and user input contexts.

local M = {}

---Performs a protected call and wraps result in a table
---@generic T
---@param fn fun(...): T
---@param ... any Arguments for the function
---@return boolean, T|string If ok, returns result; otherwise, error message
function M.safe_call(fn, ...)
  local ok, result = pcall(fn, ...)
  if ok then
    return true, result
  else
    return false, tostring(result)
  end
end

return M
