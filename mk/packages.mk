help_config::
	@echo  '  packages        - Build the packages'
help_module::
	@echo  '  list-pkg   - List all packages'

CT_PKG_COMPONENTS := kernel \
	bootloader \
	strace		\
	busybox		\
	ncurses		\
	minicom		\
	nano		\
	ppp		\
	ntp		\
	dropbear	\
	axTLS		\
	mini-httpd	\
	ntpclient	\
	lsof		\
	sqlite		\
	popt		\
	oprofile	\
	gdbserver \
	new_package


export CT_PKG_STEPS:=$(CT_PKG_COMPONENTS)
export CT_PKG_DIR  :=$(CT_TOP_DIR)/packages
export CT_FS_DIR   :=$(CT_TMP_DIR)/_rootfs

PHONY += list-pkg
list-pkg:
	@echo  'Available packages, in order:'
	@for package in $(CT_PKG_COMPONENTS); do    \
	     echo "  - pkg-$${package}";       \
	 done
	@echo  'Use "<package>" as action to execute only that step.'
	@echo  'Use "+<package>" as action to execute up to that step.'
	@echo  'Use "<package>+" as action to execute from that step onward.'

$(patsubst %,pkg-%,$(CT_PKG_STEPS)):
	$(MAKE) V=$(V) RESTART=$(patsubst pkg-%,%,$@) STOP=$(patsubst pkg-%,%,$@) packages

$(patsubst %,+pkg-%,$(CT_PKG_STEPS)):
	$(MAKE) V=$(V) STOP=$(patsubst +pkg-%,%,$@) packages

$(patsubst %,pkg-%+,$(CT_PKG_STEPS)):
	$(MAKE) V=$(V) RESTART=$(patsubst pkg-%+,%,$@) packages

PHONY += packages
packages: .config $(CT_LOG_DIR) $(CT_FS_DIR)
	$(CT_LIB_DIR)/chainbuilder.sh CT_STEPS=\"$(CT_PKG_STEPS)\" CT_PKG=\"y\" CT_COMPONENTS=\"$(CT_PKG_COMPONENTS)\" CT_COMPONENTS_DIR=\"${CT_PKG_DIR}\"

pkg.%:
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) $(shell echo "$(@)" |$(sed) -r -e 's|^([^.]+)\.([[:digit:]]+)$$|\1 CT_JOBS=\2|;')

bin: .config $(CT_LOG_DIR) $(CT_FS_DIR)
	$(SILENT)CT_STEPS='bin' CT_COMPONENTS='bin' CT_COMPONENTS_DIR='${CT_PKG_DIR}' $(CT_LIB_DIR)/chainbuilder.sh
