#!/usr/bin/env bash
# vim: set fdm=marker :

MODULE_NAME='Pipx Packages'

# Functions {{{
function pipx_is_installed()
{
    local package=$1
    # Resolve first time and let it leak
    [[ -z $_PIPX_VENV_DIR ]] &&
	_PIPX_VENV_DIR=$(pipx list | sed -n 's/venvs are in //p')

    is_dir "$_PIPX_VENV_DIR/$package"
}

function module_pipx_packages()
{
    local packages="$@"
    log_module_start
    reload_rc
    program_is_available pipx ||
	log_fatal "Could not find pipx"

    local INST=''
    for pkg in $packages
    do
        pipx_is_installed "$pkg" || INST="$INST $pkg"
    done
    [[ -z $INST ]] && log_no_changes
    log_info "Installing pip packages with pipx: $INST"
    for pkg in $INST
    do
	pipx install "$pkg" || log_error "Problem (pipx-)installing python package : $pkg"
    done
    log_module_end
}
# }}}
    

module_pipx_packages \
    pygments \
    colout2 \
    ;
