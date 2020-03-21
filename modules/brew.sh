#!/usr/bin/env bash

MODULE_NAME='Homebrew'

log_module_start

[[ -e /home/linuxbrew/.linuxbrew/bin/brew ]] && log_no_changes

INSTALLER_URL='https://raw.githubusercontent.com/Homebrew/install/master/install.sh'

tmp_dir=''
create_temp_dir homebrew tmp_dir

trap "cd /tmp && rm -rf $tmp_dir" EXIT
download_file_to "$INSTALLER_URL" "$tmp_dir"
echo | bash "$tmp_dir/install.sh" || log_fatal "Could not install brew"
echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> "$HOME/.dotfiles/bash.d/local/after/brew_init.sh"

log_module_end
