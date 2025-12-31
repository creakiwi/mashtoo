#!/bin/sh

MASHTOO_DIR="."

. "$MASHTOO_DIR/mashtoo.sh"

function live_in_initramfs_callback_gentoo() {
  set_locale "fr" "fr_FR.UTF-8"
  ssh_at_boot "${INITRAMFS_EXTRACT_POINT}"
}

summary
check_dependencies
download_dist
#cleanup_drive
#create_bootable_drive
handle_livecd
#cleanup_files
