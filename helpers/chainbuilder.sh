#!/bin/bash
# Copyright 2007 Yann E. MORIN
# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.



###################################################################################
# Create the bin-overide early
# Contains symlinks to the tools found by ./configure
# Note: CT_DoLog and CT_DoExecLog do not use any of those tool, so
# they can be safely used
createBinOveride()
{
	CT_BIN_OVERIDE_DIR="${CT_WORK_DIR}/bin"
	CT_DoStep INFO "Creating bin-overide for tools in '${CT_BIN_OVERIDE_DIR}'"
	CT_DoExecLog DEBUG mkdir -p "${CT_BIN_OVERIDE_DIR}"
	cat "${CT_MK_DIR}/_paths.mk" |while read trash line; do
		tool="${line%%=*}"
		path="${line#*=}"
		if [ ! -f "${CT_BIN_OVERIDE_DIR}/${tool}" ]; then
			CT_DoLog DEBUG "  '${tool}' -> '${path}'"
			printf "#${BANG}/bin/sh\nexec '${path}' \"\${@}\"\n" >"${CT_BIN_OVERIDE_DIR}/${tool}"
			CT_DoExecLog ALL chmod 700 "${CT_BIN_OVERIDE_DIR}/${tool}"
		fi
	done
	CT_DoLog ALL ${CT_BIN_OVERIDE_DIR}
	CT_EndStep
}
buildEnv()
{
	CT_DoStep INFO "Building environment variables"

	# renice oursleves
	CT_DoExecLog DEBUG ${renice} ${CT_NICE} $$


	# Some sanity checks in the environment and needed tools
	CT_DoLog INFO "Checking environment sanity"

	CT_DoLog DEBUG "Unsetting and unexporting MAKEFLAGS"
	export MAKEFLAGS=

	# Other environment sanity checks
	CT_TestAndAbort "Don't set LD_LIBRARY_PATH. It screws up the build." -n "${LD_LIBRARY_PATH}"
	CT_TestAndAbort "Don't set CFLAGS. It screws up the build." -n "${CFLAGS}"
	CT_TestAndAbort "Don't set CXXFLAGS. It screws up the build." -n "${CXXFLAGS}"
	CT_Test "GREP_OPTIONS='${GREP_OPTIONS}' screws up the build. Resetting." -n "${GREP_OPTIONS}"
	export GREP_OPTIONS=


	# Include sub-scripts instead of calling them: that way, we do not have to
	# export any variable, nor re-parse the configuration and functions files.
	. "${CT_TLC_DIR}/arch/${CT_ARCH}/build.sh"
	. "${CT_TLC_DIR}/kernel/linux/build.sh"


	# Target tuple: CT_TARGET needs a little love:
	CT_DoBuildTargetTuple

	# Kludge: If any of the configured options needs CT_TARGET,
	# then rescan the options file now:
	source .config

	# When building a toolchain use that to compile the rest of the targets
	if [ "${CT_MK_TOOLCHAIN}" = "y" ] ; then
		CT_USE_EXTERNAL_TOOLCHAIN=n
	fi


	# Second kludge: merge user-supplied target CFLAGS with architecture-provided
	# target CFLAGS. Do the same for LDFLAGS in case it happens in the future.
	# Put user-supplied flags at the end, so that they take precedence.
	CT_TARGET_CFLAGS="${CT_ARCH_TARGET_CFLAGS} ${CT_TARGET_CFLAGS}"
	CT_TARGET_LDFLAGS="${CT_ARCH_TARGET_LDFLAGS} ${CT_TARGET_LDFLAGS}"
	CT_CC_CORE_EXTRA_CONFIG="${CT_ARCH_CC_CORE_EXTRA_CONFIG} ${CT_CC_CORE_EXTRA_CONFIG}"
	CT_CC_EXTRA_CONFIG="${CT_ARCH_CC_EXTRA_CONFIG} ${CT_CC_EXTRA_CONFIG}"

	# Note: we'll always install the core compiler in its own directory, so as to
	# not mix the two builds: core and final.
	CT_BUILD_DIR="${CT_WORK_DIR}/${CT_TARGET}/build"
	CT_STATE_DIR="${CT_WORK_DIR}/${CT_TARGET}/state"
	CT_CC_CORE_STATIC_PREFIX_DIR="${CT_BUILD_DIR}/${CT_CC}-core-static"
	CT_CC_CORE_SHARED_PREFIX_DIR="${CT_BUILD_DIR}/${CT_CC}-core-shared"

	#CT_SetLibPath "${CT_PREFIX_DIR}/lib:${CT_PREFIX_DIR}/${CT_TARGET}/lib" first

	# We must ensure that we can restart if asked for!
	if [ -n "${CT_RESTART}" -a ! -d "${CT_STATE_DIR}"  ]; then
		CT_DoLog ERROR "You asked to restart a non-restartable build"
		CT_DoLog ERROR "This happened because you didn't set CT_DEBUG_CT_SAVE_STEPS"
		CT_DoLog ERROR "in the config options for the previous build, or the state"
		CT_DoLog ERROR "directory for the previous build was deleted."
		CT_Abort "I will stop here to avoid any carnage"
	fi

	# If the local tarball directory does not exist, say so, and don't try to save there!
	if [ ! -d "${CT_LOCAL_TARBALLS_DIR}" ]; then
		CT_DoLog WARN "Directory CT_LOCAL_TARBALLS_DIR='${CT_LOCAL_TARBALLS_DIR}' does not exist. Will not download tarballs to local storage."
		CT_SAVE_TARBALLS=
	fi

	# Some more sanity checks now that we have all paths set up
	case "${CT_LOCAL_TARBALLS_DIR},${CT_TARBALLS_DIR},${CT_SRC_DIR},${CT_BUILD_DIR},${CT_PREFIX_DIR},${CT_INSTALL_DIR}" in
		*" "*) CT_Abort "Don't use spaces in paths, it breaks things.";;
	esac

	# Good, now grab a bit of informations on the system we're being run on,
	# just in case something goes awok, and it's not our fault:
	CT_SYS_USER=$(${id} -un)
	CT_SYS_HOSTNAME=$(hostname -f 2>/dev/null || true)
	# Hmmm. Some non-DHCP-enabled machines do not have an FQDN... Fall back to node name.
	CT_SYS_HOSTNAME="${CT_SYS_HOSTNAME:-$(${uname} -n)}"
	CT_SYS_KERNEL=$(${uname} -s)
	CT_SYS_REVISION=$(${uname} -r)
	# MacOS X lacks '-o' :
	CT_SYS_OS=$(${uname} -o || echo "Unknown (maybe MacOS-X)")
	CT_SYS_MACHINE=$(${uname} -m)
	CT_SYS_PROCESSOR=$(${uname} -p)
	CT_SYS_GCC=$(gcc -dumpversion)
	CT_SYS_TARGET=$(CT_DoConfigGuess)
	CT_TOOLCHAIN_ID="chainbuilder-${CT_VERSION} build ${CT_STAR_DATE_HUMAN} by ${CT_SYS_USER}@${CT_SYS_HOSTNAME}"
	CT_EndStep
}
prepareWorkingDirs()
{
	CT_DoStep INFO "Preparing working directories"

	# Ah! The build directory shall be eradicated, even if we restart!
	if [ -d "${CT_BUILD_DIR}" ]; then
		CT_DoForceRmdir "${CT_BUILD_DIR}"
	fi

	# Don't eradicate directories if we need to restart
	if [ -z "${CT_RESTART}" ]; then
		# Get rid of pre-existing installed toolchain and previous build directories.
		# We need to do that _before_ we can safely log, because the log file will
		# most probably be in the toolchain directory.
		if [ "${CT_FORCE_DOWNLOAD}" = "y" -a -d "${CT_TARBALLS_DIR}" ]; then
			CT_DoForceRmdir "${CT_TARBALLS_DIR}"
		fi
		if [ "${CT_FORCE_EXTRACT}" = "y" -a -d "${CT_SRC_DIR}" ]; then
			CT_DoForceRmdir "${CT_SRC_DIR}"
		fi
		if [ "${CT_USE_EXTERNAL_TOOLCHAIN}" = "n" ] ; then
			# Check now if we can write to the destination directory:
			# this should actually be tested at install time
			if [ -d "${CT_INSTALL_DIR}" ]; then
				CT_TestAndAbort "Destination directory '${CT_INSTALL_DIR}' is not removable" ! -w $(dirname "${CT_INSTALL_DIR}")
			fi
			if [ -d "${CT_INSTALL_DIR}" ]; then
				echo "Removing CT_INSTALL_DIR=${CT_INSTALL_DIR}"
				#CT_DoForceRmdir "${CT_INSTALL_DIR}"
			fi
		fi
		if [ -d "${CT_STATE_DIR}" ]; then
			CT_DoLog DEBUG "we start anew, get rid of the previously saved state directory" 
			CT_DoForceRmdir "${CT_STATE_DIR}"
		fi
	fi

	# Create the directories we'll use, even if restarting: it does no harm to
	# create already existent directories, and CT_BUILD_DIR needs to be created
	# anyway
	CT_DoExecLog ALL mkdir -p   "${CT_TARBALLS_DIR}"
	CT_DoExecLog ALL mkdir -p   "${CT_SRC_DIR}"
	CT_DoExecLog ALL mkdir -p   "${CT_BUILD_DIR}"

	CT_DoExecLog ALL mkdir -p   "${CT_CC_CORE_STATIC_PREFIX_DIR}"
	CT_DoExecLog ALL mkdir -p   "${CT_CC_CORE_SHARED_PREFIX_DIR}"

	if [ -n "{CT_DEBUG_CT_SAVE_STEPS}" ] ; then
		CT_DoExecLog ALL mkdir -p   "${CT_STATE_DIR}"
	fi

	# Create install directory only when building a toolchain too
	if [ "${CT_USE_EXTERNAL_TOOLCHAIN}" = "n" ] ; then
		CT_DoExecLog ALL mkdir -p "${CT_INSTALL_DIR}"
		CT_DoExecLog ALL mkdir -p "${CT_PREFIX_DIR}"
		# Kludge: CT_INSTALL_DIR and CT_PREFIX_DIR might have grown read-only if
		# the previous build was successful. To be able to move the logfile there,
		# switch them back to read/write
		CT_DoExecLog ALL chmod -R u+w "${CT_INSTALL_DIR}" "${CT_PREFIX_DIR}"
	fi
	CT_EndStep
}

