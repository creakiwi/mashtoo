#!/bin/sh

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

  if [ -f `livecd_iso_path` ] && [ -r `livecd_iso_path` ]
  then
    echo_info "`livecd_iso` in `download_dir` already exists, ignore download."
    return 0
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
  echo_info "Downloading ${ISO_URL_PATH}..."
  wget -O `livecd_iso_path` ${ISO_URL_PATH}
}
