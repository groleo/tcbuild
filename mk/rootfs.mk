help_config::
	@echo  '  rootfs'
help_module::
	@echo  '  rootfs   - TODO'

CT_FS_COMPONENTS := \
	base	\
	libc	\
	strip	\
	devs	\
	mkfs

export CT_FS_STEPS  :=$(CT_FS_COMPONENTS)
export CT_ROOTFS_DIR:=$(CT_TOP_DIR)/rootfs

PHONY +=$(CT_FS_DIR)
$(CT_FS_DIR):
	@$(ECHO) "  MKDIR $(CT_FS_DIR)"
	$(SILENT)mkdir -p $(CT_FS_DIR)

$(CT_FS_COMPONENTS):
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) V=$(V) RESTART=$@ STOP=$@ rootfs

$(patsubst %,+%,$(CT_FS_COMPONENTS)):
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) V=$(V) STOP=$(patsubst +%,%,$@) rootfs

$(patsubst %,%+,$(CT_FS_COMPONENTS)):
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) V=$(V) RESTART=$(patsubst %+,%,$@) rootfs

rootfs: .config $(CT_LOG_DIR) $(CT_FS_DIR)
	$(SILENT)CT_STEPS='$(CT_FS_STEPS)' CT_COMPONENTS='$(CT_FS_COMPONENTS)' CT_COMPONENTS_DIR='${CT_ROOTFS_DIR}' $(CT_LIB_DIR)/chainbuilder.sh

rootfs.%:
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) $(shell echo "$(@)" |$(sed) -r -e 's|^([^.]+)\.([[:digit:]]+)$$|\1 CT_JOBS=\2|;')
