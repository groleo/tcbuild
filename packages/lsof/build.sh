PKG_NAME=lsof
PKG_URL="ftp://ftp.cs.mun.ca/pub/mirror/gentoo/distfiles"
PKG_SRC="${PKG_NAME}_${CT_LSOF_VERSION}"

do_lsof_get() {
    CT_GetFile "${PKG_SRC}" "${PKG_URL}"
}

do_lsof_extract() {
	CT_Extract "${PKG_NAME}_${CT_LSOF_VERSION}"

	if [ -f "${CT_SRC_DIR}/${PKG_NAME}_${CT_LSOF_VERSION}/${PKG_NAME}_${CT_LSOF_VERSION}_src.tar" ] ; then
		CT_DoExecLog ALL mv "${CT_SRC_DIR}/${PKG_NAME}_${CT_LSOF_VERSION}/${PKG_NAME}_${CT_LSOF_VERSION}_src.tar" "${CT_TARBALLS_DIR}"

		CT_Extract "${PKG_NAME}_${CT_LSOF_VERSION}_src"

		CT_DoExecLog ALL rm -rf "${CT_SRC_DIR}/${PKG_NAME}_${CT_LSOF_VERSION}"
		CT_DoExecLog ALL ln -sf "${CT_SRC_DIR}/${PKG_NAME}_${CT_LSOF_VERSION}_src" "${CT_SRC_DIR}/${PKG_NAME}_${CT_LSOF_VERSION}"
	fi
	CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
	return 0
}

do_lsof_configure() {
	CT_DoStep INFO "Configuring ${PKG_NAME} "

        LINUX_CLIB="-DGLIBCV=2\ -DUSE_LIB_REGEX"  \
	LSOF_HOST="${CT_TARGET}"	\
	LSOF_CC="${CT_TARGET}-cc"	\
	LSOF_AR="${CT_TARGET}-ar cr"	\
	CT_DoExecLog ALL	\
	 ./Configure -n linux

	CT_EndStep
}

do_lsof() {
	CT_DoStep INFO "INSTALL ${PKG_NAME}"

	mkdir -p "${CT_BUILD_DIR}/${PKG_NAME}"
	CT_Pushd "${CT_BUILD_DIR}/${PKG_NAME}"

	CT_DoLog EXTRA "COPY sources to build dir"
	{ cd "${CT_SRC_DIR}/${PKG_NAME}_${CT_LSOF_VERSION}"; tar cf - .; } |tar xf -

	do_lsof_configure

	CT_DoLog EXTRA "BUILD ${PKG_NAME}"

        #LINUX_CLIB="-DGLIBCV=2\ -DUSE_LIB_REGEX" LSOF_CFGF="-UHASIPv6 -U_FILE_OFFSET_BITS" \
	#LSOF_HOST="${CT_TARGET}" LSOF_CC="${CT_TARGET}-cc" \
	#LSOF_AR="${CT_TARGET}-ar" \
	CT_DoExecLog ALL				\
	${make} ${CT_LSOF_PARALLEL:+${PARALLELMFLAGS}}	\
	 CROSS=${CT_TARGET}-				\
	 DESTDIR="${CT_FS_DIR}/"			\
	 all

	CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
	CT_DoExecLog ALL			\
	${install} -m 4755 lsof "${CT_FS_DIR}/usr/bin/lsof"

	CT_Popd
	CT_EndStep
}

do_lsof_finish() {
	:
}

