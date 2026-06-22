#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Options
NO_SUDO=0

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Options:
  --no-sudo   Skip sudo steps; on Linux, install via Homebrew instead of apt
              and set up zsh from ~/.bashrc instead of chsh.
  -h, --help  Show this help.

Environment:
  HEADLESS=1  Force headless mode (skip GUI-only apps from apps.json).
  HEADLESS=0  Force non-headless mode.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --no-sudo) NO_SUDO=1 ;;
    -h | --help) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
  printf "${BLUE}[...]${NC} %s\n" "$1"
}

success() {
  printf "${GREEN}[OK]${NC}  %s\n" "$1"
}

error() {
  printf "${RED}[ERR]${NC} %s\n" "$1"
}

# Run a command with sudo, or skip it entirely under --no-sudo.
sudo_run() {
  if [ "$NO_SUDO" = 1 ]; then
    info "Skipping (--no-sudo): sudo $*"
    return 0
  fi
  sudo "$@"
}

# Make sure "brew" is usable on Linux without sudo: reuse an existing
# Linuxbrew, otherwise attempt to bootstrap it. Returns non-zero if brew is
# still unavailable afterwards.
ensure_linuxbrew() {
  command -v brew > /dev/null && return 0

  local p
  for p in /home/linuxbrew/.linuxbrew "$HOME/.linuxbrew"; do
    if [ -x "$p/bin/brew" ]; then
      eval "$("$p/bin/brew" shellenv)"
      return 0
    fi
  done

  info "Installing Homebrew (Linuxbrew)..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true

  for p in /home/linuxbrew/.linuxbrew "$HOME/.linuxbrew"; do
    if [ -x "$p/bin/brew" ]; then
      eval "$("$p/bin/brew" shellenv)"
      break
    fi
  done

  command -v brew > /dev/null
}

# Sudo-free way to "default" to zsh when chsh isn't available (no sudo, or a
# locked-down account): hand off to zsh from interactive bash. Idempotent.
add_exec_zsh_fallback() {
  local rc="$HOME/.bashrc"
  local marker="# >>> dotfiles: launch zsh >>>"

  if [ -f "$rc" ] && grep -qF "$marker" "$rc"; then
    success "zsh auto-launch already configured in ~/.bashrc"
    return
  fi

  cat >> "$rc" <<EOF

$marker
if [ -x "$ZSH_BIN" ] && [ -z "\${ZSH_VERSION:-}" ] && [[ \$- == *i* ]]; then
  exec "$ZSH_BIN" -l
fi
# <<< dotfiles: launch zsh <<<
EOF
  success "Configured ~/.bashrc to launch zsh (no chsh needed)"
}

# Is this a headless environment (no graphical display)? macOS always has a
# GUI; on Linux we look for a display. Override with HEADLESS=1 or HEADLESS=0.
is_headless() {
  if [ -n "${HEADLESS:-}" ]; then
    [ "$HEADLESS" = 1 ]
    return
  fi
  [ "$OS" = "Darwin" ] && return 1
  [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && return 1
  return 0
}

pkg_install_apt() {
  local p="$1"
  if dpkg -s "$p" > /dev/null 2>&1; then
    success "$p (already installed)"
    return
  fi
  info "Installing $p (apt)..."
  sudo_run apt-get install -y -qq "$p"
  success "$p installed (apt)"
}

pkg_install_snap() {
  local p="$1"
  if ! command -v snap > /dev/null; then
    info "$p: snap not available, skipping"
    return
  fi
  if snap list "$p" > /dev/null 2>&1; then
    success "$p (already installed)"
    return
  fi
  info "Installing $p (snap)..."
  sudo_run snap install "$p"
  success "$p installed (snap)"
}

pkg_install_brew() {
  local p="$1"
  if brew list "$p" > /dev/null 2>&1 || brew list --cask "$p" > /dev/null 2>&1; then
    success "$p (already installed)"
    return
  fi
  info "Installing $p (brew)..."
  # Try formula first, then cask (the JSON doesn't distinguish them).
  if brew install "$p" > /dev/null 2>&1; then
    success "$p installed (brew)"
  elif brew install --cask "$p"; then
    success "$p installed (brew cask)"
  else
    error "failed to install $p (brew)"
  fi
}

# Install every package declared under .packages.<mgr> in apps.json that
# applies to this OS, skipping GUI-only packages (headless:false) on a
# headless host.
install_from_json() {
  local mgr="$1" os="$2"
  local headless_now=0
  is_headless && headless_now=1

  local name hl
  while IFS=$'\t' read -r name hl; do
    [ -n "$name" ] || continue
    if [ "$headless_now" = 1 ] && [ "$hl" = "false" ]; then
      info "Skipping $name ($mgr): headless terminal"
      continue
    fi
    case "$mgr" in
      apt) pkg_install_apt "$name" ;;
      snap) pkg_install_snap "$name" ;;
      brew) pkg_install_brew "$name" ;;
    esac
  done < <(jq -r --arg os "$os" \
    ".packages.\"$mgr\" // {} | to_entries[] | select(.value[\$os] == true) | \"\(.key)\t\(.value.headless)\"" \
    "$APPS_JSON")
}

