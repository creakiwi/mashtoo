#!/bin/sh
set -eu
MASHTOO_DIR="."

. ./.env

. "$MASHTOO_DIR/mashtoo.sh"

live_in_initramfs_callback_gentoo() {
  set_locale "${LOCALE_KEYMAP}" "${LOCALE_LANG}" "${INITRAMFS_EXTRACT_POINT}"
  ssh_at_boot "${INITRAMFS_EXTRACT_POINT}"
}

summary
check_dependencies
download_dist
#cleanup_drive
#create_bootable_drive
handle_livecd
#cleanup_files
