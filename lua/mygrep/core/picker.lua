---@module 'mygrep.core.picker'
---@brief
---@description
---
---@class Picker
local M = {}


-- Telescope APIs
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

-- MyGrep internals
local history = require("mygrep.core.history")
local history_utils = require("mygrep.utils.history_utils")


---Returns the index of a value in a list or nil
---@param t table
---@param val any
---@return integer|nil
local function tbl_indexof(t, val)
  for i, v in ipairs(t) do
    if v == val then return i end
  end
  return nil
end


---Opens the main picker for a given tool
---@param tool ToolName
---@param title string
---@param callback fun(query: string)
---@param tool_state ToolState
---@param opts? PickerUserOpts
function M.open(tool, title, callback, tool_state, opts)
  opts = opts or {}

  if not tool_state or not tool_state.history then
    vim.notify("[mygrep] Picker called without valid state", vim.log.levels.ERROR)
    return
  end

  local default_text = opts.default_text or ""
  local combined_history = history_utils.build_combined_history(tool_state)
  local current_index = #combined_history + 1

  require("telescope.builtin").live_grep({
    prompt_title = title,
    default_text = default_text,
    attach_mappings = function(bufnr, map)
      map("i", "<F5>", function()
        local last_prompt = action_state.get_current_line()
        actions.close(bufnr)
        vim.defer_fn(function()
          require("mygrep.context.search_root").select()
          vim.defer_fn(function()
            M.open(tool, title, callback, tool_state, { default_text = last_prompt })
          end, 100)
        end, 10)
      end)

      map("i", "<C-n>", function()
        if #combined_history == 0 then return end
        current_index = (current_index % #combined_history) + 1
        local entry = combined_history[current_index]
        if entry then
          require("telescope.actions.state").get_current_picker(bufnr):reset_prompt(entry)
        end
      end)

      map("i", "<C-p>", function()
        if #combined_history == 0 then return end
        current_index = ((current_index - 2 + #combined_history) % #combined_history) + 1
        local entry = combined_history[current_index]
        if entry then
          require("telescope.actions.state").get_current_picker(bufnr):reset_prompt(entry)
        end
      end)

      map("i", "<C-o>", function()
        local last_prompt = action_state.get_current_line()
        actions.close(bufnr)
        vim.defer_fn(function()
          M.open_history_picker(tool, title, callback, tool_state, last_prompt)
        end, 10)
      end)

      actions.select_default:replace(function(_)
        local input = action_state.get_current_line()
        local selection = action_state.get_selected_entry()

        history.add_history(tool_state, input)
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


---Opens the history picker (favorites, persist, session)
---@param tool ToolName
---@param title string
---@param callback fun(query: string)
---@param tool_state ToolState
---@param last_prompt? string
function M.open_history_picker(tool, title, callback, tool_state, last_prompt)
  history.load(tool, tool_state)

  local entries = {}
  local seen = {}

  vim.api.nvim_set_hl(0, "MyGrepFavorite", { link = "TelescopeResultsNumber", default = true })
  vim.api.nvim_set_hl(0, "MyGrepPersist", { link = "TelescopeResultsOperator", default = true })
  vim.api.nvim_set_hl(0, "MyGrepSession", { link = "Comment", default = true })

  local function push(tag, val)
    if history_utils.is_valid_query(val) and not seen[val] then
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

      local width = vim.fn.strdisplaywidth(symbol)

      table.insert(entries, {
        tag = tag,
        value = val,
        ordinal = val,
        display = symbol .. val,
        display_highlights = {
          { 0, width, hl }
        },
      })
    end
  end

  for _, v in ipairs(tool_state.favorites) do push("favorite", v) end
  for _, v in ipairs(tool_state.persist) do push("persist", v) end
  for _, v in ipairs(tool_state.history) do push("session", v) end

  if vim.tbl_isempty(entries) then
    table.insert(entries, {
      value = "",
      ordinal = "empty",
      display = "[mygrep] No saved search queries",
      display_highlights = {
        { 0, 35, "Comment" }
      }
    })
  end

  pickers.new({}, {
    prompt_title = title .. " History",
    finder = finders.new_table {
      results = entries,
      entry_maker = function(entry)
        return {
          tag = entry.tag,
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
        history.remove(tool_state, sel.value)
        history.save(tool, tool_state)
        M.open_history_picker(tool, title, callback, tool_state, last_prompt)
      end)

      map("i", "<Tab>", function()
        local sel = action_state.get_selected_entry()
        if not sel or not sel.value then return end

        -- Confirmation for persistent deletion
        local is_persistent = vim.tbl_contains(tool_state.persist or {}, sel.value)
        if is_persistent then
          vim.ui.input({ prompt = "[mygrep] Remove persistent query from file? [y/n]: " }, function(answer)
            if answer == "y" then
              history.toggle_state(tool_state, sel.value)
              history.save(tool, tool_state)
              M.open_history_picker(tool, title, callback, tool_state, last_prompt)
            end
          end)
          return
        end

        history.toggle_state(tool_state, sel.value)
        history.save(tool, tool_state)
        M.open_history_picker(tool, title, callback, tool_state, last_prompt)
      end)

      map("i", "<S-Tab>", function()
        local sel = action_state.get_selected_entry()
        if not sel or not sel.value then return end

        history.toggle_state_reverse(tool_state, sel.value)
        history.save(tool, tool_state)
        M.open_history_picker(tool, title, callback, tool_state, last_prompt)
      end)

      map("i", "<C-Up>", function()
        local sel = action_state.get_selected_entry()
        if not sel or not sel.value or not sel.tag then return end
        local list = tool_state[sel.tag]
        local idx = tbl_indexof(list, sel.value)
        if idx and idx > 1 then
          list[idx], list[idx - 1] = list[idx - 1], list[idx]
          if sel.tag == "persist" then
            history.save(tool, tool_state)
          end
          M.open_history_picker(tool, title, callback, tool_state, last_prompt)
        end
      end)

      map("i", "<C-Down>", function()
        local sel = action_state.get_selected_entry()
        if not sel or not sel.value or not sel.tag then return end
        local list = tool_state[sel.tag]
        local idx = tbl_indexof(list, sel.value)
        if idx and idx < #list then
          list[idx], list[idx + 1] = list[idx + 1], list[idx]
          if sel.tag == "persist" then
            history.save(tool, tool_state)
          end
          M.open_history_picker(tool, title, callback, tool_state, last_prompt)
        end
      end)

      map("i", "<Esc>", function()
        actions.close(bufnr)
        vim.defer_fn(function()
          M.open(tool, title, callback, tool_state, { default_text = last_prompt or "" })
        end, 10)
      end)

      return true
    end
  }):find()
end

return M
