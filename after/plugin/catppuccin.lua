-- Setup Catppuccin
require("catppuccin").setup({
    flavour = "macchiato",
    transparent_background = false
})

vim.cmd.colorscheme "catppuccin"

-- Toggle background transparency
local bg_transparent = false

local toggle_transparency = function()
    bg_transparent = not bg_transparent
    require("catppuccin").setup({
        flavour = "macchiato",
        transparent_background = bg_transparent
    })
    -- Reapply the colorscheme to reflect the change
    vim.cmd.colorscheme "catppuccin"
end

vim.keymap.set('n', '<leader>bg', toggle_transparency, { noremap = true, silent = true })

