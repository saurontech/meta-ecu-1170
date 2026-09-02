#!/bin/sh
# ecu1170-setup.sh - prepare an ECU1170 build directory after repo sync.
#
# Run after sourcing oe-init-build-env:
#     ../layers/meta-ecu-1170/scripts/ecu1170-setup.sh
#
# Idempotent: re-running regenerates local.conf and only adds missing layers.

set -eu

BUILD_DIR="${1:-${BUILDDIR:-$PWD}}"
CONF_DIR="${BUILD_DIR}/conf"
BBLAYERS_CONF="${CONF_DIR}/bblayers.conf"
LOCAL_CONF="${CONF_DIR}/local.conf"

if [ ! -f "${BBLAYERS_CONF}" ]; then
    echo "ecu1170-setup: not a build directory: ${BUILD_DIR}" >&2
    echo "ecu1170-setup: source oe-init-build-env first, or pass the build dir" >&2
    exit 1
fi

add_layer() {
    layer="$1"

    if grep -v '^[[:space:]]*#' "${BBLAYERS_CONF}" | grep -q "/${layer}[[:space:]]*\\\\*[[:space:]]*$"; then
        printf '  [have] %s\n' "${layer}"
        return
    fi

    if grep -v '^[[:space:]]*#' "${BBLAYERS_CONF}" | grep -q "/${layer}[[:space:]]*\""; then
        printf '  [have] %s\n' "${layer}"
        return
    fi

    printf '  [ add] %s\n' "${layer}"
    tmp="${BBLAYERS_CONF}.tmp.$$"
    awk -v add="  \${TOPDIR}/../layers/${layer} \\\\" '
        BEGIN { inserted = 0 }
        /^[[:space:]]*"[[:space:]]*$/ && !inserted {
            print add
            inserted = 1
        }
        { print }
        END {
            if (!inserted) {
                exit 1
            }
        }
    ' "${BBLAYERS_CONF}" > "${tmp}"
    mv "${tmp}" "${BBLAYERS_CONF}"
}

remove_local_workspace_layer() {
    tmp="${BBLAYERS_CONF}.tmp.$$"
    grep -v '/build/workspace' "${BBLAYERS_CONF}" > "${tmp}"
    mv "${tmp}" "${BBLAYERS_CONF}"
}

write_local_conf() {
    rm -f "${LOCAL_CONF}"
    cat > "${LOCAL_CONF}" <<'LOCAL_EOF'
include include/common.conf
include include/demo.conf

MACHINE = "ecu1170"

BB_NUMBER_THREADS = "4"
PARALLEL_MAKE = "-j 6"
LOCAL_EOF
    printf '  [conf] %s\n' "${LOCAL_CONF}"
}

echo "ecu1170-setup: ${BUILD_DIR}"
remove_local_workspace_layer
add_layer meta-ecu-1170
write_local_conf
echo "ecu1170-setup: done"
