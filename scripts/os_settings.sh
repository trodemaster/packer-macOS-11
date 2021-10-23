#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# stop screensaver from wheezing the juice
defaults -currentHost write com.apple.screensaver idleTime -int 0

# kill feedback assistant
pkill Feedback || true

# cleanup ssh enablement from install process
if [[ -e /Library/LaunchDaemons/ssh.plist ]]; then
  sudo launchctl unload -w /Library/LaunchDaemons/ssh.plist
  sudo rm /Library/LaunchDaemons/ssh.plist
  #sudo /usr/sbin/systemsetup -f -setremotelogin on
  sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
fi

exit 0
