-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local utils = require("user.zet")
vim.keymap.set("n", "<leader>z", utils.create_md_file, { desc = "Create markdown zet file" })
vim.keymap.set("n", "<C-w>z", ":SimpleZoomToggle<CR>")

-- Terminal
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
