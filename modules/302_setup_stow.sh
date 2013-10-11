#!/usr/bin/env bash

MODULE_NAME='GNU Stow Setup'

log_module_start

STOW_BASE_DIR=/opt/stow
PACKAGES_DIR=$STOW_BASE_DIR/packages
SOURCES_DIR=$STOW_BASE_DIR/packages
STOW_TARGET=/usr/local

changed=false

package_is_installed stow || log_fatal "Package stow is not installed"


if ! is_dir "$PACKAGES_DIR"; then
    SUDO=sudo create_dir "$PACKAGES_DIR" && changed=true
    sudo chown ${USER}.${USER} $PACKAGES_DIR
fi
if ! is_dir "$SOURCES_DIR"; then
    SUDO=sudo create_dir "$SOURCES_DIR" && changed=true
    sudo chown ${USER}.${USER} $SOURCES_DIR
fi

if ! is_file ~/.stowrc
then
    sed 's/^\s*//' <<EORC > ~/.stowrc
        --dir=$PACKAGES_DIR
        --target=$STOW_TARGET
EORC
    changed=true
fi


$changed || log_no_changes

log_module_end
