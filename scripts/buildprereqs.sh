#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# mount the installer dmg
# setup gitignore for install_bits dir

hdiutil attach submodules/macadmin-scripts/Install_macOS*.dmg -noverify -mountpoint install_bits/dmg

# built an ios
# use this as a git submodule https://github.com/rtrouton/create_macos_vm_install_dmg/blob/master/create_macos_vm_install_dmg.sh
echo 1 | ./submodules/create_macos_vm_install_dmg/create_macos_vm_install_dmg.sh install_bits/dmg/Install\ macOS\ Big\ Sur\ Beta.app install_bits/ || true

# ugly try to unmount any existing installer volumes
hdiutil detach install_bits/dmg -force

# cleanup dmg of installer
rm install_bits/macOS_1100_installer.dmg

# output shasum
echo "Updating the shasum file"
shasum -a 256 install_bits/macOS_1100_installer.iso > install_bits/macOS_1100_installer.shasum

exit 0
