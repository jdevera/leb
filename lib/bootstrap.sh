#!/usr/bin/env bash

LIBRARY_DIR=$(dirname "$BASH_SOURCE")
BOOTSTRAP_DIR=$(dirname "$LIBRARY_DIR")
MODULES_ACTIVE_DIR=${OVERRIDE_MODULES_DIR:-$BOOTSTRAP_DIR/modules}



function check_has_bash4
{
    ${BASH4:-bash} --version | grep -q "GNU bash.*version 4" || \
        { echo  "ERROR: Bash v4 or newer is required"; exit 1; }
}

function assert_not_at_home()
{
    [[ -n $LEB_SKIP_HOME_CHECK ]]  && return
    case "$(readlink -f "$BOOTSTRAP_DIR")" in
        /home/*)
        { echo  "Do not run from under the home directory"; exit 1; }
    esac
}

function assert_not_root()
{
    [[ $EUID -ne 0 ]] || {
        echo "ERROR: Do not run as root"; exit 1; }
}

function source_library()
{
    for file in $LIBRARY_DIR/*.sh
    do
        source $file EXPORT || { echo "Library error" && exit 1; }
    done
}

function run_module()
{
    local file="$1"
    if is_exec "$file"
    then
        ( cd "$MODULES_ACTIVE_DIR" && ./$(basename $file) )
    fi
}

function run_modules()
{
    if [[ -n $1 ]]
    then
        log_info "Running only these modules: $*"
        for file in "$@"
        do
            run_module $MODULES_ACTIVE_DIR/$file
        done
    else
        declare -a MODULES
        source $MODULES_ACTIVE_DIR/modules.enabled
        for module in ${MODULES[@]}
        do
            run_module "$MODULES_ACTIVE_DIR/$module"
        done
    fi
}

function print_banner()
{
    cat <<EOH
    ┏━━━━━━━━━━━━━━━━━━━━━━┓
    ┃     ╻   ┏━╸ ┏┓       ┃ 
    ┃     ┃   ┣╸  ┣┻┓      ┃
    ┃     ┗━╸╹┗━╸╹┗━┛╹     ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━┛

EOH
}
