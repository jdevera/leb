#!/usr/bin/env bash

MODULE_NAME='Ack-grep renaming'

log_module_start

ACK_BIN='/usr/bin/ack'
ACK_MAN='/usr/share/man/man1/ack.1p.gz'

changed=false

function divert()
{
    sudo dpkg-divert --local --divert "$1" --rename --add "$2" | indent
    changed=true
}

package_is_installed ack-grep || log_fatal "Package ack-grep is not installed"

is_file "$ACK_BIN" || divert "$ACK_BIN" /usr/bin/ack-grep
is_file "$ACK_MAN" || divert "$ACK_MAN" /usr/share/man/man1/ack-grep.1p.gz

$changed || log_no_changes

log_module_end
