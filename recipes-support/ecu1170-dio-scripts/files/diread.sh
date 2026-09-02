#!/bin/sh

usage() {
    echo "Usage: diread.sh ch" >&2
}

gpio_for_channel() {
    case "$1" in
        0) echo 39 ;;
        1) echo 40 ;;
        2) echo 41 ;;
        3) echo 42 ;;
        4) echo 495 ;;
        5) echo 496 ;;
        6) echo 497 ;;
        7) echo 498 ;;
        8) echo 499 ;;
        9) echo 500 ;;
        10) echo 501 ;;
        11) echo 502 ;;
        12) echo 503 ;;
        13) echo 504 ;;
        14) echo 505 ;;
        15) echo 506 ;;
        16) echo 507 ;;
        17) echo 508 ;;
        18) echo 509 ;;
        19) echo 510 ;;
        *) return 1 ;;
    esac
}

export_gpio() {
    gpio="$1"

    if [ ! -d "/sys/class/gpio/gpio${gpio}" ]; then
        echo "$gpio" > /sys/class/gpio/export 2>/dev/null || true
    fi

    [ -e "/sys/class/gpio/gpio${gpio}/value" ] || return 1
    echo in > "/sys/class/gpio/gpio${gpio}/direction" 2>/dev/null || true
    return 0
}

[ "$#" -eq 1 ] || {
    usage
    exit 1
}

ch="$1"
gpio="$(gpio_for_channel "$ch")" || {
    echo "Invalid DI channel: $ch" >&2
    usage
    exit 1
}

export_gpio "$gpio" || {
    echo "Failed to access GPIO_$gpio" >&2
    exit 1
}

raw="$(cat "/sys/class/gpio/gpio${gpio}/value")" || exit 1
case "$raw" in
    0) divalue=1 ;;
    1) divalue=0 ;;
    *)
        echo "Invalid GPIO_$gpio value: $raw" >&2
        exit 1
        ;;
esac

echo "di channel $ch: $divalue"
