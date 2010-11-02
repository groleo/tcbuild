# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.

PKG_NAME=mini-httpd
PKG_URL="http://www.acme.com/software/mini_httpd"
PKG_SRC="mini_httpd-${CT_MINIHTTPD_VERSION}"

do_mini-httpd_get() {
	CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_mini-httpd_extract() {
	CT_Extract "${PKG_SRC}"
	CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_mini-httpd_configure() {
	CT_DoStep INFO "CHECK ${PKG_NAME} configuration"

	CT_EndStep
}

do_mini-httpd() {
	CT_DoStep INFO "INSTALL ${PKG_NAME}"

	mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
	CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

	CT_DoLog EXTRA "COPY sources to build dir"
	{ cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

	do_mini-httpd_configure

	CT_DoLog EXTRA "BUILD ${PKG_NAME}"

	CFLAGS="-DCGI_NICE=0"			\
	CT_DoExecLog ALL			\
	${make} CC=${CT_TARGET}-gcc		\
		SSL_TREE=${CT_BUILD_DIR}/axTLS-${CT_AXTLS_VERSION}/ \
	all

	CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
	CT_DoExecLog ALL			\
	${make} CC=${CT_TARGET}-gcc		\
		BINDIR=${CT_FS_DIR}/usr/bin	\
		MANDIR=${CT_FS_DIR}/usr/man	\
	install

	CT_Popd
	CT_EndStep
}
