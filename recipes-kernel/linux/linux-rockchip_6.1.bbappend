FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-arm64-dts-add-rk3568-ecu1170-board.patch file://0002-usb-serial-add-ch343-support.patch file://0003-net-support-ecu1170-ethernet-configuration.patch file://0004-serial-8250-support-ecu1170-rs485-gpio-control.patch"

