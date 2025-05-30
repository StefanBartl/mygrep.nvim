---@module 'mygrep.usercommands'
---@brief Defines `:Mygrep` user command interface
---@description
--- Exposes all registered tools via `:Mygrep` command.
--- Supports running a named tool directly or opening a prompt to choose one.

local registry = require("mygrep.core.registry")
local safe_call = require("mygrep.utils.safe_call").safe_call

local M = {}

---Runs a registered grep tool by name
---@param name ToolName
local function run_tool(name)
  local entry = registry.get(name)
  if not entry or type(entry.run) ~= "function" then
    vim.notify("[mygrep] Unknown tool: " .. name, vim.log.levels.WARN)
    return
  end

  local result = safe_call(entry.run)
  if not result.ok then
    vim.notify("[mygrep] Tool execution failed: " .. result.err, vim.log.levels.ERROR)
  end
end

---Presents UI selection list of available tools
local function choose_tool()
  local list = registry.list()
  if vim.tbl_isempty(list) then
    vim.notify("[mygrep] No grep tools registered", vim.log.levels.WARN)
    return
  end

  local ui_ok = safe_call(vim.ui.select, list, {
    prompt = "Select a grep tool",
    format_item = function(item) return "🔍 " .. item end,
  }, function(choice)
    if choice then run_tool(choice) end
  end)

  if not ui_ok.ok then
    vim.notify("[mygrep] Tool chooser failed: " .. ui_ok.err, vim.log.levels.ERROR)
  end
end

---Defines `:Mygrep [toolname]` user command
vim.api.nvim_create_user_command("Mygrep", function(opts)
  local name = opts.args
  if name == "" then
    choose_tool()
  else
    run_tool(name)
  end
end, {
  nargs = "?",
  complete = function() return registry.list() end,
  desc = "Run a registered mygrep tool or open tool chooser",
})

return M
