# ===========================================================================
# crosstool-NG genererated config files
# These targets are used from top-level makefile

#-----------------------------------------------------------
# List all config files, wether sourced or generated

# The top-level config file to be used be configurators
KCONFIG_TOP = $(CT_CFG_DIR)/config.in
# Build the list of all source config files
STATIC_CONFIG_FILES := $(patsubst $(CT_TOP_DIR)/%,%,$(shell find '$(CT_TLC_DIR)' -type f -name '*.in' 2>/dev/null))
# ... and how to access them:
$(STATIC_CONFIG_FILES): config

# Build a list of per-component-type source config files
ARCH_CONFIG_FILES   = $(wildcard $(CT_TLC_DIR)/arch/*/config.in)
LIBC_CONFIG_FILES   = $(wildcard $(CT_TLC_DIR)/libc/*/config.in)
KERNEL_CONFIG_FILES = $(wildcard $(CT_TLC_DIR)/kernel/*/config.in)
CC_CONFIG_FILES     = $(wildcard $(CT_TLC_DIR)/compiler/*/config.in)
GMP_CONFIG_FILES    = $(wildcard $(CT_TLC_DIR)/gmp/config.in)
MPFR_CONFIG_FILES   = $(wildcard $(CT_TLC_DIR)/mpfr/config.in)
PPL_CONFIG_FILES    = $(wildcard $(CT_TLC_DIR)/ppl/config.in)
CLOOG_CONFIG_FILES  = $(wildcard $(CT_TLC_DIR)/cloog-ppl/config.in)
BINUTILS_CONFIG_FILES= $(wildcard $(CT_TLC_DIR)/binutils/config.in)
PACKAGES_CONFIG_FILES= $(wildcard $(CT_PKG_DIR)/*/config.in)

#-----------------------------------------------------------
# Build list of per-component-type items to easily build generated files

ARCHS   = $(notdir $(patsubst %/,%,$(dir $(ARCH_CONFIG_FILES))) )
LIBCS   = $(notdir $(patsubst %/,%,$(dir $(LIBC_CONFIG_FILES))) )
KERNELS = $(notdir $(patsubst %/,%,$(dir $(KERNEL_CONFIG_FILES))) )
CCS     = $(notdir $(patsubst %/,%,$(dir $(CC_CONFIG_FILES))) )
GMPS    = $(notdir $(patsubst %/,%,$(dir $(GMP_CONFIG_FILES))) )
MPFRS   = $(notdir $(patsubst %/,%,$(dir $(MPFR_CONFIG_FILES))) )
#
PPL    = $(notdir $(patsubst %/,%,$(dir $(PPL_CONFIG_FILES))) )
CLOOG    = $(notdir $(patsubst %/,%,$(dir $(CLOOG_CONFIG_FILES))) )
#
BINUTILS= $(notdir $(patsubst %/,%,$(dir $(BINUTILS_CONFIG_FILES))) )
PACKAGES= $(notdir $(patsubst %/,%,$(dir $(PACKAGES_CONFIG_FILES))) ) 

# Build the list of generated config files
GEN_CONFIG_FILES = $(CT_CFG_DIR)/_arch.in	   \
			$(CT_CFG_DIR)/_libc.in	   \
			$(CT_CFG_DIR)/_compiler.in \
			$(CT_CFG_DIR)/_cloog-ppl.in     \
			$(CT_CFG_DIR)/_ppl.in     \
			$(CT_CFG_DIR)/_mpfr.in     \
			$(CT_CFG_DIR)/_gmp.in      \
			$(CT_CFG_DIR)/_kernel.in   \
			$(CT_CFG_DIR)/_binutils.in \
			$(CT_CFG_DIR)/_packages.in

# ... and how to access them:
# Generated files depends on config.mk (this file) because it has the
# functions needed to build the genrated files, and thus they might
# need re-generation if config.mk changes
$(GEN_CONFIG_FILES): $(CT_MK_DIR)/config.mk

# Helper entry for the configurators
PHONY += config_files
config_files: $(STATIC_CONFIG_FILES) $(GEN_CONFIG_FILES) $(CT_CFG_DIR)/config.in

# Where to access to the source config files from
config:
	@$(ECHO) "  LN    config"
	$(SILENT)ln -s $(CT_LIB_DIR)/config config

#-----------------------------------------------------------
# Helper functions to ease building generated config files

# The function 'build_gen_choice_in' builds a choice-menu of a list of
# components in the given list, also adding source-ing of associazted
# config files:
# $1 : destination file
# $2 : name for the entries family (eg. Architecture, kernel...)
# $3 : prefix for the choice entries (eg. ARCH, KERNEL...)
# $4 : base directory containing config files
# $5 : list of config entries (eg. for architectures: "alpha arm ia64"...,
#      and for kernels: "bare-metal linux"...)
# Example to build the kernels generated config file:
# $(call build_gen_choice_in,config.gen/kernel.in,Target OS,KERNEL,config/kernel,$(KERNELS))
define build_gen_choice_in
	@$(ECHO) '  IN    $(1)'
	$(SILENT)(echo "# $(2) menu";                                           \
	  echo "# Generated file. Do not edit $(1)!!!";                              \
	  echo "";                                                              \
	  echo "menu \"$(2)\"";                                                        \
	  echo "";                                                              \
	  echo "choice";                                                              \
	  echo "bool \"Flavor\"";                                               \
	  echo "";                                                              \
	  for entry in $(5); do                                                 \
	    file="$(4)/$${entry}/config.in";                                           \
	    _entry=$$(echo "$${entry}" |sed -r -s -e 's/[-.+]/_/g;');           \
	    echo "config $(3)_$${_entry}";                                      \
	    echo "    bool";                                                    \
	    printf "    prompt \"$${entry}";                                    \
	    if $(grep) -E '^# +EXPERIMENTAL$$' $${file} >/dev/null 2>&1; then   \
	      echo " (EXPERIMENTAL)\"";                                         \
	      echo "    depends on EXPERIMENTAL";                               \
	    else                                                                \
	      echo "\"";                                                        \
	    fi;                                                                 \
	  done;                                                                 \
	  echo "";                                                              \
	  echo "endchoice";                                                     \
	  echo "";                                                              \
	 if [ -f "$(CT_CFG_DIR)/common`basename $(1)`" ]; then				\
	    echo "source $(CT_CFG_DIR)/common`basename $(1)`";				\
	 fi ;\
	  for entry in $(5); do                                                 \
	    file="$(4)/$${entry}/config.in";                                           \
	    _entry=$$(echo "$${entry}" |sed -r -s -e 's/[-.+]/_/g;');        \
	    echo "";                                                            \
	    echo "if $(3)_$${_entry}";                                          \
	    echo "config $(3)";                                                 \
	    echo "    default \"$${entry}\" if $(3)_$${_entry}";                \
	    echo "source $${file}";                                             \
	    echo "endif";                                                       \
	  done;                                                                 \
	  echo "endmenu";                                                       \
	  echo "";                                                              \
	  for file in $(wildcard $(4)/*.in-common); do                          \
	    echo "source $${file}";                                             \
	  done;                                                                 \
	 ) >$(1)
endef
# The function 'build_gen_menu_in' builds a menuconfig for each component in
# the given list, source-ing the associated files conditionnaly:
# $1 : destination file
# $2 : name of entries family (eg. Tools, Debug...)
# $3 : prefix for the menu entries (eg. TOOL, DEBUG)
# $4 : base directory containing config files
# $5 : list of config entries (eg. for tools: "libelf sstrip"..., and for
#      debug: "dmalloc duma gdb"...)
#
# Example to build the tools generated config file:
# $(call build_gen_menu_in,config.gen/tools.in,Tools,TOOL,config/tools,$(TOOLS))
define build_gen_menu_in
	@$(ECHO) '  IN    $(1)'
	$(SILENT)(echo "# $(2) facilities menu";                                \
	  echo "# Generated file, do not edit!!!";                              \
	  echo "";                                                              \
	  echo "menu \"$(2)\"";                                                              \
	  for entry in $(5); do                                                 \
	    file="$(4)/$${entry}/config.in"; \
	    _entry=$$(echo "$${entry}" |sed -r -s -e 's/[-.+]/_/g;');        \
	    echo "menuconfig $(3)_$${_entry}";                                  \
	    echo "    bool";                                                    \
	    printf "    prompt \"$${entry}";                                    \
	    if $(grep) -E '^# +EXPERIMENTAL$$' $${file} >/dev/null 2>&1; then   \
	      echo " (EXPERIMENTAL)\"";                                         \
	      echo "    depends on EXPERIMENTAL";                               \
	    else                                                                \
	      echo "\"";                                                        \
	    fi;                                                                 \
	    echo "if $(3)_$${_entry}";                                          \
	    echo "source $${file}";                                             \
	    echo "endif";                                                       \
	    echo "";                                                            \
	  done;                                                                 \
	  echo "endmenu";                                                              \
	 ) >$(1)
endef


#-----------------------------------------------------------
# The rules for the generated config files
$(CT_CFG_DIR)/_arch.in: $(ARCH_CONFIG_FILES)
	$(call build_gen_choice_in,$@,Target Architecture,ARCH,$(CT_TLC_DIR)/arch,$(ARCHS))

$(CT_CFG_DIR)/_libc.in: $(LIBC_CONFIG_FILES)
	$(call build_gen_choice_in,$@,C library,LIBC,$(CT_TLC_DIR)/libc,$(LIBCS))

$(CT_CFG_DIR)/_kernel.in: $(KERNEL_CONFIG_FILES)
	$(call build_gen_choice_in,$@,Target Kernel,KERNEL,$(CT_TLC_DIR)/kernel,$(KERNELS))

$(CT_CFG_DIR)/_compiler.in: $(CC_CONFIG_FILES)
	$(call build_gen_choice_in,$@,C compiler,CC,$(CT_TLC_DIR)/compiler,$(CCS))

$(CT_CFG_DIR)/_binutils.in: $(BINUTILS_CONFIG_FILES)
	$(call build_gen_choice_in,$@,Binutils,CC,$(CT_TLC_DIR),$(BINUTILS))

$(CT_CFG_DIR)/_gmp.in: $(GMP_CONFIG_FILES)
	$(call build_gen_choice_in,$@,GMP library,GMP,$(CT_TLC_DIR),$(GMPS))

$(CT_CFG_DIR)/_mpfr.in: $(MPFR_CONFIG_FILES)
	$(call build_gen_choice_in,$@,MPFR library,MPFR,$(CT_TLC_DIR),$(MPFRS))
#
$(CT_CFG_DIR)/_ppl.in: $(PPL_CONFIG_FILES)
	$(call build_gen_choice_in,$@,PPL library,PPL,$(CT_TLC_DIR),$(PPL))

$(CT_CFG_DIR)/_cloog-ppl.in: $(CLOOG_CONFIG_FILES)
	$(call build_gen_choice_in,$@,CLOOG-PPL library,CLOOG_PPL,$(CT_TLC_DIR),$(CLOOG))
#

$(CT_CFG_DIR)/_packages.in: $(PACKAGES_CONFIG_FILES)
	$(call build_gen_menu_in,$@,Packages,PKG,$(CT_PKG_DIR),$(PACKAGES))

#-----------------------------------------------------------
# include the above generated config files
$(CT_CFG_DIR)/config.in: $(GEN_CONFIG_FILES)
	@$(ECHO) "  IN    $@"
	$(SILENT)echo -e "$(addprefix source config/,$(addsuffix \n,$(notdir $^)))" > $@
	$(SILENT)echo "source config/toolchain.in" >> $@
	$(SILENT)echo "source config/global.in"    >> $@

#-----------------------------------------------------------
# Cleaning up the mess...

help_config::
	@echo "  Available targets: $(ARCHS)"

clean::
	@$(ECHO) "  CLEAN config"
	$(SILENT)rm -f config 2>/dev/null || true
	@$(ECHO) "  CLEAN config.gen"
	$(SILENT)rm -rf config.gen
