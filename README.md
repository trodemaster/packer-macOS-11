# packer-macOS-11

This a packer template for macOS 11 or 12 built on VMware fusion 12. It's created using the newer packer hcl2 syntax. These templates only support x86 platform as Apple has introduced breaking changes with the new Applesilicon platform.

## Discussion thread for usage questions
See this hashicorp discuss thread for general usage questions & answers.

--> [**building-macos-12-x-vms-with-packer-and-fusion**](https://discuss.hashicorp.com/t/building-macos-12-x-vms-with-packer-and-fusion/31069) <--

## Key capabilities
* [scripts/macosiso.sh](scripts/macosiso.sh) creates a macOS installer via mist
* Using voiceover and boot commands to open terminal.app !!
* Downloading .pkg and script payloads to the recovery environment 
* Running the payload scripts that handle the install process
* packer user creation and autologin
* Clearing setup screens
* Enable remotelogin system settings
* Install Command Line Developer tools
* Approve VMware tools Kernel Extensions
## Building macOS 11+ with this packer template
* Minimum packer version is 1.7.x
* VMware Fusion 12.0 or greater



## Prerequisite installer bits
The current version of this project now uses mist to create macOS x86 installer iso files. Grab a copy from https://github.com/ninxsoft/Mist and make sure it's available on your path before the next steps. 

For generating the boot iso and matching shasum run the macosiso.sh script providing the OS major version you want to create. Generating the iso directly with mist also works. You will just need to povide packer the sha256 via input variable.

    scripts/macosiso.sh 12.2

With the customize build I'm installing Xcode command line tools 13. Grab both the latest Xcode Command Line tools installer dmg from [developer.apple.com](https://developer.apple.com). Toss them into the `install_bits` directory. 

Here is what your `install_bits` directory should look like to successfully build the full image:
```
install_bits/
├── Command_Line_Tools_for_Xcode_13.2.dmg
├── macOS_12.2.1_21D62.iso
└── macOS_12.2.1_21D62.shasum
```
NOTE: Filenames will change as newer versions are released

## Named builds
This template has two named builds `base` and `customize`. The idea here is to split the lengthy process of macOS installation (baking the image) from the customization (frying the image). The `base` build does the os install with the vmware-iso builder and `customize` takes the output VM from that and customizes it. Re-running the customization quickly gets allows for quicker testing of that phase.


### Building the base image
Builds just the OS including VMware tools

    packer build -force -only=base.vmware-iso.macOS macOS.pkr.hcl

### Building the customize image
Useful for testing customizations without waiting for the whole OS to install.

    packer build -force -only=customize.vmware-vmx.macOS macOS.pkr.hcl

### Input variables
This template uses input variables for a bunch of customizable values. Run packer inspect to see the defaults and what can be changed. See the docs for more options like creating a local variables file for customization https://www.packer.io/docs/templates/hcl_templates/variables . 

    packer inspect macOS_11.pkr.hcl

## Varibles file
The recommended way to tweak settings in the template is by creating a packer variables file. Any of the Input variables can be adjusted this way. Specify a var file with the build commands to change the defaults.

    packer build -force -only=customize.vmware-vmx.macOS -var-file bigsur.pkrvars.hcl macOS.pkr.hcl

Here is an example var file named bigsur.pkrvars.hcl
```
boot_key_interval_iso = "20ms"
boot_wait_iso = "150s"
boot_keygroup_interval_iso = "150ms"
seeding_program = "none" # PublicSeed  CustomerSeed DeveloperSeed none
xcode_cli = "install_bits/Command_Line_Tools_for_Xcode_13.dmg"
iso_filename = "install_bits/macOS_1160_installer.iso"
iso_file_checksum = "file:install_bits/macOS_1160_installer.shasum"
ram_gb = "8"
cpu_count = "2"
tools_path = "install_bits/darwin.iso"
macos_version = "11.6"
```

## Adjust resources
If you need to adjust the cpu and RAM requirements to match your available resources. 

    cpu_count="2"
    ram_gb="6"

## Adjust timing
The process for starting the installer is very dependant on timing, unfortunately. If you run into unexpected results when the installer is starting up you may need to adjust the timing to match your system. Each release of the OS and specific hardware running the build can change the optimal timing. When in doubt add some time to these values to see if that fixes the issue. 

    boot_key_interval_iso="400ms"
    boot_wait_iso="400s"
    boot_keygroup_interval_iso="5s"

### Username & Password
The build process created a packer user with UID 502. I recommended to login with that account and create a new user with the appropriate password when you start using the VM after the build. Customizing the user/pass has been simplified. Start by setting them in your variables file.

    user_username="packer2"
    user_password="packer3"

Additionally the username is embeded in packages and scritps using durring the install process. Run the helper script below to regenerate the user creation package. 

    scripts/makepkgs.sh packer2 packer3

### Customize computer serial and model
Variables have been added to customize board id, hardware model & serial number. This can be handy for testing DEP workflows.

    board_id="Mac-27AD2F918AE68F61"
    serial_number="M00000000001" 
    hw_model="MacPro7,1"

### Install pre-release software updates
Apple has been seeding pre-release builds as software update only more often. To configure the installation of these pre-release versions pass the seed value you want to configure on the OS.

    seeding_program="DeveloperSeed" 

Possible values are

    PublicSeed
    CustomerSeed
    DeveloperSeed
    none
### Apple GPU support on Big Sur hosts
If the host system is running macOS 11.x enabling the virtualized GPU provides a dramatic speedup of the GUI. This version of the template uses a post-processor to add the needed vmx config if the host OS is macOS 11.x+. 

### Use downloaded version of VMware tools .iso
Sometimes newer versions of VMware tools are available from vmware.com . Check https://vmware.com/go/tools . If you want to use an iso besides the one included with VMware fusion then update the variable tools_path 

    tools_path="install_bits/darwin.iso"

### Add your own config script
Additionally a new variable *bootstrapper_script* has been added. Using this is an easy way to add a few more commands to the build or pull down a script to extend the build process to your needs. I use it to install golang, macports and dotfiles via a script in another repo. See below for an example. 

```
bootstrapper_script = [ "curl https://raw.githubusercontent.com/gitusers/myconfig/main/bootstrap.sh -o bootstrap.sh",
"chmod +x bootstrap.sh",
"./bootstrap.sh" ]
```

### Simple wrapper script to run both base & customize builds 
Included is a simple wrapper script used to build the base image and then the customized image. It takes a single parameter that is a packer variable file. This simplifies the build process if you maintain multiple versions of macOS VMs. 

```
./build monterey.pkrvars.hcl
```