#!/bin/sh

handle_livecd() {
  title "Handle LiveCD"

  local LIVECD_EXTRACT_POINT=$(mount_dir)/livecd

  run "rm -rf ${LIVECD_EXTRACT_POINT}/"
  run "mkdir -p ${LIVECD_EXTRACT_POINT}"
  extract_iso "$(livecd_iso_path)" "${LIVECD_EXTRACT_POINT}"
#  touch ${LIVECD_EXTRACT_POINT}/.gitkeep
#  DRIVES=$(show_drives)
#  PART=$(show_drives 1)
#  echo ${USB_DEVICE}
#  for DRIVE in ${DRIVES}
#  do
#    echo ${DRIVE}
#  done
}
