do_install:append:ecu1170() {
    sed -i '/^\[core\]/a sw-cursor=true' ${D}${sysconfdir}/xdg/weston/weston.ini
    sed -i '/^\[core\]/a idle-time=0' ${D}${sysconfdir}/xdg/weston/weston.ini
}
