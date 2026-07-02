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

  # Pick the layout by screen width: docked to a wide (>=3000px) display, center
  # claude at a fixed reading width so it doesn't hug the far-left edge (wt-wide,
  # flanked by lazygit + a shell); on the laptop alone, claude full-width (wt).
  # system_profiler (~0.4s) is a proxy for "am I docked" — it sees the physical
  # monitor, which is good enough here. No attached wide display → full-width.
  local layout=wt
  if system_profiler SPDisplaysDataType 2>/dev/null \
       | awk '/Resolution:/ { if ($2 + 0 >= 3000) f = 1 } END { exit !f }'; then
    layout=wt-wide
  fi

  # Bare `new-tab --cwd` is ignored (lands in ~); pairing --cwd with a --layout
  # makes it stick (same combo as cockpit), rooting every pane at the worktree.
  zellij action new-tab --layout "$layout" --cwd "$dir" --name "$name"
}

# Toggle desktop popups for the Claude agent-status hook. Tab markers
# (⋯ busy · ✓ done · ? needs-input) are always on; this flips only the macOS
# notification, via a flag file the hook reads fresh on each fire.
agent-popups() {
  local flag="$HOME/.claude/notify-popups"
  case "$1" in
    on)  : > "$flag"; echo "agent popups: on" ;;
    off) rm -f "$flag"; echo "agent popups: off" ;;
    *)   [[ -f "$flag" ]] && echo "agent popups: on" || echo "agent popups: off" ;;
  esac
}

