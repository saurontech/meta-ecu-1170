SUMMARY = "Realtek RTL8822B Bluetooth firmware for ECU-1170"
DESCRIPTION = "Bluetooth firmware files used by the RTL8822BU USB module on ECU-1170."
LICENSE = "Firmware-rtlwifi_firmware"
LIC_FILES_CHKSUM = "file://LICENCE.rtlwifi_firmware.txt;md5=225c5d5a7a0c640e4a0444004cd4238b"
NO_GENERIC_LICENSE[Firmware-rtlwifi_firmware] = "LICENCE.rtlwifi_firmware.txt"

SRC_URI = " \
    file://rtl_bt/rtl8822b_fw.bin \
    file://rtl_bt/rtl8822b_config.bin \
    file://LICENCE.rtlwifi_firmware.txt \
"

S = "${UNPACKDIR}"

inherit allarch

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/rtl_bt
    install -m 0644 ${UNPACKDIR}/rtl_bt/rtl8822b_fw.bin ${D}${nonarch_base_libdir}/firmware/rtl_bt/
    install -m 0644 ${UNPACKDIR}/rtl_bt/rtl8822b_config.bin ${D}${nonarch_base_libdir}/firmware/rtl_bt/
}

FILES:${PN} = "${nonarch_base_libdir}/firmware/rtl_bt/rtl8822b_fw.bin ${nonarch_base_libdir}/firmware/rtl_bt/rtl8822b_config.bin"
