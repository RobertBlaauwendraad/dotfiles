-- fnm injects node into PATH only inside a shell that ran `fnm env`. Launched
-- outside one, nvim can't find `node`, so node-based LSP servers (ts_ls) spawn
-- and exit 127. Append fnm's stable default-node bin as a fallback — appended,
-- so a project's `fnm use` node already on PATH still takes precedence.
local fnm_bin = vim.fn.fnamemodify(vim.fn.stdpath("data"), ":h") .. "/fnm/aliases/default/bin"
if vim.uv.fs_stat(fnm_bin) then
  vim.env.PATH = vim.env.PATH .. ":" .. fnm_bin
end

require("options")
require("keymaps")
require("plugins")
