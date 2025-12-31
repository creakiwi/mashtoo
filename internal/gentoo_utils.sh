#!bin/sh

ensure_network() {
	check_arguments $# 1 "ensure_network <root_dir>(string)"
	local ROOT_DIR=${1}
  local TPL_INITRAMFS_DIR="$(tpl_dir)/gentoo/initramfs"

  run "mkdir -p ${ROOT_DIR}/etc/runlevels/default"
  run "cp -f ${TPL_INITRAMFS_DIR}/etc/conf.d/net ${ROOT_DIR}/net"
  run "ln -sf ${ROOT_DIR}/etc/init.d/net.lo ${ROOT_DIR}/etc/runlevels/default/net.lo"
}

set_locale() {
	check_arguments $# 2 "set_locale <keymap>(string) <lang>(string)"
	local KEYMAP=${1}
	local LANG=${2}

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
  run "cp -f ${TPL_INITRAMFS_DIR}/etc/local.d/sshd.start ${ROOT_DIR}/etc/local.d/"
  run "chmod +x ${ROOT_DIR}/etc/local.d/sshd.start"

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
