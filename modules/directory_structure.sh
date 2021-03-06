#!/usr/bin/env bash

MODULE_NAME='Home directory structure'
log_module_start

DIR_LIST_FILE='directories.data'

function get_directories()
{
	set_var "$1" "$(cat $DIR_LIST_FILE)"
}

function home_is_empty()
{
    is_dir "$HOME" && [[ -z $(ls "$HOME") ]]
}

function has_directories()
{
	local directories='backup comms devel doc media other'
	for dir in $directories
	do
		is_dir "$HOME/$dir" || return 1
	done
	return 0
}

function create_all_home_dirs()
{
	local dirs
	get_directories dirs
	for dir in $dirs
	do
		log_info "Creating directory $dir"
		create_dir "$HOME/$dir"
	done
}



# The backup module should have run before this. So we expect home to be empty
home_is_empty || log_no_changes

create_all_home_dirs

log_module_end
