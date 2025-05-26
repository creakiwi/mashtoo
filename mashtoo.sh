#!/bin/sh

MAIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

. ./internal/includes.sh

check_dependencies
cleanup_drive
summary
download_dist
cleanup_drive
handle_livecd