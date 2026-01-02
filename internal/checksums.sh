## /desc Read file to extract wanted checksum or exit on errors
## /usage checksum_extract_from_file <file>(string) [type](string)
## /param <file> (string) The file where to extract checksum from
## /param [type] (string) The checksum hash type (default: sha256)
## /return (string) The extracted checksum
## /error Invalid [type]
## /error <file> does not exist or is not regular
checksum_extract_from_file() {
	check_arguments $# 1 "checksum_extract_from_file <file>(string) [type](string)"
  local _FILE="${1}"
	local _TYPE=$(checksum_type_normalize "${2:-sha256}")
	checksum_type_validate "${_TYPE}"
	file_exists_regular "${_FILE}" 1
	local _CONTENT
	local _CHECKSUM

  _CONTENT=$(cat "${_FILE}")
  _CHECKSUM=$(checksum_extract_from_string "${_CONTENT}" "${_TYPE}")

  printf '%s\n' "${_CHECKSUM}"
}

## /desc Extract checksum part of a string or exit on unsupported checksum
## /usage checksum_extract_from_string <string>(string) [type](string)
## /param <string> (string) The string where to extract checksum from
## /param <type> (string) The checksum hash type (default: sha256)
## /return (string) The extracted checksum
## /error Invalid [type]
checksum_extract_from_string() {
	check_arguments $# 1 "checksum_extract_from_string <string>(string) [type](string)"
	local _STRING="${1}"
	local _TYPE=$(checksum_type_normalize "${2:-sha256}")
	checksum_type_validate "${_TYPE}"

  case "${_TYPE}" in
    sha256)
      printf '%s\n' "${_STRING}" | grep -Eo '^[a-f0-9]{64}'
      ;;
    sha512)
      printf '%s\n' "${_STRING}" | grep -E '^[a-f0-9]{128}'
      ;;
    *)
      exit_error "Unsupported checksum \"${_STRING}\""
      ;;
  esac
}

## /desc Validate checksum type or exit
## /usage checksum_type_validate <type>(string)
## /param <type> (string) Checksum type
## /return (bool) 0 if valid, 1 else (exist-status boolean)
## /error Invalid <type>
## /todo Add parameter [exit] if defined to 1 then exit, return 1 else
checksum_type_validate() {
	check_arguments $# 1 "checksum_type_validate <type>(string)"
  local _TYPE=$(checksum_type_normalize "${1}")

  case "${_TYPE}" in
    sha256|sha512)
      return 0
      ;;
    *)
      exit_error "Unsupported checksum type \"${_TYPE}\""
      ;;
  esac
}

## /desc Normalize checksum type
## /usage checksum_type_normalize <type>(string)
## /param <type> (string)
## /return (string) Normalized checksum type
checksum_type_normalize() {
	check_arguments $# 1 "checksum_type_normalize <type>(string)"
	local _TYPE="${1}"

  printf '%s' "${_TYPE}" | tr '[:upper:]' '[:lower:]'
}
