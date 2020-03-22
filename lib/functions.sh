#!/bin/bash -p

# LOGGING {{{
function echoe() 
{ 
    echo $* 1>&2
}
function log_info()
{
    echo "    $@"
}
function log_error()
{
    echoe "$(colored light_red ERROR): $@"
}
function log_fatal()
{
    echoe "$(colored light_red FATAL): $@"
    exit 1
}
function print_module_name()
{
    local modname_color=white
    local modlabel_color=light_blue
    echo "$(colored $modlabel_color Module): $(colored $modname_color $MODULE_NAME)"
}
function log_module_start()
{
    print_module_name
}
function log_module_end()
{
    local color outcome
    if [[ $1 == '__noop' ]]
    then
        echo -en "\033[F" # Go back to the previous line
        color=green
        outcome=NOOP
    else
        color=light_green
        outcome=DONE
    fi
    echo -en ".................................................[$(colored $color $outcome)]\033[0G"
    print_module_name
    [[ $outcome == 'DONE' ]] && echo -e "\033[F        "

}
function log_no_changes()
{
    if [[ $1 == 'force' ]]
    then
        echo -n "    $(colored green NO OP): No changes needed. "
        echo "Forced execution."
    else
        # echo "Bailing out."
        log_module_end __noop
        exit 0
    fi
}
function indent()
{
    sed 's/^/    /'
}
# }}}
# PRESENTATION {{{

