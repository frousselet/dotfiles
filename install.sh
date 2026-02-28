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

  if [ -e "$dest" ]; then
    mv "$dest" "${dest}.backup"
    info "Backed up $dest to ${dest}.backup"
  fi

  ln -s "$src" "$dest"
  success "$dest -> $src"
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

if [ "$OS" = "Darwin" ]; then
  # 1. Homebrew
  info "Checking Homebrew..."
  if ! command -v brew > /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -d "/opt/homebrew" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi
  success "Homebrew installed"

  info "Updating Homebrew..."
  brew update
  success "Homebrew updated"

  # 2. CLI packages
  info "Installing CLI packages..."
  brew install zsh git wget
  success "CLI packages installed"

  # 3. Cask apps
  info "Installing cask apps..."
  brew install --cask drawio rectangle tower netnewswire
  success "Cask apps installed"

else
  # 1. APT packages
  info "Updating apt..."
  sudo apt-get update -qq
  success "apt updated"

  info "Installing packages..."
  sudo apt-get install -y -qq zsh git wget curl
  success "Packages installed"
fi

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

echo ""
echo "=== Done ==="
echo ""
