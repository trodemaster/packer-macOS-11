# packer-macos-11

This is very rough beginnings of a packer template for macOS 11 with VMware fusion 12. 

## What's working
* [buildprerequs.sh] working with imported submodules
* Booting the VM from a macos install .iso
* Using voiceover and boot commands to open terminal.app !!
* Formatting the disk
* Starting the installer
* packer user creation and autologin
* Learing setup screens

## What's missing
* Post install pkgs
  * Enable remotelogin system settings
  * Get rid of feedback assistant popup
* get shell provisioners working
* Install Xcode & cli tools
* softwareupdate
* export fusion happy .ova
