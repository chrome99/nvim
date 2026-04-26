<div align="center">
  <img src="https://github.com/user-attachments/assets/f06ce405-b865-4a2b-bc16-bfd478a1982c" alt="Okapi Logo" width="500" />
  <h1>Neovim Config</h1>
</div>

Personal Neovim config written in Lua.

## Stack

- **Plugin manager**: packer.nvim
- **Theme**: Catppuccin Macchiato
- **LSP**: Mason + nvim-lspconfig
- **Completion**: nvim-cmp + LuaSnip
- **Fuzzy find**: Telescope + FZF native
- **Syntax**: Treesitter
- **File tree**: neo-tree
- **Git**: Fugitive + gitsigns + delta integration

## Custom Features

#### [Git Log](lua/core/git-log.lua) — `<leader>gl`

Custom floating git log viewer. Shows commits with branch refs, subject, and relative timestamps — each field color-coded. Press `<CR>` on any commit to open a second floating window with the full `git show` diff (syntax highlighted). `yh` yanks the commit hash, `ym` yanks the commit message — both flash the line briefly as confirmation. `q` / `<Esc>` to close either window.

#### [Todo Manager](lua/core/todo.lua) — `<Space>td`

Persistent floating markdown checklist, stored in Neovim's state directory. `<CR>` toggles a checkbox; visual-select multiple lines and `<CR>` toggles them all. `gf` / `gF` jump to file references in the list (supports `path:line:col` format). Backs up automatically once per day with 30-day retention — `R` opens a picker to restore from any backup. A lock file prevents two Neovim instances from editing it at the same time.

## Notable Features

- **Floating terminal** — `<Space>tt` to toggle a centered terminal overlay
- **DB client** — vim-dadbod for running SQL queries against local databases, with auto-open for `.db`/`.sqlite` files and in-editor completion
- **Yank history** — yanky.nvim keeps a ring of previous yanks, browsable via Telescope (`<leader>sy`)
- **Code outline** — aerial.nvim symbol tree in a sidebar (`<leader>a`), navigate symbols with `[a` / `]a`
- **Diagnostics UI** — Trouble.nvim for a structured view of workspace errors, quickfix, and references (`<leader>xx`)
- **Markdown** — render-markdown.nvim renders headers/checkboxes/tables in the buffer; markdown-preview.nvim for live browser preview
- **Command line** — wilder.nvim adds fuzzy completion and a popup menu to `:` commands
