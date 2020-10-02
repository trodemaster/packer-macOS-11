source "vmware-iso" "macOS_11" {
  iso_url              = "install_bits/macOS_1100_installer.iso"
  iso_checksum         = "sha1:3fc8fb22a94cc1a0fc454fc2e85881acb4c3e803"
  ssh_username         = "packer"
  ssh_password         = "packer"
  shutdown_command     = "sudo shutdown -h now"
  guest_os_type        = "darwin20-64"
  cdrom_adapter_type   = "sata"
  disk_size            = "100000"
  disk_adapter_type    = "nvme"
  http_directory       = "http"
  network_adapter_type = "e1000e"
  disk_type_id         = "0"
  boot_wait            = "140s"
  ssh_timeout          = "12h"
  usb                  = "true"
  version              = "18"
  vmx_data = {
    "smc.present"                  = "TRUE",
    "smbios.restrictSerialCharset" = "TRUE",
    "board-id.reflectHost"         = "TRUE",
    "ich7m.present"                = "TRUE"
  }
boot_key_interval = "20ms"
boot_keygroup_interval = "2s"
  boot_command = [
    "<enter><wait10s>",
    "<leftSuperon><f5><leftSuperoff>",
    "<leftCtrlon><f2><leftCtrloff>",
    "u<down><down><down>",
    "<enter>",
    "<leftSuperon><f5><leftSuperoff><wait10>",
    "curl -o /var/root/packer.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/packer.pkg<enter>",
    "curl -o /var/root/setupsshlogin.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/setupsshlogin.pkg<enter>",
    "curl -o /var/root/bootstrap.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.sh<enter>",
    "chmod +x /var/root/bootstrap.sh<enter>",
    "/var/root/bootstrap.sh<enter>"
  ]
  cpus   = "8"
  cores  = "8"
  memory = "24576"
}

build {
  sources = ["sources.vmware-iso.macOS_11"]
}

