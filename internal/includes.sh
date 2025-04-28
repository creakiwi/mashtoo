#!/bin/sh

for file in ./internal/*.sh
do
  if [ "$(basename "${file}")" != "includes.sh" ] && [ -f "${file}" ]
  then
      . "${file}"
  fi
done

cat ./internal/assets/logo
echo -e "Version: ${FCGREEN}0.1${FCDEF}"
echo -e "Author: ${FCGREEN}Alex Ception <alexandre@creakiwi.com>${FCDEF}\n"
