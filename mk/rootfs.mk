help_config::
	@echo  '  fs    - Package the root filesystem'
help_module::
	@echo  '  list-fs   - List rootfs steps'

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

PHONY += list-fs
list-fs:
	@echo  'Available rootfs steps, in order:'
	@for rootfs in $(CT_FS_COMPONENTS); do	\
	     echo "  - fs-$${rootfs}";	\
	 done
	@echo  'Use "<rootfs>" as action to execute only that step.'
	@echo  'Use "+<rootfs>" as action to execute up to that step.'
	@echo  'Use "<rootfs>+" as action to execute from that step onward.'

$(patsubst %,fs-%,$(CT_FS_COMPONENTS)):
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) V=$(V) RESTART=$(patsubst fs-%,%,$@) STOP=$(patsubst fs-%,%,$@) fs

$(patsubst %,+fs-%,$(CT_FS_COMPONENTS)):
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) V=$(V) STOP=$(patsubst +fs-%,%,$@) fs

$(patsubst %,fs-%+,$(CT_FS_COMPONENTS)):
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) V=$(V) RESTART=$(patsubst fs-%+,%,$@) fs

fs: .config $(CT_LOG_DIR) $(CT_FS_DIR)
	$(SILENT)CT_STEPS='$(CT_FS_STEPS)' CT_COMPONENTS='$(CT_FS_COMPONENTS)' CT_COMPONENTS_DIR='${CT_ROOTFS_DIR}' CT_CALL="nosave" $(CT_LIB_DIR)/chainbuilder.sh

fs.%:
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) $(shell echo "$(@)" |$(sed) -r -e 's|^([^.]+)\.([[:digit:]]+)$$|\1 CT_JOBS=\2|;')
