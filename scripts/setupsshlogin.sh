#!/usr/bin/env bash
#set -euo pipefail
#IFS=$'\n\t'
#shopt -s nullglob nocaseglob

echo "setupsshlogin.sh starting"

# disable screensaver & energy saver
pmset displaysleep 0 || true
pmset disksleep 0 || true
defaults -currentHost write com.apple.screensaver idleTime 0

# sudo nopasswd for packer user
echo 'packer     ALL=(ALL)       NOPASSWD: ALL' >/private/etc/sudoers.d/packer
echo 'vagrant    ALL=(ALL)       NOPASSWD: ALL' >/private/etc/sudoers.d/vagrant

# supress setup screens
touch /private/var/db/.AppleSetupDone

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

# add vmware to the kext allowlist for tools
/usr/sbin/spctl kext-consent add EG7KH642X6

# enable ssh at next boot
echo "setupsshlogin.sh enable ssh at next boot"
cp /System/Library/LaunchDaemons/ssh.plist /Library/LaunchDaemons/ssh.plist
/usr/libexec/plistbuddy -c "set Disabled FALSE" /Library/LaunchDaemons/ssh.plist

echo "setupsshlogin.sh completed"

exit 0
