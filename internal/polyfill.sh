if ! command_exists "envsubst"; then
envsubst() {
  local _INPUT=$(cat)
  local _VAR
  local _ESCAPED_VAL
  local _INPUT

  for _VAR in $(printf '%s\n' "${_INPUT}" | grep -o '\${[A-Za-z_][A-Za-z0-9_]*}' | tr -d '${}' | sort -u); do
    eval "_VAL=\${${_VAR}-}"
    _ESCAPED_VAL=$(printf '%s' "${_VAL}" | sed 's/[\/&]/\\&/g')
    _INPUT=$(printf '%s\n' "${_INPUT}" | sed "s|\${${_VAR}}|${_ESCAPED_VAL}|g")
  done

  printf '%s\n' "${_INPUT}"
}
fi
