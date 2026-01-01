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

# usage: exit_error [error_msg](string) [error_code](integer)
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

# usage: exit_warn [warn_code](integer) [warn_msg](string)
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

# usage: equals_or_exit <given>(integer|string) <expected>(integer|string)
equals_or_exit() {
	check_arguments ${#} 2 "<given>(integer|string) <expected>(integer|string)"
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

# usage: _log_level_priority <level>(string)
_log_level_priority() {
	check_arguments $# 1 "_log_level_priority <level>(string)"
  case "$1" in
    ERROR) echo 1 ;;
    WARN)  echo 2 ;;
    INFO)  echo 3 ;;
    DEBUG) echo 4 ;;
    ALL)   echo 5 ;;
    TODO)  echo 6 ;; # Unwanted for ALL because its for dev purpose only
    LLAMA) echo 7 ;; # Do we need to log easter eggs in ALL ? Nope
    *)     echo 99 ;;
  esac
}

# usage: log <level>(string) <message>(string)
log() {
  check_arguments $# 2 "log <level>(string) <message>(string)"

  local CURRENT_LOG_LEVEL=$(_log_level_priority "${LOG_LEVEL}")
  local MESSAGE_LOG_LEVEL=$(_log_level_priority "${1}")
  if [ ${MESSAGE_LOG_LEVEL} -le ${CURRENT_LOG_LEVEL} ]
  then
    local CLEANED_MESSAGE=$(printf "%s" "${2}" | sed -E 's/(\x1B|\033)\[[0-9;]*[mK]//g' | sed -E 's/\\e\[[0-9;]*[a-zA-Z]//g')
    echo "[${1}] ${CLEANED_MESSAGE}" >> "/tmp/mashtoo.log"
  fi
}

# usage: log_info <message>(string)
log_info() {
	check_arguments $# 1 "log_info <message>(string)"
	local MESSAGE="${1}"

  log "INFO" "${MESSAGE}"
}

# usage: log_error <message>(string)
log_error() {
	check_arguments $# 1 "log_error <message>(string)"
	local MESSAGE="${1}"

  log "ERROR" "${MESSAGE}"
}

# usage: log_warn <message>(string)
log_warn() {
	check_arguments $# 1 "log_warn <message>(string)"
	local MESSAGE="${1}"

  log "WARN" "${MESSAGE}"
}

# usage: log_debug <message>(string)
log_debug() {
	check_arguments $# 1 "log_debug <message>(string)"
	local MESSAGE="${1}"

  log "DEBUG" "${MESSAGE}"
}

# usage: log_todo <message>(string)
log_todo() {
	check_arguments $# 1 "log_todo <message>(string)"
	local MESSAGE="${1}"

  log "TODO" "${MESSAGE}"
}

# usage: log_llama <message>(string)
log_llama() {
	check_arguments $# 1 "log_llama <message>(string)"
	local MESSAGE="${1}"

  log "LLAMA" "${MESSAGE}"
}

