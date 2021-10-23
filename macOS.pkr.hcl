packer {
  required_version = ">= 1.7.0"
}

variable "iso_file_checksum" {
  type    = string
  default = "file:install_bits/macOS_1120_installer.shasum"
}

variable "iso_filename" {
  type    = string
  default = "install_bits/macOS_1120_installer.iso"
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
  default = "2"
}

variable "ram_gb" {
  type    = number
  default = "6"
}

variable "xcode_cli" {
  type    = string
  default = "install_bits/Command_Line_Tools_for_Xcode_12.4.dmg"
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

variable "snapshot_linked" {
  type    = bool
  default = false
}

# Set this to DeveloperSeed if you want prerelease software updates
variable "seeding_program" {
  type    = string
  default = "none"
}

variable "tools_path" {
  type    = string
  default = "/Applications/VMware Fusion.app/Contents/Library/isoimages/darwin.iso"
}

variable "boot_key_interval_iso" {
  type    = string
  default = "150ms"
}

variable "boot_wait_iso" {
  type    = string
  default = "300s"
}

variable "boot_keygroup_interval_iso" {
  type    = string
  default = "4s"
}

variable "macos_version" {
  type    = string
  default = "12.0"
}

variable "bootstrapper_script" {
  type    = list(string)
  default = ["sw_vers"]
}

# source from iso
source "vmware-iso" "macOS" {
  display_name         = "{{build_name}} ${var.macos_version} base"
  vm_name              = "{{build_name}}_${var.macos_version}_base"
  vmdk_name            = "{{build_name}}_${var.macos_version}_base"
  iso_url              = "${var.iso_filename}"
  iso_checksum         = "${var.iso_file_checksum}"
  output_directory     = "output/{{build_name}}_${var.macos_version}_base"
  ssh_username         = "${var.user_username}"
  ssh_password         = "${var.user_password}"
  shutdown_command     = "sudo shutdown -h now"
  guest_os_type        = "darwin20-64"
  cdrom_adapter_type   = "sata"
  disk_size            = "100000"
  disk_adapter_type    = "nvme"
  http_directory       = "http"
  network_adapter_type = "vmxnet3"
  disk_type_id         = "0"
  ssh_timeout          = "12h"
  usb                  = "true"
  version              = "19"
  cpus                 = var.cpu_count
  cores                = var.cpu_count
  memory               = var.ram_gb * 1024
  vmx_data = {
    "tools.upgrade.policy"         = "manual"
    "smc.present"                  = "TRUE"
    "smbios.restrictSerialCharset" = "TRUE"
    "ulm.disableMitigations"       = "TRUE"
    "ich7m.present"                = "TRUE"
    "hw.model"                     = "${var.hw_model}"
    "hw.model.reflectHost"         = "FALSE"
    "smbios.reflectHost"           = "FALSE"
    "board-id"                     = "${var.board_id}"
    "serialNumber"                 = "${var.serial_number}"
    "serialNumber.reflectHost"     = "FALSE"
    "SMBIOS.use12CharSerialNumber" = "TRUE"
    "usb_xhci:4.deviceType"        = "hid"
    "usb_xhci:4.parent"            = "-1"
    "usb_xhci:4.port"              = "4"
    "usb_xhci:4.present"           = "TRUE"
    "usb_xhci:6.deviceType"        = "hub"
    "usb_xhci:6.parent"            = "-1"
    "usb_xhci:6.port"              = "6"
    "usb_xhci:6.present"           = "TRUE"
    "usb_xhci:6.speed"             = "2"
    "usb_xhci:7.deviceType"        = "hub"
    "usb_xhci:7.parent"            = "-1"
    "usb_xhci:7.port"              = "7"
    "usb_xhci:7.present"           = "TRUE"
    "usb_xhci:7.speed"             = "4"
    "usb_xhci.pciSlotNumber"       = "192"
    "usb_xhci.present"             = "TRUE"
  }
  boot_wait              = var.boot_wait_iso
  boot_key_interval      = var.boot_key_interval_iso
  boot_keygroup_interval = var.boot_keygroup_interval_iso
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
}

# Customize build from existing vm
source "vmware-vmx" "macOS" {
  display_name     = "{{build_name}} ${var.macos_version}"
  vm_name          = "{{build_name}}_${var.macos_version}"
  vmdk_name        = "{{build_name}}_${var.macos_version}"
  ssh_username     = "${var.user_username}"
  ssh_password     = "${var.user_password}"
  boot_wait        = "30s"
  skip_compaction  = true
  linked           = var.snapshot_linked
  source_path      = "output/{{build_name}}_${var.macos_version}_base/macOS_${var.macos_version}_base.vmx"
  shutdown_command = "sudo shutdown -h now"
  output_directory = "output/{{build_name}}_${var.macos_version}"
  vmx_data = {
    "nvram" = "../../scripts/disablesip.nvram"
  }
  vmx_data_post = {
    "nvram" = "{{build_name}}_${var.macos_version}.nvram"
  }
}

# Base build
build {
  name = "base"
  sources = [
    "sources.vmware-iso.macOS"
  ]

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "2m" # needed for the first provisioner to let the OS finish booting
    script            = "scripts/os_settings.sh"
  }

  provisioner "file" {
    source      = var.tools_path
    destination = "~/darwin.iso"
  }

  provisioner "shell" {
    expect_disconnect = true
    scripts = [
      "scripts/vmw_tools.sh"
    ]
  }
}

build {
  name    = "customize"
  sources = ["sources.vmware-vmx.macOS"]

  provisioner "file" {
    sources     = [var.xcode_cli, "submodules/tccutil/tccutil.py"]
    destination = "~/"
  }

  provisioner "shell" {
    environment_vars = [
      "USER_PASSWORD=${var.user_password}"
    ]
    expect_disconnect   = true
    script = "scripts/os_configure.sh"
  }

  provisioner "shell" {
    expect_disconnect   = true
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

  # optionally call external bootstrap script set by var.bootstrapper_script
  provisioner "shell" {
    expect_disconnect = true
    inline            = var.bootstrapper_script
  }

  post-processor "shell-local" {
    inline = ["scripts/vmx_cleanup.sh output/{{build_name}}_${var.macos_version}/macOS_${var.macos_version}.vmx"]
  }
}
