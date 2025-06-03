#!/bin/sh

MAIN_DIR=$(cd "$(dirname "$0")" && pwd)

. ./internal/includes.sh

summary
check_dependencies
download_dist
cleanup_drive
#create_bootable_drive
handle_livecd
