#!/usr/bin/env bash

MODULE_NAME='Packaged fonts'

if distro_has_gui
then
    module_packages xfonts-terminus
else
    log_module_start
    log_info "GUI not available, skipping fonts installation"
    log_no_changes
fi

