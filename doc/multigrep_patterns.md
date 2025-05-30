# MultiGrep Query Guide

The `multigrep` tool in `mygrep.nvim` allows you to combine standard text pattern searches with optional file globs using `ripgrep` (`rg`). This lets you restrict searches to specific files, extensions, or folder structures.

## Basic Syntax

```

\<search\_pattern>  \<file\_glob>

```

**Important**: The pattern and glob must be separated by *two spaces* (`␣␣`), not one.

## Examples

| Input                            | Meaning                                                                |
| -------------------------------- | ---------------------------------------------------------------------- |
| `TODO`                           | Search for "TODO" in all files                                         |
| `TODO` ␣␣ `*.lua`                | Search "TODO" in `.lua` files only                                     |
| `init` ␣␣ `init*.lua`            | Search for "init" in any file matching `init*.lua`                     |
| `error` ␣␣ `**/*.ts`             | Search for "error" in all `.ts` files recursively                      |
| `function` ␣␣ `plugins/**/*.lua` | Look for "function" in `plugins/` folder (and subfolders), `.lua` only |
| `config` ␣␣ `*/config.*`         | Search for "config" in top-level files with names like `config.js`     |
| `main` ␣␣ `*.{js,ts}`            | Search for "main" in `.js` and `.ts` files                             |
| `foo bar` ␣␣ `**/*.md`           | Search for "foo bar" (as a phrase) in Markdown files                   |

## Notes

- Globs follow ripgrep syntax (`rg -g`): https://github.com/BurntSushi/ripgrep
- Do not include quotes or escape characters.
- File globs are optional. You can just enter a plain query.
- To match multiple filetypes, use `{}` syntax: `*.{js,ts}`

## Advanced

Want to make these searches persistent?

- Use `<C-o>` inside a picker to access the history
- Use `<Tab>` to toggle states:
  - `S` → `` → `` → removed
- Queries marked `` are saved to disk across sessions

## Example Use Cases

- Narrowing to config files:
  `timeout`  ␣␣  `config/**.lua`

- Searching for CSS classes:
  `.btn-primary`  ␣␣  `**/*.css`

- Grepping documentation only:
  `API`  ␣␣  `docs/**/*.md`

---