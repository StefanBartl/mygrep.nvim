---@module 'mygrep.core.picker'
---@brief Unified interface for query pickers
---@description
--- This module provides access to the main query picker and the history picker.
--- Internally, it delegates to specialized modules:
---  - `main_picker` handles the standard live input UI
---  - `history_picker` displays memory entries (favorites, persist, session)

local M = {}

-- Submodules
M.open = require("mygrep.core.picker.main_picker").open
M.open_history_picker = require("mygrep.core.picker.history_picker").open
return M

