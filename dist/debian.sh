#!/bin/sh

download_dist_debian() {
  case "${ARCH}" in
    # CPU 64
    amd64|x86_64)
      DEFINED_ARCH="amd64"
      ;;
    # CPU 32
    x86|i386|i486|i686)
      DEFINED_ARCH="i386"
      ;;
    # MICROCONTROLLER 64
    arm64|aarch64)
      DEFINED_ARCH="arm64"
      ;;
    *)
      exit_error "Unsupported arch '${ARCH}'"
      ;;
  esac

  _base_url="https://debian.osuosl.org/debian-cdimage/"
  if ! wget --spider -q "${_base_url}${VERSION}/"; then
    echo_warn "Unknown 'version ${FBOLD}${VERSION}${FBOLD_OFF}' for distribution '${FBOLD}${DIST}${FBOLD_OFF}'"
    echo_info "Use version '${FBOLD}current${FBOLD_OFF}' instead of '${FBOLD}${VERSION}${FBOLD_OFF}'"
    VERSION='current'
  fi

  _base_url="${_base_url}${VERSION}/${ARCH}/"
  if [ "${NETINST:-0}" -eq 1 ]; then
    _base_url="${_base_url}iso-cd/"
  else
    _base_url="${_base_url}iso-dvd/"
  fi

  _sha512sums="${_base_url}SHA512SUMS"

  _iso_url=$(wget -q -O - "${_sha512sums}" | head -n 1 | awk '{print $2}')
  _iso_url_path="${_base_url}${_iso_url}"
  _target_iso="$(livecd_iso_path)"
  
  download "${_iso_url_path}" "${_target_iso}"
}

extract_initramfs_debian() {
  _initrd_file="${LIVECD_EXTRACT_POINT}/install.amd/initrd.gz"

  # Use a subshell to safely change directories and execute cpio
  (
    cd "${INITRAMFS_EXTRACT_POINT}" || exit_error "Unable to access ${INITRAMFS_EXTRACT_POINT}"
    run "zcat \"${_initrd_file}\" | cpio -imdv"
  )
}

repack_initramfs_debian() {
  _initrd_file="${LIVECD_EXTRACT_POINT}/install.amd/initrd.gz"

  # Use a subshell to safely change directories and repack initramfs
  (
    cd "${INITRAMFS_EXTRACT_POINT}" || exit_error "Unable to access ${INITRAMFS_EXTRACT_POINT}"
    run "find . | cpio -o -H newc | gzip -9 > \"${_initrd_file}\""
  )
}
