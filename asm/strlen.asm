	global _start
	section .data
test_string:	db "abcdef", 0

	section .text
strlen:
	xor rax, rax
_loop:
	cmp byte[rdi + rax], 0
	je _end
	inc rax
	jmp _loop
_end:
	ret

_start:
	mov rdi, test_string
	call strlen
	
	mov rdi, rax
	mov rax, 60
	syscall
