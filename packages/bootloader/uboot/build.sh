PKG_NAME=u-boot
CT_BOOTLOADER_VERSION="2010.06"
PKG_SRC="${PKG_NAME}-${CT_BOOTLOADER_VERSION}"
PKG_URL=ftp://ftp.denx.de/pub/u-boot/

do_bootloader_get() {
	CT_GetFile "${PKG_SRC}" "${PKG_URL}"
}
do_bootloader_extract() {
	CT_Extract "${PKG_SRC}"
	CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}
do_bootloader_configure() {
	CT_DoStep ALL "Config bootloader"
	CT_DoExecLog ALL make M5485CFE_config
	CT_EndStep
}

do_bootloader() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"
    mkdir -p "${CT_BUILD_DIR}/${PKG_NAME}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_NAME}"
    CT_DoLog EXTRA "Copying sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -
    do_bootloader_configure

    CROSS_COMPILE=${CT_TARGET}- CT_DoExecLog ALL make

    CT_DoExecLog ALL rm -rf "${CT_TOP_DIR}/u-boot.bin"
    CT_DoExecLog ALL cp u-boot.bin "${CT_TOP_DIR}"

    CT_DoExecLog ALL rm -rf "${CT_TOP_DIR}/u-boot.srec"
    CT_DoExecLog ALL cp u-boot.srec "${CT_TOP_DIR}"

    CT_Popd
    CT_EndStep
}

