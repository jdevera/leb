#!/usr/bin/env bash

MODULE_NAME='Old home directory backup relocation'
log_module_start

HOME_BACKUP_DIR="$HOME/.oldhome"
HOME_BACKUP_PROPER_DIR="$HOME/backup/oldhome/$(date +%Y%M%d%_H%M%S)"


is_dir "$HOME_BACKUP_DIR" || log_no_changes
dir_is_empty "$HOME_BACKUP_DIR" && log_no_changes

mv "$HOME_BACKUP_DIR" "$HOME_BACKUP_PROPER_DIR"

log_module_end

