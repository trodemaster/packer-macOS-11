#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob


# set hostname
sudo scutil --set HostName $NEW_HOSTNAME
sudo scutil --set ComputerName $NEW_HOSTNAME 
sudo scutil --set LocalHostName $NEW_HOSTNAME

# /usr/local/bin
if ! [[ -d /usr/local/bin ]]; then
  sudo mkdir -p /usr/local/bin
fi

# install cliclick
/usr/bin/sudo mv ~/cliclick /usr/local/bin/cliclick

# get rid of notifications
launchctl unload /System/Library/LaunchAgents/com.apple.notificationcenterui.plist

# address some kext warnings and needed approvals
if [[ $(csrutil status) =~ "disabled" ]]; then
  sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "INSERT OR REPLACE INTO kext_load_history_v3(rowid,path,team_id,bundle_id,boot_uuid,created_at,last_seen,flags,cdhash) VALUES(5,'/Library/Extensions/VMwareGfx.kext','EG7KH642X6','com.vmware.kext.VMwareGfx','018D4064-57E3-4AE0-AFAE-489807AE8794','2022-07-23 19:10:09','2022-07-23 19:11:50',16,'a440619b81eba21bfb0577ddbe141aad412f5aae');"
  sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "INSERT OR REPLACE INTO kext_load_history_v3(rowid,path,team_id,bundle_id,boot_uuid,created_at,last_seen,flags,cdhash) VALUES(6,'/Library/Application Support/VMware Tools/vmhgfs.kext','EG7KH642X6','com.vmware.kext.vmhgfs','018D4064-57E3-4AE0-AFAE-489807AE8794','2022-07-23 19:10:14','2022-07-23 19:11:50',16,'203c46f8c16f599edd0da9436ec7fa3628adff15');"
  sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "INSERT OR REPLACE INTO kext_policy(rowid,team_id,bundle_id,allowed,developer_name,flags) VALUES(1,'EG7KH642X6','com.vmware.kext.VMwareGfx',1,'VMware, Inc.',0);"
  sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "INSERT OR REPLACE INTO kext_policy(rowid,team_id,bundle_id,allowed,developer_name,flags) VALUES(2,'EG7KH642X6','com.vmware.kext.vmhgfs',1,'VMware, Inc.',0);"
  sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "INSERT OR REPLACE INTO settings(rowid,name,value) VALUES(16,'lastStateSecurityPolicy','0');"

#  # Disable DEP enrolement at boot maybe?
#  sudo tee -a /etc/hosts >/dev/null <<-EOF
#0.0.0.0 iprofiles.apple.com
#0.0.0.0 mdmenrollment.apple.com
#0.0.0.0 deviceenrollment.apple.com
#0.0.0.0 gdmf.apple.com
#0.0.0.0 albert.apple.com    
#0.0.0.0 deviceenrollment.apple.com    
#EOF
#  sudo rm -rf /var/db/ConfigurationProfiles/
#  sudo rm /Library/Keychains/apsd.keychain

  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceAccessibility', '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/AE.framework/Versions/A/Support/AEServer', 1, 1, 4, 1, x'fade0c000000003000000001000000060000000200000012636f6d2e6170706c652e4145536572766572000000000003', NULL, 0, 'UNUSED', NULL, 0, 1646855925);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceAccessibility', '/Library/Application Support/VMware Tools/vmware-tools-daemon', 1, 2, 4, 1, NULL, NULL, 0, 'UNUSED', NULL, 0, 0);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceAccessibility', '/usr/local/bin/cliclick', 1, 2, 4, 1, NULL, NULL, 0, 'UNUSED', NULL, 0, 0);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceAccessibility', '/usr/libexec/sshd-keygen-wrapper', 1, 2, 4, 1, NULL, NULL, 0, 'UNUSED', NULL, 0, 0);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceDeveloperTool', 'com.apple.Terminal', 0, 0, 4, 1, NULL, NULL, 0, 'UNUSED', NULL, 0, 1646856644);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceSystemPolicyAllFiles', 'com.apple.Terminal', 0, 0, 5, 1, x'fade0c000000003000000001000000060000000200000012636f6d2e6170706c652e5465726d696e616c000000000003', NULL, NULL, 'UNUSED', NULL, 0, 1647143564);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(rowid,service,client,client_type,auth_value,auth_reason,auth_version,csreq,policy_id,indirect_object_identifier_type,indirect_object_identifier,indirect_object_code_identity,flags,last_modified) VALUES(14,'kTCCServiceSystemPolicyAllFiles','/bin/bash',1,2,4,1,x'fade0c000000002c0000000100000006000000020000000e636f6d2e6170706c652e62617368000000000003',NULL,0,'UNUSED',NULL,0,1648928242);"
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

else
  echo "sip is enabled skipping some config changes"
fi

exit 0
