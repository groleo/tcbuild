PKG_NAME=sqlite
PKG_URL="http://www.sqlite-editor.org/dist/v2.0"
PKG_URL="http://www.sqlite.org"
PKG_SRC="${PKG_NAME}-${CT_SQLITE_VERSION}"

do_sqlite_get() {
    CT_GetFile "${PKG_SRC}" .tar.gz "${PKG_URL}"
}

do_sqlite_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_sqlite_configure() {
	CT_DoStep INFO "Configuring ${PKG_NAME} "

	rm -rf config.cache;

	CFLAGS=-DSQLITE_DISABLE_LFS \
	 CT_DoExecLog ALL	\
	 ./configure		\
	 --host=${CT_TARGET}	\
	 --target=${CT_TARGET}	\
	 --prefix=/usr		\
	 --sysconfdir=/etc	\
	 --program-suffix=""	\
	 --program-prefix=""	\
	 --disable-largefile	\
	 --disable-debug	\
	 --disable-tcl		\
	 --disable-threadsafe

	CT_EndStep
}

do_sqlite() {
	CT_DoStep INFO "INSTALL ${PKG_NAME}"

	mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
	CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

	CT_DoLog EXTRA "COPY sources to build dir"
	{ cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

	do_sqlite_configure

	CT_DoLog EXTRA "BUILD ${PKG_NAME}"
	CT_DoExecLog ALL				\
	${make} ${CT_SQLITE_PARALLEL:+${PARALLELMFLAGS}}	\
	 CROSS=${CT_TARGET}-				\
	 DESTDIR="${CT_FS_DIR}/"			\
	 all

	CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
	CT_DoExecLog ALL			\
	${make} CROSS=${CT_TARGET}-		\
	 DESTDIR="${CT_FS_DIR}/"		\
	 install

	CT_Popd
	CT_EndStep
}
