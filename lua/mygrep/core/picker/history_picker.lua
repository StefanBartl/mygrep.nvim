---@module 'mygrep.core.picker.history_
---@brief Displays the memory-based query history
---@description
--- This picker shows previous queries from session, favorites, and persist layers.
--- It allows toggling entries, reordering, deleting, and switching states.
local M = {}

-- Telescope utils
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
-- History utils
local history = require("mygrep.core.history")
local history_utils = require("mygrep.utils.history_utils")
-- Picker utils
local highlights = require("mygrep.core.picker.highlight")


---@private
---Find index of value in a list
---@param tbl Storage
---@param val Query
local function index_of(tbl, val)
  for i, v in ipairs(tbl) do
    if v == val then return i end
  end
  return nil
end

---Opens the history picker with favorites, persistent, and session entries.
---@param tool ToolName
---@param title string
---@param callback fun(query: string)
---@param tool_state ToolState
---@param last_prompt? string
function M.open(tool, title, callback, tool_state, last_prompt)
  history.load(tool, tool_state)
  highlights.apply_history_highlights()
  local entries, seen = {}, {}

  ---Adds a query to the display list if not already present
  local function push(tag, val)
    if history_utils.is_valid_query(val) and not seen[val] then
      seen[val] = true
      local def = highlights.tag_defs[tag] or { symbol = "  ", hl = "Comment" }
      local width = vim.fn.strdisplaywidth(def.symbol)

      table.insert(entries, {
        tag = tag,
        value = val,
        ordinal = val,
        display = def.symbol .. val,
        display_highlights = { { 0, width, def.hl } },
      })
    end
  end

  for _, v in ipairs(tool_state.favorites) do push("favorite", v) end
  for _, v in ipairs(tool_state.persist)   do push("persist", v) end
  for _, v in ipairs(tool_state.history)   do push("session", v) end

  if #entries == 0 then
    table.insert(entries, {
      value = "",
      ordinal = "empty",
      display = "[mygrep] No saved search queries",
      display_highlights = { { 0, 35, "Comment" } },
    })
  end



  pickers.new({}, {
    prompt_title = title .. " History",
    finder = finders.new_table {
      results = entries,
      entry_maker = function(e) return e end
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
        if sel and sel.value then
          history.remove_from_all(tool_state, sel.value)
          history.save(tool, tool_state)
          M.open(tool, title, callback, tool_state, last_prompt)
        end
      end)

      map("i", "<Tab>", function()
        local sel = action_state.get_selected_entry()
        if sel and sel.value then
          local is_persist = vim.tbl_contains(tool_state.persist or {}, sel.value)
          if is_persist then
            vim.ui.input({ prompt = "[mygrep] Remove persistent query from file? [y/n]: " }, function(ans)
              if ans == "y" then
                history.toggle_state(tool_state, sel.value)
                history.save(tool, tool_state)
                M.open(tool, title, callback, tool_state, last_prompt)
              end
            end)
            return
          end
          history.toggle_state(tool_state, sel.value)
          history.save(tool, tool_state)
          M.open(tool, title, callback, tool_state, last_prompt)
        end
      end)

      map("i", "<S-Tab>", function()
        local sel = action_state.get_selected_entry()
        if sel and sel.value then
          history.toggle_state_reverse(tool_state, sel.value)
          history.save(tool, tool_state)
          M.open(tool, title, callback, tool_state, last_prompt)
        end
      end)

      map("i", "<C-Up>", function()
        local sel = action_state.get_selected_entry()
        if sel and sel.value and sel.tag then
          local list = tool_state[sel.tag]
          local i = index_of(list, sel.value)
          if i and i > 1 then
            list[i], list[i - 1] = list[i - 1], list[i]
            if sel.tag == "persist" then history.save(tool, tool_state) end
            M.open(tool, title, callback, tool_state, last_prompt)
          end
        end
      end)

      map("i", "<C-Down>", function()
        local sel = action_state.get_selected_entry()
        if sel and sel.value and sel.tag then
          local list = tool_state[sel.tag]
          local i = index_of(list, sel.value)
          if i and i < #list then
            list[i], list[i + 1] = list[i + 1], list[i]
            if sel.tag == "persist" then history.save(tool, tool_state) end
            M.open(tool, title, callback, tool_state, last_prompt)
          end
        end
      end)

      map("i", "<Esc>", function()
        actions.close(bufnr)
        vim.defer_fn(function()
          require("mygrep.core.picker").open(tool, title, callback, tool_state, { default_text = last_prompt or "" })
        end, 10)
      end)

      return true
    end,
  }):find()
end

return M

