# Navigation
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias la='eza -a --icons'

# Files
alias cat='bat --paging=never'

# Tools
alias lg='lazygit'
alias cheat='open ~/Documents/dev/cheatsheet.html'

# Open the cockpit (nvim + claude/lazygit/shell stack) on this repo, replacing
# the current tab: spawn the layout in a fresh tab, then close the one you ran
# from. new-tab initialises the tab-bar cleanly (override-layout doesn't).
# Claude runs in a hidden floating pane; reveal/hide it with Ctrl Alt Shift Super p.
cockpit() {
  [[ -n "$ZELLIJ" ]] || { echo "cockpit: run inside zellij (open Ghostty)" >&2; return 1; }
  local root="$(git rev-parse --show-toplevel 2>/dev/null)"
  local origin="$(zellij action current-tab-info | awk '/^id:/ {print $2}')"
  zellij action new-tab --layout cockpit --cwd "$PWD" --name "Cockpit: ${${root:-$PWD}:t}"
  [[ -n "$origin" ]] && zellij action close-tab-by-id "$origin"
}

# Open an agent tab bound to a git worktree: cwd + tab name from the path.
# e.g. `wt ../myproj-feature`
wt() {
  local dir="${1:?usage: wt <worktree-path>}"
  [[ -d "$dir" ]] || { echo "wt: no such directory: $dir" >&2; return 1; }
  [[ -n "$ZELLIJ" ]] || { echo "wt: run inside zellij (open Ghostty)" >&2; return 1; }
  zellij action new-tab --cwd "$dir" --name "${1:t:r}"
}

