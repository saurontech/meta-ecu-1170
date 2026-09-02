SUMMARY = "ECU1170 DIO and AI sysfs helper scripts"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://diread.sh \
    file://lsdwrite.sh \
    file://hsdwrite.sh \
    file://dowrite.sh \
    file://ecu1170-ai-common.sh \
    file://airangecode_get.sh \
    file://airangecode_set.sh \
    file://aicalibrate_vol.sh \
    file://aicalibrate_cur.sh \
    file://airead.sh \
"

S = "${UNPACKDIR}"

RDEPENDS:${PN} += "busybox"

FILES:${PN} += "${datadir}/ecu1170"

do_install() {
    install -d ${D}${bindir}
    install -d ${D}${datadir}/ecu1170
    install -m 0755 ${UNPACKDIR}/diread.sh ${D}${bindir}/diread.sh
    install -m 0755 ${UNPACKDIR}/lsdwrite.sh ${D}${bindir}/lsdwrite.sh
    install -m 0755 ${UNPACKDIR}/hsdwrite.sh ${D}${bindir}/hsdwrite.sh
    install -m 0755 ${UNPACKDIR}/dowrite.sh ${D}${bindir}/dowrite.sh
    install -m 0644 ${UNPACKDIR}/ecu1170-ai-common.sh ${D}${datadir}/ecu1170/ecu1170-ai-common.sh
    install -m 0755 ${UNPACKDIR}/airangecode_get.sh ${D}${bindir}/airangecode_get.sh
    install -m 0755 ${UNPACKDIR}/airangecode_set.sh ${D}${bindir}/airangecode_set.sh
    install -m 0755 ${UNPACKDIR}/aicalibrate_vol.sh ${D}${bindir}/aicalibrate_vol.sh
    install -m 0755 ${UNPACKDIR}/aicalibrate_cur.sh ${D}${bindir}/aicalibrate_cur.sh
    install -m 0755 ${UNPACKDIR}/airead.sh ${D}${bindir}/airead.sh
}
