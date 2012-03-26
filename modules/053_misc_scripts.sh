#!/usr/bin/env bash

MODULE_NAME='Misc Scripts'

log_module_start

REPO_URL='git://github.com/jdevera/misc-scripts.git'
DEST_DIR="$HOME/other/run/share/lib/misc-scripts"

is_dir "$DEST_DIR/.git" && log_no_changes

git clone "$REPO_URL" "$DEST_DIR"

# link all executables here
link_all_programs "$DEST_DIR" "$HOME/other/run/bin"
log_module_end
