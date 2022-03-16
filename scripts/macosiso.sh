#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# path to self and parent dir
SCRIPT=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPT)

# check for mist binary
if ! ( command -v mist > /dev/null 2>&1 ); then
  echo "This script requires mist in your path to work properly."
  echo "Get the latest version from https://github.com/ninxsoft/Mist"
  exit 1
fi

# test for target path
if ! [[ -d install_bits ]]; then
  echo "Script needs to run from the root of the repo"
  exit 1
fi

# use mist to download and convert the iso
sudo mist download $1 --iso --iso-name macOS_%VERSION%_%BUILD%.iso -t install_bits -o install_bits

# include beta flag if you want beta OS versions
# sudo mist download -b $1 --iso --iso-name macOS_%VERSION%_%BUILD%.iso -t install_bits -o install_bits

# fixup owner
sudo chown $USER install_bits/macOS_$1*.iso

# get iso name
ISO_NAME=$(basename $(ls -Art install_bits/macOS_$1*.iso | tail -n 1))
SHASUM_NAME=$(sed 's/iso/shasum/' <<<$ISO_NAME)

# output shasum
echo "Updating the shasum file"
shasum -a 256 install_bits/$ISO_NAME > install_bits/$SHASUM_NAME

# output details
echo "Resulting artifacts"
echo install_bits/$ISO_NAME
echo install_bits/$SHASUM_NAME

exit 0