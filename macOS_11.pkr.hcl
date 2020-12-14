packer {
  required_version = ">= 1.6.5"
}

variable "iso_file_checksum" {
  type    = string
  default = "file:install_bits/macOS_1110_installer.shasum"
}

variable "iso_filename" {
  type    = string
  default = "install_bits/macOS_1110_installer.iso"
}

variable "user_password" {
  type    = string
  default = "packer"
}

variable "user_username" {
  type    = string
  default = "packer"
}

variable "cpu_count" {
  type    = number
  default = "6"
}

variable "ram_gb" {
  type    = number
  default = "24"
}

variable "xcode" {
  type    = string
  default = "install_bits/Xcode_12.3.xip"
}

variable "xcode_cli" {
  type    = string
  default = "install_bits/Command_Line_Tools_for_Xcode_12.3.dmg"
}

variable "board_id" {
  type    = string
  default = "Mac-27AD2F918AE68F61"
}

variable "hw_model" {
  type    = string
  default = "MacPro7,1"
}

variable "serial_number" {
  type    = string
  default = "M00000000001"
}

variable "seeding_program" {
  type = string
  default = "DeveloperSeed" # set to "none" to disable
}

variable "tools_url" {
  type = string
  default = "local"
}

# Full build 
build {
  name    = "full"
  sources = ["sources.vmware-iso.macOS_11"]

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "2m" # needed for the first provisioner to let the OS finish booting
    script            = "scripts/os_settings.sh"
  }

  provisioner "file" {
    sources     = [var.xcode, var.xcode_cli, "/Applications/VMware Fusion.app/Contents/Library/isoimages/darwin.iso"]
    destination = "~/"
  }

  provisioner "shell" {
    expect_disconnect = true
    start_retry_timeout = "2h"
    environment_vars = [
      "SEEDING_PROGRAM=${var.seeding_program}",
      "TOOLS_URL=${var.tools_url}"
    ] 
    scripts = [
      "scripts/vmw_tools.sh",
      "scripts/xcode.sh",
      "scripts/softwareupdate.sh",
      "scripts/softwareupdate_complete.sh"
    ]
  }
}

source "vmware-iso" "macOS_11" {
  display_name         = "macOS 11"
  vm_name              = "macOS_11"
  vmdk_name            = "macOS_11"
  iso_url              = "${var.iso_filename}"
  iso_checksum         = "${var.iso_file_checksum}"
  output_directory     = "output/{{build_name}}"
  ssh_username         = "${var.user_username}"
  ssh_password         = "${var.user_password}"
  shutdown_command     = "sudo shutdown -h now"
  guest_os_type        = "darwin20-64"
  cdrom_adapter_type   = "sata"
  disk_size            = "100000"
  disk_adapter_type    = "nvme"
  http_directory       = "http"
  network_adapter_type = "e1000e"
  disk_type_id         = "0"
  boot_wait            = "180s"
  ssh_timeout          = "12h"
  usb                  = "true"
  version              = "18"
    vmx_data = {
    "tools.upgrade.policy"         = "manual",
    "smc.present"                  = "TRUE",
    "smbios.restrictSerialCharset" = "TRUE",
    "ulm.disableMitigations"       = "TRUE",
    "ich7m.present"                = "TRUE"
    "hw.model"                     = "${var.hw_model}",
    "hw.model.reflectHost"         = "FALSE",
    "smbios.reflectHost"           = "FALSE",
    "board-id"                     = "${var.board_id}",
    "serialNumber"                 = "${var.serial_number}",
    "serialNumber.reflectHost"     = "FALSE",
    "SMBIOS.use12CharSerialNumber" = "TRUE"
  }
  boot_key_interval      = "20ms"
  boot_keygroup_interval = "2s"
  boot_command = [
    "<enter><wait10s>",
    "<leftSuperon><f5><leftSuperoff>",
    "<leftCtrlon><f2><leftCtrloff>",
    "u<down><down><down>",
    "<enter>",
    "<leftSuperon><f5><leftSuperoff><wait10>",
    "<leftCtrlon><f2><leftCtrloff>",
    "w<down><down>",
    "<enter>",
    "curl -o /var/root/packer.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/packer.pkg<enter>",
    "curl -o /var/root/setupsshlogin.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/setupsshlogin.pkg<enter>",
    "curl -o /var/root/bootstrap.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.sh<enter>",
    "chmod +x /var/root/bootstrap.sh<enter>",
    "/var/root/bootstrap.sh<enter>"
  ]
  cpus   = var.cpu_count
  cores  = var.cpu_count
  memory = var.ram_gb * 1024
}

