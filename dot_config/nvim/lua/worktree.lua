-- Git worktree helpers. Lets the single cockpit review a worktree's changes
-- without leaving it: pick a worktree, diffview opens against it via `-C`, so
-- nvim's cwd stays on the main checkout while agents run in their own tabs.
local M = {}

-- Parse `git worktree list --porcelain` into { path, branch } entries.
local function worktrees()
  local out = vim.fn.systemlist({ "git", "worktree", "list", "--porcelain" })
  if vim.v.shell_error ~= 0 then
    return nil
  end
  local trees, cur = {}, nil
  for _, line in ipairs(out) do
    if line:match("^worktree ") then
      cur = { path = line:sub(10) }
      table.insert(trees, cur)
    elseif cur and line:match("^branch ") then
      cur.branch = line:gsub("^branch refs/heads/", "")
    elseif cur and line:match("^detached") then
      cur.branch = "(detached)"
    end
  end
  return trees
end

-- Pick a worktree and open diffview against it (working-tree changes, like
-- <leader>gv but rooted elsewhere).
function M.review_diff()
  local trees = worktrees()
  if not trees or #trees == 0 then
    vim.notify("No git worktrees found", vim.log.levels.WARN)
    return
  end
  -- Telescope is lazy-loaded on its own keys, so its vim.ui.select override
  -- isn't active yet when this runs; force it in so the picker floats instead
  -- of falling back to the built-in cmdline list.
  pcall(function() require("lazy").load({ plugins = { "telescope.nvim" } }) end)
  vim.ui.select(trees, {
    prompt = "Review worktree diff:",
    format_item = function(t)
      return string.format("%-24s %s", t.branch or "?", vim.fn.fnamemodify(t.path, ":~"))
    end,
  }, function(choice)
    if choice then
      -- diffview's short flags take their value attached (`-C=<path>`); a space
      -- would leave -C empty and read the path as a rev (E5108).
      vim.cmd("DiffviewOpen -C=" .. vim.fn.fnameescape(choice.path))
    end
  end)
end

return M
