SUMMARY = "Realtek RTL88x2BU USB Wi-Fi kernel module"
DESCRIPTION = "Out-of-tree Realtek RTL88x2BU USB Wi-Fi driver for ECU-1170."
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ab842b299d0a92fb908d6eb122cd6de9"

SRC_URI = "file://rtl88x2bu-5.13.1.20210702.tar.gz"

S = "${UNPACKDIR}/88x2bu-20210702"

inherit module

DEPENDS += "bc-native"

INSANE_SKIP:kernel-module-88x2bu-${KERNEL_VERSION} += "buildpaths"
INSANE_SKIP:${PN}-dbg += "buildpaths"

MAKE_TARGETS = "modules"

EXTRA_OEMAKE += " \
    ARCH=${ARCH} \
    CROSS_COMPILE=${TARGET_PREFIX} \
    KERNELDIR=${STAGING_KERNEL_DIR} \
    KSRC=${STAGING_KERNEL_DIR} \
    KVER=${KERNEL_VERSION} \
    O=${STAGING_KERNEL_BUILDDIR} \
    KCFLAGS=-Wno-error \
    CONFIG_BR_EXT=n \
"

do_compile() {
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    oe_runmake ${MAKE_TARGETS}
}

do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless
    install -m 0644 ${S}/88x2bu.ko \
        ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/88x2bu.ko
}
