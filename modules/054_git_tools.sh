#!/usr/bin/env bash

MODULE_NAME='Git tools'

log_module_start

BIN_DIR="$HOME/other/run/bin"

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
    download_file_to "http://defunkt.io/hub/standalone" "/tmp/"
    mv /tmp/standalone $BIN_DIR/hub
    chmod +x $BIN_DIR/hub
    is_exec $BIN_DIR/hub && changes=true
fi

$changes || log_no_changes


log_module_end
