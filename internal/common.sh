## /desc Check arguments passed to a function or exit
## /usage check_arguments <passed_parameters>(integer) <needed_parameters>(integer) [usage](string)
## /param <passed_parameters> (integer) Number of given parameters
## /param <needed_parameters> (integer) Expected number of parameters
## /param [usage] (string) If defined display the usage
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

## /desc Run command quietly displaying result and elapsed time
## /usage run_quiet ...<any>
## /param ...<any> The commmand to run
run_quiet() {
	local _TIMESTAMP=$(timestamp)
	local _COMMAND=$@

	printf "Running \"%b%s%b\"..." "${FCBLUE}" "$*" "${FCDEF}"
	#echo -e -n "Running \"${FCBLUE}$@${FCDEF}\"..."
	eval "${_COMMAND}" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo_ok "($(diff_timestamp "${_TIMESTAMP}" 1))"
	else
		echo_ko "($(diff_timestamp "${_TIMESTAMP}" 1))"
	fi
}


## /desc Run command quietly displaying result and elapsed time
## /usage run ...<any>
## /param ...<any> The commmand to run
run() {
	local _TIMESTAMP=$(timestamp)
	local _COMMAND=$@

	printf "Running \"%b%s%b\"..." "${FCBLUE}" "$*" "${FCDEF}"
	#echo -e -n "Running \"${FCBLUE}$@${FCDEF}\"..."
	log_info "run \"$@\""
	eval "${_COMMAND}"
	if [ $? -eq 0 ]; then
		echo_ok "(`diff_timestamp ${_TIMESTAMP} 1`)"
	else
		echo_ko "(`diff_timestamp ${_TIMESTAMP} 1`)"
	fi
}

command_exists() {
  check_arguments $# 1 "command_exists <command>(string)"
  command -v "${1}" >/dev/null 2>&1
}

#############
# DOWNLOADS #
#############

# usage: download <source>(string) <destination>(string) [override](bool)
download() {
	check_arguments $# 2 "download <source>(string) <destination>(string) [override](any)"
	local SOURCE=${1}
	local DESTINATION=${2}
	local OVERRIDE=${3:-}

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
