section .bss
	camera resb 36
	
section .text
	extern mat4_print

	extern camera_init
	extern camera_viewProjection
	
	global _start
	
_start:
	push ebp
	mov ebp, esp
	
	sub esp, 64		;matrix
	
	push camera
	call camera_init
	add esp, 4
	
	lea eax, [ebp-64]
	push eax
	push camera
	call camera_viewProjection
	add esp, 4
	
	lea eax, [ebp-64]
	push eax
	call mat4_print
	add esp, 4
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
