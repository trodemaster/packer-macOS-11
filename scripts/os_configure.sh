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
  sudo python /usr/local/bin/tccutil.py -l 
  sudo python /usr/local/bin/tccutil.py -i '/Library/Application Support/VMware Tools/vmware-tools-daemon'
  sudo python /usr/local/bin/tccutil.py -i /usr/local/bin/cliclick
  sudo python /usr/local/bin/tccutil.py -e /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/AE.framework/Versions/A/Support/AEServer
  sudo python /usr/local/bin/tccutil.py -i /usr/libexec/sshd-keygen-wrapper
  sudo python /usr/local/bin/tccutil.py -l 
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  ## use UI automation to approve VMware Kernel Extensions
  # dismiss kernel ext dialog
  /usr/local/bin/cliclick -m verbose c:515,360
  # Open System Preferences to security
  open "x-apple.systempreferences:com.apple.preference.security?General"
  sleep 5
  # click lock icon
  /usr/local/bin/cliclick -m verbose c:220,632 w:500
  # input password
  /usr/local/bin/cliclick -m verbose "t:${USER_PASSWORD}" w:500
  # submit password
  /usr/local/bin/cliclick -m verbose kp:enter w:1500
  # click allow button for kext
  /usr/local/bin/cliclick -m verbose c:750,545 w:500
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

# remove vmware shared folders shortcut
[[ -x ${HOME}/Desktop/VMware\ Shared\ Folders ]] && rm ${HOME}/Desktop/VMware\ Shared\ Folders

exit 0



