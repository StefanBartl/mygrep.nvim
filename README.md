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
- 🧩 Add your own tools via plugin API
- 🧼 Refined UX: `<C-n>`, `<C-p>`, `<C-o>`, `<Tab>`, `<C-d>`, `<Esc>`

---

## Installation (lazy.nvim)

```lua
{
  "StefanBartl/reposcope.nvim",
  config = function()
    require("mygrep")
  end,
}
````

---

## Default Keymaps

| Mapping      | Description               |
| ------------ | ------------------------- |
| `<leader>lg` | Run live\_grep            |
| `<leader>fg` | Run multigrep             |
| `<leader>gr` | Tool selector (`:Mygrep`) |

All picker-specific mappings are injected dynamically.
See `:h mygrep` for full list.

---

## Usage

```vim
:Mygrep live_grep     " Run directly
:Mygrep               " Open tool chooser
```

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

## Persistent Storage

Session queries are stored in memory.
Persistent favorites are saved to:

```
~/.local/share/nvim/mygrep/<tool>.json
```

---

## Built-in Tools

* `live_grep`: telescope.builtin.live\_grep
* `multigrep`: your own multi-path version

You can disable any, or register your own.

---

## Help

```
:help mygrep
```

---

## Status

This is a **v0.1 beta**. API is stable, but some edge cases still in testing.

---

## License

MIT — © 2025 [LICENSE](./LICENSE)

---