local ok, aider = pcall(require, "nvim_aider")
if ok then
  aider.setup({
    aider_cmd = "aider",
    args = {
      "--no-auto-commits",
      "--pretty",
      "--stream",
    },
    auto_reload = false,
    theme = {
      user_input_color = "#a6da95",
      tool_output_color = "#8aadf4",
      tool_error_color = "#ed8796",
      tool_warning_color = "#eed49f",
      assistant_output_color = "#c6a0f6",
      completion_menu_color = "#cad3f5",
      completion_menu_bg_color = "#24273a",
      completion_menu_current_color = "#181926",
      completion_menu_current_bg_color = "#f4dbd6",
    },
    picker_cfg = {
      preset = "vscode",
    },
    config = {
      os = { editPreset = "nvim-remote" },
      gui = { nerdFontsVersion = "3" },
    },
    win = {
      wo = { winbar = "Aider" },
      style = "nvim_aider",
      position = "right",
    },
  })
end

vim.keymap.set("n", "<leader>at", "<cmd>Aider toggle<cr>", { desc = "Toggle Aider" })
vim.keymap.set("n", "<leader>as", "<cmd>Aider send<cr>", { desc = "Send to Aider" })
vim.keymap.set("n", "<leader>ac", "<cmd>Aider command<cr>", { desc = "Aider Commands" })
vim.keymap.set("n", "<leader>ab", "<cmd>Aider buffer<cr>", { desc = "Send Buffer" })
vim.keymap.set("n", "<leader>a+", "<cmd>Aider add<cr>", { desc = "Add File" })
vim.keymap.set("n", "<leader>a-", "<cmd>Aider drop<cr>", { desc = "Drop File" })
vim.keymap.set("n", "<leader>ar", "<cmd>Aider add readonly<cr>", { desc = "Add Read-Only" })
vim.keymap.set("n", "<leader>aR", "<cmd>Aider reset<cr>", { desc = "Reset Session" })

-- Reload file if changed by other programs (such as Aider)
vim.o.autoread = true
