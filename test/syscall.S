.intel_syntax noprefix
.global write
write:
	mov rax, 1
	syscall
	retq

.global exit
exit:
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
	
