#!/usr/bin/env bash

MODULE_NAME='Passwordless sudo'

log_module_start

NOPASS_FILE='/etc/sudoers.d/sudoers_nopass'

is_file $NOPASS_FILE && log_no_changes

function sudoers_group()
{
    local userinfo="$(id -Gn)"
    local group
    if echo "$userinfo" | grep -q '\bsudo\b'
    then
        echo '%sudo'
        return
    elif echo "$userinfo" | grep -q '\badmin\b'
    then
        echo '%admin'
        return
    else
        id -un
    fi
}

echo "$(sudoers_group) ALL=(ALL) NOPASSWD: ALL" | sudo tee /tmp/nopass_file > /dev/null
sudo chmod 0440 /tmp/nopass_file
sudo mv /tmp/nopass_file $NOPASS_FILE

log_module_end

