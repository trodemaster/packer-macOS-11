#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# boot in verbose mode to debug
# sudo nvram boot-args="-v"

# enable developer beta
if [[ $SEEDING_PROGRAM = "none" ]]; then
  echo "Unenroll from seeding"
  sudo /System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil unenroll
else
  echo "Enrolling to $SEEDING_PROGRAM"
  sudo /System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil enroll $SEEDING_PROGRAM
  sleep 23
fi

# check update state and save it to a log file to survive reboots
sudo softwareupdate -l 2>&1 | sudo tee ~/Library/Logs/packer_softwareupdate.log

# check log file to see if updates are available and install them if so
if (grep "No new software available" ~/Library/Logs/packer_softwareupdate.log); then
  echo "No software updates found"
else
  echo "$(date +"%Y-%m-%d %T") packer installing software updates and rebooting" | sudo tee /var/log/install.log
  sudo softwareupdate -iaR
  sleep 30
fi

exit 0
