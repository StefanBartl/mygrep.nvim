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
local config = require("mygrep.config")

-- Tools
local live_grep = require("mygrep.tools.live_grep")
local multigrep = require("mygrep.tools.multigrep")

-- Register built-in tools
registry.register("live_grep", {
  name = "live_grep",
  run = live_grep.run,
})

registry.register("multigrep", {
  name = "multigrep",
  run = multigrep.run,
})

-- Setup UI integrations
require("mygrep.usercommands")

-- Public API
local M = {}

---Plugin setup function (called by user)
---@param opts ConfigOptions
function M.setup(opts)
  if type(opts) == "table" then
    for k, v in pairs(opts) do
      if k == "keymaps" and type(v) == "table" then
        for name, lhs in pairs(v) do
          if config.options.keymaps[name] ~= nil then
            config.options.keymaps[name] = lhs
          else
            vim.notify("[mygrep] Unknown keymap: " .. name, vim.log.levels.WARN)
          end
        end
      elseif config.options[k] ~= nil then
        config.options[k] = v
      else
        vim.notify("[mygrep] Unknown config option: " .. k, vim.log.levels.WARN)
      end
    end
  end

  require("mygrep.keymaps")
end

M.registry = registry

return M
