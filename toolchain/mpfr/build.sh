PKG_NAME=mpfr
PKG_SRC="${PKG_NAME}-${CT_MPFR_VERSION}"
PKG_URL="http://www.mpfr.org/mpfr-current/  http://www.mpfr.org/mpfr-${CT_MPFR_VERSION}/"

do_mpfr_get() {
    CT_GetFile "${PKG_SRC}" ${PKG_URL}
}

do_mpfr_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${PKG_SRC}"

    # OK, Gentoo have a sanity check that libtool.m4 and ltmain.sh have the
    # same version number. Unfortunately, some tarballs of MPFR are not
    # built sanely, and thus ./configure fails on Gentoo.
    # See: http://sourceware.org/ml/crossgcc/2008-05/msg00080.html
    # and: http://sourceware.org/ml/crossgcc/2008-06/msg00005.html
    # This hack is not bad per se, but the MPFR guys would be better not to
    # do that in the future...
    # It seems that MPFR >= 2.4.0 do not need this...
    case "${CT_MPFR_VERSION}" in
        1.*|2.0.*|2.1.*|2.2.*|2.3.*)
            CT_Pushd "${CT_SRC_DIR}/${PKG_SRC}"
            if [ ! -f .autotools.ct-ng ]; then
                CT_DoLog DEBUG "Re-building autotools files"
                CT_DoExecLog ALL autoreconf -fi
                # Starting with libtool-1.9f, config.{guess,sub} are no longer
                # installed without -i, but starting with libtool-2.2.6, they
                # are no longer removed without -i. Sight... Just use -i with
                # libtool >=2
                # See: http://sourceware.org/ml/crossgcc/2008-11/msg00046.html
                # and: http://sourceware.org/ml/crossgcc/2008-11/msg00048.html
                libtoolize_opt=
                case "$(libtoolize --version |head -n 1 |gawk '{ print $(NF); }')" in
                    0.*)    ;;
                    1.*)    ;;
                    *)      libtoolize_opt=-i;;
                esac
                CT_DoExecLog ALL libtoolize -f ${libtoolize_opt}
                touch .autotools.ct-ng
            fi
            CT_Popd
            ;;
    esac
}

do_mpfr() {
    CT_DoStep INFO "Installing ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    mpfr_opt=
    # Under Cygwin, we can't build a thread-safe library
    case "${CT_HOST}" in
        *-cygwin|m68k-*)	mpfr_opt="--disable-thread-safe";;
        *)			mpfr_opt="--enable-thread-safe";;
    esac

    CT_DoLog EXTRA "Configuring ${PKG_NAME}"
	${CT_GET_CONFIG_FLAGS} "${CT_SRC_DIR}/${PKG_SRC}/configure" ${CT_TOP_DIR}/_mpfr.in

    rm -rf config.cache
    CC="${CT_HOST}-gcc"			\
    CFLAGS="${CT_CFLAGS_FOR_HOST}"	\
    CT_DoExecLog ALL			\
	"${CT_SRC_DIR}/${PKG_SRC}/configure"	\
	--build=${CT_BUILD}		\
	--host=${CT_HOST}		\
	--prefix="${CT_PREFIX_DIR}"	\
	--disable-shared		\
	--enable-static			\
	--with-gmp="${CT_PREFIX_DIR}"	\
	${mpfr_opt}			\
	--disable-thread-safe

    CT_DoLog EXTRA "Building ${PKG_NAME}"
    CT_DoExecLog ALL make ${PARALLELMFLAGS}

    if [ "${CT_MPFR_CHECK}" = "y" ]; then
        CT_DoLog EXTRA "Checking ${PKG_NAME}"
        CT_DoExecLog ALL make ${PARALLELMFLAGS} -s check
    fi

    CT_DoLog EXTRA "Installing ${PKG_NAME}"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

do_mpfr_target() {
    if [ "${CT_MPFR_TARGET}" != "y" ]; then
	return
    fi

    CT_DoStep INFO "Installing ${PKG_NAME} for the target"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}-target"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}-target"

    mpfr_opt=
    # Under Cygwin, we can't build a thread-safe library
    case "${CT_TARGET}" in
        *-cygwin)   mpfr_opt="--disable-thread-safe";;
        *)          mpfr_opt="--enable-thread-safe";;
    esac

    CT_DoLog EXTRA "Configuring ${PKG_NAME}"
    CC="${CT_TARGET}-gcc"                               \
    CFLAGS="${CT_CFLAGS_FOR_TARGET}"                    \
    CT_DoExecLog ALL                                    \
    "${CT_SRC_DIR}/${PKG_SRC}/configure"		\
        --build=${CT_BUILD}                             \
        --host=${CT_TARGET}                             \
        --prefix=/usr                                   \
        ${mpfr_opt}                                     \
        --disable-shared                                \
        --enable-static                                 \
        --with-gmp="${CT_SYSROOT_DIR}/usr"

    CT_DoLog EXTRA "Building ${PKG_NAME}"
    CT_DoExecLog ALL make ${PARALLELMFLAGS}

    # Not possible to check MPFR while X-compiling

    CT_DoLog EXTRA "Installing ${PKG_NAME}"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}
