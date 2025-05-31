---@module 'mygrep.core.history'
---@brief Manages per-tool search history, favorites, and persistent queries

local uv = vim.uv or vim.loop
local encode = vim.json.encode
local decode = vim.json.decode

local M = {}

-- Private ---------------------------------------------------------------------

---@param s any
---@return boolean
local function is_valid_query(s)
  return type(s) == "string" and s ~= ""
end

---@param t any[]
---@param val any
---@return integer
local function index_of(t, val)
  for i, v in ipairs(t) do
    if v == val then return i end
  end
  return -1
end

---@param tool ToolName
---@return string
local function get_storage_path(tool)
  local dir = vim.fn.stdpath("data") .. "/mygrep"
  vim.fn.mkdir(dir, "p")
  return dir .. "/" .. tool .. ".json"
end

-- Public API ------------------------------------------------------------------

---@param tool ToolName
---@return ToolState
function M.get(tool)
  assert(type(tool) == "string", "[mygrep] tool must be a string")

  local state = M[tool]
  if type(state) ~= "table" or type(state.history) ~= "table" then
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
  if is_valid_query(input) and state.history[#state.history] ~= input then
    table.insert(state.history, input)
  end
end

---@param state ToolState
---@param query string
function M.toggle_state(state, query)
  if not is_valid_query(query) then return end

  local fav_idx = index_of(state.favorites, query)
  if fav_idx ~= -1 then
    table.remove(state.favorites, fav_idx)
    table.insert(state.persist, query)
    return
  end

  local per_idx = index_of(state.persist, query)
  if per_idx ~= -1 then
    table.remove(state.persist, per_idx)
    return
  end

  table.insert(state.favorites, query)
end

---@param state ToolState
---@param query string
function M.toggle_state_reverse(state, query)
  if not is_valid_query(query) then return end

  -- remove from all lists first
  local function remove_all()
    local function remove(t)
      local i = index_of(t, query)
      if i ~= -1 then table.remove(t, i) end
    end
    remove(state.favorites)
    remove(state.persist)
    remove(state.history)
  end

  -- Persistent → Favorite
  if index_of(state.persist, query) ~= -1 then
    remove_all()
    table.insert(state.favorites, query)
    return
  end

  -- Favorite → Session
  if index_of(state.favorites, query) ~= -1 then
    remove_all()
    table.insert(state.history, query)
    return
  end

  -- Session → Persistent
  if index_of(state.history, query) ~= -1 then
    remove_all()
    table.insert(state.persist, query)
    return
  end
end

---@param state ToolState
---@param query string
function M.remove(state, query)
  if not is_valid_query(query) then return end

  local function remove_from(tbl)
    local idx = index_of(tbl, query)
    if idx ~= -1 then table.remove(tbl, idx) end
  end

  remove_from(state.history)
  remove_from(state.favorites)
  remove_from(state.persist)
end

---@param tool ToolName
---@param state ToolState
function M.save(tool, state)
  local path = get_storage_path(tool)
  local persist = vim.tbl_filter(is_valid_query, state.persist or {})

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

---@param tool ToolName
---@param state ToolState
function M.load(tool, state)
  local path = get_storage_path(tool)

  local ok, content = pcall(vim.fn.readfile, path)
  if not ok or not content then return end

  local decoded = decode(table.concat(content, "\n"))
  if type(decoded) == "table" and type(decoded.persist) == "table" then
    state.persist = vim.tbl_filter(is_valid_query, decoded.persist)
  end
end

return M
