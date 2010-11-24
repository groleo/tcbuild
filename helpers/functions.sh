# This file contains some usefull common functions
# Copyright 2007 Yann E. MORIN
# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


# Prepare the fault handler
CT_OnError() {
	ret=$?
	# Bail out early in subshell, the upper level shell will act accordingly.
	[ ${BASH_SUBSHELL} -eq 0 ] || exit $ret

	CT_DoLog ERROR "Report:-----------------------------------------------"
	CT_DoLog ERROR ""
	CT_DoLog ERROR "Build failed in step '${CT_STEP_MESSAGE[${CT_STEP_COUNT}]}'"
	for ((s=(CT_STEP_COUNT-1); s>1; s--)); do
		CT_DoLog ERROR "      called in step '${CT_STEP_MESSAGE[${s}]}'"
	done

	CT_DoLog ERROR "Error happened in '${BASH_SOURCE[1]}' in function '${FUNCNAME[1]}' (line unknown, sorry)"
	for ((depth=2; ${BASH_LINENO[$((${depth}-1))]}>0; depth++)); do
		CT_DoLog ERROR "      called from ${BASH_SOURCE[${depth}]} +${BASH_LINENO[${depth}-1]} in function '${FUNCNAME[${depth}]}'"
	done

	[ "${CT_LOG_TO_FILE}" = "y" ] && CT_DoLog ERROR "Look at '${CT_LOG_FILE}' for more info on this error."

	if [ "${CT_USE_EXTERNAL_TOOLCHAIN}" = "y" ] ; then
		CT_DoLog ERROR "Using External compiler"
	else
		CT_DoLog ERROR "Using Internal compiler"
	fi

	CT_DoLog ERROR "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
	CT_DoLog ERROR "PATH=${PATH}"
	CT_DoLog ERROR "------------------------------------------------------"

	CT_STEP_COUNT=1
	CT_DoEnd ERROR
	exit $ret
}

# Install the fault handler
trap CT_OnError ERR

# Inherit the fault handler in subshells and functions
set -E

# Make pipes fail on the _first_ failed command
# Not supported on bash < 3.x, but we need it, so drop the obsoleting bash-2.x
set -o pipefail

# Don't hash commands' locations, and search every time it is requested.
# This is slow, but needed because of the static/shared core gcc which shall
# always match to shared if it exists, and only fallback to static if the
# shared is not found
set +o hashall

# Log policy:
#  - first of all, save stdout so we can see the live logs: fd #6
exec 6>&1
#  - then point stdout to the log file (temporary for now)
tmp_log_file="${CT_LOG_DIR}/`date +%s`_$$.log"
exec >>"${tmp_log_file}"

# The different log levels:
CT_LOG_LEVEL_ERROR=0
CT_LOG_LEVEL_WARN=1
CT_LOG_LEVEL_INFO=2
CT_LOG_LEVEL_EXTRA=3
CT_LOG_LEVEL_DEBUG=4
CT_LOG_LEVEL_ALL=5

# Make it easy to use \n and !
CR=$(printf "\n")
BANG='!'

# Add the specified directory to LD_LIBRARY_PATH, and export it
# If the specified patch is already present, just export
# $1: path to add
# $2: add as 'first' or 'last' path, 'first' is assumed if $2 is empty
# Usage CT_SetLibPath /some/where/lib [first|last]
CT_SetLibPath() {
    local path="$1"
    local pos="$2"

    case ":${LD_LIBRARY_PATH}:" in
        *:"${path}":*)  ;;
        *)  case "${pos}" in
                last)
                    CT_DoLog DEBUG "Adding '${path}' at end of LD_LIBRARY_PATH"
                    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${path}"
                    ;;
                first|"")
                    CT_DoLog DEBUG "Adding '${path}' at start of LD_LIBRARY_PATH"
                    LD_LIBRARY_PATH="${path}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
                    ;;
                *)
                    CT_Abort "Incorrect position '${pos}' to add '${path}' to LD_LIBRARY_PATH"
                    ;;
            esac
            ;;
    esac
    CT_DoLog INFO "==> LD_LIBRARY_PATH='${LD_LIBRARY_PATH}'"
    export LD_LIBRARY_PATH
    export LD_RUN_PATH=""
}




# A function to log what is happening
# Different log level are available:
#   - ERROR:   A serious, fatal error occurred
#   - WARN:    A non fatal, non serious error occurred, take your responsbility with the generated build
#   - INFO:    Informational messages
#   - EXTRA:   Extra informational messages
#   - DEBUG:   Debug messages
#   - ALL:     Component's build messages
# Usage: CT_DoLog <level> [message]
# If message is empty, then stdin will be logged.
CT_DoLog() {
	local max_level LEVEL level cur_l cur_L
	local l
	eval max_level="\${CT_LOG_LEVEL_${CT_LOG_LEVEL_MAX}}"
	# Set the maximum log level to DEBUG if we have none
	[ -z "${max_level}" ] && max_level=${CT_LOG_LEVEL_DEBUG}

	LEVEL="$1"; shift
	eval level="\${CT_LOG_LEVEL_${LEVEL}}"

	if [ $# -eq 0 ]; then
		${cat} -
	else
		echo "${@}"
	fi |( IFS="${CR}" # We want the full lines, even leading spaces
		  _prog_bar_cpt=0
		  _prog_bar[0]='/'
		  _prog_bar[1]='-'
		  _prog_bar[2]="\\"
		  _prog_bar[3]='|'
		  indent=$((2*CT_STEP_COUNT))
		  while read line; do
			  case "${CT_LOG_SEE_TOOLS_WARN},${line}" in
				y,*"warning:"*)         cur_L=WARN; cur_l=${CT_LOG_LEVEL_WARN};;
				y,*"WARNING:"*)         cur_L=WARN; cur_l=${CT_LOG_LEVEL_WARN};;
				*"error:"*)             cur_L=ERROR; cur_l=${CT_LOG_LEVEL_ERROR};;
				*"make["*"]: *** ["*)   cur_L=ERROR; cur_l=${CT_LOG_LEVEL_ERROR};;
				*)                      cur_L="${LEVEL}"; cur_l="${level}";;
			  esac
			# There will always be a log file (stdout, fd #1), be it /dev/null
			printf "[%-5s %s]%*s%s %s\n" "${cur_L}" "${step}" "${indent}" " " "${line}" >&1

			# Only print to console (fd #6) if log level is high enough.
			  if [ "${cur_l}" -le "${max_level}" ]; then
				printf "\r[%-5s %s]%*s%s%s\n" "${cur_L}" "${step}" "${indent}" " " "${line}" >&6
			  fi
			  if [ "${CT_LOG_PROGRESS_BAR}" = "y" ]; then
				  printf "\r[%02d:%02d] %s " $((SECONDS/60)) $((SECONDS%60)) "${_prog_bar[$((_prog_bar_cpt/10))]}" >&6
				  _prog_bar_cpt=$(((_prog_bar_cpt+1)%40))
			  fi
		  done
		)

	return 0
}

