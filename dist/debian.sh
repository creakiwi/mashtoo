#!/bin/sh

download_dist_debian()
{
  case ${ARCH} in
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

  local BASE_URL="https://debian.osuosl.org/debian-cdimage/"
  wget --spider -q "${BASE_URL}${VERSION}/"
  if [ "${?}" -ne 0 ]
  then
    echo_warn "Unknown 'version ${FBOLD}${VERSION}${FBOLD_OFF}' for distribution '${FBOLD}${DIST}${FBOLD_OFF}'"
    echo_info "Use version '${FBOLD}current${FBOLD_OFF}' instead of '${FBOLD}${VERSION}${FBOLD_OFF}'"
    VERSION='current'
  fi

  BASE_URL="${BASE_URL}${VERSION}/${ARCH}/"
  if [ ${NETINST} -eq 1 ]
  then
    BASE_URL="${BASE_URL}iso-cd/"
  else
    BASE_URL="${BASE_URL}iso-dvd/"
  fi

  SHA512SUMS="${BASE_URL}SHA512SUMS"

  local ISO_URL=$(wget -q -O - "${SHA512SUMS}" | head -n 1 | awk '{print $2}')
  local ISO_URL_PATH="${BASE_URL}${ISO_URL}"
  download "${ISO_URL_PATH}" "`livecd_iso_path`"
}