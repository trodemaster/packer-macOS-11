#!/usr/bin/env bash
#set -euo pipefail
#IFS=$'\n\t'
#shopt -s nullglob nocaseglob

echo "setupsshlogin.sh starting"
echo "setupsshlogin.sh argument 1 is $1"
echo "setupsshlogin.sh argument 2 is $2"
echo "setupsshlogin.sh argument 3 is $3"
echo "setupsshlogin.sh argument 4 is $4"
echo "setupsshlogin.sh mount"
mount
ls /System/Volumes/Data/Users


# disable screensaver & energy saver
pmset displaysleep 0 || true
pmset disksleep 0 || true
defaults -currentHost write com.apple.screensaver idleTime 0

# disable Accessablity
# disable data and privacy
# disable sign in apple id
# disable analytics
# disable screen time

# sudo nopasswd for packer user
echo 'packer     ALL=(ALL)       NOPASSWD: ALL' >/private/etc/sudoers.d/packer

# supress setup screens
touch /private/var/db/.AppleSetupDone

/usr/sbin/systemsetup -f -setremotelogin on || true

# get rid of popup dialogs
sw_vers=$(sw_vers -productVersion)
sw_build=$(sw_vers -buildVersion)

if [[ -d /System/Library/User\ Template/English.lproj/Library/Preferences/ ]]; then
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant DidSeePrivacy -bool TRUE
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant DidSeeTrueTonePrivacy -bool TRUE
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant DidSeeTouchIDSetup -bool TRUE
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant DidSeeSiriSetup -bool TRUE
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant DidSeeActivationLock -bool TRUE
    /usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant DidSeeScreenTime -bool TRUE
else
    echo "setupsshlogin.sh /System/Library/User\ Template/English.lproj/Library/Preferences not found!!"
fi

if [[ -d /System/Volumes/Data/Users/packer/Library/Preferences/ ]]; then
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeePrivacy -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeTrueTonePrivacy -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeTouchIDSetup -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeSiriSetup -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeActivationLock -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeScreenTime -bool TRUE
    /usr/sbin/chown packer /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant.plist
else
    echo "setupsshlogin.sh /System/Volumes/Data/Users/packer/Library/Preferences/ not found!!"
    mkdir -p /System/Volumes/Data/Users/packer/Library/Preferences/
    chown -R packer:staff /System/Volumes/Data/Users/packer
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeePrivacy -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeTrueTonePrivacy -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeTouchIDSetup -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeSiriSetup -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeActivationLock -bool TRUE
    /usr/bin/defaults write /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant DidSeeScreenTime -bool TRUE
    /usr/sbin/chown packer /System/Volumes/Data/Users/packer/Library/Preferences/com.apple.SetupAssistant.plist
fi

# enable ssh login
echo $PWD
ls /Users
/usr/sbin/systemsetup -f -setremotelogin on || true

echo "setupsshlogin.sh completed"

exit 0
