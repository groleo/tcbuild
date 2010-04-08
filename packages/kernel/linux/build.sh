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

do_kernel_configure() {
    CT_DoStep INFO "CHECK ${PKG_NAME}:${CT_KERNEL_CONFIG_FILE}:configuration"

    if [ "${CT_KERNEL_RUN_CONFIG}" = "y" ]; then
	if [ -f "${CT_KERNEL_CONFIG_FILE}" ]; then
		CT_Pushd "${CT_SRC_DIR}/${PKG_SRC}"
			CT_DoExecLog INFO cp "${CT_KERNEL_CONFIG_FILE}" .config
			${make} -C "${CT_SRC_DIR}/${PKG_SRC}"		\
				O=$(pwd)					\
				ARCH=${CT_KERNEL_ARCH}				\
				INSTALL_HDR_PATH="${CT_SYSROOT_DIR}/usr"	\
				INSTALL_MOD_PATH=${CT_FS_DIR}			\
				CROSS_COMPILE=${CT_TARGET}-			\
				HOSTCC=${CT_BUILD}-gcc				\
				${V_OPT}					\
				menuconfig 1>&6
			cp .config "${CT_KERNEL_CONFIG_FILE}"
			${make} mrproper
		CT_Popd
	fi
    fi

    if [ ! -f "${CT_KERNEL_CONFIG_FILE}" ] ; then
	CT_DoLog WARN "No ${PKG_NAME} config file(${CT_KERNEL_CONFIG_FILE})"
	( cd "${CT_SRC_DIR}/${PKG_SRC}" ; ${make} ARCH=${CT_KERNEL_ARCH} CROSS_COMPILE=${CT_TARGET}- HOSTCC=${CT_BUILD}-gcc ${V_OPT} menuconfig ; cp .config "${CT_KERNEL_CONFIG_FILE}" ) 1>&6
    fi

    CT_EndStep
}

# Wrapper to the actual headers install method
do_kernel() {

    CT_DoStep INFO "INSTALL ${PKG_NAME}"
    mkdir -p "${CT_BUILD_DIR}/${PKG_NAME}"
    CT_Pushd "${CT_BUILD_DIR}/${PKG_NAME}"

    # Only starting with 2.6.18 does headers_install is usable. We only
    # have 2.6 version available, so only test for sublevel.
    k_sublevel=$(${awk} '/^SUBLEVEL =/ { print $3 }' "${CT_SRC_DIR}/linux-${CT_KERNEL_VERSION}/Makefile")
    [ ${k_sublevel} -ge 18 ] || CT_Abort "Kernel version >= 2.6.18 is needed to install kernel headers."

    V_OPT="V=${CT_KERNEL_LINUX_VERBOSE_LEVEL}"

    do_kernel_configure

    # Retrieve the config file
    CT_DoExecLog ALL cp "${CT_KERNEL_CONFIG_FILE}" .config

    CT_DoExecLog ALL					\
    ${make} -C "${CT_SRC_DIR}/${PKG_SRC}"		\
	O=$(pwd)					\
	ARCH=${CT_KERNEL_ARCH}				\
	INSTALL_HDR_PATH="${CT_SYSROOT_DIR}/usr"	\
	INSTALL_MOD_PATH=${CT_FS_DIR}			\
	CROSS_COMPILE=${CT_TARGET}-			\
	HOSTCC=${CT_BUILD}-gcc				\
	${V_OPT}					\
	oldconfig vmlinux zImage modules

    chmod u+w "${CT_FS_DIR}" -R
    CT_DoExecLog ALL					\
    ${make} -C "${CT_SRC_DIR}/${PKG_SRC}"		\
	O=$(pwd)					\
	ARCH=${CT_KERNEL_ARCH}				\
	INSTALL_HDR_PATH="${CT_SYSROOT_DIR}/usr"	\
	INSTALL_MOD_PATH=${CT_FS_DIR}			\
	CROSS_COMPILE=${CT_TARGET}-			\
	HOSTCC=${CT_BUILD}-gcc				\
	${V_OPT}					\
	modules_install

    ${CT_TARGET}-objcopy -O binary ./vmlinux ./vmlinux.bin

    CT_DoExecLog ALL rm -rf "${CT_TOP_DIR}/vmlinux"
    CT_DoExecLog ALL cp vmlinux ${CT_TOP_DIR}/

    CT_DoExecLog ALL rm -rf "${CT_TOP_DIR}/System.map"
    CT_DoExecLog ALL cp System.map ${CT_TOP_DIR}/

    CT_DoExecLog ALL rm -rf "${CT_TOP_DIR}/uzImage"
    CT_DoExecLog ALL ${mkimage} -A m68k -O linux -T kernel -C gzip -a 0x00020000 -e 0x00020000 -n 'Linux Kernel Image' -d arch/${CT_KERNEL_ARCH}/boot/zImage ${CT_TOP_DIR}/uzImage

    CT_Popd
    CT_EndStep
}
