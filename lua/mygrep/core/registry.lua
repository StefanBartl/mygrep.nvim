---@module 'mygrep.core.registry'
---@brief Central registry for all grep tools
---@description
--- This module manages tool registration for mygrep.nvim.
--- Each tool registers itself with a unique name and entrypoint.
--- Consumers can then lookup and invoke tools dynamically.

-- System API
local assert = assert

-- Utilities and Debugging
local safe_call = require("mygrep.utils.safe_call").safe_call

-- Types
---@type table<string, RegistryEntry>
local tools = {}

local M = {}

---Registers a new grep tool
---@param name ToolName
---@param entry RegistryEntry
---@return boolean, string? Error message if registration fails
function M.register(name, entry)
  if not name or not entry or type(entry.run) ~= "function" then
    return false, "Invalid registry entry"
  end
  tools[name] = entry
  return true
end

---Retrieves a tool by name
---@param name ToolName
---@return RegistryEntry|nil
function M.get(name)
  return tools[name]
end

---Returns all registered tool names
---@return ToolName[]
function M.list()
  local names = {}
  for k in pairs(tools) do
    table.insert(names, k)
  end
  return names
end

return M
