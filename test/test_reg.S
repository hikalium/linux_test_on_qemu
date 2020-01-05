.intel_syntax noprefix
.global main
main:
	xor rax, rax
loop:
	inc rax
	mov rax, rax
	mov rcx, rax
	mov rdx, rax
	mov rbx, rax
	mov rsp, rax
	mov rbp, rax
	mov rsi, rax
	mov rdi, rax
	mov r8, rax
	mov r9, rax
	mov r10, rax
	mov r11, rax
	mov r12, rax
	mov r13, rax
	mov r14, rax
	mov r15, rax
check:
	cmp rax, rax
	jne exit_error
	cmp rcx, rax
	jne exit_error
	cmp rdx, rax
	jne exit_error
	cmp rbx, rax
	jne exit_error
	cmp rsp, rax
	jne exit_error
	cmp rbp, rax
	jne exit_error
	cmp rsi, rax
	jne exit_error
	cmp rdi, rax
	jne exit_error
	cmp r8, rax
	jne exit_error
	cmp r9, rax
	jne exit_error
	cmp r10, rax
	jne exit_error
	cmp r11, rax
	jne exit_error
	cmp r12, rax
	jne exit_error
	cmp r13, rax
	jne exit_error
	cmp r14, rax
	jne exit_error
	cmp r15, rax
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
	
