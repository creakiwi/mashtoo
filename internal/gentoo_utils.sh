#!bin/sh

ensure_network() {
	check_arguments $# 1 "ensure_network <root_dir>(string)"
	local ROOT_DIR=${1}
  local TPL_INITRAMFS_DIR="$(tpl_dir)/gentoo/initramfs"

  run "mkdir -p ${ROOT_DIR}/etc/runlevels/default"
  run "cp -f ${TPL_INITRAMFS_DIR}/etc/conf.d/net ${ROOT_DIR}/net"
  run "ln -sf ${ROOT_DIR}/etc/init.d/net.lo ${ROOT_DIR}/etc/runlevels/default/net.lo"
}

ssh_at_boot() {
	check_arguments $# 1 "ssh_at_boot <root_dir>(string)"
	local ROOT_DIR=${1}

  ensure_network "${ROOT_DIR}"

  run "mkdir -p ${ROOT_DIR}/etc/runlevels/default"
  run "ln -sf ${ROOT_DIR}/etc/init.d/sshd ${ROOT_DIR}/etc/runlevels/default/sshd"

  # Allow root login
  run "sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' ${ROOT_DIR}/etc/ssh/sshd_config"
  run "sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' ${ROOT_DIR}/etc/ssh/sshd_config"
  run "cp $(secrets_dir)/authorized_keys ${ROOT_DIR}/root/.ssh/authorized_keys"
}
