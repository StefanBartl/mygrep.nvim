---@module 'myterm.@types.entry'
---@brief Entry types for command memory
---@description
--- Tags and storage types used for history/favorites/persist entries.

---@alias Query string
---@alias EntryTag "favorite" | "persist" | "session"

---@alias HistoryStorage Query[]
---@alias FavoritesStorage Query[]
---@alias PersistsStorage Query[]
---@alias Storage HistoryStorage | FavoritesStorage | PersistsStorage
