#!/usr/bin/env bash

MODULE_NAME='Home directory backup'
log_module_start


HOME_BACKUP_DIR="$HOME/.oldhome"

function has_all_home_dirs()
{
	local directories='backup comms devel doc media other'
	for dir in $directories
	do
		is_dir "$HOME/$dir" || return 1
	done
	return 0
}

function backup_home()
{
	create_dir "$HOME_BACKUP_DIR"
	mv $HOME/* $HOME_BACKUP_DIR/
}


# If we already have the good structure, do nothing
has_all_home_dirs && log_no_changes

backup_home

log_module_end
