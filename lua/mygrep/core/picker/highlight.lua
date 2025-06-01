---@module 'mygrep.core.picker.highlight'
---@brief Symbol and highlight definitions for history picker entries
---@description
--- Provides shared EntryTag → symbol and highlight group mapping,
--- as well as highlight setup compatible with Telescope.
local M = {}


---@type table<EntryTag, { symbol: string, hl: string }>
M.tag_defs = {
  favorite = { symbol = " ", hl = "MyGrepFavorite" },
  persist  = { symbol = " ", hl = "MyGrepPersist" },
  session  = { symbol = "S  ",  hl = "MyGrepSession" },
}

---Ensures highlight groups exist and are linked to defaults
---@return nil
function M.apply_history_highlights()
  local api = vim.api
  local links = {
    MyGrepFavorite = "TelescopeResultsNumber",
    MyGrepPersist  = "TelescopeResultsOperator",
    MyGrepSession  = "Comment",
  }

  for group, link in pairs(links) do
    api.nvim_set_hl(0, group, { link = link, default = true })
  end
end

return M

