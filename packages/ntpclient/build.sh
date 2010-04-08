PKG_NAME=ntpclient
PKG_URL="http://doolittle.icarus.com/ntpclient"
PKG_ARCHV="${PKG_NAME}_${CT_NTPCLIENT_VERSION}"
PKG_SRC="${PKG_NAME}-2007"

do_ntpclient_get() {
    CT_GetFile "${PKG_ARCHV}" .tar.gz "${PKG_URL}"
}

do_ntpclient_extract() {
    CT_Extract "${PKG_ARCHV}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_ntpclient() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -


    CT_DoLog EXTRA "Applying patches"

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL                                    \
    ${make} ${CT_NTPCLIENT_PARALLEL:+${PARALLELMFLAGS}}    \
         CC=${CT_TARGET}-gcc                            \
         all

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"

    CT_DoExecLog ALL cp ntpclient "${CT_FS_DIR}/usr/bin"

    CT_Popd
    CT_EndStep
}
