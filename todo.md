# mygrep.nvim

> Extendable memory-enhanced search layer for Telescope-powered grep tools in Neovim.

**mygrep** adds a persistent, session-aware memory system to any Telescope-based grep tool.
It remembers your search history, lets you mark favorites, supports undo for accidental deletions, and provides interactive, tool-specific pickers with consistent UX.

## Features

- 🧠 **Session memory** for all registered grep tools (`live_grep`, `multigrep`, ...).
  - öffnet man tein tool, kann man mit C-n bzw C-p durch die letzten einträge der hjistrory gehen (werden sofort in das tool als query eingesetzt)
  - mit <C-o> kann man einen weiters selecter fenster öffnen, dass die history anzeigt
- history, favorites tool (`live_grep`, `multigrep`, ...)
- 📌 **Favorites** with toggle support (`<Tab>`) and view at the top in history
- 🗑️ **History Entry deletion** (`<C-d>`)
- 💾 Persistent storage in `stdpath("cache")/mygrep/`:
  - Ein zweites mal <Tab> schiebt den query vom session memory in den persistent memory (per tool)
- Ein drittes mal <Tab> am selben query löscht den query wieder aus persistnent und session memory
- ✅ Safe, testable, documented & LSP-ready codebase
- 🔁 Modular architecture — register new tools with a single Lua file
  - Struktur:
```bash
mygrepy/
├── init.lua              ← Entry point + tool registration
├── README.md
├── doc/
│   ├── mygrep.txt        ← `:h`Hilfeseite
├── usercommands.lua
├── keymaps.lua
├── init.lua              ← Entry point + tool registration
├── @types/
│   ├── aliases.lua
├── tools/
    ├── live_grep.lua     ← Uses `builtin.live_grep` aber upgradet!
    ├── multigrep.lua     ← Pattern + glob matching (via `rg`) ? Lass uns noch darüber sprechen, was das genau bedeuten würde


Zwischen core und utils brauchen wir eine Strategie, da siech die beiden sehr überschneiden. Las uns darüber noch sprechen"
├── utils/
├── core/
In etwas diese Files (sicherlcih noch viele mehr)
===============================================================
│   ├── picker.lua        ← Generic UI + keymaps
│   ├── history.lua       ← Tool-specific history/favorites
│   ├── undo.lua          ← Session undo stack
│   ├── registry.lua      ← Tool registration & lookup
│   └── preview.lua       ← Live result count preview
│   └── navigation.lua    ← opens match (vimgrep.entry ??)
===============================================================
```


- Das Projekt soll als eigenständiges Plugin aufgebaut sein,d ass so in die plufgininit.lua (Beispiel `lazy` Paketmanager) eingebunden wird:
```bash
{
  "mygrep.local",
  dir = vim.fn.stdpath("config") .. "/lua/custom/mygrep",
  lazy = false,
  config = function()
    require("custom.mygrep")
  end,
},
```

Dieses Beispiel ist für mich beim entwickeln, wenn es dann veröfentlich isst, eher so:

```bash
{
  "StefanBartl/mygrep.nvim",
  lazy = false,
  config = function()
    require("custom.mygrep")
  end,
},
```

## In the future
- 🔍 **Result preview** of potential matches (`<C-h>`) via `rg --count`: Wenn man in der history C-c eingibt, dann bekommt man die countzahl ausgegeben, die eine auswahl des querys aus der history im picker aktuell treffen wr
- **undo** (`<C-z>`) stack per tool (`live_grep`, `multigrep`, ...) (Möglcherweiesße bei entwickeln bereits mitbedenken): innerhalb der ersten 5 Sekunden kann man ein delete aus der history rückgängig machen

---

Default keybindings:

| Mode | Mapping          | Description                                                                               |
| ---- | ---------------- | ----------------------------------------------------------------------------------------- |
| `n`  | `<leader>gr`     | Launch kleines Auswahlmen, bei dem zwischen den Tools wählen kann, die registriert sind   |
| `n`  | `<leader>lg`     | Launch `live_grep` memory picker                                                          |
| `n`  | `<C-n>`          | Next entry in session memory (only in tool picker, not in history picker)                 |
| `n`  | `<C-p>`          | Previous entry in session memory (only in tool picker, not in history picker)             |
| `n`  | `<C-o-`          | Open History picker, Session history first, persisten stored after                        |
| `n`  | `<Tab> (x2, x3)` | Mark query for session history, than for persistent storage, than fpor removing from both |
| `n`  | `<C-d>`          | only in History picker: delete query from sesion and persistent                           |

(später wenn schwierig einzubinden)
| Mode | Mapping | Description                                                 |
| ---- | ------- | ----------------------------------------------------------- |
| `n`  | `<C-h>` | Only in history picker, show count if query woud be applied |
| `n`  | `<C-z>` | 10 S. Undo                                                  |

---

## Tool Examples

### Register your own grep tool:

```lua
  local state = require("...history").load("somegrep")
  require("...picker").open("somegrep", "somegrep", function(input)
    -- your custom search implementation
  end, state)
```

### Add to registry:

```lua
-- in init.lua or plugin setup
local registry = require("custom.mygrep.core.registry")
registry.register("somegrep", require("custom.mygrep.tools.somegrep"))
```
