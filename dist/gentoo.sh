#!/bin/sh

# required download_dist_{distribution}(void): exit on error
# required extract_initramfs_{distribution(void): exit_on_error
# optional abstract checksum_dist_{gentoo}(void): exit on error

download_dist_gentoo() {
  case ${ARCH} in
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
      if [ "${ARCH}" = "arm" ]
      then
        echo_warn "Arch '${ARCH}' does not have install CD"
      fi
      exit_error "Unsupported arch '${ARCH}'"
      ;;
  esac

  if [ ${VERSION} != 'latest' ]
  then
    echo_warn "Ignore version '${VERSION}' for '${FBOLD}${DIST}${FBOLD_OFF}', always use 'latest'"
    VERSION="latest"
  fi

  local BASE_URL="https://gentoo.osuosl.org/releases/${DEFINED_ARCH}/autobuilds/"
  local GPG_ISO_URL="${BASE_URL}latest-"
  if [ ${NETINST} -eq 1 ]
  then
    GPG_ISO_URL="${GPG_ISO_URL}install-${DEFINED_ARCH}-minimal.txt"
  else
    GPG_ISO_URL="${GPG_ISO_URL}livegui-${DEFINED_ARCH}.txt"
  fi
  local ISO_URL=$(wget -q -O - "${GPG_ISO_URL}" | grep -oE '[0-9]{8}T[0-9]{6}Z/.*\.iso')
  local ISO_URL_PATH="${BASE_URL}${ISO_URL}"
  if [ -f `livecd_iso_path` ]
  then
    echo "already downloaded"
  else
    download "${ISO_URL_PATH}" "`livecd_iso_path`"
    download "${ISO_URL_PATH}.sha256" "`livecd_iso_path`.sha256"
    download "${ISO_URL_PATH}.asc" "`livecd_iso_path`.asc"
  fi
  echo_ok "Downloaded needed files"
}

checksum_dist_gentoo() {
  if [ 1 == 1 ]
  then
    echo_warn "Currently does not verify gpg keys as files are downloaded from trusted source."
  else
    gpg --keyserver hkps://keys.gentoo.org --recv-keys 13EBBDBEDE7A12775DFDB1BABB572E0E2D182910
    gpg --verify "`livecd_iso_path`.asc"
  fi

  VERIFIED_SHA256=$(checksum_extract_from_file "SHA256" "`livecd_iso_path`.sha256")
  COMPUTED_SHA256=$(checksum_extract_from_string "SHA256" "$(sha256sum "`livecd_iso_path`")")
  echo_info "Verified checksum: ${FBOLD}${VERIFIED_SHA256}${FBOLD_OFF}"
  echo_info "Computed checksum: ${FBOLD}${COMPUTED_SHA256}${FBOLD_OFF}"
  if [ "${VERIFIED_SHA256}" == "${COMPUTED_SHA256}" ]
  then
    echo_ok "Checksums matches"
  else
    echo_warn "Maybe cleanup $(download_dir) ?"
    exit_error "Checksums does not match"
  fi
}

extract_initramfs_gentoo() {
  local INITRAMFS_SQUASH_FILE="${LIVECD_EXTRACT_POINT}/image.squashfs"

  extract_squashfs "${INITRAMFS_SQUASH_FILE}" "${INITRAMFS_EXTRACT_POINT}"
}

repack_initramfs_gentoo() {
  local INITRAMFS_SQUASH_FILE="${LIVECD_EXTRACT_POINT}/image.squashfs"

  echo_todo "Assuming XZ compression, verify compression with unsquashfs -s ${INITRAMFS_SQUASH_FILE}"
  repack_squashfs "${INITRAMFS_EXTRACT_POINT}" "${INITRAMFS_SQUASH_FILE}" "-comp xz -noappend"
}
