#!/usr/bin/env bash

MODULE_NAME='TTF fonts'

log_module_start

typeset -a FONT_URLS
FONT_URLS=(
'http://www.gringod.com/wp-upload/software/Fonts/Monaco_Linux.ttf'
)

did_install=false
for url in ${FONT_URLS[@]}
do
    if ! font_ttf_is_installed "$(basename $url)"
    then
        log_info "Installing $(basename $url)" | indent
        font_ttf_install $url && did_install=true
    fi
done

$did_install || log_no_changes

log_module_end
