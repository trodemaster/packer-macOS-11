#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# /usr/local/bin
if ! [[ -d /usr/local/bin ]]; then
  sudo mkdir -p /usr/local/bin
fi

# install cliclick
/usr/bin/sudo mv ~/cliclick /usr/local/bin/cliclick

# install tccutil.py
sudo mv ~/tccutil.py /usr/local/bin/

# get rid of notifications
launchctl unload /System/Library/LaunchAgents/com.apple.notificationcenterui.plist

# Let's try and get rid of a few security warnings and needed approvals

if [[ $(csrutil status) =~ "disabled" ]]; then

  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceAccessibility', '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/AE.framework/Versions/A/Support/AEServer', 1, 1, 4, 1, x'fade0c000000003000000001000000060000000200000012636f6d2e6170706c652e4145536572766572000000000003', NULL, 0, 'UNUSED', NULL, 0, 1646855925);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceAccessibility', '/Library/Application Support/VMware Tools/vmware-tools-daemon', 1, 2, 4, 1, NULL, NULL, 0, 'UNUSED', NULL, 0, 0);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceAccessibility', '/usr/local/bin/cliclick', 1, 2, 4, 1, NULL, NULL, 0, 'UNUSED', NULL, 0, 0);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceAccessibility', '/usr/libexec/sshd-keygen-wrapper', 1, 2, 4, 1, NULL, NULL, 0, 'UNUSED', NULL, 0, 0);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceDeveloperTool', 'com.apple.Terminal', 0, 0, 4, 1, NULL, NULL, 0, 'UNUSED', NULL, 0, 1646856644);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceSystemPolicyAllFiles', 'com.apple.Terminal', 0, 0, 5, 1, x'fade0c000000003000000001000000060000000200000012636f6d2e6170706c652e5465726d696e616c000000000003', NULL, NULL, 'UNUSED', NULL, 0, 1647143564);"
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access(service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES('kTCCServiceSystemPolicyAllFiles', '/bin/bash', 0, 0, 5, 1, x'fade0c000000003000000001000000060000000200000012636f6d2e6170706c652e5465726d696e616c000000000003', NULL, NULL, 'UNUSED', NULL, 0, 1647143564);"

  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  ## use UI automation to approve VMware Kernel Extensions
  # dismiss kernel ext dialog
  /usr/local/bin/cliclick -m verbose c:515,360
  # Open System Preferences to security
  open "x-apple.systempreferences:com.apple.preference.security?General"
  sleep 5
  # click lock icon
  /usr/local/bin/cliclick -m verbose c:220,632 w:2000
  # input password
  /usr/local/bin/cliclick -m verbose "t:${USER_PASSWORD}" w:2000
  # submit password
  /usr/local/bin/cliclick -m verbose kp:enter w:3000
  # click allow button for kext
  /usr/local/bin/cliclick -m verbose c:750,545 w:2000
  # confirm reboot
  /usr/local/bin/cliclick -m verbose kp:space
  echo "rebooting"
  sleep 1
  pkill "System Preferences" || true
  # Wait for ssh to stop responding
  sleep 30
else
  echo "sip is enabled skipping some config changes"
fi

exit 0



