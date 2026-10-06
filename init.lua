-- Ensure homebrew binaries are available (macOS GUI launch doesn't inherit full PATH)
vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH

-- Shim deprecated API used by plugins (telescope, project.nvim)
vim.lsp.buf_get_clients = vim.lsp.get_clients

-- Shim vim.tbl_flatten (deprecated in 0.12, still used by many plugins)
vim.tbl_flatten = function(t) return vim.iter(t):flatten(math.huge):totable() end

-- Workaround for async treesitter parse race in Neovim 0.11+: nodes from a
-- previous parse cycle can be garbage-collected mid-coroutine, causing
-- node:range() to appear nil in the decoration provider.
vim.g._ts_force_sync_parsing = true

require("features.clipboard.provider").setup()
require("config.options")
require("config.filetypes")
require("config.keymaps")
require("config.commands")
require("features.terminal")
require("features.clipboard.primary").setup()
require("features.todo")
require("features.linear")
require("features.herdr")
require("plugins")
require("config.colorscheme")
