ensure_network() {
	check_arguments $# 1 "ensure_network <root_dir>(string)"
	local ROOT_DIR=${1}
	local TPL_INITRAMFS_DIR="$(tpl_dir)/gentoo/initramfs"

	run "mkdir -p ${ROOT_DIR}/etc/runlevels/default"
	run "cp -f ${TPL_INITRAMFS_DIR}/etc/conf.d/net ${ROOT_DIR}/net"
	run "ln -sf ${ROOT_DIR}/etc/init.d/net.lo ${ROOT_DIR}/etc/runlevels/default/net.lo"
}

set_locale() {
	check_arguments $# 3 "set_locale <keymap>(string) <lang>(string) <root_dir>(string)"
	local KEYMAP=${1}
	local LANG=${2}
	local ROOT_DIR=${3}

  run "echo 'keymap=${KEYMAP}' > ${ROOT_DIR}/etc/conf.d/keymaps"
  run "echo 'LANG=${LANG}' > ${ROOT_DIR}/etc/locale.conf"
}

ssh_at_boot() {
	check_arguments $# 1 "ssh_at_boot <root_dir>(string)"
	local ROOT_DIR=${1}
	local TPL_INITRAMFS_DIR="$(tpl_dir)/gentoo/initramfs"

	ensure_network "${ROOT_DIR}"

	run "mkdir -p ${ROOT_DIR}/etc/runlevels/default"
	run "ln -sf /etc/init.d/sshd ${ROOT_DIR}/etc/runlevels/default/sshd"
	run "ln -sf /etc/init.d/local ${ROOT_DIR}/etc/runlevels/default/local"

	run "mkdir -p ${ROOT_DIR}/etc/local.d"
	run "cp -f ${TPL_INITRAMFS_DIR}/etc/local.d/00-sshd.start ${ROOT_DIR}/etc/local.d/"
	run "chmod +x ${ROOT_DIR}/etc/local.d/00-sshd.start"

	# Allow root login by ssh keys
	# run "sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' ${ROOT_DIR}/etc/ssh/sshd_config"
	# run "sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' ${ROOT_DIR}/etc/ssh/sshd_config"
	run "sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' ${ROOT_DIR}/etc/ssh/sshd_config"
	run "sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' ${ROOT_DIR}/etc/ssh/sshd_config"

	run "mkdir -p ${ROOT_DIR}/root/.ssh"
	run "chmod 700 ${ROOT_DIR}/root/.ssh"
	run "cp -f $(secrets_dir)/authorized_keys ${ROOT_DIR}/root/.ssh/"
	run "chmod 600 ${ROOT_DIR}/root/.ssh/authorized_keys"

	run "mkdir -p ${ROOT_DIR}/etc/ssh"
	run "ssh-keygen -A -f ${ROOT_DIR}"

	run "echo 'rc_need="net"' >> ${ROOT_DIR}/etc/conf.d/sshd"
}

mashtoo_installer_at_startup() {
	check_arguments $# 1 "mashtoo_installer_at_startup <root_dir>(string)"
	local ROOT_DIR=${1}
	local TPL_INITRAMFS_DIR="$(tpl_dir)/gentoo/initramfs"

	run "mkdir -p ${ROOT_DIR}/etc/local.d"
	run "cp -f ${TPL_INITRAMFS_DIR}/etc/local.d/10-mashtoo-installer.start ${ROOT_DIR}/etc/local.d/"
	run "chmod +x ${ROOT_DIR}/etc/local.d/10-mashtoo-installer.start"
}

