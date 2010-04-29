# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


PKG_NAME=nano
PKG_URL="http://www.nano-editor.org/dist/v2.0"
PKG_SRC="${PKG_NAME}-${CT_NANO_VERSION}"

do_nano_get() {
    CT_GetFile "${PKG_SRC}" .tar.gz "${PKG_URL}"
}

do_nano_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_nano_configure() {
	CT_DoStep INFO "Configuring ${PKG_NAME} "

	rm -rf config.cache;	\
	 CT_DoExecLog ALL	\
	 ./configure		\
	 --host=${CT_TARGET}	\
	 --prefix=/usr		\
	 --sysconfdir=/etc	\
	 --program-suffix=""	\
	 --program-prefix=""	\
	 --disable-largefile	\
	 --disable-debug	\
	 --disable-nls		\
	 --disable-mouse	\
	 --disable-speller	\
	 --disable-glibtest	\
	 CFLAGS="-I${CT_FS_DIR}/usr/include -Os"	\
	 LDFLAGS="-L${CT_FS_DIR}/lib -lncurses"

	CT_EndStep
}

do_nano() {
	CT_DoStep INFO "INSTALL ${PKG_NAME}"

	mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
	CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

	CT_DoLog EXTRA "COPY sources to build dir"
	{ cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

	do_nano_configure

	CT_DoLog EXTRA "BUILD ${PKG_NAME}"
	CT_DoExecLog ALL				\
	${make} ${CT_NANO_PARALLEL:+${PARALLELMFLAGS}}	\
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
