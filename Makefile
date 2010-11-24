# Don't use built-in rules, we know what we're doing
MAKEFLAGS += --no-builtin-rules

# Don't go parallel
.NOTPARALLEL:

# This is where ct-ng is:
export CT_NG:=$(lastword $(MAKEFILE_LIST))
# and this is where we're working in:
export CT_TOP_DIR:=$(CURDIR)
export CT_TMP_DIR:=$(CT_TOP_DIR)/tmp

# Paths and values set by ./configure
# Don't bother to change it other than with a new ./configure!
export CT_LIB_DIR:=$(CT_TOP_DIR)/helpers
export CT_DOC_DIR:=$(CT_TOP_DIR)/doc
export CT_LOG_DIR:=$(CT_TMP_DIR)/_log
export CT_CFG_DIR:=$(CT_TOP_DIR)/config
export CT_MK_DIR:=$(CT_TOP_DIR)/mk
export CT_GET_CONFIG_FLAGS:=$(CT_LIB_DIR)/getConfigure

# This is the version string
export CT_VERSION:=1.0

# Paths found by ./configure
include $(CT_MK_DIR)/_paths.mk

# Some distributions (eg. Ubuntu) thought it wise to point /bin/sh to
# a truly POSIX-conforming shell, ash in this case. This is not so good
# as we, smart (haha!) developers (as smart we ourselves think we are),
# got used to bashisms, and are enclined to easiness... So force use of
# bash.
export SHELL=$(bash)

# Make the restart/stop steps availabe to scripts/crostool-NG.sh
export CT_STOP:=$(STOP)
export CT_RESTART:=$(RESTART)
export do

SILENT=@
ECHO=echo
ifeq ($(strip $(origin V)),command line)
  ifeq ($(strip $(V)),0)
    SILENT=@
    ECHO=:
  else
    ifeq ($(strip $(V)),1)
      SILENT=
      ECHO=:
    else
      ifeq ($(strip $(V)),2)
        SILENT=
        ECHO=echo
      endif # V == 2
    endif # V== 1
  endif # V == 0
endif # origin V
export V SILENT ECHO

.FORCE: $(FORCE)
PHONY += all

all: help $(CT_PATHS_MK)

$(CT_LOG_DIR):
	@$(ECHO) "  MKDIR $(CT_LOG_DIR)"
	$(SILENT)mkdir -p $(CT_LOG_DIR)

# Help system
help:: help_head help_config help_samples help_module help_clean help_distrib help_env help_tail

help_head:: version
	@echo  'help_head:    See below for a list of available targets, listed by category:'

help_config::
	@echo
	@echo  'help_config:  Configuration targets:'

help_samples::
	@echo
	@echo  'help_samples: Preconfigured toolchains (#: force number of // jobs):'

help_module::
	@echo
	@echo  'help_module:  Build targets (#: force number of // jobs):'

help_clean::
	@echo
	@echo  'Cleaning targets:'

help_distrib::
	@echo
	@echo  'Distribution targets:'

help_env::
	@echo


help_tail::
	@echo
	@echo '  make V=0|1|2 [targets] 0=quiet, 1=??, 2=??'
	@echo
	@echo 'Use action "menuconfig" to configure chainbuilder'
	@echo 'Use action "toolchain" to build your toolchain'
	@echo 'Use action "version" to see the version'
	@echo 
	@echo 'Incremental build howto:'
	@echo 'a) Use `make list-tlc` to list toolchain steps'
	@echo 'b) Use `make tlc-libc do=list-functions` to list the steps of the `libc` build.'
	@echo 'a) Use `make tlc-libc do=do_libc` to compile and install the libc.'
	@echo
	@echo 'To build only the packages (this will not build the toolchain) run `make packages`'
	@echo 'To build the root file system run `make fs`'
	@echo
	@echo 'To build the VR900 IMAGE run `make image ver=<version>` (will create rootfs first)'
	@echo '  (VR900 image needs packages to be already built - THERE IS NO CHECK)'
	@echo
	@echo 'You can combine the above commands in a single run `make packages rootfs`'
	@echo
	@echo " 1) build"
	@echo " this is *always* the platform on which you are running the build"
	@echo " process; since we are building on Linux, this is unequivocally going to"
	@echo " specify 'linux', with the canonical form being 'i686-pc-linux-gnu'."
	@echo
	@echo " 2) host"
	@echo " this is a tricky one: it specifies the platform on which whatever we"
	@echo " are building is going to be run; for the cross-compiler itself, that's"
	@echo " also 'i686-pc-linux-gnu', but when we get to the stage of building the"
	@echo " runtime support libraries to go with that cross-compiler, they must"
	@echo " contain code which will run on the 'i686-pc-mingw32' host, so the 'host'"
	@echo " specification should change to this, for the 'runtime' and 'w32api'"
	@echo " stages of the build."
	@echo
	@echo " 3) target"
	@echo " this is probably the one which causes the most confusion; it is only"
	@echo " relevant when building a cross-compiler, and it specifies where the code"
	@echo " which is built by that cross-compiler itself will ultimately run; it"
	@echo " should not need to be specified at all, for the 'runtime' or 'w32api',"
	@echo " since these are already targetted to 'i686-pc-mingw32' by a correct"
	@echo " 'host' specification."

help_build::
	@echo  '  build[.#]       - Build the currently configured toolchain'

help_clean::
	@echo  '  clean           - Remove generated files'
	@echo  '  distclean       - Remove generated files, configuration and build directories'

help_distrib::
	@echo  '  tarball         - Build a tarball of the configured toolchain'

help_env::
	@echo  '  STOP            - Stop the build just after this step'
	@echo  '  RESTART         - Restart the build just before this step'

include $(CT_MK_DIR)/config.mk
include $(CT_MK_DIR)/toolchain.mk
include $(CT_MK_DIR)/packages.mk
include $(CT_MK_DIR)/rootfs.mk
include $(CT_MK_DIR)/scripts.mk
include $(CT_CFG_DIR)/kconfig/kconfig.mk

.PHONY: $(PHONY)

# End help system


.config:
	@echo ' There is no existing .config file!'
	@false

image: fs
	cd magic && ./magic.sh $(ver) && cp vr900img_$(ver).tar.gz ..
	@pwd
	@echo

PHONY += tarball
#tarball:
#	@$(CT_LIB_DIR)/scripts/tarball.sh
tarball:
	@echo 'Tarball creation disabled for now... Sorry.'
	@true

PHONY += version
version:
	@echo 'This is chainbuilder version $(CT_VERSION)'
	@echo

PHONY += clean
clean::
	@$(ECHO) "  CLEAN log/"
	$(SILENT)rm -rf log/* $(CT_CFG_DIR)/_* _*.in

PHONY += distclean
distclean:: clean
	@$(ECHO) "  CLEAN .config"
	$(SILENT)rm -f .config .config.* ..config*
	@$(ECHO) "  CLEAN targets"
	$(SILENT)chmod -R u+w targets >/dev/null 2>&1 || true
	$(SILENT)rm -rf targets
