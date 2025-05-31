---@module 'mygrep.context.search_root'
---@brief Manages the current search root (cwd, root, custom, home)

local M = {}

---@class SearchRootState
---@field mode 'cwd' | 'root' | 'custom' | 'home'
---@field custom_path? string
---@field project_dir? string

---@type SearchRootState
local state = {
  mode = "cwd",
  custom_path = nil,
  project_dir = vim.fn.getcwd(), -- assume initial working dir is project
}

---Returns current effective path
---@return string
function M.get()
  return vim.fn.getcwd()
end

---Returns current root mode
---@return SearchRootState["mode"]
function M.mode()
  return state.mode
end

---Ensures initial project directory is captured (once)
local function remember_project_dir()
  if not state.project_dir or state.project_dir == "" then
    local buf_path = vim.api.nvim_buf_get_name(0)
    if buf_path ~= "" then
      local dir = vim.fn.fnamemodify(buf_path, ":p:h")
      if vim.fn.isdirectory(dir) == 1 then
        state.project_dir = dir
        return
      end
    end
    state.project_dir = vim.fn.getcwd()
  end
end

---Normalizes a user path input (expands ~ etc.)
---@param path string
---@return string normalized, or empty string if invalid
local function normalize_path(path)
  local resolved = vim.fn.expand(path)
  if vim.fn.isdirectory(resolved) == 1 then
    return resolved
  end
  return ""
end

---Changes the working directory safely
---@param path string
---@param mode SearchRootState["mode"]
local function change_dir(path, mode)
  local ok, err = pcall(vim.fn.chdir, path)
  if not ok then
    vim.notify("[mygrep] Failed to change directory: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  state.mode = mode
  state.custom_path = (mode == "custom") and path or nil
  vim.notify("[mygrep] Search root changed to: " .. path, vim.log.levels.INFO)
end

---Prompts user to select the new root mode
function M.select()
  remember_project_dir()

  local cwd = vim.fn.getcwd()
  local opts = {}
  local current_mode = state.mode

  local function label_with_check(icon, label, mode)
    local check = (current_mode == mode) and " " or ""
    return icon .. "  " .. label .. check
  end

  -- Add option: switch to project directory (cwd)
  table.insert(opts, {
    label = label_with_check("", "Switch to project directory (" .. state.project_dir .. ")", "cwd"),
    action = function()
      change_dir(state.project_dir, "cwd")
    end,
  })

  -- Add option: switch to home
  table.insert(opts, {
    label = label_with_check("󰋞", "Switch to home directory (~)", "home"),
    action = function()
      local home = vim.fn.expand("~")
      change_dir(home, "home")
    end,
  })

  -- Add option: switch to root
  table.insert(opts, {
    label = label_with_check("󰜉", "Switch to filesystem root (/)", "root"),
    action = function()
      change_dir("/", "root")
    end,
  })

  -- Always allow entering a new custom path
  table.insert(opts, {
    label = "  Enter custom path...",
    action = function()
      vim.ui.input({ prompt = "Enter directory:" }, function(input)
        if not input then return end
        local path = normalize_path(input)
        if path ~= "" then
          change_dir(path, "custom")
        else
          vim.notify("[mygrep] Invalid directory: " .. input, vim.log.levels.WARN)
        end
      end)
    end,
  })

  vim.ui.select(opts, {
    prompt = "[mygrep] Current root: " .. cwd,
    format_item = function(item) return item.label end,
  }, function(choice)
    if choice and choice.action then choice.action() end
  end)
end

return M