mirrors_select() {
    check_arguments "${#}" 0 "mirrors_select [max](int)"

    _max=1
    if [ "${#}" -gt 0 ]; then
       _max="${1}"
    fi

	_proxies_file="./tmp/${DIST}_proxies"

	if [ -f "${_proxies_file}" ]; then
		echo_info "Getting best proxy from cache"
	else
		get_mirrors_list
		_mirrors="${r_get_mirrors_list}"

		# Get the total number of mirrors securely in POSIX
		set -- $_mirrors
		_total=$#

		i=0
	    echo_info "Testing $_total mirrors (this may take a few minutes)..." >&2

		# Capture de toute la sortie du bloc dans la variable r_mirrors_select
		r_mirrors_select=$(
			{
				for url in $_mirrors; do
					i=$((i + 1))

					# 1. Extract the domain name (split using slashes)
					host=$(echo "$url" | awk -F/ '{print $3}')

					# Print live progress to stderr
					printf "\r[%d/%d] Testing %s...       " "$i" "$_total" "$host" >&2

					# 2. Ping: 1 packet (-c 1), 1-second timeout (-W 1)
					# 3. Extract the time with sed (captures the value after 'time=')
					latency=$(ping -c 1 -W 1 "$host" 2>/dev/null | sed -n 's/.*time=\([0-9.]*\).*/\1/p')

					# 4. Format the output: Latency MUST stay first for numerical sorting
					if [ -n "$latency" ]; then
						echo "$latency $url"
					else
						echo "99999 $url"
					fi
				done

				# Add a final newline to stderr to clean up the terminal after the loop
				echo "" >&2

			# 5. Sort numerically, keep the top $_max results, and extract ONLY the URL (column 2)
			} | sort -n | head -n "$_max" | awk '{print $2}'
		)
	fi

	echo_todo "cache file for proxy"
	#echo "${r_mirrors_select}" > "${_proxies_file}"

    return 0
}

get_mirrors_list() {
    r_get_mirrors_list=$(curl -s https://api.gentoo.org/mirrors/distfiles.xml | sed -n 's|.*<uri[^>]*>\(.*\)</uri>.*|\1|p')

    return 0
}

download_stage3()
{
	check_arguments "${#}" "1" "mashtoo_installer_at_startup <initramfs_root_dir>(string)"
	_initramfs_root_dir="${1}"

	mirrors_select
	_base_url="${r_mirrors_select}releases/${ARCH}/autobuilds/"
	_stage3_txt="latest-stage3-${ARCH}"

	if [ "${PROFILE}" = "desktop" ]; then
		_stage3_txt="${_stage3_txt}-desktop-${SYSINIT}"
	else
		if [ "${LIB_PROFILE}" = "nomultilib" ]; then
			_stage3_txt="${_stage3_txt}-nomultilib"
		fi
		_stage3_txt="${_stage3_txt}-${SYSINIT}"
	fi

	_stage3_txt="${_stage3_txt}.txt"

	_full_stage3_txt="${_base_url}${_stage3_txt}"
	_stage3_path=$(curl -sSL "$_full_stage3_txt" | awk '/^[0-9].*\.tar\.xz/ {print $1}')
	_full_stage3_file=$"${_base_url}${_stage3_path}"
	_dst_stage3="./tmp/${_stage3_path}"

	if [ ! -f "${_dst_stage3}" ] \
		|| [ ! -f "${_dst_stage3}.CONTENTS.gz" ] \
		|| [ ! -f "${_dst_stage3}.DIGESTS" ] \
		|| [ ! -f "${_dst_stage3}.asc" ] \
		|| [ ! -f "${_dst_stage3}.sha256" ]; then
		download "${_full_stage3_file}" "${_dst_stage3}"
		download "${_full_stage3_file}.CONTENTS.gz" "${_dst_stage3}.CONTENTS.gz"
		download "${_full_stage3_file}.DIGESTS" "${_dst_stage3}.DIGESTS"
		download "${_full_stage3_file}.asc" "${_dst_stage3}.asc"
		download "${_full_stage3_file}.sha256" "${_dst_stage3}.sha256"
	else
		echo_ok "${_stage3_path} and verification files already downloaded"
	fi

	run "cp ${_dst_stage3} ${_initramfs_root_dir}/${_stage3_path}"
	run "cp ${_dst_stage3}.CONTENTS.gz ${_initramfs_root_dir}/${_stage3_path}.CONTENTS.ge"
	run "cp ${_dst_stage3}.DIGESTS ${_initramfs_root_dir}/${_stage3_path}.DIGESTS"
	run "cp ${_dst_stage3}.asc ${_initramfs_root_dir}/${_stage3_path}.asc"
	run "cp ${_dst_stage3}.sha512 ${_initramfs_root_dir}/${_stage3_path}.sha512"
}

