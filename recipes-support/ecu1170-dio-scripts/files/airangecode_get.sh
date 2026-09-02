#!/bin/sh

. /usr/share/ecu1170/ecu1170-ai-common.sh

ai_ensure_config || {
    echo "Failed to access $ECU1170_CONF" >&2
    exit 1
}

code="$AI0_RANGECODE"
label="$(ai_range_label "$code")" || exit 1
echo "ai channel 0 rangecode: $code - $label"

code="$AI1_RANGECODE"
label="$(ai_range_label "$code")" || exit 1
echo "ai channel 1 rangecode: $code - $label"
