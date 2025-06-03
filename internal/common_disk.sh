###########################
# DISKS/DRIVES/PARTITIONS #
###########################

# usage: show_partitions [with_partitions](bool:0)
show_drives() {
  if [ $# -eq 1 ]
  then
    echo $(lsblk -n -o NAME | sed 's|^|/dev/|')
  else
    echo $(lsblk -n -d -o NAME | sed 's|^|/dev/|')
  fi
}

# usage: drive_exists <drive>(string): (bool)
drive_exists() {
	check_arguments $# 1 "drive_exists <drive>(string)"

  local DRIVES=$(show_drives)
  local DRIVE_TO_CHECK=${1}
  local DRIVE_EXISTS=0

  for DRIVE in ${DRIVES}
  do
    if [ "${DRIVE}" = "${DRIVE_TO_CHECK}" ]
    then
      DRIVE_EXISTS=1
    fi
  done

  echo ${DRIVE_EXISTS}
}

# usage: clean_random <drive>(string)
clean_random() {
	check_arguments $# 1 "clean_random <drive>(string)"
	local PARTITION=${1}

	dd if=/dev/urandom of=${PARTITION} && sync
}

# usage: clean_zero <drive>(string)
clean_zero() {
	check_arguments $# 1 "clean_zero <drive>(string)"
	local PARTITION=${1}

	dd if=/dev/zero of=${PARTITION} && sync
}

# usage: wipe_drive <drive>(string)
wipe_drive() {
	check_arguments $# 1 "wipe_drive <drive>(string)"
	local DRIVE=${1}

  WIPEOUT=0
#  if [ ${DEBUG} = "1" ]
#  then
#    echo "lol"
#  fi
  run_quiet "wipefs -a ${DRIVE}"
}

# usage: write_bios_uefi <drive>(string)
write_bios_uefi() {
	check_arguments $# 1 "write_bios_uefi <drive>(string)"
	local DRIVE=${1}

  echo_info "Create ${FBOLD}bios${FBOLD_OFF} partition of ${FBOLD}1MiB${FBOLD_OFF} on ${FBOLD}${DRIVE}1${FBOLD_OFF}"
  echo_info "Create ${FBOLD}uefi${FBOLD_OFF} partition of ${FBOLD}512MiB${FBOLD_OFF} on ${FBOLD}${DRIVE}2${FBOLD_OFF}"
  sfdisk ${DRIVE} <<-EOF
    label: gpt
    1 : size=1MiB, type=21686148-6449-6E6F-744E-656564454649, name="bios"
    2 : size=512MiB, type=c12a7328-f81f-11d2-ba4b-00a0c93ec93b, name="uefi"
EOF

  run_quiet "mkfs.vfat -F32 -n 'UEFI' ${DRIVE}2"
}

# usage: mount_partition <partition>(string) <mount_point>(string)
mount_partition() {
	check_arguments $# 2 "mount_partition <partition>(string) <mount_point>(string)"
	local PARTITION=${1}
	local MOUNT_POINT=${2}

	echo_todo "Check ${MOUNT_POINT} exists and rwx"
	run "mount ${PARTITION} ${MOUNT_POINT}"
}
# usage: unmount_partition <mount_point>(string)
unmount_partition() {
	check_arguments $# 1 "unmount_partition <mount_point>(string)"
	local PARTITION=${1}

run "umount ${PARTITION}"
}

# usage: install_grub_bios <drive>(string) <mount_point>(string)
install_grub_bios() {
	check_arguments $# 2 "install_grub_bios <drive>(string) <mount_point>(string)"
	local DRIVE=${1}
	local MOUNT_POINT=${2}

  run_quiet "grub-install --target=i386-pc --boot-directory=${MOUNT_POINT}/boot --recheck ${DRIVE}"
}

# usage: install_grub_uefi:
install_grub_uefi() {
	check_arguments $# 2 "install_grub_uefi <drive>(string) <mount_point>(string)"
	local DRIVE=${1}
	local MOUNT_POINT=${2}

  run_quiet "grub-install --target=x86_64-efi --efi-directory=${MOUNT_POINT} --boot-directory=${MOUNT_POINT}/boot --removable --recheck"
# SIGNED does not exists on alpine
#  run "grub-install --target=x86_64-efi-signed --efi-directory=${MOUNT_POINT} --boot-directory=${MOUNT_POINT}/boot --removable --recheck"
}

# usage: extract_iso: <iso_file>(string) <extract_dir>(string)
extract_iso() {
	check_arguments $# 2 "extract_iso <iso_file>(string) <extract_dir>(string)"
	local ISO_FILE=${1}
	local EXTRACT_DIR=${2}

  extract_iso_bsdtar ${ISO_FILE} ${EXTRACT_DIR}
}

# usage: extract_iso_bsdtar: <iso_file>(string) <extract_dir>(string)
extract_iso_bsdtar() {
	check_arguments $# 2 "extract_iso_bsdtar <iso_file>(string) <extract_dir>(string)"
	local ISO_FILE=${1}
	local EXTRACT_DIR=${2}

  run "bsdtar -xf ${ISO_FILE} -C ${EXTRACT_DIR}"
}

# usage: extract_iso_7z: <iso_file>(string) <extract_dir>(string)
extract_iso_7z() {
	check_arguments $# 2 "extract_iso_7z <iso_file>(string) <extract_dir>(string)"
	local ISO_FILE=${1}
	local EXTRACT_DIR=${2}

  run "7z x ${ISO_FILE} -o${EXTRACT_DIR}"
}