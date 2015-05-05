#!/usr/bin/env bash

MODULE_NAME='Misc Scripts'

log_module_start

load_prefix_dirs

changes=false

function install_scripts_repo()
{
    local repo_url="$1"
    local repo_name="$2"
    if [[ -z $repo_name ]]
    then
        repo_name="$(basename $repo_url .git)"
    fi
    local repo_dir="$USER_SHARE_LIB_DIR/$repo_name"

    if is_dir "$repo_dir/.git"
    then
        (cd "$repo_dir" && git pull >/dev/null 2>&1)
        all_programs_linked "$repo_dir" "$USER_BIN_DIR" && return
    else
        git clone "$repo_url" "$repo_dir"
    fi
    changes=true
    link_all_programs "$repo_dir" "$USER_BIN_DIR"
}

install_scripts_repo git://github.com/jdevera/misc-scripts.git
install_scripts_repo git://github.com/jdevera/purehome.git

$changes || log_no_changes

log_module_end
