#!/usr/bin/env bash

MODULE_NAME='Shared Dotfiles'

log_module_start

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_DATA_FILE='dotfiles.data'
DOTFILES_REPO='git://github.com/jdevera/dotfiles.git'


# Allow unattended installation by loading here all values for environment
# variables that are used in the dotfiles templates.
# It is important to 'export' any variables
function load_github_config()
{
    if is_file "$DOTFILES_DATA_FILE"
    then
        log_info "With preloaded github data from $DOTFILES_DATA_FILE"
        source "$DOTFILES_DATA_FILE"
    fi
}

function is_dotfiles_installed()
{
    is_dir $DOTFILES_DIR/.git && \
    [[ $(readlink -f ~/.bashrc) == $(readlink -f $DOTFILES_DIR/bashrc) ]] && \
    is_dir ~/.bash.d/local/after
}

function install_dotfiles()
{
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
    export SKIP_VIM_PLUGINS=1
    bash install

    # Source to verify all is good with no errors
    source $HOME/.bashrc
}

is_dotfiles_installed && log_no_changes

is_file "$HOME/.bashrc" && mv "$HOME/.bashrc" "$HOME/.bashrc.dist"
load_github_config
install_dotfiles

log_module_end
