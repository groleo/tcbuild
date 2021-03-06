#! /bin/sh -e

KERNELSIZE=C0000
TFTPDIR=mariusn
IMAGE_NAME=img
BOARD_NAME=TestB
CT_FS_DIR=../tmp/_rootfs
OUT=out
NEEDED_FILES="../uzImage"

KERNELSCR='
echo **************************************************************************
echo * [stage1] Configuration
echo Align to block size, the kernel_size and rootfs_size
set kernel_size 0x000<KERNELSIZE>
set kernel_end  0xE00<KERNELSIZE>
set rootfs_size 0x00F20000
set kernel_file <TFTPDIR>/uzImage<FSVERSION>
set rootfs_file <TFTPDIR>/rootfs<FSVERSION>.jffs2
set bootargs pci=nodomains root=/dev/mtdblock1 rw rootfstype=jffs2 mtdparts=physmap-flash.0:${kernel_size}(boot)ro,-(root)
set bootdelay 2
set bootcmd bootm 0xE0000000
save
echo * [stage1] done.
echo **************************************************************************
echo
echo
echo **************************************************************************
echo * [stage2] Loading Kernel [0xE000.0000-0xE000.0000+${kernel_size}]
protect off 0xE0000000 +${kernel_size}
erase 0xE0000000 +${kernel_size}
tftp 0x00020000  ${kernel_file}
cp.b 0x00020000  0xE0000000 ${filesize}
protect on 0xE0000000 +${kernel_size}
echo * [stage2] done. Kernel loaded.
echo **************************************************************************
echo
'

ROOTFSSCR='
echo
echo
echo **************************************************************************
echo * [stage3] Loading rootfs [${kernel_end}..${kernel_end}+${filesize}]
protect off bank 2
protect on 0xE0000000 +${kernel_size}
echo Downloading rootfs
tftp 0x00020000  ${rootfs_file}
erase all
echo cp.b 0x00020000  ${kernel_end} ${filesize}
cp.b 0x00020000  ${kernel_end} ${filesize}
echo * [stage3] done. Rootfs loaded.
echo **************************************************************************
echo
'

BOOT='
echo
echo You successfully installed Linux on your board.
echo
echo Im going to boot now so please dont reset me.
echo
boot
'

#TAKE CARE: The script MUST run from chainbuilder/magic
rm -rf kernel.img kernel.sh
rm -rf autoscr.img autoscr.sh

if [ ! -d ${OUT} ];then
	mkdir ${OUT}
fi

if [ $# -lt 1 ]; then
	echo "Usage: magic.sh <version>"
	exit 0
fi

if [ "${1}" = "" ] ; then
	FSVERSION=
else
	FSVERSION=_${1}
fi

check_files() {
	for file in $*; do
		if [ ! -f ${file} ]; then
			echo "Needed file >> $file << missing"
			exit 0
		fi
	done
}

check_files ${NEEDED_FILES}

echo "**************************************************************************"
echo "* Creating autoscr.sh with <FSVERSION>=${FSVERSION}"
echo "${KERNELSCR}" | sed "s/<FSVERSION>/${FSVERSION}/;s/<KERNELSIZE>/${KERNELSIZE}/;s/<TFTPDIR>/${TFTPDIR}/" > ${OUT}/autoscr.sh
echo "${ROOTFSSCR}" | sed "s/<FSVERSION>/${FSVERSION}/" >> ${OUT}/autoscr.sh
echo "${BOOT}" >> ${OUT}/autoscr.sh

echo "* Creating kernel.sh with <FSVERSION>=${FSVERSION}"
echo "${KERNELSCR}" | sed "s/<FSVERSION>/${FSVERSION}/;s/<KERNELSIZE>/${KERNELSIZE}/;s/<TFTPDIR>/${TFTPDIR}/" > ${OUT}/kernel.sh
echo "${BOOT}" >> ${OUT}/kernel.sh
echo "**************************************************************************"
echo
echo "**************************************************************************"
echo "* Building autoscr.img"
mkimage -A m68k -O linux -T script -C gzip -a 0x00020000 -e 0x00020000 -n 'Linux Kernel Image' -d ${OUT}/autoscr.sh ${OUT}/autoscr.img
echo "**************************************************************************"
echo
echo "**************************************************************************"
echo "* Building kernel.img"
mkimage -A m68k -O linux -T script -C gzip -a 0x00020000 -e 0x00020000 -n 'Linux Kernel Image' -d ${OUT}/kernel.sh  ${OUT}/kernel.img
echo "**************************************************************************"

#cp uboot_M28W160CB70N6E.bin ${OUT}/u-boot${FSVERSION}.bin
#cp ../uzImage ${OUT}/"uzImage${FSVERSION}"

# ok, so rootfs.jffs2 is built twice using mkfs.jffs2 (first by the Makefile). Big deal.
echo
echo "**************************************************************************"
echo "* Building rootfs.jffs2 with <FSVERSION>=${FSVERSION}"

if [ ! -d "${CT_FS_DIR}" ]; then
    echo "Needed directory missing: ${CT_FS_DIR}"
    exit 0
fi

# -v will crash mkfs.jffs2 if owner is not right
#sudo chown root:root -R ${CT_FS_DIR}
#mkfs.jffs2 -v -b -n  -e128KiB -p0xF2D0E7 -r ${CT_FS_DIR} -o ${OUT}/rootfs${FSVERSION}.jffs2 > rootfs.jffs2.log
#sudo chown $USER:$USER -R ${CT_FS_DIR}
echo "**************************************************************************"

#cp uboot_M28W160CB70N6E.srec ${OUT}/uboot${FSVERSION}.srec
echo
echo "**************************************************************************"
echo "* Building ${IMAGE_NAME}${FSVERSION}.tar.gz"
tar czvf ${IMAGE_NAME}${FSVERSION}.tar.gz ${OUT}/autoscr.img ${OUT}/kernel.img "${OUT}/uzImage${FSVERSION}" "${OUT}/rootfs${FSVERSION}.jffs2" "${OUT}/u-boot${FSVERSION}.bin" "${OUT}/uboot${FSVERSION}.srec"
echo "**************************************************************************"

rm -rf ${OUT}
echo ""
echo "* ${BOARD_NAME} image ${IMAGE_NAME}${FSVERSION}.tar.gz created"
echo ""
pwd
echo ""
