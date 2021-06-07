#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# List kernel extensions
echo "Current kernel extension staus"
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT * FROM kext_policy"

sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "REPLACE INTO kext_policy VALUES('EG7KH642X6','com.vmware.kext.VMwareGfx',1,'VMware, Inc.',1)"
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "REPLACE INTO kext_policy VALUES('EG7KH642X6','com.vmware.kext.vmhgfs',1,'VMware, Inc.',1)"
LIKE_NOW_N_SHIT=$(/bin/date "+%Y-%m-%d %H:%M:%S")
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "REPLACE INTO kext_load_history_v3 VALUES('/Library/Extensions/VMwareGfx.kext','EG7KH642X6','com.vmware.kext.VMwareGfx','BC429FD9-060C-4347-AF15-8368B9AB0525','$LIKE_NOW_N_SHIT','$LIKE_NOW_N_SHIT',53,'dc117f972f28df0f0375943865d1c50e318cf845')"
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "REPLACE INTO kext_load_history_v3 VALUES('/Library/Application Support/VMware Tools/vmhgfs.kext','EG7KH642X6','com.vmware.kext.vmhgfs','BC429FD9-060C-4347-AF15-8368B9AB0525','$LIKE_NOW_N_SHIT','$LIKE_NOW_N_SHIT',16,'2de8c493ab488c19c96de27089a0b5afe4621616')"

#sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "delete from kext_load_history_v3 where bundle_id = 'com.vmware.kext.VMwareGfx'"
#sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "delete from kext_load_history_v3 where bundle_id = 'com.vmware.kext.vmhgfs'"


sudo touch /Library/DriverExtensions

#sudo kmutil install --update-all --force --volume-root /Volumes/11vm
#sudo kextcache -force -all-loaded -system-caches -update-volume /
#sudo kextcache --clear-staging 
echo "Updated kernel extension status"
sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT * FROM kext_policy"

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
