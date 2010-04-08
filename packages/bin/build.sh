PKG_NAME=bin
PKG_URL=
PKG_SRC=

do_bin_get() {
	:
}

do_bin_extract() {
	:
}

do_bin() {
    CT_DoStep INFO "INSTALL ${PKG_NAME}"

    mkdir -p "${CT_BUILD_DIR}/${PKG_SRC}"
    CT_Pushd "${CT_FS_DIR}"

    # this will hit the fan when more binary packages will be included
    # in the filesystem, and we will have to choose between them depending
    # on the preferences
    tar xzvf "${CT_PKG_DIR}/${PKG_NAME}/openvpn/bin.tar.gz"

    CT_Popd
    CT_EndStep
}
