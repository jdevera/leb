# LEB: Linux Environment Bootstrapper

This tool sets up a fresh Linux environment with all my preferences an customisations.

It does so through the execution of a series of specialised modules that perform the various tasks.

Module execution is designed to be idempotent, so the bootstrapper can be run on an already configured box to apply only the changes that have not already been applied.

The bootstrapper provides all modules with a useful set of functions so that writing modules should be relatively easy.

Note that this distribution is provided with a set of very personal choices, feel free to fork and customise :).


## Modules

These are the modules currently included:

 * Passwordless sudo
 * Git PPA
 * Initial packages
 * Home directory backup
 * Home directory structure
 * Old home directory backup relocation
 * XDG Directories
 * GTK Directory bookmarks
 * Shared Dotfiles
 * Bashmarks
 * Misc Scripts
 * Git tools
 * Packaged fonts
 * TTF fonts
 * Packaged applications
 * Ack-grep renaming
 * Dummy module


## LICENSE

This software is distributed under the MIT license, see LICENSE file for details.
