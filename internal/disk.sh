## /desc Show drives and partitions list if specified
## /usage drive_list [with_partitions](bool)
## /param [with_partitions] (bool) Include partitions or not
drive_list() {
  if [ "$#" -eq 1 ] && [ "${1}" = "1" ]; then
    lsblk -n -l -p -o NAME
  else
    lsblk -n -l -d -p -o NAME
  fi
}

## /desc Show drives and partitions informations (size) if specified
## /usage drive_list_info [with_partitions](bool)
## /param [with_partitions] (bool) Include partitions or not
drive_list_info() {
  if [ "$#" -eq 1 ] && [ "${1}" = "1" ]; then
    lsblk -p -n -o NAME,SIZE
  else
    lsblk -p -n -d -o NAME,SIZE
  fi
}

## /desc Check if a drive exists or not
## /usage drive_exists <device>(string)
## /param <drive> (string)
## /return bool 0 if exists, 1 else (exist-status boolean)
drive_exists() {
	check_arguments $# 1 "drive_exists <drive>(string)"
  [ -b "${1}" ]
}

## /desc Check if a drive exists and is in the defined list
## /usage drive_exists_against <drive>(string) <drive_list>(stray)
## /param <drive> (string) /dev/sda The drive to check
## /param <drive_list> (string) Some space separated drives list
## /return bool 0 if exists and in list, 1 else (exist-status boolean)
drive_exists_against() {
	check_arguments $# 2 "drive_exists_against <drive>(string) <drive_list>(string)"
  local DRIVE=${1}
  local DRIVE_LIST=${2}

  for d in ${DRIVE_LIST}; do
    if drive_exists "${d}" && [ "${DRIVE}" = "${d}" ]; then
      return 0
    fi
  done

  return 1
}

_device_type() {
  check_arguments $# 1 "device_type <drive> (string)"
  local _DEVICE="${1}"

  if ! drive_exists "${_DEVICE}"; then
    exit_error "Device ${_DEVICE} does not exists"
  fi

  lsblk -d -n -o TYPE "${_DEVICE}" 2>/dev/null
}

device_is_partition() {
  check_arguments $# 1 "device_is_partition <drive> (string)"
  [ "$(_device_type "${1}")" = "part" ]
}

device_is_disk() {
  check_arguments $# 1 "device_is_disk <drive> (string)"
  [ "$(_device_type "${1}")" = "disk" ]
}

device_size() {
  check_arguments $# 1 "device_size <drive> (string) [human_readable](bool)"
  local _DEVICE="${1}"

  if ! drive_exists "${_DEVICE}"; then
    exit_error "Device ${_DEVICE} does not exists"
  fi

  if [ $# -eq 2 ]; then
    lsblk -d -n -o SIZE "${_DEVICE}" 2>/dev/null
  else
    blockdev --getsize64 "${_DEVICE}" 2>/dev/null
  fi
}

## /desc Validate filesystem against mkfs command available on system
## /usage _make_filesystem_type_validate <type>(string) [exit](bool)
## /param <type> (string) Filesystem type to validate
## /param [exit] (bool) If specified, exit on error
_make_filesystem_type_validate() {
  check_arguments $# 1 "_make_filesystem_type_validate <type>(string) [exit](bool)"
  local _TYPE=$(lower "${1}")
  local _EXIT="${2}"

  case "${_TYPE}" in
    bfs|btrfs|cramfs|exfat|ext2|ext3|ext4|f2fs|fat|jfs|minix|msdos|ntfs|reiserfs|vfat|xfs)
      if command_exists "mkfs.${_TYPE}"; then
        return 0
      else
        if [ -n "${_EXIT}" ]; then
          exit_error "Required command 'mkfs.${_TYPE}' not found"
        else
          log_error "Required command 'mkfs.${_TYPE}' not found"
          return 1
        fi
      fi
      ;;
    swap)
      if command_exists "mkswap" && command_exists "swapon"; then
        return 0
      else
        if [ -n "${_EXIT}" ]; then
          exit_error "Required command 'mkswap' or 'swapon' not found"
        else
          log_error "Required command 'mkswap' or 'swapon' not found"
          return 1
        fi
      fi
      ;;
    *)
      if [ -n "${_EXIT}" ]; then
        exit_error "Unsupported filesystem type \"${_TYPE}\""
      else
        log_error  "Unsupported filesystem type \"${_TYPE}\""
        return 1
      fi
      ;;
  esac
}

make_filesystem() {
  check_arguments $# 2 "make_filesystem <type>(string) <device>(string)"
  local _TYPE=$(lower ${1})
  local _DEVICE="${2}"
  local _OPTIONS=""
  _make_filesystem_type_validate "${_TYPE}" 1
  if ! device_is_partition "${_DEVICE}"; then
    exit_error "Device ${_DEVICE} is not a partition."
  fi

  if [ "${_TYPE}" = "ext4" ] && [ "$(device_size "${_DEVICE}")" -lt $((2**33)) ]; then
    _OPTIONS=" -T small"
  fi

  case "${_TYPE}" in
    bfs|btrfs|cramfs|exfat|ext2|ext3|ext4|f2fs|fat|jfs|minix|msdos|ntfs|reiserfs|vfat|xfs)
      if command_exists "mkfs.${_TYPE}"; then
        run "mkfs.${_TYPE}${_OPTIONS} ${_DEVICE}"
      fi
      ;;
    swap)
      run "mkswap ${_DEVICE}"
      run "swapon ${_DEVICE}"
      ;;
  esac
}
