require("chafa").setup({
	render = {
		min_padding = 5,
		show_label = true,
	},
	events = {
		update_on_nvim_resize = true,
		on_filetype = {
			enabled = true,
			filetypes = { "png", "jpg", "jpeg", "gif", "svg", "webp" },
		},
	},
})
