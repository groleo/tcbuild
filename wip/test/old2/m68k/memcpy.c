#include <string.h>
void* memcpy(void*dest, const void*src,size_t len)
{
	return memmove(dest,src,len);
}
libc_hidden_def(memcpy)
