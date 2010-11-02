help_config::
	@echo  '  toolchain       - Build the toolchain'
help_module::
	@echo  '  list-tlc      - List all toolchain steps'

# ----------------------------------------------------------
# The steps list
CLOOG_PPL=ppl cloog-ppl mpc


CT_TLC_COMPONENTS := \
	kernel		\
	gmp		\
	mpfr		\
	$(CLOOG_PPL)	\
	binutils	\
	compiler	\
	libc		\
	gdb		\
	sstrip


CT_TLC_STEPS := \
	kernel			\
	libc_check_config	\
	gmp			\
	mpfr			\
	$(CLOOG_PPL)		\
	binutils		\
	compiler_step1		\
	libc_headers		\
	libc_start_files	\
	compiler_step2		\
	libc			\
	compiler_step3		\
	libc_finish		\
	sstrip			\
	gdb			\
	gmp_target		\
	mpfr_target		\
	binutils_target		\
	finish

export CT_TLC_STEPS
export CT_TLC_DIR:=$(CT_TOP_DIR)/toolchain

PHONY += list-tlc
list-tlc:
	@echo  'Available build steps, in order:'
	@for step in $(CT_TLC_STEPS); do    \
	     echo "  - tlc-$${step}"; \
	 done
	@echo  'Use "<step>" as action to execute only that step.'
	@echo  'Use "+<step>" as action to execute up to that step.'
	@echo  'Use "<step>+" as action to execute from that step onward.'

last-tlc-step:
	@last_step="" ; for step in $(CT_TLC_STEPS); do \
		if [ -f "$${CT_STATE_DIR}/$${step}" ] ; then \
			last_step=$${step} ;\
		fi \
	done ;	echo $$last_step

# ----------------------------------------------------------
# This part deals with executing steps

$(patsubst %,tlc-%,$(CT_TLC_STEPS)):
	$(MAKE) -r V=$(V) RESTART=$(patsubst tlc-%,%,$@) STOP=$(patsubst tlc-%,%,$@) toolchain

$(patsubst %,+tlc-%,$(CT_TLC_STEPS)):
	$(MAKE) -r V=$(V) STOP=$(patsubst +tlc-%,%,$@) toolchain

$(patsubst %,tlc-%+,$(CT_TLC_STEPS)):
	$(MAKE) -r V=$(V) RESTART=$(patsubst tlc-%+,%,$@) toolchain

# Actual build
PHONY+=toolchain
toolchain: .config $(CT_LOG_DIR)
	$(CT_LIB_DIR)/chainbuilder.sh CT_STEPS=\"$(CT_TLC_STEPS)\" CT_MK_TOOLCHAIN=y CT_COMPONENTS=\"$(CT_TLC_COMPONENTS)\"  CT_COMPONENTS_DIR=\"${CT_TLC_DIR}\" CT_CALL=$(do)

tlc.%:
	$(SILENT)$(MAKE) -rf $(CT_MAKEFILE) $(shell echo "$(@)" |$(sed) -r -e 's|^([^.]+)\.([[:digit:]]+)$$|\1 CT_JOBS=\2|;')

