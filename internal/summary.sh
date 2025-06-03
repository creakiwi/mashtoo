#!/bin/sh

summary() {
  title "Configured parameters"
  echo -e "Device: ${FCYELLOW}${USB_DEVICE}${FCDEF}"
  echo -e "Arch: ${FCBLUE}${ARCH}${FCDEF}"
  echo -e "Microarch: ${FCBLUE}${MICROARCH}${FCDEF}"
  echo -e "Distribution: ${FCBLUE}${DIST}${FCDEF}"
  echo -e "Version: ${FCBLUE}${VERSION}${FCDEF}"
  if [ "${NETINST}" = "1" ]
  then
      echo -e "Netinstall mode: ${FCGREEN}yes${FCDEF}"
  else
      echo -e "Netinstall mode: ${FCYELLOW}no${FCDEF}"
  fi

  if [ "${DEBUG}" = "1" ]
  then
    echo_info "Debug is enabled (questions will be asked)"
  else
    local EXPLODING_LLAMA=1
    echo -e "${FCRED}${FBOLD}${FBLINK}[DEBUG IS DISABLED]${FBLINK_OFF} NO QUESTIONS WILL BE ASKED !${FCDEF}"
    echo -e "${FCYELLOW}${FBOLD}${USB_DEVICE}${FCRED} WILL BE ERASED !${FCDEF}"
    echo -e "${FCRED}${FBOLD}YOU HAVE ${EXPLODING_LLAMA} SECONDS TO CHECK YOUR CONFIGURATION !${FCDEF}"

    while [ "${EXPLODING_LLAMA}" -gt 0 ]; do
      local WARNING_LLAMA=$(llama_colors "Exploding llama in ${EXPLODING_LLAMA} seconds...")
      printf "\r%b" "${FBOLD}${WARNING_LLAMA}${FBOLD_OFF}"
      sleep 1
      EXPLODING_LLAMA=$((EXPLODING_LLAMA - 1))
    done
    echo ""
  fi
}
