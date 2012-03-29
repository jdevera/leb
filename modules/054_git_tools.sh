#!/usr/bin/env bash

MODULE_NAME='Git tools'

log_module_start

load_prefix_dirs

LOCAL_BASH_DIR="$HOME/.bash.d/local/after"

changes=false

if ! is_exec "$USER_BIN_DIR/git-wtf"
then
    log_info "Installing git-wtf"
    program_is_available ruby || package_install ruby1.9.1
    download_file_to "http://git-wt-commit.rubyforge.org/git-wtf" "$USER_BIN_DIR"
    chmod +x $USER_BIN_DIR/git-wtf
    is_exec $USER_BIN_DIR/git-wtf && changes=true
fi

if ! is_exec "$USER_BIN_DIR/hub"
then
    log_info "Installing hub"
    program_is_available ruby || package_install ruby1.9.1
    program_is_available rake || package_install rake
    is_dir "$USER_SHARE_LIB_DIR/hub" && remove_dir "$USER_SHARE_LIB_DIR/hub"
    git clone git://github.com/defunkt/hub.git "$USER_SHARE_LIB_DIR/hub"
    cd "$USER_SHARE_LIB_DIR/hub"
    rake install prefix="$USER_PREFIX_DIR"
    is_exec $USER_BIN_DIR/hub && changes=true
    # Install bash completion
    ln -sf "$USER_SHARE_LIB_DIR/hub/etc/hub.bash_completion.sh" "$LOCAL_BASH_DIR/"
    $USER_BIN_DIR/hub alias -s > "$LOCAL_BASH_DIR/hub.alias.sh"
fi

$changes || log_no_changes


log_module_end
