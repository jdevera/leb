# LEB: Linux Environment Bootstrapper

LEB sets up a fresh Linux environment with many of my preferences an customisations.

It does so through the execution of a series of specialised modules that perform the various tasks.

Module execution is designed to be **idempotent**, so the bootstrapper can be run on an already configured box to apply only the changes that have not already been applied.

LEB provides modules with a useful set of functions to make writing them easier.

Note that this distribution is provided with a set of very personal choices, feel free to fork and customise :).

## Quick Setup

```bash
cd /tmp
wget -O - https://github.com/jdevera/leb/archive/master.tar.gz | tar xzvf -
cd leb-master
./bootstrap
```

## Running from within the home directory

Part of what LEB does involves restructuring the user's home directory. Because of the LEB will refuse to run from the home directory. If you want to bypass this, define and export  an environment variable called `OVERRIDE_MODULES_DIR`:

```bash
OVERRIDE_MODULES_DIR=1 ./bootstrap
```

## Modules

These are the modules currently included:

 * Passwordless sudo
 * Pre-PPA packages
 * Add PPAs
 * Initial APT packages
 * Packaged applications
 * Home directory backup
 * Home directory structure
 * Old home directory backup relocation
 * XDG Directories
 * GTK Directory bookmarks
 * Whitelist Unity Systray
 * Shared Dotfiles
 * Homebrew
 * Homebrew completions
 * Homebrew packages
 * Custom installation apps
 * Bashmarks
 * Misc Scripts
 * Git tools
 * Packaged fonts
 * TTF fonts
 * Ack-grep renaming
 * GNU Stow Setup
 * Dummy module

## LICENSE

This software is distributed under the MIT license, see LICENSE file for details.
