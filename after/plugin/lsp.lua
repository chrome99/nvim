-- Ensure lspconfig.util is available
local util = require("lspconfig.util")

local function setup_lsp()
	-- LSP Attach Autocommand
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
		callback = function(event)
			local map = function(keys, func, desc, mode)
				mode = mode or "n"
				vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
			end

			map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
			map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
			map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
			map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
			map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
			map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
			map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
			map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
				local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.document_highlight,
				})
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.clear_references,
				})
			end

			if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
				map("<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[T]oggle Inlay [H]ints")
			end
		end,
	})

	-- Capabilities
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	if cmp_ok then
		capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
	end

	-- LSP server configs (lspconfig names)
	local servers = {
		vtsls = {
			root_dir = util.root_pattern("tsconfig.json", "package.json", ".git"),
			settings = {
				typescript = {
					inlayHints = {
						parameterNames = { enabled = "all" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = true },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
				vtsls = {
					autoUseWorkspaceTsdk = true,
				},
			},
		},
		ruff = {},
		pylsp = {
			settings = {
				pylsp = {
					plugins = {
						pyflakes = { enabled = false },
						pycodestyle = { enabled = false },
						autopep8 = { enabled = false },
						yapf = { enabled = false },
						mccabe = { enabled = false },
						pylsp_mypy = { enabled = false },
						pylsp_black = { enabled = false },
						pylsp_isort = { enabled = false },
					},
				},
			},
		},
		html = { filetypes = { "html", "twig", "hbs" } },
		cssls = {},
		remark_ls = {},
		jsonls = {},
		yamlls = {},
		gopls = {},
		bashls = {},
		tailwindcss = {},
		dockerls = {},
		sqlls = {},
		terraformls = {},
		svelte = {},
		lua_ls = {
			settings = {
				Lua = {
					completion = { callSnippet = "Replace" },
					runtime = { version = "LuaJIT" },
					workspace = {
						checkThirdParty = false,
						library = {
							"${3rd}/luv/library",
							unpack(vim.api.nvim_get_runtime_file("", true)),
						},
					},
					diagnostics = {
						disable = { "missing-fields" },
					},
					format = { enable = false },
				},
			},
		},
	}

	-- Correct Mason package names
	local mason_lsp_names = {
		vtsls = "vtsls",
		ruff = "ruff-lsp",
		pylsp = "python-lsp-server",
		html = "html-lsp",
		cssls = "css-lsp",
		remark_ls = "remark-language-server",
		jsonls = "json-lsp",
		yamlls = "yaml-language-server",
		gopls = "gopls",
		bashls = "bash-language-server",
		tailwindcss = "tailwindcss-language-server",
		dockerls = "dockerfile-language-server",
		sqlls = "sqls",
		terraformls = "terraform-ls",
		svelte = "svelte-language-server",
		lua_ls = "lua-language-server",
	}

	local ensure_installed = vim.tbl_values(mason_lsp_names)
	vim.list_extend(ensure_installed, { "stylua" }) -- formatters, etc.

	-- Setup Mason
	local mason_ok, mason = pcall(require, "mason")
	if not mason_ok then
		vim.notify("Mason not found!", vim.log.levels.ERROR)
		return
	end
	mason.setup()

	-- Setup Mason Tool Installer
	local mti_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
	if not mti_ok then
		vim.notify("Mason Tool Installer not found!", vim.log.levels.ERROR)
		return
	end
	mason_tool_installer.setup({
		ensure_installed = ensure_installed,
	})

	-- Setup Mason LSPConfig
	local mlc_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
	if not mlc_ok then
		vim.notify("Mason LSPConfig not found!", vim.log.levels.ERROR)
		return
	end
	mason_lspconfig.setup({
		handlers = {
			function(server_name)
				local server_opts = servers[server_name] or {}
				-- Ensure capabilities are merged correctly
				server_opts.capabilities =
					vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
				require("lspconfig")[server_name].setup(server_opts)
			end,
		},
	})
end

setup_lsp()
