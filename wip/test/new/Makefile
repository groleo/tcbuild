CC=/opt/test/m68k-unknown-linux-uclibc/bin/m68k-unknown-linux-uclibc-gcc
all:
	$(CC) main.c
	#$(CC) -include timmy.h -O0 torture-2.c memmove.c bcopy.c memcpy.c
	#$(CC) -include timmy.h -O0 test-memmove.c memmove.c bcopy.c memcpy.c
	#$(CC) -include timmy.h -O0 main.c memmove.c bcopy.c memcpy.c bzero.c
	#$(CC) memcmp-bench.c -o memcmp
	scp a.out memcmp test@10.32.0.170:~/mariusn/
