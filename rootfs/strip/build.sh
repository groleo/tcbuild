# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


do_strip_get() {
	:
}

do_strip_extract() {
	:
}

do_strip() {
	CT_DoExecLog ALL rm -rf ${CT_FS_DIR}/linuxrc

	CT_DoLog ALL "Removing un-necesary libraries"
	CT_DoExecLog ALL chmod 0777 ${CT_FS_DIR}/lib/ldscripts
	CT_DoExecLog ALL rm -rf ${CT_FS_DIR}/lib/{*.a,*.la,libmenu*,libpanel*,libform*,ldscripts}
	CT_DoExecLog ALL rm -rf ${CT_FS_DIR}/usr/lib/{*.a,*.la,libmenu*,libpanel*,libform*,pkgconfig}

	CT_DoLog ALL "Removing un-necesary binaries"
	CT_DoExecLog ALL rm -rf ${CT_FS_DIR}/usr/bin/{ntp-wait,ntptrace,ntp-keygen,ntpdate,ntpdc,ntptime,xminicom,ncurses5-config,strace-graph}

	CT_DoLog ALL "Removing man and info"
	rm -rf ${CT_FS_DIR}/share/{doc,man,info}
	rm -rf ${CT_FS_DIR}/usr/{doc,man,info}
	rm -rf ${CT_FS_DIR}/usr/share/{doc,man,info}
	rm -rf ${CT_FS_DIR}/usr/include ${CT_FS_DIR}/include
	rm -rf ${CT_FS_DIR}/usr/lib/php
	rm -rf ${CT_FS_DIR}/lib/modules/${CT_KERNEL_VERSION}/{modules.*,source,build}

#mv   ${CT_FS_DIR}/usr/share/terminfo/l .
	rm -rf ${CT_FS_DIR}/usr/share/terminfo/*
#mv   ${CT_FS_DIR}/l ${CT_FS_DIR}/usr/share/terminfo/

	CT_DoLog ALL "Stripping executables"
	SAVED_BYTES=0


	find ${CT_FS_DIR} -type f -a -print  | \
	while IFS= read -r line1; do
		line="`file ${line1}`"
		F=${line%%:*}
		V=${F##*/fake-+([!/])/}
		STRIP="${CT_TARGET}-strip"
		SSTRIP="${CT_TARGET}-sstrip"
		NM="${CT_TARGET}-nm"
		[[ $F = */fwwif/* ]] || STRIP=$STRIP$stripcomm
		case $line in
			*ELF*executable*statically\ linked*)
				echo >&2 "$SELF: *WARNING* '$V' is not dynamically linked!"
				;;
		esac
		case $line in
			*ELF*executable*,\ not\ stripped*)
				S='executable'
				;;
			*/lib/modules/2.*.o:*ELF*relocatable*,\ not\ stripped* | \
			*/lib/modules/2.*.ko:*ELF*relocatable*,\ not\ stripped*)
				# kernel module parametres must not be stripped off
				STRIP="$STRIP --strip-unneeded $(echo $(${NM} $F | \
				sed -n -e '/__param_/s/^.*__param_/-K /p' \
				-e '/__module_parm_/s/^.*__module_parm_/-K /p'))"
				S='kernel module'
				SSTRIP=true
				;;
			*ELF*relocatable*,\ not\ stripped*)
				S='relocatable'
				;;
			*ELF*shared\ object*,\ not\ stripped*)
				S='shared object'
				;;
			*)
				continue
				;;
		esac
		#OLD_SIZE=`ls -l "${F}" | tr -s ' ' | cut -f 5 -d' '`
		CT_DoLog ALL "$SELF: $V:$S"

		CT_DoExecLog DEBUG chmod -R u+rxw "${F}"
		  CT_DoExecLog DEBUG $STRIP $F
		  CT_DoExecLog DEBUG $SSTRIP $F
		CT_DoExecLog DEBUG chmod -R u-wx "${F}"

		#NEW_SIZE=`ls -l "${F}" | tr -s ' ' | cut -f 5 -d' '`
		#DIFF=`expr ${OLD_SIZE} - ${NEW_SIZE}`
		#SAVED_BYTES="`expr ${SAVED_BYTES} + ${DIFF}`"
		#CT_DoLog ALL "OldSize:${OLD_SIZE} NewSize:${NEW_SIZE}  Saved:${DIFF} TotalSaved:${SAVED_BYTES}"
	done
}
