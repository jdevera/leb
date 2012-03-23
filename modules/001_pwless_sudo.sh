#!/usr/bin/env bash

MODULE_NAME='Passwordless sudo'

log_module_start

NOPASS_FILE='/etc/sudoers.d/admin_nopass'

is_file $NOPASS_FILE && log_no_changes


echo '%admin ALL=(ALL) NOPASSWD: ALL' | sudo tee /tmp/nopass_file > /dev/null
sudo chmod 0440 /tmp/nopass_file
sudo mv /tmp/nopass_file $NOPASS_FILE

log_module_end

