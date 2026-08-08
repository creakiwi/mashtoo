#!/bin/sh

MASHTOO_DIR=$(pwd)
PISHTOO_DIR="${MASHTOO_DIR}/pishtoo"

pishtoo_search() {
    check_arguments $# 1 "pishtoo_search <keyword>(string)"
    local keyword="$1"
    
    echo_info "Searching for \"${keyword}\" in pishtoo tree..."
    
    # Find all .pishtoo files
    local found=0
    find "${PISHTOO_DIR}" -name "*.pishtoo" 2>/dev/null | while read -r pkg_file; do
        # Extract package name from filename
        local pkg_name=$(basename "${pkg_file}" .pishtoo)
        
        # Grep for DESCRIPTION line
        local desc_line=$(grep "^## DESCRIPTION:" "${pkg_file}")
        
        # If no description found, skip or use empty
        if [ -n "${desc_line}" ]; then
            # Remove header
            local description=${desc_line#*# DESCRIPTION: }
        else
            local description="(No description)"
        fi
        
        # Combine name and description for search
        local search_string="${pkg_name} ${description}"
        
        # Check if keyword is in the search string (case insensitive)
        if echo "${search_string}" | grep -iq "${keyword}"; then
             # Highlight the keyword in the output
             # Escape backslashes in color codes
             local c_high=$(printf "%s" "${FCYELLOW}" | sed 's/\\/\\\\/g')
             local c_def=$(printf "%s" "${FCDEF}" | sed 's/\\/\\\\/g')
             
             # We want to highlight matches in pkg_name and description separately for cleaner output
             # Display: pkg_name description
             
             local out_line="${pkg_name} ${description}"
             local highlighted_line=$(echo "$out_line" | sed "s/${keyword}/${c_high}&${c_def}/gI")
             
             printf "  • %b\n" "${highlighted_line}"
             found=1
        fi
    done
    
    # Check if we found anything (grep exit code logic is tricky in pipe, so we rely on visual output for now)
    # A cleaner implementation would be to collect results in a variable
}

pishtoo_install() {
    check_arguments $# 1 "pishtoo_install <package>(string)"
    local package="$1"

    echo_info "Locating package \"${package}\"..."

    # Find the package script
    local script_path=$(find "${PISHTOO_DIR}" -name "${package}.pishtoo" 2>/dev/null | head -n 1)

    if [ -z "${script_path}" ]; then
        exit_error "Package script for '${package}' not found."
    fi

    echo_ok "Found: ${script_path}"
    echo_info "Loading script..."
    . "${script_path}"

    # Determine distribution (default to gentoo if not set)
    local target_dist="${DIST:-gentoo}"
    
    # Try specific distro function first, then generic
    # Naming convention: pkg_install_<package>_<distro>
    local func_dist="pkg_install_${package}_${target_dist}"
    local func_source="pkg_install_${package}_source"
    local func_generic="pkg_install_${package}"

    if command -v "${func_dist}" >/dev/null 2>&1; then
        echo_info "Executing specific installer: ${FBOLD}${func_dist}${FBOLD_OFF}"
        "${func_dist}"
    elif command -v "${func_source}" >/dev/null 2>&1; then
        echo_info "No installer for ${target_dist}. Using source fallback."
        echo_info "Executing source installer: ${FBOLD}${func_source}${FBOLD_OFF}"
        
        # Prepare isolated build environment
        local build_dir=$(mktemp -d -t pishtoo-build-XXXXXX)
        echo_info "Build directory: ${build_dir}"
        
        # Run in subshell to preserve current directory
        # We capture exit code to handle cleanup logic if needed
        (
            cd "${build_dir}" || exit 1
            "${func_source}"
        )
        local ret=$?
        
        # Cleanup
        if [ $ret -eq 0 ]; then
            echo_info "Build successful. Cleaning up..."
            rm -rf "${build_dir}"
        else
            echo_warn "Build failed. Artifacts left in ${build_dir} for inspection."
            exit $ret
        fi
    elif command -v "${func_generic}" >/dev/null 2>&1; then
        echo_warn "No specific or source installer found. Using generic fallback."
        echo_info "Executing generic installer: ${FBOLD}${func_generic}${FBOLD_OFF}"
        "${func_generic}"
    else
        exit_error "No install function found for ${package}. Checks failed for '${func_dist}', '${func_source}' and '${func_generic}'."
    fi
    
    echo_ok "Installation of ${package} complete."
}

pishtoo_uninstall() {
    check_arguments $# 1 "pishtoo_uninstall <package>(string)"
    local package="$1"

    echo_info "Locating package \"${package}\"..."

    # Find the package script
    local script_path=$(find "${PISHTOO_DIR}" -name "${package}.pishtoo" 2>/dev/null | head -n 1)

    if [ -z "${script_path}" ]; then
        exit_error "Package script for '${package}' not found."
    fi

    echo_ok "Found: ${script_path}"
    echo_info "Loading script..."
    . "${script_path}"

    # Determine distribution (default to gentoo if not set)
    local target_dist="${DIST:-gentoo}"
    
    # Try specific distro function first, then generic
    # Naming convention: pkg_uninstall_<package>_<distro>
    local func_dist="pkg_uninstall_${package}_${target_dist}"
    local func_generic="pkg_uninstall_${package}"

    if command -v "${func_dist}" >/dev/null 2>&1; then
        echo_info "Executing specific uninstaller: ${FBOLD}${func_dist}${FBOLD_OFF}"
        "${func_dist}"
    elif command -v "${func_generic}" >/dev/null 2>&1; then
        echo_warn "No specific uninstaller for ${target_dist}. Using generic fallback."
        echo_info "Executing generic uninstaller: ${FBOLD}${func_generic}${FBOLD_OFF}"
        "${func_generic}"
    else
        exit_error "No uninstall function found for ${package}. Checks failed for '${func_dist}' and '${func_generic}'."
    fi
    
    echo_ok "Uninstallation of ${package} complete."
}

# Version Helpers
_pishtoo_versions_debian() {
    local pkg_name=$1
    if command -v apt-cache >/dev/null 2>&1; then
        apt-cache madison "$pkg_name" | awk -F'|' '{print $2}' | tr -d ' ' | head -n 5
    else
        echo_warn "apt-cache not found (not on Debian?)"
    fi
}

_pishtoo_versions_gentoo() {
    local pkg_name=$1
    # Try equery first (gentoolkit), then emerge search
    if command -v equery >/dev/null 2>&1; then
        equery list -p -o "$pkg_name" 2>/dev/null
    elif command -v emerge >/dev/null 2>&1; then
        # Basic fallback, less precise
        emerge --search "$pkg_name" | grep "Latest version available:"
    else
        echo_warn "equery/emerge not found (not on Gentoo?)"
    fi
}

_pishtoo_versions_github() {
    local repo_url=$1
    if command -v git >/dev/null 2>&1; then
        echo_info "Querying GitHub tags from ${repo_url}..."
        git ls-remote --tags --refs "${repo_url}" \
            | cut -d/ -f3 \
            | grep -vE "nightly|beta|rc|alpha" \
            | sort -V \
            | tail -n 5
    else
        echo_warn "git not found. Cannot list versions from GitHub."
    fi
}

_pishtoo_versions_svn() {
    local repo_url=$1
    if command -v svn >/dev/null 2>&1; then
        echo_info "Querying SVN tags from ${repo_url}..."
        svn list "${repo_url}" \
            | sed 's/\/$//' \
            | sort -V \
            | tail -n 5
    else
        echo_warn "svn not found. Cannot list versions from SVN."
    fi
}

pishtoo_versions() {
    check_arguments $# 1 "pishtoo_versions <package>(string)"
    local package="$1"

    echo_info "Checking available versions for \"${package}\"..."

    # Find the package script
    local script_path=$(find "${PISHTOO_DIR}" -name "${package}.pishtoo" 2>/dev/null | head -n 1)

    if [ -z "${script_path}" ]; then
        exit_error "Package script for '${package}' not found."
    fi

    echo_ok "Found: ${script_path}"
    # We don't necessarily need to source the script if we use standard helpers, 
    # but we MUST source it to get the custom pkg_versions functions if they exist.
    . "${script_path}"

    local target_dist="${DIST:-gentoo}"

    # Priority:
    # 1. pkg_versions_<package>_<distro> (Specific override)
    # 2. pkg_versions_<package>_source (IF dist=source)
    # 3. pkg_versions_<package> (Generic logic provided by package maintainer)
    # 4. Fallback to trying the helper manually if the package file didn't define anything (Auto-magic)
    
    local func_versions_dist="pkg_versions_${package}_${target_dist}"
    local func_versions_source="pkg_versions_${package}_source"
    local func_versions_generic="pkg_versions_${package}"

    if command -v "${func_versions_dist}" >/dev/null 2>&1; then
        echo_info "Fetching versions (Strategy: ${func_versions_dist})..."
        "${func_versions_dist}"
    elif [ "${target_dist}" = "source" ] && command -v "${func_versions_source}" >/dev/null 2>&1; then
        echo_info "Fetching versions (Strategy: ${func_versions_source})..."
        "${func_versions_source}"
    elif command -v "${func_versions_generic}" >/dev/null 2>&1; then
        echo_info "Fetching versions (Strategy: Generic)..."
        "${func_versions_generic}"
    else
        # Auto-magic fallback: try to guess the package name is the same as the file name
        echo_warn "No specific version logic found in ${package}.pishtoo."
        echo_info "Attempting auto-discovery for ${target_dist} assuming package name '${package}'..."
        
        if [ "${target_dist}" = "debian" ]; then
            _pishtoo_versions_debian "${package}"
        elif [ "${target_dist}" = "gentoo" ]; then
            _pishtoo_versions_gentoo "${package}"
        elif [ "${target_dist}" = "source" ]; then
             echo_info "Trying to guess GitHub URL for ${package}..."
             # Heuristic: try standard github URL patterns or search
             # But first, warn that explicit function is better
             echo_warn "No pkg_versions_${package}_source defined. Cannot guess repository URL reliably."
             echo_info "Please define pkg_versions_${package}_source() { _pishtoo_versions_github \"<url>\"; } in ${package}.pishtoo"
        else
            echo "No strategy found for distribution '${target_dist}'"
        fi
    fi
}
