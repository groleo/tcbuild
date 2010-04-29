# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.

PKG_NAME=gdb
PKG_URL="ftp://sourceware.org/pub/gdb/releases/"
PKG_SRC="${PKG_NAME}-${CT_GDB_VERSION}"

do_gdbserver_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_gdbserver_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_gdbserver_configure() {
    CT_DoStep INFO "CHECK ${PKG_NAME} configuration"

	#CFLAGS="${CT_CFLAGS_FOR_HOST} -L${CT_FS_DIR}/lib -O2" \
	rm -rf config.cache; \
	CC_FOR_TARGET="${CT_TARGET}-gcc" \
	CXX_FOR_TARGET="${CT_TARGET}-g++" \
	CFLAGS="-L${CT_FS_DIR}/lib -O2" \
	CT_DoExecLog ALL		\
	./configure			\
	 --host=${CT_TARGET} \
	 --target=${CT_TARGET} \
	 --prefix=/usr \
	 --exec-prefix=/usr \
	 --bindir=/usr/bin \
	 --sbindir=/usr/sbin \
	 --libdir=/usr/lib \
	 --libexecdir=/usr/lib \
	 --sysconfdir=/etc \
	 --datadir=/usr/share \
	 --localstatedir=/var \
	 --includedir=/usr/include \
	 --mandir=/usr/man \
	 --infodir=/usr/info \
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

do_gdbserver() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}/gdb/gdbserver"
    do_gdbserver_configure

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL					\
    ${make} ${CT_GDB_PARALLEL:+${PARALLELMFLAGS}}	\
         DESTDIR="${CT_FS_DIR}/"			\
         ${CT_GDB_VERBOSITY}				\
         all

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL			\
    ${make} ${CT_GDB_PARALLEL:+${PARALLELMFLAGS}}	\
         DESTDIR="${CT_FS_DIR}/"			\
         ${CT_GDB_VERBOSITY}				\
         install

    CT_Popd

    CT_Popd
    CT_EndStep
}
