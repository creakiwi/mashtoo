#!/bin/sh

MAIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

. ./internal/includes.sh

summary
download_dist
