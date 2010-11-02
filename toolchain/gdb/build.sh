PKG_NAME=gdb
PKG_SRC="${PKG_NAME}-${CT_GDB_VERSION}"
PKG_URL="ftp://sourceware.org/pub/gdb/releases/"

do_gdb_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_gdb_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_gdb_configure() {
    CT_DoStep INFO "CHECK ${PKG_NAME} configuration"

	#CFLAGS="${CT_CFLAGS_FOR_HOST} -L${CT_FS_DIR}/lib -O2" \
	rm -rf config.cache; \
	CC_FOR_TARGET="${CT_TARGET}-gcc" \
	CXX_FOR_TARGET="${CT_TARGET}-g++" \
	CFLAGS="-L${CT_FS_DIR}/lib -O2" \
	CT_DoExecLog ALL		\
	./configure			\
	 --build=${CT_BUILD} \
	 --target=${CT_TARGET} \
	 --host=${CT_BUILD} \
	 --prefix=/ \
	 --exec-prefix=/ \
	 --bindir=/bin \
	 --sbindir=/sbin \
	 --libdir=/lib \
	 --libexecdir=/lib \
	 --sysconfdir=/etc \
	 --datadir=/share \
	 --localstatedir=/var \
	 --includedir=/include \
	 --mandir=/share/man \
	 --infodir=/info \
	 --without-uiout \
	 --disable-tui \
	 --disable-gdbtk \
	 --without-x \
	 --without-included-gettext \
	 --disable-sim \
	 --enable-threads \
	 --with-curses \
	 --enable-static \
	 --disable-werror

    CT_EndStep
}

do_gdb() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    do_gdb_configure

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL					\
    ${make} ${CT_GDB_PARALLEL:+${PARALLELMFLAGS}}	\
         CROSS=${CT_TARGET}-				\
         DESTDIR="${CT_FS_DIR}/"			\
         ${CT_GDB_VERBOSITY}				\
         all

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL                    \
    ${make} CROSS=${CT_TARGET}-            \
         DESTDIR="${CT_PREFIX_DIR}/"    \
         install

    do_gdb_finish
    CT_Popd
    CT_EndStep
}

# This function is used to install those components needing the final C compiler
do_gdb_finish() {
	CT_DoStep INFO "Finishing ${PKG_NAME}"
	# Move the ncurses libraries into /lib, since they're important:
    CT_EndStep
}

