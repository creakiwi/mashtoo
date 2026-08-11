#!/bin/sh

# required download_dist_gentoo(void): exit on error
# required extract_initramfs_gentoo(void): exit on error
# optional abstract checksum_dist_gentoo(void): exit on error

download_dist_gentoo() {
  case "${ARCH}" in
    # CPU 64
    amd64|x86_64)
      DEFINED_ARCH="amd64"
      ;;
    # CPU 32
    x86|i386|i486|i686)
      DEFINED_ARCH="x86"
      ;;
    # MICROCONTROLLER 64
    arm64|aarch64)
      DEFINED_ARCH="arm64"
      ;;
    *)
      if [ "${ARCH}" = "arm" ]; then
        echo_warn "Arch '${ARCH}' does not have install CD"
      fi
      exit_error "Unsupported arch '${ARCH}'"
      ;;
  esac

  if [ "${VERSION}" != "latest" ]; then
    echo_warn "Ignore version '${VERSION}' for '${FBOLD}${DIST}${FBOLD_OFF}', always use 'latest'"
    VERSION="latest"
  fi

  _base_url="https://gentoo.mirrors.ovh.net/gentoo-distfiles/releases/${DEFINED_ARCH}/autobuilds/"
  _gpg_iso_url="${_base_url}latest-"
  if [ "${NETINST:-0}" -eq 1 ]; then
    _gpg_iso_url="${_gpg_iso_url}install-${DEFINED_ARCH}-minimal.txt"
  else
    _gpg_iso_url="${_gpg_iso_url}livegui-${DEFINED_ARCH}.txt"
  fi

  _iso_url=$(wget -q -O - "${_gpg_iso_url}" | grep -oE '[0-9]{8}T[0-9]{6}Z/.*\.iso')
  _iso_url_path="${_base_url}${_iso_url}"
  _target_iso="$(livecd_iso_path)"

  if [ -f "${_target_iso}" ]; then
    echo "already downloaded"
  else
    download "${_iso_url_path}" "${_target_iso}"
    download "${_iso_url_path}.sha256" "${_target_iso}.sha256"
    download "${_iso_url_path}.asc" "${_target_iso}.asc"
  fi
  echo_ok "Downloaded needed files"
}

checksum_dist_gentoo() {
  echo_warn "Currently does not verify gpg keys as files are downloaded from trusted source."

  _target_iso="$(livecd_iso_path)"
  VERIFIED_SHA256=$(checksum_extract_from_file "${_target_iso}.sha256")
  COMPUTED_SHA256=$(checksum_extract_from_string "$(sha256sum "${_target_iso}")")
  echo_info "Verified checksum: ${FBOLD}${VERIFIED_SHA256}${FBOLD_OFF}"
  echo_info "Computed checksum: ${FBOLD}${COMPUTED_SHA256}${FBOLD_OFF}"
  if [ "${VERIFIED_SHA256}" = "${COMPUTED_SHA256}" ]; then
    echo_ok "Checksums matches"
  else
    echo_warn "Maybe cleanup $(download_dir) ?"
    exit_error "Checksums does not match"
  fi
}

extract_initramfs_gentoo() {
  _initramfs_squash_file="${LIVECD_EXTRACT_POINT}/image.squashfs"

  extract_squashfs "${_initramfs_squash_file}" "${INITRAMFS_EXTRACT_POINT}"
}

repack_initramfs_gentoo() {
  _initramfs_squash_file="${LIVECD_EXTRACT_POINT}/image.squashfs"
  _compression="xz"

  echo_warn "Use ${_compression} algorithm"
  repack_squashfs "${INITRAMFS_EXTRACT_POINT}" "${_initramfs_squash_file}" "-comp ${_compression} -noappend" # -processors $(nproc)"
}

live_in_initramfs_callback_gentoo() {
  set_locale "${LOCALE_KEYMAP}" "${LOCALE_LANG}" "${INITRAMFS_EXTRACT_POINT}"
  ssh_at_boot "${INITRAMFS_EXTRACT_POINT}"
  download_stage3 "${INITRAMFS_EXTRACT_POINT}"
  mashtoo_installer_at_startup "${INITRAMFS_EXTRACT_POINT}"
}
