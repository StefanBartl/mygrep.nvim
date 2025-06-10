---@module 'mygrep.core.picker.multigrep_mappings'
---@brief Attach picker-specific mappings (e.g. <C-n>, <C-p>, <CR>) for multigrep pickers
---@description
--- Defines and applies picker-specific keymaps for navigating grep history, opening history view,
--- and executing a selected match. Integrates with picker state, history tracking and Telescope.

---@see mygrep.@types.picker
---@see mygrep.utils.safe_call

local M = {}

-- External dependencies
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Project modules
local picker_state = require("mygrep.state.picker_state")
local history = require("mygrep.core.history")
local safe_call = require("mygrep.utils.safe_call").safe_call

-- Shorthands
local notify = vim.notify
local defer_fn = vim.defer_fn
local schedule = vim.schedule

--- Attaches interactive key mappings to a running picker buffer
---@param bufnr integer Buffer number of the active Telescope picker
---@param map fun(mode: string, lhs: string, rhs: function) Mapping utility
---@param opts PickerMappingParams Picker configuration
function M.attach(bufnr, map, opts)
  local current_index = #opts.combined_history + 1

  -- Try to cache the currently active picker into state
  local result = safe_call(action_state.get_current_picker, bufnr)
  if result.ok and result.result then
    picker_state.set(result.result)
  end

  -- Map <C-n> -> next history entry
  map("i", "<C-n>", function()
    if #opts.combined_history == 0 then return end

    current_index = (current_index % #opts.combined_history) + 1
    local entry = opts.combined_history[current_index]
    local picker = picker_state.get()

    if picker and entry then
      picker:reset_prompt(entry)
    else
      notify("[mygrep] No picker or entry", vim.log.levels.WARN)
    end
  end)

  -- Map <C-p> -> previous history entry
  map("i", "<C-p>", function()
    if #opts.combined_history == 0 then return end

    current_index = ((current_index - 2 + #opts.combined_history) % #opts.combined_history) + 1
    local entry = opts.combined_history[current_index]
    local picker = picker_state.get()

    if picker and entry then
      picker:reset_prompt(entry)
    else
      notify("[mygrep] No picker or entry", vim.log.levels.WARN)
    end
  end)

  -- Map <C-o> -> open full history picker
  map("i", "<C-o>", function()
    local input = action_state.get_current_line()
    actions.close(bufnr)

    defer_fn(function()
      require("mygrep.core.picker").open_history_picker(
        opts.tool,
        opts.title,
        opts.callback,
        opts.tool_state,
        input
      )
    end, 10)
  end)

  -- Override default <CR> to either jump to match or run callback
  actions.select_default:replace(function()
    local input = action_state.get_current_line()
    local sel = action_state.get_selected_entry()

    history.add_history(opts.tool_state, input)
    actions.close(bufnr)

    schedule(function()
      if sel and sel.filename and sel.lnum then
        vim.cmd("edit " .. vim.fn.fnameescape(sel.filename))

        local line = vim.fn.getline(sel.lnum)
        local regex = vim.fn.escape(input, [[\^$.*~[]])
        local sc_result = safe_call(vim.fn.match, line, regex)

        local col = (sc_result.ok and sc_result.result >= 0) and sc_result.result or 0
        vim.api.nvim_win_set_cursor(0, { sel.lnum, col })
      else
        opts.callback(input)
      end
    end)
  end)
end

return M
