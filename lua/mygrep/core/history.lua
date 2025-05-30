---@module 'mygrep.core.history'
---@class HistoryManager

local fn = vim.fn
local json = vim.json
local safe_call = require("mygrep.utils.safe_call").safe_call
local active_states = setmetatable({}, { __mode = "v" }) -- weak values

---@type ToolState
local default_state = {
  history = {},   -- session only
  favorites = {}, -- not persisted
  persist = {},   -- stored on disk
}

local M = {}

local function get_storage_path(tool)
  local dir = fn.stdpath("cache") .. "/mygrep"
  fn.mkdir(dir, "p")
  return dir .. "/" .. tool .. ".json"
end

---@param state ToolState
---@return table
local function clone_persistable(state)
  return {
    persist = vim.deepcopy(state.persist),
  }
end

---@param tool ToolName
---@return ToolState
function M.load_from_file(tool)
  local path = get_storage_path(tool)
  local ok, content = safe_call(fn.readfile, path)
  if not ok or type(content) ~= "table" or #content == 0 then
    return vim.deepcopy(default_state)
  end

  local ok2, parsed = safe_call(function()
    return json.decode(table.concat(content, "\n"))
  end)

  if not ok2 or type(parsed) ~= "table" then
    return vim.deepcopy(default_state)
  end

  return vim.tbl_deep_extend("force", vim.deepcopy(default_state), parsed)
end

function M.get(tool)
  if active_states[tool] then return active_states[tool] end
  local state = M.load_from_file(tool)
  active_states[tool] = state
  return state
end

---@param tool ToolName
---@param state ToolState
---@return boolean, string?
function M.save(tool, state)
  local path = get_storage_path(tool)
  local ok, encoded = safe_call(json.encode, clone_persistable(state))
  if not ok or not encoded then
    return false, "Failed to encode state"
  end
  local ok2, res = pcall(fn.writefile, vim.split(encoded, "\n"), path)
  return ok2, ok2 and nil or tostring(res)
end

---@param state ToolState
---@param input string
---@return boolean
function M.add_history(state, input)
  if not input or input == "" then return false end
  if #state.history == 0 or state.history[#state.history] ~= input then
    table.insert(state.history, input)
    return true
  end
  return false
end

local function indexof(t, val)
  for i, v in ipairs(t) do
    if v == val then return i end
  end
  return nil
end

function M.is_favorite(state, input)
  return indexof(state.favorites, input) ~= nil
end

function M.is_persist(state, input)
  return indexof(state.persist, input) ~= nil
end

---@param state ToolState
---@param input string
---@return "session" | "favorite" | "persist"
function M.get_status(state, input)
  if M.is_persist(state, input) then return "persist" end
  if M.is_favorite(state, input) then return "favorite" end
  return "session"
end

---Toggles memory state (Tab-Zyklus)
---@param state ToolState
---@param input string
---@return string new_state
function M.toggle_state(state, input)
  local is_fav = M.is_favorite(state, input)
  local is_persist = M.is_persist(state, input)

  if not is_fav and not is_persist then
    table.insert(state.favorites, 1, input)
    return "favorite"
  elseif is_fav and not is_persist then
    table.insert(state.persist, 1, input)
    return "persist"
  elseif is_persist then
    -- Remove from both
    local pf = indexof(state.favorites, input)
    if pf then table.remove(state.favorites, pf) end
    local pp = indexof(state.persist, input)
    if pp then table.remove(state.persist, pp) end
    return "session"
  end
end

function M.remove(state, input)
  local removed = false
  for _, list in ipairs({ state.history, state.favorites, state.persist }) do
    local idx = indexof(list, input)
    if idx then
      table.remove(list, idx)
      removed = true
    end
  end
  return removed
end

return M
