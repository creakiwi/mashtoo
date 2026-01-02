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
