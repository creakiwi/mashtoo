#!/bin/sh

create_bootable_drive() {
  title "Create bootable device on ${USB_DEVICE}"

  echo_debug "temporarily disabled while unable to make uefi signed files"
  write_bios_uefi ${USB_DEVICE}
  local SDA2="$(mount_dir)/sda2"
  mount_partition "${USB_DEVICE}2" "${SDA2}"
  install_grub_bios "${USB_DEVICE}" "${SDA2}"
  install_grub_uefi "${USB_DEVICE}" "${SDA2}"
  unmount_partition "${SDA2}"
}