#!/bin/sh

MAIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DOWNLOAD_DIR="${MAIN_DIR}/downloads"

. ./internal/includes.sh

summary
download_dist