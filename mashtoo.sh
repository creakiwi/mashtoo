#!/bin/sh

if [ -z ${MASHTOO_DIR} ]
then
  echo "You must define MASHTOO_DIR variable (ex: MASHTOO_DIR=\"/usr/local/sbin/mashtoo\")"
  exit
fi

. ${MASHTOO_DIR}/internal/includes.sh
