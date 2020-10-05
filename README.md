# packer-macos-11

This is the beginnings of a packer template for macOS 11 with VMware fusion 12. 

## What's working
* [scripts/buildprerequs.sh](buildprerequs.sh) working with imported submodules
* Booting the VM from a macos install .iso
* Using voiceover and boot commands to open terminal.app !!
* Formatting the disk
* Starting the installer
* packer user creation and autologin
* Clearing setup screens
* Enable remotelogin system settings
* Install Xcode & cli tools
* softwareupdate

## What's missing
* Get rid of feedback assistant popup
* export fusion happy .ova
* Profile to adjust a bunch of settings

## Building macOS 11 with this packer template
* Minimum packer version is 1.6.4 and not coded into the template due to https://github.com/hashicorp/packer/issues/9284
* VMware Fusion 12.0 or greater

Prerequesits and install bits
I have imported two projects as submodules to create the needed macOS installer .iso. Running the [scripts/buildprerequs.sh](buildprerequs.sh) will call those to generate it. If you have a macOS 11 install .iso from some other method that will work as well. 

With the customize build I'm installing Xcode beta. Grab both the latest Xcode .xip and matching command line tools installer dmg from developer.apple.com. Toss them into the install_bits directory. 

This template has two named builds base and customize. The idea here is splitting the lenghthy process of macOS installation (baking the image) from the customization (frying the image). The base build does the os instal with the vmware-iso builder and customize takes the output VM from that and customizes it. Re-running the customization quickly gets allows for quicker testing of that phase. Eventually I'll add one that combines them both. 

Building the base macOS image
packer build -only=base.vmware-vmx.macOS_11 -force macOS11.pkr.hcl

Building the customize image
packer build -only=customize.vmware-vmx.macOS_11 -force -on-error=abort macOS11.pkr.hcl