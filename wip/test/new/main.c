#include <string.h>
#include <stdio.h>
#include <stdlib.h>
//void memmove(const void *dest, void *src, size_t n);
//void memcpy(const void *dest, void *src, size_t n);
//void bcopy(void*src,const void *dest, size_t n);

#define memmove memmove
#define memcpy memcpy
#define bcopy bcopy


void lmbench_fcp(const void* _dest,void* _src,size_t n)
{
	register int* src = _src;
	register int* dest = _dest ;
	register int*  lastone=_src+n;
	while (src <= lastone) {
#define	DOIT(i)	dest[i]=src[i];
		DOIT(0) DOIT(1) DOIT(2) DOIT(3) DOIT(4) DOIT(5) DOIT(6)
		DOIT(7) DOIT(8) DOIT(9) DOIT(10) DOIT(11) DOIT(12)
		DOIT(13) DOIT(14) DOIT(15) DOIT(16) DOIT(17) DOIT(18)
		DOIT(19) DOIT(20) DOIT(21) DOIT(22) DOIT(23) DOIT(24)
		DOIT(25) DOIT(26) DOIT(27) DOIT(28) DOIT(29) DOIT(30)
		DOIT(31) DOIT(32) DOIT(33) DOIT(34) DOIT(35) DOIT(36)
		DOIT(37) DOIT(38) DOIT(39) DOIT(40) DOIT(41) DOIT(42)
		DOIT(43) DOIT(44) DOIT(45) DOIT(46) DOIT(47) DOIT(48)
		DOIT(49) DOIT(50) DOIT(51) DOIT(52) DOIT(53) DOIT(54)
		DOIT(55) DOIT(56) DOIT(57) DOIT(58) DOIT(59) DOIT(60)
		DOIT(61) DOIT(62) DOIT(63) DOIT(64) DOIT(65) DOIT(66)
		DOIT(67) DOIT(68) DOIT(69) DOIT(70) DOIT(71) DOIT(72)
		DOIT(73) DOIT(74) DOIT(75) DOIT(76) DOIT(77) DOIT(78)
		DOIT(79) DOIT(80) DOIT(81) DOIT(82) DOIT(83) DOIT(84)
		DOIT(85) DOIT(86) DOIT(87) DOIT(88) DOIT(89) DOIT(90)
		DOIT(91) DOIT(92) DOIT(93) DOIT(94) DOIT(95) DOIT(96)
		DOIT(97) DOIT(98) DOIT(99) DOIT(100) DOIT(101) DOIT(102)
		DOIT(103) DOIT(104) DOIT(105) DOIT(106) DOIT(107)
		DOIT(108) DOIT(109) DOIT(110) DOIT(111) DOIT(112)
		DOIT(113) DOIT(114) DOIT(115) DOIT(116) DOIT(117)
		DOIT(118) DOIT(119) DOIT(120) DOIT(121) DOIT(122)
		DOIT(123) DOIT(124) DOIT(125) DOIT(126) DOIT(127)
		src += 128;
		dest += 128;
	}
}

char* getBuffer(size_t sz)
{
	char * src=calloc(sz,sizeof(char));
	int i;
	for (i=0;i<sz;++i) src[i]=i;
	return src;
}

int dummyFunc(int i,int k,int j) ;
void printBuf(char*buf,size_t sz)
{
	int i;
	for (i=0;i<sz;++i) printf("%X ",buf[i]);printf("\n");
}


int differ(char* d,const char*s,size_t sz)
{
	int i;
	for (i=0;i<sz;++i)
		if (d[i] != s[i])
		{
			printf("d[%p]:%x!=s[%p]:%x idx:%i\n",d+i,d[i],s+i,s[i],i);
			printBuf(d,5*i);
			printBuf(s,5*i);
			return 1;
		}
	return 0;
}
//#define differ(a,b,c) 0


int testBzero(char* src, size_t SIZE)
{
	bzero(src,SIZE);
}

