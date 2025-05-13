#!/bin/sh

download_dist() {
  title "Download ${DIST}"
  DIST_FILE="./dist/${DIST}.sh"

  if [ -f "$DIST_FILE" ]
  then
    . "$DIST_FILE"

    if command -v download_dist_${DIST} >/dev/null 2>&1
    then
      echo_ok "Entering '${DIST}' distribution process"
      download_dist_${DIST}
      if command -v checksum_dist_${DIST} >/dev/null 2>&1
      then
        echo_ok "Entering '${DIST}' checksum process"
        checksum_dist_${DIST}
      else
        echo_warn "No '${FBOLD}checksum_dist_${DIST}${FBOLD_OFF}' function found in \"${DIST_FILE}\", you ${FBOLD}REALLY${FBOLD_OFF} should implement it."
      fi
    else
      echo_warn "Distribution\"${DIST}\" should be handled but no '${FBOLD}download_dist_${DIST}${FBOLD_OFF}' function found in \"${DIST_FILE}\"."
      exit 1
    fi
  else
    echo_ko "Unhandled distribution \"${DIST}\"."
    exit 1
  fi
}
