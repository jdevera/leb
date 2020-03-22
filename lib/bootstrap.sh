#!/usr/bin/env bash

LIBRARY_DIR=$(dirname "$BASH_SOURCE")
BOOTSTRAP_DIR=$(dirname "$LIBRARY_DIR")
MODULES_ACTIVE_DIR=${LEB_MODULES_DIR:-$BOOTSTRAP_DIR/modules}


function die()
{
    echo "$@" >&2
    exit 1
}

function bad_usage()
{
    [[ -n $* ]] && echo "BAD USAGE: $@" >&2
    usage
    exit 2
}

function assert_has_value()
{
    local arg=$1
    local value=$2

    [[ -n $value ]] || bad_usage "Agument $arg requires a value";
}

function check_has_bash4
{
    ${BASH4:-bash} --version | grep -q "GNU bash.*version 4" ||
        die "ERROR: Bash v4 or newer is required"
}

function assert_not_at_home()
{
    [[ -n $LEB_SKIP_HOME_CHECK ]]  && return
    case "$(readlink -f "$BOOTSTRAP_DIR")" in
        /home/*)
        die "Do not run from under the home directory"
    esac
}

function assert_not_root()
{
    [[ $EUID -ne 0 ]] ||
        die "ERROR: Do not run as root"
}

function source_library()
{
    for file in $LIBRARY_DIR/*.sh
    do
        source $file EXPORT || die "Library error"
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
    load_and_check_modules "$@"
    if [[ -n $1 ]]
    then
        log_info "Running only these modules: $*"
    fi
    for module in ${MODULES[@]}
    do
        run_module "$MODULES_ACTIVE_DIR/$module"
    done
}

load_and_check_modules()
{
    local file

    # Build the list of modules
    if [[ -n $1 ]]
    then
        MODULES=( "$@" )
    else
        source $MODULES_ACTIVE_DIR/modules.enabled
    fi

    # Check them
    for file in ${MODULES[@]}
    do
        [[ -e $MODULES_ACTIVE_DIR/$file ]] ||
            die "Error: module $file could not be found under $MODULES_ACTIVE_DIR"
    done
}

function print_module_list()
{
    load_and_check_modules "$@"
    print_banner
    echo "Module List"
    echo
    local file
    for file in ${MODULES[@]}
    do
        echo "$file :: $(module_name "$file")"
    done
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

usage_header()
{
        cat <<EOU
Jacobo de Vera's Linux Environment Bootstrapper

LEB sets up a fresh Linux environment with many of my preferences and
customisations.

It does so through the execution of a series of specialised modules that
perform the various tasks.

Module execution is designed to be **idempotent**, so the bootstrapper can be
run on an already configured box to apply only the changes that have not
already been applied.
EOU
}

function module_name()
{
    local module=$1
    local MODULE_NAME
    eval "$(grep -h ^MODULE_NAME "$MODULES_ACTIVE_DIR/$module")"
    echo $MODULE_NAME
}

