#!/bin/sh

# Set working directory to script location
cd "$(dirname "$0")" || exit 1
MASHTOO_DIR=$(pwd)
export MASHTOO_DIR

# Source internals
if [ -f "./internal/colors.sh" ]; then
    . "./internal/colors.sh"
else
    echo "Error: internal/colors.sh not found"
    exit 1
fi

if [ -f "./internal/common.sh" ]; then
    . "./internal/common.sh"
else
    echo "Error: internal/common.sh not found"
    exit 1
fi

if [ -f "./_internal/pishtoo.sh" ]; then
    . "./_internal/pishtoo.sh"
else
    echo "Error: _internal/pishtoo.sh not found"
    exit 1
fi

# Argument parsing loop
while [ $# -gt 0 ]; do
    case "$1" in
        -d|--dist)
            if [ -n "$2" ]; then
                export DIST="$2"
                shift 2
            else
                echo_ko "Error: --dist requires an argument"
                exit 1
            fi
            ;;
        s|search)
            if [ -z "$2" ]; then
                echo_ko "Usage: $0 s(earch) <keyword>"
                exit 1
            fi
            pishtoo_search "$2"
            exit 0
            ;;
        i|install)
            if [ -z "$2" ]; then
                echo_ko "Usage: $0 i(nstall) <package>"
                exit 1
            fi
            pishtoo_install "$2"
            exit 0
            ;;
        u|uninstall)
            if [ -z "$2" ]; then
                echo_ko "Usage: $0 u(ninstall) <package>"
                exit 1
            fi
            pishtoo_uninstall "$2"
            exit 0
            ;;
        v|versions)
            if [ -z "$2" ]; then
                echo_ko "Usage: $0 v(ersions) <package>"
                exit 1
            fi
            pishtoo_versions "$2"
            exit 0
            ;;
        -h|--help|help)
            title "Pishtoo Package Manager"
            echo "Usage: $0 [options] {s|i|u|v} [args...]"
            echo ""
            echo "Options:"
            echo "  -d, --dist <distro>     Override target distribution (gentoo, debian...)"
            echo ""
            echo "Commands:"
            echo "  s, search <keyword>     Search for a package"
            echo "  i, install <package>    Install a package"
            echo "  u, uninstall <package>  Uninstall a package"
            echo "  v, versions <package>   List available versions"
            exit 0
            ;;
        *)
            echo_ko "Unknown argument: $1"
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
    esac
done

if [ $# -eq 0 ]; then
    echo "Usage: $0 [options] <command> [args]"
    echo "Try '$0 --help' for more information."
    exit 1
fi
