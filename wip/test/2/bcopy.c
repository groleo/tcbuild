#include <string.h>
void bcopy(const void*src, void*dest,size_t len)
{
	memmove(dest,src,len);
}
