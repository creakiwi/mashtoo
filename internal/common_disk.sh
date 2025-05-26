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