redirectLog()
{
	# Redirect log to the actual log file now we can
	# It's quite understandable that the log file will be installed in the
	# install directory, so we must first ensure it exists and is writeable
	# (above) before we can log there
	exec >/dev/null
	case "${CT_LOG_TO_FILE}" in
		y)  CT_LOG_FILE="${CT_BUILD_DIR}/build.log"
			cat "${tmp_log_file}" >>"${CT_LOG_FILE}"
			rm -f "${tmp_log_file}"
			exec >>"${CT_LOG_FILE}"
			CT_DoLog INFO "Log file: ${CT_LOG_FILE}"
		;;
		*)  rm -f "${tmp_log_file}"
		;;
	esac
}
setup_environment()
{
	CT_DoStep INFO "Setup Environment"
	# What's our shell?
	# Will be plain /bin/sh on most systems, except if we have /bin/ash and we
	# _explictly_ required using it
	export CT_SHELL="/bin/sh"
	[ "${CT_CONFIG_SHELL_ASH}" = "y" -a -x "/bin/ash" ] && CT_SHELL="/bin/ash"

	setup_vars
	setup_toolchain_compiler

	# Determine build system if not set by the user
	CT_Test "You did not specify the build system. That's OK, I can guess..." -z "${CT_BUILD}"
	case "${CT_BUILD}" in
		"")
			export CT_BUILD=$("${CT_BUILD_PREFIX}gcc${CT_BUILD_SUFFIX}" -dumpmachine);;
	esac

	# Prepare mangling patterns to later modify BUILD and HOST (see below)
	case "${CT_TOOLCHAIN_TYPE}" in
		cross)
			export CT_HOST="${CT_BUILD}"
			build_mangle="build_"
			host_mangle="build_"
			;;
		*)  CT_Abort "No code for '${CT_TOOLCHAIN_TYPE}' toolchain type!"
			;;
	esac

	# Save the real tuples to generate shell-wrappers to the real tools
	export CT_REAL_BUILD="${CT_BUILD}"
	export CT_REAL_HOST="${CT_HOST}"

	# Canonicalise CT_BUILD and CT_HOST
	# Not only will it give us full-qualified tuples, but it will also ensure
	# that they are valid tuples (in case of typo with user-provided tuples)
	# That's way better than trying to rewrite config.sub ourselves...
	export CT_BUILD=$(CT_DoConfigSub "${CT_BUILD}")
	export CT_HOST=$(CT_DoConfigSub "${CT_HOST}")

	# Modify BUILD and HOST so that gcc always generate a cross-compiler
	# even if any of the build, host or target machines are the same.
	# NOTE: we'll have to mangle the (BUILD|HOST)->TARGET x-compiler to
	#       support canadain build, later...
	export CT_BUILD="${CT_BUILD/-/-${build_mangle}}"
	export CT_HOST="${CT_HOST/-/-${host_mangle}}"

	build_tools_alias

	# Carefully add paths in the order we want them:
	#  - first try in ${CT_PREFIX_DIR}/bin
	#  - then try in ${CT_CC_CORE_SHARED_PREFIX_DIR}/bin
	#  - then try in ${CT_CC_CORE_STATIC_PREFIX_DIR}/bin
	#  - fall back to searching user's PATH
	# Of course, neither cross-native nor canadian can run on BUILD,
	# so don't add those PATHs in this case...
	case "${CT_TOOLCHAIN_TYPE}" in
		cross)
			if [ "${CT_USE_EXTERNAL_TOOLCHAIN}" = "y" ] ; then
				export PATH="${CT_EXTERNAL_TOOLCHAIN_DIR}/bin:${CT_BIN_OVERIDE_DIR}:${CT_CC_CORE_SHARED_PREFIX_DIR}/bin:${CT_CC_CORE_STATIC_PREFIX_DIR}/bin:${PATH}"
			else
				export PATH="${CT_PREFIX_DIR}/bin:${CT_BIN_OVERIDE_DIR}:${CT_CC_CORE_SHARED_PREFIX_DIR}/bin:${CT_CC_CORE_STATIC_PREFIX_DIR}/bin:${PATH}"
			fi
		;;
		*)  ;;
	esac

	# Help gcc
	CT_CFLAGS_FOR_HOST=

	# Override the configured jobs with what's been given on the command line
	[ -n "${CT_JOBS}" ] && CT_PARALLEL_JOBS="${CT_JOBS}"

	# Set the shell to be used by ./configure scripts and by Makefiles (those
	# that support it!).
	export CONFIG_SHELL="${CT_SHELL}"

	# And help make go faster
	PARALLELMFLAGS=
	[ ${CT_PARALLEL_JOBS} -ne 0 ] && PARALLELMFLAGS="${PARALLELMFLAGS} -j${CT_PARALLEL_JOBS}"
	[ ${CT_LOAD} -ne 0 ] && PARALLELMFLAGS="${PARALLELMFLAGS} -l${CT_LOAD}"
	export PARALLELMFLAGS

	CT_DoLog EXTRA "Installing user-supplied configuration"
	CT_DoExecLog DEBUG install -m 0755 "${CT_LIB_DIR}/toolchain-config.in" "${CT_BUILD_DIR}/${CT_TARGET}-ct-ng.config"
	bzip2 -c -9 .config >>"${CT_BUILD_DIR}/${CT_TARGET}-ct-ng.config"

	CT_DoLog EXTRA  "Building a toolchain for:"
	CT_DoLog EXTRA  "  build  = ${CT_REAL_BUILD}"
	CT_DoLog EXTRA  "  host   = ${CT_REAL_HOST}"
	CT_DoLog EXTRA  "  target = ${CT_TARGET}"
	CT_EndStep
}
dumpUserConfig()
{
	if [ "${CT_DEBUG_DUMP_CONFIG}" != "y" ]; then
		return
	fi
	CT_DoStep DEBUG "Dumping user-supplied configuration"
	CT_DoExecLog DEBUG ${grep} -E '^(# |)CT_' .config
	CT_EndStep
}
dumpInternalConfig()
{
	if [ "${CT_DEBUG_DUMP_CONFIG}" != "y" ]; then
		return
	fi
	CT_DoStep DEBUG "Dumping internal configuration"
	set | ${grep} -E '^CT_.+=' | ${sort} |CT_DoLog DEBUG
	CT_EndStep
}


