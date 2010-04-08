PKG_NAME=libelf
PKG_URL="http://www.mr511.de/software/"
PKG_SRC="${PKG_NAME}-${CT_LIBELF_VERSION}"

do_libelf_get() {
    CT_GetFile "${PKG_SRC}" .tar.gz ${PKG_URL}
}

do_libelf_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${PKG_SRC}"
}

do_libelf() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"
    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    CT_DoLog EXTRA "Configuring ${PKG_NAME}"

    rm -rf config.cache;		\
    CC="${CT_TARGET}-gcc"		\
    CT_DoExecLog ALL			\
    ./configure				\
        --build=${CT_BUILD}		\
        --host=${CT_TARGET}		\
        --target=${CT_TARGET}		\
        --prefix=/usr			\
        --enable-compat			\
        --enable-elf64			\
        --enable-shared			\
        --enable-extended-format	\
        --enable-static

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL ${make}

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL ${make} instroot="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

