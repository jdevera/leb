#!/usr/bin/env bash

MODULE_NAME='Git tools'

log_module_start

load_prefix_dirs

LOCAL_BASH_DIR="$HOME/.bash.d/local/after"

changes=false

# git-wtf

if ! is_exec "$USER_BIN_DIR/git-wtf"
then
    log_info "Installing git-wtf"
    program_is_available ruby || package_install ruby
    download_file_to "http://git-wt-commit.rubyforge.org/git-wtf" "$USER_BIN_DIR"
    chmod +x $USER_BIN_DIR/git-wtf
    is_exec $USER_BIN_DIR/git-wtf && changes=true
fi


install_hub()
{
    local plat='386'
    [[ $(getconf LONG_BIT) == '64' ]] && plat='amd64'
    local url="$(curl -s https://api.github.com/repos/github/hub/releases/latest |
        grep "download.*linux-${plat}" | sed 's/.*"\(https:.*\)"/\1/')"
    local filename="$(basename "$url")"
    local hubdir="$USER_SHARE_LIB_DIR/hub"
    local distpath="$hubdir/$filename"

    # Get the tarball
    if ! is_file "$distpath"
    then
        create_dir "$hubdir"
        log_info "Hub: Downloading distribution"
        download_file_to "$url" "$hubdir"
    fi
    if ! is_file "$distpath"
    then 
        log_fatal "Hub: Could not download"
    fi

    # Now it is downloaded, untar
    log_info "Hub: Unpacking"
    local dirname="$(tar tf "$distpath" | head -1)"
    local dirpath="$hubdir/$dirname"
    tar -C "$hubdir" -x -f "$distpath"

    # Make links
    log_info "Hub: Setting up"
    local binpath="$USER_BIN_DIR/hub"
    rm -f "$binpath"

    command ln -s "$dirpath/hub" "$binpath"

    # Install bash completion
    command ln -s "$dirpath/etc/hub.bash_completion.sh" "$LOCAL_BASH_DIR/"
    "$binpath" alias -s > "$LOCAL_BASH_DIR/hub.alias.sh"

}


if ! is_exec "$USER_BIN_DIR/hub"
then
    log_info "Installing hub"
    install_hub
    is_exec $USER_BIN_DIR/hub && changes=true
fi

$changes || log_no_changes


log_module_end
