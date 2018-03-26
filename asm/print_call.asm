	section .data
newline_char: db 10
codes:	db '0123456789abcdef'

	section .text
	global _start

print_newline:
	mov rax, 1
	mov rdi, 1
	mov rsi, newline_char
	mov rdx, 1
	syscall
	ret

print_hex:
	mov rax, rdi 		; save param1 to rax

	mov rdi, 1		; param1: stdout
	mov rdx, 1		; param3: string length
	mov rcx, 64		; count
iterate:
	push rax		; save rax, syscall will use it

	sub rcx, 4
	sar rax, cl		; shift-right, cl is smallest part of rax
	and rax, 0x0f
	lea rsi, [codes + rax]
	mov rax, 1		; syscall number
	push rcx		; save rcx, syscall will modify it
	syscall
	pop rcx
	pop rax
	test rcx, rcx		; if count is not zero
	jnz iterate

	ret

_start:
	mov rdi, 0x1122334455667788
	call print_hex
	call print_newline

	mov rax, 60
	xor rdi, rdi
	syscall
	
