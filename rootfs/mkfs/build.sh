# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


do_mkfs_get() {
	:
}

do_mkfs_extract() {
	:
}

do_mkfs() {
	CT_DoLog ALL "Making rootfs.jffs2"
	[ -f "${CT_TOP_DIR}/rootfs.jffs2" ] && rm -rf "${CT_TOP_DIR}/rootfs.jffs2"
	CT_DoExecLog ALL ${mkfs_jffs2} -X lzo -b -n  -e128KiB -p0x00F40000 -r ${CT_FS_DIR} -o ${CT_TOP_DIR}/rootfs.jffs2
}
