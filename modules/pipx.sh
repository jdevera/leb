#!/usr/bin/env bash

MODULE_NAME='Install Pipx'

log_module_start

program_is_available pipx && log_no_changes

python3 -m pip install pipx ||
    log_fatal "pipx: Could not install packages"

log_module_end
