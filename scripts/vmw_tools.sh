#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# http://softwareupdate.vmware.com/cds/vmw-desktop/fusion/11.5.6/16696540/core/com.vmware.fusion.zip.tar

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