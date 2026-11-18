	.file	"bench.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"%ld\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB40:
	.cfi_startproc
	endbr64
	movl	%edi, %eax
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$1000000000, %edi
	cmpl	$1, %eax
	jg	.L11
.L2:
	movabsq	$2951479051793528259, %r8
	xorl	%ecx, %ecx
	xorl	%esi, %esi
	.p2align 4,,10
	.p2align 3
.L4:
	movq	%rcx, %rdx
	shrq	$2, %rdx
	movq	%rdx, %rax
	mulq	%r8
	movq	%rdx, %rax
	andq	$-4, %rdx
	shrq	$2, %rax
	addq	%rax, %rdx
	movq	%rcx, %rax
	addq	$1, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	salq	$2, %rdx
	subq	%rdx, %rax
	imull	%eax, %eax
	cltq
	addq	%rax, %rsi
	cmpq	%rcx, %rdi
	jne	.L4
.L3:
	movq	%rsi, %rdx
	movl	$2, %edi
	xorl	%eax, %eax
	leaq	.LC0(%rip), %rsi
	call	__printf_chk@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L11:
	.cfi_restore_state
	movq	8(%rsi), %rdi
	movl	$10, %edx
	xorl	%esi, %esi
	call	strtol@PLT
	movq	%rax, %rdi
	testq	%rax, %rax
	jg	.L2
	xorl	%esi, %esi
	jmp	.L3
	.cfi_endproc
.LFE40:
	.size	main, .-main
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