build_tools_alias()
{
	# Now we have mangled our BUILD and HOST tuples, we must fake the new
	# cross-tools for those mangled tuples.
	CT_DoLog DEBUG "Making build system tools available"
	CT_DoExecLog ALL mkdir -p "${CT_PREFIX_DIR}/bin"
	for m in BUILD HOST; do
		r="CT_REAL_${m}"
		v="CT_${m}"
		p="CT_${m}_PREFIX"
		s="CT_${m}_SUFFIX"
		CT_DoLog ALL "p=${!p} s=${!s} ${!r} ${CT_REAL_HOST} HOST:${HOST}"
		if [ -n "${!p}" ]; then
			t="${!p}"
		else
			t="${!r}-"
		fi

		for tool in ar as dlltool gcc g++ gcj gnatbind gnatmake ld nm objcopy objdump ranlib strip windres; do
			# First try with prefix + suffix
			# Then try with prefix only
			# Then try with suffix only, but only for BUILD, and HOST iff REAL_BUILD == REAL_HOST
			# Finally try with neither prefix nor suffix, but only for BUILD, and HOST iff REAL_BUILD == REAL_HOST
			# This is needed, because some tools have a prefix and
			# a suffix (eg. gcc), while others may have only one,
			# or even none (eg. binutils)
			where=$(CT_Which "${t}${tool}${!s}")
			[ -z "${where}" ] && where=$(CT_Which "${t}${tool}")
			if [    -z "${where}"                         \
			     -a \(    "${m}" = "BUILD"                \
			           -o "${CT_REAL_BUILD}" = "${!r}" \) ]; then
			    where=$(CT_Which "${tool}${!s}")
			fi
			if [ -z "${where}" -a \( "${m}" = "BUILD" -o "${CT_REAL_BUILD}" = "${!r}" \) ]; then
			    where=$(CT_Which "${tool}")
			fi

			# Not all tools are available for all platforms, but some are really,
			# bally needed
			if [ -n "${where}" ]; then
			    CT_DoLog DEBUG "  '${!v}-${tool}' -> '${where}'"
			    printf "#${BANG}${CT_SHELL}\nexec '${where}' \"\${@}\"\n" >"${CT_BIN_OVERIDE_DIR}/${!v}-${tool}"
			    CT_DoExecLog ALL chmod 700 "${CT_BIN_OVERIDE_DIR}/${!v}-${tool}"
			else
			    case "${tool}" in
			        # We'll at least need some of them...
			        ar|as|gcc|g++|ld|nm|objcopy|objdump|ranlib)
			            CT_Abort "Missing: '${t}${tool}${!s}' or '${t}${tool}' or '${tool}' <${where}> : either needed!"
			            ;;
			        # Some are conditionnally required
			        # Add them in alphabetical (C locale) ordering
			        gcj)
			            CT_TestAndAbort "Missing: '${t}${tool}${!s}' or '${t}${tool}' or '${tool}' : either needed!" "${CT_CC_LANG_JAVA}" = "y"
			            ;;
			        # If any other is missing, only warn at low level
			        *)
			            # It does not deserve a WARN level.
			            CT_DoLog DEBUG "  Missing: '${t}${tool}${!s}' or '${t}${tool}' or '${tool}' : not required."
			            ;;
			    esac
			fi
		done
	done
}


