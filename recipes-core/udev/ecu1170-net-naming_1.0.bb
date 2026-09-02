DESCRIPTION = "ECU1170 persistent network interface naming (PCIe r8168 port order)."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = " \
	file://70-persistent-net.rules \
"

S = "${UNPACKDIR}"

do_install() {
	install -d ${D}${sysconfdir}/udev/rules.d
	install -m 0644 ${UNPACKDIR}/70-persistent-net.rules ${D}${sysconfdir}/udev/rules.d/70-persistent-net.rules
}

FILES:${PN} = "${sysconfdir}/udev/rules.d/70-persistent-net.rules"
