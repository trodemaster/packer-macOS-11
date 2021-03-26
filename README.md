# packer-macOS-11

This a packer template for macOS 11 built on VMware fusion 12. It's created using the newer packer hcl2 syntax which is relatively new. 

## Discussion thread for usage questions
Please see this hashicorp discuss thread for general usage questions & answers.

--> [**building-macos-11-x-vms-with-packer-and-fusion**](https://discuss.hashicorp.com/t/building-macos-11-x-vms-with-packer-and-fusion/) <--

## Key capabilities
* [scripts/buildprerequs.sh](scripts/buildprerequs.sh) creates a macOS installer .iso
* Using voiceover and boot commands to open terminal.app !!
* Downloading .pkg and script payloads to the recovery environment 
* Running the payload scripts that handle the install process
* packer user creation and autologin
* Clearing setup screens
* Enable remotelogin system settings
* Install Xcode & cli tools

## What's missing
I'll give the community a few months to sort out any reasonable options for these. Not interested in creating a full MDM workflow here.
* Get rid of feedback assistant popup for beta releases
* Approve VMware tools system extension and helper tool
* Profile to adjust a bunch of settings

## Building macOS 11 with this packer template
* Minimum packer version is 1.6.6
* VMware Fusion 12.0 or greater

## Update submodules
After cloning this repo you must pull down the submodules by running the following command from the root of the repo.

    git submodule update --init

## Prerequisite installer bits
I have imported two projects as submodules to create the needed macOS installer .iso. Running the [scripts/buildprerequs.sh](scripts/buildprerequs.sh) will call those to generate it. If you have a macOS 11 install .iso from some other method that will work as well. 

Thanks to all contributors of the following project that are imported as submodules:

* [create_macos_vm_install_dmg](https://github.com/rtrouton/create_macos_vm_install_dmg)
* [macadmin-scripts](https://github.com/grahampugh/macadmin-scripts)

With the customize build I'm installing Xcode 12.4. Grab both the latest Xcode .xip and matching command line tools installer dmg from [developer.apple.com](https://developer.apple.com). Toss them into the `install_bits` directory. 

Here is what your `install_bits` directory should look like to successfully build the full image:
```
install_bits/
├── Command_Line_Tools_for_Xcode_12.4.dmg
├── Xcode_12.4.xip
├── dmg
├── macOS_1120_installer.iso
└── macOS_1120_installer.shasum
```
NOTE: Filenames will change as newer versions are released

## Named builds
This template has three named builds `base`, `customize`, and `full`. The idea here is to split the lengthy process of macOS installation (baking the image) from the customization (frying the image). The `base` build does the os install with the vmware-iso builder and `customize` takes the output VM from that and customizes it. Re-running the customization quickly gets allows for quicker testing of that phase. The `full` build does all the steps at once and if you're not testing the customizations likely what you want to use. 

### Building the full image 
Builds the VM with all the options including Xcode

    packer build -force -only=full.vmware-iso.macOS_11 macOS_11.pkr.hcl

### Building the base image
Builds just the OS including VMware tools

    packer build -force -only=base.vmware-iso.macOS_11_base macOS_11.pkr.hcl

### Building the customize image
Useful for testing customizations without waiting for the whole OS to install.

    packer build -force -only=customize.vmware-vmx.macOS_11_customize macOS_11.pkr.hcl

### Input variables
This template uses input variables for a bunch of customizable values. Run packer inspect to see the defaults and what can be changed. See the docs for more options like creating a local variables file for customization https://www.packer.io/docs/from-1.5/variables . Creating a per machine variable file is also a good way to customize settings without editing the template or adding them to the command line.

    packer inspect macOS_11.pkr.hcl

## Adjust resources
If you need to adjust the cpu and RAM requirements to match your available resources. The variables can be edited in the template directly or passed on the cli. 

    packer build -force -only=full.vmware-iso.macOS_11 -var cpu_count="2" -var ram_gb="6" macOS_11.pkr.hcl

## Adjust timing
The process for starting the installer is very dependant on timing, unfortunately. If you run into unexpected results when the installer is starting up you may need to adjust the timing to match your system. Each release of the OS and specific hardware running the build can change the optimal timing. When in doubt add some time to these values to see if that fixes the issue. 

    packer build -force -only=full.vmware-iso.macOS_11 -var boot_key_interval_iso="400ms" -var boot_wait_iso="400s" -var boot_keygroup_interval_iso="5s" macOS_11.pkr.hcl

### Username & Password
The build process created a packer user with UID 502. It's recommended to login with that account and create a new user with the appropriate password when you start using the VM. 

    Username: packer
    Password: packer

Additionally the username is embeded in packages and scritps using durring the install process. Update scripts/setupsshlogin.sh, scripts/makepkgs.sh & packages/sesetupsshlogin.pkgproj

If you want to override the username and password they can be specified on the cli. Just remember to rebuild the packages listed to use the updated name.

    packer build -force -only=full.vmware-iso.macOS_11 -var user_password="vagrant" -var user_username="vagrant" macOS_11.pkr.hcl

### Customize computer serial and model
Variables have been added to customize board id, hardware model & serial number. This can be handy for testing DEP workflows.

    packer build -force -only=full.vmware-iso.macOS_11 -var board_id="Mac-27AD2F918AE68F61" -var serial_number="M00000000001" -var hw_model="MacPro7,1" macOS_11.pkr.hcl

### Install pre-release software updates
Apple has been seeding pre-release builds as software update only more often. To configure the installation of these pre-release versions pass the seed value you want to configure on the OS.

    packer build -force -only=full.vmware-iso.macOS_11 -var seeding_program="DeveloperSeed" macOS_11.pkr.hcl

### Apple GPU support on Big Sur hosts
If the host system is running macOS 11.x enabling the virtualized GPU provides a dramatic speedup of the GUI. This version of the template uses a post-processor to add the needed vmx config if the host OS is macOS 11.x . 

### Use downloaded version of VMware tools .iso
Sometimes newer versions of VMware tools are available from vmware.com . Check https://my.vmware.com/en/web/vmware/downloads/info/slug/datacenter_cloud_infrastructure/vmware_tools/11_x . If you want to use an iso besides the one included with VMware fusion then update the variable tools_path 
```
-var tools_path="install_bits/darwin.iso"
```