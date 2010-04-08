PKG_NAME=joe
PKG_SRC="${PKG_NAME}-${CT_JOE_VERSION}"
PKG_URL="http://freefr.dl.sourceforge.net/sourceforge/joe-editor/"

do_joe_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_joe_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}


do_joe_configure() {
    CT_DoStep INFO "Configuring ${PKG_NAME} "
    rm -rf config.cache	;			\
         CT_DoExecLog ALL			\
	 ./configure				\
        --host=${CT_TARGET}			\
	--prefix=/usr				\
	--sysconfdir=/etc                       \
	--disable-largefile                     \
	--disable-termcap                       \
	--program-suffix=""			\
	--program-prefix=""			\
        CFLAGS="-I${CT_FS_DIR}/usr/include"	\
	LDFLAGS="-L${CT_FS_DIR}/lib -lncurses"
    CT_EndStep
}

do_joe() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    do_joe_configure

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL                                    \
    ${make} ${CT_JOE_PARALLEL:+${PARALLELMFLAGS}}  \
         CROSS=${CT_TARGET}-                            \
         DESTDIR="${CT_FS_DIR}/"                    \
         ${CT_JOE_VERBOSITY}                    \

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL                    \
    ${make} CROSS=${CT_TARGET}-            \
         DESTDIR="${CT_FS_DIR}/"    \
         install
    CT_Popd
    CT_EndStep
}
