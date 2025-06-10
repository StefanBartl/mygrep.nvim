---@module 'myterm.@types.search_root'
---@brief Types related to directory root selection
---@description
--- Used for representing user-selected root modes and paths.

---@alias SearchRootMode 'cwd' | 'root' | 'custom' | 'home'

---@class SearchRootState
---@field mode SearchRootMode
---@field custom_path? string
---@field project_dir? string
