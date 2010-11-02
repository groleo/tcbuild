PKG_NAME=linux
PKG_SRC="${PKG_NAME}-${CT_KERNEL_VERSION}"
PKG_URL={ftp,http}://ftp.{de.,eu.,}kernel.org/pub/linux/kernel/v2.{6{,/testing},4,2}

CT_DoKernelTupleValues() {
    # Nothing to do, keep the default value
    :
}

# Download the kernel
do_kernel_get() {
    if [ "${CT_KERNEL_LINUX_USE_CUSTOM_HEADERS}" != "y" ]; then
        CT_GetFile "${PKG_SRC}" "${PKG_URL}"
    fi
    return 0
}

# Extract kernel
do_kernel_extract() {
    if [ "${CT_KERNEL_LINUX_USE_CUSTOM_HEADERS}" = "y" ]; then
	return 0
    fi
    CT_Extract "${PKG_SRC}"
    CT_Patch   "${CT_TLC_DIR}/kernel/${PKG_NAME}/${PKG_SRC}"
}

# Wrapper to the actual headers install method
do_kernel() {
    CT_DoStep INFO "Installing kernel headers"

    if [ "${CT_KERNEL_LINUX_USE_CUSTOM_HEADERS}" = "y" ]; then
        do_kernel_custom
    else
        do_kernel_install
    fi

    CT_EndStep
}

# Install kernel headers using headers_install from kernel sources.
do_kernel_install() {
    CT_DoStep INFO "Using kernel's headers_install"

    mkdir -p "${CT_BUILD_DIR}/${PKG_NAME}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_NAME}"

    # Only starting with 2.6.18 does headers_install is usable. We only
    # have 2.6 version available, so only test for sublevel.
    k_sublevel=$(${awk} '/^SUBLEVEL =/ { print $3 }' "${CT_SRC_DIR}/linux-${CT_KERNEL_VERSION}/Makefile")
    [ ${k_sublevel} -ge 18 ] || CT_Abort "Kernel version >= 2.6.18 is needed to install kernel headers."

    V_OPT="V=${CT_KERNEL_LINUX_VERBOSE_LEVEL}"

    CT_DoStep EXTRA "Installing kernel headers"
    CT_DoExecLog ALL                                    \
    ${make} -C "${CT_SRC_DIR}/${PKG_SRC}"		\
         O=$(pwd)                                       \
         ARCH=${CT_KERNEL_ARCH}                         \
         INSTALL_HDR_PATH="${CT_SYSROOT_DIR}/usr"       \
         ${V_OPT}                                       \
         headers_install
    CT_EndStep

    #If you are in doubt that installed headers are buggy
    if [ "${CT_KERNEL_LINUX_INSTALL_CHECK}" = "y" ]; then
        CT_DoStep EXTRA "Checking installed headers"
        CT_DoExecLog ALL                                    \
        ${make} -C "${CT_SRC_DIR}/${PKG_SRC}"  \
             O=$(pwd)                                       \
             ARCH=${CT_KERNEL_ARCH}                         \
             INSTALL_HDR_PATH="${CT_SYSROOT_DIR}/usr"       \
             ${V_OPT}                                       \
             headers_check
        find "${CT_SYSROOT_DIR}" -type f -name '.check*' -exec rm {} \;
        CT_EndStep
    fi

    CT_Popd
    CT_EndStep
}

# Use custom headers (most probably by using make headers_install in a
# modified (read: customised) kernel tree, or using pre-2.6.18 headers, such
# as 2.4). In this case, simply copy the headers in place
do_kernel_custom() {
    local tar_opt

    CT_DoLog EXTRA "Installing custom kernel headers"

    mkdir -p "${CT_SYSROOT_DIR}/usr"
    cd "${CT_SYSROOT_DIR}/usr"
    if [ "${CT_KERNEL_LINUX_CUSTOM_IS_TARBALL}" = "y" ]; then
        case "${CT_KERNEL_LINUX_CUSTOM_PATH}" in
            *.tar)      ;;
            *.tgz)      tar_opt=--gzip;;
            *.tar.gz)   tar_opt=--gzip;;
            *.tar.bz2)  tar_opt=--bzip2;;
            *.tar.lzma) tar_opt=--lzma;;
        esac
        CT_DoExecLog ALL tar x ${tar_opt} -vf ${CT_KERNEL_LINUX_CUSTOM_PATH}
    else
        CT_DoExecLog ALL cp -rv "${CT_KERNEL_LINUX_CUSTOM_PATH}/include" .
    fi
}
