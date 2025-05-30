#  __  __        _____
# |  \/  |      / ____|
# | \  / |_   _| |  __ _ __ ___ _ __
# | |\/| | | | | | |_ | '__/ _ \ '_ \
# | |  | | |_| | |__| | | |  __/ |_) |
# |_|  |_|\__, |\_____|_|  \___| .__/
#          __/ |               | |
#         |___/                |_|

![version](https://img.shields.io/badge/version-0.1-blue.svg)
![license](https://img.shields.io/github/license/StefanBartl/mygrep.nvim)
![Lazy.nvim compatible](https://img.shields.io/badge/lazy.nvim-supported-success)

> Grep smarter. Memory-powered search for Telescope.

---

## Features

- 🔍 Drop-in wrapper for `live_grep`, `multigrep`, or your custom pickers
- 🧠 Remembers your previous queries in a session
-  Toggle favorites and  mark persistent queries
- 🔁 Reorder queries (⇧/⇩) inside history picker
- 🔄 Navigate query memory via `<C-n>` and `<C-p>`
- ⛅ Choose between floating UI or command-line select
- 🧩 Easily extend with your own tools

---

## Installation (lazy.nvim)

```lua
{
  "StefanBartl/mygrep.nvim",
  config = function()
    require("mygrep").setup()
  end,
}
```

This installs `mygrep.nvim` with the default floating UI tool selector.

If you prefer a minimal **command-line style** selector (`vim.ui.select`), configure it like this:

```lua
require("mygrep").setup({
  tool_picker_style = "select",
})
```

To override default keymaps (e.g. use `<leader>gr` instead of `<leader><leader>`):

```lua
require("mygrep").setup({
  keymaps = {
    open = "<leader>gr",
    live_grep = "<leader>ml",
    multigrep = "<leader>mm",
  },
})
```

---

## Default Keymaps

| Mapping            | Description                           |
| ------------------ | ------------------------------------- |
| `<leader><leader>` | Run live\_grep                        |
| `<leader>ml`       | Run multigrep                         |
| `<leader>mg`       | Tool selector (UI or `vim.ui.select`) |

All picker-specific mappings are injected dynamically.
See `:h mygrep` for full list.

---

## Usage

```vim
:Mygrep live_grep     " Run directly
:Mygrep               " Open tool chooser (based on config)
```

---

## History & Favorites

* `<CR>` confirms a query and adds it to session memory
* `<Tab>` in history picker toggles favorite or persistent mode
* `<C-d>` deletes the selected query
* `<Esc>` returns to previous prompt (from history picker)
* `<C-n>`, `<C-p>` rotate through previous queries

Icons:

| Symbol | Meaning      |
| ------ | ------------ |
| ``   | Favorite     |
| ``   | Persistent   |
| `S`    | Session-only |

---

## Persistent Storage

Persistent queries are saved to:

```
~/.local/share/nvim/mygrep/<tool>.json
```

Session queries exist only during the current Neovim session.

---

## Adding Custom Tools

```lua
local registry = require("mygrep.core.registry")

registry.register("grep_open_files", {
  name = "grep_open_files",
  run = function()
    require("telescope.builtin").grep_string({
      search = "",
      only_cwd = false,
    })
  end,
})
```

---

## Built-in Tools

* `live_grep`: telescope.builtin.live\_grep
* `multigrep`: your own multi-path version

---

## Help

```vim
:help mygrep
```

---

## Status

This is a **v0.1 beta**. Core is stable. Sorting, prompts, and storage APIs under active refinement.

---

## License

MIT — © 2025 [LICENSE](./LICENSE)

---