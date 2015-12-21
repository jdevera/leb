#!/usr/bin/env bash

MODULE_NAME='GTK Directory bookmarks'

log_module_start

typeset -A BOOKMARKS
BOOKMARKS=(
    [Downloads]=comms/downloads
    [Documents]=doc
    [Music]=media/audio/music
    [Pictures]=media/image/pictures
    [Video]=media/video
)
BOOKMARKS_FILE="$HOME/.gtk-bookmarks"

function choose_bookmarks_file()
{
    BOOKMARKS_FILE="$HOME/.config/gtk-3.0/bookmarks"
    if [[ ! -e $BOOKMARKS_FILE ]]
    then
        BOOKMARKS_FILE="$HOME/.gtk-bookmarks"
    fi
}

function get_bookmark_line()
{
    local dest="$1"
    local name="$2"
    local dir="$HOME/${BOOKMARKS[$name]}"
    local encpath=$(python -c "import urllib; print urllib.quote('''$dir''')")
    set_var $dest "file://$encpath $name"
}

function check_bookmark()
{
    local bookmarkname="$1"
    local line
    get_bookmark_line line "$bookmarkname"
    grep -q "$line" "$BOOKMARKS_FILE"
}

function remove_bookmark()
{
    local name="$1"
    sed -i "/\b$name\$/d" "$BOOKMARKS_FILE"
}

function set_bookmark()
{
    local name="$1"
    local line
    get_bookmark_line line "$name"
    if ! grep -q "$line" "$BOOKMARKS_FILE"; then
        remove_bookmark "$name"
        echo $line >> $BOOKMARKS_FILE
        log_info "Setting bookmark $name to $HOME/${BOOKMARKS[$name]}"
    fi
}

function check_all_bookmarks()
{
    is_file "$BOOKMARKS_FILE" || return 1
    local bname
    for bname in ${!BOOKMARKS[@]}
    do
        check_bookmark "$bname" || return 1
    done
    return 0
}

function set_all_bookmarks()
{
    touch "$BOOKMARKS_FILE"
    local bname
    for bname in ${!BOOKMARKS[@]}
    do
        set_bookmark "$bname"
    done

}

choose_bookmarks_file
check_all_bookmarks && log_no_changes
set_all_bookmarks
log_module_end
