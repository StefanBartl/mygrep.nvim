---@module 'mygrep.utils.safe_call'
---@brief Provides a structured wrapper around pcall()
---@description
--- Wraps a protected Lua call (`pcall`) and returns a consistent result table.
--- Useful for IO, JSON, unsafe function calls etc.
--- Instead of using `(ok, result)` return, it wraps the result as:
---   { ok = true, result = <T>, err = nil }
--- or
---   { ok = false, result = nil, err = "<string>" }

local M = {}

---Safely calls a function and returns a structured result
---@generic T
---@param fn fun(...): T Function to call
---@param ... any Arguments to pass to `fn`
---@return { ok: true, result: T, err: nil } | { ok: false, result: nil, err: string }
function M.safe_call(fn, ...)
  local ok, result = pcall(fn, ...)
  if ok then
    return { ok = true, result = result, err = nil }
  else
    return { ok = false, result = nil, err = tostring(result) }
  end
end

return M
