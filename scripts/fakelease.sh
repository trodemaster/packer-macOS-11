#!/usr/bin/env bash

# test for gnu sed
if ! ( command -v jq > /dev/null 2>&1 ); then
  echo "This script requires gnu sed to work properly."
  exit 1
fi

# get the bridge interface used by internet sharing
BRIDGE_IF=$(pgrep -lf rtadvd | grep -E -o "bridge[0-9]+")

# set the mac address prefix used by fusion
MAC_ADDR_PREFIX=0:c:29

# look for an arp entry with the same mac prefix
ARP_TABLE=$(arp -i $BRIDGE_IF -a | grep $MAC_ADDR_PREFIX) 

# extract the MAC
VM_MAC=$(grep -E -o "([0-9a-fA-F]{1,2}[:-]{0,1}){5}[0-9a-fA-F]{1,2}" <<<$ARP_TABLE)
VM_MAC_PADDED=$(/opt/local/libexec/gnubin/sed 's/\b\(\w\)\b/0\1/g' <<<$VM_MAC)

# extract the IP 
VM_IP=$(grep -E -o "([0-9]+\.){3}[0-9]+" <<<$ARP_TABLE)

# write the fake leaes to teh config file
sudo tee /private/var/db/vmware/vmnet-dhcpd-vmnet8.leases >/dev/null <<FAKELEASE
lease $VM_IP {
        starts 2 2020/03/17 20:05:20;
        ends 2 2029/03/17 20:35:20;
        hardware ethernet $VM_MAC_PADDED;
        uid 01:$VM_MAC_PADDED;
        client-hostname "faker";
}
FAKELEASE

