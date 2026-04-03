#!/usr/bin/env zsh
# usagi-cli-banner installer

set -e

local src_dir="${${(%):-%x}:A:h}"
local install_dir="$HOME/.local/share/usagi"
local config_dir="$HOME/.config/usagi"
local zshrc="$HOME/.zshrc"
local source_line='[[ -f "$HOME/.local/share/usagi/usagi-banner.zsh" ]] && source "$HOME/.local/share/usagi/usagi-banner.zsh"'
local marker="# usagi-cli-banner"

print "Installing usagi-cli-banner..."

# Copy files to install directory
mkdir -p "$install_dir"/{defaults,themes}
cp "$src_dir/usagi-banner.zsh" "$install_dir/"
cp "$src_dir/defaults/"* "$install_dir/defaults/"
cp "$src_dir/themes/"* "$install_dir/themes/"
cp "$src_dir/uninstall.zsh" "$install_dir/"

# Create user config directory and copy template (if not exists)
mkdir -p "$config_dir"
if [[ ! -f "$config_dir/config.zsh" ]]; then
    cp "$src_dir/defaults/config-template.zsh" "$config_dir/config.zsh"
    print "  Created config at $config_dir/config.zsh"
else
    print "  Config already exists at $config_dir/config.zsh (preserved)"
fi

# Add source line to .zshrc (if not already present)
if ! grep -qF "$marker" "$zshrc" 2>/dev/null; then
    print "" >> "$zshrc"
    print "$marker" >> "$zshrc"
    print "$source_line" >> "$zshrc"
    print "  Added source line to $zshrc"
else
    print "  Source line already in $zshrc (skipped)"
fi

print ""
print "Done! Open a new terminal to see your banner."
print "To uninstall: zsh $install_dir/uninstall.zsh"
print "To configure: \$EDITOR $config_dir/config.zsh"
