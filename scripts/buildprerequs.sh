#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# cleanup the old ish
sudo rm submodules/macadmin-scripts/*.dmg > /dev/null 2>&1 || true
sudo rm submodules/macadmin-scripts/*.iso > /dev/null 2>&1 || true
rm install_bits/*.iso > /dev/null 2>&1 || true
rm install_bits/*.shasum > /dev/null 2>&1 || true

# build the installer dmg
cd submodules/macadmin-scripts/
echo "Start OS installer download. You will need to enter sudo pass a couple times."
sudo ./installinstallmacos.py --seedprogram DeveloperSeed --ignore-cache
cd ../../

# mount the installer dmg
# setup gitignore for install_bits dir

hdiutil attach submodules/macadmin-scripts/Install_macOS*.dmg -noverify -mountpoint install_bits/dmg

# built an ios
# use this as a git submodule https://github.com/rtrouton/create_macos_vm_install_dmg/blob/master/create_macos_vm_install_dmg.sh
echo 1 | ./submodules/create_macos_vm_install_dmg/create_macos_vm_install_dmg.sh install_bits/dmg/Install\ macOS\ Big\ Sur.app install_bits/ || true

# ugly try to unmount any existing installer volumes
hdiutil detach install_bits/dmg -force

# cleanup dmg of installer 
rm install_bits/macOS_*_installer.dmg

# get iso name
ISO_NAME=$(basename install_bits/macOS_*_installer.iso)
FILE_NAME=$(cut -f 1 -d .<<<$ISO_NAME)

# output shasum
echo "Updating the shasum file"
shasum -a 256 install_bits/$ISO_NAME > install_bits/$FILE_NAME.shasum

exit 0
