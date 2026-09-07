-- PyInstaller .spec files are Python; nvim's default mapping for *.spec is RPM.
-- Decided per file so real RPM specs keep their own filetype.
vim.filetype.add({
  pattern = {
    [".*%.spec"] = function(_, bufnr)
      local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
      if first:find("mode: python", 1, true) then
        return "python"
      end
    end,
  },
})
