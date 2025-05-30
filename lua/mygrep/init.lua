---@module 'mygrep'
---@brief Plugin entrypoint and tool registration
---@description
--- Initializes mygrep.nvim by registering all built-in tools
--- and preparing them for user invocation. This file should be
--- required from your Neovim config (e.g. via lazy.nvim).
---
--- @see mygrep.core.registry
--- @see mygrep.tools.live_grep
--- @see mygrep.tools.multigrep

-- Core
local registry = require("mygrep.core.registry")

-- Tools
local live_grep = require("mygrep.tools.live_grep")
local multigrep = require("mygrep.tools.multigrep")

-- Register available tools
registry.register("live_grep", {
  name = "live_grep",
  run = live_grep.run,
})

registry.register("multigrep", {
  name = "multigrep",
  run = multigrep.run,
})

-- UI
require("mygrep.usercommands")
require("mygrep.keymaps")

return {
  registry = registry, -- for testing or external usage
}
