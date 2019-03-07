#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
LIB_DIR=$(readlink -f "$SCRIPT_DIR/../../lib")
MOD_DIR=$(readlink -f "$SCRIPT_DIR/../../modules")
TOOL_DIR=$(readlink -f "$SCRIPT_DIR/../../resources/tools")
BOOTSTRAPPER=$(readlink -f "$SCRIPT_DIR/../../bootstrap")

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

if [[ $1 == rank ]]
then
    for func in $func_names
    do
        count=$(count_in "$func" "$BOOTSTRAPPER" "$LIB_DIR"/* "$MOD_DIR"/* "$TOOL_DIR"/* )
        echo "$(( count - 1 )) $func"
    done |
        sort -n -k1
else
    for func in $func_names
    do
        count=$(count_in "$func" "$BOOTSTRAPPER" "$LIB_DIR"/* "$MOD_DIR"/*)
        if [[ $count -lt 2 ]]
        then
            echo "$func is not used in bootstrapper, library, or modules"
            tool_count=$(count_in "$func" "$TOOL_DIR"/* )
            if [[ $tool_count -gt 0 ]]
            then
                echo "   but it is used $tool_count times in tools"
            fi
        fi
    done
fi

