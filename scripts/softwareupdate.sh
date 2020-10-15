#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

UPDATES_NEEDED=$(sudo softwareupdate -l 2>&1 >/dev/null)
if [[ $UPDATES_NEEDED =~ "No updates are available" ]]; then
  echo "No software updates found"
else
  echo "Installing software updates and rebooting"
  sudo /System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil enroll DeveloperSeed
  sudo softwareupdate -iaR
  sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist
  sleep 30
fi

exit 0
