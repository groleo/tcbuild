PKG_NAME=busybox
PKG_SRC="${PKG_NAME}-${CT_BUSYBOX_VERSION}"
PKG_URL="http://busybox.net/downloads/
	http://busybox.net/downloads/downloads/snapshots
	http://busybox.net/downloads/old-releases"

do_busybox_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_busybox_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${CT_PKG_DIR}/${PKG_NAME}/${PKG_SRC}"
}

do_busybox_configure() {
    CT_DoStep INFO "CHECK ${PKG_NAME} configuration"


    if [ "${CT_BUSYBOX_RUN_CONFIG}" = "y" ]; then
	if [ -f "${CT_BUSYBOX_CONFIG_FILE}" ]; then
		CT_Pushd "${CT_SRC_DIR}/${PKG_SRC}"
			CT_DoExecLog INFO cp "${CT_BUSYBOX_CONFIG_FILE}" .config
			${make} menuconfig 1>&6
			cp .config "${CT_BUSYBOX_CONFIG_FILE}"
		CT_Popd
	fi
    fi

    if [ ! -f "${CT_BUSYBOX_CONFIG_FILE}" ] ; then
        CT_DoLog WARN "No ${PKG_NAME} config file(${CT_BUSYBOX_CONFIG_FILE})"
        ( cd "${CT_SRC_DIR}/${PKG_SRC}" ; ${make} menuconfig ; cp .config "${CT_BUSYBOX_CONFIG_FILE}" ) 1>&6
    fi

    CT_EndStep
}

do_busybox() {
    do_busybox_configure

    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    # Simply copy files until busybox has the ablity to build out-of-tree
    CT_DoLog EXTRA "COPY sources to build dir"
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    # Retrieve the config file
    CT_DoExecLog ALL cp "${CT_BUSYBOX_CONFIG_FILE}" .config

    # So it is useless and seems to be a bad thing to
    # use LIBC_EXTRA_CFLAGS here.
    CT_DoLog EXTRA "APPLY configuration"
    CT_DoYes "" |CT_DoExecLog ALL               \
         ${make} \
	 CROSS_COMPILE="${CT_TARGET}-"    \
         PREFIX="${CT_SYSROOT_DIR}/"    \
         ${CT_BUSYBOX_VERBOSITY}                \
         oldconfig

    CT_DoLog EXTRA "BUILD ${PKG_NAME}"        \
    CFLAGS="${CT_CFLAGS_FOR_HOST}"            \
    CFLAGS_FOR_TARGET="${CT_TARGET_CFLAGS}"   \
    CT_DoExecLog ALL                          \
    ${make} ${CT_BUSYBOX_PARALLEL:+${PARALLELMFLAGS}}  \
         CROSS_COMPILE="${CT_TARGET}-"                    \
         PREFIX="${CT_SYSROOT_DIR}/"            \
         ${CT_BUSYBOX_VERBOSITY}                \
         all

    CT_DoLog EXTRA "INSTALL ${PKG_NAME}"
    CT_DoExecLog ALL                \
    ${make} ${CT_BUSYBOX_PARALLEL:+${PARALLELMFLAGS}}  \
         CROSS_COMPILE="${CT_TARGET}-"                    \
         PREFIX="${CT_SYSROOT_DIR}/"\
         ${CT_BUSYBOX_VERBOSITY}    \
         install

    CT_DoExecLog ALL cp -r _install/* "${CT_FS_DIR}"
    CT_Popd
    CT_EndStep
}
