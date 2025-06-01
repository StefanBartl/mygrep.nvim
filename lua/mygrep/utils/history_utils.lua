---@module 'mygrep.utils.history_utils'
---@brief Shared utilities for history, favorites, and persistent entries
---@description
--- This module provides helper functions to manage and validate
--- entries in tool state tables (history, favorites, persist), including
--- input validation, deduplication, and storage path resolution.

local M = {}

---Returns true if s is a valid query (string and not empty)
---@param s any
---@return boolean
function M.is_valid_query(s)
  return type(s) == "string" and s ~= ""
end

---Returns the index of val in list or -1 if not found
---@param t any[]
---@param val any
---@return integer
function M.index_of(t, val)
  for i, v in ipairs(t) do
    if v == val then return i end
  end
  return -1
end

---Returns the tool-specific file path for persistent storage
---@param tool ToolName
---@return string
function M.get_storage_path(tool)
  local dir = vim.fn.stdpath("data") .. "/mygrep"
  vim.fn.mkdir(dir, "p")
  return dir .. "/" .. tool .. ".json"
end

---Builds a deduplicated, flat history list from all categories
---@param state ToolState
---@return string[]
function M.build_combined_history(state)
  local result, seen = {}, {}
  for _, list in ipairs({ state.history, state.favorites, state.persist }) do
    for _, entry in ipairs(list) do
      if not seen[entry] and M.is_valid_query(entry) then
        table.insert(result, entry)
        seen[entry] = true
      end
    end
  end
  return result
end

---Sanitizes a new history input: ensures no dupes, enforces limit
---Can be called before inserting a new item manually
---@param state ToolState
---@param input string
---@param limit integer
function M.sanitize_history(state, input, limit)
  if not M.is_valid_query(input) then return end

  for _, v in ipairs(state.history) do
    if v == input then return end
  end

  table.insert(state.history, input)

  while #state.history > limit do
    table.remove(state.history, 1)
  end
end

return M
