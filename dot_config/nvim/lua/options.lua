local opt = vim.opt

opt.scrolloff = 10
opt.number = true
opt.relativenumber = true
opt.showmode = false
opt.showcmd = true
opt.ruler = true
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.splitright = true
opt.splitbelow = true
opt.wrap = false
opt.cursorline = true
opt.autoread = true

-- autoread only reloads on some events; poll for external edits (agents editing
-- files, worktree switches) so buffers refresh without a manual :e.
local reload = vim.api.nvim_create_augroup("auto-reload", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
  group = reload,
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd.checktime()
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = reload,
  callback = function()
    vim.notify("File changed on disk — buffer reloaded", vim.log.levels.INFO)
  end,
})