# On Linux, decide which package manager to use for the declared packages,
# honoring the settings block. Echoes "apt", "brew", or nothing.
linux_choose_source() {
  local prefer fallback have_apt=0
  prefer="$(jq -r '.settings.linux_prefer_default_package_manager // true' "$APPS_JSON" 2> /dev/null)"
  fallback="$(jq -r '.settings.linux_fallback_to_brew // true' "$APPS_JSON" 2> /dev/null)"
  if [ "$NO_SUDO" = 0 ] && command -v apt-get > /dev/null; then
    have_apt=1
  fi

  if [ "$prefer" = "true" ] && [ "$have_apt" = 1 ]; then
    echo apt
  elif [ "$fallback" = "true" ]; then
    echo brew
  elif [ "$have_apt" = 1 ]; then
    echo apt
  fi
}

link_file() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    success "$dest (already linked)"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "${dest}.backup"
    info "Backed up $dest to ${dest}.backup"
  fi

  ln -s "$src" "$dest"
  success "$dest -> $src"
}

# Clone a git repo, or fast-forward it if it's already there (idempotent).
clone_or_update() {
  local repo="$1"
  local dest="$2"
  local name
  name="$(basename "$dest")"

  if [ -d "$dest/.git" ]; then
    info "Updating $name..."
    if git -C "$dest" pull --ff-only --quiet; then
      success "$name updated"
    else
      info "$name: skipped update (local changes?)"
    fi
  else
    info "Installing $name..."
    git clone --depth=1 --quiet "$repo" "$dest"
    success "$name installed"
  fi
}

# ---

OS="$(uname -s)"
if [ "$OS" != "Darwin" ] && [ "$OS" != "Linux" ]; then
  error "Unsupported OS: $OS (macOS and Linux only)"
  exit 1
fi

if [ "$OS" = "Linux" ] && [ ! -f /etc/debian_version ]; then
  error "Only Debian/Ubuntu is supported on Linux"
  exit 1
fi

echo ""
echo "=== Dotfiles Installer ($OS) ==="
echo ""

# 1. Package manager + bootstrap tools
# Bootstrap installs what the installer itself needs (jq to read apps.json, plus
# zsh/git); the declared packages from apps.json are handled right after.
APPS_JSON="$DOTFILES_DIR/apps.json"
PKG_SRC=""
OS_KEY=""

if [ "$OS" = "Darwin" ]; then
  OS_KEY="macos"
  info "Checking Homebrew..."
  if ! command -v brew > /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Make sure brew is on PATH for the rest of this script (Apple Silicon or Intel).
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  success "Homebrew ready"

  info "Updating Homebrew..."
  brew update
  success "Homebrew updated"

  info "Installing bootstrap tools..."
  brew install jq zsh git
  success "Bootstrap tools installed"
  PKG_SRC="brew"
