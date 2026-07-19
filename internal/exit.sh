## /desc Exit with lama style
## /usage exit_llama <message>(string)
## /param <message> (string) The exit message
exit_llama() {
	check_arguments $# 1 "exit_llama <message>(string)"
	local _MESSAGE="${1}"

  echo_llama "${_MESSAGE}"
  echo_llama "KTHXBYE"

  exit 42
}

## /desc Exit on error
## /usage exit_error [error_message](string) [error_code](integer)
## /param [error_message] (string) The error message
## /param [error_code] (integer) The error code
exit_error() {
	if [ "${#}" -eq 1 ]; then
		echo_ko "${1}"
	fi

	if [ "${#}" -ge 1 ]; then
		exit ${2}
	fi

  exit 1
}

## /desc Exit on warn
## /usage exit_warn [warn_message](string) [warn_code](integer)
## /param [warn_message] (string) The warning message
## /param [warn_code] (integer) The warning code
exit_warn() {
	if [ ${#} -eq 1 ]
	then
		echo_warn "${2}"
	fi

	if [ $# -ge 1 ]
	then
		exit ${2}
	fi

  exit 1
}

## /desc Exit with success but without style like exit_llama
## /usage exit_success
exit_success() {
	exit 0
}

## /desc Assert parameters equals or exit with error
## /usage equals_or_exit <given>(integer|string) <expected>(integer|string)
## /param <given> (integer|string) The given value
## /param <expected (integer|string) The expected value
equals_or_exit() {
	check_arguments ${#} 2 "equals_or_exit <given>(integer|string) <expected>(integer|string)"
	local _GIVEN=${1}
	local _EXPECTED=${2}
	local _VALID=1

	if [ "${_GIVEN}" != "${_EXPECTED}" ]
	then
		_VALID=0
	fi

	if [ ${_VALID} -eq 1 ]
	then
		echo_ok
	else
		echo_ko
		exit_error "parameter ${FBOLD}${GIVEN}${FBOLD_OFF} does not match expected parameter ${FBOLD}${GIVEN}${FBOLD_OFF}"
	fi
}
