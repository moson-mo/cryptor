# cryptor
## Simple GUI application for gocryptfs

[![GitHub release](https://img.shields.io/github/v/tag/moson-mo/cryptor.svg?label=release&sort=semver)](https://github.com/moson-mo/cryptor/releases)
[![build](https://img.shields.io/github/workflow/status/moson-mo/cryptor/build)](https://github.com/moson-mo/cryptor/actions)

cryptor is a simple GUI wrapper for [gocryptfs]("https://github.com/rfjakob/gocryptfs"), written in Vala using the GTK toolkit.  
It allows you to create an mount gocryptfs encrypted file systems via a graphical user interface.  
Settings and "Vaults" are stored in a configuration file.

[![Main window](https://github.com/moson-mo/cryptor/assets/screenshots/cryptor_main.png)]
[![Vault window](https://github.com/moson-mo/cryptor/assets/screenshots/cryptor_vault.png)]

#### How to build

- `git clone https://github.com/moson-mo/cryptor.git` (clone repo)
- `cd cryptor` (navigate to project folder)
- `meson build` (create build dir with meson)
- `meson compile -C build` (build project)
###
- Run with: `build/cryptor`


#### Dependencies

- gtk3
- glib2
- json-glib
- libgee
- gocryptfs