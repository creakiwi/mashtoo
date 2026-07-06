## /desc Print with style
## /usage echo_llama <message>(string)
## /param <message> (string) Message to llamafy
## /unposix
echo_llama() {
	check_arguments $# 1 "echo_llama <message>(string)"
	local _MESSAGE="${1}"
    local _CLEANED_MESSAGE=$(printf "%s" "${_MESSAGE}" | sed -E 's/(\x1B|\033)\[[0-9;]*[mK]//g' | sed -E 's/\\e\[[0-9;]*[a-zA-Z]//g')

	log_llama "${_MESSAGE}"
	echo_todo "Use llama_colors in echo_llama"

	local _COLORS="31 33 32 36 34 35 91"
    local _i=0
    local _char
    local _color

    while [ $_i -lt ${#_CLEANED_MESSAGE} ]; do
        _CHAR=$(printf "%s" "${_MESSAGE}" | cut -c $((_i+1)))
        _COLOR=$(echo ${_COLORS} | cut -d' ' -f $(( (_i % 7) + 1 )))
        _i=$((_i + 1))
        printf '\033[${_COLOR}m%s\033[0m' "${_CHAR}"
    done
    printf '\n'
}

## /desc Print OK style formatted message
## /usage echo_ok [message](string)
## /param [message] (string) Message to prepend
## /unposix
echo_ok() {
	if [ -n "${1}" ]; then
	local _MESSAGE="${1}"
        log_info "${_MESSAGE}"
        printf '%b\n' "${FCGREEN}${_MESSAGE} ${FBOLD}[OK]${FBOLD_OFF}${FCDEF}"
	else
		printf '%b\n' "${FCGREEN}${FBOLD}[OK]${FBOLD_OFF}${FCDEF}"
	fi
}

## /desc Print info style formatted message
## /usage echo_info <message>(string)
## /param <message>(string) The message to append
## /unposix
echo_info() {
	check_arguments $# 1 "echo_info <message>(string)"
	local _MESSAGE="${1}"

    log_info "${_MESSAGE}"
    printf '%b\n' "${FCBLUE}${FBOLD}[*]${FBOLD_OFF} ${_MESSAGE}${FCDEF}"
}

## /desc Print debug style formatted message
## /usage echo_debug <message>(string)
## /param <message>(string) The message to append
## /unposix
echo_debug() {
	check_arguments $# 1 "echo_debug <message>(string)"
	local _MESSAGE="${1}"

    log_debug "${_MESSAGE}"
    printf '%b\n' "${FCMAGENTA}${FBOLD}[#]${FBOLD_OFF} ${_MESSAGE}${FCDEF}"
}

## /desc Print todo style formatted message
## /usage echo_todo <message>(string)
## /param <message> (string) The message to append
## /unposix
echo_todo() {
	check_arguments $# 1 "echo_todo <message>(string)"
	local _MESSAGE="${1}"

    log_todo "${_MESSAGE}"
    printf '%b\n' "${FCMAGENTA}${FBOLD}${FBLINK}[@] TODO${FBLINK_OFF}${FBOLD_OFF} ${_MESSAGE}${FCDEF}"
}

## /desc Print warning style formatted message
## /usage echo_warn <message>(string)
## /param <message> (string) The message to append
## /unposix
echo_warn() {
	check_arguments $# 1 "echo_warn <message>(string)"
	local _MESSAGE="${1}"

    log_warn "${_MESSAGE}"
    printf '%b\n' "${FCYELLOW}${FBOLD}[!️]${FBOLD_OFF} ${_MESSAGE}${FCDEF}"
}

## /desc Print KO style formatted message
## /usage echo_ko [message](string)
## /param [message] (string) Message to prepend
## /unposix
echo_ko() {
	if [ -n "$1" ]; then
        local _MESSAGE="${1}"
        log_error "${_MESSAGE}"
		printf '%b\n' "${FCRED}${_MESSAGE} ${FBOLD}[KO]${FBOLD_OFF}${FCDEF}"
	else
		printf '%b\n' "${FCRED}${FBOLD}[KO]${FBOLD_OFF}${FCDEF}"
	fi
}

## /desc Repeat a character multiple times
## /usage repeat <character>(integer|string|chr) <number_of_times>(integer)
## /param <character> (integer|string|chr) The character to repeat
## /param <number_of_times> (integer) The number of times you want to repeat it
## /unposix
repeat() {
	check_arguments $# 2 "repeat <character>(integer|string|chr) <number_of_times>(integer)"

	local _START=1
	local _END="${1:-80}"
	local _STR="${2:-=}"
	local _RANGE=$(seq ${_START} ${_END})
	local i
	for i in ${_RANGE}
	do
		echo -n ${_STR}
	done
}

## /desc Show a title style formatted string
## /usage title <title>(string)
## /param <title> (string) The title to display
## /unposix
title() {
	check_arguments $# 1 "title <title>(string)"
	local _SEPARATORS=$((${#1}+4))
	local _TITLE="# ${1} #"

	echo ""
	repeat ${_SEPARATORS} "#"
	echo ""
	echo ${_TITLE} | tr a-z A-Z
	repeat ${_SEPARATORS} "#"
	echo ""
	echo ""
}

## /desc Obfuscate a value "my_value" => "m******e"
## /usage obfuscate <value>
## /param <value> (string) Value to obfuscate
## /unposix
obfuscate() {
	check_arguments $# 1 "obfuscate <value>(string)"
	local _PASSWORD=${1}
	local _LENGTH=$((${#_PASSWORD}-2))
	local _FIRST_CHAR=`echo ${_PASSWORD} | sed -E 's/^(.{1}).*$/\1/'`
	local _LAST_CHAR=`echo ${_PASSWORD} | sed -E 's/^.*(.{1})$/\1/'`
	local _MASK=$(printf "%0.s|*" $(seq 1 ${_LENGTH}))
	local _MASK=`echo ${_MASK} | sed 's/|//g'`
	local _OBFUSCATED="${_FIRST_CHAR}${_MASK}${_LAST_CHAR}"

	print '%s\n' "${_OBFUSCATED}"
}
