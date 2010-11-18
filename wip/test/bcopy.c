#include <string.h>
#define libc_hidden_def(a)
void bcopy(const void*src, void*dest,size_t len)
{
	memmove(dest,src,len);
}
