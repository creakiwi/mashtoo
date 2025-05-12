#!/bin/sh

BASE_URL="https://gentoo.osuosl.org/releases"

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
      exit_error 1 "Unsupported arch '${ARCH}'"
      ;;
  esac

  echo_warn "Ignore version '${VERSION}' for gentoo, always use 'latest'"
  VERSION="latest"
  BASE_URL="${BASE_URL}/${DEFINED_ARCH}/autobuilds/"
  GPG_ISO_URL="${BASE_URL}latest-"
  if [ ${NETINST} -eq 1 ]
  then
    GPG_ISO_URL="${GPG_ISO_URL}install-${DEFINED_ARCH}-minimal.txt"
  else
    GPG_ISO_URL="${GPG_ISO_URL}livegui-${DEFINED_ARCH}.txt"
  fi
  ISO_URL=$(wget -q -O - "${GPG_ISO_URL}" | grep -oE '[0-9]{8}T[0-9]{6}Z/.*\.iso')
  ISO_URL="${BASE_URL}${ISO_URL}"
  echo_info "Downloading ${ISO_URL}..."
  wget -O ${DOWNLOAD_DIR}/livecd-${DIST}-${ARCH}-${VERSION}.iso ${ISO_URL}
}