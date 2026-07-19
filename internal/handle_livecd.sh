copy_files_to_initramfs() {
  run "cp -R $(custom_dir)/initramfs/. ${INITRAMFS_EXTRACT_POINT}/"
}

live_in_initramfs() {
  if command -v live_in_initramfs_callback >/dev/null 2>&1
  then
    echo_ok "Entering user defined 'live_in_initramfs_callback'"
    live_in_initramfs_callback
  fi

  if command -v live_in_initramfs_callback_${DIST} >/dev/null 2>&1
  then
    echo_ok "Entering user defined 'live_in_initramfs_callback_${DIST}'"
    live_in_initramfs_callback_${DIST}
  fi
}


handle_livecd() {
  title "Handle LiveCD"

  local LIVECD_EXTRACT_POINT=$(mount_dir)/livecd
  local INITRAMFS_EXTRACT_POINT=$(mount_dir)/initramfs

  run "rm -rf ${LIVECD_EXTRACT_POINT}/"
  run "mkdir -p ${LIVECD_EXTRACT_POINT}"
  run "touch ${LIVECD_EXTRACT_POINT}/.gitkeep"
  extract_iso "$(livecd_iso_path)" "${LIVECD_EXTRACT_POINT}"
  extract_boot_info "$(livecd_iso_path)" "$(tmp_dir)/boot_info"

  run "rm -rf ${INITRAMFS_EXTRACT_POINT}/"
  run "mkdir -p ${INITRAMFS_EXTRACT_POINT}"
  run "touch ${INITRAMFS_EXTRACT_POINT}/.gitkeep"
  if command -v extract_initramfs_${DIST} >/dev/null 2>&1
  then
    echo_ok "Entering '${DIST}' initramfs extract process"
    extract_initramfs_${DIST}
  else
    exit_error "Distribution '${FBOLD}${DIST}${FBOLD_OFF}' should be handled but no '${FBOLD}extract_initramfs_${DIST}${FBOLD_OFF}' function found in '${FBOLD}${DIST_FILE}${FBOLD_OFF}'."
  fi

  copy_files_to_initramfs
  live_in_initramfs

  reprap ${INITRAMFS_EXTRACT_POINT}/opt/

  if command -v repack_initramfs_${DIST} >/dev/null 2>&1
  then
    echo_ok "Entering '${DIST}' repack initramfs process"
    repack_initramfs_${DIST}
  else
    exit_error "Distribution '${FBOLD}${DIST}${FBOLD_OFF}' should be handled but no '${FBOLD}repack_initramfs_${DIST}${FBOLD_OFF}' function found in '${FBOLD}${DIST_FILE}${FBOLD_OFF}'."
  fi

  repack_iso_xorriso_from_report "$(tmp_dir)/boot_info" "${LIVECD_EXTRACT_POINT}" "$(tmp_dir)/$(livecd_name)-mashtoo.iso"
  iso_to_device "$(tmp_dir)/$(livecd_name)-mashtoo.iso" "${USB_DEVICE}"
#  DRIVES=$(drive_list)
#  PART=$(drive_list_info 1)
#  echo "DEVICE IZ ${USB_DEVICE}"
#  for DRIVE in ${DRIVES}
#  do
#    echo ${DRIVE}
#  done
}
