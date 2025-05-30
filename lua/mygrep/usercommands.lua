---@module 'mygrep.usercommands'
---@brief Defines Neovim :Mygrep user commands
---@description
--- Provides user-facing commands to run specific grep tools or show tool list.
--- Registered tools are dynamically looked up via the mygrep registry.

-- Core Registry
local registry = require("mygrep.core.registry")

-- Safe utility
local safe_call = require("mygrep.utils.safe_call").safe_call

local M = {}

---Run a tool by name (e.g. :Mygrep live_grep)
---@param toolname string
local function run_tool(toolname)
  local tool = registry.get(toolname)
  if tool and tool.run then
    tool.run()
  else
    vim.notify("mygrep: unknown tool '" .. toolname .. "'", vim.log.levels.WARN)
  end
end

---List available tools and let user select one via input
local function choose_tool()
  local all = registry.list()
  if #all == 0 then
    vim.notify("No tools registered", vim.log.levels.ERROR)
    return
  end

  vim.ui.select(all, {
    prompt = "Select grep tool",
    format_item = function(item) return "🔍 " .. item end,
  }, function(choice)
    if choice then
      run_tool(choice)
    end
  end)
end

-- :Mygrep <toolname?>
vim.api.nvim_create_user_command("Mygrep", function(opts)
  local tool = opts.args
  if tool == "" then
    choose_tool()
  else
    run_tool(tool)
  end
end, {
  nargs = "?",
  desc = "Run a registered mygrep tool or open selection menu",
  complete = function()
    return registry.list()
  end,
})

return M
