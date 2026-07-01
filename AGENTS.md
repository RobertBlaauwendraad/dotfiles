# AGENTS.md — dotfiles (chezmoi source)

Instructions for agents working in **this repo**. `CLAUDE.md` is a symlink to this file,
so Claude Code and opencode share it. Not deployed to `$HOME` (see `.chezmoiignore`).

## What this is
The chezmoi **source directory** (`~/.local/share/chezmoi`). Files here are templates for
`$HOME`, not live config. Editing a file here does nothing until `chezmoi apply`.

## Source naming (chezmoi attributes)
- `dot_foo`        → `~/.foo`
- `private_foo/`   → dir with `0700` perms
- `symlink_foo`    → symlink; file content is the target path
- `run_once_*`     → script run once on a fresh machine
- `run_onchange_*` → script re-run whenever its (rendered) content changes
- `*.tmpl`         → Go-template, rendered at apply time

## Rules
- **Never** put secrets/machine-specific values in tracked files. They go in
  `~/.config/chezmoi/chezmoi.toml` (untracked) and are pulled into `*.tmpl` via `{{ .x.y }}`.
- After editing, verify before declaring done:
  - `chezmoi execute-template < file.tmpl` — check a template renders + is valid.
  - `chezmoi diff` — preview what `apply` would change in `$HOME`.
  - `zellij --config <file> setup --check` for zellij; `jq . < file` for JSON.
- Don't run `chezmoi apply` or `git commit`/`push` unless asked.

## Workflow
This setup is a **living, continuously-evolving** work in progress — expect it to change
as the workflow is refined.

Current workflow: agentic development using **git worktrees** for parallel/isolated agent
work, with changes reviewed in **lazygit** and **nvim**.
