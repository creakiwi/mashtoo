#!/bin/sh

download_dir() {
  echo "${MASHTOO_DIR}/downloads"
}
mount_dir() {
  echo "${MASHTOO_DIR}/mnt"
}

custom_dir() {
  echo "${MASHTOO_DIR}/custom"
}

tmp_dir() {
  echo "${MASHTOO_DIR}/tmp"
}

tpl_dir() {
  echo "${MASHTOO_DIR}/templates"
}

secrets_dir() {
  echo "${MASHTOO_DIR}/secrets"
}

extracted_iso_dir() {
  echo "$(mount_dir)/livecd"
}

livecd_name() {
  local LIVECD_NAME=livecd-${DIST}-${ARCH}-${VERSION}
  if [ ${NETINST} -eq 1 ]
  then
    local LIVECD_NAME=livecd-${DIST}-${ARCH}-${VERSION}-netinstall
  fi

  echo ${LIVECD_NAME}
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
  echo "$(download_dir)/$(livecd_iso)"
}
