# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


PKG_NAME=ncurses
PKG_URL="http://ftp.gnu.org/pub/gnu/ncurses/"
PKG_SRC="${PKG_NAME}-${CT_NCURSES_VERSION}"

do_ncurses_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_ncurses_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_ncurses_configure() {
    CT_DoStep INFO "CHECK ${PKG_NAME} configuration"

	rm -rf config.cache; \
		BUILD_CC="${CT_BUILD}-gcc" \
		CFLAGS="${CT_CFLAGS_FOR_HOST} -Os"                  \
	        CT_DoExecLog ALL                                \
		./configure \
		--target=${CT_TARGET} \
		--host=${CT_TARGET} \
		--build=${CT_HOST} \
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
		--with-terminfo-dirs=/usr/share/terminfo \
		--with-default-terminfo-dir=/usr/share/terminfo \
		--with-shared --without-cxx --without-cxx-binding \
		--without-ada --without-progs --disable-big-core \
		--disable-nls --disable-largefile \
		--without-profile --without-debug --disable-rpath \
		--enable-echo --enable-const --enable-overwrite \
		--enable-broken_linker

    CT_EndStep
}

do_ncurses() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -


    do_ncurses_configure
    CT_DoLog EXTRA "BUILD ${PKG_NAME}" \
    CT_DoExecLog ALL                                    \
    ${make} ${CT_NCURSES_PARALLEL:+${PARALLELMFLAGS}}  \
         CROSS=${CT_TARGET}-                            \
         DESTDIR="${CT_FS_DIR}/"                    \
         ${CT_NCURSES_VERBOSITY}                    \
         all

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL                    \
    ${make} CROSS=${CT_TARGET}-            \
         DESTDIR="${CT_FS_DIR}/"    \
         install

    do_ncurses_finish
    CT_Popd
    CT_EndStep
}

# This function is used to install those components needing the final C compiler
do_ncurses_finish() {
	CT_DoStep INFO "Finishing ${PKG_NAME}"
	# Move the ncurses libraries into /lib, since they're important:
	mkdir -p ${CT_FS_DIR}/lib
	( cd ${CT_FS_DIR}/usr/lib
	  chmod 755 *.so
	  rm -f *.a
#
	  mv libncurses.so* ${CT_FS_DIR}/lib
	  ln -sf /lib/libncurses.so libncurses.so
#
	  mv libmenu.so* ${CT_FS_DIR}/lib
	  ln -sf /lib/libmenu.so libmenu.so
#
	  mv libpanel.so* ${CT_FS_DIR}/lib
	  ln -sf /lib/libpanel.so libpanel.so
#
	  mv libform.so* ${CT_FS_DIR}/lib
	  ln -sf /lib/libform.so libform.so
	  # Olde obsolete names, just in case
	  rm -f libcurses.so
	  ln -sf libncurses.so libcurses.so
        )
    CT_EndStep
}

