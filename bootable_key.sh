#!/bin/sh
set -eu
MASHTOO_DIR="."

. ./.env

. "$MASHTOO_DIR/mashtoo.sh"

# The main installer script is fully agnostic.
# Distribution-specific callbacks are defined in dist/${DIST}.sh

summary
check_dependencies
download_dist
#cleanup_drive
#create_bootable_drive
handle_livecd
#cleanup_files
