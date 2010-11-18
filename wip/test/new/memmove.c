#include <string.h>

void* memmove(void*dest, const void*src,size_t len)
{
	__asm__ volatile(
	"	movl	16(%fp),%d0		/* get len */\n"
	"	jeq	Lmemmove_exit		/* if len==0, return */\n"
	"	movl	12(%fp),%a0		/* get src address */\n"
	"	movl	8(%fp),%a1		/* get dest address */\n"

	"	cmp.l	%a1,%a0			/* Quick abort for src=dst */\n"
	"	jeq	Lmemmove_exit\n"

	"	lea -12*4(%sp),%sp		/* Save regs */\n"
	"	movem.l %d1-%d7/%a2-%a6,(%sp)	/* Save regs */\n"

	"	cmpl	%a1,%a0			/* src before dest? */\n"
	"	jlt	Lmemmove_Backwards	/* to avoid overlap */\n"

	"	movl	%a0,%d1\n"
	"	btst	#0,%d1			/* src address unaligned? */\n"
	"	jeq	Lmemmove_Forward	/* no, go check dest */\n"
	"	movb	%a0@+,%a1@+		/* yes, copy 1 byte */\n"
	"	subql	#1,%d0			/* update len */\n"
	"	jeq	Lmemmove_exit		/* exit if done */\n"
	"Lmemmove_Forward:\n"
	"	movl	%a1,%d1\n"
	"	btst	#0,%d1			/* dest address unaligned? */\n"
	"	jne	Lmemmove_F1		/* yes, must copy 1 byte at a time */\n"
	"Lmemmove_FM:\n"
	"	cmpi.l #48,%d0			/*  len ? 48( 12regs * 4bytes)	*/\n"
	"	jlt Lmemmove_F4			/*  IF (len-48) < 0 GOTO 2f; ELSE*/\n"
	"	movem.l (%a0),%d1-%d7/%a2-%a6	/*  move *src to regs		*/\n"
	"	movem.l %d1-%d7/%a2-%a6,(%a1)	/*  7cfe move regs to *dest	*/\n"
	"	lea.l (48,%a0),%a0		/*  src  = src + 48		*/\n"
	"	lea.l (48,%a1),%a1		/*  dest = dest+ 48			*/\n"
	"	subi.l #48,%d0			/*  n -= 48			*/\n"
	"	jra Lmemmove_FM		/*  one more iteration		*/\n"
	"\n"
	"Lmemmove_F4:\n"
	"	cmpi.l #4, %d0			/*  Copy in 4 bytes chunks?	*/\n"
	"	jlt Lmemmove_F2			/*  No, THEN GOTO 3f	*/\n"
	"	move.l (%a0),%d1		/*  move *src to reg		*/\n"
	"	move.l %d1,(%a1)		/*  move reg to *dest		*/\n"
	"	lea.l (4,%a0),%a0		/*  src  = src + 4		*/\n"
	"	lea.l (4,%a1),%a1		/*  dest = dest+ 4		*/\n"
	"	subq.l #4,%d0			/*  len -= 4			*/\n"
	"	jra Lmemmove_F4			/*  one more iteration		*/\n"
	"Lmemmove_F2:\n"
	"	cmpi.l #2, %d0			/*  Copy in 2 bytes chunks?	*/\n"
	"	jlt Lmemmove_F1			/*  No, THEN GOTO 4f	*/\n"
	"	move.w (%a0),%d1		/*  move *src to reg;		*/\n"
	"	move.w %d1,(%a1)		/*  move reg to *dest;		*/\n"
	"	lea.l (2,%a0),%a0		/*  src  = src + 2		*/\n"
	"	lea.l (2,%a1),%a1		/*  dest = dest+ 2		*/\n"
	"	subq.l #2,%d0			/*  n -= 2			*/\n"
	"	jra Lmemmove_F2			/*  one more iteration	*/\n"
	"Lmemmove_F1:\n"
	"	tst.l %d0			/* IF n==0 THEN			*/\n"
	"	jeq Lmemmove_pop		/*  GOTO 5f			*/\n"
	"	move.b (%a0),%d1		/*  move *src to reg		*/\n"
	"	move.b %d1,(%a1)		/*  move reg to *dest		*/\n"
	"	lea.l (1,%a0),%a0		/*  src  = src + 1		*/\n"
	"	lea.l (1,%a1),%a1		/*  dest = dest+ 1		*/\n"
	"	subq.l #1,%d0			/*  n--				*/\n"
	"	jra Lmemmove_F1			/*  THEN GOTO 5f		*/\n"
	"\n"
	"Lmemmove_Backwards:\n"
	"	addl	%d0,%a0			/* src += len */\n"
	"	addl	%d0,%a1			/* dest+= len */\n"
	"	movl	%a0,%d1\n"
	"	btst	#0,%d1			/* src address odd? */\n"
	"	jeq	Lmemmove_Beven		/* no, go check dest */\n"
	"	movb	%a0@-,%a1@-		/* yes, copy a byte */\n"
	"	subql	#1,%d0			/* update len */\n"
	"	jeq	Lmemmove_exit		/* exit if done */\n"

	"Lmemmove_Beven:\n"
	"	movl	%a1,%d1\n"
	"	btst	#0,%d1			/* dest address odd? */\n"
	"	jne	 Lmemmove_B1		/* yes, must copy by bytes */\n"
	"Lmemmove_BM:\n"
	"	cmpi.l #48,%d0			/*  len ? 48( 12regs * 4bytes)	*/\n"
	"	jlt Lmemmove_B4			/*  IF (len-48) < 0 GOTO 2f; ELSE*/\n"
	"	lea.l (-12*4,%a0),%a0		/*  src  = src - 48		*/\n"
	"	lea.l (-12*4,%a1),%a1		/*  dest = dest- 48		*/\n"
	"	movem.l (%a0),%d1-%d7/%a2-%a6	/*  move *src to regs		*/\n"
	"	movem.l %d1-%d7/%a2-%a6,(%a1)	/*  move regs to *dest		*/\n"
	"	subi.l #48,%d0			/*  n -= 48			*/\n"
	"	jra Lmemmove_BM		/*  one more iteration		*/\n"
	"Lmemmove_B4:\n"
	"	cmpi.l #4, %d0			/*  Copy in 4 bytes chunks?*/\n"
	"	jlt Lmemmove_B2			/*  No, THEN GOTO 3f	*/\n"
	"	lea.l (-4,%a0),%a0		/*  src  = src - 4		*/\n"
	"	lea.l (-4,%a1),%a1		/*  dest = dest- 4			*/\n"
	"	move.l (%a0),%d1		/*  move *src to reg		*/\n"
	"	move.l %d1,(%a1)		/*  move reg to *dest		*/\n"
	"	subq.l #4,%d0			/*  n -= 4			*/\n"
	"	jra Lmemmove_B4			/*  one more iteration		*/\n"
	"Lmemmove_B2:\n"
	"	cmpi.l #2, %d0			/*  Copy in 2 bytes chunks?	*/\n"
	"	jlt Lmemmove_B1			/*  No, THEN GOTO 4f	*/\n"
	"	lea.l (-2,%a0),%a0		/*  src  = src - 2		*/\n"
	"	lea.l (-2,%a1),%a1		/*  dest = dest- 2			*/\n"
	"	move.w (%a0),%d1		/*  move *src to reg;		*/\n"
	"	move.w %d1,(%a1)		/*  move reg to *dest;		*/\n"
	"	subq.l #2,%d0			/*  n -= 2			*/\n"
	"	jra Lmemmove_B2			/*  one more iteration	*/\n"
	"Lmemmove_B1:\n"
	"	tst.l %d0			/* IF n==0 THEN			*/\n"
	"	jeq Lmemmove_pop		/*  GOTO 5f			*/\n"
	"	lea.l (-1,%a0),%a0		/*  src  = src - 1		*/\n"
	"	lea.l (-1,%a1),%a1		/*  dest = dest- 1			*/\n"
	"	move.b (%a0),%d1		/*  move *src to reg		*/\n"
	"	move.b %d1,(%a1)		/*  move reg to *dest		*/\n"
	"	subq.l #1,%d0			/*  n--				*/\n"
	"	jra Lmemmove_B1			/*  THEN GOTO 5f		*/\n"
	"Lmemmove_pop:\n"
	"	movem.l (%sp),%d1-%d7/%a2-%a6\n"
	"	lea 12*4(%sp),%sp\n"
	"Lmemmove_exit:");
	return dest;
}
libc_hidden_def(memmove)
#if 0
	unlk %fp
	move.l %a1, %a0
	move.l %a0, %d0
	rts

.size memmove, .-memmove
//libc_hidden_def(memmove)
linkw %fp,#0
movel %fp@(16),%d0
moveal %fp@(12),%a1
moveal %fp@(8),%a0
bras 20f0e <mempcpy+0x16>
moveb %a1@+,%a0@+
subql #1,%d0
tstl %d0
bnes 20f0a <mempcpy+0x12>
unlk %fp
movel %a0,%d0
rts
#endif
