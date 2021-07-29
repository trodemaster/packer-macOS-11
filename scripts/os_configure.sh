#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# /usr/local/bin
if ! [[ -d /usr/local/bin ]]; then
  sudo mkdir -p /usr/local/bin
fi

# install cliclick
/usr/bin/curl -s -S -o ~/cliclick.zip https://www.bluem.net/files/cliclick.zip
/usr/bin/unzip -o ~/cliclick.zip
/usr/bin/sudo mv ~/cliclick/cliclick /usr/local/bin/cliclick
/bin/rm -r ~/cliclick*

# List kernel extensions
echo "Current kernel extension staus"
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT * FROM kext_policy" > ~/befo.txt
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT * FROM kext_load_history_v3" >> ~/befo.txt

sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "REPLACE INTO kext_policy VALUES('EG7KH642X6','com.vmware.kext.VMwareGfx',1,'VMware, Inc.',1)"
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "REPLACE INTO kext_policy VALUES('EG7KH642X6','com.vmware.kext.vmhgfs',1,'VMware, Inc.',1)"
LIKE_NOW_N_SHIT=$(/bin/date "+%Y-%m-%d %H:%M:%S")
A_WHILE_AGO=$(/bin/date  -v-5m "+%Y-%m-%d %H:%M:%S")
#> /Library/Extensions/VMwareGfx.kext|EG7KH642X6|com.vmware.kext.VMwareGfx|BC429FD9-060C-4347-AF15-8368B9AB0525|2021-01-27 14:02:16|2021-06-27 21:09:19|53|fc6c7865969ce929022ea07caefce5f669144959

sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "REPLACE INTO kext_load_history_v3 VALUES('/Library/Extensions/VMwareGfx.kext','EG7KH642X6','com.vmware.kext.VMwareGfx','BC429FD9-060C-4347-AF15-8368B9AB0525','2021-01-27 14:02:16','$A_WHILE_AGO',53,'fc6c7865969ce929022ea07caefce5f669144959')"
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "REPLACE INTO kext_load_history_v3 VALUES('/Library/Application Support/VMware Tools/vmhgfs.kext','EG7KH642X6','com.vmware.kext.vmhgfs','BC429FD9-060C-4347-AF15-8368B9AB0525','2021-01-27 14:02:16','$A_WHILE_AGO',16,'2de8c493ab488c19c96de27089a0b5afe4621616')"

sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT * FROM kext_policy" > ~/afta.txt
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT * FROM kext_load_history_v3" >> ~/afta.txt

sudo kmutil install --update-all || true
sudo kcditto || true


exit 0
#sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "delete from kext_load_history_v3 where bundle_id = 'com.vmware.kext.VMwareGfx'"
#sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "delete from kext_load_history_v3 where bundle_id = 'com.vmware.kext.vmhgfs'"

sudo chown -R root:wheel /System/Library/Extensions/
sudo chmod -R 755 /System/Library/Extensions/
sudo kmutil install --update-all
sudo kcditto

bless --folder /Volumes/macOS/System/Library/CoreServices --bootefi --create-snapshot

#sudo touch /Library/DriverExtensions
#sudo kmutil install --force || true
#sudo kmutil install --update-all --force --volume-root /Volumes/macOS
#sudo kextcache -force -all-loaded -system-caches -update-volume /
#sudo kextcache --clear-staging 
echo "Updated kernel extension status"
#sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT * FROM kext_policy"

exit 0

sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy .dump > befor.txt
> INSERT INTO kext_policy VALUES('EG7KH642X6','com.vmware.kext.VMwareGfx',1,'VMware, Inc.',1);
> INSERT INTO kext_policy VALUES('EG7KH642X6','com.vmware.kext.vmhgfs',1,'VMware, Inc.',1);

sleep 99999
# approve kenel extensions

sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT INTO access VALUES('kTCCServiceAccessibility','<APP>',0,1,1,NULL,NULL);"

echo "INSERT or REPLACE INTO access VALUES('kTCCServiceMicrophone','com.microsoft.SkypeForBusiness',0,1,1,NULL,NULL,NULL,'UNUSED',NULL,0,1541440109)" | sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db

# update accessablity db


EG7KH642X6|com.vmware.kext.VMwareGfx|1|VMware, Inc.|1
EG7KH642X6|com.vmware.kext.vmhgfs|1|VMware, Inc.|1


sudo defaults write /Library/Preferences/com.apple.loginwindow.plist autoLoginUser packer

sudo plutil -replace autoLoginUser -string packer /Library/Preferences/com.apple.loginwindow.plist

sudo /usr/libexec/PlistBuddy -c "Set autoLoginUser packer" /Library/Preferences/com.apple.loginwindow.plist


#!/bin/sh -e
/Volumes/Macintosh\ HD/usr/bin/sqlite3 /Volumes/Macintosh\ HD/var/db/SystemPolicyConfiguration/KextPolicy 'delete from kext_policy where team_id="TEAMID1234";'
/Volumes/Macintosh\ HD/usr/bin/sqlite3 /Volumes/Macintosh\ HD/var/db/SystemPolicyConfiguration/KextPolicy 'delete from kext_load_history_v3 where team_id="TEAMID1234";'
