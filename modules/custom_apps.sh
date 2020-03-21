#!/usr/bin/env bash
# vim: fdm=marker :

MODULE_NAME='Custom installation apps'

function has_command()
{
    type "$1" >& /dev/null
}

log_module_start

changes=false

# FZF {{{
if ! has_command fzf
then
    function install_fzf()
    {
	git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf ||
	    log_fatal 'fzf: Could not clone repo'
	$HOME/.fzf/install \
	    --xdg --key-bindings --completion --no-update-rc \
	    --no-zsh --no-fish ||
	    log_fatal 'fzf: Could not install'
	echo '# FZF' >> $HOME/.bashrc
	echo 'maybe_source_file "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash' >> $HOME/.bashrc
    }
    install_fzf && changes=true
fi

# FZF END }}}


$changes || log_no_changes
log_module_end
