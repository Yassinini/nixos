-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<F5>", function()
  vim.cmd("w") -- save current buffer

  -- Close any existing terminal splits to prevent clutter
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_win_close(win, true)
    end
  end

  local file = vim.fn.expand("%")
  local output = vim.fn.expand("%:r")

  -- Open a clean terminal split at the bottom
  vim.cmd("botright 15split | terminal g++ -std=c++20 " .. file .. " -o " .. output .. " && " .. output)
  vim.cmd("startinsert")
end, { desc = "Compile & Run C++" })
