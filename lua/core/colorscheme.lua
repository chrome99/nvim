-- Setup Catppuccin
require("catppuccin").setup({
  flavour = "macchiato",
  transparent_background = false,
  custom_highlights = function(colors)
    local blend = require("catppuccin.utils.colors").blend
    -- Subtle per-level heading bars: accent tinted ~13% into base.
    -- Fg groups color the icon/sign; heading text stays treesitter @markup.heading.
    local accents = {
      colors.red,
      colors.peach,
      colors.yellow,
      colors.green,
      colors.sky,
      colors.mauve,
    }
    local hl = {
      Folded = { fg = colors.overlay1, bg = "NONE", style = { "italic" } },
    }
    for i, accent in ipairs(accents) do
      hl["RenderMarkdownH" .. i] = { fg = accent, bold = true }
      hl["RenderMarkdownH" .. i .. "Bg"] = {
        bg = blend(accent, colors.base, 0.13),
      }
    end
    return hl
  end,
})

vim.cmd.colorscheme("catppuccin")
