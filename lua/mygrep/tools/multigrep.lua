---@module 'mygrep.tools.multigrep'
---@class ToolMultigrep
---@brief Grep tool that supports multiple patterns and glob filters
---@description
--- This tool allows advanced grep queries using `ripgrep` directly,
--- supporting syntax like: `error  *.js` (pattern + glob).
--- It is enhanced with session memory, favorites, and persistent query storage
--- via the shared core modules of mygrep.

-- Telescope Components
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local sorters = require("telescope.sorters")

-- Project Core
local picker = require("mygrep.core.picker")
local history = require("mygrep.core.history")

local M = {}

---Generates the `rg` command arguments for given query
---@param prompt string
---@return string[]|nil
local function command_generator(prompt)
  if not prompt or prompt == "" then return nil end
  local pieces = vim.split(prompt, "  ")
  local args = { "rg" }

  if pieces[1] then
    table.insert(args, "-e")
    table.insert(args, pieces[1])
  end

  if pieces[2] then
    table.insert(args, "-g")
    table.insert(args, pieces[2])
  end

  vim.list_extend(args, {
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
  })

  return args
end

---Runs multigrep with memory layer
---@param opts? table
function M.run(opts)
  local tool = "multigrep"
  local state = history.get("live_grep")

  picker.open(tool, "Multi Grep", function(input)
    opts = opts or {}
    opts.cwd = opts.cwd or vim.uv.cwd()

    pickers.new(opts, {
      prompt_title = "Multi Grep",
      debounce = 100,
      finder = finders.new_async_job {
        command_generator = function() return command_generator(input) end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd,
      },
      previewer = conf.grep_previewer(opts),
      sorter = sorters.empty(),
    }):find()
  end, state)
end

return M
