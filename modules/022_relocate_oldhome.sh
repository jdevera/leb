#!/usr/bin/env bash

MODULE_NAME='Old home directory backup relocation'
log_module_start

HOME_BACKUP_DIR="$HOME/.oldhome"
HOME_BACKUP_PROPER_DIR="$HOME/backup/oldhome"


is_dir $HOME_BACKUP_DIR || log_no_changes

is_dir $HOME_BACKUP_PROPER_DIR && \
	HOME_BACKUP_PROPER_DIR="${HOME_BACKUP_PROPER_DIR}_$(date +%Y%M%d%H%M%S)"
mv $HOME_BACKUP_DIR $HOME_BACKUP_PROPER_DIR

log_module_end

