#!/usr/bin/env bash

MODULE_NAME='Git tools'

log_module_start

PREFIX="$HOME/other/run"
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib"
LOCAL_BASH_DIR="$HOME/.bash.d/local/after"

changes=false

if ! is_exec "$BIN_DIR/git-wtf"
then
    log_info "Installing git-wtf" | indent
    program_is_available ruby || package_install ruby1.9.1
    download_file_to "http://git-wt-commit.rubyforge.org/git-wtf" "$BIN_DIR"
    chmod +x $BIN_DIR/git-wtf
    is_exec $BIN_DIR/git-wtf && changes=true
fi

if ! is_exec "$BIN_DIR/hub"
then
    log_info "Installing hub" | indent
    program_is_available ruby || package_install ruby1.9.1
    program_is_available rake || package_install rake
    is_dir "$LIB_DIR/hub" && remove_dir "$LIB_DIR/hub"
    git clone git://github.com/defunkt/hub.git "$LIB_DIR/hub"
    cd "$LIB_DIR/hub"
    rake install prefix="$PREFIX"
    is_exec $BIN_DIR/hub && changes=true
    # Install bash completion
    ln -sf "$LIB_DIR/hub/etc/hub.bash_completion.sh" "$LOCAL_BASH_DIR/"
    $BIN_DIR/hub alias -s > "$LOCAL_BASH_DIR/hub.alias.sh"
fi

$changes || log_no_changes


log_module_end
