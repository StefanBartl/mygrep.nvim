---@module 'mygrep.core.registry'
---@brief Central registry for all grep tools
---@description
--- Provides dynamic registration and retrieval of grep tools.
--- Tools are registered with a unique name and a run entrypoint.
--- Other modules can lookup tools by name to invoke them generically.
local M = {}

---@type RegistryTable
local tools = {}


---Validates a registry entry
---@param entry any
---@return boolean
local function is_valid_entry(entry)
  return type(entry) == "table" and type(entry.run) == "function"
end


---Registers a new grep tool
---@param name ToolName
---@param entry RegistryEntry
---@return boolean, string? Error message if registration fails
function M.register(name, entry)
  if type(name) ~= "string" or not is_valid_entry(entry) then
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
