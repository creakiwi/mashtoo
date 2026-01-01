###########################
# DISKS/DRIVES/PARTITIONS #
###########################

# usage: show_partitions [with_partitions](bool:0)
drive_list() {
  if [ "$#" -eq 1 ] && [ "$1" = "1" ]
  then
    lsblk -n -l -p -o NAME
  else
    lsblk -n -l -d -p -o NAME
  fi
}

# usage: show_drives_info [with_partitions](bool:0)
drive_list_info() {
  if [ "$#" -eq 1 ] && [ "$1" = "1" ]
  then
    lsblk -p -n -o NAME,SIZE
  else
    lsblk -p -n -d -o NAME,SIZE
  fi
}

## /desc Check if a drive exists or not
## /usage drive_exists <device>
## /param <drive> (string)
## /return bool 0 if exists, 1 else (exist-status boolean)
drive_exists() {
	check_arguments $# 1 "drive_exists <drive>(string)"
	local DRIVE=${1}

  [ -b "${DRIVE}" ]
}

## /desc Check if a drive exists and is in the defined list
## /usage drive_exists_against <drive> <drive_list>
## /param <drive> (string) /dev/sda The drive to check
## /param <drive_list> (string) Some space separated drives list
## /return bool 0 if exists and in list, 1 else (exist-status boolean)
drive_exists_against() {
	check_arguments $# 2 "drive_exists <drive>(string) <drive_list>(string)"
  local DRIVE=${1}
  local DRIVE_LIST=${2}

  for d in ${DRIVE_LIST}; do
    if drive_exists "${d}" && [ "${DRIVE}" = "${d}" ]; then
      return 0
    fi
  done

  return 1
}

ifndef_BOOT_FIRMWARE() {
  if [ -z ${BOOT_FIRMWARE} ]; then
    echo "Boot firmware"
    echo "1. BIOS"
    echo "2. UEFI"
    ask_set_if_unset BOOT_FIRMWARE "Please select (bios|uefi)" "uefi"
    case ${BOOT_FIRMWARE} in
      1|bios|BIOS)
        BOOT_FIRMWARE="bios"
        ;;
      2|uefi|UEFI)
        BOOT_FIRMWARE="uefi"
        ;;
      *)
        exit_error "Undefined boot firmware \"${BOOT_FIRMWARE}\""
        ;;
    esac
  fi
}

# usage: clean_random <drive>(string)
clean_random() {
	check_arguments $# 1 "clean_random <drive>(string)"
	local DRIVE=${1}

	dd if=/dev/urandom of=${DRIVE} && sync
}

# usage: clean_zero <drive>(string)
clean_zero() {
	check_arguments $# 1 "clean_zero <drive>(string)"
	local DRIVE=${1}

	dd if=/dev/zero of=${DRIVE} && sync
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

  extract_iso_xorriso ${ISO_FILE} ${EXTRACT_DIR}
}

# usage: extract_iso_xorriso <iso_file>(string) <extract_dir>(string)
extract_iso_xorriso() {
	check_arguments $# 2 "extract_iso_xorriso <iso_file>(string) <extract_dir>(string)"
	local ISO_FILE=${1}
	local EXTRACT_DIR=${2}

  run "xorriso -osirrox on -indev ${ISO_FILE} -extract / ${EXTRACT_DIR}"
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

# usage: extract_boot_info <iso_file>(string) <extract_name>(string)
extract_boot_info() {
  check_arguments $# 2 "extract_boot_info <iso_file>(string) <extract_name>(string)"
  local ISO_FILE=${1}
  local EXTRACT_NAME=${2}

  run "xorriso -indev ${ISO_FILE} -report_el_torito as_mkisofs > ${EXTRACT_NAME}"
}

## /desc Extract a SquashFS filesystem
## /usage extract_squashfs <squashfs_file> <extract_dir>
## /param <squashfs_file> (string) path/to/file.squashfs The SquashFS file to extract
## /param <extract_dir> (string) path/to/existing/extract/directory The destination directory where the SquashFS file will be extracted
extract_squashfs() {
  check_arguments $# 2 "extract_squashfs <squashfs_file>(string) <extract_dir>(string)"
  local SQUASHFS_FILE=${1}
  local EXTRACT_DIR=${2}

  run "unsquashfs -d ${EXTRACT_DIR} ${SQUASHFS_FILE}"
}

## /desc Create/recreate a SquashFS filesystem from directory
## /usage repack_squashfs <directory> <squashfs_file> [options]
## /param <directory> (string) path/to/directory The directory you want to create a SquashFS filesystem from
## /param <squashfs_file> (string) path/to/file.squashfs The final SquashFS filesystem name
## /param [options] (string) If provided will be appended to "mksquashfs". Please see "mksquashfs" options
repack_squashfs() {
  check_arguments $# 2 "repack_squashfs <directory>(string) <squashfs_file>(string) [options](string)"
  local DIRECTORY=${1}
  local SQUASHFS_FILE=${2}

  OPTIONS=""
  if [ -n "${3}" ]
  then
    OPTIONS=" ${3}"
  fi

  run "mksquashfs ${DIRECTORY} ${SQUASHFS_FILE}${OPTIONS}"
}

## /desc Unimplemented
## /note Searching for others ways to rebuilding ISO
repack_iso() {
  local var
}

## /desc Rebuild an ISO from extracted one with its report
## /usage repack_iso_xorriso_from_report <report_file> <extract_dir> <output_iso>
## /param <report_file> (string) path/to/report_file Report file created "extract_boot_info"
## /param <extract_dir> (string) path/to/extract_dir A directory previously extracted with "extract_iso"
## /param <output_iso> (string) path/to/new-iso-file.iso The ISO file you want to create
repack_iso_xorriso_from_report() {
  check_arguments $# 3 "repack_iso_xorriso_from_report <report_file>(string) <extract_dir>(string) <output_iso>(string)"
  local REPORT_FILE=${1}
  local EXTRACT_DIR=${2}
  local OUTPUT_ISO=${3}

  if [ ! -f "${REPORT_FILE}" ]; then
    exit_error "Report file not found: ${REPORT_FILE}"
  fi

  REPORT_CONTENT=$(tr '\n' ' ' < "$REPORT_FILE")
  run "xorriso -as mkisofs ${REPORT_CONTENT} -o ${OUTPUT_ISO} ${EXTRACT_DIR}"
}

## /desc Copy an ISO file to a drive
## /usage iso_to_device <iso_file> <drive>
## /param <iso_file> (string) path/to/new-iso-file.iso The ISO file you want to write
## /param <drive> (string) /dev/sdX The drive you want to write/"burn"
## /deprecated should be renamed to iso_to_drive
iso_to_device() {
  check_arguments $# 2 "iso_to_device <iso_file>(string) <drive>(string)"
  local ISO_FILE=${1}
  local DRIVE=${2}

  if [ ! -f "${ISO_FILE}" ]; then
    exit_error "ISO file not found: ${ISO_FILE}"
  fi

  run "dd if=${ISO_FILE} of=${DRIVE} bs=4096 && sync"
}
