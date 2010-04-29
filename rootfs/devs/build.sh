# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


# see linux/Documentation/devices.txt for more.
do_devs_get() {
	:
}

do_devs_extract() {
	:
}

do_devs() {
	CT_Pushd ${CT_FS_DIR}

	rm -rf ./dev
	mkdir dev

	# NAME TYPE MAJOR MINOR
	CT_DoExecLog ALL sudo mknod ./dev/full     c 1 7
	CT_DoExecLog ALL sudo mknod ./dev/mem      c 1 1
	CT_DoExecLog ALL sudo mknod ./dev/kmem     c 1 2
	CT_DoExecLog ALL sudo mknod ./dev/null     c 1 3
	CT_DoExecLog ALL sudo mknod ./dev/port     c 1 4
	CT_DoExecLog ALL sudo mknod ./dev/zero     c 1 5
	CT_DoExecLog ALL sudo mknod ./dev/random   c 1 8
	CT_DoExecLog ALL sudo mknod ./dev/urandom  c 1 9
	CT_DoExecLog ALL sudo mknod ./dev/kmsg     c 1 11
	CT_DoExecLog ALL sudo mknod ./dev/ttyS0    c 4 64
	CT_DoExecLog ALL sudo mknod ./dev/ttyS1    c 4 65
	CT_DoExecLog ALL sudo mknod ./dev/ttyS2    c 4 66
	CT_DoExecLog ALL sudo mknod ./dev/ttyS3    c 4 67
	CT_DoExecLog ALL sudo mknod ./dev/ttyS4    c 4 68
	CT_DoExecLog ALL sudo mknod ./dev/tty      c 5 0
	CT_DoExecLog ALL sudo mknod ./dev/console  c 5 1
	CT_DoExecLog ALL sudo mknod ./dev/ptmx     c 5 2
	CT_DoExecLog ALL sudo mknod ./dev/cua0     c 5 64
	CT_DoExecLog ALL sudo mknod ./dev/cua1     c 5 65
	CT_DoExecLog ALL sudo mknod ./dev/watchdog c 10 130
	CT_DoExecLog ALL sudo mknod ./dev/rtc      c 10 135
	CT_DoExecLog ALL ln -sf /dev/rtc ./dev/rtc0

	CT_DoExecLog ALL sudo mknod ./dev/i2c-0    c 89 0

	#Coldfire encryption module
	CT_DoExecLog ALL sudo mknod ./dev/cfsec   c 130 0

	CT_DoExecLog ALL mkdir ./dev/pts
	CT_DoExecLog ALL sudo mknod ./dev/pts/0 c 136 0

	CT_DoExecLog ALL mkdir ./dev/pty
	CT_DoExecLog ALL sudo mknod ./dev/pty/m0 c 2 0
	CT_DoExecLog ALL sudo mknod ./dev/pty/m1 c 2 1
	CT_DoExecLog ALL sudo mknod ./dev/pty/m2 c 2 2
	CT_DoExecLog ALL sudo mknod ./dev/pty/m3 c 2 3
	CT_DoExecLog ALL sudo mknod ./dev/pty/m4 c 2 4
	CT_DoExecLog ALL sudo mknod ./dev/pty/m5 c 2 5
	CT_DoExecLog ALL sudo mknod ./dev/pty/m6 c 2 6
	CT_DoExecLog ALL sudo mknod ./dev/pty/m7 c 2 7
	CT_DoExecLog ALL sudo mknod ./dev/pty/s0 c 3 0
	CT_DoExecLog ALL sudo mknod ./dev/pty/s1 c 3 1
	CT_DoExecLog ALL sudo mknod ./dev/pty/s2 c 3 2
	CT_DoExecLog ALL sudo mknod ./dev/pty/s3 c 3 3
	CT_DoExecLog ALL sudo mknod ./dev/pty/s4 c 3 4
	CT_DoExecLog ALL sudo mknod ./dev/pty/s5 c 3 5
	CT_DoExecLog ALL sudo mknod ./dev/pty/s6 c 3 6
	CT_DoExecLog ALL sudo mknod ./dev/pty/s7 c 3 7



	CT_DoExecLog ALL mkdir ./dev/vc
	CT_DoExecLog ALL sudo mknod ./dev/vc/0 c 4 0
	CT_DoExecLog ALL sudo mknod ./dev/vc/1 c 4 1
	CT_DoExecLog ALL sudo mknod ./dev/vc/10 c 4 10
	CT_DoExecLog ALL sudo mknod ./dev/vc/11 c 4 11
	CT_DoExecLog ALL sudo mknod ./dev/vc/12 c 4 12
	CT_DoExecLog ALL sudo mknod ./dev/vc/13 c 4 13
	CT_DoExecLog ALL sudo mknod ./dev/vc/14 c 4 14
	CT_DoExecLog ALL sudo mknod ./dev/vc/15 c 4 15
	CT_DoExecLog ALL sudo mknod ./dev/vc/16 c 4 16
	CT_DoExecLog ALL sudo mknod ./dev/vc/17 c 4 17
	CT_DoExecLog ALL sudo mknod ./dev/vc/18 c 4 18
	CT_DoExecLog ALL sudo mknod ./dev/vc/19 c 4 19
	CT_DoExecLog ALL sudo mknod ./dev/vc/2 c 4 2
	CT_DoExecLog ALL sudo mknod ./dev/vc/20 c 4 20
	CT_DoExecLog ALL sudo mknod ./dev/vc/21 c 4 21
	CT_DoExecLog ALL sudo mknod ./dev/vc/22 c 4 22
	CT_DoExecLog ALL sudo mknod ./dev/vc/23 c 4 23
	CT_DoExecLog ALL sudo mknod ./dev/vc/24 c 4 24
	CT_DoExecLog ALL sudo mknod ./dev/vc/25 c 4 25
	CT_DoExecLog ALL sudo mknod ./dev/vc/26 c 4 26
	CT_DoExecLog ALL sudo mknod ./dev/vc/27 c 4 27
	CT_DoExecLog ALL sudo mknod ./dev/vc/28 c 4 28
	CT_DoExecLog ALL sudo mknod ./dev/vc/29 c 4 29
	CT_DoExecLog ALL sudo mknod ./dev/vc/3 c 4 3
	CT_DoExecLog ALL sudo mknod ./dev/vc/30 c 4 30
	CT_DoExecLog ALL sudo mknod ./dev/vc/31 c 4 31
	CT_DoExecLog ALL sudo mknod ./dev/vc/32 c 4 32
	CT_DoExecLog ALL sudo mknod ./dev/vc/33 c 4 33
	CT_DoExecLog ALL sudo mknod ./dev/vc/34 c 4 34
	CT_DoExecLog ALL sudo mknod ./dev/vc/35 c 4 35
	CT_DoExecLog ALL sudo mknod ./dev/vc/36 c 4 36
	CT_DoExecLog ALL sudo mknod ./dev/vc/37 c 4 37
	CT_DoExecLog ALL sudo mknod ./dev/vc/38 c 4 38
	CT_DoExecLog ALL sudo mknod ./dev/vc/39 c 4 39
	CT_DoExecLog ALL sudo mknod ./dev/vc/4 c 4 4
	CT_DoExecLog ALL sudo mknod ./dev/vc/40 c 4 40
	CT_DoExecLog ALL sudo mknod ./dev/vc/41 c 4 41
	CT_DoExecLog ALL sudo mknod ./dev/vc/42 c 4 42
	CT_DoExecLog ALL sudo mknod ./dev/vc/43 c 4 43
	CT_DoExecLog ALL sudo mknod ./dev/vc/44 c 4 44
	CT_DoExecLog ALL sudo mknod ./dev/vc/45 c 4 45
	CT_DoExecLog ALL sudo mknod ./dev/vc/46 c 4 46
	CT_DoExecLog ALL sudo mknod ./dev/vc/47 c 4 47
	CT_DoExecLog ALL sudo mknod ./dev/vc/48 c 4 48
	CT_DoExecLog ALL sudo mknod ./dev/vc/49 c 4 49
	CT_DoExecLog ALL sudo mknod ./dev/vc/5 c 4 5
	CT_DoExecLog ALL sudo mknod ./dev/vc/50 c 4 50
	CT_DoExecLog ALL sudo mknod ./dev/vc/51 c 4 51
	CT_DoExecLog ALL sudo mknod ./dev/vc/52 c 4 52
	CT_DoExecLog ALL sudo mknod ./dev/vc/53 c 4 53
	CT_DoExecLog ALL sudo mknod ./dev/vc/54 c 4 54
	CT_DoExecLog ALL sudo mknod ./dev/vc/55 c 4 55
	CT_DoExecLog ALL sudo mknod ./dev/vc/56 c 4 56
	CT_DoExecLog ALL sudo mknod ./dev/vc/57 c 4 57
	CT_DoExecLog ALL sudo mknod ./dev/vc/58 c 4 58
	CT_DoExecLog ALL sudo mknod ./dev/vc/59 c 4 59
	CT_DoExecLog ALL sudo mknod ./dev/vc/6 c 4 6
	CT_DoExecLog ALL sudo mknod ./dev/vc/60 c 4 60
	CT_DoExecLog ALL sudo mknod ./dev/vc/61 c 4 61
	CT_DoExecLog ALL sudo mknod ./dev/vc/62 c 4 62
	CT_DoExecLog ALL sudo mknod ./dev/vc/63 c 4 63
	CT_DoExecLog ALL sudo mknod ./dev/vc/7 c 4 7
	CT_DoExecLog ALL sudo mknod ./dev/vc/8 c 4 8
	CT_DoExecLog ALL sudo mknod ./dev/vc/9 c 4 9

	CT_DoExecLog ALL mkdir ./dev/vcc
	CT_DoExecLog ALL sudo mknod ./dev/vcc/0 c 7 0
	CT_DoExecLog ALL sudo mknod ./dev/vcc/a0 c 7 128

	CT_DoExecLog ALL sudo mknod ./dev/mtdblock0 b 31 0
	CT_DoExecLog ALL sudo mknod ./dev/mtdblock1 b 31 1

	CT_Popd
}
