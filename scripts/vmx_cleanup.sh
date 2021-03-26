#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# set target var
VMX_FILE=$1

# confirm the vmx file provided exists
if [[ -e "$VMX_FILE" ]]; then
  echo "Updating $(basename $VMX_FILE)"
else
  echo "The target vmx file $VMX_FILE doesn't exist"
  exit 0
fi

# check if host system is macOS 11.x or greater. If so enable pvgpu
if grep -q -e '^11' <<<$(sw_vers -productVersion); then
  echo "Adding pvgpu settings"
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

fi
