PKG_NAME=binutils
PKG_SRC="${PKG_NAME}-${CT_BINUTILS_VERSION}"
PKG_URL="{ftp,http}://{ftp.gnu.org/gnu,ftp.kernel.org/pub/linux/devel}/${PKG_NAME} ftp://gcc.gnu.org/pub/${PKG_NAME}/{releases,snapshots}"

do_binutils_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_binutils_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch   "${PKG_SRC}"
}

do_binutils() {
    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoStep INFO "Installing ${PKG_NAME}"
    ${CT_GET_CONFIG_FLAGS} "${CT_SRC_DIR}/${PKG_SRC}/configure" ${CT_TOP_DIR}/_${PKG_NAME}.in

    binutils_opts=
    # If GMP and MPFR were configured, then use that,
    # otherwise let binutils find the system-wide libraries, if they exist.
    if [ "${CT_GMP}" = "gmp" -a "${CT_MPFR}"="mpfr" ]; then
        binutils_opts="--with-gmp=${CT_PREFIX_DIR} --with-mpfr=${CT_PREFIX_DIR}"
    fi
    { cd "${CT_SRC_DIR}/${PKG_SRC}"; tar cf - .; } |tar xf -

    CT_DoLog EXTRA "Configuring ${PKG_NAME}"

    rm -rf config.cache
    CFLAGS="${CT_CFLAGS_FOR_HOST}"		\
    CT_DoExecLog ALL				\
	./configure				\
        --build=${CT_BUILD}			\
        --host=${CT_HOST}			\
        --target=${CT_TARGET}			\
        --prefix=${CT_PREFIX_DIR}		\
        --disable-nls				\
        --disable-multilib			\
        --disable-libada			\
        --disable-werror                        \
        --disable-libssp			\
        --enable-poison-system-directories      \
        ${binutils_opts}                        \
        ${CT_ARCH_WITH_FLOAT}                   \
        ${CT_BINUTILS_EXTRA_CONFIG}             \
        ${BINUTILS_SYSROOT_ARG}

    CT_DoLog EXTRA "Building ${PKG_NAME}"
    CT_DoExecLog ALL make ${PARALLELMFLAGS}

    CT_DoLog EXTRA "Installing ${PKG_NAME}"
    CT_DoExecLog ALL make install

    # Make those new tools available to the core C compilers to come.
    # Note: some components want the ${TARGET}-{ar,as,ld,strip} commands as
    # well. Create that.
    mkdir -p "${CT_CC_CORE_STATIC_PREFIX_DIR}/${CT_TARGET}/bin"
    mkdir -p "${CT_CC_CORE_STATIC_PREFIX_DIR}/bin"
    mkdir -p "${CT_CC_CORE_SHARED_PREFIX_DIR}/${CT_TARGET}/bin"
    mkdir -p "${CT_CC_CORE_SHARED_PREFIX_DIR}/bin"
    for t in ar as ld strip; do
        ln -sv "${CT_PREFIX_DIR}/bin/${CT_TARGET}-${t}" "${CT_CC_CORE_STATIC_PREFIX_DIR}/${CT_TARGET}/bin/${t}"
        ln -sv "${CT_PREFIX_DIR}/bin/${CT_TARGET}-${t}" "${CT_CC_CORE_STATIC_PREFIX_DIR}/bin/${CT_TARGET}-${t}"
        ln -sv "${CT_PREFIX_DIR}/bin/${CT_TARGET}-${t}" "${CT_CC_CORE_SHARED_PREFIX_DIR}/${CT_TARGET}/bin/${t}"
        ln -sv "${CT_PREFIX_DIR}/bin/${CT_TARGET}-${t}" "${CT_CC_CORE_SHARED_PREFIX_DIR}/bin/${CT_TARGET}-${t}"
    done 2>&1 |CT_DoLog ALL

    CT_Popd
    CT_EndStep
}

# Now on for the target libraries
do_binutils_target() {
    targets=
    [ "${CT_BINUTILS_FOR_TARGET_IBERTY}" = "y" ] && targets="${targets} libiberty"
    [ "${CT_BINUTILS_FOR_TARGET_BFD}"    = "y" ] && targets="${targets} bfd"
    targets="${targets# }"

    binutils_opts=
    # If GMP and MPFR were configured, then use that
    if [ "${CT_GMP_MPFR_TARGET}" = "y" ]; then
        binutils_opts="--with-gmp=${CT_SYSROOT_DIR}/usr --with-mpfr=${CT_SYSROOT_DIR}/usr"
    fi

    if [ -n "${targets}" ]; then
        CT_DoStep INFO "Installing ${PKG_NAME} for target"
        mkdir -p "${CT_BUILD_DIR}/${PKG_NAME}-for-target"
        CT_Pushd "${CT_BUILD_DIR}/${PKG_NAME}-for-target"

        CT_DoLog EXTRA "Configuring ${PKG_NAME} for target"
        CT_DoExecLog ALL                                            \
        "${CT_SRC_DIR}/${PKG_SRC}/configure"   \
            --build=${CT_BUILD}                                     \
            --host=${CT_TARGET}                                     \
            --target=${CT_TARGET}                                   \
            --prefix=/usr                                           \
            --disable-werror                                        \
            --enable-shared                                         \
            --enable-static                                         \
            --disable-nls                                           \
            --disable-multilib                                      \
            ${binutils_opts}                                        \
            ${CT_ARCH_WITH_FLOAT}                                   \
            ${CT_BINUTILS_EXTRA_CONFIG}

        build_targets=$(echo "${targets}" |sed -r -e 's/(^| +)/\1all-/g;')
        install_targets=$(echo "${targets}" |sed -r -e 's/(^| +)/\1install-/g;')

        CT_DoLog EXTRA "Building ${PKG_NAME}' libraries (${targets}) for target"
        CT_DoExecLog ALL make ${PARALLELMFLAGS} ${build_targets}
        CT_DoLog EXTRA "Installing ${PKG_NAME}' libraries (${targets}) for target"
        CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" ${install_targets}

        CT_Popd
        CT_EndStep
    fi
}
