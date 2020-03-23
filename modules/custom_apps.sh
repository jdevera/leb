#!/usr/bin/env bash
# vim: fdm=marker :

MODULE_NAME='Custom installation apps'

log_module_start

load_prefix_dirs

changes=false

# FZF {{{
if ! program_is_available fzf
then
    function install_fzf()
    {
	log_info Installing fzf
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

# FD {{{
if ! program_is_available fd
then
    function install_fd()
    {
	log_info Installing fd
	local project='sharkdp/fd'
	local arch=$(get_architecture)
	local package_url=$(github_latest_release "$project" |
	    jq -r ".assets[] | select(.name | test(\"fd_.+${arch}.deb\")) | .browser_download_url") ||
		log_fatal 'fd: Could not get package URL'
	local tmp_dir=''
	create_temp_dir fd tmp_dir
	trap "cd /tmp && rm -rf "$tmp_dir"" EXIT
	download_file_to "$package_url" "$tmp_dir" ||
		log_fatal 'fd: Could not download package'
	package_install "$tmp_dir"/*.deb ||
		log_fatal 'fd: Could not install package'

    }

    install_fd && changes=true
fi

# FD END }}}

# PUP {{{
if ! program_is_available pup
then
    function install_pup()
    {
	log_info Installing pup
	local project='ericchiang/pup'
	local arch=$(get_architecture)
	local package_url=$(github_latest_release "$project" |
	    jq -r ".assets[] | select(.name | test(\"pup_.*_linux_amd64.zip\")) | .browser_download_url") ||
		log_fatal 'pup: Could not get package URL'
	local tmp_dir=''
	create_temp_dir pup tmp_dir
	trap "cd /tmp && rm -rf "$tmp_dir"" EXIT
	download_file_to "$package_url" "$tmp_dir" ||
		log_fatal 'pup: Could not download package'
	{
	    cd "$tmp_dir" &&
		unzip *.zip &&
		cp "$tmp_dir/pup" "$USER_BIN_DIR/pup" &&
		chmod +x "$USER_BIN_DIR/pup"
	} ||
	    log_fatal 'pup: Could not install downloaded package'
    }

    install_pup && changes=true
fi

# PUP END }}}

# VAGRANT {{{
if ! program_is_available vagrant
then
    function install_vagrant()
    {
	log_info Installing vagrant
	program_is_available pup || log_fatal 'vagrant: Requires pup to install'
	local releases_url='https://www.vagrantup.com/downloads.html'
	local arch=$(get_architecture i686 x86_64)
	local package_url=$(curl -s "$releases_url" |
	    pup "a[data-os=debian][data-arch=$arch][href] attr{href}") ||
		log_fatal 'vagrant: Could not get package URL'
	package_install_from_url vagrant "$package_url"
    }

    install_vagrant && changes=true
fi

# VAGRANT END }}}

# VIRTUALBOX {{{
if ! program_is_available virtualbox
then
    function install_virtualbox()
    {
	log_info Installing virtualbox
	local ubuntu_codename=$(lsb_release -cs)
	local sources_line="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $ubuntu_codename contrib"

	package_add_signature 'https://www.virtualbox.org/download/oracle_vbox_2016.asc' ||
	    log_fatal "virtualbox: Could not add package source signature"
	package_add_signature 'https://www.virtualbox.org/download/oracle_vbox.asc' ||
	    log_fatal "virtualbox: Could not add package source signature"
	package_add_repository "$sources_line"
	package_install virtualbox-6.1 ||
	    log_fatal "virtualbox: Could not install package"

    }

    install_virtualbox && changes=true
fi

# VIRTUALBOX END }}}

# DOCKER {{{
if ! program_is_available docker
then
    function install_docker()
    {
	log_info Installing docker
	local ubuntu_codename=$(lsb_release -cs)
	local sources_line="deb [arch=amd64] https://download.docker.com/linux/ubuntu $ubuntu_codename stable"

	package_add_signature 'https://download.docker.com/linux/ubuntu/gpg' ||
	    log_fatal "docker: Could not add package source signature"
	package_add_repository "$sources_line"
	package_install docker-ce docker-ce-cli containerd.io ||
	    log_fatal "docker: Could not install packages"

    }

    install_docker && changes=true
fi

# DOCKER END }}}

$changes || log_no_changes
log_module_end
