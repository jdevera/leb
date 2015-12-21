#!/usr/bin/env bash

MODULE_NAME='Initial packages'

if distro_has_gui
then
    vim=vim-gnome
else
    vim=vim-nox
fi

module_packages git aptitude wget curl gawk sed $vim
