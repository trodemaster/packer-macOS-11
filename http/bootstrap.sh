#!/bin/bash
#set -euo pipefail
#IFS=$'\n\t'
#shopt -s nullglob nocaseglob

# just do the dang install
diskutil eraseDisk APFS 11vm disk0
nvram IASUCatalogURL=https://swscan.apple.com/content/catalogs/others/index-10.16seed-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog
/Volumes/macOS\ Base\ System/Install\ macOS\ Big\ Sur.app/Contents/Resources/startosinstall --agreetolicense --rebootdelay 90 --installpackage packer.pkg --installpackage setupsshlogin.pkg --volume /Volumes/11vm


echo "Bootstrap Completed"
exit 0