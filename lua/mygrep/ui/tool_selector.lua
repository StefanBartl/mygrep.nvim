---@module 'mygrep.ui.tool_selector'
---@brief Displays a floating UI to select a grep tool
---@description
--- Uses a centered floating window with a selectable list of registered tools.
--- The user can navigate and select a tool using <CR>. ESC closes the menu.

local api = vim.api
local registry = require("mygrep.core.registry")

local M = {}

local state = {
  win = nil,
  buf = nil,
  tools = {},
  ns = api.nvim_create_namespace("MyGrepToolSelector"),
}

-- Cleanup function to close window and clear buffer
local function close()
  if state.win and api.nvim_win_is_valid(state.win) then
    api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

-- Highlights the active line visually
local function update_highlight()
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

---Opens the floating tool selector
function M.open()
  state.tools = registry.list()
  if vim.tbl_isempty(state.tools) then
    vim.notify("[mygrep] No tools registered", vim.log.levels.WARN)
    return
  end

  table.sort(state.tools, function(a, b)
    if a == "live_grep" then return true end
    if b == "live_grep" then return false end
    return a < b
  end)

  local lines = vim.tbl_map(function(t) return "  🔍  " .. t end, state.tools)

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

  -- Initial highlight
  update_highlight()

  -- Keymaps (local to buffer)
  vim.keymap.set("n", "<Esc>", close, {
    buffer = state.buf,
    desc = "Close tool selector",
    noremap = true,
    silent = true,
  })

  vim.keymap.set("n", "<CR>", function()
    local line = api.nvim_win_get_cursor(state.win)[1]
    local tool = state.tools[line]
    close()
    if tool then
      local def = registry.get(tool)
      if def and def.run then
        def.run()
      else
        vim.notify("[mygrep] Tool '" .. tool .. "' is invalid", vim.log.levels.ERROR)
      end
    end
  end, {
    buffer = state.buf,
    desc = "Run selected tool",
    noremap = true,
    silent = true,
  })

  api.nvim_create_autocmd("CursorMoved", {
    buffer = state.buf,
    callback = update_highlight,
    once = false,
  })
end

return M

