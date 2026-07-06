## /desc Ask for answer with expected response
## /usage ask_expected <expected>(any) <prompt>(string) [default_value](any)
## /param <expected> (any) The expected value
## /param <prompt>(string) Prompt to display
## /param [default_value] (any) Default value to assign
## /unposix
ask_expected() {
	check_arguments $# 2 "ask_expected <expected>(any) <prompt>(string) [default_value](any)"
	local _EXPECTED="${1}"
	shift
	local _ANSWER=$(ask "$@")

	[ "$(lower "${_EXPECTED}")" = "$(lower "${_ANSWER}")" ]
}

## /undocumented
ask_confirm_yes() {
  check_arguments "${#}" "1" "ask_confirm_yes <prompt>"

  ask_expected "yes" "$@"
}

## /desc Ask something
## /usage ask <prompt>(string) [default_value](any)
## /param <prompt> (string) Prompt to display
## /param [default_value] (any) Default value to assign
## /unposix
ask() {
  check_arguments $# 1 "ask <prompt>(string) [default_value](any)"
  local _PROMPT="${1}"
  local _DEFAULT="${2}"
  local _ANSWER

  if [ -n "${_DEFAULT}" ]; then
    read -r -p "${_PROMPT} [${_DEFAULT}]: " _ANSWER
  else
    read -r -p "${_PROMPT}: " _ANSWER
  fi

  if [ -z "${_ANSWER}" ] && [ -n "${_DEFAULT}" ]; then
    _ANSWER="${_DEFAULT}"
  fi

  printf '%s\n' "${_ANSWER}"
}

## /desc Ask something assigning variable
## /usage ask <variable>(string) <prompt>(string) [default_value](any)
## /param <variable> (string) Variable name without $
## /param <prompt> (string) Prompt to display
## /param [default_value] (any) Default value to assign
## /unposix
ask_set() {
	check_arguments $# 2 "ask <var>(string) <prompt>(string) [default_value](any)"
	local _ASK_SET_VAR="${1}"
	local _PROMPT="${2}"
	local _ANSWER

  if [ -n "${3}" ]; then
    local _DEFAULT="${3}"
    _ANSWER=$(ask "${_PROMPT}" "${_DEFAULT}")
    if [ -z ${_ANSWER} ]; then
      _ANSWER=${_DEFAULT}
    fi
  else
    _ANSWER=$(ask "${_PROMPT}")
  fi

  eval "${_ASK_SET_VAR}=\"${_ANSWER}\"
  export ${_ASK_SET_VAR}"
}

## /desc Ask something assigning variable only if not assigned or empty
## /usage ask <variable>(string) <prompt>(string) [default_value](any)
## /param <variable> (string) Variable name without $
## /param <prompt> (string) Prompt to display
## /param [default_value] (any) Default value to assign
## /unposix
ask_set_if_unset() {
	check_arguments $# 2 "ask <var>(string) <prompt>(string) [default_value](any)"
	local _ASK_SET_VAR="${1}"
	local _PROMPT="${2}"

  if [ -n "${3}" ]; then
    local _DEFAULT="${3}"
    eval "if [ ! \"\${${_ASK_SET_VAR}+x}\" ]; then
      _ANSWER=\$(ask \"${_PROMPT}\" \"${_DEFAULT}\")
      if [ -z \"\${_ANSWER}\" ]; then
        _ANSWER=\"\${_DEFAULT}\"
      fi
      ${_ASK_SET_VAR}=\"\${_ANSWER}\"
      export ${_ASK_SET_VAR}
    fi"
  else
    eval "if [ ! \"\${${_ASK_SET_VAR}+x}\" ]; then
      _ANSWER=\$(ask \"${_PROMPT}\")
      if [ ! -z \"\${_ANSWER}\" ]; then
        ${_ASK_SET_VAR}=\"\${_ANSWER}\"
        export ${_ASK_SET_VAR}
      fi
    fi"
  fi
}

## /desc Ask something hidden
## /usage: ask_hidden <prompt>(string) [default_value](string)
## /param <prompt> (string) Prompt to display
## /param [default_value] (any) Default value to assign
## /unposix
ask_hidden() {
	check_arguments $# 1 "ask_hidden <prompt>(string) [default_value](string)"
	local _PROMPT="${1}"
	local _DEFAULT
	local _ANSWER

	if [ -n ${2} ]; then
	  _DEFAULT=${2}
		_DEFAULT_DISPLAY=$(obfuscate ${_DEFAULT})
  	read -r -s -p "${_ANSWER} [${_DEFAULT_DISPLAY}]: " _ANSWER
    if [ -z ${_ANSWER} ]; then
      _ANSWER=${_DEFAULT}
    fi
  else
	  read -r -s -p "${_ANSWER}: " _ANSWER
	fi

	echo ${_ANSWER}
}
