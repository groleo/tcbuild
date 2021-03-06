PKG_NAME=cloog-ppl
PKG_SRC="${PKG_NAME}-${CT_CLOOG_PPL_VERSION}"
PKG_URL="ftp://gcc.gnu.org/pub/gcc/infrastructure/"

do_cloog-ppl_get() {
    CT_GetFile "${PKG_SRC}" "${PKG_URL}"
}

do_cloog-ppl_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch   "${PKG_NAME}"
}

do_cloog-ppl() {
    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoStep INFO "Installing ${PKG_NAME}"

    CT_DoLog EXTRA "Configuring ${PKG_NAME}"

    rm -rf config.cache
    CC="${CT_HOST}-gcc"				\
    CFLAGS="${CT_CFLAGS_FOR_HOST}"		\
    CT_DoExecLog ALL				\
	"${CT_SRC_DIR}/${PKG_NAME}/configure"	\
	 --build=${CT_BUILD}			\
	 --host=${CT_HOST}			\
	 --prefix="${CT_PREFIX_DIR}"		\
	 --with-gmp="${CT_PREFIX_DIR}"		\
	 --with-ppl="${CT_PREFIX_DIR}"		\
	 --disable-shared			\
	 --enable-static

    CT_DoLog EXTRA "Building ${PKG_NAME}"
    CT_DoExecLog ALL make ${PARALLELMFLAGS}

    if [ "${CT_CLOOG_PPL_CHECK}" = "y" ]; then
        CT_DoLog EXTRA "Checking ${PKG_NAME}"
        CT_DoExecLog ALL make ${PARALLELMFLAGS} -s check
    fi

    CT_DoLog EXTRA "Installing ${PKG_NAME}"
    CT_DoExecLog ALL make install

    CT_EndStep
}

do_cloog-ppl_target() {
    if [ "${CT_CLOOG_PPL_TARGET}" != "y" ]; then
	return
    fi

    CT_DoStep INFO "Installing ${PKG_NAME} for the target"
    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}-target"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}-target"
}
