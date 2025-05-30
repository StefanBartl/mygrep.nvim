---@module 'mygrep.tools.multigrep'
---@class ToolMultigrep
---@brief Memory-enhanced wrapper for custom rg-based grep with pattern + glob support

-- Telescope dependencies
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local sorters = require("telescope.sorters")

-- mygrep core modules
local picker = require("mygrep.core.picker")
local history = require("mygrep.core.history")

local M = {}

---Builds a `ripgrep` command from user input
---@param prompt string
---@return string[]|nil
local function command_generator(prompt)
  if type(prompt) ~= "string" or prompt == "" then return nil end

  local args = { "rg" }
  local pieces = vim.split(prompt, "  ")

  if pieces[1] and pieces[1] ~= "" then
    table.insert(args, "-e")
    table.insert(args, pieces[1])
  end

  if pieces[2] and pieces[2] ~= "" then
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

---Starts a custom grep using `rg` with memory tracking
---@param opts? table Optional Telescope configuration
function M.run(opts)
  local tool = "multigrep"
  local state = history.get(tool)
  if not state then
    vim.notify("[mygrep] Failed to load state for 'multigrep'", vim.log.levels.ERROR)
    return
  end

  history.load(tool, state)

  picker.open(tool, "Multi Grep", function(input)
    if type(input) ~= "string" or input == "" then
      vim.notify("[mygrep] Invalid input passed to multigrep", vim.log.levels.WARN)
      return
    end

    local args = command_generator(input)
    if not args then
      vim.notify("[mygrep] No valid command generated for input", vim.log.levels.WARN)
      return
    end

    opts = opts or {}
    local cwd = opts.cwd or (vim.uv and vim.uv.cwd()) or vim.fn.getcwd()

    pickers.new(opts, {
      prompt_title = "Multi Grep",
      debounce = 100,
      finder = finders.new_async_job {
        command_generator = function() return args end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = cwd,
      },
      previewer = conf.grep_previewer(opts),
      sorter = sorters.empty(),
    }):find()
  end, state)
end

return M
