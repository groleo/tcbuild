#drop 1 - personal patches
CT_SubGitApply ${pkg_patch_dir}/0001-use-gcc-funit-at-a-time.patch
#CT_SubPatch ${pkg_patch_dir}/204-jffs2_eofdetect.patch
CT_SubPatch ${pkg_patch_dir}/1240846620_linux-2.6.25-pagemap_h.patch
#linux-2.6.25-m547x-8x-pci-reset-usb-fix.patch

#drop 2 - freescale patches
CT_SubGitApply ${pkg_patch_dir}/1193870211_linux-2.6.25-mcfv4e-checkfiles-script.git
CT_SubGitApply ${pkg_patch_dir}/1193870371_linux-2.6.25-mcfv4e-coldfire-headers.git
CT_SubGitApply ${pkg_patch_dir}/1193870501_linux-2.6.25-mcfv4e-coldfire-headers2.git
CT_SubGitApply ${pkg_patch_dir}/1193870581_linux-2.6.25-m5445x-headers.git
CT_SubGitApply ${pkg_patch_dir}/1193871369_linux-2.6.25-mcfv4e-kernel-mods.git
CT_SubGitApply ${pkg_patch_dir}/1193871425_linux-2.6.25-mcfv4e-arch-lib-mods.git
CT_SubGitApply ${pkg_patch_dir}/1193871507_linux-2.6.25-mcfv4e-arch-mm-mods-1.git
CT_SubGitApply ${pkg_patch_dir}/1193871618_linux-2.6.25-mcfv4e-coldfire-code.git
CT_SubGitApply ${pkg_patch_dir}/1193871701_linux-2.6.25-m5445x-serial.git
CT_SubGitApply ${pkg_patch_dir}/1193872045_linux-2.6.25-m5445x-fec.git
CT_SubGitApply ${pkg_patch_dir}/1193872139_linux-2.6.25-mcfv4e-namespace-align.git
CT_SubGitApply ${pkg_patch_dir}/1193872323_linux-2.6.25-m5445x-defconfig-base.git
CT_SubGitApply ${pkg_patch_dir}/1195498894_linux-2.6.25-m5445x-ata.git
CT_SubGitApply ${pkg_patch_dir}/1195511070_linux-2.6.25-m5445x-ioremap-xf0000000.git
CT_SubGitApply ${pkg_patch_dir}/1195578136_linux-2.6.25-m5445x-cau-crypto.git
CT_SubGitApply ${pkg_patch_dir}/1195581974_linux-2.6.25-m5445x-usb-initial-port.git
CT_SubGitApply ${pkg_patch_dir}/1195682179_linux-2.6.25-mcfv4e-elf-entry-stext.git
CT_SubGitApply ${pkg_patch_dir}/1196145683_linux-2.6.25-mcfv4e-linker-script-update.git
CT_SubGitApply ${pkg_patch_dir}/1196199577_linux-2.6.25-m5445x-spi.git
CT_SubGitApply ${pkg_patch_dir}/1196230673_linux-2.6.25-mcfv4e-inline-memory-params.git
CT_SubGitApply ${pkg_patch_dir}/1196379047_linux-2.6.25-m5445x-usb-premerge.git
CT_SubGitApply ${pkg_patch_dir}/1196452512_linux-2.6.25-m5445x-ccm-bitdefs.git
CT_SubGitApply ${pkg_patch_dir}/1196748187_linux-2.6.25-mcfv4e-cache-base-update.git
CT_SubGitApply ${pkg_patch_dir}/1196751861_linux-2.6.25-m5445x-enable-cache-store.git
CT_SubGitApply ${pkg_patch_dir}/1196793014_linux-2.6.25-m5445x-usb-autosuspend-delay.git
CT_SubGitApply ${pkg_patch_dir}/1196809397_linux-2.6.25-m5445x-usb-cleanup-2.git
CT_SubGitApply ${pkg_patch_dir}/1196890999_linux-2.6.25-m5445x-usb-add-dualspeed.git
CT_SubGitApply ${pkg_patch_dir}/1196975866_linux-2.6.25-m5445x-usb-sdram-priority.git
CT_SubGitApply ${pkg_patch_dir}/1196984439_linux-2.6.25-mcfv4e-cache-ck-0-len.git
CT_SubGitApply ${pkg_patch_dir}/1196986943_linux-2.6.25-m5445x-usb-disable-debug.git
CT_SubGitApply ${pkg_patch_dir}/1197048646_linux-2.6.25-m5445x-usb-defconfig.git
CT_SubGitApply ${pkg_patch_dir}/1197192079_linux-2.6.25-m5445x-edma-update.git
CT_SubGitApply ${pkg_patch_dir}/1197192253_linux-2.6.25-m5445x-ssi-cleanup.git
CT_SubGitApply ${pkg_patch_dir}/1197192297_linux-2.6.25-m5445x-spi-deprecated-api.git
CT_SubGitApply ${pkg_patch_dir}/1197192349_linux-2.6.25-mcfv4e-bitops-cleanup.git
CT_SubGitApply ${pkg_patch_dir}/1197282965_linux-2.6.25-m5445x-pci.git
CT_SubGitApply ${pkg_patch_dir}/1197283039_linux-2.6.25-m5445x-edma-callback.git
CT_SubGitApply ${pkg_patch_dir}/1197317733_linux-2.6.25-m5445x-audio-rates.git
CT_SubGitApply ${pkg_patch_dir}/1203114755_linux-2.6.25-mcfv4e-kbuild-flags-update.git
CT_SubGitApply ${pkg_patch_dir}/1203114803_linux-2.6.25-m5445x-usb-header-move.git
CT_SubGitApply ${pkg_patch_dir}/1203114846_linux-2.6.25-mcfv4e-bitops-lock-hdr.git
CT_SubGitApply ${pkg_patch_dir}/1203114898_linux-2.6.25-m5445x-pata-24-cleanup.git
CT_SubGitApply ${pkg_patch_dir}/1203114964_linux-2.6.25-m5445x-spi-cdev-remove.git
CT_SubGitApply ${pkg_patch_dir}/1204221377_linux-2.6.25-m547x-8x-initial.git
CT_SubGitApply ${pkg_patch_dir}/1205122445_linux-2.6.25-m547x-8x-fec-dma.git
CT_SubGitApply ${pkg_patch_dir}/1205357943_linux-2.6.25-mcfv4e-kern-to-phys.git
CT_SubGitApply ${pkg_patch_dir}/1205363609_linux-2.6.25-m547x-8x-fec-cleanup.git
CT_SubGitApply ${pkg_patch_dir}/1205467595_linux-2.6.25-m547x-8x-internal-rename.git
CT_SubGitApply ${pkg_patch_dir}/1205969864_linux-2.6.25-mcfv4e-linker-bss-cleanup.git
CT_SubGitApply ${pkg_patch_dir}/1208301295_linux-2.6.25-mcfv4e-irq-magic-bit.git
CT_SubGitApply ${pkg_patch_dir}/1209579723_linux-2.6.25-m547x-8x-mcdma-1.0.git
CT_SubGitApply ${pkg_patch_dir}/1209586848_linux-2.6.25-m547x-8x-dspi.git
CT_SubGitApply ${pkg_patch_dir}/1210789392_linux-2.6.25-mcfv4e-brcache-inval.git
CT_SubGitApply ${pkg_patch_dir}/1210873860_linux-2.6.25-mcfv4e-defconfig-upd.git
CT_SubGitApply ${pkg_patch_dir}/1210879407_linux-2.6.25-m547x-8x-i2c.git
CT_SubGitApply ${pkg_patch_dir}/1210879498_linux-2.6.25-m547x-8x-rtc-rv5c387a.git
CT_SubGitApply ${pkg_patch_dir}/1210879786_linux-2.6.25-m547x-8x-sec11-1.git
CT_SubGitApply ${pkg_patch_dir}/1210888139_linux-2.6.25-mcfv4e-add-mm-args.git
CT_SubGitApply ${pkg_patch_dir}/1211471431_linux-2.6.25-mcfv4e-tlsnptl-elf-reloc.git
CT_SubGitApply ${pkg_patch_dir}/1211476853_linux-2.6.25-mcfv4e-vdso-headers.git
CT_SubGitApply ${pkg_patch_dir}/1211924807_linux-2.6.25-m547x-8x-sec-crypto-hooks.git
CT_SubGitApply ${pkg_patch_dir}/1212120188_linux-2.6.25-m547x-8x-move-memmap.git
CT_SubGitApply ${pkg_patch_dir}/1213823851_linux-2.6.25-m5445x-rename-config.git
CT_SubGitApply ${pkg_patch_dir}/1213824021_linux-2.6.25-mcfv4e-cache-split.git
CT_SubGitApply ${pkg_patch_dir}/1214364238_linux-2.6.25-m5445x-rambar-config.git
CT_SubGitApply ${pkg_patch_dir}/1214366974_linux-2.6.25-mcfv4e-update-cmdlines.git
CT_SubGitApply ${pkg_patch_dir}/1214367137_linux-2.6.25-mcfv4e-bss-clear-move.git
CT_SubGitApply ${pkg_patch_dir}/1214367631_linux-2.6.25-mcfv4e-endmem-fix.git
CT_SubGitApply ${pkg_patch_dir}/1214371267_linux-2.6.25-mcfv4e-acr-cleanup.git
CT_SubGitApply ${pkg_patch_dir}/1214371470_linux-2.6.25-m547x-8x-NOR-FLASH-baseaddr.git
CT_SubGitApply ${pkg_patch_dir}/1214371614_linux-2.6.25-m5445x-fecint-nest-1.git
CT_SubGitApply ${pkg_patch_dir}/1214379270_linux-2.6.25-m5445x-rambar-init-1.git
CT_SubGitApply ${pkg_patch_dir}/1214519396_linux-2.6.25-m5445x-i2c.git
CT_SubGitApply ${pkg_patch_dir}/1215036236_linux-2.6.25-mcfv4e-disable-irq-nosync.git
CT_SubGitApply ${pkg_patch_dir}/1215495450_linux-2.6.25-mcfv4e-uboot-bootargs.git
CT_SubGitApply ${pkg_patch_dir}/1215500378_linux-2.6.25-mcfv4e-except-vector-fix.git
CT_SubGitApply ${pkg_patch_dir}/1215739031_linux-2.6.25-m547x-8x-pci-initial.git
CT_SubGitApply ${pkg_patch_dir}/1219428664_linux-2.6.25-m5445x-head-build-fix.git
CT_SubGitApply ${pkg_patch_dir}/1215547846_linux-2.6.25-mcfv4e-watchdog.git
CT_SubGitApply ${pkg_patch_dir}/1215554267_linux-2.6.25-mcfv4e-irda.git
CT_SubGitApply ${pkg_patch_dir}/1215558693_linux-2.6.25-mcfv4e-flexcan.git
CT_SubGitApply ${pkg_patch_dir}/1215719534_linux-2.6.25-m5445x-usb-infrastructure.git
CT_SubGitApply ${pkg_patch_dir}/1215719675_linux-2.6.25-m5445x-usb-host.git
CT_SubGitApply ${pkg_patch_dir}/1215739169_linux-2.6.25-m547x-8x-pci-video-sm712.git
CT_SubGitApply ${pkg_patch_dir}/1216143848_linux-2.6.25-mcfv4e-dspi-update.git
CT_SubGitApply ${pkg_patch_dir}/1216165691_linux-2.6.25-mcfv4e-vmalloc-fix.git
CT_SubGitApply ${pkg_patch_dir}/1216185036_linux-2.6.25-m547x-8x-ocf-openswan-ipsec.git
CT_SubGitApply ${pkg_patch_dir}/1216185442_linux-2.6.25-m547x-8x-ipsec-kernel.git
#CT_SubGitApply ${pkg_patch_dir}/1216185700_linux-2.6.25-m547x-8x-ocf-talitos.git
#CT_SubGitApply ${pkg_patch_dir}/1216185856_linux-2.6.25-m547x-8x-ocf-talitos-kernel.git
CT_SubGitApply ${pkg_patch_dir}/1216328543_linux-2.6.25-m547x-8x-dma-dipr.git
CT_SubGitApply ${pkg_patch_dir}/1216335749_linux-2.6.25-m547x-8x-reboot-wd.git
CT_SubGitApply ${pkg_patch_dir}/1216406404_linux-2.6.25-m547x-8x-i2c-timeout-fix.git
CT_SubGitApply ${pkg_patch_dir}/1218211438_linux-2.6.25-m5445x-usb-gadget.git
CT_SubGitApply ${pkg_patch_dir}/1218572942_linux-2.6.25-m5445x-usb-otg.git
CT_SubGitApply ${pkg_patch_dir}/1218582555_linux-2.6.25-m5445x-new-edma.git
CT_SubGitApply ${pkg_patch_dir}/1218646526_linux-2.6.25-m5445x-usb-host-ehci.git
CT_SubGitApply ${pkg_patch_dir}/1218811054_linux-2.6.25-m5445x-usb-gadget-usb2.git
CT_SubGitApply ${pkg_patch_dir}/1218811203_linux-2.6.25-m5445x-usb-infrastructure-usb_dr.git
CT_SubGitApply ${pkg_patch_dir}/1219184669_linux-2.6.25-m5445x-usb-serial-gadget-acm.git
CT_SubGitApply ${pkg_patch_dir}/1219521864_linux-2.6.25-m5445x-usb-config-54451.git
CT_SubGitApply ${pkg_patch_dir}/1220903970_linux-2.6.25-m5445x-usb-device_test.git
CT_SubGitApply ${pkg_patch_dir}/1221548094_linux-2.6.25-mcfv4e-vdso.git
CT_SubGitApply ${pkg_patch_dir}/1221629466_linux-2.6.25-m547x-8x-dma-exports.git
#CT_SubGitApply ${pkg_patch_dir}/1222891344_linux-2.6.25-m5445x-usb-defconfig-1.git
CT_SubGitApply ${pkg_patch_dir}/1225755028_linux-2.6.25-mcfv4e-makefile-uimage.git
CT_SubGitApply ${pkg_patch_dir}/1226361425_linux-2.6.25-m5445x-usb-update-copyright.git
CT_SubGitApply ${pkg_patch_dir}/1228325478_linux-2.6.25-mcfv4e-align-nfsdata.git
CT_SubGitApply ${pkg_patch_dir}/1228327331_linux-2.6.25-mcfv4e-mmap-writable.git
CT_SubGitApply ${pkg_patch_dir}/1231286804_linux-2.6.25-mcfv4e-fix-inline-warning.git
CT_SubGitApply ${pkg_patch_dir}/1231453236_linux-2.6.25-mcfv4e-fix-usbcv-halt-endpoint.git
CT_SubGitApply ${pkg_patch_dir}/1231453308_linux-2.6.25-mcfv4e-fix-usbcv-remote-wakeup.git
#CT_SubGitApply ${pkg_patch_dir}/1232060114_linux-2.6.25-mcfv4e-ata-pci-mapping.git
#CT_SubGitApply ${pkg_patch_dir}/1222880029_linux-2.6.25-m5445x-cf-header-split-1.git
CT_SubGitApply ${pkg_patch_dir}/1232062147_linux-2.6.25-mcfv4e-pci-update.git
CT_SubGitApply ${pkg_patch_dir}/1218184948_linux-2.6.25-m5445x-spi-fixes.git
#
CT_SubGitApply ${pkg_patch_dir}/1218185021_linux-2.6.25-m5445x-initial-sound.git
CT_SubGitApply ${pkg_patch_dir}/1218694398_linux-2.6.25-m5445x-edma-spi-ssi.git
CT_SubGitApply ${pkg_patch_dir}/1222375039_linux-2.6.25-m5445x-edma-cleanup.git
CT_SubGitApply ${pkg_patch_dir}/1227302381_linux-2.6.25-m5445x-edma-halfirq.git
CT_SubGitApply ${pkg_patch_dir}/1232409627_linux-2.6.25-mcfv4e-fsl-pata-dma-support.git
CT_SubGitApply ${pkg_patch_dir}/1217035826_linux-2.6.25-m547x-8x-pci-reset-usb-fix.git
CT_SubGitApply ${pkg_patch_dir}/1218231944_linux-2.6.25-m547x-8x-fec-rxfifo-check.git
CT_SubGitApply ${pkg_patch_dir}/1256826990_getline.git

