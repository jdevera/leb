#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
LIB_DIR=$(readlink -f "$SCRIPT_DIR/../../lib")

func=$1

clean_funcs=$(env "BASH_FUNC_tmp_%%=() {
$(<"$LIB_DIR/functions.sh")
}" bash -c 'declare -f tmp_' |
    tail -n+3 |
    sed '$d')

func_names=$(grep -P '^\s*function \w+' <<<"$clean_funcs" |
    awk '{ print $2 }')


function count_in()
{
    local func=$1
    shift
    grep -o "$func" "$@" | wc -l
}


if ! grep "^${func}$" <<<"$func_names"
then
    echo "$func was not found"
    exit 1
fi

# Start a subshell with a function to edit the output of declare -F function_name
(
    editf()
    {
        local file=$3
        local line=$2
        exec vim "$file" +$line
    }
    source "$LIB_DIR/functions.sh"
    shopt -s extdebug
    editf $(declare -F "$func")
)
