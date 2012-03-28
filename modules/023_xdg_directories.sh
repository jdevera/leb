#!/usr/bin/env bash

MODULE_NAME='XDG Directories'

log_module_start

typeset -A DIR_MAPPINGS
DIR_MAPPINGS=(
    [DESKTOP]=other/desktop
    [DOWNLOAD]=comms/downloads
    [TEMPLATES]=other/templates
    [PUBLICSHARE]=comms/public
    [DOCUMENTS]=doc
    [MUSIC]=media/audio/music
    [PICTURES]=media/image/pictures
    [VIDEOS]=media/video
)

function set_xdg_dir()
{
    local dirclass="$1"
    local relpath="$2"
    local fullpath="$HOME/$relpath"
    local olddir=$( xdg-user-dir "$dirclass" )

    [[ $olddir == $fullpath ]] && return 0

    [[ -n $olddir ]] && local odt="(was $olddir)"
    log_info "$dirclass directory is now $fullpath $odt" | indent
    create_dir "$fullpath"
    xdg-user-dirs-update --set $dirclass "$fullpath"
    [[ -n $olddir ]] && remove_dir_if_empty "$olddir"
}

function check_xdg_dir()
{
    local class="$1"
    local dir="$HOME/$2"
    [[ $( xdg-user-dir "$class" ) == "$dir" ]]
}

function set_all_xdg_dirs()
{
    local dir class
    for class in ${!DIR_MAPPINGS[@]}
    do
        dir=${DIR_MAPPINGS[$class]}
        set_xdg_dir $class $dir
    done
}

function check_all_xdg_mappings()
{
    local dir class
    for class in ${!DIR_MAPPINGS[@]}
    do
        dir=${DIR_MAPPINGS[$class]}
        check_xdg_dir $class $dir || return 1
    done
}

function can_do_xdg()
{
    program_is_available xdg-user-dirs-update && \
        program_is_available xdg-user-dir
}

can_do_xdg || log_fatal "XDG tools not available"
check_all_xdg_mappings && log_no_changes
set_all_xdg_dirs

log_module_end
