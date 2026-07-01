# dotfiles

Personal macOS dotfiles managed with [chezmoi](https://chezmoi.io).

## Fresh machine bootstrap

```sh
# Installs chezmoi, pulls this repo, and applies everything
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply RobertBlaauwendraad
```

On first `apply`, chezmoi will:
- **Install packages** — `run_onchange_before_install-packages.sh.tmpl` installs Homebrew
  (if missing) and runs `brew bundle` for every CLI tool and app used here.
- **Install zinit** — `run_once_after_install-zinit.sh.tmpl` clones the zsh plugin manager.

## Day-to-day

```sh
chezmoi edit ~/.zshrc     # edit a managed file (in the source dir)
chezmoi diff              # preview pending changes to $HOME
chezmoi apply             # apply changes
chezmoi re-add            # pull edits made directly in $HOME back into the repo
chezmoi cd                # jump to the source dir
```

## What's here

| Path | What |
|------|------|
| `dot_zshrc`, `dot_config/zsh/` | zsh + zinit, aliases |
| `dot_p10k.zsh` | Powerlevel10k prompt |
| `dot_config/nvim/` | Neovim (lazy.nvim) |
| `dot_config/zellij/` | Zellij multiplexer + layouts |
| `dot_config/ghostty/` | Ghostty terminal |
| `dot_config/karabiner/` | Karabiner-Elements (Caps Lock → Esc/Ctrl) |
| `dot_config/opencode/` | opencode config (templated) |
| `dot_claude/` | Claude Code settings + `CLAUDE.md` → `AGENTS.md` |
| `dot_config/AGENTS.md` | Shared AI-agent instructions |
| `dot_gitconfig`, `dot_config/git/` | git config + global ignore |
| `private_Library/.../lazygit/` | lazygit config |

## Workflow

Agentic development inside one persistent zellij session. In a repo, `cockpit`
opens a tab with nvim + lazygit + a hidden `claude` pane — agents write, I review
the diff in nvim (diffview) and stage in lazygit. Isolated or parallel agent work
gets its own git worktree via `wt <path>`. Always evolving.

## Keyboard & keybindings

One idea: **most-used actions on the easiest keys; each layer stays out of the
ones below it.** A terminal can't see `Cmd` and `Ctrl`/`Alt` are awkward, so the
physical layer is remapped first.

- **Caps Lock** → Esc (tap) / Ctrl (hold) — the one physical remap
- **`Ctrl+g`** → zellij prefix (tmux-style; `clear-defaults` lets every other key fall through to nvim/shell)
- **`Ctrl+hjkl`** → focus across nvim splits *and* zellij panes (zellij-nav.nvim)
- **`Space`** → nvim leader + which-key groups

## Secrets / private values

Nothing secret is committed. Machine-specific or private values (e.g. work GCP
identifiers) live in `~/.config/chezmoi/chezmoi.toml` (never tracked) and are pulled
into `*.tmpl` source files at apply time. Example:

```toml
# ~/.config/chezmoi/chezmoi.toml
[data.work]
    gcpProject  = "..."
    gcpInstance = "..."
```