# Base build
build {
  name    = "base"
  sources = ["sources.vmware-iso.macOS_11_base"]

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "2m" # needed for the first provisioner to let the OS finish booting
    script            = "scripts/os_settings.sh"
  }

  provisioner "file" {
    source      = "/Applications/VMware Fusion.app/Contents/Library/isoimages/darwin.iso"
    destination = "~/darwin.iso"
  }

  provisioner "shell" {
    expect_disconnect = true
    environment_vars = [
      "TOOLS_URL=${var.tools_url}"
    ]
    scripts = [
      "scripts/vmw_tools.sh"
    ]
  }
}

source "vmware-iso" "macOS_11_base" {
  display_name         = "macOS 11 base"
  vm_name              = "macOS_11_base"
  vmdk_name            = "macOS_11_base"
  iso_url              = "${var.iso_filename}"
  iso_checksum         = "${var.iso_file_checksum}"
  output_directory     = "output/{{build_name}}"
  ssh_username         = "${var.user_username}"
  ssh_password         = "${var.user_password}"
  shutdown_command     = "sudo shutdown -h now"
  guest_os_type        = "darwin20-64"
  cdrom_adapter_type   = "sata"
  disk_size            = "100000"
  disk_adapter_type    = "nvme"
  http_directory       = "http"
  network_adapter_type = "e1000e"
  disk_type_id         = "0"
  boot_wait            = "180s"
  ssh_timeout          = "12h"
  usb                  = "true"
  version              = "18"
    vmx_data = {
    "tools.upgrade.policy"         = "manual",
    "smc.present"                  = "TRUE",
    "smbios.restrictSerialCharset" = "TRUE",
    "ulm.disableMitigations"       = "TRUE",
    "ich7m.present"                = "TRUE"
    "hw.model"                     = "${var.hw_model}",
    "hw.model.reflectHost"         = "FALSE",
    "smbios.reflectHost"           = "FALSE",
    "board-id"                     = "${var.board_id}",
    "serialNumber"                 = "${var.serial_number}",
    "serialNumber.reflectHost"     = "FALSE",
    "SMBIOS.use12CharSerialNumber" = "TRUE"
  }
  boot_key_interval      = "20ms"
  boot_keygroup_interval = "2s"
  boot_command = [
    "<enter><wait10s>",
    "<leftSuperon><f5><leftSuperoff>",
    "<leftCtrlon><f2><leftCtrloff>",
    "u<down><down><down>",
    "<enter>",
    "<leftSuperon><f5><leftSuperoff><wait10>",
    "<leftCtrlon><f2><leftCtrloff>",
    "w<down><down>",
    "<enter>",
    "curl -o /var/root/packer.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/packer.pkg<enter>",
    "curl -o /var/root/setupsshlogin.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/setupsshlogin.pkg<enter>",
    "curl -o /var/root/bootstrap.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.sh<enter>",
    "chmod +x /var/root/bootstrap.sh<enter>",
    "/var/root/bootstrap.sh<enter>"
  ]
  cpus   = var.cpu_count
  cores  = var.cpu_count
  memory = var.ram_gb * 1024
}

# Customize build
source "vmware-vmx" "macOS_11_customize" {
  display_name     = "macOS 11 customize"
  vm_name          = "macOS_11_customize"
  vmdk_name        = "macOS_11_customize"
  ssh_username     = "packer"
  ssh_password     = "packer"
  boot_wait        = "30s"
  skip_compaction  = true
  source_path      = "output/macOS_11_base/macOS_11_base.vmx"
  shutdown_command = "sudo shutdown -h now"
  output_directory = "output/{{build_name}}"
}

build {
  name    = "customize"
  sources = ["sources.vmware-vmx.macOS_11_customize"]

  provisioner "file" {
    sources     = [var.xcode, var.xcode_cli]
    destination = "~/"
  }

  provisioner "shell" {
    expect_disconnect = true
    start_retry_timeout = "2h"
    environment_vars = [
      "SEEDING_PROGRAM=${var.seeding_program}"
    ] 
    scripts = [
      "scripts/xcode.sh",
      "scripts/softwareupdate.sh",
      "scripts/softwareupdate_complete.sh"
    ]
  }
}