# Execute an action, and log its messages
# Usage: CT_DoExecLog <level> <[VAR=val...] command [parameters...]>
CT_DoExecLog() {
	local level="$1"
	shift
	CT_DoLog DEBUG "==> Executing: '${@}'"
	"${@}" 2>&1 |CT_DoLog "${level}"
}

# Tail message to be logged whatever happens
# Usage: CT_DoEnd <level>
CT_DoEnd()
{
	local level="$1"
	CT_STOP_DATE=$(CT_DoDate +%s%N)
	CT_STOP_DATE_HUMAN=$(CT_DoDate +%Y%m%d.%H%M%S)
	if [ "${level}" != "ERROR" ]; then
		CT_DoLog "${level:-INFO}" "Build completed at ${CT_STOP_DATE_HUMAN}"
	fi
	elapsed=$((CT_STOP_DATE-CT_STAR_DATE))
	elapsed_min=$((elapsed/(60*1000*1000*1000)))
	elapsed_sec=$(printf "%02d" $(((elapsed%(60*1000*1000*1000))/(1000*1000*1000))))
	elapsed_csec=$(printf "%02d" $(((elapsed%(1000*1000*1000))/(10*1000*1000))))
	CT_DoLog ${level:-INFO} "(elapsed: ${elapsed_min}:${elapsed_sec}.${elapsed_csec})"
}

# Abort the execution with an error message
# Usage: CT_Abort <message>
CT_Abort() {
	CT_DoLog ERROR "$1"
	exit 1
}

# Test a condition, and print a message if satisfied
# Usage: CT_Test <message> <tests>
CT_Test() {
	local ret
	local m="$1"
	shift
	test "$@" && CT_DoLog WARN "$m"
	return 0
}

# Test a condition, and abort with an error message if satisfied
# Usage: CT_TestAndAbort <message> <tests>
CT_TestAndAbort() {
	local m="$1"
	shift
	test "$@" && CT_Abort "$m"
	return 0
}

# Test a condition, and abort with an error message if not satisfied
# Usage: CT_TestAndAbort <message> <tests>
CT_TestOrAbort() {
	local m="$1"
	shift
	test "$@" || CT_Abort "$m"
	return 0
}

# Test the presence of a tool, or abort if not found
# Usage: CT_HasOrAbort <tool>
CT_HasOrAbort() {
	CT_TestAndAbort "'${1}' not found and needed for successful toolchain build." -z "$(CT_Which "${1}")"
	return 0
}

# Search a program: wrap "which" for those system where
# "which" verbosely says there is no match (Mandriva is
# such a sucker...)
# Usage: CT_Which <filename>
CT_Which() {
  which "$1" 2>/dev/null || true
}

# Get current date with nanosecond precision
# On those system not supporting nanosecond precision, faked with rounding down
# to the highest entire second
# Usage: CT_DoDate <fmt>
CT_DoDate() {
	${date} "$1" | ${sed} -r -e 's/%N$/000000000/;'
}

CT_STEP_COUNT=1
CT_STEP_MESSAGE[${CT_STEP_COUNT}]="<none>"
# Memorise a step being done so that any error is caught
# Usage: CT_DoStep <loglevel> <message>
CT_DoStep() {
	local start=$(CT_DoDate +%s%N)
	CT_DoLog "$1" "================================================================="
	CT_DoLog "$1" "$2"
	CT_STEP_COUNT=$((CT_STEP_COUNT+1))
	CT_STEP_LEVEL[${CT_STEP_COUNT}]="$1"; shift
	CT_STEP_START[${CT_STEP_COUNT}]="${start}"
	CT_STEP_MESSAGE[${CT_STEP_COUNT}]="$1"
	return 0
}

# End the step just being done
# Usage: CT_EndStep
CT_EndStep() {
	local stop=$(CT_DoDate +%s%N)
	local duration=$(printf "%032d" $((stop-${CT_STEP_START[${CT_STEP_COUNT}]})) | ${sed} -r -e 's/([[:digit:]]{2})[[:digit:]]{7}$/\.\1/; s/^0+//; s/^\./0\./;')
	local elapsed=$(printf "%02d:%02d" $((SECONDS/60)) $((SECONDS%60)))
	local level="${CT_STEP_LEVEL[${CT_STEP_COUNT}]}"
	local message="${CT_STEP_MESSAGE[${CT_STEP_COUNT}]}"
	CT_STEP_COUNT=$((CT_STEP_COUNT-1))
	CT_DoLog "${level}" "${message}: done in ${duration}s (at ${elapsed})"
	return 0
}

# Pushes into a directory, and pops back
CT_Pushd() {
	CT_TestOrAbort "CT_Pushd:Invalid directory $1" -d "${1}"
	pushd "$1" > /dev/null 2>&1
	CT_DoLog DEBUG "pushd $1"
}
CT_Popd() {
	O="`popd 2>&1`"
	CT_DoLog DEBUG "popd ${O}"
}

# Creates a temporary directory
# $1: variable to assign to
# Usage: CT_MktempDir foo
CT_MktempDir() {
	# Some mktemp do not allow more than 6 Xs
	eval "$1"=$(mktemp -q -d "${CT_BUILD_DIR}/tmp.XXXXXX")
	CT_TestOrAbort "Could not make temporary directory" -n "${!1}" -a -d "${!1}"
	CT_DoLog DEBUG "Made temporary directory '${!1}'"
	return 0
}

