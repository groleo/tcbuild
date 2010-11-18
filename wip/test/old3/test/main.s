#NO_APP
	.file	"main.c"
	.text
	.align	2
	.globl	getBuffer
	.type	getBuffer, @function
getBuffer:
	link.w %fp,#-8
	mov3q.l #1,-(%sp)
	move.l 8(%fp),-(%sp)
	jsr calloc
	addq.l #8,%sp
	move.l %a0,%d0
	move.l %d0,-8(%fp)
	clr.l -4(%fp)
	jra .L2
.L3:
	move.l -4(%fp),%d0
	add.l -8(%fp),%d0
	move.l -4(%fp),%d1
	move.b %d1,%d1
	move.l %d0,%a0
	move.b %d1,(%a0)
	addq.l #1,-4(%fp)
.L2:
	move.l -4(%fp),%d0
	cmp.l 8(%fp),%d0
	jcs .L3
	move.l -8(%fp),%d0
	move.l %d0,%d1
	move.l %d1,%a0
	unlk %fp
	rts
	.size	getBuffer, .-getBuffer
	.section	.rodata
.LC0:
	.string	"%X "
	.text
	.align	2
	.globl	printBuf
	.type	printBuf, @function
printBuf:
	link.w %fp,#-4
	clr.l -4(%fp)
	jra .L6
.L7:
	move.l -4(%fp),%d0
	add.l 8(%fp),%d0
	move.l %d0,%a0
	move.b (%a0),%d0
	mvs.b %d0,%d0
	move.l #.LC0,%d1
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr printf
	addq.l #8,%sp
	addq.l #1,-4(%fp)
.L6:
	move.l -4(%fp),%d0
	cmp.l 12(%fp),%d0
	jcs .L7
	pea 10.w
	jsr putchar
	addq.l #4,%sp
	unlk %fp
	rts
	.size	printBuf, .-printBuf
	.align	2
	.globl	dummyFunc
	.type	dummyFunc, @function
dummyFunc:
	link.w %fp,#-12
	move.l 12(%fp),-12(%fp)
	move.l 8(%fp),-8(%fp)
	move.l 16(%fp),-4(%fp)
	move.l -4(%fp),%d0
	add.l -12(%fp),%d0
	unlk %fp
	rts
	.size	dummyFunc, .-dummyFunc
	.section	.rodata
.LC1:
	.string	"d[%p]:%x!=s[%p]:%x idx:%i\n"
	.text
	.align	2
	.globl	differ
	.type	differ, @function
differ:
	link.w %fp,#-4
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	clr.l -4(%fp)
	jra .L12
.L15:
	move.l -4(%fp),%d0
	add.l 8(%fp),%d0
	move.l %d0,%a0
	move.b (%a0),%d1
	move.l -4(%fp),%d0
	add.l 12(%fp),%d0
	move.l %d0,%a2
	move.b (%a2),%d0
	mvs.b %d1,%d1
	mvs.b %d0,%d0
	cmp.l %d1,%d0
	jeq .L13
	move.l -4(%fp),%d0
	add.l 12(%fp),%d0
	move.l %d0,%a0
	move.b (%a0),%d0
	mvs.b %d0,%d0
	move.l %d0,%a1
	move.l -4(%fp),%d0
	move.l 12(%fp),%a0
	add.l %d0,%a0
	move.l -4(%fp),%d0
	add.l 8(%fp),%d0
	move.l %d0,%a2
	move.b (%a2),%d0
	mvs.b %d0,%d1
	move.l -4(%fp),%d0
	add.l 8(%fp),%d0
	move.l #.LC1,%d2
	move.l -4(%fp),-(%sp)
	move.l %a1,-(%sp)
	move.l %a0,-(%sp)
	move.l %d1,-(%sp)
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	jsr printf
	lea (24,%sp),%sp
	move.l 16(%fp),-(%sp)
	move.l 8(%fp),-(%sp)
	jsr printBuf
	addq.l #8,%sp
	pea 10.w
	jsr putchar
	addq.l #4,%sp
	move.l 16(%fp),-(%sp)
	move.l 12(%fp),-(%sp)
	jsr printBuf
	addq.l #8,%sp
	mov3q.l #1,%d0
	jra .L14
.L13:
	addq.l #1,-4(%fp)
.L12:
	move.l -4(%fp),%d0
	cmp.l 16(%fp),%d0
	jcs .L15
	clr.l %d0
.L14:
	move.l -12(%fp),%d2
	move.l -8(%fp),%a2
	unlk %fp
	rts
	.size	differ, .-differ
	.section	.rodata
.LC2:
	.string	"testSize:%i\n"
.LC3:
	.string	"Error 1"
	.text
	.align	2
	.globl	test
	.type	test, @function