CT_SubPatch ${pkg_patch_dir}/kernel-2.6.25-block2mtd_init.patch

#drop 3 - mariusn patches1
CT_SubPatch ${pkg_patch_dir}/1240900315_linux-2.6.25-m547x-8x-remove-i2c-debug-msgs.patch
CT_SubPatch ${pkg_patch_dir}/1243502723_linux-2.6.25-mcfv4e-optimize_string_memset.patch
CT_SubPatch ${pkg_patch_dir}/1243502723_linux-2.6.25-mcfv4e-optimize_uaccess_moveml.patch
CT_SubGitApply ${pkg_patch_dir}/1259154699_jffs2_read_inode_range.git


#drop 4 - mariusn patches2
CT_SubGitApply ${pkg_patch_dir}/0003-activate-instruction-and-data-cache.patch
CT_SubPatch ${pkg_patch_dir}/1257329293_0002-cfV4e-enable-memory-cache.patch
CT_SubPatch ${pkg_patch_dir}/add_cf_dcache_flush.patch
CT_SubGitApply ${pkg_patch_dir}/0007-flush-data-cache-in-FEC-driver.patch
#CT_SubPatch ${pkg_patch_dir}/1257329293_0001-cfV4e-add-dma-zone.patch

#drop 5 - freescale speed improvements and (failed)attempts at fixing the hang
#Patches below were added after the PCI hang
#CT_SubPatch ${pkg_patch_dir}/1257852157_make_it_work.patch
#CT_SubPatch ${pkg_patch_dir}/1257945567_kk.patch
#CT_SubPatch ${pkg_patch_dir}/1258614578_yuppy.patch

#drop 6 - mariusn patches2 - extra functionality
#CT_SubPatch ${pkg_patch_dir}/1275565383_fallback_killing_more_tasks_if_tif-memdie_doesn_go.patch
#CT_SubGitApply ${pkg_patch_dir}/1271755619_memory-usage-limit-notification-addition-to-memcg.git
#CT_SubGitApply ${pkg_patch_dir}/jffs2_retval.git
