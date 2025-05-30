---@module 'mygrep.tools.live_grep'
---@class ToolLiveGrep
---@brief Grep tool using Telescope's builtin live_grep with memory support
---@description
--- This module implements a wrapper around `builtin.live_grep` enhanced with
--- session history, favorites, and persistence using the shared mygrep core.
--- It delegates all memory, picker and state logic to the shared `core` modules.

-- Telescope Core
local builtin = require("telescope.builtin")

-- Project Core
local picker = require("mygrep.core.picker")
local history = require("mygrep.core.history")

local M = {}

---Runs live_grep with memory layer
---@param opts? table Optional Telescope opts
function M.run(opts)
  local tool = "live_grep"
  local state = history.get("live_grep")

  picker.open(tool, "Live Grep", function(input)
    if type(input) == "string" and input ~= "" then
      builtin.live_grep(vim.tbl_extend("force", opts or {}, { default_text = input }))
    else
      vim.notify("[mygrep] Invalid input passed to live_grep: " .. vim.inspect(input), vim.log.levels.WARN)
    end
  end, state)
end

return M
