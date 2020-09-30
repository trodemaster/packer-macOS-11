#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# build the installer dmg
cd submodules/macadmin-scripts/
echo "Start OS installer download"
sudo ./installinstallmacos.py --seedprogram DeveloperSeed
cd ../../

# mount the installer dmg
# setup gitignore for install_bits dir
hdiutil attach submodules/macadmin-scripts/Install_macOS*.dmg -noverify -mountpoint install_bits/dmg

# built an ios
# use this as a git submodule https://github.com/rtrouton/create_macos_vm_install_dmg/blob/master/create_macos_vm_install_dmg.sh
echo 1 | ./submodules/create_macos_vm_install_dmg/create_macos_vm_install_dmg.sh install_bits/dmg/Install\ macOS\ Big\ Sur\ Beta.app install_bits/

# ugly try to unmount any existing installer volumes
hdiutil detach install_bits/dmg

# output shasum
echo "remember to update the shasum in the packer template"
shasum -a 1 install_bits/macOS_1100_installer.iso

exit 0
