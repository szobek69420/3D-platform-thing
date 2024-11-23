section .text
	extern window_create
	extern printf
	
	global _start:
_start:
	push ebp
	mov ebp, esp
	
	sub esp, 12		;buffer for screeninfo
	
	mov eax, esp
	push eax
	call window_create
	add esp, 8
	
_start_endless_loop:
	jmp _start_endless_loop
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
	
