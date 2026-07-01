vim.g.mapleader = " "

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Exit insert without leaving home row
map("i", "jk", "<Esc>", "Exit insert mode")

-- Kill arrow keys to build hjkl muscle memory
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  map({ "n", "i" }, key, "<NOP>", "Disabled arrow key")
end

-- Ctrl-hjkl (split/pane focus) is handled by zellij-nav.nvim, which navigates
-- nvim splits and crosses into zellij panes at the edge. See plugins/editor.lua.

-- Windows (+window)
map("n", "<leader>wv", "<C-w>v", "Split right")
map("n", "<leader>ws", "<C-w>s", "Split below")
map("n", "<leader>wd", "<C-w>c", "Close window")
map("n", "<leader>wo", "<C-w>o", "Close other windows")

-- Buffers (+buffer)
map("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")

-- Diagnostics navigation
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,  "Next diagnostic")
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")

-- Keep selection when indenting in visual mode
map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")

-- Keep cursor centred while scrolling / searching
map("n", "<C-d>", "<C-d>zz", "Half page down (centred)")
map("n", "<C-u>", "<C-u>zz", "Half page up (centred)")
map("n", "n", "nzzzv", "Next search result (centred)")
map("n", "N", "Nzzzv", "Prev search result (centred)")

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")
