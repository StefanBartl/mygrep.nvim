---@module 'mygrep.core.picker.mappings'
---@brief Keymaps for the main picker interface
---@description
--- This module defines all <insert> mode mappings for the main query picker.
--- It includes history navigation, root switching, and query execution.
local M = {}

-- Vim Utilies
-- ocal safe_call = require("mygrep.utils.safe_call").safe_call
local notify = vim.notify
local defer_fn = vim.defer_fn
-- Telescope dependencies
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
-- History Utilies
local history = require("mygrep.core.history")
local picker_state = require("mygrep.state.picker_state")

---@param bufnr integer
---@param map fun(mode: string, lhs: string, rhs: function)
---@param opts PickerMappingParams
function M.attach_main_picker_mappings(bufnr, map, opts)
  local current_index = (#opts.combined_history > 0) and #opts.combined_history + 1 or 0

  --- Opens root selector, then restores picker with current input
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

    local picker = picker_state.get()
    if picker then
      picker:reset_prompt(entry)
    else
      notify("[mygrep] No active picker available", vim.log.levels.ERROR)
    end
  end)


  ---Cycles to previous query in memory
  map("i", "<C-p>", function()
    if #opts.combined_history == 0 then return end

    current_index = ((current_index - 2 + #opts.combined_history) % #opts.combined_history) + 1
    local entry = opts.combined_history[current_index]
    if not entry then return end

    local picker = picker_state.get()
    if picker then
      picker:reset_prompt(entry)
    else
      notify("[mygrep] No active picker available", vim.log.levels.ERROR)
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

  actions.select_default:replace(function()
    local input = action_state.get_current_line()
    local sel = action_state.get_selected_entry()

    -- Store to history
    history.add_history(opts.tool_state, input)
    actions.close(bufnr)

    vim.defer_fn(function()
      if sel and sel.filename and sel.lnum then
        -- Optional: check file existence first
        if vim.fn.filereadable(sel.filename) == 0 then
          notify("[mygrep] File not readable: " .. sel.filename, vim.log.levels.WARN)
          return
        end

        -- Try to edit the file
        local cmd = "edit " .. vim.fn.fnameescape(sel.filename)
        local ok_edit = pcall(vim.api.nvim_command, cmd)
        if not ok_edit then
          notify("[mygrep] Failed to open file: " .. sel.filename, vim.log.levels.ERROR)
          return
        end

        -- Move cursor to matched line/column
        local line = vim.fn.getline(sel.lnum)
        local regex = vim.fn.escape(input, [[\^$.*~[]])
        local result = require("mygrep.utils.safe_call").safe_call(vim.fn.match, line, regex)
        local col = (result.ok and result.result >= 0) and result.result or 0

        vim.api.nvim_win_set_cursor(0, { sel.lnum, col })
      else
        -- No file to open → just run callback
        opts.callback(input)
      end
    end, 100) -- increased delay for LSP cleanup
  end)

end

return M
