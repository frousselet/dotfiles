# Homebrew keg-only ruby lives in different prefixes depending on the host
# (Intel macOS, Apple Silicon, Linuxbrew). Only prepend the one that exists.
for _ruby_bin in /opt/homebrew/opt/ruby/bin /usr/local/opt/ruby/bin; do
    if [[ -d "$_ruby_bin" ]]; then
        export PATH="$_ruby_bin:$PATH"
        break
    fi
done
unset _ruby_bin

if command -v rbenv > /dev/null; then
    eval "$(rbenv init -)"
fi