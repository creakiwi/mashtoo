#!/bin/sh

download_dir() {
  echo "${MASHTOO_DIR}/downloads"
}
mount_dir() {

  echo "${MASHTOO_DIR}/mnt"
}

custom_generic_dir() {
  echo "${MASHTOO_DIR}/custom/generic"
}

custom_dist_dir() {
  echo "${MASHTOO_DIR}/custom/${DIST}"
}

tmp_dir() {
	echo "${MASHTOO_DIR}/tmp"
}

tpl_dir() {
  echo "${MASHTOO_DIR}/templates"
}

logs_dir() {
	echo "${MASHTOO_DIR}/tmp"
}

secrets_dir() {
  echo "${MASHTOO_DIR}/secrets"
}

cache_dir() {
	mkdir -p "${MASHTOO_DIR}/cache"
	echo "${MASHTOO_DIR}/cache"
}

extracted_iso_dir() {
  echo "$(mount_dir)/livecd"
}

livecd_name() {
  local LIVECD_NAME="livecd-${DIST}-${ARCH}-${VERSION}"
  if [ "${NETINST:-0}" -eq 1 ]; then
    LIVECD_NAME="livecd-${DIST}-${ARCH}-${VERSION}-netinstall"
  fi

  echo "${LIVECD_NAME}"
}

livecd_iso() {
  local LIVECD_ISO="livecd-${DIST}-${ARCH}-${VERSION}.iso"
  if [ "${NETINST:-0}" -eq 1 ]; then
    LIVECD_ISO="livecd-${DIST}-${ARCH}-${VERSION}-netinstall.iso"
  fi

  echo "${LIVECD_ISO}"
}

livecd_iso_path() {
  echo "$(download_dir)/$(livecd_iso)"
}
