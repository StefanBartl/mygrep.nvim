local uv = vim.uv or vim.loop
local encode = vim.json.encode
local decode = vim.json.decode

local M = {}
M.live_grep = {
  history = {},
  favorites = {},
  persist = {},
}
M.multigrep = {
  history = {},
  favorites = {},
  persist = {},
}

---@private
-- Nur gültige Strings akzeptieren
local function is_valid_query(s)
  return type(s) == "string" and s ~= ""
end


---@private
local function tbl_indexof(t, val)
  for i, v in ipairs(t) do
    if v == val then return i end
  end
  return -1
end

---@private
local function get_storage_path(tool)
  local dir = vim.fn.stdpath("cache") .. "/mygrep"
  vim.fn.mkdir(dir, "p")
  return dir .. "/" .. tool .. ".json"
end

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

function M.add_history(state, input)
  if is_valid_query(input) and (state.history[#state.history] ~= input) then
    table.insert(state.history, input)
  end
end

function M.toggle_state(state, query)
  if not is_valid_query(query) then return end

  local idx = tbl_indexof(state.favorites, query)
  if idx ~= -1 then
    table.remove(state.favorites, idx)
    table.insert(state.persist, query)
  else
    local persist_idx = tbl_indexof(state.persist, query)
    if persist_idx ~= -1 then
      table.remove(state.persist, persist_idx)
    else
      table.insert(state.favorites, query)
    end
  end
end

function M.remove(state, query)
  if not is_valid_query(query) then return end
  local function remove_from(tbl)
    local i = tbl_indexof(tbl, query)
    if i ~= -1 then table.remove(tbl, i) end
  end
  remove_from(state.history)
  remove_from(state.favorites)
  remove_from(state.persist)
end

function M.save(tool, state)
  local path = get_storage_path(tool)

  local filtered = vim.tbl_filter(is_valid_query, state.persist or {})
  local ok, json = pcall(encode, { persist = filtered })
  if not ok then
    vim.notify("[mygrep] Failed to encode JSON: " .. tostring(json), vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.fnamemodify(path, ":h")
  vim.fn.mkdir(dir, "p")

  local f, err = io.open(path, "w")
  if not f then
    vim.notify("[mygrep] Failed to open file for writing: " .. err, vim.log.levels.ERROR)
    return
  end

  f:write(json)
  f:close()
end

function M.load(tool, state)
  local path = get_storage_path(tool)
  local ok, content = pcall(vim.fn.readfile, path)
  if not ok or not content then return end

  local decoded = decode(table.concat(content, "\n"))
  if not decoded then return end

  state.persist = vim.tbl_filter(is_valid_query, decoded.persist or {})
end

return M
