# cryptor
## Simple GUI application for gocryptfs

[![GitHub release](https://img.shields.io/github/v/tag/moson-mo/cryptor.svg?label=release&sort=semver)](https://github.com/moson-mo/cryptor/releases)
[![build](https://img.shields.io/github/workflow/status/moson-mo/cryptor/build)](https://github.com/moson-mo/cryptor/actions)

cryptor is a simple GUI wrapper for [gocryptfs](https://github.com/rfjakob/gocryptfs), written in Vala using the GTK toolkit.  
It allows you to create and mount gocryptfs encrypted file systems via a graphical user interface.  
Settings and "Vaults" are stored in a configuration file.

![Main window](https://github.com/moson-mo/cryptor/raw/master/assets/screenshots/cryptor_main.png)  
![Vault window](https://github.com/moson-mo/cryptor/raw/master/assets/screenshots/cryptor_vault.png)

#### How to build

- `git clone https://github.com/moson-mo/cryptor.git` (clone repo)
- `cd cryptor` (navigate to project folder)
- `meson build` (create build dir with meson)
- `meson compile -C build` (build project)
###
- Run with: `build/cryptor`

#### How to install

Once built, use `meson install -C build` to install the application.

For Arch based distributions an AUR package is available here: [cryptor](https://aur.archlinux.org/packages/cryptor/)

#### Configuration

On the first run, save your configuration file here:  
`~/.config/cryptor/cryptor.config`

This file will be loaded automatically when cryptor starts...

#### Dependencies

- gtk3
- glib2
- json-glib
- libgee
- gocryptfs