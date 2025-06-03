---@module 'mygrep.tools.multigrep'
---@class ToolMultigrep
---@brief Memory-enhanced wrapper for custom rg-based grep with pattern + glob support
local M = {}

-- Vim Utilities
local notify = vim.notify
-- Telescope dependencies
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local sorters = require("telescope.sorters")
-- mygrep core modules
local history = require("mygrep.core.history")
local history_utils = require("mygrep.utils.history_utils")
local multigrep_mappings = require("mygrep.core.picker.multigrep_mappings")

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
    notify("[mygrep] Failed to load state for 'multigrep'", vim.log.levels.ERROR)
    return
  end

  history.load(tool, state)

  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()
  local filename = vim.fn.expand("%:t")
  local prompt_title = "Multi Grep: " .. filename
  local combined_history = history_utils.build_combined_history(state)

  pickers.new(opts, {
    prompt_title = prompt_title,
    debounce = 100,
    finder = finders.new_async_job {
      command_generator = function(prompt)
        return command_generator(prompt)
      end,
      entry_maker = make_entry.gen_from_vimgrep(opts),
      cwd = cwd,
    },
    previewer = conf.grep_previewer(opts),
    sorter = sorters.empty(),
    attach_mappings = function(bufnr, map)
      multigrep_mappings.attach(bufnr, map, {
        tool = tool,
        title = prompt_title,
        callback = function(input)
          local args = command_generator(input)
          if not args then
            notify("[mygrep] Invalid input", vim.log.levels.WARN)
            return
          end
          -- Neu starten mit aktualisiertem Prompt
          vim.defer_fn(function()
            vim.cmd("stopinsert")
            vim.schedule(function()
              M.run({ cwd = cwd, default_text = input })
            end)
          end, 10)
        end,
        tool_state = state,
        combined_history = combined_history,
        last_prompt = "",
      })
      return true
    end,
  }):find()
end

return M
