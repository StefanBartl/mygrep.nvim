---@module 'mygrep.core.picker.mappings'
---@brief Keymaps for the main picker interface
---@description
--- This module defines all <insert> mode mappings for the main query picker.
--- It includes history navigation, root switching, and query execution.
local M = {}

-- Vim Utilies
local safe_call = require("mygrep.utils.safe_call").safe_call
local notify = vim.notify
local defer_fn = vim.defer_fn
local schedule = vim.schedule
-- Telescopr dependencies
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
-- History Utilies
local history = require("mygrep.core.history")

---@param bufnr integer
---@param map fun(mode: string, lhs: string, rhs: function)
---@param opts PickerMappingParams
function M.attach_main_picker_mappings(bufnr, map, opts)
  local current_index = (#opts.combined_history > 0) and #opts.combined_history + 1 or 0

  ---Reopens root selector, then restores picker with current input
  map("i", "<F5>", function()
    local input = action_state.get_current_line()
    actions.close(bufnr)
    defer_fn(function()
      require("mygrep.context.search_root").select()
      defer_fn(function()
        require("mygrep.core.picker").open(
          opts.tool, opts.title, opts.callback, opts.tool_state, { default_text = input }
        )
      end, 100)
    end, 10)
  end)

  ---Cycles to next query in memory
  map("i", "<C-n>", function()
    if #opts.combined_history == 0 then return end

    current_index = (current_index % #opts.combined_history) + 1
    local entry = opts.combined_history[current_index]

    if not entry then return end

    local ok, picker, err = safe_call(action_state.get_current_picker, bufnr)
    if ok and picker then
      picker:reset_prompt(entry)
    else
      -- Try fallback: reset to first known valid query
      local fallback = opts.combined_history[1]
      if fallback then
        local ok_fallback, picker_fallback = safe_call(action_state.get_current_picker, bufnr)
        if ok_fallback and picker_fallback then
          picker_fallback:reset_prompt(fallback)
        else
          notify("[mygrep] Picker error: " .. (err or "Unknown error"), vim.log.levels.ERROR)
        end
      end
    end
  end)


  ---Cycles to previous query in memory
  map("i", "<C-p>", function()
    if #opts.combined_history == 0 then return end

    current_index = ((current_index - 2 + #opts.combined_history) % #opts.combined_history) + 1
    local entry = opts.combined_history[current_index]
    if not entry then return end

    local ok, picker, err = safe_call(action_state.get_current_picker, bufnr)
    if ok and picker then
      picker:reset_prompt(entry)
    else
      local fallback = opts.combined_history[1]
      if fallback then
        local ok_fallback, picker_fallback = safe_call(action_state.get_current_picker, bufnr)
        if ok_fallback and picker_fallback then
          picker_fallback:reset_prompt(fallback)
        else
          notify("[mygrep] Picker error: " .. (err or "Unknown error"), vim.log.levels.ERROR)
        end
      end
    end
  end)


  ---Switch to full history picker
  map("i", "<C-o>", function()
    local input = action_state.get_current_line()
    actions.close(bufnr)
    defer_fn(function()
      require("mygrep.core.picker").open_history_picker(
        opts.tool, opts.title, opts.callback, opts.tool_state, input
      )
    end, 10)
  end)

  ---Default action: run or jump to file
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
        local ok, col = pcall(vim.fn.match, line, regex)
        vim.api.nvim_win_set_cursor(0, { sel.lnum, (ok and col >= 0) and col or 0 })
      else
        opts.callback(input)
      end
    end)
  end)
end

return M

