vim.g.mapleader = " "

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

map("i", "jk", "<Esc>", "Exit insert mode")

for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  map({ "n", "i" }, key, "<NOP>", "Disabled arrow key")
end

map("n", "<A-h>", "<C-w>h", "Move to left pane")
map("n", "<A-l>", "<C-w>l", "Move to right pane")
map("n", "<A-k>", "<C-w>k", "Move to upper pane")
map("n", "<A-j>", "<C-w>j", "Move to lower pane")

map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")

map("n", "<leader>wv", "<C-w>v", "Split vertically")
map("n", "<leader>wh", "<C-w>s", "Split horizontally")
map("n", "<leader>wu", "<C-w>o", "Close other panes")

map("n", "<Esc>", ":nohlsearch<CR>", "Clear search highlight")
map("n", "<leader>q", ":bd<CR>", "Close buffer")
