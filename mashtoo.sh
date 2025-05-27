#!/bin/sh

MAIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

. ./internal/includes.sh

summary
check_dependencies
cleanup_drive
download_dist
cleanup_drive
handle_livecd