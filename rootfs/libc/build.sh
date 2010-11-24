# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.



do_libc_get() {
	:
}

do_libc_extract() {
	:
}

do_libc() {
	CT_DoStep ALL "INSTALL libc filesystem"

	mkdir -p "${CT_FS_DIR}/lib"
	CT_Pushd "${CT_FS_DIR}/lib"

	# in case we're overwriting
	chmod u+w ${CT_FS_DIR}/lib/ -R
	SOURCE_DIR="${CT_SYSROOT_DIR}/lib/"

	#this is actually gcc specific
	if [ "${CT_USE_EXTERNAL_TOOLCHAIN}" = "y" ] ; then
		SOURCE_DIR="${CT_EXTERNAL_TOOLCHAIN_DIR}/${CT_TARGET}/sys-root/lib"
	fi

        { cd "${SOURCE_DIR}"; tar cf - .; } | tar xf -

	CT_EndStep
}
