## /desc Uppercase value
## /usage upper <value>(string)
## /param <value> (string) The value to uppercase
## /posix
upper() {
	check_arguments "${#}" "1" "upper <value>(string)"
    printf '%s' "${1}" | tr '[:lower:]' '[:upper:]'
}

## /desc Lowercase value
## /usage lower <value>(string)
## /param <value> (string) The value to lowercase
## /posix
lower() {
	check_arguments "${#}" "1" "lower <value>(string)"
    printf '%s' "${1}" | tr '[:upper:]' '[:lower:]'
}
