#!/bin/sh

summary() {
  title "Configured parameters"
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
}
