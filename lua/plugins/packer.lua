-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

-- Support Colors
vim.opt.termguicolors = true

return require("packer").startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")

  -- CMP (Completion)
  use({
    "hrsh7th/nvim-cmp",
    requires = {
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        requires = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
  })

  -- Needed for LSP
  use({
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  })

  -- Main LSP Configuration
  use({
    "neovim/nvim-lspconfig",
    requires = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
    },
  })

  -- Auto Format
  use({
    "nvimtools/none-ls.nvim",
    requires = {
      "nvimtools/none-ls-extras.nvim",
      "jayp0521/mason-null-ls.nvim",
    },
  })

  -- Git Signs
  use({
    "lewis6991/gitsigns.nvim",
    opts = true,
  })

  -- Comment
  use({
    "numToStr/Comment.nvim",
    opts = {},
  })

  -- Keybind hints
  use({ "folke/which-key.nvim" })

  -- Auto-pairs (e.g. brackets, quotes)
  use({
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  })

  -- Color highlighter
  use({
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  })

  -- ASCII Images
  use({
    "princejoogie/chafa.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "m00qek/baleia.nvim",
    },
  })

  -- Animations
  use({ "echasnovski/mini.animate" })

  use({
    "echasnovski/mini.indentscope",
    config = function()
      require("mini.indentscope").setup()
    end,
  })

  -- Notifications
  use({
    "echasnovski/mini.notify",
    config = function()
      require("mini.notify").setup()
    end,
  })

  -- Telescope
  use({
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    requires = { "nvim-lua/plenary.nvim" },
  })

  -- Catppuccin Theme
  use({ "catppuccin/nvim", as = "catppuccin" })

  -- Icons
  use({ "nvim-tree/nvim-web-devicons" })

  -- Neo-tree
  use({
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",
    },
  })

  -- Alpha Dashboard
  use({ "goolord/alpha-nvim" })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
  })

  -- MDX Treesitter
  use({
    "davidmh/mdx.nvim",
    requires = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("mdx").setup()
    end,
  })

  -- Lualine
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons", opt = true },
  })

  -- Markdown Rendering
  use({ "MeanderingProgrammer/render-markdown.nvim" })

  -- Share Buffers with Cursor
  use({ "vim-denops/denops.vim" })
  use({ "kbwo/vim-shareedit" })

  -- Buffer line
  use({
    "akinsho/bufferline.nvim",
    requires = {
      "moll/vim-bbye",
      "nvim-tree/nvim-web-devicons",
    },
  })

  -- Fugitive
  use("tpope/vim-fugitive")

  -- Project & Session Management
  use("ahmedkhalf/project.nvim")
  use("rmagatti/auto-session")
end)
