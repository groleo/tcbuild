.file	"bcopy.S"
.text
/*
 * bcopy(src, dest, len)
 * Works for counts up to 128K.
 */
.globl          bcopy
.type           bcopy,@function
.align 4
bcopy:
	movl	%sp@(12),%d0		| get len
	movl	%sp@(8),%a1		| dest address
	movl	%sp@(4),%a0		| src address

	move.l	%d0, -(%sp)		| 3rd parameter
	move.l	%a0, -(%sp)		| 2nd parameter
	move.l	%a1, -(%sp)		| 1st parameter

	jsr memmove
	addq.l #8,%sp
	addq.l #4,%sp
	rts

.size bcopy,.-bcopy
