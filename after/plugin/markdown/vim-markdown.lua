-- Enable folding for markdown
vim.g.vim_markdown_folding_disabled = 0
vim.g.vim_markdown_folding_level = 6
vim.g.vim_markdown_folding_style_pythonic = 1
vim.g.vim_markdown_no_default_key_mappings = 1
vim.cmd([[set foldlevelstart=6]])

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "GetMarkdownFold()"

    vim.keymap.set("n", "=", "za", { buffer = true, desc = "Toggle fold" })

    -- Toggle between fold all and unfold all
    local folded = false
    vim.keymap.set("n", "-", function()
      if folded then
        vim.cmd("normal! zR")
        folded = false
      else
        vim.cmd("normal! zM")
        folded = true
      end
    end, { buffer = true, desc = "Toggle fold all/unfold all" })
  end,
})
