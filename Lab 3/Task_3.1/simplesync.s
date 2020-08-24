	.file	"simplesync.c"
	.text
.Ltext0:
	.globl	mutex
	.bss
	.align 32
	.type	mutex, @object
	.size	mutex, 40
mutex:
	.zero	40
	.section	.rodata
	.align 8
.LC0:
	.string	"About to increase variable %d times\n"
.LC1:
	.string	"Done increasing variable.\n"
	.text
	.globl	increase_fn
	.type	increase_fn, @function
increase_fn:
.LFB2:
	.file 1 "simplesync.c"
	.loc 1 43 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	.loc 1 45 0
	movq	-24(%rbp), %rax
	movq	%rax, -16(%rbp)
	.loc 1 47 0
	movq	stderr(%rip), %rax
	movl	$10000000, %edx
	movl	$.LC0, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf
	.loc 1 48 0
	movl	$0, -4(%rbp)
	jmp	.L2
.L3:
	.loc 1 53 0
	movl	$mutex, %edi
	call	pthread_mutex_lock
	.loc 1 54 0
	movq	-16(%rbp), %rax
	movl	(%rax), %eax
	leal	1(%rax), %edx
	movq	-16(%rbp), %rax
	movl	%edx, (%rax)
	.loc 1 55 0
	movl	$mutex, %edi
	call	pthread_mutex_unlock
	.loc 1 48 0
	addl	$1, -4(%rbp)
.L2:
	.loc 1 48 0 is_stmt 0 discriminator 1
	cmpl	$9999999, -4(%rbp)
	jle	.L3
	.loc 1 58 0 is_stmt 1
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$26, %edx
	movl	$1, %esi
	movl	$.LC1, %edi
	call	fwrite
	.loc 1 60 0
	movl	$0, %eax
	.loc 1 61 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	increase_fn, .-increase_fn
	.section	.rodata
	.align 8
.LC2:
	.string	"About to decrease variable %d times\n"
.LC3:
	.string	"Done decreasing variable.\n"
	.text
	.globl	decrease_fn
	.type	decrease_fn, @function
decrease_fn:
.LFB3:
	.loc 1 64 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	.loc 1 66 0
	movq	-24(%rbp), %rax
	movq	%rax, -16(%rbp)
	.loc 1 68 0
	movq	stderr(%rip), %rax
	movl	$10000000, %edx
	movl	$.LC2, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf
	.loc 1 69 0
	movl	$0, -4(%rbp)
	jmp	.L6
.L7:
	.loc 1 74 0
	movl	$mutex, %edi
	call	pthread_mutex_lock
	.loc 1 75 0
	movq	-16(%rbp), %rax
	movl	(%rax), %eax
	leal	-1(%rax), %edx
	movq	-16(%rbp), %rax
	movl	%edx, (%rax)
	.loc 1 76 0
	movl	$mutex, %edi
	call	pthread_mutex_unlock
	.loc 1 69 0
	addl	$1, -4(%rbp)
.L6:
	.loc 1 69 0 is_stmt 0 discriminator 1
	cmpl	$9999999, -4(%rbp)
	jle	.L7
	.loc 1 79 0 is_stmt 1
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$26, %edx
	movl	$1, %esi
	movl	$.LC3, %edi
	call	fwrite
	.loc 1 81 0
	movl	$0, %eax
	.loc 1 82 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	decrease_fn, .-decrease_fn
	.section	.rodata
.LC4:
	.string	"pthread_create"
.LC5:
	.string	"pthread_join"
.LC6:
	.string	""
.LC7:
	.string	"NOT "
.LC8:
	.string	"%sOK, val = %d.\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB4:
	.loc 1 86 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movl	%edi, -36(%rbp)
	movq	%rsi, -48(%rbp)
	.loc 1 93 0
	movl	$0, -12(%rbp)
	.loc 1 98 0
	leaq	-12(%rbp), %rdx
	leaq	-24(%rbp), %rax
	movq	%rdx, %rcx
	movl	$increase_fn, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	movl	%eax, -4(%rbp)
	.loc 1 99 0
	cmpl	$0, -4(%rbp)
	je	.L10
	.loc 1 100 0
	call	__errno_location
	movq	%rax, %rdx
	movl	-4(%rbp), %eax
	movl	%eax, (%rdx)
	movl	$.LC4, %edi
	call	perror
	.loc 1 101 0
	movl	$1, %edi
	call	exit
