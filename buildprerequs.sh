#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# update the installer build script
git -C ../macadmin-scripts/ pull

# build the installer dmg
cd install_bits
sudo ../macadmin-scripts/installinstallmacos.py --seedprogram DeveloperSeed #--raw --clear --os "11.0"

# mount the installer dmg
open Install*.dmg

# built an ios
hdiutil create -o macOS_11_rw -size 15g -volname macOS -layout SPUD -fs HFS+J
hdiutil attach macOS_11_rw.dmg -noverify -mountpoint /Volumes/macOS_11_rw
sudo Install\ macOS\ Big\ Sur\ Beta.app/Contents/Resources/createinstallmedia --volume /Volumes/macOS_11_rw --nointeraction
hdiutil detach /Volumes/Install\ macOS\ Big\ Sur\ Beta
hdiutil convert macOS_11_rw.dmg -format UDTO -o macOS_11.cdr
mv macOS_11.cdr macOS_11.iso
