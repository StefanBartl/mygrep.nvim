---@module 'mygrep.core.picker.multigrep_mappings'
local M = {}

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local picker_state = require("mygrep.state.picker_state")
local history = require("mygrep.core.history")
local notify = vim.notify
local defer_fn = vim.defer_fn
local schedule = vim.schedule

---@param bufnr integer
---@param map fun(mode: string, lhs: string, rhs: function)
---@param opts PickerMappingParams
function M.attach(bufnr, map, opts)
  local current_index = #opts.combined_history + 1

  -- Save active picker
  local ok, picker = pcall(action_state.get_current_picker, bufnr)
  if ok and picker then
    picker_state.set(picker)
  end

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
