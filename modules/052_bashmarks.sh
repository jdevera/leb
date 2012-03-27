#!/usr/bin/env bash

MODULE_NAME='Bashmarks'

log_module_start

REPO_URL='https://github.com/jdevera/bashmarks'
DEST_DIR="$HOME/other/run/share/lib/bashmarks"

is_file "$DEST_DIR/bashmarks.sh" && log_no_changes

git clone "$REPO_URL" "$DEST_DIR"

# Quick sanity check
source "$DEST_DIR/bashmarks.sh"

ln -s "$DEST_DIR/bashmarks.sh" "$HOME/.bash.d/local/after/bashmarks.sh"

log_module_end
