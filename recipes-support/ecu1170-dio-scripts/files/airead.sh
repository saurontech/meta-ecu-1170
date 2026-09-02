#!/bin/sh

usage() {
    echo "Usage: airead.sh ch" >&2
}

. /usr/share/ecu1170/ecu1170-ai-common.sh

[ "$#" -eq 1 ] || {
    usage
    exit 1
}

ch="$1"
case "$ch" in
    0|1) ;;
    *)
        echo "Invalid AI channel: $ch" >&2
        usage
        exit 1
        ;;
esac

ai_ensure_config || {
    echo "Failed to access $ECU1170_CONF" >&2
    exit 1
}

code="$(ai_get_channel_rangecode "$ch")" || exit 1
pmax="$(ai_range_pmax "$code")" || exit 1
vmin="$(ai_get_vmin "$code")" || exit 1
vmax="$(ai_get_vmax "$code")" || exit 1
raw="$(ai_read_raw "$ch")" || {
    echo "Failed to read AI channel $ch raw data" >&2
    exit 1
}
vmin_dec="$(ai_to_dec "$vmin")" || exit 1
vmax_dec="$(ai_to_dec "$vmax")" || exit 1

awk -v ch="$ch" -v raw="$raw" -v vmin="$vmin_dec" -v vmax="$vmax_dec" -v pmax="$pmax" '
BEGIN {
    if ((vmax + 0.0) == (vmin + 0.0)) {
        exit 2
    }

    p = pmax * ((raw + 0.0) - (vmin + 0.0)) / ((vmax + 0.0) - (vmin + 0.0))
    printf("ai channel %d: %.3f\n", ch, p)
}'

case "$?" in
    0) ;;
    2)
        echo "Invalid calibration: vmax equals vmin" >&2
        exit 1
        ;;
    *)
        echo "Failed to calculate AI value" >&2
        exit 1
        ;;
esac
