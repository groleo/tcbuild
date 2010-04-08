PKG_NAME=util-linux-ng
PKG_URL="ftp://ftp.kernel.org/pub/linux/utils/util-linux-ng/v2.14/"
PKG_SRC="${PKG_NAME}-${CT_UTIL_LINUX_NG_VERSION}"

do_util-linux-ng_get() {
    CT_GetFile "${PKG_SRC}" "${PKG_URL}"
}

do_util-linux-ng_extract() {
    CT_Extract	"${PKG_SRC}"
    CT_Patch	"${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_util-linux-ng_configure() {
    CT_DoStep INFO "Configuring ${PKG_NAME} "
	rm -rf config.cache;		\
         CT_DoExecLog ALL		\
	./configure			\
	--host=${CT_TARGET}		\
	--prefix=/usr			\
	--sysconfdir=/etc		\
	--localstatedir=/var		\
	--mandir=/usr/man		\
	--infodir=/usr/info		\
	--docdir=/usr/doc/util-linux-ng-$VERSION \
	--disable-agetty			\
	--disable-mesg			\
	--disable-raw			\
	--disable-rdev			\
	--disable-rename			\
	--disable-schedutils		\
	--disable-use-tty-group		\
	--disable-reset			\
	--disable-arch			\
	--disable-write			\
	--disable-init			\
	--disable-kill			\
	--disable-last			\
	--disable-login-utils		\
	--disable-nls			\
	--disable-wall			\
	CFLAGS="-Os"
    CT_EndStep
}

do_util-linux-ng() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    do_util-linux-ng_configure

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL					\
    ${make} ${CT_UTIL_LINUX_NG_PARALLEL:+${PARALLELMFLAGS}}\
         CROSS=${CT_TARGET}-				\
         DESTDIR="${CT_FS_DIR}/"			\
         ${CT_UTIL_LINUX_NG_VERBOSITY}			\
	 all

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL			\
    ${make} CROSS=${CT_TARGET}-		\
         DESTDIR="${CT_FS_DIR}/"	\
         install

    CT_Popd
    CT_EndStep
}