setup_vars()
{
	CT_DoStep INFO "Setup Compiler Variables"
	# Arrange paths depending on wether we use sys-root or not.
	if [ "${CT_USE_SYSROOT}" = "y" ]; then
		export CT_SYSROOT_DIR="${CT_PREFIX_DIR}/${CT_TARGET}/${CT_SYSROOT_DIR_PREFIX}/sys-root"
		export CT_DEBUGROOT_DIR="${CT_PREFIX_DIR}/${CT_TARGET}/${CT_SYSROOT_DIR_PREFIX}/debug-root"
		export CT_HEADERS_DIR="${CT_SYSROOT_DIR}/usr/include"
		export BINUTILS_SYSROOT_ARG="--with-sysroot=${CT_SYSROOT_DIR}"
		export CC_CORE_SYSROOT_ARG="--with-sysroot=${CT_SYSROOT_DIR}"
		export CC_SYSROOT_ARG="--with-sysroot=${CT_SYSROOT_DIR}"
		export LIBC_SYSROOT_ARG=""
		# glibc's prefix must be exactly /usr, else --with-sysroot'd gcc will get
		# confused when $sysroot/usr/include is not present.
		# Note: --prefix=/usr is magic!
		# See http://www.gnu.org/software/libc/FAQ.html#s-2.2
	else
		# plain old way. All libraries in prefix/target/lib
		export CT_SYSROOT_DIR="${CT_PREFIX_DIR}/${CT_TARGET}"
		export CT_DEBUGROOT_DIR="${CT_PREFIX_DIR}/${CT_TARGET}/${CT_SYSROOT_DIR_PREFIX}/debug-root"
		export CT_HEADERS_DIR="${CT_SYSROOT_DIR}/include"
		# hack!  Always use --with-sysroot for binutils.
		# binutils 2.14 and later obey it, older binutils ignore it.
		# Lets you build a working 32->64 bit cross gcc
		export BINUTILS_SYSROOT_ARG="--with-sysroot=${CT_SYSROOT_DIR}"
		# Use --with-headers, else final gcc will define disable_glibc while
		# building libgcc, and you'll have no profiling
		export CC_CORE_SYSROOT_ARG="--without-headers"
		export CC_SYSROOT_ARG="--with-headers=${CT_HEADERS_DIR}"
		export LIBC_SYSROOT_ARG="prefix="
	fi
	CT_EndStep
}


