#!/usr/bin/env bash

MODULE_NAME=dotfiles

log_module_start

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_DATA_FILE='dotfiles.data'

function load_github_config()
{
    is_file "$DOTFILES_DATA_FILE" && source "$DOTFILES_DATA_FILE"
}

function install_dotfiles()
{
    git clone https://jdevera@github.com/jdevera/dotfiles.git "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
    bash install

    # Source to verify all is good with no errors
    source $HOME/.bashrc
}

is_dir $DOTFILES_DIR/.git && log_no_changes
load_github_config
install_dotfiles

log_module_end
