#include <string.h>
#include <stdio.h>
#include <stdlib.h>
void my_memmove(const void *dest, void *src, size_t n);
void my_memcpy(const void *dest, void *src, size_t n);
void my_bcopy(void*src,const void *dest, size_t n);

//#define my_memmove memmove


char* getBuffer(size_t sz)
{
	char * src=calloc(sz,sizeof(char));
	int i;
	for (i=0;i<sz;++i) src[i]=i;
	return src;
}

void printBuf(char*buf,size_t sz)
{
	int i;
	for (i=0;i<sz;++i) printf("%X ",buf[i]);printf("\n");
}


int dummyFunc(int i,int k,int j)
{
	int a,b,c;
	a=k;
	b=i;
	c=j;
	return c+a;
}

int differ(char* d,char*s,size_t sz)
{
	int i;
	for (i=0;i<sz;++i)
		if (d[i]!=s[i])
		{
			printf("d[%p]:%x!=s[%p]:%x idx:%i\n",d+i,d[i],s+i,s[i],i);
			printBuf(d,sz);
			printf("\n");
			printBuf(s,sz);
			return 1;
		}
	return 0;
}

int testMemmove(size_t SIZE)
{
	int i,rv,j;
	char * src=getBuffer(SIZE+1);
	char * dst=calloc(SIZE+1,sizeof(char));

	printf("testSize:%i\n",SIZE);
	my_memmove(dst,src,SIZE);
	rv=differ(dst,src,SIZE) ;
	if ( rv ) printf("Error 1\n");

	free(src);
	free(dst);
	return 0;
}
int testMemcpy(size_t SIZE)
{
	int i,rv,j;
	char * src=getBuffer(SIZE+1);
	char * dst=calloc(SIZE+1,sizeof(char));

	printf("testSize:%i\n",SIZE);
	my_memcpy(dst,src,SIZE);
	rv=differ(dst,src,SIZE) ;
	if ( rv ) printf("Error 1\n");

	free(src);
	free(dst);
	return 0;
}

#define min(a,b) (a)<(b)?(a):(b)

int testMemmoveAlign(size_t SIZE)
{
	int rv,j;
	for ( j=1;j<SIZE;++j)
	{
		char *src=getBuffer(SIZE+1);
		char *ref=getBuffer(SIZE+1);

		printf("testAlign:%p,%p,%i,%i\n",src+j,src,SIZE-j,j);
		my_memmove(src+j, src, SIZE-j);

		rv=differ( src+j, src,min(j,SIZE-j)) ;
		if ( rv ) printf("Error 2\n----------------------------------------\n");

		rv=differ( src+j, ref,SIZE-j) ;
		if ( rv ) printf("Error 3\n----------------------------------------\n");
		free(src);
		free(ref);
		printf("\n");
	}
}
int testBcopyAlign(size_t SIZE)
{
	int rv,j;
	for ( j=1;j<SIZE;++j)
	{
		char *src=getBuffer(SIZE+1);
		char *ref=getBuffer(SIZE+1);

		printf("testAlign:%p,%p,%i,%i\n",src+j,src,SIZE-j,j);
		my_bcopy(src, src+j, SIZE-j);

		rv=differ( src+j, src,min(j,SIZE-j)) ;
		if ( rv ) printf("Error 2\n----------------------------------------\n");

		rv=differ( src+j, ref,SIZE-j) ;
		if ( rv ) printf("Error 3\n----------------------------------------\n");
		free(src);
		free(ref);
		printf("\n");
	}
}

int main()
{
#define TEST_SZ (1024)
	int i;

	for (i=TEST_SZ;i>0;--i)
	{
//		testMemmoveAlign(i);
//		testBcopyAlign(i);
		testMemcpy(i);
	}
}
