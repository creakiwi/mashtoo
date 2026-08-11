ensure_network() {
	check_arguments $# 1 "ensure_network <root_dir>(string)"
	local ROOT_DIR=${1}
	local TPL_INITRAMFS_DIR="$(tpl_dir)/gentoo/initramfs"

	run "mkdir -p ${ROOT_DIR}/etc/runlevels/default"
	run "cp -f ${TPL_INITRAMFS_DIR}/etc/conf.d/net ${ROOT_DIR}/etc/conf.d/net"
	run "cp -f ${TPL_INITRAMFS_DIR}/etc/local.d/00-fix-net.start ${ROOT_DIR}/etc/local.d/"
	run "ln -sf ${ROOT_DIR}/etc/init.d/net.lo ${ROOT_DIR}/etc/runlevels/default/net.lo"
}

set_locale() {
	check_arguments $# 3 "set_locale <keymap>(string) <lang>(string) <root_dir>(string)"
	local KEYMAP=${1}
	local LANG=${2}
	local ROOT_DIR=${3}

	run "mkdir -p ${ROOT_DIR}/etc/conf.d/"
  run "echo \"keymap=${KEYMAP}\" > ${ROOT_DIR}/etc/conf.d/keymaps"
  run "echo \"LANG=${LANG}\" > ${ROOT_DIR}/etc/locale.conf"
}

ssh_at_boot() {
	check_arguments $# 1 "ssh_at_boot <root_dir>(string)"
	local ROOT_DIR=${1}
	local TPL_INITRAMFS_DIR="$(tpl_dir)/gentoo/initramfs"

	ensure_network "${ROOT_DIR}"

	run "mkdir -p ${ROOT_DIR}/etc/runlevels/default"
	run "mkdir -p ${ROOT_DIR}/etc/ssh"

	run "ln -sf /etc/init.d/sshd ${ROOT_DIR}/etc/runlevels/default/sshd"
	run "ln -sf /etc/init.d/local ${ROOT_DIR}/etc/runlevels/default/local"

	run "mkdir -p ${ROOT_DIR}/etc/local.d"
	run "cp -f ${TPL_INITRAMFS_DIR}/etc/local.d/01-chronyd-fix.start ${ROOT_DIR}/etc/local.d/"
	run "cp -f ${TPL_INITRAMFS_DIR}/etc/local.d/10-sshd.start ${ROOT_DIR}/etc/local.d/"

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
	run "cp -f ${TPL_INITRAMFS_DIR}/etc/local.d/*-mashtoo-installer.start ${ROOT_DIR}/etc/local.d/"
	run "chmod +x ${ROOT_DIR}/etc/local.d/*-mashtoo-installer.start"
}

get_mirrors_list() {
    #r_get_mirrors_list=$(curl -s https://api.gentoo.org/mirrors/distfiles.xml | sed -n 's|.*<uri[^>]*>\(.*\)</uri>.*|\1|p')
    # ignore gtp/rsync
    echo_warn "Ignore rsync:// and ftp:// as download command only use wget or curl."
	r_get_mirrors_list=$(curl -s https://api.gentoo.org/mirrors/distfiles.xml | sed -n 's|.*<uri[^>]*>\(https\?://.*\)</uri>.*|\1|p')

    return 0
}

mirrors_select() {
    check_arguments "$#" 0 "mirrors_select [max](int)"

    _max=1
    if [ "$#" -gt 0 ]; then
       _max="${1}"
    fi

	r_mirrors_select=""
	_proxies_file="$(cache_dir)/${DIST}_proxies"

	if [ -n "$(find "${_proxies_file}" -mtime -1 2>/dev/null)" ]; then
		echo_info "Getting best proxy from cache"
		r_mirrors_select=$(cat "${_proxies_file}" | head -n "$_max")
	else
		echo_info "Selecting fast Gentoo mirror..." >&2
		_fast_mirrors="
https://distfiles.gentoo.org/
https://gentoo.mirrors.ovh.net/gentoo-distfiles/
https://gentoo.osuosl.org/
https://mirror.bytemark.co.uk/gentoo/
"
		_best_mirror=""
		for url in $_fast_mirrors; do
			if curl -sSL --connect-timeout 2 --max-time 3 -I "$url" >/dev/null 2>&1; then
				_best_mirror="$url"
				break
			fi
		done

		if [ -z "$_best_mirror" ]; then
			_best_mirror="https://distfiles.gentoo.org/"
		fi

		echo "$_best_mirror" > "${_proxies_file}"
		r_mirrors_select="$_best_mirror"
	fi

    return 0
}

verify_stage3_signature() {
	check_arguments "$#" "1" "verify_signatures <stage3_path>(string)"
	_stage3_path="${1}"

	echo_ok "Verify Stage3 signatures"

	run "rm -f $(download_dir)/*.verified"
	run "gpg --keyserver hkps://keys.gentoo.org --recv-keys 13EBBDBEDE7A12775DFDB1BABB572E0E2D182910"
	run "gpg --verify \"${_stage3_path}.asc\" \"${_stage3_path}\""
	if [ "${?}" -ne 0 ]; then
		exit_error "Unable to verify ${_stage3_path} signature."
	fi

	run "gpg --output \"${_stage3_path}.DIGESTS.verified\" --verify \"${_stage3_path}.DIGESTS\""
	if [ "${?}" -ne 0 ]; then
		exit_error "Unable to verify ${_stage3_path}.DIGESTS signature."
	fi

	run "gpg --output \"${_stage3_path}.sha256.verified\" --verify \"${_stage3_path}.sha256\""
	if [ "${?}" -ne 0 ]; then
		exit_error "Usnable to verify ${_stage3_path}.sha256 signature."
	fi

	return 0
}

download_stage3() {
	check_arguments "$#" "1" "mashtoo_installer_at_startup <initramfs_root_dir>(string)"
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
	_stage3_filename="${_stage3_path##*/}"
	_full_stage3_file="${_base_url}${_stage3_path}"
	_stage3_path="$(download_dir)/${_stage3_filename}"

	if [ ! -f "${_stage3_path}" ] \
		|| [ ! -f "${_stage3_path}.CONTENTS.gz" ] \
		|| [ ! -f "${_stage3_path}.DIGESTS" ] \
		|| [ ! -f "${_stage3_path}.asc" ] \
		|| [ ! -f "${_stage3_path}.sha256" ]; then
		download "${_full_stage3_file}" "${_stage3_path}"
		download "${_full_stage3_file}.CONTENTS.gz" "${_stage3_path}.CONTENTS.gz"
		download "${_full_stage3_file}.DIGESTS" "${_stage3_path}.DIGESTS"
		download "${_full_stage3_file}.asc" "${_stage3_path}.asc"
		download "${_full_stage3_file}.sha256" "${_stage3_path}.sha256"
	else
		echo_ok "${_stage3_path} and verification files already downloaded"
	fi

	verify_stage3_signature "${_stage3_path}"

	echo_ok "Copying stage3 files to initramfs"
	_initramfs_dst_stage3="${_initramfs_root_dir}/${_stage3_filename}"
	run "cp ${_stage3_path} ${_initramfs_dst_stage3}"
	run "cp ${_stage3_path}.asc ${_initramfs_dst_stage3}.asc"
}

run_chronyd() {
	chown ntp:ntp /run/chrony
	chronyd -q -u ntp
}