setup_toolchain_compiler()
{
	if [ "${CT_USE_EXTERNAL_TOOLCHAIN}" = "y" -o "${CT_MK_TOOLCHAIN}" = "" ] ; then
		return
	fi

	CT_DoStep INFO "Setup Environment Compiler"
	CT_DoExecLog ALL mkdir -p "${CT_SYSROOT_DIR}"
	CT_DoExecLog ALL mkdir -p "${CT_DEBUGROOT_DIR}"

	# Prepare the 'lib' directories in sysroot, else the ../lib64 hack used by
	# 32 -> 64 bit crosscompilers won't work, and build of final gcc will fail
	# with: "ld: cannot open crti.o: No such file or directory"
	# Also prepare the lib directory in the install dir, else some 64 bit archs
	# won't build
	CT_DoExecLog ALL mkdir -p "${CT_PREFIX_DIR}/lib"
	CT_DoExecLog ALL mkdir -p "${CT_SYSROOT_DIR}/lib"
	CT_DoExecLog ALL mkdir -p "${CT_SYSROOT_DIR}/usr/lib"

	# Prevent gcc from installing its libraries outside of the sys-root
	CT_DoExecLog ALL ln -sf "./${CT_SYSROOT_DIR_PREFIX}/sys-root/lib" "${CT_PREFIX_DIR}/${CT_TARGET}/lib"

	# Now, in case we're 64 bits, just have lib64/ be a symlink to lib/
	# so as to have all libraries in the same directory (we can do that
	# because we are *not* multilib).
	if [ "${CT_ARCH_64}" = "y" ]; then
		CT_DoExecLog ALL ln -sf "lib" "${CT_PREFIX_DIR}/lib64"
		CT_DoExecLog ALL ln -sf "lib" "${CT_PREFIX_DIR}/${CT_TARGET}/lib64"
		CT_DoExecLog ALL ln -sf "lib" "${CT_SYSROOT_DIR}/lib64"
		CT_DoExecLog ALL ln -sf "lib" "${CT_SYSROOT_DIR}/usr/lib64"
	fi
	CT_EndStep
}

