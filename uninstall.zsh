#!/usr/bin/env zsh
# usagi-cli-banner uninstaller

set -e

local install_dir="$HOME/.local/share/usagi"
local config_dir="$HOME/.config/usagi"
local zshrc="$HOME/.zshrc"
local marker="# usagi-cli-banner"

print "Uninstalling usagi-cli-banner..."

# Remove install directory
if [[ -d "$install_dir" ]]; then
    rm -rf "$install_dir"
    print "  Removed $install_dir"
else
    print "  $install_dir not found (skipped)"
fi

# Remove source lines from .zshrc
if [[ -f "$zshrc" ]]; then
    local tmp="$(mktemp)"
    local skip=false
    while IFS= read -r line; do
        if [[ "$line" == "$marker" ]]; then
            skip=true
            continue
        fi
        if [[ "$skip" == true ]]; then
            # Skip the source line immediately after the marker
            skip=false
            continue
        fi
        print -r -- "$line" >> "$tmp"
    done < "$zshrc"
    mv "$tmp" "$zshrc"
    print "  Cleaned $zshrc"
fi

print ""
print "Done! User config preserved at $config_dir"
print "To remove config too: rm -rf $config_dir"
