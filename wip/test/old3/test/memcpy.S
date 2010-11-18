.file	"memcpy.S"
.text
/*
 * memcpy(src, dest, len)
 * Works for counts up to 128K.
 */
.globl          my_memcpy
.type           my_memcpy,@function
.align 4
my_memcpy:
	movl	%sp@(12),%d0		| get len
	movl	%sp@(8),%a1		| dest address
	movl	%sp@(4),%a0		| src address

	move.l	%d0, -(%sp)		| 3rd parameter
	move.l	%a1, -(%sp)		| 2nd parameter
	move.l	%a0, -(%sp)		| 1st parameter

	jsr my_memmove
	addq.l #8,%sp
	addq.l #4,%sp
	rts

.size my_memcpy,.-my_memcpy
