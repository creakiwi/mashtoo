#!/bin/sh

# FOREGROUND COLORS

FCDEF="\e[0m"
FCRED="\e[31m"
FCGREEN="\e[32m"
FCYELLOW="\e[33m"
FCBLUE="\e[34m"
FCMAGENTA="\e[35m"
FCCYAN="\e[36m"
FCPINK="\e[95m"
FCWHITE="\e[97m"

# BACKGROUND COLORS
BCDEF="\e[0m"
BCRED="\e[41m"
BCGREEN="\e[42m"
BCYELLOW="\e[43m"
BCBLUE="\e[44m"
BCMAGENTA="\e[45m"
BCCYAN="\e[46m"
BCWHITE="\e[47m"

# STYLES

FBOLD="\e[1m"
FBOLD_OFF="\e[22m"

FBLINK="\e[5m"
FBLINK_OFF="\e[25m"

# usage: llama_colors <string>(string)
llama_colors() {
	check_arguments $# 1 "llama_colors <message>(string)"
	local STRING=${1}
	local LLAMA_STRING=""
	local COLORS="31 33 32 36 34 35 91"
  local CLEANED_STRING=$(printf "%s" "${STRING}" | sed -E 's/(\x1B|\033)\[[0-9;]*[mK]//g' | sed -E 's/\\e\[[0-9;]*[a-zA-Z]//g')

  local i=0
  while [ $i -lt ${#CLEANED_STRING} ]; do
    local CHAR=$(printf "%s" "${STRING}" | cut -c $((i+1)))
    local COLOR=$(echo ${COLORS} | cut -d' ' -f $(( (i % 7) + 1 )))
    LLAMA_STRING="${LLAMA_STRING}\033[${COLOR}m${CHAR}\033[0m"
    i=$((i + 1))
  done

  printf "%b\n" "${LLAMA_STRING}"
}

# usage: llama_colors <string>(string)
mllama_colors() {
	check_arguments $# 1 "llama_colors <message>(string)"
  local STRING=${1}

  local COLORS="31 33 32 36 34 35 91"
  local LLAMA_STRING=""
  local i=1
  local LENGTH=$(printf "%s" "$STRING" | wc -c)

  while [ "$i" -le "${LENGTH}" ]; do
    local CHAR=$(printf "%s" "${STRING}" | cut -c "$i")
    local COLOR_INDEX=$(( (i - 1) % 7 + 1 ))
    COLOR=$(printf "%s\n" "${COLORS}" | cut -d' ' -f "${COLOR_INDEX}")
    LLAMA_STRING="${LLAMA_STRING}\033[${COLOR}m${CHAR}\033[0m"
    i=$((i + 1))
  done

  printf "%b" "$LLAMA_STRING"
}

nllama_colors() {
  STRING=$1
  COLORS="31 33 32 36 34 35 91"
  LLAMA_STRING=""

  i=1
  len=$(printf "%s" "$STRING" | wc -c)

  while [ "$i" -le "$len" ]; do
    c=$(printf "%s" "$STRING" | dd bs=1 skip=$((i - 1)) count=1 2>/dev/null)
    color_index=$(( (i - 1) % 7 + 1 ))
    COLOR=$(printf "%s\n" "$COLORS" | cut -d' ' -f "$color_index")
    LLAMA_STRING="${LLAMA_STRING}\033[${COLOR}m${c}\033[0m"
    i=$((i + 1))
  done

  printf "%b" "$LLAMA_STRING"
}

zllama_colors() {
  STRING="$1"
  COLORS="31 33 32 36 34 35 91"
  i=0

  echo "$STRING" | fold -w1 | while IFS= read -r CHAR; do
    COLOR=$(echo $COLORS | cut -d' ' -f $(( (i % 7) + 1 )))
    printf "\033[%sm%s\033[0m" "$COLOR" "$CHAR"
    i=$((i + 1))
  done
  printf "\n"
}
