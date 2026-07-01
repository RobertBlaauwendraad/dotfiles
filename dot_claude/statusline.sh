#!/usr/bin/env bash
# Global Claude Code statusline.  Segments:  branch [⑂] · context% · model
#   ⑂ marks a linked git worktree (parallel agent sessions).
# Reads session JSON on stdin, prints one line to stdout.
input=$(cat)
j() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

G=$'\e[32m'; Y=$'\e[33m'; Rd=$'\e[31m'; C=$'\e[36m'; D=$'\e[2m'; X=$'\e[0m'
sep=" ${D}·${X} "

model=$(j '.model.display_name'); model=${model:-Claude}
cwd=$(j '.cwd'); [ -z "$cwd" ] && cwd=$(j '.workspace.current_dir'); [ -z "$cwd" ] && cwd=$PWD
ctx=$(j '.context_window.used_percentage')

# git branch + worktree flag, cached 2s (the statusline runs on every tick)
cache="/tmp/cc-sl-$(printf '%s' "$cwd" | cksum | cut -d' ' -f1)"
if [ -f "$cache" ] && [ "$(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || stat -f %m "$cache" 2>/dev/null) ))" -lt 2 ]; then
  IFS='|' read -r branch wt < "$cache"
else
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  gitdir=$(git -C "$cwd" --no-optional-locks rev-parse --git-dir 2>/dev/null)
  common=$(git -C "$cwd" --no-optional-locks rev-parse --git-common-dir 2>/dev/null)
  wt=""; [ -n "$gitdir" ] && [ "$gitdir" != "$common" ] && wt="1"
  printf '%s|%s' "$branch" "$wt" > "$cache"
fi
[ -z "$branch" ] && branch="no-git"
[ -n "$wt" ] && branch="${branch} ⑂"

# context, colored against a soft cap (early warning before compaction)
if [ -n "$ctx" ]; then
  pct=$(printf '%.0f' "$ctx")
  if   [ "$pct" -lt 55 ]; then col=$G
  elif [ "$pct" -lt 75 ]; then col=$Y
  else col=$Rd; fi
  ctxseg="${col}${pct}% ctx${X}"
else
  ctxseg="--% ctx"
fi

printf '%s' "${C}${branch}${X}${sep}${ctxseg}${sep}${D}${model}${X}"
