	.file	"inline_bench.c"
	.text
	.p2align 4
	.type	mix, @function
mix:
.LFB39:
	.cfi_startproc
	leal	1(%rdi,%rdi,2), %eax
	ret
	.cfi_endproc
.LFE39:
	.size	mix, .-mix
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC2:
	.string	"%u\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB40:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$250000, %r8d
	cmpl	$1, %edi
	jle	.L4
	movq	8(%rsi), %rdi
	movl	$10, %edx
	xorl	%esi, %esi
	call	strtol@PLT
	movq	%rax, %r8
.L4:
	leaq	a.0(%rip), %r9
	movdqa	.LC0(%rip), %xmm0
	movdqa	.LC1(%rip), %xmm2
	leaq	16384(%r9), %rcx
	movq	%r9, %rax
	.p2align 4,,10
	.p2align 3
.L5:
	movdqa	%xmm0, %xmm1
	addq	$16, %rax
	paddd	%xmm2, %xmm0
	movaps	%xmm1, -16(%rax)
	cmpq	%rcx, %rax
	jne	.L5
	xorl	%esi, %esi
	testq	%r8, %r8
	jle	.L7
.L6:
	movq	%r9, %rdx
	.p2align 4,,10
	.p2align 3
.L8:
	movl	(%rdx), %edi
	addq	$4, %rdx
	call	mix
	movl	%eax, -4(%rdx)
	cmpq	%rcx, %rdx
	jne	.L8
	addq	$1, %rsi
	cmpq	%rsi, %r8
	jne	.L6
.L7:
	movl	16380+a.0(%rip), %edx
	leaq	.LC2(%rip), %rsi
	movl	$2, %edi
	xorl	%eax, %eax
	call	__printf_chk@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE40:
	.size	main, .-main
	.local	a.0
	.comm	a.0,16384,32
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC0:
	.long	0
	.long	1
	.long	2
	.long	3
	.align 16
.LC1:
	.long	4
	.long	4
	.long	4
	.long	4
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
