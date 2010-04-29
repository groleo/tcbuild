PKG_NAME=ppl
PKG_SRC="${PKG_NAME}-${CT_PPL_VERSION}"
PKG_URL="http://www.cs.unipr.it/ppl/Download/ftp/releases/0.10.2"

do_ppl_get() {
    CT_GetFile "${PKG_SRC}" "${PKG_URL}"
}

do_ppl_extract() {
    CT_Extract	"${PKG_SRC}"
    CT_Patch	"${PKG_SRC}"
}

do_ppl() {
    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoStep INFO "INSTALL ${PKG_SRC}"

    CT_DoLog EXTRA "CONFIG ${PKG_SRC}"

    rm -rf config.cache
    CFLAGS="${CT_CFLAGS_FOR_HOST}"		\
    CT_DoExecLog ALL				\
       "${CT_SRC_DIR}/${PKG_SRC}/configure"	\
        --build=${CT_BUILD}			\
        --host=${CT_HOST}			\
        --prefix="${CT_PREFIX_DIR}"		\
	--enable-cxx				\
	--with-gmp=${CT_PREFIX_DIR}		\
	--with-gmpxx=${CT_PREFIX_DIR}		\
	--enable-shared

    CT_DoLog EXTRA "BUILD ${PKG_SRC}"
    CT_DoExecLog ALL make ${PARALLELMFLAGS}

    if [ "${CT_PPL_CHECK}" = "y" ]; then
        CT_DoLog EXTRA "CHECK ${PKG_SRC}"
        CT_DoExecLog ALL make ${PARALLELMFLAGS} -s check
    fi

    CT_DoLog EXTRA "INSTALL ${PKG_SRC}"
    CT_DoExecLog ALL make install

    CT_EndStep
}

do_ppl_target() {
	:
}
