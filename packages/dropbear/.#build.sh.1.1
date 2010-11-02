# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.

PKG_NAME=dropbear
PKG_SRC="${PKG_NAME}-${CT_DROPBEAR_VERSION}"
PKG_URL="http://matt.ucc.asn.au/dropbear/releases/"

do_dropbear_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_dropbear_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}


do_dropbear_configure() {
    CT_DoStep INFO "Configuring ${PKG_NAME} "
    rm -rf config.cache	;			\
         CT_DoExecLog ALL			\
	 ./configure				\
        --host=${CT_TARGET}			\
	--prefix=/usr				\
	--sysconfdir=/etc			\
	--disable-largefile			\
	--disable-zlib				\
	--program-suffix=""			\
	--program-prefix=""

    CT_EndStep
}

do_dropbear() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    do_dropbear_configure

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"
    CT_DoExecLog ALL					\
    ${make} ${CT_DROPBEAR_PARALLEL:+${PARALLELMFLAGS}}	\
         CROSS=${CT_TARGET}-				\
         DESTDIR="${CT_FS_DIR}/"			\
         ${CT_DROPBEAR_VERBOSITY}			\
	 PROGRAMS="dropbear dbclient scp dropbearkey dropbearconvert" \
	 MULTI=0					\
	 STATIC=0					\
	 SCPPROGRESS=0

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL			\
    ${make} CROSS=${CT_TARGET}-		\
         DESTDIR="${CT_FS_DIR}/"	\
         install
    CT_Popd
    CT_EndStep
}
