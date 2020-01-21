.intel_syntax noprefix

.data
tmp:
	.quad 0

.text

.global main
main:
	mov rax, 17
	mov [tmp], rax
	movq xmm0, [tmp]
	movq xmm1, [tmp]
	movq xmm2, [tmp]
	movq xmm3, [tmp]
	movq xmm4, [tmp]
	movq xmm5, [tmp]
	movq xmm6, [tmp]
	movq xmm7, [tmp]
	movq xmm8, [tmp]
	movq xmm9, [tmp]
	movq xmm10, [tmp]
	movq xmm11, [tmp]
	movq xmm12, [tmp]
	movq xmm13, [tmp]
	movq xmm14, [tmp]
	movq xmm15, [tmp]
loop:
check:
	movq [tmp], xmm0
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm1
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm2
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm3
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm4
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm5
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm6
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm7
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm8
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm9
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm10
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm11
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm12
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm13
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm14
	cmp [tmp], rax
	jne exit_error
	movq [tmp], xmm15
	cmp [tmp], rax
	jne exit_error

	jmp loop

exit_error:	// rdi: exit code
	mov rdi, 1

.global exit
exit:	// rdi: exit code
	mov rax, 60
	syscall

.global ndckpt_checkpoint
ndckpt_checkpoint:
	mov rax, 59	# execve with all NULL params
	mov rdi, 0
	mov rsi, 0
	mov rdx, 0
	syscall
	ret
	
