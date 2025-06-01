---@module 'mygrep.keymaps'
---@brief Default keymaps for mygrep.nvim
---@description
--- Defines user keybindings for running grep tools, navigating history,
--- opening the tool selection menu, and interacting with memory-enabled pickers.
--- Only applies in normal mode and is designed for consistency across tools.


local registry = require("mygrep.core.registry")
local config = require("mygrep.config")
local kmaps = config.get_option("keymaps") or {}

local function map_if(_, lhs, fn, desc)
  if lhs and lhs ~= "" then
    vim.keymap.set("n", lhs, fn, { noremap = true, silent = true, desc = desc })
  end
end


-- Tool Picker
map_if("open", kmaps.open, require("mygrep.ui.tool_picker").open, "[mygrep] Open tool selector")
-- Live Grep
map_if("live_grep", kmaps.live_grep, function()
  local tool = registry.get("live_grep")
  if tool then tool.run() end
end, "[mygrep] Run live_grep")
-- Multigrep
map_if("multigrep", kmaps.multigrep, function()
  local tool = registry.get("multigrep")
  if tool then tool.run() end
end, "[mygrep] Run multigrep")

-- Picker navigation (only relevant inside insert mode of prompt buffer)
-- These keymaps are dynamically applied by `core/picker.lua`, not globally.
-- Documentation only:
--    <CR>: Execute search and save query in memory / in the history picker re-run the selected query
--   <C-n>: next history
--   <C-p>: previous history
--   <C-o>: open history picker
--   <Tab>: toggle (session → persist → remove)
-- <S-Tab>: Reverse toggle:
--   <C-d>: delete query from history picker
--  <C-Up>: Move query up within its section
--<C-Down>: Move query down within its section
--   <Esc>: Return to main picker with restored prompt

return {}
