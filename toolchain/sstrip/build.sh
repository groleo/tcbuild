PKG_NAME=sstrip
PKG_URL=http://git.buildroot.net/buildroot/plain/toolchain/${PKG_NAME}/

do_sstrip_get() {
    CT_GetFile ${PKG_NAME} ".c" ${PKG_URL}
}

do_sstrip_extract() {
    rm -rf ${CT_SRC_DIR}/sstrip
    mkdir ${CT_SRC_DIR}/sstrip
    cp "${CT_TARBALLS_DIR}/sstrip.c" ${CT_SRC_DIR}/sstrip
}
do_sstrip() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_NAME}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_NAME}"

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    cp ${CT_SRC_DIR}/${PKG_NAME}/${PKG_NAME}.c .
    CT_DoExecLog ALL "${CT_HOST}-gcc" -Wall -o ${PKG_NAME} "${PKG_NAME}.c"

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL ${install} -m 755 ${PKG_NAME} "${CT_PREFIX_DIR}/bin/${CT_TARGET}-${PKG_NAME}"

    CT_Popd
    CT_EndStep
}

