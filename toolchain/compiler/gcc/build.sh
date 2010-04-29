# This file adds the function to build the gcc C compiler
# Copyright 2007 Yann E. MORIN
# Licensed under the GPL v2. See COPYING in the root of this package

PKG_NAME=gcc
PKG_SRC="${PKG_NAME}-${CT_CC_VERSION}"
PKG_URL="ftp://ftp.irisa.fr/pub/mirrors/gcc.gnu.org/gcc/releases/${PKG_SRC}
	ftp://ftp.irisa.fr/pub/mirrors/gcc.gnu.org/gcc/snapshots/${PKG_SRC}"
# Download gcc
do_compiler_get() {
    # Ah! gcc folks are kind of 'different': they store the tarballs in
    # subdirectories of the same name! That's because gcc is such /crap/ that
    # it is such /big/ that it needs being splitted for distribution! Sad. :-(
    # Arrgghh! Some of those versions does not follow this convention:
    # gcc-3.3.3 lives in releases/gcc-3.3.3, while gcc-2.95.* isn't in a
    # subdirectory! You bastard!
    CT_GetFile "${PKG_SRC}"  `echo ${PKG_URL}`

    # Starting with GCC 4.3, ecj is used for Java, and will only be
    # built if the configure script finds ecj.jar at the top of the
    # GCC source tree, which will not be there unless we get it and
    # put it there ourselves
    if [ "${CT_CC_LANG_JAVA_USE_ECJ}" = "y" ]; then
        CT_GetFile ecj-latest .jar ftp://gcc.gnu.org/pub/java   \
                                   ftp://sourceware.org/pub/java
    fi
}

# Extract gcc
do_compiler_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${PKG_SRC}"
    # Copy ecj-latest.jar to ecj.jar at the top of the GCC source tree
    if [ "${CT_CC_LANG_JAVA_USE_ECJ}" = "y" ]; then
        CT_DoExecLog ALL cp -v "${CT_TARBALLS_DIR}/ecj-latest.jar" "${CT_SRC_DIR}/gcc-${CT_CC_VERSION}/ecj.jar"
    fi
}

