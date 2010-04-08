help_config::
	@echo  '  packages'
help_module::
	@echo  '  list-packages   - List all packages'

CT_PKG_COMPONENTS := kernel
	#strace		\
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
	kernel

#	popt		\
	oprofile
#	php		\

export CT_PKG_STEPS:=$(CT_PKG_COMPONENTS)
export CT_PKG_DIR  :=$(CT_TOP_DIR)/packages

export CT_FS_DIR :=$(CT_TOP_DIR)/_rootfs

PHONY += list-packages
list-packages:
	@echo  'Available packages, in order:'
	@for package in $(CT_PKG_COMPONENTS); do    \
	     echo "  - pkg_$${package}";       \
	 done
	@echo  'Use "<package>" as action to execute only that step.'
	@echo  'Use "+<package>" as action to execute up to that step.'
	@echo  'Use "<package>+" as action to execute from that step onward.'

$(patsubst %,pkg_%,$(CT_PKG_COMPONENTS)):
	$(SILENT)$(MAKE) -r V=$(V) RESTART=$(patsubst pkg_%,%,$@) STOP=$(patsubst pkg_%,%,$@) packages

$(patsubst %,+%,$(CT_PKG_COMPONENTS)):
	$(SILENT)$(MAKE) -r V=$(V) STOP=$(patsubst +%,%,$@) V=$(V) packages

$(patsubst %,%+,$(CT_PKG_COMPONENTS)):
	$(SILENT)$(MAKE) -rf V=$(V) RESTART=$(patsubst %+,%,$@) V=$(V) packages

PHONY += packages
packages: .config $(CT_LOG_DIR) $(CT_FS_DIR)
	$(SILENT)CT_STEPS='$(CT_PKG_STEPS)' CT_COMPONENTS='$(CT_PKG_COMPONENTS)' CT_COMPONENTS_DIR='${CT_PKG_DIR}' $(CT_LIB_DIR)/chainbuilder.sh

packages.%:
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) $(shell echo "$(@)" |$(sed) -r -e 's|^([^.]+)\.([[:digit:]]+)$$|\1 CT_JOBS=\2|;')

bin: .config $(CT_LOG_DIR) $(CT_FS_DIR)
	$(SILENT)CT_STEPS='bin' CT_COMPONENTS='bin' CT_COMPONENTS_DIR='${CT_PKG_DIR}' $(CT_LIB_DIR)/chainbuilder.sh
