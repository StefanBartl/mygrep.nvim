---@module 'mygrep.ui.tool_selector'
---@brief Displays a floating UI to select a grep tool
local M = {}

local api = vim.api
local notify = vim.notify
local registry = require("mygrep.core.registry")

local state = {
  win = nil,
  buf = nil,
  tools = {},
  ns = api.nvim_create_namespace("MyGrepToolSelector"),
}

local function close()
  if state.win and api.nvim_win_is_valid(state.win) then
    api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

local function update_highlight()
  if not state.buf or not state.win then return end
  api.nvim_buf_clear_namespace(state.buf, state.ns, 0, -1)
  local lnum = api.nvim_win_get_cursor(state.win)[1] - 1
  vim.highlight.range(
    state.buf,
    state.ns,
    "Visual",
    { lnum, 0 },
    { lnum, -1 },
    { inclusive = true }
  )
end

function M.open()
  local all_tools = registry.list()
  if vim.tbl_isempty(all_tools) then
    notify("[mygrep] No tools registered", vim.log.levels.WARN)
    return
  end

  local current_file = vim.fn.expand("%:p")
  state.tools = {}

  for _, name in ipairs(all_tools) do
    local disabled = (name == "multigrep_file") and (current_file == "")
    table.insert(state.tools, { name = name, disabled = disabled })
  end

  -- Sort tools (live_grep always first)
  table.sort(state.tools, function(a, b)
    if a.name == "live_grep" then return true end
    if b.name == "live_grep" then return false end
    return a.name < b.name
  end)

  local lines = {}
  for i, tool in ipairs(state.tools) do
    local icon = tool.disabled and "" or "🔍"
    lines[i] = string.format("  %s  %s", icon, tool.name)
  end

  state.buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
  vim.bo[state.buf].filetype = "mygrep_tool_selector"

  local width = 40
  local height = #lines + 2
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " MyGrep - Tool Selector ",
    title_pos = "center",
  }

  state.win = api.nvim_open_win(state.buf, true, win_opts)
  vim.wo[state.win].cursorline = true

  update_highlight()

  vim.keymap.set("n", "<Esc>", close, {
    buffer = state.buf,
    desc = "Close tool selector",
    noremap = true,
    silent = true,
  })

  -- Tool execution
  vim.keymap.set("n", "<CR>", function()
    local line = api.nvim_win_get_cursor(state.win)[1]
    local entry = state.tools[line]
    close()
    if entry and not entry.disabled then
      local def = registry.get(entry.name)
      if def and def.run then
        def.run()
      else
        notify("[mygrep] Tool '" .. entry.name .. "' is invalid", vim.log.levels.ERROR)
      end
    end
  end, {
    buffer = state.buf,
    desc = "Run selected tool",
    noremap = true,
    silent = true,
  })


  local function move_cursor(delta)
    local line = api.nvim_win_get_cursor(state.win)[1]
    local new_line = line + delta
    if new_line < 1 then new_line = #state.tools end
    if new_line > #state.tools then new_line = 1 end
    api.nvim_win_set_cursor(state.win, { new_line, 0 })
    update_highlight()
  end

  vim.keymap.set("n", "k", function() move_cursor(-1) end, { buffer = state.buf })
  vim.keymap.set("n", "j", function() move_cursor(1) end, { buffer = state.buf })
  vim.keymap.set("n", "<Up>", function() move_cursor(-1) end, { buffer = state.buf })
  vim.keymap.set("n", "<Down>", function() move_cursor(1) end, { buffer = state.buf })

  -- Autoclose on focus loss
  api.nvim_create_autocmd("WinLeave", {
    buffer = state.buf,
    callback = function()
      vim.defer_fn(close, 30)
    end,
    once = true,
  })

  api.nvim_create_autocmd("CursorMoved", {
    buffer = state.buf,
    callback = update_highlight,
  })
end

return M
