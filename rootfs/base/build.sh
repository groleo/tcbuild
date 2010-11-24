# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


do_base_get() {
CT_GetFile _aaa_base http://serghei.net/linux/slackware/slackware-current/source/a/aaa_base
}

do_base_extract() {
:
}

do_base() {
	export CT_DEBUG_CT_SAVE_STEPS=n
	CT_DoStep ALL "INSTALL base filesystem"

	mkdir -p "${CT_FS_DIR}/"
	CT_Pushd "${CT_FS_DIR}/"

	CT_DoExecLog ALL sudo tar xzvf ${CT_TARBALLS_DIR}/_aaa_base.tar.gz
	CT_DoExecLog ALL sudo chown -R ${USER} .

	CT_DoExecLog ALL mkdir -p etc/init.d
	cat > etc/init.d/rcS <<-ENDOFMESSAGE
	#!/bin/sh
	echo "Welcome to Linux"
	/bin/mount -t proc none /proc
	/bin/mount
ENDOFMESSAGE
	CT_DoExecLog ALL chmod +x etc/init.d/rcS

	CT_EndStep
}
