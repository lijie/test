	global _start
	section .data
test_string:	db "abcdef", 0

	section .text
	%include "lib.asm"
_start:
	mov rdi, test_string
	call string_length
	mov rdi, rax
	call print_uint
	call print_newline

	call read_char
	mov rdi, rax
	call print_char
	call print_newline

	mov rdi, rsp
	mov rsi, 8
	sub rsp, 8
	push rdi
	call read_word
	pop rdi
	call print_string
	call print_newline
	add rsp, 8
	
	mov rdi, 0
	call exit
