#!/usr/bin/env bash
# Claude Code hook: reflect an agent's state in its zellij worktree tab.
#   working  (UserPromptSubmit) → "⋯ <branch>"   busy
#   done     (Stop)             → "✓ <branch>"   your turn
#   input    (Notification)     → "? <branch>"   needs input / permission
# A background pane renames its OWN tab via `rename-tab -t <id>` (no focus
# steal). The tab is found by branch name: `wt` names each tab after its
# worktree branch, and git forbids one branch in two worktrees, so the match
# is unique. Fresh/untouched tabs keep their plain name.
#
# Desktop popups (needs-input / done) are opt-in and read fresh each fire:
# `touch ~/.claude/notify-popups` to enable — see the `agent-popups` alias.
set -u

state="${1:-}"
[ -n "$ZELLIJ" ] || exit 0   # only meaningful inside zellij

M_BUSY="⋯"; M_DONE="✓"; M_INPUT="?"

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$PWD

branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
[ -n "$branch" ] || exit 0   # detached HEAD / not a repo → nothing to mark

# Find the tab whose name, stripped of any leading marker glyph, equals $branch.
tabid=""
while read -r id _pos name; do
  [ "$id" = "TAB_ID" ] && continue          # header row
  for g in "$M_BUSY" "$M_DONE" "$M_INPUT"; do name="${name#"$g "}"; done
  if [ "$name" = "$branch" ]; then tabid="$id"; break; fi
done < <(zellij action list-tabs 2>/dev/null)
[ -n "$tabid" ] || exit 0                    # e.g. Cockpit floating agent → no matching tab

case "$state" in
  working) zellij action rename-tab -t "$tabid" "$M_BUSY $branch" ;;
  done)    zellij action rename-tab -t "$tabid" "$M_DONE $branch" ;;
  input)   zellij action rename-tab -t "$tabid" "$M_INPUT $branch" ;;
  *) exit 0 ;;
esac

# Opt-in desktop popup for the two "your turn" states.
if [ -f "$HOME/.claude/notify-popups" ] && { [ "$state" = "input" ] || [ "$state" = "done" ]; }; then
  b=${branch//\"/}   # keep the AppleScript string literal safe
  case "$state" in
    input) title="Claude · needs input" ;;
    done)  title="Claude · done" ;;
  esac
  osascript -e "display notification \"$b\" with title \"$title\"" >/dev/null 2>&1
fi
