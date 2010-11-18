.file	"memmove.S"
.text
/*
 * memmove(dest, src, len)
 * Works for lens up to 128K.
 */
.globl          memmove
.type           memmove,@function
.align 4
memmove:
	movl	%sp@(12),%d0		/* get len */
	jeq	Lmemmove_exit		/* if zero, return */
	movl	%sp@(8),%a0		/* src address */
	movl	%sp@(4),%a1		/* dest address */

	cmp.l	%a1,%a0			/* Quick abort for src=dst */
	jeq	Lmemmove_exit

	/* Determine copy direction */
	cmpl	%a1,%a0			/* src before dest? */
	jlt	Lmemmove_Backwards	/* yes, avoid overlap */

	movl	%a0,%d1
	btst	#0,%d1			/* src address unaligned? */
	jeq	Lmemmove_Forward	/* no, go check dest */
	movb	%a0@+,%a1@+		/* yes, copy 1 byte */
	subql	#1,%d0			/* update len */
	jeq	Lmemmove_exit		/* exit if done */
Lmemmove_Forward:
	movl	%a1,%d1
	btst	#0,%d1			/* dest address unaligned? */
	jne	Lmemmove_Fbloop		/* yes, must copy 1 byte at a time */
	movl	%d0,%d1			/* no, get len */
	lsrl	#2,%d1			/* convert to longwords */
	jeq	Lmemmove_Fbloop		/* no longwords, copy bytes */

Lmemmove_Flloop:
	movl	%a0@+,%a1@+		/* copy 4 bytes at a time */
	subql	#1,%d1
	jne	Lmemmove_Flloop
	andl	#3,%d0			/* get remaining len */
	jeq	Lmemmove_exit		/* done if none */
Lmemmove_Fbloop:
	movb	%a0@+,%a1@+		/* copy 1 byte at a time */
	subql	#1,%d0
	jne	Lmemmove_Fbloop
Lmemmove_Backwards:
	addl	%d0,%a0			/* add len to src */
	addl	%d0,%a1			/* add len to dest */
	movl	%a0,%d1
	btst	#0,%d1			/* src address odd? */
	jeq	Lmemmove_Beven		/* no, go check dest */
	movb	%a0@-,%a1@-		/* yes, copy a byte */
	subql	#1,%d0			/* update len */
	jeq	Lmemmove_exit		/* exit if done */

Lmemmove_Beven:
	movl	%a1,%d1
	btst	#0,%d1			/* dest address odd? */
	jne	 Lmemmove_Bbloop	/* yes, must copy by bytes */
	movl	%d0,%d1			/* no, get len */
	lsrl	#2,%d1			/* convert to longwords */
	jeq	 Lmemmove_Bbloop	/* no longwords, copy bytes */

Lmemmove_Blloop:
	movl	%a0@-,%a1@-		/* copy longwords */
	subql	#1,%d1
	jne	Lmemmove_Blloop
	andl	#3,%d0			/* get remaining len */
	jeq	Lmemmove_exit		/* done if none */

Lmemmove_Bbloop:
	movb	%a0@-,%a1@-		/* copy 1 byte at a time */
	subql	#1,%d0
	jne	Lmemmove_Bbloop
	rts