test:
	link.w %fp,#-20
	move.l 8(%fp),%d0
	addq.l #1,%d0
	move.l %d0,-(%sp)
	jsr getBuffer
	addq.l #4,%sp
	move.l %a0,%d0
	move.l %d0,-8(%fp)
	move.l 8(%fp),%d0
	addq.l #1,%d0
	mov3q.l #1,-(%sp)
	move.l %d0,-(%sp)
	jsr calloc
	addq.l #8,%sp
	move.l %a0,%d0
	move.l %d0,-4(%fp)
	move.l #.LC2,%d0
	move.l 8(%fp),-(%sp)
	move.l %d0,-(%sp)
	jsr printf
	addq.l #8,%sp
	move.l 8(%fp),-(%sp)
	move.l -8(%fp),-(%sp)
	move.l -4(%fp),-(%sp)
	jsr my_memmove
	lea (12,%sp),%sp
	move.l 8(%fp),-(%sp)
	move.l -8(%fp),-(%sp)
	move.l -4(%fp),-(%sp)
	jsr differ
	lea (12,%sp),%sp
	move.l %d0,-16(%fp)
	tst.l -16(%fp)
	jeq .L18
	pea .LC3
	jsr puts
	addq.l #4,%sp
.L18:
	move.l -8(%fp),-(%sp)
	jsr free
	addq.l #4,%sp
	move.l -4(%fp),-(%sp)
	jsr free
	addq.l #4,%sp
	clr.l %d0
	unlk %fp
	rts
	.size	test, .-test
	.section	.rodata
.LC4:
	.string	"testAlign:%p,%p,%i,%i\n"
.LC5:
	.string	"Error 2\n----------------------------------------"
.LC6:
	.string	"Error 3\n----------------------------------------"
	.text
	.align	2
	.globl	testAlign
	.type	testAlign, @function
testAlign:
	link.w %fp,#-16
	mov3q.l #1,-12(%fp)
	jra .L21
.L25:
	move.l 8(%fp),%d0
	addq.l #1,%d0
	move.l %d0,-(%sp)
	jsr getBuffer
	addq.l #4,%sp
	move.l %a0,%d0
	move.l %d0,-8(%fp)
	move.l 8(%fp),%d0
	addq.l #1,%d0
	move.l %d0,-(%sp)
	jsr getBuffer
	addq.l #4,%sp
	move.l %a0,%d0
	move.l %d0,-4(%fp)
	move.l -12(%fp),%d0
	move.l 8(%fp),%d1
	sub.l %d0,%d1
	move.l -12(%fp),%d0
	add.l -8(%fp),%d0
	lea .LC4,%a0
	move.l -12(%fp),-(%sp)
	move.l %d1,-(%sp)
	move.l -8(%fp),-(%sp)
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr printf
	lea (20,%sp),%sp
	move.l -12(%fp),%d0
	move.l 8(%fp),%d1
	sub.l %d0,%d1
	move.l -12(%fp),%d0
	add.l -8(%fp),%d0
	move.l %d1,-(%sp)
	move.l -8(%fp),-(%sp)
	move.l %d0,-(%sp)
	jsr my_memmove
	lea (12,%sp),%sp
	move.l -12(%fp),%d0
	move.l 8(%fp),%d1
	sub.l %d0,%d1
	move.l %d1,%d0
	move.l -12(%fp),%d1
	cmp.l %d0,%d1
	jcc .L22
	move.l %d1,%d0
.L22:
	move.l -12(%fp),%d1
	add.l -8(%fp),%d1
	move.l %d0,-(%sp)
	move.l -8(%fp),-(%sp)
	move.l %d1,-(%sp)
	jsr differ
	lea (12,%sp),%sp
	move.l %d0,-16(%fp)
	tst.l -16(%fp)
	jeq .L23
	pea .LC5
	jsr puts
	addq.l #4,%sp
.L23:
	move.l -12(%fp),%d0
	move.l 8(%fp),%d1
	sub.l %d0,%d1
	move.l -12(%fp),%d0
	add.l -8(%fp),%d0
	move.l %d1,-(%sp)
	move.l -4(%fp),-(%sp)
	move.l %d0,-(%sp)
	jsr differ
	lea (12,%sp),%sp
	move.l %d0,-16(%fp)
	tst.l -16(%fp)
	jeq .L24
	pea .LC6
	jsr puts
	addq.l #4,%sp
.L24:
	move.l -8(%fp),-(%sp)
	jsr free
	addq.l #4,%sp
	move.l -4(%fp),-(%sp)
	jsr free
	addq.l #4,%sp
	pea 10.w
	jsr putchar
	addq.l #4,%sp
	addq.l #1,-12(%fp)
.L21:
	move.l -12(%fp),%d0
	cmp.l 8(%fp),%d0
	jcs .L25
	unlk %fp
	rts
	.size	testAlign, .-testAlign
	.align	2
	.globl	main
	.type	main, @function
main:
	link.w %fp,#-4
	mvz.w #1024,%d0
	move.l %d0,-4(%fp)
	jra .L28
.L29:
	move.l -4(%fp),%d0
	move.l %d0,-(%sp)
	jsr testAlign
	addq.l #4,%sp
	subq.l #1,-4(%fp)
.L28:
	tst.l -4(%fp)
	jgt .L29
	unlk %fp
	rts
	.size	main, .-main
	.ident	"GCC: (chainbuilder-1.0) 4.4.1"
	.section	.note.GNU-stack,"",@progbits
