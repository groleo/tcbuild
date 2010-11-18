#include <features.h>
.file	"memmove.S"
.text
/*
 * memmove(dest, src, len)
 * Works for lens up to 128K.
 */
.align 4
.globl          memmove
.type           memmove,@function
memmove:
	movl	%sp@(12),%d0		/* get len */
	jeq	Lmemmove_exit		/* if zero, return */

	movl	%sp@(8),%a0		/* src address */
	movl	%sp@(4),%a1		/* dest address */

	cmp.l	%a1,%a0			/* Quick abort for src=dst */
	jeq	Lmemmove_exit

	lea -12*4(%sp),%sp
	movem.l %d1-%d7/%a2-%a6,(%sp)

	/* Determine copy direction */
	movl	%a0,%a2
	addl	%d0,%a2
	cmpl	%a2,%a1		/* if ( dest-(src+len) ) < 0 copy backward */
	jlt	Lmemmove_Backwards	 | yes, avoid overlap
Lmemmove_Forward:
Lmemmove_F40:
	cmpi.l #48,%d0			/*  len ? 40( 10regs * 4bytes)	*/
	jlt Lmemmove_pop		/*  IF (len-40) < 0 GOTO 2f; ELSE*/
	movem.l (%a0),%d1-%d7/%a2-%a6	/*  move *src to regs		*/
	movem.l %d1-%d7/%a2-%a6,(%a1)	/*  7cfe move regs to *dest	*/
	lea.l (48,%a0),%a0		/*  from = from + 40		*/
	lea.l (48,%a1),%a1		/*  to = to+40			*/
	subi.l #48,%d0			/*  n -= 40			*/
	jmp Lmemmove_F40		/*  one more iteration		*/

Lmemmove_F4:
	cmpi.l #4, %d0			/*  Can  copy in 4 bytes chunks?*/
	jlt Lmemmove_F2			/*  No, THEN GOTO 3f	*/
	move.l (%a0),%d1		/*  move *src to reg		*/
	move.l %d1,(%a1)		/*  move reg to *dest		*/
	lea.l (4,%a0),%a0		/*  from = from + 4		*/
	lea.l (4,%a1),%a1		/*  to = to + 4			*/
	subq.l #4,%d0			/*  n -= 4			*/
	jra Lmemmove_F4			/*  one more iteration		*/
Lmemmove_F2:
	cmpi.l #2, %d0			/* Can copy in 2 bytes chunks?	*/
	jlt Lmemmove_F1			/*  No, THEN GOTO 4f	*/
	move.w (%a0),%d1		/*  move *src to reg;		*/
	move.w %d1,(%a1)		/*  move reg to *dest;		*/
	lea.l (2,%a0),%a0		/*  from = from + 2		*/
	lea.l (2,%a1),%a1		/*  to = to+2			*/
	subq.l #2,%d0			/*  n -= 2			*/
	jra Lmemmove_F2			/*  one more iteration	*/
Lmemmove_F1:
	tst.l %d0			/* IF n==0 THEN			*/
	jeq Lmemmove_pop		/*  GOTO 5f			*/
	move.b (%a0),%d1		/*  move *src to reg		*/
	move.b %d1,(%a1)		/*  move reg to *dest		*/
	lea.l (1,%a0),%a0		/*  from = from + 4		*/
	lea.l (1,%a1),%a1		/*  to = to+4			*/
	subq.l #1,%d0			/*  n--				*/
	jra Lmemmove_F1			/*  THEN GOTO 5f		*/

Lmemmove_Backwards:
	addl	%d0,%a0			/* add len to src */
	addl	%d0,%a1			/* add len to dest */
Lmemmove_B40:
	cmpi.l #40,%d0			/*  len ? 40( 10regs * 4bytes)	*/
	jlt Lmemmove_B4			/*  IF (len-40) < 0 GOTO 2f; ELSE*/
	lea.l (-10*4,%a0),%a0		/*  from = from - 40		*/
	lea.l (-10*4,%a1),%a1		/*  to = to - 40		*/
	movem.l (%a0),%d1-%d7/%a2-%a4	/*  move *src to regs		*/
	movem.l %d1-%d7/%a2-%a4,(%a1)	/*  move regs to *dest		*/
	subi.l #40,%d0			/*  n -= 40			*/
	jra Lmemmove_B40		/*  one more iteration		*/
Lmemmove_B4:
	cmpi.l #4, %d0			/*  Can  copy in 4 bytes chunks?*/
	jlt Lmemmove_B2			/*  No, THEN GOTO 3f	*/
	lea.l (-4,%a0),%a0		/*  from = from + 4		*/
	lea.l (-4,%a1),%a1		/*  to = to + 4			*/
	move.l (%a0),%d1		/*  move *src to reg		*/
	move.l %d1,(%a1)		/*  move reg to *dest		*/
	subq.l #4,%d0			/*  n -= 4			*/
	jra Lmemmove_B4			/*  one more iteration		*/
Lmemmove_B2:
	cmpi.l #2, %d0			/* Can copy in 2 bytes chunks?	*/
	jlt Lmemmove_B1			/*  No, THEN GOTO 4f	*/
	lea.l (-2,%a0),%a0		/*  from = from + 2		*/
	lea.l (-2,%a1),%a1		/*  to = to+2			*/
	move.w (%a0),%d1		/*  move *src to reg;		*/
	move.w %d1,(%a1)		/*  move reg to *dest;		*/
	subq.l #2,%d0			/*  n -= 2			*/
	jra Lmemmove_B2			/*  one more iteration	*/
Lmemmove_B1:
	tst.l %d0			/* IF n==0 THEN			*/
	jeq Lmemmove_pop		/*  GOTO 5f			*/
	lea.l (-1,%a0),%a0		/*  from = from + 4		*/
	lea.l (-1,%a1),%a1		/*  to = to+4			*/
	move.b (%a0),%d1		/*  move *src to reg		*/
	move.b %d1,(%a1)		/*  move reg to *dest		*/
	subq.l #1,%d0			/*  n--				*/
	jra Lmemmove_B1			/*  THEN GOTO 5f		*/
Lmemmove_pop:
	movem.l (%sp),%d1-%d7/%a2-%a6
	lea 12*4(%sp),%sp
Lmemmove_exit:
	rts

.size memmove,.-memmove
//libc_hidden_def(memmove)
