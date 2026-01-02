## /desc Check if a file exists and is regular, optionally exit on failure
## /usage file_exists_regular <file>(string) [exit](any)
## /param <file> (string) File to check
## /param [exit] (any) If non-empty, exit with error if file missing
## /return bool: 0 if exists, 1 if not (unless exit)
## /error <file> does not exist or is not regular (unless not exit)
file_exists_regular() {
	check_arguments $# 1 "file_exists_regular <file>(string) [exit](any)"
	local _FILE="${1}"
	local _EXIT="${2}"

  if [ -f "${_FILE}" ]; then
    return 0
  else
    if [ -n "${_EXIT}" ]; then
      exit_error "File does not exists or is not readable ${_FILE}"
    fi
    return 1
  fi
}

## /desc Extract variables names from file
## /usage file_extract_variables <file>(string)
## /param <file> (string) The file to extract from
## /return (stray) List of extracted variables
## /error <file> does not exist or is not regular
file_extract_variables() {
  check_arguments $# 1 "file_extract_variables <file>(string)"
  local _FILE="${1}"
  file_exists_regular "${_FILE}"

  grep -o '\${[A-Za-z_][A-Za-z0-9_]*}' "${_FILE}" | tr -d '${}' | sort -u
}