all_done()
{
	CT_DoEnd INFO

	# From now-on, it can become impossible to log any time, because
	# either we're compressing the log file, or it can become RO any
	# moment... Consign all ouptut to oblivion...
	CT_DoLog INFO "Finishing installation (may take a few seconds)..."
	exec >/dev/null 2>&1

	[ "${CT_LOG_FILE_COMPRESS}" = y ] && bzip2 -9 "${CT_LOG_FILE}"
	[ "${CT_INSTALL_DIR_RO}" = "y" -a -d "${CT_INSTALL_DIR}" ] && chmod -R a-w "${CT_INSTALL_DIR}"

	trap - EXIT
	exit
}
###################################################################################



#########################################################
# MAIN
#########################################################
# This is the main entry point to crosstool
# This will:
#   - download, extract and patch the toolchain components
#   - build and install each components in turn
#   - and eventually test the resulting toolchain

# Parse the common functions
# Note: some initialisation and sanitizing is done while parsing this file,
# most notably:
#  - set trap handler on errors,
#  - don't hash commands lookups,
#  - initialise logging.
if [ -f "${CT_LIB_DIR}/functions.sh" ] ; then
	source "${CT_LIB_DIR}/functions.sh"
else
	echo "Unable to find ${CT_LIB_DIR}/functions.sh"
	exit
