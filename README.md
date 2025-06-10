    __  __        _____                
   |  \/  |      / ____|               
   | \  / |_   _| |  __ _ __ ___ _ __  
   | |\/| | | | | | |_ | '__/ _ \ '_ \ 
   | |  | | |_| | |__| | | |  __/ |_) |
   |_|  |_|\__, |\_____|_|  \___| .__/ 
            __/ |               | |    
           |___/                |_|    

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
* `<S-Tab>` cycles states in reverse (persistent → favorite → session)
* `<C-d>` deletes the selected query
* `<Esc>` returns to previous prompt (from history picker)
* `<C-n>`, `<C-p>` rotate through previous queries
* `<C-Up>` Move query up within its section
* `<C-Down>` Move query down within its section

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

## Root Directory Switching

`mygrep.nvim` lets you dynamically change the working directory used by Neovim and all registered grep tools.

This allows you to **search in different scopes** — project, home, system root, or a custom directory — without restarting or reconfiguring anything.

### Available options

* `` **Project directory** (default)
* `󰋞` **Home directory** (`~`)
* `󰜉` **Filesystem root** (`/`)
* `` **Custom path** (user-defined)

### How to use

You can trigger the root selector from anywhere using:

```lua
:lua require("mygrep.context.search_root").select()
```

By default, it’s bound inside pickers to:

```lua
vim.keymap.set("n", "<F5>", function()
  require("mygrep.context.search_root").select()
end, { desc = "Change mygrep root directory" })
```

While using a picker, simply press `<F5>` to choose a new root directory.
Your selection will immediately take effect for all subsequent queries.

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

* **`live_grep`**: uses native `telescope.builtin.live_grep`
  → full-text search with fuzzy matching

* **`multigrep`**: search against filenames and glob patterns using multiple fields (`pattern *.lua`)
  → powered by `rg`, supports `-e` and `-g` arguments dynamically

* **`multigrep_file`**: like `multigrep`, but scoped to the currently open file
  → pre-fills the filename as `-g <filename>` and sets the cursor before it

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
