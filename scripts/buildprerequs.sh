#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# cleanup the old ish
sudo rm submodules/macadmin-scripts/*.dmg > /dev/null 2>&1 || true
sudo rm submodules/macadmin-scripts/*.iso > /dev/null 2>&1 || true
#rm install_bits/*.iso > /dev/null 2>&1 || true
#rm install_bits/*.shasum > /dev/null 2>&1 || true

# build the installer dmg
cd submodules/macadmin-scripts/
echo "Start OS installer download."
#sudo ./installinstallmacos.py --seedprogram DeveloperSeed --ignore-cache
# without seedprogram the script wont add the prerelease flag
sudo ./installinstallmacos.py --ignore-cache
cd ../../

# mount the installer dmg
hdiutil attach submodules/macadmin-scripts/Install_macOS*.dmg -noverify -mountpoint install_bits/dmg

# Create iso file by calling the following script
# use this as a git submodule https://github.com/rtrouton/create_macos_vm_install_dmg/blob/master/create_macos_vm_install_dmg.sh
INSTALL_APP=$(basename install_bits/dmg/Install*.app)
echo 1 | ./submodules/create_macos_vm_install_dmg/create_macos_vm_install_dmg.sh "install_bits/dmg/${INSTALL_APP}" install_bits/ #|| true

# ugly try to unmount any existing installer volumes
hdiutil detach install_bits/dmg -force

# cleanup dmg of installer 
sudo rm install_bits/macOS_*_installer.dmg

# get iso name
ISO_NAME=$(basename $(ls -Art install_bits/macOS_*_installer.iso | tail -n 1))
FILE_NAME=$(cut -f 1 -d .<<<$ISO_NAME)

# output shasum
echo "Updating the shasum file"
shasum -a 256 install_bits/$ISO_NAME > install_bits/$FILE_NAME.shasum

exit 0
