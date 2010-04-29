# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


do_base_get() {
	:
}

do_base_extract() {
	:
}

do_base() {
	CT_DoStep ALL "INSTALL base filesystem"

	mkdir -p "${CT_FS_DIR}/"
	CT_Pushd "${CT_FS_DIR}/"

	CT_DoExecLog ALL tar xzvf ${CT_ROOTFS_DIR}/base/base.tar.gz

	CT_EndStep
}
