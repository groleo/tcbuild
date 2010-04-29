# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.

PKG_NAME=popt
PKG_URL="http://ftp.de.debian.org/debian/pool/main/p/popt"
PKG_SRC="${PKG_NAME}-${CT_POPT_VERSION}"

do_popt_get() {
    CT_GetFile "${PKG_SRC}" "${PKG_URL}"
}

do_popt_extract() {
    CT_Extract	"${PKG_SRC}"
    CT_Patch	"${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_popt_configure() {
    CT_DoStep INFO "Configuring ${PKG_NAME} "
	rm -rf config.cache;		\
	ac_cv_va_copy="yes"  \
         CT_DoExecLog ALL		\
	./configure			\
	--host=${CT_TARGET}		\
	--prefix=/usr			\
	--sysconfdir=/etc		\
	--localstatedir=/var		\
	--mandir=/usr/man		\
	--infodir=/usr/info		\
	--disable-nls			\
	--disable-largefile		\
	CFLAGS="-Os"
    CT_EndStep
}

do_popt() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    do_popt_configure

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL					\
    ${make} ${CT_POPT_PARALLEL:+${PARALLELMFLAGS}}\
         CROSS=${CT_TARGET}-				\
         DESTDIR="${CT_FS_DIR}/"			\
         ${CT_POPT_VERBOSITY}			\
	 all

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL			\
    ${make} CROSS=${CT_TARGET}-		\
         DESTDIR="${CT_FS_DIR}/"	\
         install

    CT_Popd
    CT_EndStep
}
