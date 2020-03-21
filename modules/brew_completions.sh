#!/usr/bin/env bash

MODULE_NAME='Homebrew completions'

log_module_start

LINE='source_dir /home/linuxbrew/.linuxbrew/etc/bash_completion.d/'

grep -q "$LINE" "$HOME/.bashrc" && log_no_changes

echo "$LINE" >> ~/.bashrc

log_module_end