# Removes one or more directories, even if it is read-only, or its parent is
# Usage: CT_DoForceRmdir dir [...]
CT_DoForceRmdir() {
	local dir
	local mode
	for dir in "${@}"; do
		[ -d "${dir}" ] || continue
		mode="$(stat -c '%a' "$(dirname "${dir}")")"
		CT_DoExecLog ALL chmod u+w "$(dirname "${dir}")"
		CT_DoExecLog ALL chmod -R u+w "${dir}"
		CT_DoExecLog ALL rm -rf "${dir}"
		CT_DoExecLog ALL chmod ${mode} "$(dirname "${dir}")"
	done
}
CT_DoForceStrip() {
	local dir
	local mode
	local STRIP="$1"
	shift
	for dir in "${@}"; do
		[ -d "${dir}" ] || continue
		mode="$(stat -c '%a' "$(dirname "${dir}")")"
		CT_DoExecLog ALL chmod u+w "$(dirname "${dir}")"
		CT_DoExecLog ALL chmod -R u+w "${dir}"
		CT_DoExecLog ALL $STRIP"${dir}"
		CT_DoExecLog ALL chmod ${mode} "$(dirname "${dir}")"
	done
}
# Echoes the specified string on stdout until the pipe breaks.
# Doesn't fail
# $1: string to echo
# Usage: CT_DoYes "" | make oldconfig
CT_DoYes() {
	yes "$1" || true
}

# Get the file name extension of a component
# Usage: CT_GetFileExtension <component_name-component_version> [extension]
# If found, echoes the extension to stdout
# If not found, echoes nothing on stdout.
CT_GetFileExtension() {
	local ext
	local file="$1"
	shift
	local first_ext="$1"

	# we need to also check for an empty extension for those very
	# peculiar components that don't have one (such as sstrip from
	# buildroot).
	for ext in ${first_ext} .tar.gz .tar.bz2 .tgz .tar ''; do
		if [ -f "${CT_TARBALLS_DIR}/${file}${ext}" ]; then
			echo "${ext}"
			break
		fi
	done

	return 0
}

# Set environment for proxy access
# Usage: CT_DoSetProxy <proxy_type>
# where proxy_type is one of 'http', 'sockssys', 'socks4' or 'socks5',
# or empty (to not change proxy settings).
CT_DoSetProxy() {
	case "${1}" in
		http)
			http_proxy="http://"
			case  "${CT_PROXY_USER}:${CT_PROXY_PASS}" in
				:)      ;;
				:*)     http_proxy="${http_proxy}:${CT_PROXY_PASS}@";;
				*:)     http_proxy="${http_proxy}${CT_PROXY_USER}@";;
				*:*)    http_proxy="${http_proxy}${CT_PROXY_USER}:${CT_PROXY_PASS}@";;
			esac
			export http_proxy="${http_proxy}${CT_PROXY_HOST}:${CT_PROXY_PORT}/"
			export https_proxy="${http_proxy}"
			export ftp_proxy="${http_proxy}"
			CT_DoLog DEBUG "http_proxy='${http_proxy}'"
			;;
		sockssys)
			CT_HasOrAbort tsocks
			. tsocks -on
			;;
		socks*)
			# Remove any lingering config file from any previous run
			rm -f "${CT_BUILD_DIR}/tsocks.conf"
			# Find all interfaces and build locally accessible networks
			server_ip=$(ping -c 1 -W 2 "${CT_PROXY_HOST}" | ${head} -n 1 | ${sed} -r -e 's/^[^\(]+\(([^\)]+)\).*$/\1/;' || true)
			CT_TestOrAbort "SOCKS proxy '${CT_PROXY_HOST}' has no IP." -n "${server_ip}"
			/sbin/ifconfig | ${awk} -v server_ip="${server_ip}" '
				BEGIN {
				    split( server_ip, tmp, "\\." );
				    server_ip_num = tmp[1] * 2^24 + tmp[2] * 2^16 + tmp[3] * 2^8 + tmp[4] * 2^0;
				    pairs = 0;
				}

				$0 ~ /^[[:space:]]*inet addr:/ {
				    split( $2, tmp, ":|\\." );
				    if( ( tmp[2] == 127 ) && ( tmp[3] == 0 ) && ( tmp[4] == 0 ) && ( tmp[5] == 1 ) ) {
				        /* Skip 127.0.0.1, it'\''s taken care of by tsocks itself */
				        next;
				    }
				    ip_num = tmp[2] * 2^24 + tmp[3] * 2^16 + tmp[4] * 2 ^8 + tmp[5] * 2^0;
				    i = 32;
				    do {
				        i--;
				        mask = 2^32 - 2^i;
				    } while( (i!=0) && ( and( server_ip_num, mask ) == and( ip_num, mask ) ) );
				    mask = and( 0xFFFFFFFF, lshift( mask, 1 ) );
				    if( (i!=0) && (mask!=0) ) {
				        masked_ip = and( ip_num, mask );
				        for( i=0; i<pairs; i++ ) {
				            if( ( masked_ip == ips[i] ) && ( mask == masks[i] ) ) {
				                next;
				            }
				        }
				        ips[pairs] = masked_ip;
				        masks[pairs] = mask;
				        pairs++;
				        printf( "local = %d.%d.%d.%d/%d.%d.%d.%d\n",
				                and( 0xFF, masked_ip / 2^24 ),
				                and( 0xFF, masked_ip / 2^16 ),
				                and( 0xFF, masked_ip / 2^8 ),
				                and( 0xFF, masked_ip / 2^0 ),
				                and( 0xFF, mask / 2^24 ),
				                and( 0xFF, mask / 2^16 ),
				                and( 0xFF, mask / 2^8 ),
				                and( 0xFF, mask / 2^0 ) );
				    }
				}
			' >"${CT_BUILD_DIR}/tsocks.conf"
			( echo "server = ${server_ip}";
			  echo "server_port = ${CT_PROXY_PORT}";
			  [ -n "${CT_PROXY_USER}"   ] && echo "default_user=${CT_PROXY_USER}";
			  [ -n "${CT_PROXY_PASS}" ] && echo "default_pass=${CT_PROXY_PASS}";
			) >>"${CT_BUILD_DIR}/tsocks.conf"
			case "${CT_PROXY_TYPE/socks}" in
				4|5) proxy_type="${CT_PROXY_TYPE/socks}";;
				auto)
				    reply=$(inspectsocks "${server_ip}" "${CT_PROXY_PORT}" 2>&1 || true)
				    case "${reply}" in
				        *"server is a version 4 socks server") proxy_type=4;;
				        *"server is a version 5 socks server") proxy_type=5;;
				        *) CT_Abort "Unable to determine SOCKS proxy type for '${CT_PROXY_HOST}:${CT_PROXY_PORT}'"
				    esac
				    ;;
			esac
			echo "server_type = ${proxy_type}" >> "${CT_BUILD_DIR}/tsocks.conf"
			CT_HasOrAbort tsocks
			# If tsocks was found, then validateconf is present (distributed with tsocks).
			CT_DoExecLog DEBUG validateconf -f "${CT_BUILD_DIR}/tsocks.conf"
			export TSOCKS_CONF_FILE="${CT_BUILD_DIR}/tsocks.conf"
			. tsocks -on
			;;
	esac
}

