PKG_NAME=axTLS
PKG_URL="http://garr.dl.sourceforge.net/sourceforge/axtls"
PKG_SRC="${PKG_NAME}-${CT_AXTLS_VERSION}"

do_axTLS_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_axTLS_extract() {
    CT_Extract "${PKG_SRC}"
    ln -sf "${CT_SRC_DIR}/${PKG_NAME}" "${CT_SRC_DIR}/${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
    #rm -rf "${CT_SRC_DIR}/${PKG_SRC}"
    #mv "${CT_SRC_DIR}/${PKG_NAME}" "${CT_SRC_DIR}/${PKG_SRC}"
}

do_axTLS_configure() {
    CT_DoStep INFO "CHECK ${PKG_NAME} configuration"

    if [ ! -f "${CT_AXTLS_CONFIG_FILE}" ] ; then
        CT_DoLog WARN "No ${PKG_NAME} config file(${CT_AXTLS_CONFIG_FILE})"
        ( cd "${CT_SRC_DIR}/${PKG_SRC}" ; ${make} menuconfig ; cp config/.config "${CT_AXTLS_CONFIG_FILE}" ) 1>&6
    fi

    CT_EndStep
}

do_axTLS() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir ${CT_SRC_DIR}/${PKG_SRC}"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    do_axTLS_configure

    # Retrieve the config file
    CT_DoExecLog ALL cp "${CT_AXTLS_CONFIG_FILE}" config/.config

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL                    \
    ${make} CC=${CT_TARGET}-gcc            \
         oldconfig all

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL                    \
    ${make} CC=${CT_TARGET}-gcc            \
         PREFIX=${CT_FS_DIR}/usr install

    CT_Popd
    CT_EndStep
}
