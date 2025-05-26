#!/bin/sh

################
# EXIT METHODS #
################

# usage: exit_llama <message>(string)
exit_llama() {
	check_arguments $# 1 "<message>(string)"

  echo_llama "${1}"
  echo_llama "KTHXBYE"

  exit 42
}

# usage: exit_error [error_msg](string) [error_code](int)
exit_error() {
	if [ "${#}" -eq 1 ]
	then
		echo_ko "${1}"
	fi

	if [ "${#}" -ge 1 ]
	then
		exit ${2}
	fi

  exit 1
}

# usage: exit_warn [warn_code](int) [warn_msg](str)
exit_warn() {
	if [ ${#} -eq 2 ]
	then
		echo_warn "${2}"
	fi

	if [ $# -ge 1 ]
	then
		exit $1
	else
		exit 1
	fi
}

# usage: exit_success
exit_success() {
	exit 0
}

#usage: equals_or_exit <given>(int|str) <expected>(int|str)
equals_or_exit() {
	check_arguments ${#} 2 "<given>(int|str) <expected>(int|str)"
	local GIVEN=${1}
	local EXPECTED=${2}

	local VALID=1
	if [ "${GIVEN}" != "${EXPECTED}" ]
	then
		VALID=0
	fi

	if [ ${VALID} -eq 1 ]
	then
		echo_ok
	else
		echo_ko
		exit_error "parameter ${FBOLD}${GIVEN}${FBOLD_OFF} does not match expected parameter ${FBOLD}${GIVEN}${FBOLD_OFF}"
	fi
}

##########
# LOGGER #
##########

# usage: _log_level_priority <level>(str)
_log_level_priority() {
	check_arguments $# 1 "_log_level_priority <level>(str)"
  case "$1" in
    ERROR) echo 1 ;;
    WARN)  echo 2 ;;
    INFO)  echo 3 ;;
    DEBUG) echo 4 ;;
    ALL)   echo 5 ;;
    LLAMA) echo 7 ;;
    *)     echo 99 ;;
  esac
}

# usage: log <level>(str) <message>(str)
log() {
  check_arguments $# 2 "log <level>(str) <message>(str)"

  local CURRENT_LOG_LEVEL=$(_log_level_priority "${LOG_LEVEL}")
  local MESSAGE_LOG_LEVEL=$(_log_level_priority "${1}")
  if [ ${MESSAGE_LOG_LEVEL} -le ${CURRENT_LOG_LEVEL} ]
  then
    local CLEANED_MESSAGE=$(printf "%s" "${2}" | sed -E 's/(\x1B|\033)\[[0-9;]*[mK]//g' | sed -E 's/\\e\[[0-9;]*[a-zA-Z]//g')
    echo "[${1}] ${CLEANED_MESSAGE}" >> "${MAIN_DIR}/report.log"
  fi
}

# usage: log_info <message>(str)
log_info() {
	check_arguments $# 1 "log_info <message>(str)"

  log "INFO" "${1}"
}

# usage: log_error <message>(str)
log_error() {
	check_arguments $# 1 "log_error <message>(str)"

  log "ERROR" "${1}"
}

# usage: log_warn <message>(str)
log_warn() {
	check_arguments $# 1 "log_warn <message>(str)"

  log "WARN" "${1}"
}

# usage: log_debug <message>(str)
log_debug() {
	check_arguments $# 1 "log_debug <message>(str)"

  log "DEBUG" "${1}"
}

