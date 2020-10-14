# packer-macOS-11

This a packer template for macOS 11 built on VMware fusion 12. It's created using the newer hcl2 syntax wich curently has some known issues.  [HCL2: implementation list](https://github.com/hashicorp/packer/issues/9176) 

## What's working
* [scripts/buildprerequs.sh](buildprerequs.sh) creates a macOS installer .iso
* Using voiceover and boot commands to open terminal.app !!
* Downloading .pkg and script payloads to the recover environment 
* Running the payload scripts that handle the install process
* packer user creation and autologin
* Clearing setup screens
* Enable remotelogin system settings
* Install Xcode & cli tools
* softwareupdate

## What's missing
I'll give the comunity a few months to sort out any reasonable options for these. Not interested in creating a full MDM workflow here.
* Get rid of feedback assistant popup
* Approve VMware tools system extension and helper tool
* Profile to adjust a bunch of settings

## Building macOS 11 with this packer template
* Minimum packer version is 1.6.4 and not coded into the template due to [ min_packer_version JSON key not supported ](https://github.com/hashicorp/packer/issues/9284)
* VMware Fusion 12.0 or greater

## Upate submodules
After cloning this repo you must pull down the submodules by running the following command from the root of the repo.

    git submodule update --remote
    git submodule update --init --recursive

## Adjust resources
It's likely you will need to adjust the cpu and RAM requirements to match your available resources. Find the source definition for the named build your targeting and adjust the following values to size. Below is an example of workable lower specs. 
```
  cpus   = "2"
  cores  = "2"
  memory = "4096"
```

## Prerequesit installer bits
I have imported two projects as submodules to create the needed macOS installer .iso. Running the [scripts/buildprerequs.sh](buildprerequs.sh) will call those to generate it. If you have a macOS 11 install .iso from some other method that will work as well. 

Thanks to all contributors of the following project that are imported as submodlues!\
[create_macos_vm_install_dmg](https://github.com/rtrouton/create_macos_vm_install_dmg)\
[macadmin-scripts](https://github.com/munki/macadmin-scripts)

With the customize build I'm installing Xcode beta. Grab both the latest Xcode .xip and matching command line tools installer dmg from developer.apple.com. Toss them into the install_bits directory. 

Here is what your install_bits directory should look like to successfully build the full image. 
```
install_bits/
├── Command_Line_Tools_for_Xcode_12.2_beta_2.dmg
├── Xcode_12.2_beta_2.xip
├── dmg
├── macOS_1100_installer.iso
└── macOS_1100_installer.shasum
```

## Named builds
This template has three named builds base, customize and full. The idea here is splitting the lengthy process of macOS installation (baking the image) from the customization (frying the image). The base build does the os install with the vmware-iso builder and customize takes the output VM from that and customizes it. Re-running the customization quickly gets allows for quicker testing of that phase. The full build does all the steps at once and if you're not testing the customizations likely what you want to use. 

### Building the full image 
Builds the VM with all the options including Xcode

    packer build -only=full.vmware-iso.macOS_11 macOS_11.pkr.hcl

### Building the base image
Builds just the OS including VMware tools

    packer build -only=base.vmware-iso.macOS_11_base macOS_11.pkr.hcl

### Building the customize image
Useful for testing customizations without waiting for the whole OS to install.

    packer build -only=customize.vmware-vmx.macOS_11_customize macOS_11.pkr.hcl

### Build all for testing
Reminder for the author of this template on how to build em all at the same time.

    packer build -force -only=full.vmware-iso.macOS_11 macOS_11.pkr.hcl & packer build -force -only=base.vmware-iso.macOS_11_base macOS_11.pkr.hcl && packer build -only=customize.vmware-vmx.macOS_11_customize macOS_11.pkr.hcl

### Username & Password
The build process created a packer user with UID 502. It's recommened to login with that account and create a new user with appropriate password. 

    Username: packer
    Password: packer