################
# INPUT/OUTPUT #
################
# usage: echo_llama <message>(string)
echo_llama() {
	check_arguments $# 1 "echo_llama <message>(string)"
	local MESSAGE="${1}"
  local CLEANED_MESSAGE=$(printf "%s" "${MESSAGE}" | sed -E 's/(\x1B|\033)\[[0-9;]*[mK]//g' | sed -E 's/\\e\[[0-9;]*[a-zA-Z]//g')

	log_llama "${MESSAGE}"
	echo_todo "Use llama_colors in echo_llama"
	local COLORS="31 33 32 36 34 35 91"
  local i=0
  while [ $i -lt ${#CLEANED_MESSAGE} ]; do
    local CHAR=$(printf "%s" "${MESSAGE}" | cut -c $((i+1)))
    local COLOR=$(echo ${COLORS} | cut -d' ' -f $(( (i % 7) + 1 )))
    printf "\033[${COLOR}m%s\033[0m" "${CHAR}"
    i=$((i + 1))
  done
  echo
}

# usage: echo_ok [message](string)
echo_ok() {
	if [ -n "${1}" ]
	then
	local MESSAGE="${1}"

	  log_info "${MESSAGE}"
		printf "%b\n" "${FCGREEN}${MESSAGE} ${FBOLD}[OK]${FBOLD_OFF}${FCDEF}"
	else
		printf "%b\n" "${FCGREEN}${FBOLD}[OK]${FBOLD_OFF}${FCDEF}"
	fi
}

# usage: echo_info <message>(string)
echo_info() {
	check_arguments $# 1 "echo_info <message>(string)"
	local MESSAGE="${1}"

  log_info "${MESSAGE}"
  printf "%b\n" "${FCBLUE}${FBOLD}[*]${FBOLD_OFF} ${MESSAGE}${FCDEF}"
}

# usage: echo_debug <message>(string)
echo_debug() {
	check_arguments $# 1 "echo_debug <message>(string)"
	local MESSAGE="${1}"

  log_debug "${MESSAGE}"
  printf "%b\n" "${FCMAGENTA}${FBOLD}[#]${FBOLD_OFF} ${MESSAGE}${FCDEF}"
}

echo_todo() {
	check_arguments $# 1 "echo_debug <message>(string)"
	local MESSAGE="${1}"

  log_todo "${MESSAGE}"
  printf "%b\n" "${FCMAGENTA}${FBOLD}${FBLINK}[@] TODO${FBLINK_OFF}${FBOLD_OFF} ${MESSAGE}${FCDEF}"
}

# usage: echo_warn <message>(string)
echo_warn() {
	check_arguments $# 1 "echo_warn <message>(string)"

  log_warn "${1}"
  printf "%b\n" "${FCYELLOW}${FBOLD}[!️]${FBOLD_OFF} ${1}${FCDEF}"
}

# usage: echo_ko [message](string)
echo_ko() {
	if [ -n "$1" ]
	then
	  log_error "${1}"
		printf "%b\n" "${FCRED}${1} ${FBOLD}[KO]${FBOLD_OFF}${FCDEF}"
	else
		printf "%b\n" "${FCRED}${FBOLD}[KO]${FBOLD_OFF}${FCDEF}"
	fi
}

# usage: repeat <character>(integer|string|chr) <number of times>(integer)
repeat() {
	check_arguments $# 2 "repeat <character>(integer|string|chr) <number of times>(integer)"

	local start=1
	local end=${1:-80}
	local str="${2:-=}"
	local range=$(seq $start $end)
	for i in $range
	do
		echo -n ${str}
	done
}

# usage: title <title>(string)
title() {
	check_arguments $# 1 "title <title>(string)"
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

## /desc Obfuscate a value "my_value" => "m******e"
## /usage obfuscate <value>
## /param <value> (string) Value to obfuscate
obfuscate() {
	check_arguments $# 1 "obfuscate <value>(string)"
	local _PASSWORD=${1}
	local _LENGTH=$((${#_PASSWORD}-2))
	local _FIRST_CHAR=`echo ${_PASSWORD} | sed -E 's/^(.{1}).*$/\1/'`
	local _LAST_CHAR=`echo ${_PASSWORD} | sed -E 's/^.*(.{1})$/\1/'`
	local _MASK=$(printf "%0.s|*" $(seq 1 ${_LENGTH}))
	local _MASK=`echo ${_MASK} | sed 's/|//g'`
	local _OBFUSCATED="${_FIRST_CHAR}${_MASK}${_LAST_CHAR}"

	print "%s\n" "${_OBFUSCATED}"
}

## /usage ask_expected <prompt>(string) <expected>(any) [default_value](string)
## WARNING 1 FOR TRUE 0 FOR FALSE
ask_expected() {
	check_arguments $# 2 "ask_expected <expected>(any) <prompt>(string) [default_value](string)"
	EXPECTED="${1}"
	shift
	ANSWER=`ask "$@"`
	if [ "${EXPEPECTED}" = "${ANSWER}" ]
	then
	  echo 1
	fi

  echo 0
}

## /desc Ask something
## /usage ask <prompt> [default_value]
## /param <prompt> (string) Prompt to display
## /param [default_value] (string) Default value to assign
ask() {
	check_arguments $# 1 "ask <prompt>(string) [default_value](string)"
  local _PROMPT="${1}"
  local _ASK

	if [ -n "${2}" ]; then
		local _DEFAULT="${2}"
	  read -r -p "${_PROMPT} [${_DEFAULT}]: " _ASK
    if [ -z "${_ASK}" ]; then
      _ASK="${_DEFAULT}"
    fi
  else
	  read -r -p "${_PROMPT}: " _ASK
	fi

  printf "%s\n" "${_ASK}"
}

## /desc Ask something assigning variable
## /usage ask <variable> <prompt> [default_value]
## /param <variable> (string) Variable name without $
## /param <prompt> (string) Prompt to display
## /param [default_value] (string) Default value to assign
ask_set() {
	check_arguments $# 2 "ask <var>(string) <prompt>(string) [default_value](string)"
	local _ASK_SET_VAR="${1}"
	local _PROMPT="${2}"
	local _ASK

  if [ -n "${3}" ]; then
    local _DEFAULT="${3}"
    _ASK=$(ask "${_PROMPT}" "${_DEFAULT}")
  else
    _ASK=$(ask "${_PROMPT}")
  fi

  eval "${_ASK_SET_VAR}=\"${_ASK}\""
}

## /desc Ask something assigning variable only if not assigned or empty
## /usage ask <variable> <prompt> [default_value]
## /param <variable> (string) Variable name without $
## /param <prompt> (string) Prompt to display
## /param [default_value] (string) Default value to assign
ask_set_if_unset() {
	check_arguments $# 2 "ask <var>(string) <prompt>(string) [default_value](string)"
	local _ASK_SET_VAR="${1}"
	local _PROMPT="${2}"

  if [ -n "${3}" ]; then
    local _DEFAULT="${3}"
    eval "if [ ! \"\${${_ASK_SET_VAR}+x}\" ]; then
      _ASK=\$(ask \"${_PROMPT}\" \"${_DEFAULT}\")
      ${_ASK_SET_VAR}=\"\${_ASK}\"
      export ${_ASK_SET_VAR}
    fi"
  else
    eval "if [ ! \"\${${_ASK_SET_VAR}+x}\" ]; then
      _ASK=\$(ask \"${_PROMPT}\")
      if [ ! -z \"\${_ASK}\" ]; then
        ${_ASK_SET_VAR}=\"\${_ASK}\"
        export ${_ASK_SET_VAR}
      fi
    fi"
  fi
}

# usage: ask_hidden <prompt>(string) [default_value](string)
ask_hidden() {
	check_arguments $# 1 "ask_hidden <prompt>(string) [default_value](string)"
	local DEFAULT="none"
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

## /desc Returns current timestamp
## /usage timestamp
## /return timestamp value
timestamp() {
	printf "%d\n" "`date +%s`"
}

# usage: diff_timestamp <timestamp>(integer) [human_readable](any)
diff_timestamp() {
	check_arguments $# 1 "diff_timestamp <timestamp>(integer)"
	local TIMESTAMP=${1}

	local CURRENT=`timestamp`
	local DIFF=$((${CURRENT} - ${TIMESTAMP}))
	if [ -n ${2} ]
	then
		echo `readable_time ${DIFF}`
	else
		echo ${DIFF}
	fi
}

# usage: readable_time <timestamp>(integer)
readable_time() {
	check_arguments $# 1 "readable_time <timestamp>(integer)"
	local DIFF=$1
	local DAYS=$(($DIFF/60/60/24))
	local HOURS=$(($DIFF/60/60%24))
	local MINUTS=$(($DIFF/60%60))
	local SECONDS=$(($DIFF%60))

	local READABLE=""
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

# usage: check_arguments <passed_parameters>(integer) <needed_parameters>(integer) [usage](string)
check_arguments() {
	if [ $# -lt 2 ]
	then
		echo "check_arguments require at least two parameters"
		echo "usage: check_arguments <passed_parameters>(integer) <needed_parameters>(integer) [usage](string)"
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

# usage: run_quiet ...<any>
run_quiet() {
	local TIMESTAMP=`timestamp`
	local COMMAND=$@

	echo -e -n "Running \"${FCBLUE}$@${FCDEF}\"..."
	eval "${COMMAND}" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo_ok "(`diff_timestamp ${TIMESTAMP} 1`)"
	else
		echo_ko "(`diff_timestamp ${TIMESTAMP} 1`)"
	fi
}

# usage: run ...<any>
run() {
	local TIMESTAMP=`timestamp`
	local COMMAND=$@

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

# usage: download <source>(string) <destination>(string) [override](bool)
download() {
	check_arguments $# 2 "download <source>(string) <destination>(string) [override](any)"
	local SOURCE=${1}
	local DESTINATION=${2}
	local OVERRIDE=${3}

 if [ -f "${DESTINATION}" ] && [ -r "${DESTINATION}" ] && [ -z "${OVERRIDE}" ]
  then
    echo_info "${FBOLD}${DESTINATION}${FBOLD_OFF} in ${FBOLD}`download_dir`${FBOLD_OFF} already exists, ignore download."
    return 0
  fi

  if [ -n "${OVERRIDE}" ] && [ "${OVERRIDE}" = 1 ]
  then
    echo_debug "Override enabled"
    echo_warn "Remove ${FBOLD}${DESTINATION}${FBOLD_OFF}"
    run "rm -f ${DESTINATION}"
  fi

  echo_info "Downloading ${FBOLD}${SOURCE}${FBOLD_OFF} to ${FBOLD}${DESTINATION}${FBOLD_OFF}..."
  run "wget -q --show-progress -O ${DESTINATION} ${SOURCE}"
}

#############
# CHECKSUMS #
#############
# usage: checksum_extract_from_file <type>(string) <file>(string)
checksum_extract_from_file() {
	check_arguments $# 2 "checksum_extract_from_file <type>(string) <file>(string)"

  local CONTENT=$(cat ${2})
  local CHECKSUM=$(checksum_extract_from_string "${1}" "${CONTENT}")
  echo "${CHECKSUM}"
}

# usage: checksum_extract_from_file <type>(string) <string>(string)
checksum_extract_from_string() {
	check_arguments $# 2 "checksum_extract_from_file <type>(string) <string>(string)"

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
