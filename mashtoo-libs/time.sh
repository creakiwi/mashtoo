#!/bin/sh
set -eu

## /author alex-ception <alexandre@creakiwi.com> [https://github.com/alex-ception]
## /posix reviewer Gemini 3.5 flash
## /note 1st POSIX check

## /desc Returns current timestamp
## /usage timestamp
## /return (int) timestamp value
timestamp() {
	printf '%d' "$(date +%s)"
}

## /desc Return difference between current timestamp and argument passed timestamp
## /usage diff_timestamp <timestamp>(integer) [human_readable](any)
## /param <timestamp> (integer) Timestamp to compare with
## /param [human_readable] (any) If specified, will show difference but human readable
## /return (string|integer) The difference between timestamps
diff_timestamp() {
	check_arguments "$#" "1" "diff_timestamp <timestamp>(integer) [human_readable](any)"
	time_dt_timestamp="${1}"
	time_dt_human_readable="${2:-}"
	time_dt_current=$(timestamp)
	time_dt_diff=$((${time_dt_current} - ${time_dt_timestamp}))
	if [ -n "${time_dt_human_readable}" ]
	then
		printf "%s\n" "$(readable_time "${time_dt_diff}")"
	else
		printf '%d' "${time_dt_diff}"
	fi
}

## /desc Return the human readable form of a timestamp
## /usage readable_time <timestamp>(integer)
## /param <timestamp> (integer) Timestamp to format
## /return (string) The human readable form
readable_time() {
	check_arguments "$#" "1" "readable_time <timestamp>(integer)"
	time_rt_diff="$1"
	time_rt_days=$((${time_rt_diff}/60/60/24))
	time_rt_hours=$((${time_rt_diff}/60/60%24))
	time_rt_minutes=$((${time_rt_diff}/60%60))
	time_rt_seconds=$((${time_rt_diff}%60))
	time_rt_readable=""

	if [ "${time_rt_seconds}" -ge 0 ]
	then
		time_rt_readable="$(printf '%02d' "${time_rt_seconds}")"
	fi

	if [ "${time_rt_minutes}" -ge 0 ]
	then
		time_rt_readable="$(printf '%02d' "${time_rt_minutes}"):${time_rt_readable}"
	fi

	if [ "${time_rt_hours}" -ge 0 ]
	then
		time_rt_readable="$(printf '%02d' "${time_rt_hours}"):${time_rt_readable}"
	fi

	if [ "${time_rt_days}" -gt 0 ]
	then
		time_rt_readable="${time_rt_days} days ${time_rt_readable}"
	fi

	printf "%s\n" "${time_rt_readable}"
}
