
CT_DoArchTupleValues() {
    # The architecture part of the tuple:
    CT_TARGET_ARCH="${CT_ARCH}${target_endian_eb}"
	CT_ARCH_ENDIAN_CFLAG=-mb
    # The system part of the tuple:

    CT_TestOrAbort "Internal error: CT_ARCH_ABI should not be set for EABI build." -z "${CT_ARCH_ABI}" -o -z "${CT_ARCH_ARM_EABI}"
}
