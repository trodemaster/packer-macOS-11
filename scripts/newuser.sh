#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

echo "REMOVE_PACKER_USER=$REMOVE_PACKER_USER"
echo "NEW_USERNAME=$NEW_USERNAME"
echo "NEW_PASSWORD=$NEW_PASSWORD"
echo "NEW_SSH_KEY=$NEW_SSH_KEY"

if [[ $REMOVE_PACKER_USER =~ false ]]; then
	echo "skipping new user creation..."
	exit 0
fi

# ssh needs full disk access
# sysadminctl 	-addUser <user name> [-fullName <full name>] [-UID <user ID>] [-GID <group ID>] [-shell <path to shell>] [-password <user password>] [-hint <user hint>] [-home <full path to home>] [-admin] [-roleAccount] [-picture <full path to user image>] (interactive] || -adminUser <administrator user name> -adminPassword <administrator password>)
cd /Users
sudo sysadminctl -addUser "$NEW_USERNAME" -fullName "$NEW_USERNAME" -password "$NEW_PASSWORD" -home /Users/"$NEW_USERNAME" -admin -shell /bin/zsh -picture /Library/User\ Pictures/Instruments/Turntable.tif -adminUser packer -adminPassword packer
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
sudo tee /Users/"${NEW_USERNAME}"/cleanuser.sh >/dev/null <<-EOF
#!/bin/bash
cd /Users
/usr/sbin/sysadminctl -adminUser $NEW_USERNAME -adminPassword "$NEW_PASSWORD" -secureTokenOff packer -password packer
/usr/sbin/sysadminctl -deleteUser packer -adminUser $NEW_USERNAME -adminPassword "$NEW_PASSWORD"
rm /Library/LaunchDaemons/com.blakegarner.packer-user-removal.plist
rm /Users/$NEW_USERNAME/cleanuser.sh
exit 0
EOF
sudo chmod +x /Users/$NEW_USERNAME/cleanuser.sh

exit 0