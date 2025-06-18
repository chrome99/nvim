-- Project management
require("project_nvim").setup({
	detection_methods = { "lsp", "pattern" },
	patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
	show_hidden = true,
})
require("telescope").load_extension("projects")

-- Session management
require("auto-session").setup({
	log_level = "error",
	auto_session_suppress_dirs = {},
})
