-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("n", "<C-w>z", ":SimpleZoomToggle<CR>")

-- Terminal
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])

-- Oil
vim.keymap.set("n", "<leader>o", ":Oil<CR>")

-- Diffview
vim.keymap.set("n", "<leader>df", ":DiffviewOpen<CR>")

-- paste without replacing register
vim.keymap.set("x", "<leader>p", [["_dP]])
