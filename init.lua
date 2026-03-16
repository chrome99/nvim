-- Ensure homebrew binaries are available (macOS GUI launch doesn't inherit full PATH)
vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH

-- Shim deprecated API used by plugins (telescope, project.nvim)
vim.lsp.buf_get_clients = vim.lsp.get_clients

require("core.options")
require("core.keymaps")
require("core.functions")
require("core.term")
require("core.todo")
require("plugins.packer")