.L10:
	.loc 1 103 0
	leaq	-12(%rbp), %rdx
	leaq	-32(%rbp), %rax
	movq	%rdx, %rcx
	movl	$decrease_fn, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	movl	%eax, -4(%rbp)
	.loc 1 104 0
	cmpl	$0, -4(%rbp)
	je	.L11
	.loc 1 105 0
	call	__errno_location
	movq	%rax, %rdx
	movl	-4(%rbp), %eax
	movl	%eax, (%rdx)
	movl	$.LC4, %edi
	call	perror
	.loc 1 106 0
	movl	$1, %edi
	call	exit
.L11:
	.loc 1 112 0
	movq	-24(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	movl	%eax, -4(%rbp)
	.loc 1 113 0
	cmpl	$0, -4(%rbp)
	je	.L12
	.loc 1 114 0
	call	__errno_location
	movq	%rax, %rdx
	movl	-4(%rbp), %eax
	movl	%eax, (%rdx)
	movl	$.LC5, %edi
	call	perror
.L12:
	.loc 1 115 0
	movq	-32(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	movl	%eax, -4(%rbp)
	.loc 1 116 0
	cmpl	$0, -4(%rbp)
	je	.L13
	.loc 1 117 0
	call	__errno_location
	movq	%rax, %rdx
	movl	-4(%rbp), %eax
	movl	%eax, (%rdx)
	movl	$.LC5, %edi
	call	perror
.L13:
	.loc 1 122 0
	movl	-12(%rbp), %eax
	testl	%eax, %eax
	sete	%al
	movzbl	%al, %eax
	movl	%eax, -8(%rbp)
	.loc 1 124 0
	movl	-12(%rbp), %eax
	cmpl	$0, -8(%rbp)
	je	.L14
	.loc 1 124 0 is_stmt 0 discriminator 1
	movl	$.LC6, %ecx
	jmp	.L15
.L14:
	.loc 1 124 0 discriminator 2
	movl	$.LC7, %ecx
.L15:
	.loc 1 124 0 discriminator 4
	movl	%eax, %edx
	movq	%rcx, %rsi
	movl	$.LC8, %edi
	movl	$0, %eax
	call	printf
	.loc 1 126 0 is_stmt 1 discriminator 4
	movl	-8(%rbp), %eax
	.loc 1 127 0 discriminator 4
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	main, .-main
.Letext0:
	.file 2 "/usr/lib/gcc/x86_64-linux-gnu/4.9/include/stddef.h"
	.file 3 "/usr/include/x86_64-linux-gnu/bits/types.h"
	.file 4 "/usr/include/libio.h"
	.file 5 "/usr/include/x86_64-linux-gnu/bits/pthreadtypes.h"
	.file 6 "/usr/include/stdio.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x4c8
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF73
	.byte	0x1
	.long	.LASF74
	.long	.LASF75
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.long	.LASF7
	.byte	0x2
	.byte	0xd4
	.long	0x38
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF0
	.uleb128 0x3
	.byte	0x1
	.byte	0x8
	.long	.LASF1
	.uleb128 0x3
	.byte	0x2
	.byte	0x7
	.long	.LASF2
	.uleb128 0x3
	.byte	0x4
	.byte	0x7
	.long	.LASF3
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.long	.LASF4
	.uleb128 0x3
	.byte	0x2
	.byte	0x5
	.long	.LASF5
	.uleb128 0x4
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.long	.LASF6
	.uleb128 0x2
	.long	.LASF8
	.byte	0x3
	.byte	0x83
	.long	0x69
	.uleb128 0x2
	.long	.LASF9
	.byte	0x3
	.byte	0x84
	.long	0x69
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF10
	.uleb128 0x5
	.byte	0x8
	.uleb128 0x6
	.byte	0x8
	.long	0x95
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.long	.LASF11
	.uleb128 0x7
	.long	.LASF41
	.byte	0xd8
	.byte	0x4
	.byte	0xf5
	.long	0x21c
	.uleb128 0x8
	.long	.LASF12
	.byte	0x4
	.byte	0xf6
	.long	0x62
	.byte	0
	.uleb128 0x8
	.long	.LASF13
	.byte	0x4
	.byte	0xfb
	.long	0x8f
	.byte	0x8
	.uleb128 0x8
	.long	.LASF14
	.byte	0x4
	.byte	0xfc
	.long	0x8f
	.byte	0x10
	.uleb128 0x8
	.long	.LASF15
	.byte	0x4
	.byte	0xfd
	.long	0x8f
	.byte	0x18
	.uleb128 0x8
	.long	.LASF16
	.byte	0x4
	.byte	0xfe
	.long	0x8f
	.byte	0x20
	.uleb128 0x8
	.long	.LASF17
	.byte	0x4
	.byte	0xff
	.long	0x8f
	.byte	0x28
	.uleb128 0x9
	.long	.LASF18
	.byte	0x4
	.value	0x100
	.long	0x8f
	.byte	0x30
	.uleb128 0x9
	.long	.LASF19
	.byte	0x4
	.value	0x101
	.long	0x8f
	.byte	0x38
	.uleb128 0x9
	.long	.LASF20
	.byte	0x4
	.value	0x102
	.long	0x8f
	.byte	0x40
	.uleb128 0x9
	.long	.LASF21
	.byte	0x4
	.value	0x104
	.long	0x8f
	.byte	0x48
	.uleb128 0x9
	.long	.LASF22
	.byte	0x4
	.value	0x105
	.long	0x8f
	.byte	0x50
	.uleb128 0x9
	.long	.LASF23
	.byte	0x4
	.value	0x106
	.long	0x8f
	.byte	0x58
	.uleb128 0x9
	.long	.LASF24
	.byte	0x4
	.value	0x108
	.long	0x254
	.byte	0x60
	.uleb128 0x9
	.long	.LASF25
	.byte	0x4
	.value	0x10a
	.long	0x25a
	.byte	0x68
	.uleb128 0x9
	.long	.LASF26
	.byte	0x4
	.value	0x10c
	.long	0x62
	.byte	0x70
	.uleb128 0x9
	.long	.LASF27
	.byte	0x4
	.value	0x110
	.long	0x62
	.byte	0x74
	.uleb128 0x9
	.long	.LASF28
	.byte	0x4
	.value	0x112
	.long	0x70
	.byte	0x78
	.uleb128 0x9
	.long	.LASF29
	.byte	0x4
	.value	0x116
	.long	0x46
	.byte	0x80
	.uleb128 0x9
	.long	.LASF30
	.byte	0x4
	.value	0x117
	.long	0x54
	.byte	0x82
	.uleb128 0x9
	.long	.LASF31
	.byte	0x4
	.value	0x118
	.long	0x260
	.byte	0x83
	.uleb128 0x9
	.long	.LASF32
	.byte	0x4
	.value	0x11c
	.long	0x270
	.byte	0x88
	.uleb128 0x9
	.long	.LASF33
	.byte	0x4
	.value	0x125
	.long	0x7b
	.byte	0x90
	.uleb128 0x9
	.long	.LASF34
	.byte	0x4
	.value	0x12e
	.long	0x8d
	.byte	0x98
	.uleb128 0x9
	.long	.LASF35
	.byte	0x4
	.value	0x12f
	.long	0x8d
	.byte	0xa0
	.uleb128 0x9
	.long	.LASF36
	.byte	0x4
	.value	0x130
	.long	0x8d
	.byte	0xa8
	.uleb128 0x9
	.long	.LASF37
	.byte	0x4
	.value	0x131
	.long	0x8d
	.byte	0xb0
	.uleb128 0x9
	.long	.LASF38
	.byte	0x4
	.value	0x132
	.long	0x2d
	.byte	0xb8
	.uleb128 0x9
	.long	.LASF39
	.byte	0x4
	.value	0x134
	.long	0x62
	.byte	0xc0
	.uleb128 0x9
	.long	.LASF40
	.byte	0x4
	.value	0x136
	.long	0x276
	.byte	0xc4
	.byte	0
	.uleb128 0xa
	.long	.LASF76
	.byte	0x4
	.byte	0x9a
	.uleb128 0x7
	.long	.LASF42
	.byte	0x18
	.byte	0x4
	.byte	0xa0
	.long	0x254
	.uleb128 0x8
	.long	.LASF43
	.byte	0x4
	.byte	0xa1
	.long	0x254
	.byte	0
	.uleb128 0x8
	.long	.LASF44
	.byte	0x4
	.byte	0xa2
	.long	0x25a
	.byte	0x8
	.uleb128 0x8
	.long	.LASF45
	.byte	0x4
	.byte	0xa6
	.long	0x62
	.byte	0x10
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x223
	.uleb128 0x6
	.byte	0x8
	.long	0x9c
	.uleb128 0xb
	.long	0x95
	.long	0x270
	.uleb128 0xc
	.long	0x86
	.byte	0
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x21c
	.uleb128 0xb
	.long	0x95
	.long	0x286
	.uleb128 0xc
	.long	0x86
	.byte	0x13
	.byte	0
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.long	.LASF46
	.uleb128 0x2
	.long	.LASF47
	.byte	0x5
	.byte	0x3c
	.long	0x38
	.uleb128 0x7
	.long	.LASF48
	.byte	0x10
	.byte	0x5
	.byte	0x4b
	.long	0x2bd
	.uleb128 0x8
	.long	.LASF49
	.byte	0x5
	.byte	0x4d
	.long	0x2bd
	.byte	0
	.uleb128 0x8
	.long	.LASF50
	.byte	0x5
	.byte	0x4e
	.long	0x2bd
	.byte	0x8
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x298
	.uleb128 0x2
	.long	.LASF51
	.byte	0x5
	.byte	0x4f
	.long	0x298
	.uleb128 0x7
	.long	.LASF52
	.byte	0x28
	.byte	0x5
	.byte	0x5c
	.long	0x33b
	.uleb128 0x8
	.long	.LASF53
	.byte	0x5
	.byte	0x5e
	.long	0x62
	.byte	0
	.uleb128 0x8
	.long	.LASF54
	.byte	0x5
	.byte	0x5f
	.long	0x4d
	.byte	0x4
	.uleb128 0x8
	.long	.LASF55
	.byte	0x5
	.byte	0x60
	.long	0x62
	.byte	0x8
	.uleb128 0x8
	.long	.LASF56
	.byte	0x5
	.byte	0x62
	.long	0x4d
	.byte	0xc
	.uleb128 0x8
	.long	.LASF57
	.byte	0x5
	.byte	0x66
	.long	0x62
	.byte	0x10
	.uleb128 0x8
	.long	.LASF58
	.byte	0x5
	.byte	0x68
	.long	0x5b
	.byte	0x14
	.uleb128 0x8
	.long	.LASF59
	.byte	0x5
	.byte	0x69
	.long	0x5b
	.byte	0x16
	.uleb128 0x8
	.long	.LASF60
	.byte	0x5
	.byte	0x6a
	.long	0x2c3
	.byte	0x18
	.byte	0
	.uleb128 0xd
	.byte	0x28
	.byte	0x5
	.byte	0x5a
	.long	0x365
	.uleb128 0xe
	.long	.LASF61
	.byte	0x5
	.byte	0x7c
	.long	0x2ce
	.uleb128 0xe
	.long	.LASF62
	.byte	0x5
	.byte	0x7d
	.long	0x365
	.uleb128 0xe
	.long	.LASF63
	.byte	0x5
	.byte	0x7e
	.long	0x69
	.byte	0
	.uleb128 0xb
	.long	0x95
	.long	0x375
	.uleb128 0xc
	.long	0x86
	.byte	0x27
	.byte	0
	.uleb128 0x2
	.long	.LASF64
	.byte	0x5
	.byte	0x7f
	.long	0x33b
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF65
	.uleb128 0xf
	.long	0x62
	.uleb128 0x10
	.long	.LASF66
	.byte	0x1
	.byte	0x2a
	.long	0x8d
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.long	0x3d5
	.uleb128 0x11
	.string	"arg"
	.byte	0x1
	.byte	0x2a
	.long	0x8d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x12
	.string	"i"
	.byte	0x1
	.byte	0x2c
	.long	0x62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x12
	.string	"ip"
	.byte	0x1
	.byte	0x2d
	.long	0x3d5
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x387
	.uleb128 0x10
	.long	.LASF67
	.byte	0x1
	.byte	0x3f
	.long	0x8d
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.long	0x424
	.uleb128 0x11
	.string	"arg"
	.byte	0x1
	.byte	0x3f
	.long	0x8d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x12
	.string	"i"
	.byte	0x1
	.byte	0x41
	.long	0x62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x12
	.string	"ip"
	.byte	0x1
	.byte	0x42
	.long	0x3d5
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x10
	.long	.LASF68
	.byte	0x1
	.byte	0x55
	.long	0x62
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.long	0x4a5
	.uleb128 0x13
	.long	.LASF69
	.byte	0x1
	.byte	0x55
	.long	0x62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -52
	.uleb128 0x13
	.long	.LASF70
	.byte	0x1
	.byte	0x55
	.long	0x4a5
	.uleb128 0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0x12
	.string	"val"
	.byte	0x1
	.byte	0x57
	.long	0x62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.uleb128 0x12
	.string	"ret"
	.byte	0x1
	.byte	0x57
	.long	0x62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x12
	.string	"ok"
	.byte	0x1
	.byte	0x57
	.long	0x62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x12
	.string	"t1"
	.byte	0x1
	.byte	0x58
	.long	0x28d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x12
	.string	"t2"
	.byte	0x1
	.byte	0x58
	.long	0x28d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x8f
	.uleb128 0x14
	.long	.LASF71
	.byte	0x6
	.byte	0xaa
	.long	0x25a
	.uleb128 0x15
	.long	.LASF72
	.byte	0x1
	.byte	0x27
	.long	0x375
	.uleb128 0x9
	.byte	0x3
	.quad	mutex
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0x17
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0x35
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.long	0x2c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF61:
	.string	"__data"
.LASF41:
	.string	"_IO_FILE"
.LASF23:
	.string	"_IO_save_end"
.LASF5:
	.string	"short int"
.LASF7:
	.string	"size_t"
.LASF10:
	.string	"sizetype"
.LASF33:
	.string	"_offset"
.LASF48:
	.string	"__pthread_internal_list"
.LASF75:
	.string	"/home/oslab/oslabc16/Ex3"
.LASF17:
	.string	"_IO_write_ptr"
.LASF12:
	.string	"_flags"
.LASF64:
	.string	"pthread_mutex_t"
.LASF54:
	.string	"__count"
.LASF63:
	.string	"__align"
.LASF24:
	.string	"_markers"
.LASF14:
	.string	"_IO_read_end"
.LASF49:
	.string	"__prev"
.LASF50:
	.string	"__next"
.LASF71:
	.string	"stderr"
.LASF57:
	.string	"__kind"
.LASF46:
	.string	"long long int"
.LASF32:
	.string	"_lock"
.LASF6:
	.string	"long int"
.LASF29:
	.string	"_cur_column"
.LASF45:
	.string	"_pos"
.LASF58:
	.string	"__spins"
.LASF70:
	.string	"argv"
.LASF44:
	.string	"_sbuf"
.LASF28:
	.string	"_old_offset"
.LASF1:
	.string	"unsigned char"
.LASF69:
	.string	"argc"
.LASF4:
	.string	"signed char"
.LASF65:
	.string	"long long unsigned int"
.LASF3:
	.string	"unsigned int"
.LASF42:
	.string	"_IO_marker"
.LASF31:
	.string	"_shortbuf"
.LASF16:
	.string	"_IO_write_base"
.LASF40:
	.string	"_unused2"
.LASF13:
	.string	"_IO_read_ptr"
.LASF73:
	.string	"GNU C 4.9.2 -mtune=generic -march=x86-64 -g"
.LASF72:
	.string	"mutex"
.LASF62:
	.string	"__size"
.LASF20:
	.string	"_IO_buf_end"
.LASF11:
	.string	"char"
.LASF56:
	.string	"__nusers"
.LASF68:
	.string	"main"
.LASF74:
	.string	"simplesync.c"
.LASF43:
	.string	"_next"
.LASF34:
	.string	"__pad1"
.LASF35:
	.string	"__pad2"
.LASF36:
	.string	"__pad3"
.LASF37:
	.string	"__pad4"
.LASF38:
	.string	"__pad5"
.LASF53:
	.string	"__lock"
.LASF55:
	.string	"__owner"
.LASF2:
	.string	"short unsigned int"
.LASF66:
	.string	"increase_fn"
.LASF52:
	.string	"__pthread_mutex_s"
.LASF0:
	.string	"long unsigned int"
.LASF18:
	.string	"_IO_write_end"
.LASF9:
	.string	"__off64_t"
.LASF59:
	.string	"__elision"
.LASF26:
	.string	"_fileno"
.LASF25:
	.string	"_chain"
.LASF51:
	.string	"__pthread_list_t"
.LASF67:
	.string	"decrease_fn"
.LASF8:
	.string	"__off_t"
.LASF22:
	.string	"_IO_backup_base"
.LASF19:
	.string	"_IO_buf_base"
.LASF27:
	.string	"_flags2"
.LASF39:
	.string	"_mode"
.LASF15:
	.string	"_IO_read_base"
.LASF60:
	.string	"__list"
.LASF30:
	.string	"_vtable_offset"
.LASF21:
	.string	"_IO_save_base"
.LASF47:
	.string	"pthread_t"
.LASF76:
	.string	"_IO_lock_t"
	.ident	"GCC: (Debian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",@progbits
