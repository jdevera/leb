#!/usr/bin/env bash

MODULE_NAME='Add PPAs'


declare -A PPAS
PPAS['ppa:nmi/vim-snapshots']='Vim Snapshots'
PPAS['ppa:git-core/ppa']='Git'

module_ppas
