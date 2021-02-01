#!/usr/bin/env bash

# confirm the vmx file provided exists
if [[ -e "$1" ]]; then
  echo "Updating $1"
else
  echo "The target vmx file $1 doesn't exist"
fi

#VMX_FILE=$(sed 's/ /\\ /g' <<<"$1")
#echo $VMX_FILE
VMX_FILE=$1
# svga.present
if (grep -q svga.present "$VMX_FILE"); then
  /usr/bin/sed -i '' 's/svga.present.*/svga.present="FALSE"/g' "$VMX_FILE"
else
  echo 'svga.present="FALSE"' >>"$VMX_FILE"
fi

# appleGPU0.present
if (grep -q appleGPU0.present "$VMX_FILE"); then
  /usr/bin/sed -i '' 's/appleGPU0.present.*/appleGPU0.present="TRUE"/g' "$VMX_FILE"
else
  echo 'appleGPU0.present="TRUE"' >>"$VMX_FILE"
fi

## appleGPU0.screenWidth
#if (grep -q appleGPU0.screenWidth "$VMX_FILE"); then
#  /usr/bin/sed -i '' 's/appleGPU0.screenWidth.*/appleGPU0.screenWidth=1920/g' "$VMX_FILE"
#else
#  echo 'appleGPU0.screenWidth=1920' >>"$VMX_FILE"
#fi
#
## appleGPU0.screenHeight
#if (grep -q appleGPU0.screenHeight "$VMX_FILE"); then
#  /usr/bin/sed -i '' 's/appleGPU0.screenHeight.*/appleGPU0.screenHeight1080/g' "$VMX_FILE"
#else
#  echo 'appleGPU0.screenHeight=1080' >>"$VMX_FILE"
#fi

# view the config
grep '^appleGPU0\|^svga' "$1"

exit 0