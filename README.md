# Dotfiles

![MacOS Terminal](doc/macos_terminal.png "MacOS Terminal")

## Install

Works on macOS and Debian/Ubuntu Linux.

```bash
git clone https://github.com/frousselet/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script is idempotent: run it again any time to update an existing
installation (Homebrew/apt packages, oh-my-zsh, zsh plugins, symlinks).

The repo must live at `~/.dotfiles` — the zsh config references that path.

### Options

- `--no-sudo` — skip every step that needs sudo. On Linux, packages are
  installed via Homebrew (sudo-free) instead of apt, and zsh is set up to
  launch from `~/.bashrc` instead of `chsh` (which needs `/etc/shells`).
  Useful on machines where you don't have root.

## Packages

Packages are declared in [`apps.json`](apps.json), grouped by package manager:

```json
{
  "settings": {
    "linux_prefer_default_package_manager": true,
    "linux_fallback_to_brew": true
  },
  "packages": {
    "apt": {
      "git": { "headless": true, "linux": true, "macos": false }
    },
    "snap": {},
    "brew": {
      "git":    { "headless": true,  "linux": true,  "macos": true },
      "drawio": { "headless": false, "linux": false, "macos": true }
    }
  }
}
```

Per package:

- `linux` / `macos` — desired state on that OS: `true` installs it, `false`
  uninstalls it (if present). Omit the key to leave the package untouched.
- `headless` — `false` means GUI-only: it's skipped on headless hosts (no
  display). Override detection with `HEADLESS=1` / `HEADLESS=0`.

Settings:

- `linux_prefer_default_package_manager` — on Linux, prefer apt/snap over brew
  when available (and sudo is allowed).
- `linux_fallback_to_brew` — allow installing/using Homebrew on Linux (used
  with `--no-sudo`, or when apt isn't available).

`install.sh` installs the applicable packages idempotently on every run.

## Customization

Drop machine-local snippets into `~/.zsh_extra/pre/*.zsh` (sourced first) or
`~/.zsh_extra/post/*.zsh` (sourced last). For example, to enable Nerd Font
prompt icons on a machine that has such a font installed:

```bash
echo 'export PROMPT_ICONS=1' > ~/.zsh_extra/post/icons.zsh
```
