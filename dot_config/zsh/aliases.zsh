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
# `wt <branch>` → sibling worktree on <branch> (reusing it if it exists, else
# cutting a new one off HEAD), then a zellij tab cwd'd there. The dir slugs the
# full branch (/ → -) so prefixed branches never collide; the tab is named for
# the branch's last segment. `wt feature/foo` → dir <repo>-feature-foo, tab "foo".
# Re-running with the same branch just reopens the tab.
wt() {
  local branch="${1:?usage: wt <branch>  (e.g. feature/foo)}"
  [[ -n "$ZELLIJ" ]] || { echo "wt: run inside zellij (open Ghostty)" >&2; return 1; }

  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" \
    || { echo "wt: not inside a git repository" >&2; return 1; }

  local dir="${root:h}/${root:t}-${branch//\//-}"
  if [[ ! -d "$dir" ]]; then
    if git -C "$root" show-ref --verify --quiet "refs/heads/$branch"; then
      git -C "$root" worktree add "$dir" "$branch" || return 1
    else
      git -C "$root" worktree add -b "$branch" "$dir" || return 1
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
  zellij action new-tab --layout "$layout" --cwd "$dir" --name "${branch:t}"
}

# Tear down the worktree you're standing in: drop the worktree dir and close its
# zellij tab. The down-counterpart to `wt`. The branch is kept (its commits — and
# any PR — outlive the worktree), so this only ever risks losing an uncommitted
# tree; it refuses when work looks unlanded (dirty tree, or commits not yet on the
# branch's upstream). `-f`/`--force` overrides both guards.
unwt() {
  [[ -n "$ZELLIJ" ]] || { echo "unwt: run inside zellij (open Ghostty)" >&2; return 1; }

  local force=0
  [[ "$1" == "-f" || "$1" == "--force" ]] && force=1

  local wt_root
  wt_root="$(git rev-parse --show-toplevel 2>/dev/null)" \
    || { echo "unwt: not inside a git repository" >&2; return 1; }

  # The main worktree is always the first entry of `worktree list`; refuse to
  # nuke it — unwt is only for the sibling worktrees that `wt` spawns.
  local main
  main="$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')"
  [[ "$wt_root" != "$main" ]] \
    || { echo "unwt: this is the main checkout, not a wt worktree" >&2; return 1; }

  local branch
  branch="$(git -C "$wt_root" symbolic-ref --short -q HEAD)"

  if (( ! force )); then
    if [[ -n "$(git -C "$wt_root" status --porcelain)" ]]; then
      echo "unwt: '${wt_root:t}' has uncommitted changes — commit/stash, or -f to discard" >&2
      return 1
    fi
    # Commits sitting only on the local branch count as unlanded work. Compare
    # against the upstream if one's set, else against the main worktree's branch.
    if [[ -n "$branch" ]]; then
      local range
      if git -C "$wt_root" rev-parse -q --verify '@{upstream}' >/dev/null 2>&1; then
        range='@{upstream}..HEAD'
      else
        range="$(git -C "$main" symbolic-ref --short -q HEAD)..HEAD"
      fi
      if [[ -n "$(git -C "$wt_root" rev-list "$range" 2>/dev/null)" ]]; then
        echo "unwt: '$branch' has unlanded commits — push/merge, or -f to skip" >&2
        return 1
      fi
    fi
  fi

  # Can't remove the worktree you're standing in, so hop to the main checkout
  # first; the tab (all its panes rooted here) goes last, once the dir is gone.
  cd "$main" || return 1
  git worktree remove ${force:+--force} "$wt_root" || { cd "$wt_root"; return 1; }
  zellij action close-tab
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

