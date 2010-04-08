PKG_NAME=strace
PKG_URL="http://mesh.dl.sourceforge.net/sourceforge/strace/"
PKG_SRC="${PKG_NAME}-${CT_STRACE_VERSION}"

do_strace_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_strace_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}


do_strace_configure() {
    CT_DoLog EXTRA "Configuring ${PKG_NAME}"

    rm -rf config.cache;	\
    CT_DoExecLog ALL                                        \
    autoconf && \
    ./configure   \
        --build=${CT_BUILD}                                 \
        --host=${CT_TARGET}                                 \
        --prefix=/usr
}

do_strace() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    do_strace_configure

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL ${make}

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL ${make} DESTDIR="${CT_FS_DIR}" install

    CT_Popd
    CT_EndStep
}

