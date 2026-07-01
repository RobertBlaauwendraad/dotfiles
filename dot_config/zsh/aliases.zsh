# Navigation
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias la='eza -a --icons'

# Files
alias cat='bat --paging=never'

# Tools
alias lg='lazygit'
alias cheat='open ~/Documents/dev/cheatsheet.html'

# Open a cockpit tab (lazygit + shell) in the current repo. Ghostty already
# drops you in the persistent "main" session on a plain shell; run this from a
# repo when you want the review workspace — lazygit opens on that repo.
cockpit() {
  [[ -n "$ZELLIJ" ]] || { echo "cockpit: run inside zellij (open Ghostty)" >&2; return 1; }
  local root="$(git rev-parse --show-toplevel 2>/dev/null)"
  zellij action new-tab --layout cockpit --cwd "$PWD" --name "Cockpit: ${${root:-$PWD}:t}"
}

# Open an agent tab bound to a git worktree: cwd + tab name from the path.
# e.g. `wt ../myproj-feature`
wt() {
  local dir="${1:?usage: wt <worktree-path>}"
  [[ -d "$dir" ]] || { echo "wt: no such directory: $dir" >&2; return 1; }
  [[ -n "$ZELLIJ" ]] || { echo "wt: run inside zellij (open Ghostty)" >&2; return 1; }
  zellij action new-tab --cwd "$dir" --name "${1:t:r}"
}

