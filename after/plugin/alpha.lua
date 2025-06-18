local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.buttons.val = {
	dashboard.button("Space + S + P", "  Search Projects", ":Telescope projects<CR>"),
	dashboard.button("Space + S + F", "  Search Files", ":Telescope find_files<CR>"),
	dashboard.button("Space + S + G", "󰍉  Search Word", ":Telescope live_grep<CR>"),
	dashboard.button("Space + E", "  Open File Tree", ":NvimTreeToggle<CR>"),
	dashboard.button("Ctrl + S", "  Save File", ":w<CR>"),
	dashboard.button("Ctrl + Q", "󰍉  Exit", ":q<CR>"),
}

alpha.setup(dashboard.opts)
