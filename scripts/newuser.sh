#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# new user name var
NEW_USERNAME="vagrant"
# new user pass var
NEW_PASS="vagrant"

# ssh needs full disk access
# sysadminctl 	-addUser <user name> [-fullName <full name>] [-UID <user ID>] [-GID <group ID>] [-shell <path to shell>] [-password <user password>] [-hint <user hint>] [-home <full path to home>] [-admin] [-roleAccount] [-picture <full path to user image>] (interactive] || -adminUser <administrator user name> -adminPassword <administrator password>)
cd /Users
sudo sysadminctl -addUser "$NEW_USERNAME" -fullName "$NEW_USERNAME" -password "$NEW_PASS" -home /Users/"$NEW_USERNAME" -admin -shell /bin/zsh -adminUser packer -adminPassword packer
sudo createhomedir -u "$NEW_USERNAME" -c

#disable autologin
sudo defaults write /Library/Preferences/com.apple.loginwindow.plist autoLoginUser 0
sudo defaults delete /Library/Preferences/com.apple.loginwindow.plist autoLoginUser

## startup launchd to remove packer account and itself
#if ! [[ -d /Users/"$NEW_USERNAME"/Library/LaunchDaemons ]]; then
#  sudo mkdir -p /Users/"$NEW_USERNAME"/Library/LaunchDaemons
#  sudo chown "$NEW_USERNAME" /Users/"$NEW_USERNAME"/Library/LaunchDaemons
#fi

sudo tee /Library/LaunchDaemons/com.blakegarner.packer-user-removal.plist >/dev/null <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.blakegarner.packer-user-removal</string>
  <key>Program</key>
  <string>/Users/$NEW_USERNAME/cleanuser.sh</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <false/>
  <key>LaunchOnlyOnce</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/Users/$NEW_USERNAME/cleanuser.log</string>
  <key>StandardErrorPath</key>
  <string>/Users/$NEW_USERNAME/cleanuser.log</string></dict>
</plist>
EOF

# write cleanup script to /Users/"$NEW_USERNAME"/
sudo tee /Users/$NEW_USERNAME/cleanuser.sh >/dev/null <<-EOF
#!/bin/bash
#touch /Users/$NEW_USERNAME/cleanuser.run
whoami
cd /Users
/usr/sbin/sysadminctl -adminUser $NEW_USERNAME -adminPassword $NEW_PASS -secureTokenOff packer -password packer
/usr/sbin/sysadminctl -deleteUser packer -adminUser $NEW_USERNAME -adminPassword $NEW_PASS
echo "userdel"
# launchctl bootout system /Users/$NEW_USERNAME/com.blakegarner.packer-user-removal.plist
# echo "launchd boutout"
#/bin/rm /Users/$NEW_USERNAME/com.blakegarner.packer-user-removal.plist
#echo "launchd rm"
#rm $0
#touch /Users/$NEW_USERNAME/cleanuser.end
rm /Library/LaunchDaemons/com.blakegarner.packer-user-removal.plist
rm /Users/$NEW_USERNAME/cleanuser.sh
exit 0
EOF
sudo chmod +x /Users/$NEW_USERNAME/cleanuser.sh

exit 0
scp scripts/newuser.sh twelve3:~/ && ssh twelve3 "chmod +x ~/newuser.sh && ~/newuser.sh"

scp scripts/newuser.sh twelve3:~/ && ssh twelve3 "chmod +x ~/newuser.sh && ~/newuser.sh && sudo reboot"


