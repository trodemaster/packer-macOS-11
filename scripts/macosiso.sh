#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# check for mist binary
if ! ( command -v mist > /dev/null 2>&1 ); then
  echo "This script requires mist in your path to work properly."
  echo "Get the latest version from https://github.com/ninxsoft/mist-cli"
  exit 1
fi

# do a mist version check as the arguments changed over time
if [[ $(echo "$(mist version | /usr/bin/grep -o -e '^[0-9]\+\.[0-9]\+') < 1.8" | bc -l) == 1 ]]; then
  mist version
  echo "Mist version needs to be at least 1.8..."
  exit 1
fi

# test for target path
if ! [[ -d install_bits ]]; then
  echo "Script needs to run from the root of the repo"
  exit 1
fi

# use mist to download and convert the iso
echo "Creating the installer iso requires sudo privileges…"
sudo mist download installer --include-betas $1 iso --iso-name macOS_%VERSION%_%BUILD%.iso -t install_bits -o install_bits

# get iso name
ISO_NAME=$(basename $(ls -Art install_bits/macOS_*$1*.iso | tail -n 1))
SHASUM_NAME=$(sed 's/iso/shasum/' <<<$ISO_NAME)

# output shasum
echo "Updating the shasum file"
shasum -a 256 install_bits/$ISO_NAME > install_bits/$SHASUM_NAME

# output details
echo "Resulting artifacts"
echo install_bits/$ISO_NAME
echo install_bits/$SHASUM_NAME

exit 0