int testMemmove(char * dst, char* src, size_t SIZE)
{
	void *p;
	int i,rv,j;

	p=memmove(dst,src,SIZE);
	printf("%s:%i:%p:%p\n",__FUNCTION__,SIZE,p,dst);
	rv=differ(dst,src,SIZE) ;

	//printf(" ok\n");
	return 0;
}
int testLmbenchFcp(char * dst, const char* src, size_t SIZE)
{
	int i,rv,j;

	//printf("%s:%i ",__FUNCTION__,SIZE);
	lmbench_fcp(dst,src,SIZE);
	rv=differ(dst,src,SIZE) ;

	//printf(" ok\n");
	return 0;
}
int testBcopy(char * dst, const char* src, size_t SIZE)
{
	int i,rv,j;

	//printf("%s:%i ",__FUNCTION__,SIZE);
	bcopy(src,dst,SIZE);
	rv=differ(dst,src,SIZE) ;

	//printf(" ok\n");
	return 0;
}
int testMemcpy(char * dst, const char* src, size_t SIZE)
{
	int i,rv,j;

	memcpy(dst,src,SIZE);
	rv=differ(dst,src,SIZE) ;

	//printf(" ok\n");
	return 0;
}

#define min(a,b) (a)<(b)?(a):(b)

int testMemmoveAlign(const char*ref,size_t SIZE)
{
	int rv,j;
	for ( j=1;j<SIZE;++j)
	{
		char *src=getBuffer(SIZE+1);

		printf("%s:%p,%p,%i,%i\n",__FUNCTION__,src+j,src,SIZE-j,j);
		   memmove(src+j, src, SIZE-j);
		rv=differ( src+j, src,min(j,SIZE-j)) ;
		if ( rv )
		{
			printf("Error 2\n----------------------------------------\n");
			continue;
		}


		rv=differ( src+j, ref,SIZE-j) ;
		if ( rv ) printf("Error 3\n----------------------------------------\n");
		free(src);
		printf("\n");
	}
}
int testBcopyAlign(const char*ref,size_t SIZE)
{
	int rv,j;
	for ( j=1;j<SIZE;++j)
	{
		char *src=getBuffer(SIZE+1);

		printf("%s:%p,%p,%i,%i\n",__FUNCTION__,src+j,src,SIZE-j,j);
		bcopy(src, src+j, SIZE-j);

		rv=differ( src+j, src,min(j,SIZE-j)) ;
		if ( rv )
		{
			printf("Error 2\n----------------------------------------\n");
			continue;
		}

		rv=differ( src+j, ref,SIZE-j) ;
		if ( rv ) printf("Error 3\n----------------------------------------\n");
		free(src);
		printf("\n");
	}
}
int testMemcpyAlign(const char*ref,size_t SIZE)
{
	int rv,j;
	for ( j=1;j<SIZE;++j)
	{
		char *src=getBuffer(SIZE+1);

		printf("%s:%p,%p,%i,%i\n",__FUNCTION__,src+j,src,SIZE-j,j);
		  memcpy(src+j, src, SIZE-j);
		rv=differ(src+j, src, min(j,SIZE-j) ) ;
		if ( rv )
		{
			printf("Error 2\n----------------------------------------\n");
			continue;
		}

		rv=differ( src+j, ref,SIZE-j) ;
		if ( rv ) printf("Error 3\n----------------------------------------\n");
		free(src);
		printf("\n");
	}
}

struct timeval tvstart,tvstop;
#define TIME(it,a) \
gettimeofday(&tvstart,NULL);\
for(i=it;i>0;--i) a;\
gettimeofday(&tvstop,NULL);\
printf("%i\n",tvstop.tv_sec*1000000+tvstop.tv_usec-(tvstart.tv_sec*1000000+tvstart.tv_usec) );


#define ALIGN(a,b) (a-((a)%(b)))


int dummyFrame(int b, int a,int c, int d, int e)
{
	printf("Dummy test %i %i\n",b,a);
}

int main()
{
	//#define TEST_SZ (48*50000)
	#define TEST_SZ ALIGN(3*1024*1024,48)
	int i;
	char * src=getBuffer(TEST_SZ+1);
	char * dst=calloc(TEST_SZ+1,sizeof(char));
#define ITERATIONS 1

//	TIME( 10, testMemcpy(dst, src,TEST_SZ) );
//	dummyFrame(TEST_SZ,tvstart.tv_sec,tvstart.tv_sec,tvstart.tv_sec,tvstart.tv_sec);
//	TIME( ITERATIONS, testBcopy(dst, src,TEST_SZ) );
//	TIME( ITERATIONS, testMemmove(dst, src, TEST_SZ) );

	TIME( ITERATIONS, testBzero( src, TEST_SZ) );
	//TIME( ITERATIONS, testMemcpyAlign( src, TEST_SZ) );
	//TIME( ITERATIONS, testBcopyAlign( src, TEST_SZ) );
	//TIME( ITERATIONS, testMemmoveAlign( src, TEST_SZ) );
	free(src);
	free(dst);
}
