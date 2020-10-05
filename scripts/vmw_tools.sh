#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# unmount installer if needed
hdiutil unmount /Volumes/Install* || true
sleep 3

# mount tools iso
hdiutil mount ~/vmw_tools.iso

# install tools pkg
sudo installer -pkg "/Volumes/VMware Tools/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target / || true

# authorize kexts

# authorize tools binary

# cleanup
hdiutil unmount /Volumes/VMware\ Tools
rm  ~/vmw_tools.iso

# restart the box
sudo reboot

exit 0