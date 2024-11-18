section .data
	init_values dd 45.67, -98.12, 17.69, -87.2
	initUniform_value dd -4.2
	
section .text
	extern memcpy
	
	extern vec4_print
	extern vec4_init
	extern vec4_initUniform
	
	global _start
	
_start:
	push ebp
	mov ebp, esp
	
	sub esp, 16		;alloc space for vector1
	sub esp, 16		;alloc space for vector2
	
	;init vector1
	mov eax, init_values
	mov ecx, dword[eax+12]
	push ecx
	mov ecx, dword[eax+8]
	push ecx
	mov ecx, dword[eax+4]
	push ecx
	mov ecx, dword[eax]
	push ecx
	lea eax, [ebp-16]
	push eax
	call vec4_init
	add esp, 20
	
	;init vector2
	mov eax, initUniform_value
	mov eax, dword[eax]
	push eax
	lea eax, [ebp-32]
	push eax
	call vec4_initUniform
	add esp, 8
	
	;print vector1 and vector2
	lea eax, [ebp-16]
	push eax
	call vec4_print
	lea eax, [ebp-32]
	mov dword[esp], eax
	call vec4_print
	add esp, 4
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 80h
