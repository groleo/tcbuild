# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


PKG_NAME=ntp
PKG_SRC="${PKG_NAME}-${CT_NTP_VERSION}"
PKG_URL="http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/"

do_ntp_get() {
    CT_GetFile "${PKG_SRC}" "${PKG_URL}"
}

do_ntp_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}


do_ntp_configure() {
    CT_DoStep INFO "Configuring ${PKG_NAME} "
    rm -rf config.cache	;			\
         CT_DoExecLog ALL				\
	 ./configure					\
        --host=${CT_TARGET}				\
	--prefix=/usr					\
	--exec-prefix=/usr				\
	--bindir=/usr/bin \
	--sbindir=/usr/sbin \
	--libdir=/lib \
	--libexecdir=/usr/lib \
	--sysconfdir=/etc \
	--datadir=/usr/share \
	--localstatedir=/var \
	--mandir=/usr/man \
	--infodir=/usr/info \
        --disable-nls					\
	--with-shared					\
	--disable-simulator \
	--enable-symlinks				\
	--without-debug					\
	--program-suffix=""				\
	--program-prefix=""				\
	--program-transform-name=s,,, \
	--without-crypto \
	--disable-tickadj \
	--disable-ntptime \
	--disable-ipv6 \
        CFLAGS="-I${CT_SRC_DIR}/${CT_KERNEL}-${CT_KERNEL_VERSION}/include -Os"

    CT_EndStep
}

do_ntp_make() {
    CT_DoLog EXTRA "BUILD ${PKG_NAME}"                \
    CT_DoExecLog ALL                                    \
    ${make} ${CT_NTP_PARALLEL:+${PARALLELMFLAGS}}          \
         CROSS=${CT_TARGET}-                            \
         DESTDIR="${CT_FS_DIR}/"                    \
         ${CT_NTP_VERBOSITY}                            \
         all
}

do_ntp_make_install() {
    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL                    \
    ${make} CROSS=${CT_TARGET}-            \
         DESTDIR="${CT_FS_DIR}/"                    \
         ${CT_NTP_VERBOSITY}    \
         install
}

do_ntp() {

    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_NAME}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_NAME}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    do_ntp_configure
    do_ntp_make
    do_ntp_make_install

    CT_Popd
    CT_EndStep
}

# This function is used to install those components needing the final C compiler
do_ntp_finish() {
    :
}

do_ntp_start_files() {
    :
}

