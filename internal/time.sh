## /desc Returns current timestamp
## /usage timestamp
## /return timestamp value
timestamp() {
	printf '%d' "`date +%s`"
}

## /desc Return difference between current timestamp and argument passed timestamp
## /usage diff_timestamp <timestamp>(integer) [human_readable](any)
## /param <timestamp> (integer) Timestamp to compare with
## /param [human_readable] (any) If specified, will show difference but human readable
## /return (string|integer) The difference between timestamps
diff_timestamp() {
	check_arguments $# 1 "diff_timestamp <timestamp>(integer) [human_readable](any)"
	local _TIMESTAMP="${1}"
	local _HUMAN_READABLE="${2}"
	local _CURRENT=`timestamp`
	local _DIFF=$((${_CURRENT} - ${_TIMESTAMP}))
	if [ -n "${_HUMAN_READABLE}" ]
	then
		echo `readable_time ${_DIFF}`
	else
		printf '%d' "${_DIFF}"
	fi
}

## /desc Return the human readable form of a timestamp
## /usage readable_time <timestamp>(integer)
## /param <timestamp> (integer) Timestamp to format
## /return (string) The human readable form
readable_time() {
	check_arguments $# 1 "readable_time <timestamp>(integer)"
	local _DIFF=$1
	local _DAYS=$(($_DIFF/60/60/24))
	local _HOURS=$(($_DIFF/60/60%24))
	local _MINUTES=$(($_DIFF/60%60))
	local _SECONDS=$(($_DIFF%60))
	local _READABLE=""

	if [ ${_SECONDS} -ge 0 ]
	then
		_READABLE=`printf '%02d' "${_SECONDS}"`
	fi

	if [ ${_MINUTES} -ge 0 ]
	then
		_READABLE="`printf '%02d' "${_MINUTES}"`:${_READABLE}"
	fi

	if [ ${_HOURS} -ge 0 ]
	then
		_READABLE="`printf '%02d' "${_HOURS}"`:${_READABLE}"
	fi

	if [ ${_DAYS} -gt 0 ]
	then
		_READABLE="${_DAYS} days ${_READABLE}"
	fi

	echo $_READABLE
}
