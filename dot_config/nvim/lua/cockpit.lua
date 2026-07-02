-- Cockpit bridge. lazygit (a sibling zellij pane) drives this nvim through a
-- shared server socket; the `cockpit-nvim` helper calls these via --remote-expr.
-- Paths arrive base64-encoded so no quote or space has to survive the shell and
-- Vimscript quoting on the way in. Work is scheduled onto the main loop so it
-- runs regardless of the mode nvim happens to be in when the call lands.
local M = {}

-- Open a file (optionally at a line) here, like clicking a path in an IDE.
-- Backs lazygit's os.edit and the delta `lazygit-edit://` hyperlinks.
function M.open(args)
  local file = args[1] and vim.base64.decode(args[1])
  local line = tonumber(args[2])
  if not file or file == "" then return 0 end
  vim.schedule(function()
    vim.cmd.edit(vim.fn.fnameescape(file))
    if line and line > 0 then
      pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
      pcall(vim.cmd.normal, { args = { "zz" }, bang = true })
    end
  end)
  return 0
end

-- Follow a lazygit worktree switch: cd there (so find/grep/buffers target it)
-- and open its diff for review.
function M.worktree(b64)
  local path = b64 and vim.base64.decode(b64)
  if not path or path == "" then return 0 end
  vim.schedule(function()
    vim.cmd.cd(vim.fn.fnameescape(path))
    vim.cmd("DiffviewOpen")
  end)
  return 0
end

return M