#------------------------------------------------------------------------------
# Build core gcc
# This function is used to build both the static and the shared core C conpiler,
# with or without the target libgcc. We need to know wether:
#  - we're building static, shared or bare metal: mode=[static|shared|baremetal]
#  - we need to build libgcc or not             : build_libgcc=[yes|no]
# Usage: do_compiler_core_static mode=[static|shared|baremetal] build_libgcc=[yes|no]
do_compiler_core() {
    local mode
    local build_libgcc
    local core_prefix_dir
    local extra_config
    local lang_opt

    eval $1
    eval $2
    CT_TestOrAbort "Internal Error: 'mode' must either 'static', 'shared' or 'baremetal', not '${mode:-(empty)}'" "${mode}" = "static" -o "${mode}" = "shared" -o "${mode}" = "baremetal"
    CT_TestOrAbort "Internal Error: 'build_libgcc' must be either 'yes' or 'no', not '${build_libgcc:-(empty)}'" "${build_libgcc}" = "yes" -o "${build_libgcc}" = "no"
    # In normal conditions, ( "${mode}" = "shared" ) implies
    # ( "${build_libgcc}" = "yes" ), but I won't check for that

    CT_DoStep INFO "INSTALL ${mode} core C compiler"
    mkdir -p "${CT_BUILD_DIR}/compiler-core-${mode}"
    CT_Pushd "${CT_BUILD_DIR}/compiler-core-${mode}"

    lang_opt=c
    case "${mode}" in
        static)
            core_prefix_dir="${CT_CC_CORE_STATIC_PREFIX_DIR}"
            extra_config="${extra_config} --with-newlib --enable-threads=no --disable-shared"
            copy_headers=y
            ;;
        shared)
            core_prefix_dir="${CT_CC_CORE_SHARED_PREFIX_DIR}"
            extra_config="${extra_config} --with-newlib --enable-shared"
            copy_headers=y
            ;;
        baremetal)
            core_prefix_dir="${CT_PREFIX_DIR}"
            extra_config="${extra_config} --with-newlib --enable-threads=no --disable-shared"
            [ "${CT_CC_LANG_CXX}" = "y" ] && lang_opt="${lang_opt},c++"
            copy_headers=n
            ;;
    esac

    if [ "${copy_headers}" = "y" ]; then
        CT_DoLog DEBUG "COPY headers to install area of bootstrap gcc, so it can build libgcc2"
        CT_DoExecLog ALL mkdir -p "${core_prefix_dir}/${CT_TARGET}/include"
        CT_DoExecLog ALL cp -r "${CT_HEADERS_DIR}"/* "${core_prefix_dir}/${CT_TARGET}/include"
    fi

    CT_DoLog EXTRA "CONFIGURE ${mode} core C compiler"

    extra_config="${extra_config} ${CT_ARCH_WITH_ARCH}"
    extra_config="${extra_config} ${CT_ARCH_WITH_ABI}"
    extra_config="${extra_config} ${CT_ARCH_WITH_CPU}"
    extra_config="${extra_config} ${CT_ARCH_WITH_TUNE}"
    extra_config="${extra_config} ${CT_ARCH_WITH_FPU}"
    extra_config="${extra_config} ${CT_ARCH_WITH_FLOAT}"

    if [ "${CT_GMP}" = "gmp" -a "${CT_MPFR}"="mpfr" ]; then
        extra_config="${extra_config} --with-gmp=${CT_PREFIX_DIR}"
    fi

    if [ "${CT_MPFR}" = "mpfr" ]; then
        extra_config="${extra_config} --with-mpfr=${CT_PREFIX_DIR}"
    fi

    if [ "${CT_CLOOG_PPL}" = "cloog-ppl" ]; then
        extra_config="${extra_config} --with-ppl=${CT_PREFIX_DIR}"
        extra_config="${extra_config} --with-cloog=${CT_PREFIX_DIR}"
    fi

    if [ "${CT_CC_CXA_ATEXIT}" = "y" ]; then
        extra_config="${extra_config} --enable-__cxa_atexit"
    else
        extra_config="${extra_config} --disable-__cxa_atexit"
    fi

    CT_DoLog DEBUG "Extra config passed: '${extra_config}'"


    CT_DoLog DEBUG CC_FOR_BUILD="${CT_BUILD}-gcc"
    CT_DoLog DEBUG CFLAGS_FOR_TARGET="${CT_TARGET_CFLAGS}"
    CT_DoLog DEBUG CXXFLAGS_FOR_TARGET="${CT_TARGET_CFLAGS}"
    CT_DoLog DEBUG LDFLAGS_FOR_TARGET="${CT_TARGET_LDFLAGS}"
    #CT_DoExecLog DEBUG export
    # Use --with-local-prefix so older gccs don't look in /usr/local (http://gcc.gnu.org/PR10532)
    find . -iname 'config.cache' -exec rm {} \;
    CC_FOR_BUILD="${CT_BUILD}-gcc"                  \
    CFLAGS="${CT_CFLAGS_FOR_HOST}"                  \
    CT_DoExecLog ALL                                \
    "${CT_SRC_DIR}/gcc-${CT_CC_VERSION}/configure"  \
        --build=${CT_BUILD}                         \
        --host=${CT_HOST}                           \
        --target=${CT_TARGET}                       \
        --prefix="${core_prefix_dir}"               \
        --with-local-prefix="${CT_SYSROOT_DIR}"     \
        --disable-multilib                          \
        ${CC_CORE_SYSROOT_ARG}                      \
        ${extra_config}                             \
        --disable-nls                               \
        --enable-symvers=gnu                        \
        --enable-languages="${lang_opt}"            \
        --enable-target-optspace                    \
        --disable-clocale                           \
        ${CT_CC_CORE_EXTRA_CONFIG}

        #--enable-bootstrap                          \
        #--disable-libunwind-exceptions              \
        #--disable-decimal-float                     \
        #--with-headers=${CT_HEADERS_DIR}            \

    if [ "${build_libgcc}" = "yes" ]; then
        # HACK: we need to override SHLIB_LC from gcc/config/t-slibgcc-elf-ver or
        # gcc/config/t-libunwind so -lc is removed from the link for
        # libgcc_s.so, as we do not have a target -lc yet.
        # This is not as ugly as it appears to be ;-) All symbols get resolved
        # during the glibc build, and we provide a proper libgcc_s.so for the
        # cross toolchain during the final gcc build.
        #
        # As we cannot modify the source tree, nor override SHLIB_LC itself
        # during configure or make, we have to edit the resultant
        # gcc/libgcc.mk itself to remove -lc from the link.
        # This causes us to have to jump through some hoops...
        #
        # To produce libgcc.mk to edit we firstly require libiberty.a,
        # so we configure then build it.
        # Next we have to configure gcc, create libgcc.mk then edit it...
        # So much easier if we just edit the source tree, but hey...
        if [ ! -f "${CT_SRC_DIR}/gcc-${CT_CC_VERSION}/gcc/BASE-VER" ]; then
            CT_DoExecLog ALL make configure-libiberty
            CT_DoExecLog ALL make ${PARALLELMFLAGS} -C libiberty libiberty.a
            CT_DoExecLog ALL make configure-gcc configure-libcpp
            CT_DoExecLog ALL make ${PARALLELMFLAGS} all-libcpp
        else
            CT_DoExecLog ALL make configure-gcc configure-libcpp configure-build-libiberty
            CT_DoExecLog ALL make ${PARALLELMFLAGS} all-libcpp all-build-libiberty
        fi
        # HACK: gcc-4.2 uses libdecnumber to build libgcc.mk, so build it here.
        if [ -d "${CT_SRC_DIR}/gcc-${CT_CC_VERSION}/libdecnumber" ]; then
            CT_DoExecLog ALL make configure-libdecnumber
            CT_DoExecLog ALL make ${PARALLELMFLAGS} -C libdecnumber libdecnumber.a
        fi

        # Starting with GCC 4.3, libgcc.mk is no longer built,
        # and libgcc.mvars is used instead.

        if [ "${CT_CC_GCC_4_3_or_later}" = "y" ]; then
            libgcc_rule="libgcc.mvars"
            build_rules="all-gcc all-target-libgcc"
            install_rules="install-gcc install-target-libgcc"
        else
            libgcc_rule="libgcc.mk"
            build_rules="all-gcc"
            install_rules="install-gcc"
        fi

        CT_DoExecLog ALL make ${PARALLELMFLAGS} -C gcc ${libgcc_rule}
        sed -r -i -e 's@-lc@@g' gcc/${libgcc_rule}
    else # build_libgcc
            build_rules="all-gcc"
            install_rules="install-gcc"
    fi   # ! build libgcc

    if [ "${CT_CANADIAN}" = "y" ]; then
        CT_DoLog EXTRA "BUILD libiberty"
        CT_DoExecLog ALL make ${PARALLELMFLAGS} all-build-libiberty
    fi

    CT_DoLog EXTRA "BUILD ${mode} core C compiler"
    CT_DoExecLog ALL make ${PARALLELMFLAGS} ${build_rules}

    CT_DoLog EXTRA "INSTALL ${mode} core C compiler"
    CT_DoExecLog ALL make ${install_rules}

    CT_Popd
    CT_EndStep
}


#------------------------------------------------------------------------------
# Core gcc pass 1
do_compiler_step1() {
    # If we're building for bare metal, build the static core gcc,
    # with libgcc.
    # In case we're not bare metal, and we're NPTL, build the static core gcc.
    # In any other case, do nothing.
    case "${CT_BARE_METAL},${CT_THREADS}" in
        y,*)    do_compiler_core mode=baremetal build_libgcc=yes;;
        ,nptl)  do_compiler_core mode=static build_libgcc=no;;
        *)      ;;
    esac
}

# Core gcc pass 2
do_compiler_step2() {
    # In case we're building for bare metal, do nothing, we already have
    # our compiler.
    # In case we're NPTL, build the shared core gcc and the target libgcc.
    # In any other case, build the static core gcc and, if using gcc-4.3+,
    # also build the target libgcc.
    #rm -rf ${CT_BIN_OVERIDE_DIR}/{as,ar,gcc,g++}
    case "${CT_BARE_METAL},${CT_THREADS}" in
        y,*)    ;;
        ,nptl)
            do_compiler_core mode=shared build_libgcc=yes
            ;;
        *)  if [ "${CT_CC_GCC_4_3_or_later}" = "y" ]; then
                do_compiler_core mode=static build_libgcc=yes
            else
                do_compiler_core mode=static build_libgcc=no
            fi
            ;;
    esac
}
#------------------------------------------------------------------------------
# Build final gcc
do_compiler_step3() {
    # If building for bare metal, nothing to be done here, the static core conpiler is enough!
    [ "${CT_BARE_METAL}" = "y" ] && return 0

    CT_DoStep INFO "INSTALL final compiler"

    mkdir -p "${CT_BUILD_DIR}/compiler_step3"
    CT_Pushd "${CT_BUILD_DIR}/compiler_step3"

    CT_DoLog EXTRA "CONFIGURE final compiler"

    # Enable selected languages
    lang_opt="c"
    [ "${CT_CC_LANG_CXX}" = "y"      ] && lang_opt="${lang_opt},c++"
    [ "${CT_CC_LANG_FORTRAN}" = "y"  ] && lang_opt="${lang_opt},fortran"
    [ "${CT_CC_LANG_ADA}" = "y"      ] && lang_opt="${lang_opt},ada"
    [ "${CT_CC_LANG_JAVA}" = "y"     ] && lang_opt="${lang_opt},java"
    [ "${CT_CC_LANG_OBJC}" = "y"     ] && lang_opt="${lang_opt},objc"
    [ "${CT_CC_LANG_OBJCXX}" = "y"   ] && lang_opt="${lang_opt},obj-c++"
    CT_Test "Building ADA language is not yet supported. Will try..." "${CT_CC_LANG_ADA}" = "y"
    CT_Test "Building Objective-C language is not yet supported. Will try..." "${CT_CC_LANG_OBJC}" = "y"
    CT_Test "Building Objective-C++ language is not yet supported. Will try..." "${CT_CC_LANG_OBJCXX}" = "y"
    CT_Test "Building ${CT_CC_LANG_OTHERS//,/ } language(s) is not yet supported. Will try..." -n "${CT_CC_LANG_OTHERS}"
    lang_opt=$(echo "${lang_opt},${CT_CC_LANG_OTHERS}" |sed -r -e 's/,+/,/g; s/,*$//;')

    extra_config="--enable-languages=${lang_opt}"
    extra_config="${extra_config} --disable-multilib"
    extra_config="${extra_config} ${CT_ARCH_WITH_ARCH}"
    extra_config="${extra_config} ${CT_ARCH_WITH_ABI}"
    extra_config="${extra_config} ${CT_ARCH_WITH_CPU}"
    extra_config="${extra_config} ${CT_ARCH_WITH_TUNE}"
    extra_config="${extra_config} ${CT_ARCH_WITH_FPU}"
    extra_config="${extra_config} ${CT_ARCH_WITH_FLOAT}"
    [ "${CT_SHARED_LIBS}" = "y" ]                   || extra_config="${extra_config} --disable-shared"
    if [ "${CT_GMP}" = "gmp" -a "${CT_MPFR}"="mpfr" ]; then
        extra_config="${extra_config} --with-gmp=${CT_PREFIX_DIR}"
    fi
    if [ "${CT_MPFR}" = "mpfr" ]; then
        extra_config="${extra_config} --with-mpfr=${CT_PREFIX_DIR}"
    fi
    if [ "${CT_CLOOG_PPL}" = "cloog-ppl" ]; then
        extra_config="${extra_config} --with-ppl=${CT_PREFIX_DIR}"
        extra_config="${extra_config} --with-cloog=${CT_PREFIX_DIR}"
    fi
    [ -n "${CT_CC_PKGVERSION}" ]                    && extra_config="${extra_config} --with-pkgversion=${CT_CC_PKGVERSION}"
    [ -n "${CT_CC_BUGURL}" ]                        && extra_config="${extra_config} --with-bugurl=${CT_CC_BUGURL}"
    [ "${CT_CC_SJLJ_EXCEPTIONS_USE}" = "y" ]        && extra_config="${extra_config} --enable-sjlj-exceptions"
    [ "${CT_CC_SJLJ_EXCEPTIONS_DONT_USE}" = "y" ]   && extra_config="${extra_config} --disable-sjlj-exceptions"
    if [ "${CT_CC_CXA_ATEXIT}" = "y" ]; then
        extra_config="${extra_config} --enable-__cxa_atexit"
    else
        extra_config="${extra_config} --disable-__cxa_atexit"
    fi

    CT_DoLog DEBUG "Extra config passed: '${extra_config}'"

    # --enable-symvers=gnu really only needed for sh4 to work around a
    # detection problem only matters for gcc-3.2.x and later, I think.
    # --disable-nls to work around crash bug on ppc405, but also because
    # embedded systems don't really need message catalogs...

    #CFLAGS="${CT_CFLAGS_FOR_HOST}"                  \
    CT_TARGET_LDFLAGS="-L${CT_PREFIX_DIR}/lib -L${CT_PREFIX_DIR}/${CT_TARGET}/lib -R${CT_PREFIX_DIR}/lib -R${CT_PREFIX_DIR}/${CT_TARGET}/lib"

    CT_DoLog DEBUG CC_FOR_BUILD="${CT_BUILD}-gcc"
    CT_DoLog DEBUG CFLAGS_FOR_TARGET="${CT_TARGET_CFLAGS}"
    CT_DoLog DEBUG CXXFLAGS_FOR_TARGET="${CT_TARGET_CFLAGS}"
    CT_DoLog DEBUG LDFLAGS_FOR_TARGET="${CT_TARGET_LDFLAGS}"
    #CT_DoExecLog DEBUG export

    find . -iname 'config.cache' -exec rm {} \;
    CC_FOR_BUILD="${CT_BUILD}-gcc"                  \
    CFLAGS="${CT_CFLAGS_FOR_HOST}"                  \
    CFLAGS_FOR_TARGET="${CT_TARGET_CFLAGS}"         \
    CXXFLAGS_FOR_TARGET="${CT_TARGET_CFLAGS}"       \
    LDFLAGS_FOR_TARGET="${CT_TARGET_LDFLAGS}"       \
    CT_DoExecLog ALL                                \
    "${CT_SRC_DIR}/gcc-${CT_CC_VERSION}/configure"  \
        --build=${CT_BUILD}                         \
        --host=${CT_HOST}                           \
        --target=${CT_TARGET}                       \
        --prefix="${CT_PREFIX_DIR}"                 \
        ${CC_SYSROOT_ARG}                           \
        ${extra_config}                             \
        --with-local-prefix="${CT_SYSROOT_DIR}"     \
        --disable-nls                               \
        --enable-threads=posix                      \
        --enable-symvers=gnu                        \
        --enable-c99                                \
        --enable-long-long                          \
        --enable-target-optspace                    \
        --disable-clocale                           \
        ${CT_CC_EXTRA_CONFIG}

        #--enable-bootstrap                          \
        #--disable-multilib                          \
        #--disable-decimal-float                     \
        #--with-headers=${CT_HEADERS_DIR}

    if [ "${CT_CANADIAN}" = "y" ]; then
        CT_DoLog EXTRA "BUILD libiberty"
        CT_DoExecLog ALL make ${PARALLELMFLAGS} all-build-libiberty
    fi

    CT_DoLog EXTRA "BUILD final compiler"
    CT_DoExecLog ALL make ${PARALLELMFLAGS} all

    CT_DoLog EXTRA "INSTALL final compiler"
    CT_DoExecLog ALL make install

    # Create a symlink ${CT_TARGET}-cc to ${CT_TARGET}-gcc to always be able
    # to call the C compiler with the same, somewhat canonical name.
    CT_DoExecLog ALL rm -rf "${CT_PREFIX_DIR}/bin/${CT_TARGET}"-cc
    CT_DoExecLog ALL ln -sv "${CT_TARGET}"-gcc "${CT_PREFIX_DIR}/bin/${CT_TARGET}"-cc

    CT_Popd
    CT_EndStep
}
