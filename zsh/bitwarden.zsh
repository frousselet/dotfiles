# Use the Bitwarden desktop SSH agent when its socket is present (macOS).
# Guarded so we never point SSH_AUTH_SOCK at a missing socket on machines
# without Bitwarden, which would break ssh/git-over-ssh.
_bw_ssh_sock="$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
if [[ -S "$_bw_ssh_sock" ]]; then
    export SSH_AUTH_SOCK="$_bw_ssh_sock"
fi
unset _bw_ssh_sock
