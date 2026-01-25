default abs
section .bss
	tape resb 30000
section .text
	global _start
_start:
	mov rsi, tape
	read_input_0:
	mov rax, 0
	mov rdi, 0
	mov rdx, 1
	syscall
input_done_0:
	loop_start_0:
	cmp byte [rsi], 0
	je loop_end_0
	mov rax, 1
	mov rdi, 1
	mov rdx, 1
	syscall
	read_input_1:
	mov rax, 0
	mov rdi, 0
	mov rdx, 1
	syscall
input_done_1:
	jmp loop_start_0
loop_end_0:
	mov rax, 60
	xor rdi, rdi
	syscall

ptr_overflow:
	mov rax, 60
	xor rdi, rdi
	syscall

ptr_underflow:
	mov rax, 60
	xor rdi, rdi
	syscall

