#!/bin/sh

#DIST_FILE="./dist/${DIST}.sh"
#if [ -f "$DIST_FILE" ]
#then
#  . "$DIST_FILE"
#  sandbox() (
#    unset $(env | cut -d= -f1)
#    set
#  )
#  sandbox
#  exit 1
#else
#  echo_ko "Unhandled distribution \"${DIST}\"."
#  exit 1
#fi

for file in ${MASHTOO_DIR}/dist/*.sh
do
  if [ -f "${file}" ]
  then
      . "${file}"
  fi
done

download_dist() {
  title "Download ${DIST}"
  if command -v download_dist_${DIST} >/dev/null 2>&1
  then
    echo_ok "Entering '${DIST}' download process"
    download_dist_${DIST}
    if command -v checksum_dist_${DIST} >/dev/null 2>&1
    then
      echo_ok "Entering '${DIST}' checksum process"
      checksum_dist_${DIST}
    else
      echo_warn "No '${FBOLD}checksum_dist_${DIST}${FBOLD_OFF}' function found in '${FBOLD}${DIST_FILE}${FBOLD_OFF}', you ${FBOLD}REALLY${FBOLD_OFF} should implement it."
    fi
  else
    exit_error "Distribution '${FBOLD}${DIST}${FBOLD_OFF}' should be handled but no '${FBOLD}download_dist_${DIST}${FBOLD_OFF}' function found in '${FBOLD}${DIST_FILE}${FBOLD_OFF}'."
  fi
}
