#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

install_tools_iso () {
  hdiutil mount ~/darwin.iso
  sudo installer -pkg "/Volumes/VMware Tools/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target / || true
  hdiutil unmount /Volumes/VMware\ Tools
  rm ~/darwin.iso
}

if [[ $TOOLS_URL != "local" ]]; then

# try to grab tools from vmware.com
retrycount=0
retrylimit=5
until [ "$retrycount" -ge "$retrylimit" ]; do
  echo "Downloading $TOOLS_URL"
  curl -s $TOOLS_URL -o ~/com.vmware.fusion.zip.tar && break
  retrycount=$((retrycount + 1))
  echo "Downloading vmware tools failed. retrying in 5 seconds"
  sleep 5
done

# notify that download failed
if [ "$retrycount" -ge "$retrylimit" ]; then
  echo "Unable to download $TOOLS_URL failed after $retrylimit attempts"
  echo "Using downloaded .iso instead"
  install_tools_iso
else
  echo "install it"
  tar -xvf ~/com.vmware.fusion.zip.tar
  unzip ~/com.vmware.fusion.zip
  sudo installer -pkg "~/VMware Tools.pkg" -target / || true
fi
else
  install_tools_iso
fi

# authorize kexts

# authorize tools binary

# restart the box
sudo reboot

exit 0
