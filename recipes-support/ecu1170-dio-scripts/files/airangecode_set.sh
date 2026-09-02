#!/bin/sh

usage() {
    echo "Usage: airangecode_set.sh ch value" >&2
}

. /usr/share/ecu1170/ecu1170-ai-common.sh

[ "$#" -eq 2 ] || {
    usage
    exit 1
}

ch="$1"
value="$2"

case "$ch" in
    0|1) ;;
    *)
        echo "Invalid AI channel: $ch" >&2
        usage
        exit 1
        ;;
esac

code="$(ai_normalize_rangecode "$value")" || {
    echo "Invalid range code: $value" >&2
    usage
    exit 1
}

ai_ensure_config || {
    echo "Failed to access $ECU1170_CONF" >&2
    exit 1
}

current="$(ai_get_channel_rangecode "$ch")" || exit 1
if [ "$current" != "$code" ]; then
    ai_set_channel_rangecode "$ch" "$code" || exit 1
    ai_save_config || {
        echo "fail"
        exit 1
    }
fi

ai_load_config
readback="$(ai_get_channel_rangecode "$ch")" || exit 1
if [ "$readback" = "$code" ]; then
    echo "success"
else
    echo "fail"
fi
