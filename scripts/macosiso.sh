#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# enable developer seeds
# PublicSeed  CustomerSeed DeveloperSeed none
HOST_SYSTEM_SEED_STATE=$(sudo /System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil current | sed -n 's/^Currently enrolled in: //p')
if [[ $HOST_SYSTEM_SEED_STATE == "(null)" ]]; then
  sudo /System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil enroll DeveloperSeed
fi

# cleanup existing installer
rm -r /Applications/Install\ macOS*.app

# download installer
softwareupdate --fetch-full-installer --full-installer-version 12.0

# disable developer seeds
if [[ $HOST_SYSTEM_SEED_STATE != $(sudo /System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil current | sed -n 's/^Currently enrolled in: //p') ]]; then
  if [[ $HOST_SYSTEM_SEED_STATE == "DeveloperSeed" ]]; then
    sudo /System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil unenroll
  fi
fi

# make install disk image
INSTALL_APP=$(ls -d /System/Volumes/Data/Applications/Install\ macOS*.app)
echo 1 | ./submodules/create_macos_vm_install_dmg/create_macos_vm_install_dmg.sh "$INSTALL_APP" install_bits/ #|| true


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
