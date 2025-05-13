#!/bin/sh

download_dir() {
  echo "${MAIN_DIR}/downloads"
}
mount_dir() {
  echo "${MAIN_DIR}/mnt"
}

livecd_iso() {
  local LIVECD_ISO=livecd-${DIST}-${ARCH}-${VERSION}.iso
  if [ ${NETINST} -eq 1 ]
  then
    local LIVECD_ISO=livecd-${DIST}-${ARCH}-${VERSION}-netinstall.iso
  fi

  echo ${LIVECD_ISO}
}

livecd_iso_path() {
  local DOWNLOAD_DIR=`download_dir`
  local LIVECD_ISO=`livecd_iso`

  echo "${DOWNLOAD_DIR}/${LIVECD_ISO}"
}
