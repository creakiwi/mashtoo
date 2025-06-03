#!/bin/sh

for file in ./internal/*.sh
do
  if [ "$(basename "${file}")" != "includes.sh" ] && [ -f "${file}" ]
  then
      . "${file}"
  fi
done

cat ./internal/assets/logo | while IFS= read -r line; do
  llama_colors "$line"
  echo ""
done

echo -e "Version: ${FBOLD}${FCGREEN}0.1${FCDEF}"
echo -e "Author: ${FBOLD}${FCGREEN}Alex Ception <alexandre@creakiwi.com>${FCDEF}"
echo -e "Repositories:"
echo -e "\t - ${FBOLD}${FCGREEN}https://github.com/creakiwi/mashtoo${FCDEF}"
echo -e "\t - ${FBOLD}${FCGREEN}https://gitlab.com/creakiwi/mashtoo${FCDEF}"
echo -e "License: ${FBOLD}${FCGREEN}ANY-WARE LICENSE${FCDEF}"
echo -e "git.license: ${FBOLD}${FCGREEN}$(cat ./gift.license)${FCDEF}\n"
cat ./LICENSE