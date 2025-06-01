---@module 'mygrep.core.history'
---@brief Manages per-tool search history, favorites, and persistent queries
local M = {}


-- Utilities
local encode = vim.json.encode
local decode = vim.json.decode
local safe_call = require("mygrep.utils.safe_call").safe_call
local get_option = require("mygrep.config").get_option
--History Utils
local history_utils = require("mygrep.utils.history_utils")
local is_valid_query = history_utils.is_valid_query
local get_storage_path = history_utils.get_storage_path
local index_of = history_utils.index_of


---@private
---@param tbl table
---@param query string
local function remove_from_tbl(tbl, query)
  local idx = index_of(tbl, query)
  if idx ~= -1 then table.remove(tbl, idx) end
end


---@param state ToolState
---@param query string
function M.remove_from_all(state, query)
  if not is_valid_query(query) then return end

  remove_from_tbl(state.history, query)
  remove_from_tbl(state.favorites, query)
  remove_from_tbl(state.persist, query)
end


---@param tool ToolName
---@return ToolState
function M.get(tool)
  local state = M[tool]
  if type(state) ~= "table" or type(state.history) ~= "table" or type(state.favorites) ~= "table" or type(state.persist) ~= "table"then
    M[tool] = {
      history = {},
      favorites = {},
      persist = {},
    }
  end

  return M[tool]
end


---@param state ToolState
---@param input string
function M.add_history(state, input)
  if not is_valid_query(input) then return end

  -- Avoid duplicates anywhere in history
  for _, entry in ipairs(state.history) do
    if entry == input then
      return -- already exists, do not re-add
    end
  end

  -- Append new input
  table.insert(state.history, input)

  -- Enforce history length limit (FIFO)
  local limit = get_option("history_limit") or 100
  while #state.history > limit do
    table.remove(state.history, 1) -- remove oldest
  end
end


---Toggles the query's status in the memory layers:
---  - If it's a session-only entry: mark as favorite ()
---  - If it's a favorite: promote to persistent ()
---  - If it's persistent: remove it from memory
---@param state ToolState
---@param query string
function M.toggle_state(state, query)
  if not is_valid_query(query) then return end

  -- Check if it's a favorite
  local fav_idx = index_of(state.favorites, query)
  if fav_idx ~= -1 then
    -- Promote to persistent: remove from favorites, add to persist
    table.remove(state.favorites, fav_idx)
    table.insert(state.persist, query)
    return
  end

  -- Check if it's already persistent
  local per_idx = index_of(state.persist, query)
  if per_idx ~= -1 then
    -- Remove it completely from memory (final state)
    table.remove(state.persist, per_idx)
    return
  end

  -- Otherwise, mark it as a new favorite
  table.insert(state.favorites, query)
end


---Toggles state in reverse direction
---Steps:
--- 1. Remove the query from all lists (history, favorites, persist)
--- 2. If it was in `persist`: move to `favorites`
--- 3. If it was in `favorites`: move to `history` (session)
--- 4. If it was in `history`: move to `persist`
---@param state ToolState
---@param query string
function M.toggle_state_reverse(state, query)
  if not is_valid_query(query) then return end

  -- Persistent → Favorite
  if index_of(state.persist, query) ~= -1 then
    M.remove_from_all(state, query)
    table.insert(state.favorites, query)
    return
  end

  -- Favorite → Session
  if index_of(state.favorites, query) ~= -1 then
    M.remove_from_all(state, query)
    table.insert(state.history, query)
    return
  end

  -- Session → Persistent
  if index_of(state.history, query) ~= -1 then
    M.remove_from_all(state, query)
    table.insert(state.persist, query)
    return
  end
end



---Writes a querie to th tool path json file
---@param tool ToolName
---@param state ToolState
function M.save(tool, state)
  local path = get_storage_path(tool)
  local persist = vim.tbl_filter(is_valid_query, state.persist or {})

  -- Limit on number of persisted entries (overrwrites old for new ones)
  local persist_limit = get_option("persist_limit") or 100
  if #persist > persist_limit then
    persist = vim.list_slice(persist, #persist - persist_limit + 1, #persist)
  end

  local ok, json = pcall(encode, { persist = persist })
  if not ok then
    vim.notify("[mygrep] Failed to encode JSON: " .. tostring(json), vim.log.levels.ERROR)
    return
  end

  local f, err = io.open(path, "w")
  if not f then
    vim.notify("[mygrep] Failed to write file: " .. err, vim.log.levels.ERROR)
    return
  end

  f:write(json)
  f:close()
end


---Loads the persistent table form the json file and sets the them to state.persistent in the RAM
---@param tool ToolName
---@param state ToolState
function M.load(tool, state)
  local path = get_storage_path(tool)

  local read_ok = safe_call(vim.fn.readfile, path)
  if not read_ok.ok then
    vim.notify("[mygrep] Failed to read file: " .. tostring(read_ok.err), vim.log.levels.ERROR)
    return
  end


  local decoded = decode(table.concat(read_ok.result, "\n"))
  if type(decoded) == "table" and type(decoded.persist) == "table" then
    state.persist = vim.tbl_filter(is_valid_query, decoded.persist)
  end
end

return M
