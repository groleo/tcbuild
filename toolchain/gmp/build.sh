
PKG_NAME=gmp
PKG_SRC="${PKG_NAME}-${CT_GMP_VERSION}"
PKG_URL="{ftp,http}://{ftp.sunet.se/pub,ftp.gnu.org}/gnu/gmp"

# Download GMP
do_gmp_get() {
    CT_GetFile "${PKG_SRC}" "${PKG_URL}"
}

# Extract GMP
do_gmp_extract() {
    CT_Extract "${PKG_SRC}"
    CT_Patch "${PKG_SRC}"
}

do_gmp() {
    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_SRC}"

    CT_DoStep INFO "Installing ${PKG_SRC}"

    do_gmp_configure
    do_gmp_make
    do_gmp_install
    CT_EndStep
}

do_gmp_target() {
	:
}
do_gmp_configure() {
    CT_DoStep EXTRA "Configuring ${PKG_SRC}"
	rm -rf config.cache
	CFLAGS="${CT_CFLAGS_FOR_HOST}"		\
	CT_DoExecLog ALL			\
	"${CT_SRC_DIR}/${PKG_SRC}/configure"	\
	--build=${CT_BUILD}			\
	--host=${CT_HOST}			\
	--prefix="${CT_PREFIX_DIR}"		\
	--disable-shared			\
	--enable-static				\
	--enable-fft				\
	--enable-mpbsd				\
	--enable-cxx
    CT_EndStep
}
do_gmp_make() {
    CT_DoStep EXTRA "Building ${PKG_SRC}"
	CT_DoExecLog ALL make ${PARALLELMFLAGS}
	if [ "${CT_GMP_CHECK}" = "y" ]; then
		CT_DoLog EXTRA "Checking ${PKG_SRC}"
		CT_DoExecLog ALL make ${PARALLELMFLAGS} -s check
	fi
    CT_EndStep
}
do_gmp_install() {
    CT_DoExecLog ALL make install
}
