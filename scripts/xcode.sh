#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

#echo "unpacking xcode"
#xip -x ~/Xcode*.xip
#
#echo "Move Xcode to /Applications"
#sudo mv ~/Xcode*.app /Applications/

echo "mount cli tools"
hdiutil attach -quiet -noverify -mountpoint "/Volumes/Command Line Developer Tools/" ~/Command_Line_Tools_*.dmg 

echo "install the cli tools"
sudo installer -pkg "/Volumes/Command Line Developer Tools/Command Line Tools.pkg" -target / || true

#echo "xattar remove quarantine attributes"
#XCODE_APP=$(ls -d /Applications/Xcode*.app)
#sudo xattr -dr com.apple.quarantine ${XCODE_APP}

echo "Verify & configure Xcode..."
#sudo /usr/bin/xcode-select -s ${XCODE_APP}/Contents/Developer
sudo /usr/bin/xcode-select -s /Library/Developer/CommandLineTools/
#sudo /usr/bin/xcodebuild -license accept
#sudo /usr/bin/xcodebuild -runFirstLaunch
sudo /usr/sbin/DevToolsSecurity -enable
sudo dseditgroup -o add everyone -t group _developer

echo "unmount cli tools"
hdiutil detach "/Volumes/Command Line Developer Tools/" -force -quiet   

echo "Cleanup Xcode installer files"
#rm ~/Xcode*.xip
rm ~/Command_Line_Tools_*.dmg

exit 0