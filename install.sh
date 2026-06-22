#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# 1. Package manager + base packages
if [ "$OS" = "Darwin" ]; then
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

  info "Installing CLI packages..."
  brew install zsh git wget
  success "CLI packages installed"

  info "Installing cask apps..."
  brew install --cask drawio rectangle tower netnewswire
  success "Cask apps installed"
else
  info "Updating apt..."
  sudo apt-get update -qq
  success "apt updated"

  info "Installing packages..."
  sudo apt-get install -y -qq zsh git wget curl
  success "Packages installed"
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
else
  info "Setting zsh as default shell..."
  if ! grep -q "^${ZSH_BIN}$" /etc/shells 2> /dev/null; then
    echo "$ZSH_BIN" | sudo tee -a /etc/shells > /dev/null
  fi
  if chsh -s "$ZSH_BIN"; then
    success "Default shell set to zsh (restart your session to apply)"
  else
    error "chsh failed — set it manually with: chsh -s $ZSH_BIN"
  fi
fi

echo ""
echo "=== Done ==="
echo ""
