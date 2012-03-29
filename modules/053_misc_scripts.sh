#!/usr/bin/env bash

MODULE_NAME='Misc Scripts'

log_module_start

load_prefix_dirs

REPO_URL='git://github.com/jdevera/misc-scripts.git'
DEST_DIR="$USER_SHARE_LIB_DIR/misc-scripts"

is_dir "$DEST_DIR/.git" && log_no_changes

git clone "$REPO_URL" "$DEST_DIR"

# link all executables here
link_all_programs "$DEST_DIR" "$USER_BIN_DIR"
log_module_end
