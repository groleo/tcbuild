#include <string.h>
void memcpy(void*dest, const void*src,size_t lenn)
{
	memmove(dest,src,len);
}
libc_hidden_def(memmove)
