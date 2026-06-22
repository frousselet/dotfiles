export DOTCONFPATH="$HOME/.dotfiles/zsh"

# ── Machine-local pre hooks ──────────────────────────────────────────────
# Sourced first so a given host can tweak env/PATH before anything else.
if [[ -d "$HOME/.zsh_extra/pre" ]]; then
    for file in "$HOME/.zsh_extra/pre/"*.zsh; do
        [[ -f "$file" ]] && source "$file"
    done
fi

# ── Core shell setup ─────────────────────────────────────────────────────
# Locale, Homebrew/PATH, $ZSH — must run first so the "command -v" guards in
# the files below can actually see brew-installed tools.
source "$DOTCONFPATH/setup.zsh"

# ── Language / version managers ──────────────────────────────────────────
# These mutate PATH, so they run before plugins.zsh (whose plugin detection
# relies on "command -v" finding these tools).
source "$DOTCONFPATH/ruby.zsh"
source "$DOTCONFPATH/pyenv.zsh"
source "$DOTCONFPATH/tfenv.zsh"
source "$DOTCONFPATH/nvm.zsh"

# ── External tool integrations ───────────────────────────────────────────
source "$DOTCONFPATH/gcloud.zsh"
source "$DOTCONFPATH/1password.zsh"
source "$DOTCONFPATH/bitwarden.zsh"

# ── oh-my-zsh ────────────────────────────────────────────────────────────
# Declare the plugin list, then load the framework (extra.zsh sources
# oh-my-zsh.sh and runs compinit + the trailing completions).
source "$DOTCONFPATH/plugins.zsh"
source "$DOTCONFPATH/extra.zsh"

# ── Shell ergonomics ─────────────────────────────────────────────────────
# Sourced after oh-my-zsh so our aliases and prompt win over anything the
# framework or its plugins define.
source "$DOTCONFPATH/alias.zsh"
source "$DOTCONFPATH/prompt.zsh"

# ── Machine-local post hooks ─────────────────────────────────────────────
# Sourced last so a given host gets the final word.
if [[ -d "$HOME/.zsh_extra/post" ]]; then
    for file in "$HOME/.zsh_extra/post/"*.zsh; do
        [[ -f "$file" ]] && source "$file"
    done
fi
