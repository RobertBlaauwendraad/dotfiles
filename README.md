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
| `dot_config/opencode/` | opencode config (templated) |
| `dot_claude/` | Claude Code settings + `CLAUDE.md` → `AGENTS.md` |
| `dot_config/AGENTS.md` | Shared AI-agent instructions |
| `dot_gitconfig`, `dot_config/git/` | git config + global ignore |
| `private_Library/.../lazygit/` | lazygit config |

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
