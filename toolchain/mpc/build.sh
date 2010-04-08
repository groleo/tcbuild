
PKG_NAME=mpc
PKG_SRC="${PKG_NAME}-${CT_MPC_VERSION}"
PKG_URL="http://www.multiprecision.org/mpc/download/"

# Download mpc
do_mpc_get() {
    CT_GetFile "${PKG_SRC}" "${PKG_URL}"
}

# Extract mpc
do_mpc_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${PKG_SRC}"
}

do_mpc() {
    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoStep INFO "Installing ${PKG_NAME}"
    ${CT_GET_CONFIG_FLAGS} "${CT_SRC_DIR}/${PKG_SRC}/configure" ${CT_TOP_DIR}/_mpc.in

    CT_DoLog EXTRA "Configuring ${PKG_NAME}"

    rm -rf config.cache
    CFLAGS="${CT_CFLAGS_FOR_HOST}"		\
    CT_DoExecLog ALL				\
       "${CT_SRC_DIR}/${PKG_SRC}/configure"				\
        --build=${CT_BUILD}			\
	--host=${CT_HOST}			\
	--prefix="${CT_PREFIX_DIR}"		\
	--disable-shared			\
	--enable-static				\
	--enable-fft				\
	--enable-mpbsd				\
	--enable-cxx				\
	 --with-ppl="${CT_PREFIX_DIR}"		\
	 --with-gmp="${CT_PREFIX_DIR}"		\

    CT_DoLog EXTRA "Building ${PKG_NAME}"
    CT_DoExecLog ALL make ${PARALLELMFLAGS}

    if [ "${CT_MPC_CHECK}" = "y" ]; then
        CT_DoLog EXTRA "Checking ${PKG_NAME}"
        CT_DoExecLog ALL make ${PARALLELMFLAGS} -s check
    fi

    CT_DoLog EXTRA "Installing ${PKG_NAME}"
    CT_DoExecLog ALL make install

    CT_EndStep
}

do_mpc_target() {
	:
}
