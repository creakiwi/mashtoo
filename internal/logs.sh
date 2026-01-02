## /desc Returns log level priority codes
## /usage _log_level_priority <level>(string)
## /param <level>(string)
## /return (integer)
_log_level_priority() {
	check_arguments $# 1 "_log_level_priority <level>(string)"
	local _LEVEL="${1}"

  case "${_LEVEL}" in
    err|error|ERROR)            echo 1 ;;
    warn|WARN|warning|WARNING)  echo 2 ;;
    info|INFO)                  echo 3 ;;
    debug|DEBUG|dbg|DBG)        echo 4 ;;
    all|ALL)                    echo 5 ;;
    todo|TODO)                  echo 6 ;; # Unwanted for ALL because its for dev purpose only
    llama|LLAMA)                echo 7 ;; # Do we need to log easter eggs in ALL ? Nope
    *)                          echo 99 ;;
  esac
}

_log_level_normalize() {
  check_arguments $# 1 "_log_level_normalize <level>(string)"
  local _LEVEL="${1}"

  printf '%s' "${_TYPE}" | tr '[:lower:]' '[:upper:]'
}

## /desc Log message with level in logger
## /usage log <level>(string) <message>(string)
## /param <level>(string) The level of the log
## /param <message>(string) The message to log
## /todo Where to log to instead of /tmp/mashtoo.log
log() {
  check_arguments $# 2 "log <level>(string) <message>(string)"
  local _LEVEL=$(_log_level_normalize "${1}")
  local _MESSAGE="${2}"
  local _LOG_LEVEL="$(_log_level_normalize "${LOG_LEVEL}")"
  local _CURRENT_LOG_LEVEL=$(_log_level_priority "${_LOG_LEVEL}")
  local _MESSAGE_LOG_LEVEL=$(_log_level_priority "${_LEVEL}")

  if [ ${_MESSAGE_LOG_LEVEL} -le ${_CURRENT_LOG_LEVEL} ]; then
    local _CLEANED_MESSAGE=$(printf "%s" "${_MESSAGE}" | sed -E 's/(\x1B|\033)\[[0-9;]*[mK]//g' | sed -E 's/\\e\[[0-9;]*[a-zA-Z]//g')
    echo "[${_LEVEL}] ${_CLEANED_MESSAGE}" >> "/tmp/mashtoo.log"
  fi
  echo "[${_LEVEL}] ${_CLEANED_MESSAGE}" >> "/tmp/mashtoo_debug.log"
}

## /desc Log message with INFO level
## /usage log_info <message>(string)
## /param <message> (string) Message to log
log_info() {
	check_arguments $# 1 "log_info <message>(string)"
	local _MESSAGE="${1}"

  log "INFO" "${_MESSAGE}"
}

## /desc Log message with ERROR level
## /usage log_error <message>(string)
## /param <message> (string) Message to log
log_error() {
	check_arguments $# 1 "log_error <message>(string)"
	local _MESSAGE="${1}"

  log "ERROR" "${_MESSAGE}"
}

## /desc Log message with WARN level
## /usage log_warn <message>(string)
## /param <message> (string) Message to log
log_warn() {
	check_arguments $# 1 "log_warn <message>(string)"
	local _MESSAGE="${1}"

  log "WARN" "${_MESSAGE}"
}

## /desc Log message with DEBUG level
## /usage log_debug <message>(string)
## /param <message> (string) Message to log
log_debug() {
	check_arguments $# 1 "log_debug <message>(string)"
	local _MESSAGE="${1}"

  log "DEBUG" "${_MESSAGE}"
}

## /desc Log message with TODO level
## /usage log_todo <message>(string)
## /param <message> (string) Message to log
log_todo() {
	check_arguments $# 1 "log_todo <message>(string)"
	local _MESSAGE="${1}"

  log "TODO" "${_MESSAGE}"
}

## /desc Log message with LLAMA level
## /usage log_llama <message>(string)
## /param <message> (string) Message to log
log_llama() {
	check_arguments $# 1 "log_llama <message>(string)"
	local _MESSAGE="${1}"

  log "LLAMA" "${_MESSAGE}"
}