fi

# Parse the configuration file
# It has some info about the logging facility, so include it early
source ${CT_TOP_DIR}/.config

step=setup

# Overide the locale early
[ -z "${CT_NO_OVERIDE_LC_MESSAGES}" ] && export LC_ALL=C

# Where will we work? TODO
CT_WORK_DIR="${CT_WORK_DIR:-${CT_TMP_DIR}/_targets}"
CT_SRC_DIR="${CT_TMP_DIR}/_src"
CT_TARBALLS_DIR="${CT_TMP_DIR}/_archives"

# Start date. Can't be done until we know the locale
CT_STAR_DATE=$(CT_DoDate +%s%N)
CT_STAR_DATE_HUMAN=$(CT_DoDate +%Y%m%d.%H%M%S)
CT_DoLog INFO "Build started ${CT_STAR_DATE_HUMAN}"
createBinOveride
export PATH="${CT_BIN_OVERIDE_DIR}"

eval $*


buildEnv
if [ -z "${CT_RESTART}" ]; then
	CT_DoLog INFO "Restarting Build"
	# Setup the rest of the environment only if not restarting
	prepareWorkingDirs
	redirectLog
	setup_environment
	dumpUserConfig
	dumpInternalConfig

	for component in ${CT_COMPONENTS}; do
		IT=${component%%_*}
		# Skip package, if it's not enabled in config
		# TODO: this will skip every non-package
		eval COMPILE=\${CT_PKG_`echo ${IT}`}
		if [ "${CT_PKG}" = "y" ]; then
			if [ "${COMPILE}" = "n" -o "${COMPILE}" = "" ]; then
				continue
				:
			fi
		fi
		. "${CT_COMPONENTS_DIR}/${component}/build.sh"
		do_${component}_get
		if [ "${CT_ONLY_DOWNLOAD}" = "y" ]; then
			continue
			:
		fi
		if [ "${CT_FORCE_EXTRACT}" = "y" ]; then
			CT_DoForceRmdir "${CT_SRC_DIR}"
			CT_DoExecLog ALL mkdir -p "${CT_SRC_DIR}"
		fi
		do_${component}_extract
	done
fi

# Building the targets
if [ "${CT_ONLY_DOWNLOAD}" = "y" -o "${CT_ONLY_EXTRACT}" = "y" ]; then
	all_done
fi

# Because of CT_RESTART, this becomes quite complex
do_stop=0
prev_step=

[ -n "${CT_RESTART}" ] && do_it=0 || do_it=1

for step in ${CT_STEPS}; do
	#IT=`echo ${step}|cut -f1 -d'_'`
	IT=${step%%_*}

	# Skip it, if it's not enabled in config
	eval COMPILE=\${CT_PKG_`echo ${IT}`}
	if [ "${CT_PKG}" = "y" ]; then
		if [ "${COMPILE}" = "n" -o "${COMPILE}" = "" ]; then
			continue
			:
		fi
	fi

	. "${CT_COMPONENTS_DIR}/${IT}/build.sh"
	if [ ${do_it} -eq 0 ]; then
		if [ "${CT_RESTART}" = "${step}" ]; then
			CT_DoLoadState "${step}"
			#CT_SetLibPath "${CT_PREFIX_DIR}/lib:${CT_PREFIX_DIR}/${CT_TARGET}/lib" first
			CT_DoLog INFO "Log File: ${CT_LOG_FILE}"
			do_it=1
			do_stop=0
		fi
	else
		CT_DoSaveState ${step}
		if [ ${do_stop} -eq 1 ]; then
			CT_DoLog INFO "Stopping just after step '${prev_step}', as requested."
			exit 0
		fi
	fi
	if [ ${do_it} -eq 1 ]; then
		do_${step}
		if [ "${CT_STOP}" = "${step}" ]; then
			do_stop=1
		fi
	CT_DoPause "Step '${step}' finished. ${CT_STEPS/${step} /${step} >>>}'"
	fi
	prev_step="${step}"
done
all_done
