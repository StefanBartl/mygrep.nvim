---@module 'mygrep.keymaps'
---@brief Default keymaps for mygrep.nvim
---@description
--- Defines user keybindings for running grep tools, navigating history,
--- opening the tool selection menu, and interacting with memory-enabled pickers.
--- Only applies in normal mode and is designed for consistency across tools.

-- Safe utility
local safe_call = require("mygrep.utils.safe_call").safe_call
local registry = require("mygrep.core.registry")

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- Tool Picker via <leader>gr
vim.keymap.set("n", "<leader><leader>", function()
  require("mygrep.ui.tool_picker").open()
end, { desc = "Open tool selector (floating)" })

-- 🔍 Tool Launch Shortcuts
map("n", "<leader>ml", function()
  local tool = registry.get("live_grep")
  if tool then tool.run() end
end, "[mygrep] Run live_grep")

map("n", "<leader>mm", function()
  local tool = registry.get("multigrep")
  if tool then tool.run() end
end, "[mygrep] Run multigrep")

-- Picker navigation (only relevant inside insert mode of prompt buffer)
-- These keymaps are dynamically applied by `core/picker.lua`, not globally.
-- Documentation only:
--   <C-n>: next history
--   <C-p>: previous history
--   <C-o>: open history picker
--   <Tab>: toggle (session → persist → remove)
--   <C-d>: delete query from history picker

return {}
