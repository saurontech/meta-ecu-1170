#!/bin/sh

usage() {
    echo "Usage: lsdwrite.sh ch dovalue" >&2
}

gpio_for_channel() {
    case "$1" in
        0) echo 479 ;;
        1) echo 480 ;;
        *) return 1 ;;
    esac
}

export_gpio() {
    gpio="$1"

    if [ ! -d "/sys/class/gpio/gpio${gpio}" ]; then
        echo "$gpio" > /sys/class/gpio/export 2>/dev/null || true
    fi

    [ -e "/sys/class/gpio/gpio${gpio}/value" ] || return 1
    echo out > "/sys/class/gpio/gpio${gpio}/direction" 2>/dev/null || true
    return 0
}

[ "$#" -eq 2 ] || {
    usage
    exit 1
}

ch="$1"
dovalue="$2"

gpio="$(gpio_for_channel "$ch")" || {
    echo "Invalid LSD channel: $ch" >&2
    usage
    exit 1
}

case "$dovalue" in
    0|1) ;;
    *)
        echo "Invalid DO value: $dovalue" >&2
        usage
        exit 1
        ;;
esac

export_gpio "$gpio" || {
    echo "Failed to access GPIO_$gpio" >&2
    exit 1
}

echo "$dovalue" > "/sys/class/gpio/gpio${gpio}/value" || exit 1
readback="$(cat "/sys/class/gpio/gpio${gpio}/value")" || exit 1

if [ "$readback" = "$dovalue" ]; then
    echo "success"
else
    echo "fail"
fi
