ECU1170_CONF="/etc/ecu1170.conf"
ECU1170_IIO_DEVICE="/sys/bus/iio/devices/iio:device0"

AI_DEFAULT_RANGECODE="0x149"
AI_VOL_RANGECODE="0x149"
AI_CUR_RANGECODE="0x182"
AI_VOL_DEFAULT_VMIN="0xf"
AI_VOL_DEFAULT_VMAX="0x333"
AI_CUR_DEFAULT_VMIN="0x15"
AI_CUR_DEFAULT_VMAX="0x33c"

AI0_RANGECODE="$AI_DEFAULT_RANGECODE"
AI1_RANGECODE="$AI_DEFAULT_RANGECODE"
AI_VOL_VMIN="$AI_VOL_DEFAULT_VMIN"
AI_VOL_VMAX="$AI_VOL_DEFAULT_VMAX"
AI_CUR_VMIN="$AI_CUR_DEFAULT_VMIN"
AI_CUR_VMAX="$AI_CUR_DEFAULT_VMAX"

ai_conf_get() {
    key="$1"
    [ -f "$ECU1170_CONF" ] || return 1
    awk -F= -v key="$key" '$1 == key { value = $2 } END { if (value != "") print value }' "$ECU1170_CONF"
}

ai_is_uint() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
        *) return 0 ;;
    esac
}

ai_is_raw_value() {
    case "$1" in
        0x[0-9a-fA-F]*|0X[0-9a-fA-F]*)
            case "${1#??}" in
                ''|*[!0-9a-fA-F]*) return 1 ;;
                *) return 0 ;;
            esac
            ;;
        *) ai_is_uint "$1" ;;
    esac
}

ai_to_dec() {
    value="$1"
    ai_is_raw_value "$value" || return 1
    printf "%d\n" "$value"
}

ai_normalize_rangecode() {
    case "$1" in
        0x149|0X149) echo "$AI_VOL_RANGECODE" ;;
        0x182|0X182) echo "$AI_CUR_RANGECODE" ;;
        *) return 1 ;;
    esac
}

ai_range_label() {
    case "$1" in
        "$AI_VOL_RANGECODE") echo "0~10V" ;;
        "$AI_CUR_RANGECODE") echo "0~20mA" ;;
        *) return 1 ;;
    esac
}

ai_range_prefix() {
    case "$1" in
        "$AI_VOL_RANGECODE") echo "AI_VOL" ;;
        "$AI_CUR_RANGECODE") echo "AI_CUR" ;;
        *) return 1 ;;
    esac
}

ai_range_pmax() {
    case "$1" in
        "$AI_VOL_RANGECODE") echo "10.0" ;;
        "$AI_CUR_RANGECODE") echo "20.0" ;;
        *) return 1 ;;
    esac
}

ai_load_config() {
    value="$(ai_conf_get AI0_RANGECODE)"
    AI0_RANGECODE="$(ai_normalize_rangecode "$value" 2>/dev/null || echo "$AI_DEFAULT_RANGECODE")"

    value="$(ai_conf_get AI1_RANGECODE)"
    AI1_RANGECODE="$(ai_normalize_rangecode "$value" 2>/dev/null || echo "$AI_DEFAULT_RANGECODE")"

    value="$(ai_conf_get AI_VOL_VMIN)"
    if ai_is_raw_value "$value"; then AI_VOL_VMIN="$value"; else AI_VOL_VMIN="$AI_VOL_DEFAULT_VMIN"; fi

    value="$(ai_conf_get AI_VOL_VMAX)"
    if ai_is_raw_value "$value"; then AI_VOL_VMAX="$value"; else AI_VOL_VMAX="$AI_VOL_DEFAULT_VMAX"; fi

    value="$(ai_conf_get AI_CUR_VMIN)"
    if ai_is_raw_value "$value"; then AI_CUR_VMIN="$value"; else AI_CUR_VMIN="$AI_CUR_DEFAULT_VMIN"; fi

    value="$(ai_conf_get AI_CUR_VMAX)"
    if ai_is_raw_value "$value"; then AI_CUR_VMAX="$value"; else AI_CUR_VMAX="$AI_CUR_DEFAULT_VMAX"; fi
}

ai_save_config() {
    tmp="${ECU1170_CONF}.$$"
    umask 022
    {
        echo "AI0_RANGECODE=$AI0_RANGECODE"
        echo "AI1_RANGECODE=$AI1_RANGECODE"
        echo "AI_VOL_VMIN=$AI_VOL_VMIN"
        echo "AI_VOL_VMAX=$AI_VOL_VMAX"
        echo "AI_CUR_VMIN=$AI_CUR_VMIN"
        echo "AI_CUR_VMAX=$AI_CUR_VMAX"
    } > "$tmp" && mv "$tmp" "$ECU1170_CONF"
}

ai_ensure_config() {
    if [ -f "$ECU1170_CONF" ]; then
        ai_load_config
    fi
    ai_save_config
}

ai_get_channel_rangecode() {
    case "$1" in
        0) echo "$AI0_RANGECODE" ;;
        1) echo "$AI1_RANGECODE" ;;
        *) return 1 ;;
    esac
}

ai_set_channel_rangecode() {
    ch="$1"
    code="$2"
    case "$ch" in
        0) AI0_RANGECODE="$code" ;;
        1) AI1_RANGECODE="$code" ;;
        *) return 1 ;;
    esac
}

ai_read_raw() {
    case "$1" in
        0) raw_path="${ECU1170_IIO_DEVICE}/in_voltage1_raw" ;;
        1) raw_path="${ECU1170_IIO_DEVICE}/in_voltage2_raw" ;;
        *) return 1 ;;
    esac

    [ -r "$raw_path" ] || return 1
    raw="$(cat "$raw_path")" || return 1
    ai_is_uint "$raw" || return 1
    echo "$raw"
}

ai_set_calibration() {
    code="$1"
    vmin="$2"
    vmax="$3"

    ai_is_raw_value "$vmin" || return 1
    ai_is_raw_value "$vmax" || return 1

    case "$code" in
        "$AI_VOL_RANGECODE")
            AI_VOL_VMIN="$vmin"
            AI_VOL_VMAX="$vmax"
            ;;
        "$AI_CUR_RANGECODE")
            AI_CUR_VMIN="$vmin"
            AI_CUR_VMAX="$vmax"
            ;;
        *)
            return 1
            ;;
    esac
}

ai_get_vmin() {
    case "$1" in
        "$AI_VOL_RANGECODE") echo "$AI_VOL_VMIN" ;;
        "$AI_CUR_RANGECODE") echo "$AI_CUR_VMIN" ;;
        *) return 1 ;;
    esac
}

ai_get_vmax() {
    case "$1" in
        "$AI_VOL_RANGECODE") echo "$AI_VOL_VMAX" ;;
        "$AI_CUR_RANGECODE") echo "$AI_CUR_VMAX" ;;
        *) return 1 ;;
    esac
}
