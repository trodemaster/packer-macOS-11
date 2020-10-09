#!/usr/bin/env bash

echo "unpacking xcode"
cd ~
xip -x ~/Xcode*.xip

echo "put xcode in place"
sudo mv ~/Xcode*.app /Applications/
#xattr -d com.apple.quarantine /Applications/Xcode*.app
# validate xcode app somehow

echo "mount cli tools"
hdiutil attach -quiet -noverify -mountpoint "/Volumes/Command Line Developer Tools/" ~/Command_Line_Tools_*.dmg 

echo "instal the CLI tools"
sudo installer -pkg "/Volumes/Command Line Developer Tools/Command Line Tools.pkg" -target / || true

echo "unmount cli tools"
hdiutil detach "/Volumes/Command Line Developer Tools/"* -force -quiet   

echo "Cleanup Xcode installer files"
rm ~/Xcode*.xip
rm ~/Command_Line_Tools_*.dmg

exit 0