# Download an URL using wget
# Usage: CT_DoGetFileWget <URL>
CT_DoGetFileWget() {
	# Need to return true because it is legitimate to not find the tarball at
	# some of the provided URLs (think about snapshots, different layouts for
	# different gcc versions, etc...)
	# Some (very old!) FTP server might not support the passive mode, thus
	# retry without
	# With automated download as we are doing, it can be very dangerous to use
	# -c to continue the downloads. It's far better to simply overwrite the
	# destination file
	# Some company networks have firewalls to connect to the internet, but it's
	# not easy to detect them, and wget does not timeout by default while
	# connecting, so force a global ${CT_CONNECT_TIMEOUT}-second timeout.
# TODO make passive/active  a configurable parameter
	${wget} -T ${CT_CONNECT_TIMEOUT} -nc --progress=dot:binary --tries=${CT_DOWNLOAD_RETRIES} --passive-ftp "$1"    \
	|| ${wget} -T ${CT_CONNECT_TIMEOUT} -nc --progress=dot:binary --tries=${CT_DOWNLOAD_RETRIES} "$1"               \
	|| true
}

# Download an URL using curl
# Usage: CT_DoGetFileCurl <URL>
CT_DoGetFileCurl() {
	# Note: comments about wget method (above) are also valid here
	# Plus: no good progress indicator is available with curl,
	#       so be silent.
	CT_DoExecLog ALL ${curl} -s --ftp-pasv -O --retry ${CT_DOWNLOAD_RETRIES} "$1" --connect-timeout ${CT_CONNECT_TIMEOUT} \
	|| CT_DoExecLog ALL ${curl} -s -O --retry ${CT_DOWNLOAD_RETRIES} "$1" --connect-timeout ${CT_CONNECT_TIMEOUT} \
	|| true
}

_wget=$(CT_Which wget)
_curl=$(CT_Which curl)
# Wrapper function to call one of curl or wget
# Usage: CT_DoGetFile <URL>
CT_DoGetFile() {
	case "${_wget},${_curl}" in
		,)  CT_Abort "Could find neither wget nor curl";;
		,*) CT_DoGetFileCurl "$1";;
		*)  CT_DoGetFileWget "$1";;
	esac
}

# This function tries to retrieve a tarball form a local directory
# Usage: CT_GetLocal <basename> [.extension]
CT_GetLocal() {
	local basename="$1"
	local first_ext="$2"
	local ext

	# Do we already have it in *our* tarballs dir?
	ext=$(CT_GetFileExtension "${basename}" ${first_ext})
	if [ -n "${ext}" ]; then
		CT_DoLog DEBUG "Already have '${basename}'"
		return 0
	fi

	if [ -n "${CT_LOCAL_TARBALLS_DIR}" ]; then
		CT_DoLog DEBUG "Trying to retrieve an already downloaded copy of '${basename}'"
		# We'd rather have a bzip2'ed tarball, then gzipped tarball, plain tarball,
		# or, as a failover, a file without extension.
		for ext in ${first_ext} .tar.bz2 .tar.gz .tgz .tar ''; do
			CT_DoLog DEBUG "Trying '${CT_LOCAL_TARBALLS_DIR}/${basename}${ext}'"
			if [ -r "${CT_LOCAL_TARBALLS_DIR}/${basename}${ext}" -a \
				 "${CT_FORCE_DOWNLOAD}" != "y" ]; then
				CT_DoLog DEBUG "Got '${basename}' from local storage"
				CT_DoExecLog ALL ln -s "${CT_LOCAL_TARBALLS_DIR}/${basename}${ext}" "${CT_TARBALLS_DIR}/${basename}${ext}"
				return 0
			fi
		done
	fi
	return 1
}

# This function saves the specified to local storage if possible,
# and if so, symlinks it for later usage
# Usage: CT_SaveLocal </full/path/file.name>
CT_SaveLocal() {
	local file="$1"
	local basename="${file##*/}"

	if [ "${CT_SAVE_TARBALLS}" = "y" ]; then
		CT_DoLog EXTRA "Saving '${basename}' to local storage"
		# The file may already exist if downloads are forced: remove it first
		CT_DoExecLog ALL rm -f "${CT_LOCAL_TARBALLS_DIR}/${basename}"
		CT_DoExecLog ALL mv -f "${file}" "${CT_LOCAL_TARBALLS_DIR}"
		CT_DoExecLog ALL ln -s "${CT_LOCAL_TARBALLS_DIR}/${basename}" "${file}"
	fi
}

