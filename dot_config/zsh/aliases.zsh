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
# Claude runs in a hidden floating pane; reveal/hide it with the zellij prefix
# then p (Ctrl+g, then p).
cockpit() {
  [[ -n "$ZELLIJ" ]] || { echo "cockpit: run inside zellij (open Ghostty)" >&2; return 1; }
  local root="$(git rev-parse --show-toplevel 2>/dev/null)"
  local origin="$(zellij action current-tab-info | awk '/^id:/ {print $2}')"
  zellij action new-tab --layout cockpit --cwd "$PWD" --name "Cockpit: ${${root:-$PWD}:t}"
  [[ -n "$origin" ]] && zellij action close-tab-by-id "$origin"
}
alias ck='cockpit'

# Open an agent tab bound to a git worktree, creating it on first use.
# `wt <name>` → sibling worktree <repo>-<name> on branch <name> (reusing the
# branch if it exists, else cutting a new one off HEAD), then a zellij tab
# cwd'd there. Re-running with the same name just reopens the tab.
wt() {
  local name="${1:?usage: wt <name>}"
  [[ -n "$ZELLIJ" ]] || { echo "wt: run inside zellij (open Ghostty)" >&2; return 1; }

  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" \
    || { echo "wt: not inside a git repository" >&2; return 1; }

  local dir="${root:h}/${root:t}-${name}"
  if [[ ! -d "$dir" ]]; then
    if git -C "$root" show-ref --verify --quiet "refs/heads/$name"; then
      git -C "$root" worktree add "$dir" "$name" || return 1
    else
      git -C "$root" worktree add -b "$name" "$dir" || return 1
    fi
  fi

  # Bare `new-tab --cwd` is ignored (lands in ~); pairing --cwd with a --layout
  # makes it stick (same combo as cockpit). `default` is our normal tab template
  # (tab-bar + pane), so the tab looks identical — just rooted at the worktree.
  zellij action new-tab --layout default --cwd "$dir" --name "$name"
}