else
  OS_KEY="linux"
  # We need jq to read apps.json. Bootstrap it with a heuristic source (apt when
  # sudo is available, otherwise Homebrew), then settle the source from settings.
  if [ "$NO_SUDO" = 0 ] && command -v apt-get > /dev/null; then
    info "Updating apt..."
    sudo_run apt-get update -qq
    info "Installing bootstrap tools (apt)..."
    sudo_run apt-get install -y -qq jq zsh git curl
    success "Bootstrap tools installed"
  else
    info "--no-sudo / no apt: bootstrapping via Homebrew"
    if ! ensure_linuxbrew; then
      error "No sudo and Homebrew unavailable — install zsh/git/jq/curl manually"
      exit 1
    fi
    info "Installing bootstrap tools (brew)..."
    brew install jq zsh git
    success "Bootstrap tools installed"
  fi

  PKG_SRC="$(linux_choose_source)"
  if [ -z "$PKG_SRC" ]; then
    error "No usable package manager (apt needs sudo, brew fallback disabled)"
  elif [ "$PKG_SRC" = "brew" ]; then
    ensure_linuxbrew || error "Homebrew requested but unavailable"
  fi
  info "Package source for Linux: ${PKG_SRC:-none}"
fi

# 1b. Declared packages from apps.json
echo ""
if [ ! -f "$APPS_JSON" ]; then
  info "No apps.json — skipping declared packages"
elif ! jq empty "$APPS_JSON" 2> /dev/null; then
  error "Invalid JSON in apps.json — skipping declared packages"
else
  info "Installing declared packages from apps.json..."
  if [ "$OS" = "Darwin" ]; then
    install_from_json brew "$OS_KEY"
  elif [ "$PKG_SRC" = "apt" ]; then
    install_from_json apt "$OS_KEY"
    install_from_json snap "$OS_KEY"
  elif [ "$PKG_SRC" = "brew" ]; then
    install_from_json brew "$OS_KEY"
  fi
fi

# 2. oh-my-zsh (install or update)
echo ""
ZSH_DIR="$HOME/.oh-my-zsh"
if [ -d "$ZSH_DIR/.git" ]; then
  info "Updating oh-my-zsh..."
  if git -C "$ZSH_DIR" pull --ff-only --quiet; then
    success "oh-my-zsh updated"
  else
    info "oh-my-zsh: skipped update (local changes?)"
  fi
else
  info "Installing oh-my-zsh..."
  # KEEP_ZSHRC: don't touch our .zshrc. CHSH/RUNZSH: we handle the shell ourselves.
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  success "oh-my-zsh installed"
fi

# 3. Custom zsh plugins (install or update)
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
clone_or_update https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# 4. Symlinks
echo ""
info "Creating symlinks..."
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/htop/htoprc" "$HOME/.config/htop/htoprc"

# 5. Git config
echo ""
info "Configuring git..."
git config --global user.name "François Rousselet"
git config --global user.email "francois.rousselet@rslt.fr"
success "Git configured"

# 6. Zsh extension directories
info "Creating zsh extension directories..."
mkdir -p "$HOME/.zsh_extra/pre"
mkdir -p "$HOME/.zsh_extra/post"
success "Zsh extension directories ready"

# 7. Default shell
echo ""
ZSH_BIN="$(command -v zsh)"
if [ "${SHELL:-}" = "$ZSH_BIN" ]; then
  success "zsh already the default shell"
elif [ "$NO_SUDO" = 1 ]; then
  # chsh needs the shell in /etc/shells (sudo) and is often PAM-locked, so
  # default to zsh from ~/.bashrc instead.
  info "--no-sudo: configuring zsh via ~/.bashrc instead of chsh"
  add_exec_zsh_fallback
else
  info "Setting zsh as default shell..."
  if ! grep -q "^${ZSH_BIN}$" /etc/shells 2> /dev/null; then
    echo "$ZSH_BIN" | sudo tee -a /etc/shells > /dev/null
  fi
  if chsh -s "$ZSH_BIN"; then
    success "Default shell set to zsh (restart your session to apply)"
  else
    error "chsh failed — falling back to ~/.bashrc"
    add_exec_zsh_fallback
  fi
fi

echo ""
echo "=== Done ==="
echo ""
