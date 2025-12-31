#!/bin/sh

if [ -z ${MASHTOO_DIR} ]
then
  echo "You must define MASHTOO_DIR variable (ex: MASHTOO_DIR=\"/home/alexception/mashtoo\")"
  exit
fi

#MAIN_DIR=$(cd "$(dirname "$0")" && pwd)

. ${MASHTOO_DIR}/internal/includes.sh

