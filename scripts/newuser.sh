#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# path to self and parent dir
SCRIPT=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPT)

# new user name var
# new user pass var

. /etc/rc.common
dscl . create /Users/administrator
dscl . create /Users/administrator RealName "Terminal User Account"
dscl . create /Users/administrator hint "Password Hint"
dscl . create /Users/administrator picture "/Path/To/Picture.png"
dscl . passwd /Users/administrator thisistheaccountpassword
dscl . create /Users/administrator UniqueID 501
dscl . create /Users/administrator PrimaryGroupID 20
dscl . create /Users/administrator UserShell /bin/zsh
dscl . create /Users/administrator NFSHomeDirectory /Users/administrator
cp -R /System/Library/User\ Template/English.lproj /Users/administrator
chown -R administrator:staff /Users/administrator

# startup launchd to remove packer account and itself