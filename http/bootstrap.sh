#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# format the disk
diskutil eraseDisk jhfs+ macOS disk0

# set sucatalog nvram. This may be a temp workaround.
nvram IASUCatalogURL=https://swscan.apple.com/content/catalogs/others/index-10.16seed-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog

# run the installer with some error handling due to helper tool crashing sometimes
retrycount=0
retrylimit=5
until [ "$retrycount" -ge "$retrylimit" ]
do
  /Volumes/Image\ Volume/Install*.app/Contents/Resources/startosinstall --agreetolicense --installpackage packer.pkg --installpackage setupsshlogin.pkg --volume /Volumes/macOS && break
   retrycount=$((retrycount+1)) 
   echo "startosinstall failed. retrying in 20sec"
   sleep 20
done

if [ "$retrycount" -ge "$retrylimit" ]; then
  echo "startosinstall failed after $retrylimit attempts"
  tail  -n 30 /var/log/install.log
  exit 1
fi  

echo "Bootstrap Completed"
exit 0