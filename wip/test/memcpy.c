#include <string.h>
libc_hidden_proto(memcpy)
void* memcpy(void*dest, const void*src,size_t len)
{
	return memmove(dest,src,len);
}
libc_hidden_def(memcpy)
