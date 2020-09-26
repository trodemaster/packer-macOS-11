# packer-macos-11

This is very rough beginnings of a packer template for macOS 11 with VMware fusion 12.

## What's working
* Booting the VM from a macos install .iso
* Using voiceover and boot commands to open terminal.app !!
* Formatting the disk
* Starting the installer

## What's needed
* Post install pkgs
  * Create User (kinda have one)
  * Enable ssh system settings
  * Get rid of setup gui after boot