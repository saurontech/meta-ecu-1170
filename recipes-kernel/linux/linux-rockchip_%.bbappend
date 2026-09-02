FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:ecu1170 = " file://pca955x-gpio.cfg file://rockchip-can.cfg file://qmi-wwan.cfg file://ch343.cfg"
