# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.

PKG_NAME=ppp
PKG_URL="ftp://ftp.samba.org/pub/ppp"
PKG_SRC="${PKG_NAME}-${CT_PPP_VERSION}"

do_ppp_get() {
	CT_GetFile "${PKG_SRC}" .tar.gz ${PKG_URL}
}

do_ppp_extract() {
	CT_Extract "${PKG_SRC}"
        CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_ppp_configure() {
	CT_DoStep INFO "Configuring ${PKG_NAME} "

	rm -rf config.cache;	\
	 CT_DoExecLog ALL	\
	 ./configure		\
	--host=${CT_TARGET}	\
	--prefix=/usr		\
	--exec-prefix=/usr	\
	--bindir=/usr/bin	\
	--sbindir=/usr/sbin	\
	--libdir=/lib		\
	--libexecdir=/usr/lib	\
	--sysconfdir=/etc	\
	--datadir=/usr/share	\
	--localstatedir=/var	\
	--mandir=/usr/man	\
	--infodir=/usr/info	\
	--program-suffix=""	\
	--program-prefix=""	\
	--disable-largefile	\
	--disable-debug		\
	--disable-nls		\
	COPTS="-Os"		\
	CFLAGS="-Os"

	CT_EndStep
}

do_ppp() {
	CT_DoStep INFO "INSTALL ${PKG_SRC}"

	mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
	CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

	CT_DoLog EXTRA "COPY sources to build dir"
	{ cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

	do_ppp_configure

	CT_DoLog EXTRA "BUILD ${PKG_SRC}"
	CT_DoExecLog ALL				\
	${make} ${CT_PPP_PARALLEL:+${PARALLELMFLAGS}}	\
	 CROSS=${CT_TARGET}-				\
	 CC=${CT_TARGET}-gcc				\
	 DESTDIR="${CT_FS_DIR}/"			\
	 all

	CT_DoExecLog ALL			\
	${make} CROSS=${CT_TARGET}-		\
	 DESTDIR="${CT_FS_DIR}/"		\
	 STRIP=true \
	 install

	CT_Popd
	CT_EndStep
}