################
# INPUT/OUTPUT #
################
# usage: echo_llama <message>(string)
echo_llama() {
	check_arguments $# 1 "<message>(string)"
  local CLEANED_MESSAGE=$(printf "%s" "${1}" | sed -E 's/(\x1B|\033)\[[0-9;]*[mK]//g' | sed -E 's/\\e\[[0-9;]*[a-zA-Z]//g')

	log "LLAMA" "${1}"
	local COLORS="31 33 32 36 34 35 91"
#	echo -e "${FCPINK}${1}${FCDEF}"
  local i=0
  while [ $i -lt ${#CLEANED_MESSAGE} ]; do
    local CHAR=$(printf "%s" "${1}" | cut -c $((i+1)))
    local COLOR=$(echo ${COLORS} | cut -d' ' -f $(( (i % 7) + 1 )))
    printf "\033[${COLOR}m%s\033[0m" "${CHAR}"
    i=$((i + 1))
  done
  echo
}

# usage: echo_ok [message](str)
echo_ok() {
	if [ -n "${1}" ]
	then
	  log_info "${1}"
		echo -e "${FCGREEN}${1} ${FBOLD}[OK]${FBOLD_OFF}${FCDEF}"
	else
		echo -e "${FCGREEN}${FBOLD}[OK]${FBOLD_OFF}${FCDEF}"
	fi
}

# usage: echo_info <message>(str)
echo_info() {
	check_arguments $# 1 "echo_info <message>(str)"

  log_info "${1}"
  echo -e "${FCBLUE}${FBOLD}[*]${FBOLD_OFF} ${1}${FCDEF}"
}

# usage: echo_debug <message>(str)
echo_debug() {
	check_arguments $# 1 "echo_debug <message>(str)"

  log_debug "${1}"
  echo -e "${FCMAGENTA}${FBOLD}[#]${FBOLD_OFF} ${1}${FCDEF}"
}

# usage: echo_warn <message>(str)
echo_warn() {
	check_arguments $# 1 "echo_warn <message>(str)"

  log_warn "${1}"
  echo -e "${FCYELLOW}${FBOLD}[!️]${FBOLD_OFF} ${1}${FCDEF}"
}

# usage: echo_ko [message](str)
echo_ko() {
	if [ -n "$1" ]
	then
	  log_error "${1}"
		echo -e "${FCRED}${1} ${FBOLD}[KO]${FBOLD_OFF}${FCDEF}"
	else
		echo -e "${FCRED}${FBOLD}[KO]${FBOLD_OFF}${FCDEF}"
	fi
}

# usage: repeat <character>(int|str|chr) <number of times>(int)
repeat() {
	check_arguments $# 2 "repeat <character>(int|str|chr) <number of times>(int)"

	local start=1
	local end=${1:-80}
	local str="${2:-=}"
	local range=$(seq $start $end)
	for i in $range
	do
		echo -n ${str}
	done
}

# usage: title <title>(str)
title() {
	check_arguments $# 1 "title <title>(str)"

	local SEPARATORS=$((${#1}+4))
	local TITLE="# ${1} #"
	echo ""
	repeat ${SEPARATORS} "#"
	echo ""
	echo ${TITLE} | tr a-z A-Z
	repeat ${SEPARATORS} "#"
	echo ""
	echo ""
}

# usage: obfuscate <string>(str)
obfuscate() {
	check_arguments $# 1 "obfuscate <string>(str)"
	PASSWORD=${1}
	LENGTH=$((${#PASSWORD}-2))
	FIRST_CHAR=`echo ${PASSWORD} | sed -E 's/^(.{1}).*$/\1/'`
	LAST_CHAR=`echo ${PASSWORD} | sed -E 's/^.*(.{1})$/\1/'`
	MASK=$(printf "%0.s|*" $(seq 1 ${LENGTH}))
	MASK=`echo ${MASK} | sed 's/|//g'`
	OBFUSCATED="${FIRST_CHAR}${MASK}${LAST_CHAR}"
	echo ${OBFUSCATED}
}

# usage: ask_expected <prompt>(str) <expected>(any) [default_value](str)
ask_expected() {
	check_arguments $# 2 "ask_expected <expected>(any) <prompt>(str) [default_value](str)"
	EXPECTED="${1}"
	shift
	ANSWER=`ask "$@"`
	if [ "${EXPEPECTED}" = "${ANSWER}" ]
	then
	  echo 1
	fi

  echo 0
}

# usage: ask <prompt>(str) [default_value](str)
ask() {
	check_arguments $# 1 "ask <prompt>(str) [default_value](str)"
	DEFAULT="none"
	if [ -n "${2}" ]
	then
		DEFAULT="${2}"
	fi

	read -r -p "$(printf "${1} [${DEFAULT}]: ")" ASK
	if [ -z ${ASK} ]
	then
		ASK=${DEFAULT}
	fi
	echo ${ASK}
}

# usage: ask_hidden <prompt>(str) [default_value](str)
ask_hidden() {
	check_arguments $# 1 "ask_hidden <prompt>(str) [default_value](str)"
	DEFAULT="none"
	if [ -n ${2} ]
	then
		DEFAULT=`obfuscate ${2}`
	fi

	read -r -s -p "${1} [${DEFAULT}]: " ASK
	if [ -z ${ASK} ]
	then
		ASK=${2}
	fi
	echo ${ASK}
}

########
# TIME #
########

# usage: timestamp
timestamp() {
	echo `date +%s`
}

# usage: diff_timestamp <timestamp>(int) [human_readable](any)
diff_timestamp() {
	check_arguments $# 1 "diff_timestamp <timestamp>(int)"

	CURRENT=`timestamp`
	DIFF=$((${CURRENT} - ${1}))
	if [ -n ${2} ]
	then
		echo `readabie_time ${DIFF}`
	else
		echo ${DIFF}
	fi
}

# usage: readabie_time <timestamp>(int)
readabie_time() {
	check_arguments $# 1 "readabie_time <timestamp>(int)"
	local DIFF=$1
	local DAYS=$(($DIFF/60/60/24))
	local HOURS=$(($DIFF/60/60%24))
	local MINUTS=$(($DIFF/60%60))
	local SECONDS=$(($DIFF%60))

	READABLE=""
	if [ ${SECONDS} -ge 0 ]
	then
		READABLE=`printf "%02d" ${SECONDS}`
	fi

	if [ ${MINUTS} -ge 0 ]
	then
		READABLE="`printf "%02d" ${MINUTS}`:${READABLE}"
	fi

	if [ ${HOURS} -ge 0 ]
	then
		READABLE="`printf "%02d" ${HOURS}`:${READABLE}"
	fi

	if [ ${DAYS} -gt 0 ]
	then
		READABLE="${DAYS} days ${READABLE}"
	fi
	echo $READABLE
}

##########
# OTHERS #
##########

# usage: check_arguments <passed_parameters>(int) <needed_parameters>(int) [usage](str)
check_arguments() {
	if [ $# -lt 2 ]
	then
		echo "check_arguments require at least two parameters"
		echo "usage: check_arguments <passed_parameters>(int) <needed_parameters>(int) [usage](str)"
		exit 1
	fi

	if [ ${1} -lt ${2} ]
	then
		if [ $# -eq 3 ]
		then
			exit_error "usage: ${3}"
    fi

    exit_error "Missing arguments."
	fi
}

run_quiet() {
	TIMESTAMP=`timestamp`
	COMMAND=$@
	echo -e -n "Running \"${FCBLUE}$@${FCDEF}\"..."
	eval "${COMMAND}" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo_ok "(`diff_timestamp ${TIMESTAMP} 1`)"
	else
		echo_ko "(`diff_timestamp ${TIMESTAMP} 1`)"
	fi
}

run() {
	COMMAND=$@
	echo -e -n "Running \"${FCBLUE}$@${FCDEF}\"..."
	eval "${COMMAND}"
	if [ $? -eq 0 ]; then
		echo_ok "(`diff_timestamp ${TIMESTAMP} 1`)"
	else
		echo_ko "(`diff_timestamp ${TIMESTAMP} 1`)"
	fi
}

#############
# DOWNLOADS #
#############

# usage: download <source>(string) <destination>(string) [override](any)
download() {
	check_arguments $# 2 "download <source>(string) <destination>(string) [override](any)"

 if [ -f "${2}" ] && [ -r "${2}" ] && [ -z "${3}" ]
  then
    echo_info "${2} in `download_dir` already exists, ignore download."
    return 0
  fi

  if [ -n "${3}" ]
  then
    echo_debug "Override enabled"
    echo_warn "Remove ${FBOLD}${2}${FBOLD_OFF}"
    rm -f ${2}
  fi

  echo_info "Downloading ${FBOLD}${1}${FBOLD_OFF} to ${FBOLD}${2}${FBOLD_OFF}..."
  wget -q --show-progress -O ${2} ${1}
}

#############
# CHECKSUMS #
#############
# usage: checksum_extract_from_file <type>(str) <file>(str)
checksum_extract_from_file() {
	check_arguments $# 2 "checksum_extract_from_file <type>(str) <file>(str)"

  local CONTENT=$(cat ${2})
  local CHECKSUM=$(checksum_extract_from_string "${1}" "${CONTENT}")
  echo "${CHECKSUM}"
}

# usage: checksum_extract_from_file <type>(str) <string>(str)
checksum_extract_from_string() {
	check_arguments $# 2 "checksum_extract_from_file <type>(str) <string>(str)"

  case ${1} in
    sha256|SHA256)
      echo "${2}" | grep -Eo '^[a-f0-9]{64}'
      ;;
    sha512|SHA512)
      echo "${2}" | grep -Eo '^[a-f0-9]{128}'
      ;;
    *)
      exit_error "Unsupported checksum ${1}"
      ;;
  esac
}
