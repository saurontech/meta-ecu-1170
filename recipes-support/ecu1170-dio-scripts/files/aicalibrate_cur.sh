#!/bin/sh

. /usr/share/ecu1170/ecu1170-ai-common.sh

code="$AI_CUR_RANGECODE"
label="$(ai_range_label "$code")"

ai_ensure_config || {
    echo "Failed to access $ECU1170_CONF" >&2
    exit 1
}

ai_set_channel_rangecode 0 "$code" || exit 1
ai_save_config || {
    echo "fail"
    exit 1
}

printf "Set AI channel 0 hardware jumper to %s, input maximum value, then press Enter..." "$label"
read dummy
vmax="$(ai_read_raw 0)" || {
    echo
    echo "Failed to read AI channel 0 raw data" >&2
    exit 1
}
echo

printf "Input minimum value on AI channel 0, then press Enter..."
read dummy
vmin="$(ai_read_raw 0)" || {
    echo
    echo "Failed to read AI channel 0 raw data" >&2
    exit 1
}
echo

ai_set_calibration "$code" "$vmin" "$vmax" || {
    echo "fail"
    exit 1
}

ai_save_config || {
    echo "fail"
    exit 1
}

echo "success"
