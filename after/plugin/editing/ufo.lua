require("ufo").setup({
  fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
    local new_virt_text = {}
    local suffix = " ⋯ "
    local count_str = " " .. (end_lnum - lnum) .. " lines"
    local target_width = width - vim.fn.strdisplaywidth(suffix) - vim.fn.strdisplaywidth(count_str)
    local cur_width = 0
    for _, chunk in ipairs(virt_text) do
      local text = chunk[1]
      local chunk_width = vim.fn.strdisplaywidth(text)
      if target_width > cur_width + chunk_width then
        table.insert(new_virt_text, chunk)
      else
        text = truncate(text, target_width - cur_width)
        table.insert(new_virt_text, { text, chunk[2] })
        if cur_width + vim.fn.strdisplaywidth(text) < target_width then
          suffix = suffix .. (" "):rep(target_width - cur_width - vim.fn.strdisplaywidth(text))
        end
        break
      end
      cur_width = cur_width + chunk_width
    end
    table.insert(new_virt_text, { suffix, "UfoFoldedEllipsis" })
    table.insert(new_virt_text, { count_str, "Comment" })
    return new_virt_text
  end,
  provider_selector = function()
    return { "treesitter", "indent" }
  end,
})


-- Override za/zR/zM to work with ufo
vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
-- Peek inside a fold without opening it
vim.keymap.set("n", "zp", require("ufo").peekFoldedLinesUnderCursor, { desc = "Peek fold" })