function color()
{
   local COLOR_NONE="\033[m"
   local color=$COLOR_NONE
   case "$1" in
      black)        color="\033[0;30m" ;; 
      red)          color="\033[0;31m" ;; 
      green)        color="\033[0;32m" ;; 
      brown)        color="\033[0;33m" ;; 
      blue)         color="\033[0;34m" ;; 
      purple)       color="\033[0;35m" ;; 
      cyan)         color="\033[0;36m" ;; 
      light_gray)   color="\033[0;37m" ;; 
      dark_gray)    color="\033[1;30m" ;; 
      light_red)    color="\033[1;31m" ;; 
      light_green)  color="\033[1;32m" ;; 
      yellow)       color="\033[1;33m" ;; 
      light_blue)   color="\033[1;34m" ;; 
      light_purple) color="\033[1;35m" ;; 
      light_cyan)   color="\033[1;36m" ;; 
      white)        color="\033[1;37m" ;; 
   esac
   echo -e "$color"
}
function colored()
{
    local color=$1
    shift
    echo -e $(color $color)$*$(color none)
}
# }}}
# PACKAGE MANAGEMENT {{{
function brew_is_installed()
{
   local package=$1
    program_is_available brew || log_fatal "Can't find brew"
    program_is_available jq || log_fatal "Can't find jq"
    [[ $(brew info --json "$package" | jq "map(select(.installed != [])) == []") == 'false' ]]
}
function package_is_installed()
{
    local package="$1"
    program_is_available dpkg || log_fatal "Can't find dpkg"
    dpkg -s $package 2>/dev/null | grep -q 'Status:.*installed'
}
function package_update_sources()
{
    log_info "Updating package sources"
    sudo apt-get -q=10 update
}
function package_install()
{
    package_get_apt_program apt_program
    sudo DEBIAN_FRONTEND=noninteractive $apt_program -y -q=2 install "$@" | indent
    return ${PIPESTATUS[0]}
}
function package_install_from_url()
{
    local name=$1
    local package_url=$2
    local tmp_dir=''
    create_temp_dir "$name" tmp_dir
    trap "cd /tmp && rm -rf \"$tmp_dir\"" EXIT
    download_file_to "$package_url" "$tmp_dir" ||
           log_fatal "$name: Could not download package"
    package_install "$tmp_dir/"*.deb ||
       log_fatal "$name: Could not install package"
}
function package_has_ppa()
{
    local ppa="$(cut -d: -f2 <<<$1)"
    grep -q "^deb .*ppa.launchpad.net/$ppa/" /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null
}
function package_add_repository()
{
    local source="$1"
    program_is_available add-apt-repository ||
        log_fatal "Can't add package source, add-apt-repository is missing"
    log_info "Adding package source: $source"
    sudo add-apt-repository --yes "$source" | indent ||
       log_fatal "Could not add package source $source"
}
function package_add_ppa()
{
    local ppa="$1"
    program_is_available add-apt-repository || \
        log_fatal "Can't add PPAs, add-apt-repository is missing"
    log_info "Adding PPA: $ppa"
    sudo add-apt-repository --yes "$ppa" || log_fatal "Could not add PPA $ppa"
    package_update_sources
}
function package_get_apt_program()
{
    local __apt_program=apt-get
    if ! program_is_available apt-get; then
        log_fatal "Can't find any package installer"
    fi
    set_var "$1" "$__apt_program"
}
function package_add_signature()
{
    local url=$1
    curl -s "$url" | sudo apt-key add - &>/dev/null
}
# }}}
# SHELL UTILS {{{
function set_var()
{
    eval "$1='$2'"
}
function assert()
{
    local msg="$1"
    shift
    local funct="$1"
    shift
    eval "$funct $@" || log_fatal $msg
}
function program_is_available()
{
    [[ -z $1 ]] && return 1;
    type -t "$1" > /dev/null
}
function export_all_functions()
{
	for funct in $(sed -n 's/^function\s\+\([^(]\+\).*/\1/p' "$BASH_SOURCE")
	do
		export -f $funct
	done
}
function is_exec()
{
    [[ -x $1 ]]
}
#}}}
# FILES UTILS {{{
function is_file()
{
    [[ -f $1 ]]
}
function download_file_to()
{
    local url="$1"
    local dir="$2"
    is_dir "$dir" || log_fatal "Can't download file to $dir. Directory not found"
    program_is_available wget || log_fatal "Can't find wget"
    wget --no-check-certificate -q -P "$dir" "$url"
}
#}}}
# DIRECTORIES UTILS {{{
function is_dir()
{
    [[ -d $1 ]]
}
function create_dir()
{
    is_dir "$1" && return 1
    $SUDO mkdir -p "$1"
}
function create_temp_dir()
{
    local tpl="$1"
    local var="$2"
    local dir=$(mktemp --directory "${tpl}_XXXXXX" --tmpdir)
    set_var "$var" "$dir"
}
function dir_is_empty()
{
    is_dir $1 && [[ -z $(ls -A "$1") ]]
}
function remove_dir()
{
    is_dir "$1" && rm -rf "$1" || return 1
}
function remove_dir_if_empty()
{
    dir_is_empty "$1" && remove_dir "$1"
}
function link_all_programs()
{
    local src="$1"
    local dest="$2"
    local destfile
    for file in "$src"/*
    do
        [[ ! -x $file ]] && continue
        destfile="$dest/$(basename $file)"
        [[ -h $destfile ]] && rm -f "$destfile"
        is_file "$destfile" && continue
        ln -fs "$file" "$dest"/
    done
}
function all_programs_linked()
{
    local src="$1"
    local dest="$2"
    local file basefile
    for file in "$src"/*
    do
        [[ ! -x $file ]] && continue
        destfile="$dest/$(basename $file)"
        [[ ! -h $destfile ]] && return 1
        [[ $(readlink -es "$destfile") != $(readlink -es "$file") ]] && return 1
    done
    return 0
}
#}}}
# FONTS {{{

function get_fonts_dir()
{
    local class="$2"
    set_var "$1" "$HOME/.fonts/$class"
}
function font_ttf_install()
{
    local url="$1"
    local class="$2" # directory to use
    local revert_mkdir=false
    local fonts_dir
    get_fonts_dir fonts_dir "$class"
    create_dir "$fonts_dir" && revert_mkdir=true
    if [[ $url = http://* ]]; then
        download_file_to "$url" "$fonts_dir"
    elif is_file "$url"; then
        cp "$url" "$fonts_dir/"
    else
        log_fatal "Don't know how to handle font location $url"
        $revert_mkdir && remove_dir "$fonts_dir"
    fi

    # Update font cache
    fc-cache -f

    $revert_mkdir && remove_dir_if_empty "$fonts_dir"
    return 0
}
function font_ttf_is_installed()
{
    local file="$1"
    local class="$2" # directory to use
    local fonts_dir
    get_fonts_dir fonts_dir "$class"
    is_file "$fonts_dir/$file"
}
#}}}
# MODULE HELPERS {{{

# A module that installs a single PPA, passed as parameter
function module_ppa()
{
    local ppa="$1"
    log_module_start
    package_has_ppa "$ppa" && log_no_changes
    program_is_available add-apt-repository || package_install software-properties-common
    package_add_ppa "$ppa"
    log_module_end
}

# A module that installs a series of PPAs, as they appear in the PPAS
# associative array, where the keys are the PPA specs and the values are the
# descriptions to show.
function module_ppas()
{
    local changes=false
    log_module_start
    for ppa in "${!PPAS[@]}"
    do
        description="${PPAS[$ppa]}"
        if ! package_has_ppa "$ppa"; then
            program_is_available add-apt-repository || package_install software-properties-common
            echo "Adding $description PPA"
            package_add_ppa "$ppa"
            changes=true
        fi
    done
    $changes || log_no_changes
    log_module_end
}

# A module to install a series of packages, as they are given in the parameters
function module_packages()
{
    local packages="$@"
    log_module_start
    local INST=''
    for pkg in $packages
    do
        package_is_installed "$pkg" || INST="$INST $pkg"
    done

    [[ -z $INST ]] && log_no_changes
    package_update_sources
    log_info "Installing packages: $INST"
    for pkg in $INST
    do
        package_install "$pkg" || log_error "Problem installing $pkg"
    done
    log_module_end
}
function module_brew_packages()
{
    local packages="$@"
    log_module_start
    local INST=''
    for pkg in $packages
    do
        brew_is_installed "$pkg" || INST="$INST $pkg"
    done

    [[ -z $INST ]] && log_no_changes
    log_info "Installing brew packages: $INST"
    for pkg in $INST
    do
        brew install "$pkg" || log_error "Problem installing $pkg"
    done
    log_module_end
}
# }}}
# CONFIGURATION {{{
function load_prefix_dirs()
{
    USER_PREFIX_DIR="$HOME/other/run"
    USER_SHARE_LIB_DIR="$USER_PREFIX_DIR/share/lib"
    USER_BIN_DIR="$USER_PREFIX_DIR/bin"
}

function distro_has_gui()
{
   package_is_installed xinit
}
# }}}
# SYSTEM {{{
function get_architecture()
{
   local name32=${1:-i386}
   local name64=${1:-amd64}

   if uname -a | grep -q x86_64
   then
      echo $name64
   else
      echo $name32
   fi
}
# }}}
# INTERNET {{{
function github_latest_release()
{
   local project=$1
   local url="https://api.github.com/repos/$project/releases/latest"
   curl -s "$url"
}
# }}}


[[ 'EXPORT' == $1 ]] && export_all_functions


# vim: fdm=marker :
