#!/bin/sh

cleanup_drive() {
  title "Cleanup drive"
  _check_disk
  if [ "${DEBUG}" = "1" ]
  then
    _erase_disk
  fi

  wipe_drive ${USB_DEVICE}
}

_check_disk() {
  if drive_exists ${USB_DEVICE}
  then
    echo_info "Drive ${FBOLD}${USB_DEVICE}${FBOLD_OFF} exists".
  else
    exit_error "Drive ${FBOLD}${USB_DEVICE}${FBOLD_OFF} does not exists."
  fi
}

_erase_disk() {
  RESULT=$(ask_expected "yes" "${FCYELLOW}Are you sure you want to erase ${FBOLD}${USB_DEVICE}${FBOLD_OFF} ? (yes/no)${FCDEF}" "no")
  if [ 0 -eq ${RESULT} ]
  then
    exit_llama "You are not really sure you want to erase ${USB_DEVICE}."
  fi
}
