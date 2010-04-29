# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.

PKG_NAME=php
PKG_URL="http://www.php.net/get/"
PKG_SRC="${PKG_NAME}-${CT_PHP_VERSION}"

do_php_get() {
	CT_GetFile "${PKG_SRC}" .tar.gz "${PKG_URL}"
}

do_php_extract() {
	CT_Extract "${PKG_SRC}"
	CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}


do_php_configure() {
	CT_DoStep INFO "Configuring ${PKG_NAME} "

	rm -rf config.{cache,status};	\
	CC="${CT_TARGET}-gcc"	\
	CFLAGS="-Os -DSQLITE_DISABLE_LFS=1 -L${CT_FS_DIR}/usr/lib -I${CT_FS_DIR}/usr/include"	\
	ac_cv_func_dlopen=yes	\
	php_cv_cc_rpath="no"	\
	CT_DoExecLog ALL	\
	./configure		\
	 --target=${CT_TARGET}	\
	 --host=${CT_TARGET}	\
	 --prefix=/usr		\
	 --exec-prefix=/usr	\
	 --bindir=/usr/bin	\
	 --sysconfdir=/etc	\
	 --program-suffix=""	\
	 --program-prefix=""	\
	 --disable-ctype	\
	 --disable-debug	\
	 --disable-dom		\
	 --disable-filter	\
	 --disable-flatfile	\
	 --disable-force-cgi-redirect \
	 --disable-inifile	\
	 --disable-json		\
	 --disable-libxml	\
	 --disable-nls		\
	 --disable-reflection	\
	 --disable-short-tags	\
	 --disable-simplexml	\
	 --disable-spl		\
	 --disable-tokenizer	\
	 --disable-xml		\
	 --disable-xmlreader	\
	 --disable-xmlwriter	\
	 --with-config-file-path=/etc/	\
	 --without-gettext \
	 --without-pear		\
	 --without-iconv	\
	 --without-mysql	\
	 --without-mssql	\
	 --without-mysqli	\
	 --without-pcre-regex	\
	 --enable-discard-path	\
	 --enable-pcntl		\
	 --enable-pdo=static,${CT_FS_DIR}/usr	\
	 --with-pdo-sqlite=static,${CT_FS_DIR}/usr	\
	 --without-sqlite

	CT_EndStep
}

do_php() {
	CT_DoStep INFO "INSTALL ${PKG_NAME}"

	mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
	CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

	CT_DoLog EXTRA "COPY sources to build dir"
	{ cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

	do_php_configure

	CT_DoLog EXTRA "BUILD ${PKG_NAME}"
	CT_DoExecLog ALL				\
	${make} ${CT_PHP_PARALLEL:+${PARALLELMFLAGS}}	\
	 CROSS=${CT_TARGET}-				\
	 DESTDIR="${CT_FS_DIR}/"			\
	 INSTALL_ROOT="${CT_FS_DIR}/"			\
	 all

	CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
	CT_DoExecLog ALL			\
	${make} CROSS=${CT_TARGET}-		\
	 DESTDIR="${CT_FS_DIR}/"		\
	 INSTALL_ROOT="${CT_FS_DIR}/"		\
	 install

	CT_Popd
	CT_EndStep
}
