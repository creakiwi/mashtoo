#!/bin/sh

################
# EXIT METHODS #
################

# usage: exit_error [error_code(int) [error_msg](str)]
exit_error()
{
	if [ ${#} -eq 2 ]
	then
		echo ${2} >&2
	fi

	if [ $# -ge 1 ]
	then
		exit ${1}
	else
		exit 1
	fi
}

# usage: exit_success
exit_success()
{
	exit 0
}

#usage: equals_or_exit <first_parameter>(int|str) <second_parameter>(int|str)
equals_or_exit()
{
	check_arguments $# 2 "<first_parameter>(int|str) <second_parameter>(int|str)"

	VALID=1
	if [ ${1} != ${2} ]
	then
		VALID=0
	fi

	if [ ${VALID} -eq 1 ]
	then
		echo_ok
	else
		echo_ko
		exit_error 1
	fi
}

################
# INPUT/OUTPUT #
################

# usage: echo_ok [message]<str>
echo_ok()
{
	if [ -n "$1" ]
	then
		echo -e "${FCGREEN}${FBOLD}[OK]${FBOLD_OFF} ${1}${FCDEF}"
	else
		echo -e "${FCGREEN}${FBOLD}[OK]${FBOLD_OFF}${FCDEF}"
	fi
}

# usage: echo_warning [message]<str>
echo_warn()
{
	if [ -n "$1" ]
	then
		echo -e "${FCYELLOW}${FBOLD}[!!]${FBOLD_OFF} ${1}${FCDEF}"
	else
		echo -e "${FCYELLOW}${FBOLD}[!!]${FBOLD_OFF}${FCDEF}"
	fi
}

# usage: echo_ok [message]<str>
echo_ko()
{
	if [ -n "$1" ]
	then
		echo -e "${FCRED}${FBOLD}[KO]${FBOLD_OFF} ${1}${FCDEF}"
	else
		echo -e "${FCRED}${FBOLD}[KO]${FBOLD_OFF}${FCDEF}"
	fi
}

# usage: repeat <character>(int|str|chr) <number of times>(int)
repeat()
{
	check_arguments $# 2 "function repeat require two parameters character to repeat and number of times\nusage: repeat <character>(int|str|chr) <number of times>(int)"

	local start=1
	local end=${1:-80}
	local str="${2:-=}"
	local range=$(seq $start $end)
	for i in $range
	do
		echo -n ${str}
	done
}

# usage: title <title>(mixed)
title()
{
	check_arguments $# 1 "title <title>"

	local SEPARATORS=$((${#1}+4))
	local TITLE="# ${1} #"
	echo ""
	repeat ${SEPARATORS} "#"
	echo ""
	echo ${TITLE} | tr a-z A-Z
	repeat ${SEPARATORS} "#"
	echo ""
	echo ""
}

obfuscate()
{
	check_arguments $# 1 "obfuscate <string>(str)"
	PASSWORD=${1}
	LENGTH=$((${#PASSWORD}-2))
	FIRST_CHAR=`echo ${PASSWORD} | sed -E 's/^(.{1}).*$/\1/'`
	LAST_CHAR=`echo ${PASSWORD} | sed -E 's/^.*(.{1})$/\1/'`
	MASK=$(printf "%0.s|*" $(seq 1 ${LENGTH}))
	MASK=`echo ${MASK} | sed 's/|//g'`
	OBFUSCATED="${FIRST_CHAR}${MASK}${LAST_CHAR}"
	echo ${OBFUSCATED}
}

ask()
{
	check_arguments $# 1 "ask <prompt>(str) [default_value](str)"
	DEFAULT="none"
	if [ -n ${2} ]
	then
		DEFAULT=${2}
	fi


	read -r -p "${1} [${DEFAULT}]: " ASK
	if [ -z ${ASK} ]
	then
		ASK=${2}
	fi
	echo ${ASK}
}

ask_hidden()
{
	check_arguments $# 1 "ask_hidden <prompt>(str) [default_value](str)"
	DEFAULT="none"
	if [ -n ${2} ]
	then
		DEFAULT=`obfuscate ${2}`
	fi

	read -r -s -p "${1} [${DEFAULT}]: " ASK
	if [ -z ${ASK} ]
	then
		ASK=${2}
	fi
	echo ${ASK}
}

########
# TIME #
########

# usage: timestamp
timestamp()
{
	echo `date +%s`
}

# usage: diff_timestamp <timestamp>(int) [human_readable](any)
diff_timestamp()
{
	check_arguments $# 1 "diff_timestamp <timestamp>(int)"

	CURRENT=`timestamp`
	DIFF=$((${CURRENT} - ${1}))
	if [ -n ${2} ]
	then
		echo `readabie_time ${DIFF}`
	else
		echo ${DIFF}
	fi
}

readabie_time()
{
	check_arguments $# 1 "readabie_time <timestamp>(int)"
	local DIFF=$1
	local DAYS=$(($DIFF/60/60/24))
	local HOURS=$(($DIFF/60/60%24))
	local MINUTS=$(($DIFF/60%60))
	local SECONDS=$(($DIFF%60))

	READABLE=""
	if [ ${SECONDS} -ge 0 ]
	then
		READABLE=`printf "%02d" ${SECONDS}`
	fi

	if [ ${MINUTS} -ge 0 ]
	then
		READABLE="`printf "%02d" ${MINUTS}`:${READABLE}"
	fi

	if [ ${HOURS} -ge 0 ]
	then
		READABLE="`printf "%02d" ${HOURS}`:${READABLE}"
	fi

	if [ ${DAYS} -gt 0 ]
	then
		READABLE="${DAYS} days ${READABLE}"
	fi
	echo $READABLE
}

##########
# OTHERS #
##########

# usage: check_arguments <passed_parameters>(int) <needed_parameters>(int) [usage](str)
check_arguments()
{
	if [ $# -lt 2 ]
	then
		echo "check_arguments require at least two parameters"
		echo "usage: check_arguments <passed_parameters>(int) <needed_parameters>(int) [usage](str)"
		exit 1
	fi

	if [ ${1} -lt ${2} ]
	then
		if [ $# -eq 3 ]
		then
			echo "usage: ${3}"
		else
			echo "Missing arguments."
		fi
		exit 1
	fi
}

run_quiet()
{
	TIMESTAMP=`timestamp`
	COMMAND=$@
	echo -e -n "Running \"${FCBLUE}$@${FCDEF}\"..."
	eval "${COMMAND}" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo_ok "(`diff_timestamp ${TIMESTAMP} 1`)"
	else
		echo_ko "(`diff_timestamp ${TIMESTAMP} 1`)"
	fi
}

run()
{
	COMMAND=$@
	echo -e -n "Running \"${FCBLUE}$@${FCDEF}\"..."
	eval "${COMMAND}"
	if [ $? -eq 0 ]; then
		echo_ok "(`diff_timestamp ${TIMESTAMP} 1`)"
	else
		echo_ko "(`diff_timestamp ${TIMESTAMP} 1`)"
	fi
}
