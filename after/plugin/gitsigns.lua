require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local map = function(mode, l, r, desc)
			vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
		end

		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, "Next hunk")

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, "Prev hunk")

		map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk (inline, 1 pane)")
	end,
	signs = {
		add          = { text = "▋" },
		change       = { text = "▋" },
		delete       = { text = "▋" },
		topdelete    = { text = "▋" },
		changedelete = { text = "▋" },
		untracked    = { text = "▋" },
	},
	signs_staged = {
		add          = { text = "▋" },
		change       = { text = "▋" },
		delete       = { text = "▋" },
		topdelete    = { text = "▋" },
		changedelete = { text = "▋" },
	},
})
