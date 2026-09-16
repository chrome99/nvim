require("livepreview.config").set({
  port = 5500,
  sync_scroll = true,
  picker = "telescope",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "mdx" },
  callback = function()
    vim.keymap.set("n", "<leader>m", function()
      if require("livepreview").is_running() then
        vim.cmd("LivePreview close")
      else
        vim.cmd("LivePreview start")
      end
    end, { buffer = true, desc = "Toggle markdown preview in browser" })
  end,
})
