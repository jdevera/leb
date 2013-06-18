#!/usr/bin/env bash

MODULE_NAME='Misc Scripts'

log_module_start

load_prefix_dirs

REPO_URL='git://github.com/jdevera/misc-scripts.git'
DEST_DIR="$USER_SHARE_LIB_DIR/misc-scripts"


if is_dir "$DEST_DIR/.git"; then
    (cd "$DEST_DIR" && git pull >/dev/null 2>&1)
    all_programs_linked "$DEST_DIR" "$USER_BIN_DIR" && log_no_changes
else
    git clone "$REPO_URL" "$DEST_DIR"
fi

# link all executables here
link_all_programs "$DEST_DIR" "$USER_BIN_DIR"
log_module_end
