---@module 'mygrep.tools.live_grep'
---@class ToolLiveGrep
---@brief Memory-enhanced wrapper for Telescope's builtin `live_grep`
---@description
--- Provides a live_grep interface with session history, favorites,
--- and persistent query support using shared mygrep core modules.
local M = {}

local builtin = require("telescope.builtin")
local picker = require("mygrep.core.picker")
local history = require("mygrep.core.history")
local search_root = require("mygrep.context.search_root")


---Start a memory-aware live_grep search
---@param opts? table Optional Telescope config overrides
function M.run(opts)
  local tool = "live_grep"
  local state = history.get(tool)
  if not state then
    vim.notify("[mygrep] Failed to load state for 'live_grep'", vim.log.levels.ERROR)
    return
  end

  history.load(tool, state)

  picker.open(tool, "Live Grep", function(input)
    if type(input) ~= "string" or input == "" then
      vim.notify("[mygrep] Invalid input passed to live_grep", vim.log.levels.WARN)
      return
    end

    local args = vim.tbl_extend("force", opts or {}, {
      default_text = input,
      cwd = search_root.get(),
    })

    builtin.live_grep(args)
  end, state)
end

return M
