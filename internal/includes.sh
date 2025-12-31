#!/bin/sh

for file in ${MASHTOO_DIR}/internal/*.sh
do
  if [ "$(basename "${file}")" != "includes.sh" ] && [ -f "${file}" ]
  then
      . "${file}"
  fi
done

while IFS= read -r line; do
  zllama_colors "$line"
done < "${MASHTOO_DIR}/internal/assets/logo" > ${MASHTOO_DIR}/internal/assets/logo_colored
cat ${MASHTOO_DIR}/internal/assets/logo_colored

echo -e "Version: ${FBOLD}${FCGREEN}0.2${FCDEF}"
echo -e "Author: ${FBOLD}${FCGREEN}Alex Ception <alexandre@creakiwi.com>${FCDEF}"
echo -e "Repositories:"
echo -e "\t - ${FBOLD}${FCGREEN}https://github.com/creakiwi/mashtoo${FCDEF}"
echo -e "\t - ${FBOLD}${FCGREEN}https://gitlab.com/creakiwi/mashtoo${FCDEF}"
echo -e "License: ${FBOLD}${FCGREEN}ANY-WARE LICENSE${FCDEF}"
echo -e "git.license: ${FBOLD}${FCGREEN}$(cat ./gift.license)${FCDEF}\n"
cat ./LICENSE