# Download the file from one of the URLs passed as argument
# Usage: CT_GetFile <basename> [.extension] <url> [url ...]
CT_GetFile() {
	local ext
	local url URLS LAN_URLS
	local file="$1"
	local first_ext
	shift
	# If next argument starts with a dot, then this is not an URL,
	# and we can consider that it is a preferred extension.
	case "$1" in
		.*) first_ext="$1"
			shift
			;;
	esac

	# Does it exist localy?
	CT_GetLocal "${file}" ${first_ext} && return 0 || true
	# No, it does not...

	# Are downloads allowed ?
	CT_TestAndAbort "File '${file}' not present locally, and downloads are not allowed" "${CT_FORBID_DOWNLOAD}" = "y"

	# Try to retrieve the file
	CT_DoLog EXTRA "Retrieving '${file}'"
	CT_Pushd "${CT_TARBALLS_DIR}"

	URLS="$@"

	# Add URLs on the LAN mirror
	LAN_URLS=
	if [ "${CT_USE_MIRROR}" = "y" ]; then
		CT_TestOrAbort "Please set the mirror base URL" -n "${CT_MIRROR_BASE_URL}"
		LAN_URLS="${LAN_URLS} ${CT_MIRROR_BASE_URL}/${file%-*}"
		LAN_URLS="${LAN_URLS} ${CT_MIRROR_BASE_URL}"

		if [ "${CT_PREFER_MIRROR}" = "y" ]; then
			CT_DoLog DEBUG "Pre-pending LAN mirror URLs"
			URLS="${LAN_URLS} ${URLS}"
		else
			CT_DoLog DEBUG "Appending LAN mirror URLs"
			URLS="${URLS} ${LAN_URLS}"
		fi
	fi

	# Scan all URLs in turn, and try to grab a tarball from there
	CT_DoSetProxy ${CT_PROXY_TYPE}

	# Try all urls in turn
	for url in ${URLS}; do
		for ext in ${first_ext} .tar.bz2 .tar.gz .tgz .tar ''; do
			CT_DoLog DEBUG "Trying '${url}/${file}${ext}'"
			CT_DoGetFile "${url}/${file}${ext}"
			if [ -f "${file}${ext}" ]; then
				CT_DoLog DEBUG "Got '${file}' from the Internet"
				CT_SaveLocal "${CT_TARBALLS_DIR}/${file}${ext}"
				return 0
			fi
		done
	done
	CT_Popd

	CT_Abort "Could not retrieve '${file}'."
}

# Checkout from CVS, and build the associated tarball
# The tarball will be called ${basename}.tar.bz2
# Prerequisite: either the server does not require password,
# or the user must already be logged in.
# 'tag' is the tag to retrieve. Must be specified, but can be empty.
# If dirname is specified, then module will be renamed to dirname
# prior to building the tarball.
# Usage: CT_GetCVS <basename> <url> <module> <tag> [dirname]
CT_GetCVS() {
	local basename="$1"
	local uri="$2"
	local module="$3"
	local tag="${4:+-r ${4}}"
	local dirname="$5"
	local tmp_dir

	# Does it exist localy?
	CT_GetLocal "${basename}" && return 0 || true
	# No, it does not...

	# Are downloads allowed ?
	CT_TestAndAbort "File '${basename}' not present locally, and downloads are not allowed" "${CT_FORBID_DOWNLOAD}" = "y"

	CT_DoLog EXTRA "Retrieving '${basename}'"

	CT_MktempDir tmp_dir
	CT_Pushd "${tmp_dir}"

	CT_DoSetProxy ${CT_PROXY_TYPE}
	CT_DoExecLog ALL ${cvs} -z 9 -d "${uri}" co -P ${tag} "${module}"
	[ -n "${dirname}" ] && CT_DoExecLog ALL mv "${module}" "${dirname}"
	CT_DoExecLog ALL ${tar} cjf "${CT_TARBALLS_DIR}/${basename}.tar.bz2" "${dirname:-${module}}"
	CT_SaveLocal "${CT_TARBALLS_DIR}/${basename}.tar.bz2"

	CT_Popd
	CT_DoExecLog ALL rm -rf "${tmp_dir}"
}

# Check out from SVN, and build the associated tarball
# The tarball will be called ${basename}.tar.bz2
# Prerequisite: either the server does not require password,
# or the user must already be logged in.
# 'rev' is the revision to retrieve
# Usage: CT_GetSVN <basename> <url> [rev]
CT_GetSVN() {
	local basename="$1"
	local uri="$2"
	local rev="$3"

	# Does it exist localy?
	CT_GetLocal "${basename}" && return 0 || true
	# No, it does not...

	# Are downloads allowed ?
	CT_TestAndAbort "File '${basename}' not present locally, and downloads are not allowed" "${CT_FORBID_DOWNLOAD}" = "y"

	CT_DoLog EXTRA "Retrieving '${basename}'"

	CT_MktempDir tmp_dir
	CT_Pushd "${tmp_dir}"

	CT_DoSetProxy ${CT_PROXY_TYPE}
	CT_DoExecLog ALL ${svn} export ${rev:+-r ${rev}} "${uri}" "${basename}"
	CT_DoExecLog ALL ${tar} cjf "${CT_TARBALLS_DIR}/${basename}.tar.bz2" "${basename}"
	CT_SaveLocal "${CT_TARBALLS_DIR}/${basename}.tar.bz2"

	CT_Popd
	CT_DoExecLog ALL rm -rf "${tmp_dir}"
}

# Extract a tarball
# Some tarballs need to be extracted in specific places. Eg.: glibc addons
# must be extracted in the glibc directory; uCLibc locales must be extracted
# in the extra/locale sub-directory of uClibc. This is taken into account
# by the caller, that did a 'cd' into the correct path before calling us
# and sets nochdir to 'nochdir'.
# Usage: CT_Extract <basename> [nochdir]
CT_Extract() {
	local basename="$1"
	local nochdir="$2"
	local ext=$(CT_GetFileExtension "${basename}")
	CT_TestAndAbort "'${basename}' not found in '${CT_TARBALLS_DIR}'" -z "${ext}"
	local full_file="${CT_TARBALLS_DIR}/${basename}${ext}"
	CT_DoStep INFO "EXTRACT '${basename}'"

	# Check if already extracted
	if [ -e "${CT_SRC_DIR}/_${basename}.extracted" ]; then
		CT_DoLog DEBUG "Already extracted '${basename}'"
		CT_EndStep
		return 0
	fi

	[ "${nochdir}" = "nochdir" ] || CT_Pushd "${CT_SRC_DIR}"

	case "${ext}" in
		.tar.bz2)     CT_DoExecLog EXTRA ${tar} xvjf "${full_file}";;
		.tar.gz|.tgz) CT_DoExecLog EXTRA ${tar} xvzf "${full_file}";;
		.tar)         CT_DoExecLog EXTRA ${tar} xvf  "${full_file}";;
		*)            CT_Abort "Don't know how to handle '${basename}${ext}': unknown extension" ;;
	esac

	# Some tarballs have read-only files... :-(
	# Because of nochdir, we don't know where we are, so chmod all
	# the src tree
	CT_DoExecLog DEBUG chmod -R u+w "${CT_SRC_DIR}"

	CT_DoExecLog DEBUG touch "${CT_SRC_DIR}/_${basename}.extracted"

	[ "${nochdir}" = "nochdir" ] || CT_Popd
	CT_EndStep
}

