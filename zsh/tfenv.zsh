# Guard on the directory, not "command -v tfenv": tfenv isn't on PATH yet —
# adding its bin/ here is precisely what puts it there.
if [[ -d "$HOME/.tfenv/bin" ]]; then
    export PATH="$HOME/.tfenv/bin:$PATH"
fi