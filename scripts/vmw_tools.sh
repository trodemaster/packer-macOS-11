#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# mount tools iso
hdiutil mount ~/darwin.iso

# install tools pkg
sudo installer -pkg "/Volumes/VMware Tools/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target / || true

# authorize kexts

# authorize tools binary

# cleanup
hdiutil unmount /Volumes/VMware\ Tools
rm  ~/darwin.iso

# restart the box
sudo reboot

exit 0