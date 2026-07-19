#!/bin/sh

# usage: reprap <directory>(string)
reprap() {
	check_arguments $# 1 "reprap <directory>(string)"

	local DIRECTORY=${1}
	local MASHTOO_SRC_DIR=$(dirname "${MASHTOO_DIR}")
	local MASHTOO_DST="${DIRECTORY}/mashtoo"

	echo_todo "Should clone but not for now"
	run "mkdir -p ${MASHTOO_DST}"
	run "mkdir -p ${MASHTOO_DST}/downloads"
	run "touch ${MASHTOO_DST}/downloads/.gitkeep"
	run "mkdir -p ${MASHTOO_DST}/mnt"
	run "mkdir -p ${MASHTOO_DST}/mnt/initramfs"
	run "touch ${MASHTOO_DST}/mnt/initramfs/.gitkeep"
	run "mkdir -p ${MASHTOO_DST}/mnt/livecd"
	run "touch ${MASHTOO_DST}/mnt/livecd/.gitkeep"
	run "mkdir -p ${MASHTOO_DST}/mnt/sda2"
	run "touch ${MASHTOO_DST}/mnt/sda2/.gitkeep"
	run "mkdir -p ${MASHTOO_DST}/secrets"
	run "touch ${MASHTOO_DST}/secrets/.gitkeep"
	run "mkdir -p ${MASHTOO_DST}/tmp"
	run "touch ${MASHTOO_DST}/tmp/.gitkeep"
	run "cp -R ${MASHTOO_SRC_DIR}/.git ${MASHTOO_DST}"
	run "cp -R ${MASHTOO_SRC_DIR}/custom ${MASHTOO_DST}"
	run "cp -R ${MASHTOO_SRC_DIR}/dist ${MASHTOO_DST}"
	run "cp -R ${MASHTOO_SRC_DIR}/internal ${MASHTOO_DST}"
	run "cp -R ${MASHTOO_SRC_DIR}/templates ${MASHTOO_DST}"
	run "find ${MASHTOO_SRC_DIR} -maxdepth 1 -type f -exec cp {} ${MASHTOO_DST} \;"
	run "ln -s ${MASHTOO_DST}/mashtoo.sh /usr/local/sbin/mashtoo"
}