CT_SubGitApply() {
	CT_DoLog DEBUG "GIT-APPLY '${1}'"
	CT_DoExecLog ALL ${git_apply} -v --apply --whitespace=nowarn "${1}"
	CT_TestAndAbort "FAIL GIT-APPLY '${1}'" ${PIPESTATUS[0]} -ne 0
}

CT_SubPatch() {
	CT_DoLog DEBUG "PATCH     '${1}'"
	CT_DoExecLog ALL ${patch} -g0 -F1 -p1 -f <"${1}"
	CT_TestAndAbort "FAIL PATCH '${1}'" ${PIPESTATUS[0]} -ne 0
}

# Patches the specified component
# Usage: CT_Patch <basename> [nochdir]
CT_Patch() {
	local file="$1"
	local nochdir="$2"

	local base_dir=${file%/*}
	local basename=${file##*/}
	local base_file="${basename%%[_-]*}"
	local ver_file="${basename##*[_-]}"
	local official_patch_dir
	local pkg_patch_dir
	CT_DoLog EXTRA "PATCHING ${basename}"
	# Check if already patched
	if [ -e "${CT_SRC_DIR}/_${basename}.patched" ]; then
		CT_DoLog DEBUG "Already patched '${basename}'"
		return 0
	fi

	# Check if already extracted TODO
	#CT_TestOrAbort "'${basename}' is not yet extracted while attempting to patch" -e "${CT_SRC_DIR}/_${basename}.extracted"

	[ "${nochdir}" = "nochdir" ] || CT_Pushd "${CT_SRC_DIR}/${basename}"

	official_patch_dir="${CT_TOP_DIR}/patches/${base_file}/${ver_file}"
	pkg_patch_dir="${base_dir}/${ver_file}/patches"
	arch_patch_dir="${base_dir}/${CT_ARCH}/${ver_file}/patches/"

	CT_DoLog EXTRA "Patching '${basename}' using patches from ${arch_patch_dir} ${pkg_patch_dir} ${official_patch_dir}"

	if [ -f "${arch_patch_dir}/patch.sh" ] ; then
		CT_DoLog EXTRA "patch found"
		sleep 2
		source "${arch_patch_dir}/patch.sh"
	else
		for patch_dir in "${official_patch_dir}" "${pkg_patch_dir}"  "${arch_patch_dir}" ; do
			if [ -n "${patch_dir}" -a -d "${patch_dir}" ]; then
			for p in "${patch_dir}"/*.patch; do
				if [ -f "${p}" ]; then
					CT_SubPatch "${p}"
				fi
			done
			for p in "${patch_dir}"/*.git; do
				if [ -f "${p}" ]; then
					CT_SubGitApply "${p}"
				fi
			done
			fi
		done
	fi

	if [ "${CT_OVERIDE_CONFIG_GUESS_SUB}" = "y" ]; then
		CT_DoLog ALL "Overiding config.guess and config.sub"
		for cfg in config_guess config_sub; do
			eval ${cfg}="${CT_LIB_DIR}/${cfg/_/.}"
			[ -e "${CT_LIB_DIR}/${cfg/_/.}" ] && eval ${cfg}="${CT_LIB_DIR}/${cfg/_/.}"
			# Can't use CT_DoExecLog because of the '{} \;' to be passed un-mangled to find
			find . -type f -name "${cfg/_/.}" -exec cp -v "${!cfg}" {} \; |CT_DoLog ALL
		done
	fi

	touch "${CT_SRC_DIR}/_${basename}.patched"

	[ "${nochdir}" = "nochdir" ] || CT_Popd
}

# Two wrappers to call config.(guess|sub) either from CT_TOP_DIR or CT_LIB_DIR.
# Those from CT_TOP_DIR, if they exist, will be be more recent than those from CT_LIB_DIR.
CT_DoConfigGuess() {
	if [ -x "${CT_LIB_DIR}/config.guess" ]; then
		"${CT_LIB_DIR}/config.guess"
	#else
	#    "${CT_LIB_DIR}/scripts/config.guess"
	fi
}

CT_DoConfigSub() {
	if [ -x "${CT_LIB_DIR}/config.sub" ]; then
		"${CT_LIB_DIR}/config.sub" "$@"
	#else
	#    "${CT_LIB_DIR}/scripts/config.sub" "$@"
	fi
}

# Compute the target tuple from what is provided by the user
# Usage: CT_DoBuildTargetTuple
# In fact this function takes the environment variables to build the target
# tuple. It is needed both by the normal build sequence, as well as the
# sample saving sequence.
CT_DoBuildTargetTuple() {
	# Set the endianness suffix, and the default endianness gcc option
	case "${CT_ARCH_BE},${CT_ARCH_LE}" in
		y,) target_endian_eb=eb
			target_endian_el=
			CT_ARCH_ENDIAN_CFLAG="-mbig-endian"
			CT_ARCH_ENDIAN_LDFLAG="-EB"
			;;
		,y) target_endian_eb=
			target_endian_el=el
			CT_ARCH_ENDIAN_CFLAG="-mlittle-endian"
			CT_ARCH_ENDIAN_LDFLAG="-EL"
			;;
	esac

	# Build the default architecture tuple part
	CT_TARGET_ARCH="${CT_ARCH}"

	# Set defaults for the system part of the tuple. Can be overriden
	# by architecture-specific values.
	case "${CT_LIBC}" in
		none)   CT_TARGET_SYS=elf;;
		*glibc) CT_TARGET_SYS=gnu;;
		uClibc) CT_TARGET_SYS=uclibc;;
		eglibc) CT_TARGET_SYS=eglibc;;
		newlib) CT_TARGET_SYS=newlib;;
	esac

	# Transform the ARCH into a kernel-understandable ARCH
	CT_KERNEL_ARCH="${CT_ARCH}"

	# Set the default values for ARCH, ABI, CPU, TUNE, FPU and FLOAT
	unset CT_ARCH_ARCH_CFLAG CT_ARCH_ABI_CFLAG CT_ARCH_CPU_CFLAG CT_ARCH_TUNE_CFLAG CT_ARCH_FPU_CFLAG CT_ARCH_FLOAT_CFLAG
	unset CT_ARCH_WITH_ARCH CT_ARCH_WITH_ABI CT_ARCH_WITH_CPU CT_ARCH_WITH_TUNE CT_ARCH_WITH_FPU CT_ARCH_WITH_FLOAT
	[ "${CT_ARCH_ARCH}"     ] && { CT_ARCH_ARCH_CFLAG="-march=${CT_ARCH_ARCH}";  CT_ARCH_WITH_ARCH="--with-arch=${CT_ARCH_ARCH}"; }
	[ "${CT_ARCH_ABI}"      ] && { CT_ARCH_ABI_CFLAG="-mabi=${CT_ARCH_ABI}";     CT_ARCH_WITH_ABI="--with-abi=${CT_ARCH_ABI}";    }
	[ "${CT_ARCH_CPU}"      ] && { CT_ARCH_CPU_CFLAG="-mcpu=${CT_ARCH_CPU}";     CT_ARCH_WITH_CPU="--with-cpu=${CT_ARCH_CPU}";    }
	[ "${CT_ARCH_TUNE}"     ] && { CT_ARCH_TUNE_CFLAG="-mtune=${CT_ARCH_TUNE}";  CT_ARCH_WITH_TUNE="--with-tune=${CT_ARCH_TUNE}"; }
	[ "${CT_ARCH_FPU}"      ] && { CT_ARCH_FPU_CFLAG="-mfpu=${CT_ARCH_FPU}";     CT_ARCH_WITH_FPU="--with-fpu=${CT_ARCH_FPU}";    }
	[ "${CT_ARCH_FLOAT_SW}" ] && { CT_ARCH_FLOAT_CFLAG="-msoft-float";           CT_ARCH_WITH_FLOAT="--with-float=soft";          }

	# Build the default kernel tuple part
	CT_TARGET_KERNEL="${CT_KERNEL}"

	# Overide the default values with the components specific settings
	CT_DoArchTupleValues
	CT_DoKernelTupleValues

	# Finish the target tuple construction
	CT_TARGET="${CT_TARGET_ARCH}-${CT_TARGET_KERNEL}${CT_TARGET_KERNEL:+-}${CT_TARGET_SYS}"

	# Sanity checks
	__sed_alias=""
	if [ -n "${CT_TARGET_ALIAS_SED_EXPR}" ]; then
		__sed_alias=$(echo "${CT_TARGET}" | ${sed} -r -e "${CT_TARGET_ALIAS_SED_EXPR}")
	fi
	case ":${CT_TARGET_VENDOR}:${CT_TARGET_ALIAS}:${__sed_alias}:" in
	  :*" "*:*:*:) CT_Abort "Don't use spaces in the vendor string, it breaks things.";;
	  :*"-"*:*:*:) CT_Abort "Don't use dashes in the vendor string, it breaks things.";;
	  :*:*" "*:*:) CT_Abort "Don't use spaces in the target alias, it breaks things.";;
	  :*:*:*" "*:) CT_Abort "Don't use spaces in the target sed transform, it breaks things.";;
	esac

	# Canonicalise it
	CT_TARGET=$(CT_DoConfigSub "${CT_TARGET}")

	# Prepare the target CFLAGS
	CT_ARCH_TARGET_CFLAGS="${CT_ARCH_TARGET_CFLAGS} ${CT_ARCH_ENDIAN_CFLAG}"
	CT_ARCH_TARGET_CFLAGS="${CT_ARCH_TARGET_CFLAGS} ${CT_ARCH_ARCH_CFLAG}"
	CT_ARCH_TARGET_CFLAGS="${CT_ARCH_TARGET_CFLAGS} ${CT_ARCH_ABI_CFLAG}"
	CT_ARCH_TARGET_CFLAGS="${CT_ARCH_TARGET_CFLAGS} ${CT_ARCH_CPU_CFLAG}"
	CT_ARCH_TARGET_CFLAGS="${CT_ARCH_TARGET_CFLAGS} ${CT_ARCH_TUNE_CFLAG}"
	CT_ARCH_TARGET_CFLAGS="${CT_ARCH_TARGET_CFLAGS} ${CT_ARCH_FPU_CFLAG}"
	CT_ARCH_TARGET_CFLAGS="${CT_ARCH_TARGET_CFLAGS} ${CT_ARCH_FLOAT_CFLAG}"

	# Now on for the target LDFLAGS
	CT_ARCH_TARGET_LDFLAGS="${CT_ARCH_TARGET_LDFLAGS} ${CT_ARCH_ENDIAN_LDFLAG}"
}

# This function does pause the build until the user strikes "Return"
# Usage: CT_DoPause [optional_message]
CT_DoPause() {
	if [ "${CT_DEBUG_PAUSE_STEPS}" != "y" ]; then
	   return 0
	fi
	local foo
	local message="${1:-Pausing for your pleasure}"
	CT_DoLog INFO "${message}"
	read -p "Press 'Enter' to continue, or Ctrl-C to stop..." foo >&6
	return 0
}

# This function saves the state of the toolchain to be able to restart
# at any one point
# Usage: CT_DoSaveState <next_step_name>
CT_DoSaveState() {
	[ "${CT_DEBUG_CT_SAVE_STEPS}" = "y" ] || return 0
	local state_name="$1"
	local state_dir="${CT_STATE_DIR}/${state_name}"


	CT_DoLog ${CT_LOG_LEVEL_MAX} "Saving state to restart at step '${state_name}'..."

	rm -rf "${state_dir}"
	mkdir -p "${state_dir}"

	case "${CT_DEBUG_CT_SAVE_STEPS_GZIP}" in
		y)  tar_opt=z; tar_ext=.gz;;
		*)  tar_opt=;  tar_ext=;;
	esac

	CT_DoLog DEBUG "  Saving environment and aliases"
	# We must omit shell functions, and some specific bash variables
	# that break when restoring the environment, later. We could do
	# all the processing in the awk script, but a sed is easier...
	set | ${awk} '
			  BEGIN { _p = 1; }
			  $0~/^[^ ]+ \(\)/ { _p = 0; }
			  _p == 1
			  $0 == "}" { _p = 1; }
			  ' | ${sed} -r -e '/^BASH_(ARGC|ARGV|LINENO|SOURCE|VERSINFO)=/d;
				           /^(UID|EUID)=/d;
				           /^(FUNCNAME|GROUPS|PPID|SHELLOPTS)=/d;' >"${state_dir}/env.sh"

	CT_DoLog DEBUG "  Saving CT_CC_CORE_STATIC_PREFIX_DIR='${CT_CC_CORE_STATIC_PREFIX_DIR}'"
	CT_Pushd "${CT_CC_CORE_STATIC_PREFIX_DIR}"
	CT_DoExecLog DEBUG ${tar} cv${tar_opt}f "${state_dir}/cc_core_static_prefix_dir.tar${tar_ext}" . > /dev/null
	CT_Popd

	CT_DoLog DEBUG "  Saving CT_CC_CORE_SHARED_PREFIX_DIR='${CT_CC_CORE_SHARED_PREFIX_DIR}'"
	CT_Pushd "${CT_CC_CORE_SHARED_PREFIX_DIR}"
	CT_DoExecLog DEBUG ${tar} cv${tar_opt}f "${state_dir}/cc_core_shared_prefix_dir.tar${tar_ext}" . > /dev/null
	CT_Popd

	CT_DoLog DEBUG "  Saving CT_PREFIX_DIR='${CT_PREFIX_DIR}'"
	CT_Pushd "${CT_PREFIX_DIR}"
	CT_DoExecLog DEBUG ${tar} cv${tar_opt}f "${state_dir}/prefix_dir.tar${tar_ext}" --exclude '*.log' .
	CT_Popd

	if [ "${CT_LOG_TO_FILE}" = "y" ]; then
		CT_DoLog DEBUG "  Saving log file"
		exec >/dev/null
		case "${CT_DEBUG_CT_SAVE_STEPS_GZIP}" in
			y)  ${gzip} -3 -c "${CT_LOG_FILE}"  >"${state_dir}/log.gz";;
			*)  ${cat} "${CT_LOG_FILE}" >"${state_dir}/log";;
		esac
		exec >>"${CT_LOG_FILE}"
	fi
}

# This function restores a previously saved state
# Usage: CT_DoLoadState <state_name>
CT_DoLoadState(){
	local state_name="$1"
	local state_dir="${CT_STATE_DIR}/${state_name}"
	local old_RESTART="${CT_RESTART}"
	local old_STOP="${CT_STOP}"

	CT_TestOrAbort "LoadState: Option 'Save intermediate steps' NOT enabled" -d "${CT_STATE_DIR}" -a -n "${CT_DEBUG_CT_SAVE_STEPS}"
	CT_TestOrAbort "The previous build did not reach the point where it could be restarted at '${CT_RESTART}'" -d "${state_dir}"

	# We need to do something special with the log file!
	if [ "${CT_LOG_TO_FILE}" = "y" ]; then
		exec >"${state_dir}/tail.log"
	fi


	CT_DoLog ${CT_LOG_LEVEL_MAX} "Restoring state at step '${state_name}', as requested."

	case "${CT_DEBUG_CT_SAVE_STEPS_GZIP}" in
		y)  tar_opt=z; tar_ext=.gz;;
		*)  tar_opt=;  tar_ext=;;
	esac

	CT_DoLog DEBUG "  Removing previous build directories"
	CT_DoExecLog ALL chmod -R u+rwX "${CT_PREFIX_DIR}" "${CT_CC_CORE_SHARED_PREFIX_DIR}" "${CT_CC_CORE_STATIC_PREFIX_DIR}"
	CT_DoForceRmdir             "${CT_PREFIX_DIR}" "${CT_CC_CORE_SHARED_PREFIX_DIR}" "${CT_CC_CORE_STATIC_PREFIX_DIR}"
	CT_DoExecLog DEBUG mkdir -p "${CT_PREFIX_DIR}" "${CT_CC_CORE_SHARED_PREFIX_DIR}" "${CT_CC_CORE_STATIC_PREFIX_DIR}"

	CT_DoLog DEBUG "  Restoring CT_PREFIX_DIR='${CT_PREFIX_DIR}'"
	CT_Pushd "${CT_PREFIX_DIR}"
	CT_DoExecLog DEBUG ${tar} xv${tar_opt}f "${state_dir}/prefix_dir.tar${tar_ext}" > /dev/null
	CT_Popd

	CT_DoLog DEBUG "  Restoring CT_CC_CORE_SHARED_PREFIX_DIR='${CT_CC_CORE_SHARED_PREFIX_DIR}'"
	CT_Pushd "${CT_CC_CORE_SHARED_PREFIX_DIR}"
	CT_DoExecLog DEBUG ${tar} xv${tar_opt}f "${state_dir}/cc_core_shared_prefix_dir.tar${tar_ext}" > /dev/null
	CT_Popd

	CT_DoLog DEBUG "  Restoring CT_CC_CORE_STATIC_PREFIX_DIR='${CT_CC_CORE_STATIC_PREFIX_DIR}'"
	CT_Pushd "${CT_CC_CORE_STATIC_PREFIX_DIR}"
	CT_DoExecLog DEBUG ${tar} xv${tar_opt}f "${state_dir}/cc_core_static_prefix_dir.tar${tar_ext}" > /dev/null
	CT_Popd

	# Restore the environment, discarding any error message
	# (for example, read-only bash internals)
	CT_DoLog DEBUG "  Restoring environment"
	. "${state_dir}/env.sh" >/dev/null 2>&1 || true

	# Restore the new RESTART and STOP steps
	CT_RESTART="${old_RESTART}"
	CT_STOP="${old_STOP}"
	unset old_stop old_restart

	if [ "${CT_LOG_TO_FILE}" = "y" ]; then
		CT_DoLog DEBUG "  Restoring log file"
		exec >/dev/null
		case "${CT_DEBUG_CT_SAVE_STEPS_GZIP}" in
			y)  ${zcat} "${state_dir}/log.gz" >"${CT_LOG_FILE}";;
			*)  ${cat} "${state_dir}/log" >"${CT_LOG_FILE}";;
		esac
		${cat} "${state_dir}/tail.log" >>"${CT_LOG_FILE}"
		exec >>"${CT_LOG_FILE}"
		rm -f "${state_dir}/tail.log"
	fi
}

CT_Source() {
	if [ ! -f "$1" ] ; then
		CT_DoLog ALL "Unable to source $1"
		exit
	fi
	source $1
}
