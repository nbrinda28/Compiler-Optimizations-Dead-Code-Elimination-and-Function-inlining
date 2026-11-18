	.file	"inline_bench.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC3:
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
	cmpl	$1, %edi
	jg	.L14
	movl	$250000, %esi
.L2:
	leaq	a.0(%rip), %rdi
	movdqa	.LC0(%rip), %xmm0
	movdqa	.LC1(%rip), %xmm2
	leaq	16384(%rdi), %rdx
	movq	%rdi, %rax
	.p2align 4,,10
	.p2align 3
.L3:
	movdqa	%xmm0, %xmm1
	addq	$16, %rax
	paddd	%xmm2, %xmm0
	movaps	%xmm1, -16(%rax)
	cmpq	%rdx, %rax
	jne	.L3
	testq	%rsi, %rsi
	jle	.L5
	movdqa	.LC2(%rip), %xmm1
	xorl	%ecx, %ecx
.L4:
	movq	%rdi, %rax
	.p2align 4,,10
	.p2align 3
.L6:
	movdqa	(%rax), %xmm0
	addq	$16, %rax
	pslld	$1, %xmm0
	paddd	-16(%rax), %xmm0
	paddd	%xmm1, %xmm0
	movaps	%xmm0, -16(%rax)
	cmpq	%rax, %rdx
	jne	.L6
	addq	$1, %rcx
	cmpq	%rcx, %rsi
	jne	.L4
.L5:
	movl	16380+a.0(%rip), %edx
	leaq	.LC3(%rip), %rsi
	movl	$2, %edi
	xorl	%eax, %eax
	call	__printf_chk@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L14:
	.cfi_restore_state
	movq	8(%rsi), %rdi
	movl	$10, %edx
	xorl	%esi, %esi
	call	strtol@PLT
	movq	%rax, %rsi
	jmp	.L2
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
	.align 16
.LC2:
	.long	1
	.long	1
	.long	1
	.long	1
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
