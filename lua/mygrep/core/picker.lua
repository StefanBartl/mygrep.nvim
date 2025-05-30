---@module 'mygrep.core.picker'
---@class Picker

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local history = require("mygrep.core.history")

local M = {}

function M.open(tool, title, callback, state, opts)
  opts = opts or {}

  if not state or not state.history then
    vim.notify("[mygrep] Picker called without valid state", vim.log.levels.ERROR)
    return
  end

  local default_text = opts.default_text or ""
  local index = #state.history + 1

  require("telescope.builtin").live_grep({
    prompt_title = title,
    default_text = default_text,
    attach_mappings = function(bufnr, map)
      map("i", "<C-n>", function()
        if #state.history == 0 then return end
        index = math.min(index + 1, #state.history)
        local entry = state.history[index]
        if entry then
          actions.close(bufnr)
          vim.defer_fn(function()
            M.open(tool, title, callback, state, { default_text = entry })
          end, 10)
        end
      end)

      map("i", "<C-p>", function()
        if #state.history == 0 then return end
        index = math.max(index - 1, 1)
        local entry = state.history[index]
        if entry then
          actions.close(bufnr)
          vim.defer_fn(function()
            M.open(tool, title, callback, state, { default_text = entry })
          end, 10)
        end
      end)

      map("i", "<C-o>", function()
        local last_prompt = action_state.get_current_line()
        actions.close(bufnr)
        vim.defer_fn(function()
          M.open_history_picker(tool, title, callback, state, last_prompt)
        end, 10)
      end)

      actions.select_default:replace(function(bufnr)
        local input = action_state.get_current_line()
        local selection = action_state.get_selected_entry()

        history.add_history(state, input)
        actions.close(bufnr)

        vim.schedule(function()
          if selection and selection.filename and selection.lnum then
            vim.cmd("edit " .. vim.fn.fnameescape(selection.filename))
            local line = vim.fn.getline(selection.lnum)
            local regex = vim.fn.escape(input, [[\^$.*~[]])
            local ok, start_col = pcall(function()
              return vim.fn.match(line, regex)
            end)
            local col = (ok and start_col >= 0) and start_col + 1 or 1
            vim.api.nvim_win_set_cursor(0, { selection.lnum, col - 1 })
          else
            callback(input)
          end
        end)
      end)

      return true
    end,
  })
end

function M.open_history_picker(tool, title, callback, state, last_prompt)
  history.load(tool, state)

  local entries = {}
  local seen = {}

  local function is_valid(s)
    return type(s) == "string" and s ~= "" and s ~= "function"
  end

  local function push(tag, val)
    if is_valid(val) and not seen[val] then
      seen[val] = true
      local symbol = ({
        favorite = " ",
        persist  = " ",
        session  = "S  ",
      })[tag] or "  "
      local hl = ({
        favorite = "MyGrepFavorite",
        persist  = "MyGrepPersist",
        session  = "MyGrepSession",
      })[tag] or "Comment"

      table.insert(entries, {
        tag = tag,
        value = val,
        ordinal = val,
        display = symbol .. val,
        display_highlights = { { 0, #symbol, hl } },
      })
    end
  end

  for _, v in ipairs(state.favorites) do push("favorite", v) end
  for _, v in ipairs(state.persist) do push("persist", v) end
  for _, v in ipairs(state.history) do push("session", v) end

  vim.api.nvim_set_hl(0, "MyGrepFavorite", { link = "TelescopeResultsNumber", default = true })
  vim.api.nvim_set_hl(0, "MyGrepPersist", { link = "TelescopeResultsOperator", default = true })
  vim.api.nvim_set_hl(0, "MyGrepSession", { link = "Comment", default = true })

  pickers.new({}, {
    prompt_title = title .. " History",
    finder = finders.new_table {
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry.value,
          ordinal = entry.ordinal,
          display = entry.display,
          display_highlights = entry.display_highlights,
        }
      end
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(bufnr, map)
      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        if sel and sel.value then
          actions.close(bufnr)
          callback(sel.value)
        end
      end)

      map("i", "<C-d>", function()
        local sel = action_state.get_selected_entry()
        if not sel or not sel.value then return end
        history.remove(state, sel.value)
        history.save(tool, state)
        M.open_history_picker(tool, title, callback, state, last_prompt)
      end)

      map("i", "<Tab>", function()
        local sel = action_state.get_selected_entry()
        if not sel or not sel.value then return end
        history.toggle_state(state, sel.value)
        history.save(tool, state)
        M.open_history_picker(tool, title, callback, state, last_prompt)
      end)

      map("i", "<Esc>", function()
        actions.close(bufnr)
        vim.defer_fn(function()
          M.open(tool, title, callback, state, { default_text = last_prompt or "" })
        end, 10)
      end)

      return true
    end
  }):find()
end

return M
