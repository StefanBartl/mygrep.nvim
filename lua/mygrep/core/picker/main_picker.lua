---@module 'mygrep.core.picker.main_picker'
---@brief Entry point for the standard live picker
---@description
--- This module defines the default query prompt using Telescope.
--- It handles history rotation (<C-n>, <C-p>), root switching (<F5>),
--- and entry execution. Key mappings are provided via mappings.lua.
local M = {}

-- Telescope APIs
local builtin = require("telescope.builtin")

-- MyGrep internals
local mappings = require("mygrep.core.picker.mappings")
local history_utils = require("mygrep.utils.history_utils")

---@param tool ToolName
---@param title string
---@param callback fun(query: string)
---@param tool_state ToolState
---@param opts? PickerUserOpts
function M.open(tool, title, callback, tool_state, opts)
  opts = opts or {}

  if type(tool_state) ~= "table" or type(tool_state.history) ~= "table" then
    vim.notify("[mygrep] Picker called without valid state", vim.log.levels.ERROR)
    return
  end

  local default_text = opts.default_text or ""
  local combined_history = history_utils.build_combined_history(tool_state)

  builtin.live_grep({
    prompt_title = title,
    default_text = default_text,
    attach_mappings = function(bufnr, map)
      mappings.attach_main_picker_mappings(bufnr, map, {
        tool = tool,
        title = title,
        callback = callback,
        tool_state = tool_state,
        combined_history = combined_history,
        last_prompt = default_text,
      })
      return true
    end,
  })
end

return M

